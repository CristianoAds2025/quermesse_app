import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class AuthService {

  Future<Map<String, dynamic>> login(
      String usuario,
      String senha) async {

    final response = await http.post(
      Uri.parse(
        '${ApiService.baseUrl}/login',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'usuario': usuario,
        'senha': senha,
      }),
    );

    return jsonDecode(response.body);
  }
}