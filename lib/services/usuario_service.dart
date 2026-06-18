import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/usuario.dart';
import 'api_service.dart';

class UsuarioService {
  Future<List<Usuario>> listarUsuarios() async {
    final resposta = await http.get(
      Uri.parse("${ApiService.baseUrl}/usuarios"),
    );

    if (resposta.statusCode != 200) {
      throw Exception("Erro ao buscar usuários");
    }

    final List dados = jsonDecode(resposta.body);

    return dados.map((item) => Usuario.fromJson(item)).toList();
  }

  Future<Map<String, dynamic>> cadastrarUsuario({
    required String nomeUsuario,
    required String usuario,
    required String senha,
    required String perfil,
  }) async {
    final resposta = await http.post(
      Uri.parse("${ApiService.baseUrl}/usuarios"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "nome_usuario": nomeUsuario,
        "usuario": usuario,
        "senha": senha,
        "perfil": perfil,
      }),
    );

    return jsonDecode(resposta.body);
  }

  Future<Map<String, dynamic>> editarUsuario({
    required int id,
    required String nomeUsuario,
    required String usuario,
    required String senha,
    required String perfil,
  }) async {
    final resposta = await http.put(
      Uri.parse("${ApiService.baseUrl}/usuarios/$id"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "nome_usuario": nomeUsuario,
        "usuario": usuario,
        "senha": senha,
        "perfil": perfil,
      }),
    );

    return jsonDecode(resposta.body);
  }

  Future<Map<String, dynamic>> excluirUsuario(int id) async {
    final resposta = await http.delete(
      Uri.parse("${ApiService.baseUrl}/usuarios/$id"),
    );

    return jsonDecode(resposta.body);
  }
}