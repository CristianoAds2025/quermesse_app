import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/dia_horario.dart';

class HorarioService {

  Future<List<DiaHorario>>
      carregarHorarios() async {

    final jsonString =
        await rootBundle.loadString(
      'assets/horarios/horarios.json',
    );

    final List<dynamic> jsonData =
        json.decode(jsonString);

    return jsonData
        .map(
          (item) =>
              DiaHorario.fromJson(item),
        )
        .toList();
  }
}