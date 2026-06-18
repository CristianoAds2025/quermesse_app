class Oracao {
  final String titulo;
  final String categoria;
  final String texto;

  Oracao({
    required this.titulo,
    required this.categoria,
    required this.texto,
  });

  factory Oracao.fromJson(Map<String, dynamic> json) {
    return Oracao(
      titulo: json["titulo"],
      categoria: json["categoria"],
      texto: json["texto"],
    );
  }
}