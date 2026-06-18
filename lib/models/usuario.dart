class Usuario {
  final int id;
  final String nomeUsuario;
  final String usuario;
  final String perfil;

  Usuario({
    required this.id,
    required this.nomeUsuario,
    required this.usuario,
    required this.perfil,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json["id"],
      nomeUsuario: json["nome_usuario"],
      usuario: json["usuario"],
      perfil: json["perfil"],
    );
  }
}