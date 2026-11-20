class HistorialEntry {
  final String id;
  final String tituloReceta;
  final DateTime fecha;
  final List<String> ingredientesUsados;
  final List<String> pasos;
  final int? tiempoMinutos;

  const HistorialEntry({
    required this.id,
    required this.tituloReceta,
    required this.fecha,
    this.ingredientesUsados = const [],
    this.pasos = const [],
    this.tiempoMinutos,
  });

  /// Fila de la tabla historial de Supabase.
  factory HistorialEntry.fromMap(Map<String, dynamic> map) {
    return HistorialEntry(
      id: map['id'].toString(),
      tituloReceta: map['titulo_receta'] as String,
      fecha: DateTime.parse(map['fecha'] as String).toLocal(),
      ingredientesUsados:
          List<String>.from(map['ingredientes_usados'] as List? ?? []),
      pasos: List<String>.from(map['pasos'] as List? ?? []),
      tiempoMinutos: map['tiempo_minutos'] as int?,
    );
  }

  factory HistorialEntry.fromJson(Map<String, dynamic> json) {
    return HistorialEntry(
      id: json['id'] as String,
      tituloReceta: json['tituloReceta'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      ingredientesUsados:
          List<String>.from(json['ingredientesUsados'] as List? ?? []),
      pasos: List<String>.from(json['pasos'] as List? ?? []),
      tiempoMinutos: json['tiempoMinutos'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tituloReceta': tituloReceta,
        'fecha': fecha.toIso8601String(),
        'ingredientesUsados': ingredientesUsados,
        'pasos': pasos,
        'tiempoMinutos': tiempoMinutos,
      };

  /// Formato que entiende RecetaIaPage para reabrir la receta.
  Map<String, dynamic> toReceta() => {
        'titulo': tituloReceta,
        'ingredientes': ingredientesUsados,
        'pasos': pasos,
        'tiempo_minutos': tiempoMinutos,
      };
}