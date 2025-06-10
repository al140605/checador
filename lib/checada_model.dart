class ChecadaModel {
  final String usuario;
  final String empresa;
  final String fecha;
  final String hora;
  final double longitud;
  final double latitud;
  final int idUsuario;
  final int? idLocal; // ID local en SQLite (opcional)

  ChecadaModel({
    required this.usuario,
    required this.empresa,
    required this.fecha,
    required this.hora,
    required this.longitud,
    required this.latitud,
    required this.idUsuario,
    this.idLocal,
  });

  factory ChecadaModel.fromMap(Map<String, dynamic> map) {
    return ChecadaModel(
      usuario: map['usuario'],
      empresa: map['empresa'],
      fecha: map['fecha'],
      hora: map['hora'],
      longitud: map['longitud'],
      latitud: map['latitud'],
      idUsuario: map['id_usuario'] ?? 0,
      idLocal: map['id'], // solo para SQLite
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuario': usuario,
      'empresa': empresa,
      'fecha': fecha,
      'hora': hora,
      'longitud': longitud,
      'latitud': latitud,
      'id_usuario': idUsuario,
    };
  }

  /// 🔄 JSON formateado para el backend .NET
  Map<String, dynamic> toJsonForApi() {
    return {
      'usuario': usuario,
      'empresa': empresa,
      'fecha': fecha,
      'hora': hora,
      'ubicacionWKT': 'POINT($longitud $latitud)',
    };
  }
}

