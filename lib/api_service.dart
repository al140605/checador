import 'dart:convert';
import 'package:http/http.dart' as http;
import 'usuario_model.dart';
import 'user_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:7203/api';
  static const String registrosEndpoint = '$baseUrl/Registros';
  static const String usuariosEndpoint = '$baseUrl/Usuarios';

  /// Login de usuario
  static Future<UsuarioModel?> login(String username, String password) async {
    try {
      final url = Uri.parse('$registrosEndpoint/login');
      print('Conectando a: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json.containsKey('usuario') && json.containsKey('rol')) {
          return UsuarioModel.fromJson(json);
        } else {
          print('Respuesta JSON inválida: $json');
          return null;
        }
      } else {
        print('Error HTTP: ${response.statusCode}, cuerpo: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  /// Enviar checada
  static Future<bool> enviarChecada(Map<String, dynamic> checada) async {
    try {
      final url = Uri.parse('$usuariosEndpoint/checadas');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(checada),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Checada enviada con éxito.');
        return true;
      } else {
        print('Error al enviar checada: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción al enviar checada: $e');
      return false;
    }
  }

  /// Obtener lista de usuarios
  static Future<List<usuariomodel>> fetchUsuarios() async {
    try {
      final url = Uri.parse('$usuariosEndpoint/mostrar');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => usuariomodel.fromJson(e)).toList();
      } else {
        print('Error al cargar usuarios: ${response.statusCode} - ${response.body}');
        throw Exception('Error al cargar usuarios');
      }
    } catch (e) {
      print('Excepción al obtener usuarios: $e');
      rethrow;
    }
  }
}
