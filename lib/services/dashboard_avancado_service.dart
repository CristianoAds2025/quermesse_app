import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class DashboardAvancadoService {
  Future<Map<String, dynamic>> buscarDados() async {
    final response = await http.get(
      Uri.parse("${ApiService.baseUrl}/dashboard_avancado"),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao carregar dashboard avançado");
    }

    return jsonDecode(response.body);
  }
}