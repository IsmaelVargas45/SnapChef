import 'package:flutter/material.dart';

import 'package:trabajo_integrador_flutter/src/pages/lista_recetas_ia_page.dart';
import 'package:trabajo_integrador_flutter/src/state/ingredientes_controller.dart';
import 'package:trabajo_integrador_flutter/src/utils/app_colours.dart';
import 'package:trabajo_integrador_flutter/src/utils/error_ia.dart';

import '../service/ia_service.dart';

class BotonGenerarReceta extends StatefulWidget {
  final IngredientesController ingredientes;
  const BotonGenerarReceta({super.key, required this.ingredientes});

  @override
  State<BotonGenerarReceta> createState() => _BotonGenerarRecetaState();
}

class _BotonGenerarRecetaState extends State<BotonGenerarReceta> {
  bool _generando = false;

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _generar() async {
    if (widget.ingredientes.estaVacio || _generando) return;
    setState(() => _generando = true);

    try {
      final recetas =
          await IaService().generarRecetas(widget.ingredientes.items);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListaRecetasIaPage(recetas: recetas),
        ),
      );
    } catch (e) {
      debugPrint('ERROR IA: $e');
      if (mounted) _mensaje(mensajeErrorIa(e));
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.ingredientes,
      builder: (context, _) {
        final vacio = widget.ingredientes.estaVacio;

        return SizedBox(
          height: 54,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (vacio || _generando) ? null : _generar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.green.withOpacity(0.4),
              disabledForegroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: _generando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              _generando
                  ? 'Generando recetas...'
                  : vacio
                      ? 'Agregá ingredientes para generar'
                      : 'Generar recetas (${widget.ingredientes.cantidad})',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}