import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';
import 'db_helper.dart';

/// Verifica si hay conexión a Internet
Future<bool> tieneInternet() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

/// Sincroniza las checadas pendientes con el servidor si hay conexión
Future<void> sincronizarChecadasPendientes() async {
  if (await tieneInternet()) {
    final checadas = await DBHelper().getChecadas();

    for (var checada in checadas) {
      try {
        bool exito = await ApiService.enviarChecada(checada);
        if (exito) {
          await DBHelper().deleteChecada(checada['id']);
        }
      } catch (e) {
        print('Error al sincronizar checada ${checada['id']}: $e');
      }
    }
  } else {
    print('No hay conexión a internet. No se puede sincronizar.');
  }
}