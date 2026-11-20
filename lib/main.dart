import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/app.dart';
import 'src/provider/menu_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  await dotenv.load(fileName: '.env'); // <- esta línea

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

// Inicia sesión anónima en el dispositivo. Esto permite guardar el historial de recetas.
  final auth = Supabase.instance.client.auth;
  if (auth.currentSession == null) {
    try {
      await auth.signInAnonymously();
    } catch (e) {
      debugPrint('No se pudo iniciar sesión anónima en este dispositivo: $e');
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => MenuProvider(),
      child: const SnapChefApp(), 
    ),
  );
}