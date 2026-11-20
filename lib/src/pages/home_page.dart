import 'package:flutter/material.dart';
import 'package:trabajo_integrador_flutter/src/state/ingredientes_controller.dart';
import 'package:trabajo_integrador_flutter/src/utils/app_colours.dart';
import 'package:trabajo_integrador_flutter/src/widgets/barra_navegacion.dart';
import 'inicio_page.dart';

import 'historial_page.dart';
import 'scan_page.dart';

/// Arma la estructura general: la pantalla activa + la barra de abajo.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final IngredientesController _ingredientes = IngredientesController();
  int _indiceActual = 0;

  @override
  void initState() {
    super.initState();
    _ingredientes.cargar(); // trae los ingredientes guardados en Supabase
  }

  @override
  void dispose() {
    _ingredientes.dispose();
    super.dispose();
  }

  Widget _paginaActual() {
    switch (_indiceActual) {
      case 1:
        return const HistorialPage();
      case 2:
        return ScanPage(controller: _ingredientes);
      default:
        return InicioPage(
          ingredientes: _ingredientes,
          onEscanear: () => setState(() => _indiceActual = 2),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: _paginaActual(),
      bottomNavigationBar: BarraNavegacion(
        indiceActual: _indiceActual,
        onTap: (i) => setState(() => _indiceActual = i),
      ),
    );
  }
}