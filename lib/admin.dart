import 'package:checador/api_service.dart';
import 'package:checador/usuario_model.dart';
import 'package:flutter/material.dart';
import 'user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class Admin extends StatefulWidget {
  const Admin({super.key, required UsuarioModel usuario});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  late Future<List<usuariomodel>> usuariosFuture;

  @override
  void initState() {
    super.initState();
    usuariosFuture = ApiService.fetchUsuarios();
  }

  Map<String, String>? _extractCoordinates(String wkt) {
    try {
      final regex = RegExp(r'POINT\s*\(\s*([-\d.]+)\s+([-\d.]+)\s*\)');
      final match = regex.firstMatch(wkt);
      if (match != null) {
        final lng = match.group(1)!; // X
        final lat = match.group(2)!; // Y
        return {'lat': lat, 'lng': lng};
      }
    } catch (e) {
      debugPrint('Error extrayendo coordenadas: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 200),
              Image.asset('assets/logo.jpeg', width: 100),
              const SizedBox(height: 20),
              const Text('Bienvenido: Admin', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              const Text('Usuarios registrados', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              FutureBuilder<List<usuariomodel>>(
                future: usuariosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay usuarios registrados');
                  } else {
                    return _buildUserTable(snapshot.data!);
                  }
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Agregar usuario"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTable(List<usuariomodel> usuarios) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 77, 249, 255)),
      ),
      child: Table(
        border: TableBorder.all(color: const Color.fromARGB(255, 82, 255, 249)),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
        },
        children: [
          _buildTableHeader(),
          ...usuarios.map(
            (usuario) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(usuario.usuario ?? 'sin nombre'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(usuario.empresa, textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () async {
                      final coords = _extractCoordinates(usuario.ubicacionWKT);
                      if (coords != null) {
                        final url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${coords['lat']},${coords['lng']}',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          debugPrint('No se pudo abrir el enlace: $url');
                        }
                      }
                    },
                    child: Text(
                      usuario.ubicacionWKT,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.edit, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return const TableRow(
      decoration: BoxDecoration(color: Color.fromARGB(255, 82, 255, 249)),
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Nombre", textAlign: TextAlign.center),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Empresa", textAlign: TextAlign.center),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Ubicacion", textAlign: TextAlign.center),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Acciones", textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
