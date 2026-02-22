import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TopNavigationBar extends StatelessWidget {
  const TopNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      color: Colors.black.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Text(
            'Out of Harm\'s Way',
            style: AppTypography.stepBadge,
          ),
          
          // Auth Buttons
          Row(
            children: [
              _NavButton(
                label: 'LOG IN',
                onPressed: () => Navigator.of(context).pushNamed('/login'),
                isGhost: true,
              ),
              const SizedBox(width: 12),
              _NavButton(
                label: 'SIGN UP',
                onPressed: () => Navigator.of(context).pushNamed('/register'),
                isGhost: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isGhost;

  const _NavButton({
    required this.label,
    required this.onPressed,
    required this.isGhost,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isGhost ? Colors.transparent : AppColors.btnPrimaryBg,
          borderRadius: BorderRadius.circular(100),
          border: isGhost ? Border.all(color: AppColors.surfaceBorder) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isGhost ? AppColors.textMain : AppColors.btnPrimaryText,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
