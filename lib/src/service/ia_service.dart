import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
class IaService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Manda la foto a la Edge Function y devuelve los ingredientes detectados.
Future<List<String>> detectarIngredientes(XFile foto) async {
  final bytes = await foto.readAsBytes();
  final res = await _client.functions.invoke(
    'detectar-ingredientes',
    body: {
      'image': base64Encode(bytes),
      'mimeType': 'image/jpeg',
    },
  );

  debugPrint('RESPUESTA IA: ${res.status} ${res.data}');

  dynamic data = res.data;
  if (data is String) data = jsonDecode(data);

  final lista = (data?['ingredientes'] as List?) ?? [];
  return lista.map((e) => e.toString().trim()).toList();
}

  /// Manda la lista de ingredientes y devuelve la receta.
  Future<List<Map<String, dynamic>>> generarRecetas(
    List<String> ingredientes) async {
  final res = await _client.functions.invoke(
    'generar-receta',
    body: {'ingredientes': ingredientes},
  );

  debugPrint('RECETAS IA: ${res.status} ${res.data}');

  dynamic data = res.data;
  if (data is String) data = jsonDecode(data);

  final lista = (data?['recetas'] as List?) ?? [];
  return lista.map((e) => Map<String, dynamic>.from(e)).toList();
}
}
  
