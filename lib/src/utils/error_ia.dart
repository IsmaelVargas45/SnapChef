import 'package:supabase_flutter/supabase_flutter.dart';

/// Convierte cualquier error en un mensaje claro para el usuario.
String mensajeErrorIa(Object e) {
  final t = e.toString();

  // Sin conexión (celular: SocketException; navegador: Failed to fetch).
  final sinRed = t.contains('SocketException') ||
      t.contains('Failed host lookup') ||
      t.contains('Failed to fetch') ||
      t.contains('ClientException');
  if (sinRed) {
    return 'Sin conexión a internet. Revisá tu Wi-Fi o datos.';
  }

  if (e is FunctionException) {
    final d = e.details;
    if (d is Map && d['error'] is Map) {
      final m = d['error']['mensaje'];
      if (m is String && m.isNotEmpty) return m;
    }
    if (e.status == 401) {
      return 'Tu sesión no está activa. Cerrá y abrí la app.';
    }
    if (e.status == 0) {
      return 'No se pudo conectar con el servicio. Revisá tu internet.';
    }
    return 'El servicio de IA respondió con un error (${e.status}).';
  }

  if (t.contains('TimeoutException')) {
    return 'La conexión tardó demasiado. Intentá de nuevo.';
  }
  return 'Ocurrió un error inesperado. Intentá de nuevo.';
}