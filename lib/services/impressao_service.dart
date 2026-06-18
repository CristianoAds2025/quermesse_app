import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ImpressaoService {
  static Future<void> imprimirCupom({
    required int numeroVenda,
    required String dataVenda,
    required List<Map<String, dynamic>> itens,
  }) async {
    final itensParaImprimir = itens.where((item) {
      return item["imprimir_cupom"] == true;
    }).toList();

    if (itensParaImprimir.isEmpty) {
      return;
    }

    double total = 0;

    for (final item in itensParaImprimir) {
      total += double.tryParse(item["valor_total"].toString()) ?? 0;
    }

    String moeda(double valor) {
      return "R\$ ${valor.toStringAsFixed(2).replaceAll(".", ",")}";
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm,
          2000 * PdfPageFormat.mm,
        ),
        margin: const pw.EdgeInsets.all(5),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                "COMUNIDADE SÃO FRANCISCO DE ASSIS",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.Divider(),

              pw.Text("Venda Nº: $numeroVenda"),
              pw.Text("Data: $dataVenda"),

              pw.Divider(),

              ...itensParaImprimir.map((item) {
                return pw.Column(
                  children: [
                    pw.SizedBox(height: 10),
                    pw.Text(
                      item["descricao"].toString(),
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                    pw.Text(
                      moeda(
                        double.tryParse(
                              item["valor_total"].toString(),
                            ) ??
                            0,
                      ),
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(),
                  ],
                );
              }),

              pw.Text(
                "TOTAL: ${moeda(total)}",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.Divider(),

              pw.Text("© 2026 - Quermesse Online"),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: "cupom_venda_$numeroVenda.pdf",
      onLayout: (format) async {
        return pdf.save();
      },
    );
  }
}