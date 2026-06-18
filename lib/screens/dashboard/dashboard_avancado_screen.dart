import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../services/dashboard_avancado_service.dart';

class DashboardAvancadoScreen extends StatefulWidget {
  const DashboardAvancadoScreen({super.key});

  @override
  State<DashboardAvancadoScreen> createState() =>
      _DashboardAvancadoScreenState();
}

class _DashboardAvancadoScreenState extends State<DashboardAvancadoScreen> {
  late Future<Map<String, dynamic>> dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = DashboardAvancadoService().buscarDados();
  }

  Future<void> atualizar() async {
    setState(() {
      dashboardFuture = DashboardAvancadoService().buscarDados();
    });
  }

  String dinheiro(dynamic valor) {
    final numero = double.tryParse(valor.toString()) ?? 0;
    return "R\$ ${numero.toStringAsFixed(2).replaceAll(".", ",")}";
  }

  Widget tituloSecao(String texto) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 8,
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget itemResumo({
    required String titulo,
    required String subtitulo,
    required String valor,
  }) {
    return Card(
      child: ListTile(
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitulo),
        trailing: Text(
          valor,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> gerarPdfDashboard(Map<String, dynamic> dados) async {
    final pdf = pw.Document();

    final porForma = dados["por_forma"] as List;
    final maisVendidos = dados["mais_vendidos"] as List;
    final porOperador = dados["por_operador"] as List;

    String dinheiro(dynamic valor) {
      final numero = double.tryParse(valor.toString()) ?? 0;
      return "R\$ ${numero.toStringAsFixed(2).replaceAll(".", ",")}";
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return [
            pw.Center(
              child: pw.Text(
                "Relatório Geral de Vendas",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Text(
              "Total Geral Arrecadado: ${dinheiro(dados["total_geral"])}",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Text(
              "Vendas por Forma de Pagamento",
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Table.fromTextArray(
              headers: ["Forma", "Total"],
              data: porForma.map((item) {
                return [
                  item["forma_pagamento"] ?? "Não informado",
                  dinheiro(item["total"]),
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 20),

            pw.Text(
              "Produtos Mais Vendidos",
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Table.fromTextArray(
              headers: ["Produto", "Quantidade", "Total"],
              data: maisVendidos.map((item) {
                return [
                  item["descricao"] ?? "Produto",
                  item["quantidade"].toString(),
                  dinheiro(item["total"]),
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 20),

            pw.Text(
              "Vendas por Operador",
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Table.fromTextArray(
              headers: ["Operador", "Vendas", "Total"],
              data: porOperador.map((item) {
                return [
                  item["nome_usuario"] ?? "Operador",
                  item["vendas"].toString(),
                  dinheiro(item["total"]),
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 30),

            pw.Center(
              child: pw.Text(
                "Quermesse Online",
                style: const pw.TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      name: "dashboard_avancado.pdf",
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatório Geral de Vendas"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: dashboardFuture,
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

          final porForma = dados["por_forma"] as List;
          final maisVendidos = dados["mais_vendidos"] as List;
          final porOperador = dados["por_operador"] as List;

          return RefreshIndicator(
            onRefresh: atualizar,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    gerarPdfDashboard(dados);
                  },
                  icon: const Icon(
                    Icons.picture_as_pdf,
                    size: 18,
                  ),
                  label: const Text("GERAR PDF"),
                ),

                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    title: const Text(
                      "Total Geral Arrecadado",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      dinheiro(dados["total_geral"]),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                tituloSecao("Vendas por Forma de Pagamento"),

                if (porForma.isEmpty)
                  const Text("Nenhuma venda registrada."),

                ...porForma.map((item) {
                  return itemResumo(
                    titulo: item["forma_pagamento"] ?? "Não informado",
                    subtitulo: "Forma de pagamento",
                    valor: dinheiro(item["total"]),
                  );
                }),

                tituloSecao("Produtos Mais Vendidos"),

                if (maisVendidos.isEmpty)
                  const Text("Nenhum produto vendido."),

                ...maisVendidos.map((item) {
                  return itemResumo(
                    titulo: item["descricao"] ?? "Produto",
                    subtitulo: "Quantidade: ${item["quantidade"]}",
                    valor: dinheiro(item["total"]),
                  );
                }),

                tituloSecao("Vendas por Operador"),

                if (porOperador.isEmpty)
                  const Text("Nenhuma venda por operador."),

                ...porOperador.map((item) {
                  return itemResumo(
                    titulo: item["nome_usuario"] ?? "Operador",
                    subtitulo: "Vendas: ${item["vendas"]}",
                    valor: dinheiro(item["total"]),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}