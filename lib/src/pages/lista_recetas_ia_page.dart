import 'package:flutter/material.dart';

import 'package:trabajo_integrador_flutter/src/pages/receta_ia_page.dart';
import 'package:trabajo_integrador_flutter/src/utils/app_colours.dart';

class ListaRecetasIaPage extends StatelessWidget {
  final List<Map<String, dynamic>> recetas;
  const ListaRecetasIaPage({super.key, required this.recetas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        title: const Text('Recetas sugeridas'),
      ),
      body: SafeArea(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Asumimos que siempre tenés sal, aceite y agua. '
                  '"Te falta" muestra lo demás que no cargaste.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
            Expanded(
              child: recetas.isEmpty
                  ? const Center(
                      child: Text(
                        'No se generaron recetas',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: recetas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) {
                        final r = recetas[i];
                        final faltantes =
                            List<String>.from(r['faltantes'] ?? []);

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecetaIaPage(receta: r),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (r['titulo'] ?? 'Receta').toString(),
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if (r['tiempo_minutos'] != null)
                                        Text(
                                          '⏱ ${r['tiempo_minutos']} min',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textGrey,
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        faltantes.isEmpty
                                            ? 'Tenés todo lo necesario'
                                            : 'Te falta: ${faltantes.join(", ")}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.green,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}