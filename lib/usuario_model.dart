class UsuarioModel {
  final String usuario;
  final int rol;

  UsuarioModel({
    required this.usuario,
    required this.rol,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      usuario: json['usuario'],
      rol: json['rol'],
    );
  }
}

