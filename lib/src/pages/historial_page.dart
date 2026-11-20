import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/historial_model.dart';
import '../pages/receta_ia_page.dart';
import '../provider/menu_provider.dart';
import '../utils/app_colours.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().cargarHistorial();
    });
  }

  Future<void> _vaciar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vaciar historial'),
        content: const Text('Se borrarán todas las recetas guardadas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final borrado = await context.read<MenuProvider>().vaciarHistorial();
      if (!borrado && mounted) _aviso('No se pudo vaciar el historial');
    }
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _eliminar(HistorialEntry e) async {
    final ok = await context.read<MenuProvider>().eliminarEntrada(e);
    if (!ok && mounted) {
      _aviso('No se pudo borrar. Probá de nuevo');
      context.read<MenuProvider>().cargarHistorial();
    }
  }

  void _abrir(HistorialEntry e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecetaIaPage(receta: e.toReceta(), guardable: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MenuProvider>();
    final agrupado = provider.historialAgrupadoPorDia;
    final dias = agrupado.keys.toList()..sort((a, b) => b.compareTo(a));

    Widget contenido;

    if (provider.cargandoHistorial && dias.isEmpty) {
      contenido = const Center(child: CircularProgressIndicator());
    } else if (dias.isEmpty) {
      contenido = const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Todavía no cocinaste ninguna receta',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey, fontSize: 14),
          ),
        ),
      );
    } else {
      contenido = RefreshIndicator(
        onRefresh: () => context.read<MenuProvider>().cargarHistorial(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          itemCount: dias.length,
          itemBuilder: (context, index) {
            final dia = dias[index];
            final entries = agrupado[dia]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _etiquetaDia(dia),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: ValueKey(e.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _eliminar(e),
                        child: _HistorialCard(
                          entry: e,
                          onTap: () => _abrir(e),
                          onBorrar: () => _eliminar(e),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        title: const Text('Historial'),
        actions: [
          if (dias.isNotEmpty)
            IconButton(
              tooltip: 'Vaciar historial',
              icon: const Icon(Icons.delete_sweep),
              onPressed: _vaciar,
            ),
        ],
      ),
      body: SafeArea(child: contenido),
    );
  }

  String _etiquetaDia(DateTime dia) {
    final hoy = DateTime.now();
    final ayer = hoy.subtract(const Duration(days: 1));
    final esHoy =
        dia.year == hoy.year && dia.month == hoy.month && dia.day == hoy.day;
    final esAyer = dia.year == ayer.year &&
        dia.month == ayer.month &&
        dia.day == ayer.day;

    if (esHoy) return 'HOY';
    if (esAyer) return 'AYER';
    return DateFormat('d MMMM', 'es').format(dia).toUpperCase();
  }
}

class _HistorialCard extends StatelessWidget {
  final HistorialEntry entry;
  final VoidCallback onTap;
  final VoidCallback onBorrar;

  const _HistorialCard({
    required this.entry,
    required this.onTap,
    required this.onBorrar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.dark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.tituloReceta,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('HH:mm').format(entry.fecha),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: AppColors.textGrey),
                onPressed: onBorrar,
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.green),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}