import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/historial_model.dart';

class MenuProvider extends ChangeNotifier {
  final SupabaseClient _db = Supabase.instance.client;

  // =========================================================
  // HISTORIAL (Supabase)
  // =========================================================
  List<HistorialEntry> _historial = [];
  bool _cargandoHistorial = false;

  bool get cargandoHistorial => _cargandoHistorial;

  Future<void> cargarHistorial() async {
    _cargandoHistorial = true;
    notifyListeners();

    try {
      final data = await _db
          .from('historial')
          .select()
          .order('fecha', ascending: false);

      _historial = data.map((fila) => HistorialEntry.fromMap(fila)).toList();
    } catch (e) {
      debugPrint('Error al cargar historial: $e');
    } finally {
      _cargandoHistorial = false;
      notifyListeners();
    }
  }

  /// Entradas de historial ordenadas de más reciente a más vieja.
  List<HistorialEntry> get historial {
    final ordenado = List<HistorialEntry>.from(_historial);
    ordenado.sort((a, b) => b.fecha.compareTo(a.fecha));
    return ordenado;
  }

  /// Entradas de historial agrupadas por día (clave = fecha sin hora).
  Map<DateTime, List<HistorialEntry>> get historialAgrupadoPorDia {
    final Map<DateTime, List<HistorialEntry>> agrupado = {};
    for (final entry in historial) {
      final dia =
          DateTime(entry.fecha.year, entry.fecha.month, entry.fecha.day);
      agrupado.putIfAbsent(dia, () => []).add(entry);
    }
    return agrupado;
  }

  /// Guarda la receta completa en el historial.
  Future<bool> registrarReceta({
    required String tituloReceta,
    List<String> ingredientesUsados = const [],
    List<String> pasos = const [],
    int? tiempoMinutos,
  }) async {
    try {
      final fila = await _db
          .from('historial')
          .insert({
            'titulo_receta': tituloReceta,
            'ingredientes_usados': ingredientesUsados,
            'pasos': pasos,
            'tiempo_minutos': tiempoMinutos,
          })
          .select()
          .single();

      _historial.add(HistorialEntry.fromMap(fila));
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error al guardar en historial: $e');
      return false;
    }
  }

  /// Borra una sola entrada del historial.
  Future<bool> eliminarEntrada(HistorialEntry entry) async {
    try {
      await _db.from('historial').delete().eq('id', entry.id);
      _historial.removeWhere((e) => e.id == entry.id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error al borrar del historial: $e');
      return false;
    }
  }

  /// Borra todo el historial del usuario.
  Future<bool> vaciarHistorial() async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) throw Exception('Sin sesión');
      await _db.from('historial').delete().eq('user_id', uid);
      _historial.clear();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error al vaciar historial: $e');
      return false;
    }
  }
}