import 'package:flutter/material.dart';

import '../../services/relatorio_service.dart';
import '../../services/impressao_service.dart';

class ItensVendaScreen extends StatefulWidget {
  final int numeroVenda;

  const ItensVendaScreen({
    super.key,
    required this.numeroVenda,
  });

  @override
  State<ItensVendaScreen> createState() => _ItensVendaScreenState();
}

class _ItensVendaScreenState extends State<ItensVendaScreen> {
  late Future<List<dynamic>> itensFuture;

  @override
  void initState() {
    super.initState();
    itensFuture = RelatorioService().buscarItensVenda(widget.numeroVenda);
  }

  String dinheiro(dynamic valor) {
    final numero = double.tryParse(valor.toString()) ?? 0;
    return "R\$ ${numero.toStringAsFixed(2).replaceAll(".", ",")}";
  }

  Future<void> confirmarExclusaoVenda() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Excluir venda"),
          content: Text(
            "Deseja realmente excluir a venda ${widget.numeroVenda}?\n\n"
            "O estoque dos produtos será restaurado.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("CANCELAR"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("EXCLUIR"),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      final resposta = await RelatorioService().excluirVenda(
        widget.numeroVenda,
      );

      if (resposta["sucesso"] == true) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Venda excluída com sucesso"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resposta["erro"] ?? "Erro ao excluir venda",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Venda ${widget.numeroVenda}"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: itensFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Erro: ${snapshot.error}"),
            );
          }

          final itens = snapshot.data ?? [];

          if (itens.isEmpty) {
            return const Center(
              child: Text("Nenhum item encontrado."),
            );
          }

          final dataVenda = itens.first["data_venda"];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                "Data: $dataVenda",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              ...itens.map((item) {
                return Card(
                  child: ListTile(
                    title: Text(
                      item["descricao"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Quantidade: ${item["quantidade"]}",
                    ),
                    trailing: Text(
                      dinheiro(item["valor_total"]),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  title: const Text(
                    "TOTAL DA VENDA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    dinheiro(
                      itens.fold<double>(
                        0,
                        (soma, item) =>
                            soma +
                            (double.tryParse(
                                  item["valor_total"].toString(),
                                ) ??
                                0),
                      ),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

                ElevatedButton.icon(
                  iconAlignment: IconAlignment.start,
                  onPressed: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Preparando impressão..."),
                        ),
                      );

                      final itens = await itensFuture;

                      if (itens.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Nenhum item para imprimir"),
                          ),
                        );
                        return;
                      }

                      await ImpressaoService.imprimirCupom(
                        numeroVenda: widget.numeroVenda,
                        dataVenda: itens.first["data_venda"],
                        itens: itens
                            .map((item) => Map<String, dynamic>.from(item))
                            .toList(),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Erro ao imprimir: $e"),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.print,
                  size: 18,),
                  label: const Text("IMPRIMIR"),
                ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  iconAlignment: IconAlignment.start,
                  onPressed: confirmarExclusaoVenda,
                  icon: const Icon(Icons.delete,
                  size: 18,),
                  label: const Text("EXCLUIR VENDA"),
                ),
            ],
          );
        },
      ),
    );
  }
}