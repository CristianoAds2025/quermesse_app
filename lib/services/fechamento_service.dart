import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class FechamentoService {
  Future<Map<String, dynamic>> buscarFechamento() async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/fechamento"),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao carregar fechamento");
    }

    return jsonDecode(response.body);
  }
}