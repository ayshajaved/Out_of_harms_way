import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color outerBg = Color(0xFF000000); // Pure black background
  static const Color innerBg = Color(0xFF0A0A0A); // Deep charcoal card background
  static const Color surfaceLight = Color(0xFF141414); // Slightly lighter surface
  static const Color surfaceBorder = Color(0xFF222222); // Subtle border
  
  // Typography
  static const Color textMain = Color(0xFFF3F4F6); // High-contrast off-white
  static const Color textMuted = Color(0xFFA1A1AA); // Zinc-400 for mute text
  static const Color accent = Color(0xFFE8C1CF); // Premium Pink accent
  static const Color gridLines = Color(0xFF111111); // Subtle grid lines

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald success
  static const Color error = Color(0xFFEF4444); // Red error
  static const Color errorBg = Color(0xFF3F1616); // Dark red background

  // Button Variants
  static const Color btnPrimaryBg = Color(0xFFE8C1CF); // Pink fill
  static const Color btnPrimaryHover = Color(0xFFFDF0F5); // Lighter pink hover
  static const Color btnPrimaryText = Color(0xFF09090B); // Dark zinc text
  static const Color btnGhostBg = Color(0xFF18181B); // Zinc 900
  static const Color btnGhostBorder = Color(0xFF27272A); // Zinc 800
  static const Color btnGhostText = Color(0xFFE4E4E7); // Zinc 200

  // Utility
  static const Color spotlight = Color(0x24FFFFFF); // White with 14% opacity
  static const Color cursorFill = Color(0x4DE8C1CF); // Pink with 30% opacity
}
