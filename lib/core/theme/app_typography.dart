import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Hero Title: clamp(44px, 8vw, 88px), line-height 0.83, weight 700, letter-spacing -0.04em
  static TextStyle heroTitle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width * 0.08 < 44
        ? 44.0
        : (width * 0.08 > 88 ? 88.0 : width * 0.08);

    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      height: 0.83,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.04 * fontSize,
      color: AppColors.textMain,
      textBaseline: TextBaseline.alphabetic,
    );
  }

  // Hero Subtitle: 15px, line-height 1.6
  static final TextStyle heroSub = GoogleFonts.spaceGrotesk(
    fontSize: 15,
    height: 1.6,
    color: AppColors.textMuted,
  );

  // Step Badge: 14px (0.9rem), weight 700, letter-spacing 0.2em, uppercase
  static final TextStyle stepBadge = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2 * 14,
    color: AppColors.accent,
  );

  // Button Text: 13px, weight 600, letter-spacing 0.1em, uppercase
  static final TextStyle buttonText = GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1 * 13,
  );

  // Hotkey/Quote Text (accent color)
  static final TextStyle accentText = GoogleFonts.spaceGrotesk(
    fontSize: 15,
    height: 1.6,
    color: AppColors.accent,
    fontWeight: FontWeight.w600,
  );
}
