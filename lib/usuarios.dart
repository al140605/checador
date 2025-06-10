import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'usuario_model.dart';
import 'db_helper.dart';
import 'checada_model.dart'; // <-- Asegúrate de importar tu modelo

class Usuario extends StatefulWidget {
  final UsuarioModel usuario;

  const Usuario({super.key, required this.usuario});

  @override
  State<Usuario> createState() => _UsuarioState();
}

class _UsuarioState extends State<Usuario> {
  String _message = '';
  String? _selectedCompany;

  final List<String> _companies = [
    'Empresa A',
    'Empresa B',
    'Empresa C',
    'Empresa D',
  ];

  final DBHelper _dbHelper = DBHelper();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _verificarConexionYSincronizar();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        await _sincronizarChecadasGuardadas();
      }
    });
  }

  Future<void> _verificarConexionYSincronizar() async {
    var result = await Connectivity().checkConnectivity();
    if (result != ConnectivityResult.none) {
      await _sincronizarChecadasGuardadas();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _enviarChecada() async {
    if (_selectedCompany == null) {
      setState(() {
        _message = 'Por favor selecciona una empresa';
      });
      return;
    }

    try {
      final coords = await _obtenerUbicacion();
      final now = DateTime.now();
      final fecha = now.toIso8601String().split('T')[0];
      final hora = now.toIso8601String().split('T')[1].substring(0, 8);

      final nuevaChecada = ChecadaModel(
        usuario: widget.usuario.usuario,
        empresa: _selectedCompany!,
        fecha: fecha,
        hora: hora,
        longitud: coords[0],
        latitud: coords[1],
        idUsuario: 0, // Puedes ajustar si usas ID real
      );

      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        await _dbHelper.insertChecada(nuevaChecada.toMap());
        setState(() {
          _message = 'Sin conexión. Checada guardada localmente.';
        });
      } else {
        final response = await http.post(
          Uri.parse('http://localhost:7203/api/usuarios/checada'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(nuevaChecada.toJsonForApi()),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            _message = 'Checada exitosa';
          });
          await _sincronizarChecadasGuardadas();
        } else {
          final error = jsonDecode(response.body)['mensaje'] ?? 'Error desconocido';
          setState(() {
            _message = 'Error al checar: $error';
          });
        }
      }
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _sincronizarChecadasGuardadas() async {
    final checadasLocales = await _dbHelper.getChecadas();
    final url = Uri.parse('http://localhost:7203/api/usuarios/checada');

    for (var checada in checadasLocales) {
      final checadaModel = ChecadaModel.fromMap(checada);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(checadaModel.toJsonForApi()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _dbHelper.deleteChecada(checada['id'] as int);
      }
    }
  }

  Future<List<double>> _obtenerUbicacion() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('El servicio de ubicación está deshabilitado.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permiso de ubicación denegado permanentemente.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return [position.longitude, position.latitude];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset('assets/logo.jpeg', height: 80),
                  const SizedBox(height: 20),
                  Text(
                    'Bienvenido: ${widget.usuario.usuario}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('assets/usuario.jpg'),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: const Color.fromARGB(255, 63, 201, 255),
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Selecciona la empresa correspondiente:',
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    dropdownColor: const Color.fromARGB(255, 249, 249, 249),
                    value: _selectedCompany,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 67, 189, 255),
                      border: OutlineInputBorder(),
                    ),
                    items: _companies.map((String company) {
                      return DropdownMenuItem<String>(
                        value: company,
                        child: Text(company),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCompany = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _enviarChecada,
                    child: const Text('Checar'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _message,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
