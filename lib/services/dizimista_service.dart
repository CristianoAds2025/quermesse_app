import 'dart:convert';
import 'package:http/http.dart' as http;

class DizimistaService {
  final String baseUrl = "https://quermesse-app.onrender.com";

  Future<Map<String, dynamic>> cadastrarDizimista({
    required String cpf,
    required String nome,
    required String email,
    required String dataNascimento,
    required String whatsapp,
    required bool casado,
    required String nomeConjuge,
    required String dataNascimentoConjuge,
    required String ruaAvenida,
    required String numero,
  }) async {
    final url = Uri.parse("$baseUrl/api/dizimistas");

    final resposta = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "cpf": cpf,
        "nome": nome,
        "email": email,
        "data_nascimento": dataNascimento,
        "whatsapp": whatsapp,
        "casado": casado,
        "nome_conjuge": nomeConjuge,
        "data_nascimento_conjuge": dataNascimentoConjuge,
        "rua_avenida": ruaAvenida,
        "numero": numero,
      }),
    );

    return json.decode(resposta.body);
  }
}