import 'package:flutter/material.dart';

import '../../models/produto.dart';
import '../../services/produto_service.dart';

class ProdutoFormScreen extends StatefulWidget {
  final Produto? produto;

  const ProdutoFormScreen({
    super.key,
    this.produto,
  });

  @override
  State<ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
  final descricaoController = TextEditingController();
  final valorController = TextEditingController();
  final estoqueController = TextEditingController();

  bool imprimirCupom = false;
  bool salvando = false;

  bool get editando => widget.produto != null;

  @override
  void initState() {
    super.initState();

    if (editando) {
      descricaoController.text = widget.produto!.descricao;
      valorController.text = widget.produto!.valor.toStringAsFixed(2);
      estoqueController.text = widget.produto!.estoqueInicial.toString();
      imprimirCupom = widget.produto!.imprimirCupom;
    }
  }

  Future<void> salvar() async {
    final descricao = descricaoController.text.trim();
    final valorTexto = valorController.text.trim().replaceAll(",", ".");
    final estoqueTexto = estoqueController.text.trim();

    if (descricao.isEmpty || valorTexto.isEmpty || estoqueTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos"),
        ),
      );
      return;
    }

    final valor = double.tryParse(valorTexto);
    final estoque = int.tryParse(estoqueTexto);

    if (valor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Valor inválido"),
        ),
      );
      return;
    }

    if (estoque == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Estoque inválido"),
        ),
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      Map<String, dynamic> resposta;

      if (editando) {
        resposta = await ProdutoService().editarProduto(
          id: widget.produto!.id,
          descricao: descricao,
          valor: valor,
          estoqueInicial: estoque,
          imprimirCupom: imprimirCupom,
        );
      } else {
        resposta = await ProdutoService().cadastrarProduto(
          descricao: descricao,
          valor: valor,
          estoqueInicial: estoque,
          imprimirCupom: imprimirCupom,
        );
      }

      if (resposta["sucesso"] == true) {
        if (!mounted) return;

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resposta["erro"] ?? "Erro ao salvar produto"),
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

    setState(() {
      salvando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? "Editar Produto" : "Novo Produto"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: descricaoController,
            decoration: const InputDecoration(
              labelText: "Descrição",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: valorController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Valor",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: estoqueController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Estoque inicial",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          SwitchListTile(
            title: const Text("Imprimir cupom"),
            value: imprimirCupom,
            onChanged: (valor) {
              setState(() {
                imprimirCupom = valor;
              });
            },
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: salvando ? null : salvar,
            child: salvando
                ? const CircularProgressIndicator()
                : Text(editando ? "SALVAR ALTERAÇÕES" : "CADASTRAR"),
          ),
        ],
      ),
    );
  }
}