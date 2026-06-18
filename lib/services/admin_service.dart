import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class AdminService {
  Future<Map<String, dynamic>> resetarQuermesse() async {
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/resetar_quermesse"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    return jsonDecode(response.body);
  }
}