import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/oracao.dart';

class OracaoService {

  Future<List<Oracao>> carregarOracoes() async {

    final jsonString = await rootBundle.loadString(
      'assets/oracoes/oracoes.json',
    );

    final List<dynamic> jsonData =
        json.decode(jsonString);

    return jsonData
        .map((item) => Oracao.fromJson(item))
        .toList();
  }
}