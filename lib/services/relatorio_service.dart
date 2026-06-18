import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class RelatorioService {
  Future<Map<String, dynamic>> buscarRelatorios({
    String? dataInicio,
    String? dataFim,
  }) async {
    String url = "${ApiService.baseUrl}/relatorios";

    if (dataInicio != null && dataFim != null) {
      url += "?data_inicio=$dataInicio&data_fim=$dataFim";
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Erro ao carregar relatórios");
    }

    return jsonDecode(response.body);
  }
  Future<List<dynamic>> buscarItensVenda(int numeroVenda) async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/itens_venda/$numeroVenda"),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao carregar itens da venda");
    }

    return jsonDecode(response.body);
  }
  Future<Map<String, dynamic>> excluirVenda(int numeroVenda) async {
    final response = await http.delete(
      Uri.parse("${ApiService.baseUrl}/excluir_venda/$numeroVenda"),
    );

    return jsonDecode(response.body);
  }
}