import 'package:flutter/material.dart';
import 'package:trabajo_integrador_flutter/src/utils/app_colours.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Barras superiores
                Row(
                  children: const [
                    Expanded(child: _Bar(color: AppColors.green)),
                    SizedBox(width: 6),
                    Expanded(child: _Bar(color: AppColors.orange)),
                    SizedBox(width: 6),
                    Expanded(child: _Bar(color: AppColors.green)),
                  ],
                ),
                const SizedBox(height: 40),

                // Recuadro del escáner
                Container(
                  width: MediaQuery.of(context).size.width * 0.55,
                  height: 170,
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(Icons.camera_alt_outlined,
                        color: AppColors.darkGreenText, size: 28),
                  ),
                ),
                const SizedBox(height: 36),
                // Título y texto
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w800,
                      fontSize: 34,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    children: [
                      TextSpan(text: 'Snap'),
                      TextSpan(
                        text: 'Chef',
                        style: TextStyle(color: AppColors.green),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Escaneá tu heladera y descubrí qué cocinar con lo que ya tenés en casa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 40),

                // Botón
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'COMENZAR',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final Color color;
  const _Bar({required this.color});

  @override
  Widget build(BuildContext context) =>
      Container(height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)));
}