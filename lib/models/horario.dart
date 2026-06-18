class Horario {

  final String hora;
  final String atividade;

  Horario({
    required this.hora,
    required this.atividade,
  });

  factory Horario.fromJson(
    Map<String, dynamic> json,
  ) {
    return Horario(
      hora: json["hora"],
      atividade: json["atividade"],
    );
  }
}