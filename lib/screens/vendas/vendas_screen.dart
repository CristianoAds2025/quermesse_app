import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/produto.dart';
import '../../services/produto_service.dart';
import '../../services/venda_service.dart';
import '../../services/pix_service.dart';

class VendasScreen extends StatefulWidget {
  final int usuarioId;

  const VendasScreen({
    super.key,
    required this.usuarioId,
  });

  @override
  State<VendasScreen> createState() => _VendasScreenState();
}

class _VendasScreenState extends State<VendasScreen> {
  List<Produto> produtos = [];
  List<Produto> carrinho = [];

  bool carregando = true;
  String formaPagamento = "Pix";

  final valorRecebidoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  Future<void> carregarProdutos() async {
    try {
      final lista = await ProdutoService().listarProdutos();

      setState(() {
        produtos = lista.where((p) => p.estoqueAtual > 0).toList();
        carregando = false;
      });
    } catch (e) {
      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar produtos: $e")),
      );
    }
  }

  void adicionarProduto(Produto produto) {
    setState(() {
      carrinho.add(produto);
    });
  }

  void removerProduto(Produto produto) {
    setState(() {
      carrinho.remove(produto);
    });
  }

  double get total {
    return carrinho.fold(
      0,
      (soma, produto) => soma + produto.valor,
    );
  }

  double get valorRecebido {
    return double.tryParse(
          valorRecebidoController.text.replaceAll(",", "."),
        ) ??
        0;
  }

  double get troco {
    if (formaPagamento != "Dinheiro") {
      return 0;
    }

    return valorRecebido - total;
  } 

  String dinheiro(double valor) {
    return "R\$ ${valor.toStringAsFixed(2).replaceAll(".", ",")}";
  }

  Map<int, int> produtosAgrupados() {
    final Map<int, int> agrupado = {};

    for (final produto in carrinho) {
      agrupado[produto.id] = (agrupado[produto.id] ?? 0) + 1;
    }

    return agrupado;
  }

  Produto buscarProdutoPorId(int id) {
    return carrinho.firstWhere((produto) => produto.id == id);
  }

  Future<void> finalizarVenda() async {
    if (carrinho.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Adicione produtos ao carrinho")),
      );
      return;
    }
    if (formaPagamento == "Dinheiro" && valorRecebido < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Valor recebido menor que o total da venda"),
        ),
      );
      return;
    }

    try {
      final itensVenda = List<Produto>.from(carrinho);
      final totalVenda = total;
      final formaPagamentoVenda = formaPagamento;

      final valorRecebidoVenda =
          formaPagamento == "Dinheiro" ? valorRecebido : null;

      final trocoVenda =
          formaPagamento == "Dinheiro" ? troco : null;
      final resposta = await VendaService().salvarVenda(
        usuarioId: widget.usuarioId,
        itens: carrinho,
        formaPagamento: formaPagamento,
        valorRecebido: valorRecebidoVenda,
        troco: trocoVenda,
      );

      if (resposta["sucesso"] == true) {
        final numeroVenda = resposta["numero_venda"];
        final dataVenda = resposta["data_venda"];

        final imprimir = await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text("Venda finalizada"),
              content: Text(
                "Venda $numeroVenda finalizada com sucesso.\n\n"
                "Deseja imprimir o comprovante?",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text("NÃO"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text("IMPRIMIR"),
                ),
              ],
            );
          },
        );

        if (imprimir == true) {
          await imprimirComprovante(
            numeroVenda: numeroVenda,
            dataVenda: dataVenda,
            formaPagamentoVenda: formaPagamentoVenda,
            itensVenda: itensVenda,
            totalVenda: totalVenda,
            valorRecebidoVenda: valorRecebidoVenda,
            trocoVenda: trocoVenda,
          );
        }

        setState(() {
          carrinho.clear();
          valorRecebidoController.clear();
        });

        await carregarProdutos();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Venda $numeroVenda finalizada com sucesso!"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resposta["erro"] ?? "Erro ao salvar venda"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao finalizar venda: $e"),
        ),
      );
    }
  }

  Future<void> mostrarPix() async {
    if (carrinho.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Adicione produtos ao carrinho"),
        ),
      );
      return;
    }

    try {
      final pix = await PixService().gerarPix(total);

      final copiaCola = pix["copia_cola"];

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Pagamento PIX"),
            content: SizedBox(
              width: 350,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      "Total: ${dinheiro(total)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: 220,
                      height: 220,
                      alignment: Alignment.center,
                      child: QrImageView(
                        data: copiaCola,
                        size: 200,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SelectableText(
                      copiaCola,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: copiaCola),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Código PIX copiado"),
                    ),
                  );
                },
                child: const Text("COPIAR PIX"),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("FECHAR"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao gerar PIX: $e"),
        ),
      );
    }
  }

  Future<void> imprimirComprovante({
    required int numeroVenda,
    required String dataVenda,
    required String formaPagamentoVenda,
    required List<Produto> itensVenda,
    required double totalVenda,
    double? valorRecebidoVenda,
    double? trocoVenda,
  }) async {
    final itensParaImprimir = itensVenda
        .where((produto) => produto.imprimirCupom == true)
        .toList();

    if (itensParaImprimir.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nenhum item marcado para imprimir cupom"),
        ),
      );
      return;
    }

    double totalImpressao = 0;

    for (final item in itensParaImprimir) {
      totalImpressao += item.valor;
    }

    String moeda(double valor) {
      return "R\$ ${valor.toStringAsFixed(2).replaceAll(".", ",")}";
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 5,
        ),
        build: (pw.Context context) {
          return pw.Container(
            width: double.infinity,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "COMUNIDADE SÃO FRANCISCO DE ASSIS",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    font: pw.Font.courier(),
                  ),
                ),

                pw.Divider(),

                pw.Text(
                  "Venda Nº: $numeroVenda",
                  style: pw.TextStyle(
                    fontSize: 10,
                    font: pw.Font.courier(),
                  ),
                ),

                pw.Text(
                  "Data: $dataVenda",
                  style: pw.TextStyle(
                    fontSize: 10,
                    font: pw.Font.courier(),
                  ),
                ),

                pw.Divider(),

                ...itensParaImprimir.map((item) {
                  return pw.Column(
                    children: [
                      pw.SizedBox(height: 10),

                      pw.Text(
                        item.descricao,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 18,
                          font: pw.Font.courier(),
                        ),
                      ),

                      pw.Text(
                        moeda(item.valor),
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 18,
                          font: pw.Font.courier(),
                        ),
                      ),

                      pw.SizedBox(height: 10),

                      pw.Divider(),
                    ],
                  );
                }),

                pw.SizedBox(height: 10),

                pw.Text(
                  "TOTAL: ${moeda(totalImpressao)}",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    font: pw.Font.courier(),
                  ),
                ),

                pw.Divider(),

                pw.Text(
                  "© 2026 - Quermesse Online",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 10,
                    font: pw.Font.courier(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agrupado = produtosAgrupados();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendas"),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final produto = produtos[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            produto.descricao,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "${dinheiro(produto.valor)} | Estoque: ${produto.estoqueAtual}",
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => adicionarProduto(produto),
                            child: const Text("+"),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Carrinho",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (carrinho.isEmpty)
                        const Text("Nenhum item adicionado"),

                      ...agrupado.entries.map((entry) {
                        final produto = buscarProdutoPorId(entry.key);
                        final quantidade = entry.value;

                        return SizedBox(
                          height: 22,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${quantidade}x ${produto.descricao}",
                                style: const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                onPressed: () => removerProduto(produto),
                                icon: const Icon(
                                  Icons.remove_circle,
                                  size: 17,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 10),

                      Text(
                        "Total: ${dinheiro(total)}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: formaPagamento,
                        decoration: const InputDecoration(
                          labelText: "Forma de pagamento",
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Pix",
                            child: Text("Pix"),
                          ),
                          DropdownMenuItem(
                            value: "Dinheiro",
                            child: Text("Dinheiro"),
                          ),
                          DropdownMenuItem(
                            value: "Crédito",
                            child: Text("Crédito"),
                          ),
                          DropdownMenuItem(
                            value: "Débito",
                            child: Text("Débito"),
                          ),
                        ],
                        onChanged: (valor) {
                          setState(() {
                            formaPagamento = valor!;
                          });
                        },
                      ),

                      if (formaPagamento == "Pix") ...[
                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          iconAlignment: IconAlignment.start,
                          onPressed: mostrarPix,
                          icon: const Icon(Icons.qr_code,
                          size: 18,),
                          label: const Text("GERAR PIX"),
                        ),
                      ],

                      if (formaPagamento == "Dinheiro") ...[
                        const SizedBox(height: 12),

                        TextField(
                          controller: valorRecebidoController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Valor recebido",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Troco: ${dinheiro(troco < 0 ? 0 : troco)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      ElevatedButton(
                        onPressed: finalizarVenda,
                        child: const Text("FINALIZAR VENDA"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}