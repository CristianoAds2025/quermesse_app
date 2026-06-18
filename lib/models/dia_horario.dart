import 'horario.dart';

class DiaHorario {

  final String dia;
  final List<Horario> horarios;

  DiaHorario({
    required this.dia,
    required this.horarios,
  });

  factory DiaHorario.fromJson(
    Map<String, dynamic> json,
  ) {
    return DiaHorario(
      dia: json["dia"],

      horarios: (json["horarios"] as List)
          .map(
            (item) =>
                Horario.fromJson(item),
          )
          .toList(),
    );
  }
}