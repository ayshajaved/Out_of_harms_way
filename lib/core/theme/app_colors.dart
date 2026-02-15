import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color outerBg = Color(0xFF000000); // Pure black background
  static const Color innerBg = Color(0xFF000000); // Card background
  static const Color textMain = Color(0xFFE5E5E5); // Primary text (off-white)
  static const Color textMuted = Color(0xFF9F9F9F); // Secondary text (gray)
  static const Color accent = Color(0xFFE8C1CF); // Pink accent (#E8C1CF)
  static const Color gridLines = Color(0xFF111111); // Subtle grid lines

  // Button Variants
  static const Color btnPrimaryBg = Color(0xFFE8C1CF); // Pink fill
  static const Color btnPrimaryText = Color(0xFF141414); // Dark text on pink
  static const Color btnGhostBorder = Color(0xFF3F3F3F); // Ghost button border
  static const Color btnGhostText = Color(0xFFD4D4D4); // Ghost button text

  // Utility
  static const Color spotlight = Color(0x24FFFFFF); // White with 14% opacity
  static const Color cursorFill = Color(0x4DE8C1CF); // Pink with 30% opacity
}
