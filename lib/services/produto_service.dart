import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/produto.dart';
import 'api_service.dart';

class ProdutoService {
  Future<List<Produto>> listarProdutos() async {
    final url = Uri.parse("${ApiService.baseUrl}/produtos");

    final resposta = await http.get(url);

    if (resposta.statusCode != 200) {
      throw Exception("Erro ao buscar produtos");
    }

    final List dados = jsonDecode(resposta.body);

    return dados.map((item) => Produto.fromJson(item)).toList();
  }

  Future<Map<String, dynamic>> cadastrarProduto({
    required String descricao,
    required double valor,
    required int estoqueInicial,
    required bool imprimirCupom,
  }) async {
    final resposta = await http.post(
      Uri.parse("${ApiService.baseUrl}/produtos"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "descricao": descricao,
        "valor": valor,
        "estoque_inicial": estoqueInicial,
        "imprimir_cupom": imprimirCupom,
      }),
    );

    return jsonDecode(resposta.body);
  }

  Future<Map<String, dynamic>> editarProduto({
    required int id,
    required String descricao,
    required double valor,
    required int estoqueInicial,
    required bool imprimirCupom,
  }) async {
    final resposta = await http.put(
      Uri.parse("${ApiService.baseUrl}/produtos/$id"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "descricao": descricao,
        "valor": valor,
        "estoque_inicial": estoqueInicial,
        "imprimir_cupom": imprimirCupom,
      }),
    );

    return jsonDecode(resposta.body);
  }

  Future<Map<String, dynamic>> excluirProduto(int id) async {
    final resposta = await http.delete(
      Uri.parse("${ApiService.baseUrl}/produtos/$id"),
    );

    return jsonDecode(resposta.body);
  }
}