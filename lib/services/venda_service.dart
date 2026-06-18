import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/produto.dart';
import 'api_service.dart';

class VendaService {
  Future<Map<String, dynamic>> salvarVenda({
    required int usuarioId,
    required List<Produto> itens,
    required String formaPagamento,
    double? valorRecebido,
    double? troco,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/salvar_venda"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "usuario_id": usuarioId,
        "itens": itens.map((produto) {
          return {
            "id": produto.id,
            "valor": produto.valor,
          };
        }).toList(),
        "forma_pagamento": formaPagamento,
        "valor_recebido": valorRecebido,
        "troco": troco,
      }),
    );

    return jsonDecode(response.body);
  }
}