import 'package:flutter/material.dart';

import '../../models/produto.dart';
import '../../services/produto_service.dart';
import 'produto_form_screen.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  late Future<List<Produto>> produtosFuture;

  @override
  void initState() {
    super.initState();
    produtosFuture = ProdutoService().listarProdutos();
  }

  Future<void> carregarProdutos() async {
    setState(() {
      produtosFuture = ProdutoService().listarProdutos();
    });
  }

  String dinheiro(double valor) {
    return "R\$ ${valor.toStringAsFixed(2).replaceAll(".", ",")}";
  }

  Future<void> abrirFormulario({Produto? produto}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProdutoFormScreen(
          produto: produto,
        ),
      ),
    );

    if (resultado == true) {
      carregarProdutos();
    }
  }

  Future<void> confirmarExclusao(Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Excluir produto"),
          content: Text(
            "Deseja realmente excluir o produto ${produto.descricao}?",
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
      final resposta = await ProdutoService().excluirProduto(produto.id);

      if (resposta["sucesso"] == true) {
        carregarProdutos();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Produto excluído com sucesso"),
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resposta["erro"] ?? "Erro ao excluir produto"),
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
        title: const Text("Produtos"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          abrirFormulario();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Produto>>(
        future: produtosFuture,
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

          final produtos = snapshot.data ?? [];

          if (produtos.isEmpty) {
            return const Center(
              child: Text("Nenhum produto cadastrado"),
            );
          }

          return RefreshIndicator(
            onRefresh: carregarProdutos,
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
                      "Valor: ${dinheiro(produto.valor)}\n"
                      "Estoque: ${produto.estoqueAtual}",
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (opcao) {
                        if (opcao == "editar") {
                          abrirFormulario(produto: produto);
                        }

                        if (opcao == "excluir") {
                          confirmarExclusao(produto);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: "editar",
                          child: Text("Editar"),
                        ),
                        PopupMenuItem(
                          value: "excluir",
                          child: Text("Excluir"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}