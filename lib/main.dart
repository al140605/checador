import 'package:checador/sincronizador.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'usuario_model.dart';
import 'usuarios.dart'; // Asegúrate de que no haya conflicto con UsuarioModel
import 'admin.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  
  // Inicializa sqflite para escritorio (Windows, Linux, macOS)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checador',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 250, 0, 0)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Bienvenidos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  String _message = '';

  void _login() async {
    String username = _userController.text.trim();
    String password = _passController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Por favor, completa todos los campos.';
      });
      return;
    }

    UsuarioModel? usuario = await ApiService.login(username, password);

    if (usuario != null) {
      setState(() {
        _message = 'Login exitoso';
      });

      if (usuario.rol == 1) {
        await sincronizarChecadasPendientes();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Admin(usuario: usuario)),
        );
      } else if (usuario.rol == 2) {
        await sincronizarChecadasPendientes();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Usuario(usuario: usuario)),
        );
      } else {
        setState(() {
          _message = 'Rol no reconocido';
        });
      }
    } else {
      setState(() {
        _message = 'Credenciales incorrectas';
      });
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Image.asset('assets/logo.jpeg', height: 80),
                const SizedBox(height: 20),
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontSize: 24, color: Color.fromARGB(255, 10, 10, 10)),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _userController,
                  style: const TextStyle(color: Color.fromARGB(255, 6, 6, 6)),
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 11, 11, 11)),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passController,
                  style: const TextStyle(color: Color.fromARGB(255, 6, 6, 6)),
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 1, 1, 1)),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Ingresar'),
                ),
                const SizedBox(height: 20),
                Text(
                  _message,
                  style: TextStyle(
                    color: _message == 'Login exitoso' ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}