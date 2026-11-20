import 'package:flutter/material.dart';
import 'package:trabajo_integrador_flutter/src/utils/app_colours.dart';

/// Barra de navegación flotante, chica y redondeada.
class BarraNavegacion extends StatelessWidget {
  final int indiceActual;
  final ValueChanged<int> onTap;

  const BarraNavegacion({
    super.key,
    required this.indiceActual,
    required this.onTap,
  });

  static const List<IconData> _iconos = [
    Icons.home_rounded,
    Icons.history,
    Icons.camera_alt,
  ];

  static const List<String> _etiquetas = [
    'Inicio',
    'Historial',
    'Escanear',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 14),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.dark,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_iconos.length, (i) {
              final activo = indiceActual == i;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: activo ? 14 : 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: activo ? AppColors.green : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconos[i],
                        size: 22,
                        color: activo ? Colors.white : Colors.grey,
                      ),
                      if (activo) ...[
                        const SizedBox(width: 6),
                        Text(
                          _etiquetas[i],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}