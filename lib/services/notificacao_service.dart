import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/notificacao.dart';

class NotificacaoService {
  final String baseUrl = "https://quermesse-app.onrender.com";

  Future<List<Notificacao>> listarNotificacoes() async {
    final url = Uri.parse("$baseUrl/api/notificacoes");

    final resposta = await http.get(url);

    if (resposta.statusCode != 200) {
      throw Exception("Erro ao buscar notificações");
    }

    final List<dynamic> dados = json.decode(resposta.body);

    return dados
        .map((item) => Notificacao.fromJson(item))
        .toList();
  }

  Future<Map<String, dynamic>> enviarNotificacao({
    required String titulo,
    required String mensagem,
  }) async {
    final url = Uri.parse("$baseUrl/api/notificacoes");

    final resposta = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "titulo": titulo,
        "mensagem": mensagem,
      }),
    );

    return json.decode(resposta.body);
  }

  Future<Map<String, dynamic>> marcarComoLida(int id) async {
    final url = Uri.parse("$baseUrl/api/notificacoes/$id/lida");

    final resposta = await http.put(url);

    return json.decode(resposta.body);
  }
}