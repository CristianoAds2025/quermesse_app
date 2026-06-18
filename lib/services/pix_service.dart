import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class PixService {
  Future<Map<String, dynamic>> gerarPix(double valor) async {
    final response = await http.post(
      Uri.parse("${ApiService.baseUrl}/gerar_pix"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "valor": valor,
      }),
    );

    return jsonDecode(response.body);
  }
}