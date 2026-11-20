import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../service/ia_service.dart';

/// Guarda los ingredientes del usuario (en memoria + Supabase) y avisa a las
/// pantallas cuando cambian.
class IngredientesController extends ChangeNotifier {
  final SupabaseClient _db = Supabase.instance.client;
  final IaService _ia = IaService();
  final List<String> _items = [];

  bool _cargando = false;
  bool get cargando => _cargando;

  List<String> get items => List.unmodifiable(_items);
  int get cantidad => _items.length;
  bool get estaVacio => _items.isEmpty;

  bool contiene(String texto) =>
      _items.any((e) => e.toLowerCase() == texto.trim().toLowerCase());

  /// Trae los ingredientes guardados. Llamar una vez al iniciar la app.
  Future<void> cargar() async {
    _cargando = true;
    notifyListeners();

    try {
      final data = await _db
          .from('ingredientes')
          .select('nombre')
          .order('created_at', ascending: true);

      _items
        ..clear()
        ..addAll(data.map((fila) => fila['nombre'] as String));
    } catch (e) {
      debugPrint('Error al cargar ingredientes: $e');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Devuelve `false` si el texto está vacío o ya existe.
  bool agregar(String texto) {
    final limpio = texto.trim();
    if (limpio.isEmpty || contiene(limpio)) return false;

    final nombre = limpio[0].toUpperCase() + limpio.substring(1);
    _items.add(nombre);
    notifyListeners();

    _guardar(nombre);
    return true;
  }

  /// Analiza la foto con IA y agrega los ingredientes detectados.
  /// Devuelve cuántos ingredientes nuevos se agregaron.
  Future<int> agregarDesdeFoto(XFile foto) async {
    final detectados = await _ia.detectarIngredientes(foto);
    var nuevos = 0;
    for (final nombre in detectados) {
      if (agregar(nombre)) nuevos++;
    }
    return nuevos;
  }

  Future<void> _guardar(String nombre) async {
    try {
      await _db.from('ingredientes').insert({'nombre': nombre});
    } catch (e) {
      debugPrint('Error al guardar "$nombre": $e');
      _items.remove(nombre);
      notifyListeners();
    }
  }

  void eliminar(String ingrediente) {
    if (!_items.remove(ingrediente)) return;
    notifyListeners();

    _borrar(ingrediente);
  }

  Future<void> _borrar(String ingrediente) async {
    try {
      await _db.from('ingredientes').delete().eq('nombre', ingrediente);
    } catch (e) {
      debugPrint('Error al borrar "$ingrediente": $e');
      _items.add(ingrediente);
      notifyListeners();
    }
  }

  void vaciar() {
    if (_items.isEmpty) return;
    final copia = List<String>.from(_items);
    _items.clear();
    notifyListeners();

    _borrarTodos(copia);
  }

  Future<void> _borrarTodos(List<String> respaldo) async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) throw Exception('Sin sesión');
      await _db.from('ingredientes').delete().eq('user_id', uid);
    } catch (e) {
      debugPrint('Error al vaciar ingredientes: $e');
      _items.addAll(respaldo);
      notifyListeners();
    }
  }
}