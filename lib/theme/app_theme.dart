import 'package:flutter/material.dart';

class NexaColors {
  NexaColors._();

  // Brand — exact specs
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color greenAlt = Color(0xFF388E3C);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color paleGreen = Color(0xFFF1F8F1);
  static const Color accentGreen = Color(0xFF4CAF50);

  // Navy / Blue
  static const Color darkNavy = Color(0xFF1A237E);
  static const Color navy = Color(0xFF0D2137);

  // Text
  static const Color textPrimary = Color(0xFF1A237E);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textMuted = Color(0xFF9E9E9E);

  // Backgrounds
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color bgLightGreen = Color(0xFFF1F8F1);

  // Borders
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF3F4F6);

  // Moroccan flag
  static const Color moroccanGreen = Color(0xFF006233);
  static const Color moroccanRed = Color(0xFFC1272D);

  // Misc
  static const Color starGold = Color(0xFFFFC107);
  static const Color shadow = Color(0x1A000000);

  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class NexaShadows {
  NexaShadows._();

  static List<BoxShadow> card = [
    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> cardHover = [
    BoxShadow(color: NexaColors.primaryGreen.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 8)),
  ];

  static List<BoxShadow> navbar = [
    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
  ];

  static List<BoxShadow> dashboard = [
    BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 40, offset: const Offset(0, 16)),
  ];

  static List<BoxShadow> mockup = [
    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 10)),
  ];
}
