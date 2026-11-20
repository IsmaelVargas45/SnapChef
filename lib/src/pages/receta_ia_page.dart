import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:trabajo_integrador_flutter/src/provider/menu_provider.dart';
import 'package:trabajo_integrador_flutter/src/utils/app_colours.dart';

class RecetaIaPage extends StatefulWidget {
  final Map<String, dynamic> receta;

  /// false cuando se abre desde el historial (ya está guardada).
  final bool guardable;

  const RecetaIaPage({
    super.key,
    required this.receta,
    this.guardable = true,
  });

  @override
  State<RecetaIaPage> createState() => _RecetaIaPageState();
}

class _RecetaIaPageState extends State<RecetaIaPage> {
  static const _basicos = ['sal', 'aceite', 'agua'];

  bool _guardando = false;
  bool _guardada = false;

  String _normalizar(String s) => s
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  /// Compara palabras completas: "salchicha" no cuenta como "sal".
  bool _esBasico(String ingrediente) {
    final palabras = _normalizar(ingrediente)
        .split(RegExp(r'[^a-z]+'))
        .where((p) => p.isNotEmpty);
    return palabras.any(_basicos.contains);
  }

  Future<void> _guardar() async {
    if (_guardando || _guardada) return;
    setState(() => _guardando = true);

    final titulo = (widget.receta['titulo'] ?? 'Receta').toString();
    final ingredientes =
        List<String>.from(widget.receta['ingredientes'] ?? []);
    final pasos = List<String>.from(widget.receta['pasos'] ?? []);
    final tiempo = widget.receta['tiempo_minutos'] as int?;

    final ok = await context.read<MenuProvider>().registrarReceta(
          tituloReceta: titulo,
          ingredientesUsados: ingredientes,
          pasos: pasos,
          tiempoMinutos: tiempo,
        );

    if (!mounted) return;
    setState(() {
      _guardando = false;
      _guardada = ok;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Receta guardada en tu historial'
            : 'No se pudo guardar, intentá de nuevo'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receta = widget.receta;
    final ingredientes = List<String>.from(receta['ingredientes'] ?? []);
    final pasos = List<String>.from(receta['pasos'] ?? []);
    final tiempo = receta['tiempo_minutos'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        title: const Text('Tu receta'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              (receta['titulo'] ?? 'Receta').toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            if (tiempo != null) ...[
              const SizedBox(height: 8),
              Text(
                '⏱ $tiempo minutos',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Ingredientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final i in ingredientes)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 15)),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textDark,
                          ),
                          children: [
                            TextSpan(text: i),
                            if (_esBasico(i))
                              const TextSpan(
                                text: '  (básico, se asume que lo tenés)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textGrey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Preparación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (pasos.isEmpty)
              const Text(
                'Esta receta se guardó antes sin la preparación.',
                style: TextStyle(color: AppColors.textGrey),
              ),
            for (var n = 0; n < pasos.length; n++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '${n + 1}. ${pasos[n]}',
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ),
            if (widget.guardable) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: (_guardando || _guardada) ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.green.withOpacity(0.5),
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(_guardada ? Icons.check : Icons.bookmark_add),
                  label: Text(
                    _guardada
                        ? 'Guardada'
                        : _guardando
                            ? 'Guardando...'
                            : 'Guardar en historial',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}