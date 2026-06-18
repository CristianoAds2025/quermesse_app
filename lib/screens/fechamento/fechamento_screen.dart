import 'package:flutter/material.dart';

import '../../services/fechamento_service.dart';

class FechamentoScreen extends StatefulWidget {
  const FechamentoScreen({super.key});

  @override
  State<FechamentoScreen> createState() => _FechamentoScreenState();
}

class _FechamentoScreenState extends State<FechamentoScreen> {
  late Future<Map<String, dynamic>> fechamentoFuture;

  @override
  void initState() {
    super.initState();
    fechamentoFuture = FechamentoService().buscarFechamento();
  }

  String dinheiro(dynamic valor) {
    final numero = double.tryParse(valor.toString()) ?? 0;

    return "R\$ ${numero.toStringAsFixed(2).replaceAll(".", ",")}";
  }

  Future<void> atualizar() async {
    setState(() {
      fechamentoFuture = FechamentoService().buscarFechamento();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fechamento de Caixa"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fechamentoFuture,
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
          final resultado = dados["resultado"] as List;

          return RefreshIndicator(
            onRefresh: atualizar,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  "Data: ${dados["data"]}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                if (resultado.isEmpty)
                  const Text(
                    "Nenhuma venda encontrada para hoje.",
                    style: TextStyle(fontSize: 16),
                  ),

                ...resultado.map((item) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        item["forma_pagamento"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Troco: ${dinheiro(item["total_troco"])}",
                      ),
                      trailing: Text(
                        dinheiro(item["total"]),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                Card(
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Card(
                  child: ListTile(
                    title: const Text(
                      "TOTAL TROCO",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      dinheiro(dados["total_troco"]),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}