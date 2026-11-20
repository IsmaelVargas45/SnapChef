import 'package:flutter/material.dart';
import 'package:trabajo_integrador_flutter/src/state/ingredientes_controller.dart';
import 'package:trabajo_integrador_flutter/src/utils/app_colours.dart';

/// Abre el panel inferior con la lista de ingredientes cargados.
void mostrarListaIngredientes(
  BuildContext context,
  IngredientesController controller,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.7,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _ListaIngredientes(controller: controller),
  );
}

class _ListaIngredientes extends StatelessWidget {
  final IngredientesController controller;

  const _ListaIngredientes({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Se redibuja solo cuando el controller avisa que algo cambió.
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final items = controller.items;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textGrey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'TUS INGREDIENTES (${items.length})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  if (items.isNotEmpty)
                    TextButton(
                      onPressed: controller.vaciar,
                      child: const Text(
                        'Vaciar todo',
                        style: TextStyle(color: AppColors.matchLow),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Todavía no cargaste ingredientes',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final ingrediente = items[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.circle,
                                size: 8, color: AppColors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ingrediente,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  size: 20, color: AppColors.textGrey),
                              onPressed: () =>
                                  controller.eliminar(ingrediente),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}