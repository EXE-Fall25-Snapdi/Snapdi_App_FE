import 'package:flutter/material.dart';

// Home screen specific constants and utilities
class HomeConstants {
  // Feature button colors
  static const Color nowButtonColor = Color(0xFF00D4AA);
  static const Color bookButtonColor = Color(0xFF4CAF50);
  static const Color vipButtonColor = Color(0xFF9C27B0);
  static const Color voucherButtonColor = Color(0xFFFF9800);
  static const Color flashButtonColor = Color(0xFFF44336);
  static const Color allButtonColor = Color(0xFF607D8B);

  // Promotional card gradients
  static const List<Color> photoCompetitionGradient = [
    Color(0xFF81C784),
    Color(0xFF4FC3F7),
  ];

  static const List<Color> flashSaleGradient = [
    Color(0xFFFF8A65),
    Color(0xFFFF7043),
  ];

  static const List<Color> vipOfferGradient = [
    Color(0xFFBA68C8),
    Color(0xFF9C27B0),
  ];
}

// Extension for home-specific themes
extension HomeTheme on ThemeData {
  BoxShadow get homeCardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 20,
    offset: const Offset(0, 5),
  );

  BoxShadow get featureButtonShadow => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
}
