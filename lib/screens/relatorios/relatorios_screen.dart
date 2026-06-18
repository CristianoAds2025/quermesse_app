import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'itens_venda_screen.dart';

import '../../services/relatorio_service.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  late Future<Map<String, dynamic>> relatorioFuture;

  final dataInicioController = TextEditingController();
  final dataFimController = TextEditingController();

  @override
  void initState() {
    super.initState();
    relatorioFuture = RelatorioService().buscarRelatorios();
  }

  String dinheiro(dynamic valor) {
    final numero = double.tryParse(valor.toString()) ?? 0;
    return "R\$ ${numero.toStringAsFixed(2).replaceAll(".", ",")}";
  }

  void consultar() {
    setState(() {
      relatorioFuture = RelatorioService().buscarRelatorios(
        dataInicio: dataInicioController.text.trim().isEmpty
            ? null
            : dataInicioController.text.trim(),
        dataFim: dataFimController.text.trim().isEmpty
            ? null
            : dataFimController.text.trim(),
      );
    });
  }

  Future<void> abrirUri(Uri uri) async {
    if (!await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: "_blank",
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Não foi possível abrir o arquivo"),
        ),
      );
    }
  }

  String montarFiltros() {
    final dataInicio = dataInicioController.text.trim();
    final dataFim = dataFimController.text.trim();

    String filtros = "";

    if (dataInicio.isNotEmpty) {
      filtros += "data_inicio=$dataInicio";
    }

    if (dataFim.isNotEmpty) {
      if (filtros.isNotEmpty) {
        filtros += "&";
      }

      filtros += "data_fim=$dataFim";
    }

    if (filtros.isNotEmpty) {
      filtros = "?$filtros";
    }

    return filtros;
  }

  Future<void> baixarPdf() async {
    final filtros = montarFiltros();

    final url = Uri.parse(
      "https://quermesse-app.onrender.com/api/relatorio_vendas_pdf$filtros",
    );

    await abrirUri(url);
  }

  Future<void> baixarExcel() async {
    final filtros = montarFiltros();

    final url = Uri.parse(
      "https://quermesse-app.onrender.com/api/relatorio_vendas_excel$filtros",
    );

    await abrirUri(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatório de Vendas"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: dataInicioController,
                  decoration: const InputDecoration(
                    labelText: "Data inicial",
                    hintText: "2026-06-05",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: dataFimController,
                  decoration: const InputDecoration(
                    labelText: "Data final",
                    hintText: "2026-06-05",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: consultar,
                    child: const Text("CONSULTAR"),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        iconAlignment: IconAlignment.start,
                        onPressed: baixarPdf,
                        icon: const Icon(Icons.picture_as_pdf,
                        size: 18,),
                        label: const Text("PDF"),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton.icon(
                        iconAlignment: IconAlignment.start,
                        onPressed: baixarExcel,
                        icon: const Icon(Icons.table_chart,
                        size: 18,),
                        label: const Text("EXCEL"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: relatorioFuture,
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

                final dados = snapshot.data!;
                final vendas = dados["vendas"] as List;

                return Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        title: const Text(
                          "TOTAL GERAL",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          dinheiro(dados["total_geral"]),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: vendas.length,
                        itemBuilder: (context, index) {
                          final venda = vendas[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              onTap: () async {
                                final resultado = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItensVendaScreen(
                                      numeroVenda: venda["numero_venda"],
                                    ),
                                  ),
                                );

                                if (resultado == true) {
                                  consultar();
                                }
                              },

                              title: Text(
                                "Venda ${venda["numero_venda"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              subtitle: Text(
                                "${venda["data_venda"]}\n"
                                "${venda["forma_pagamento"]} - ${venda["nome_usuario"]}",
                              ),

                              trailing: Text(
                                dinheiro(venda["total"]),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}