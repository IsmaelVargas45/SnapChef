import 'package:flutter/material.dart';
import 'package:trabajo_integrador_flutter/src/utils/app_colours.dart';
import 'package:trabajo_integrador_flutter/src/routes/routes.dart';

/// Widget raíz de la app. Acá se define el tema global y las rutas.
class SnapChefApp extends StatelessWidget {
  const SnapChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapChef',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          brightness: Brightness.light,
        ),
        fontFamily: 'monospace',
      ),
      initialRoute: "/",              // 👈 Pantalla inicial
      routes: getApplicationRoutes(), // 
    );
  }
}
