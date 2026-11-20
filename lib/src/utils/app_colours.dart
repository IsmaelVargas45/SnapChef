import 'package:flutter/material.dart';

/// Paleta de colores de SnapChef, extraída de los mockups:
/// fondo crema, header/tarjeta oscura tipo terminal, acentos
/// verde y naranja.
class AppColors {
  AppColors._();

  static const background = Color(0xFFEAE6D9); // crema de fondo
  static const dark = Color(0xFF16241D); // header / tarjeta oscura
  static const darkGreenText = Color(0xFF4CAF7D); // texto verde sobre oscuro
  static const green = Color(0xFF3E8E5C); // botón / progreso verde
  static const orange = Color(0xFFE2924B); // progreso naranja
  static const cardWhite = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1E1E1E);
  static const textMuted = Color(0xFF6B6B63);
  static const pillBorder = Color(0xFF1E1E1E);

  // Agregado para las pantallas de recetas e historial.
  static const Color cardBackground = Colors.white;
  static const Color textGrey = Color(0xFF8A8A8A);

  static const Color matchHigh = Color(0xFF3F8F4E); // >= 85%
  static const Color matchMid = Color(0xFFE0A02E); // 50% - 84%
  static const Color matchLow = Color(0xFFD9603B); // < 50%

  static Color colorCoincidencia(int porcentaje) {
    if (porcentaje >= 85) return matchHigh;
    if (porcentaje >= 50) return matchMid;
    return matchLow;
  }
}