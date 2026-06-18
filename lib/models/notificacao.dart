class Notificacao {
  final int id;
  final String titulo;
  final String mensagem;
  final String dataEnvio;
  final bool lida;

  Notificacao({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.dataEnvio,
    required this.lida,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json["id"],
      titulo: json["titulo"],
      mensagem: json["mensagem"],
      dataEnvio: json["data_envio"],
      lida: json["lida"] ?? false,
    );
  }
}