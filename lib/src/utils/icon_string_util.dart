import 'package:flutter/material.dart';

/// Convierte un nombre de ícono (guardado como String, por ejemplo en un
/// JSON del menú) en un widget [Icon]. Agregá acá cualquier ícono nuevo
/// que uses en tus menús.
Icon getIcon(String? iconName) {
  switch (iconName) {
    case 'home':
      return const Icon(Icons.home_outlined);
    case 'camera':
      return const Icon(Icons.camera_alt_outlined);
    case 'recipe':
      return const Icon(Icons.restaurant_menu_outlined);
    case 'list':
      return const Icon(Icons.list_alt_outlined);
    case 'favorite':
      return const Icon(Icons.favorite_border);
    case 'settings':
      return const Icon(Icons.settings_outlined);
    default:
      return const Icon(Icons.circle_outlined);
  }
}