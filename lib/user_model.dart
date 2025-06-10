class usuariomodel {
  final int? idUsuario;
  final String? usuario;
  final String empresa;
  final String fecha;
  final String hora;
  final String ubicacionWKT;

  usuariomodel({
    this.idUsuario,
    this.usuario,
    required this.empresa,
    required this.fecha,
    required this.hora,
    required this.ubicacionWKT,
  });

  factory usuariomodel.fromJson(Map<String, dynamic> json) {
    return usuariomodel(
      idUsuario: json['id_usuario'] as int?,
    usuario: json['usuario'] ?? '',
      empresa: json['empresa'],
      fecha: json['fecha'],
      hora: json['hora'],
      ubicacionWKT: json['ubicacionWKT'],
    );
  }
}
