import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class StepBadge extends StatelessWidget {
  final String number;

  const StepBadge({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.accent),
        borderRadius: BorderRadius.circular(20),
        color: const Color(0x4D000000), // rgba(0,0,0,0.3)
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(number, style: AppTypography.stepBadge),
    );
  }
}

class HeroButtons extends StatelessWidget {
  final VoidCallback? onStartHandControl;
  final VoidCallback? onStopHandControl;
  final bool isHandControlActive;

  const HeroButtons({
    super.key,
    this.onStartHandControl,
    this.onStopHandControl,
    this.isHandControlActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Primary Button
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.btnPrimaryBg,
            foregroundColor: AppColors.btnPrimaryText,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          child: Text(
            'Download for Windows',
            style: AppTypography.buttonText.copyWith(
              color: AppColors.btnPrimaryText,
            ),
          ),
        ),

        // Ghost Button - Toggle between Enable/Disable
        OutlinedButton(
          onPressed: isHandControlActive
              ? onStopHandControl
              : onStartHandControl,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.btnGhostText,
            side: BorderSide(
              color: isHandControlActive
                  ? AppColors.accent
                  : AppColors.btnGhostBorder,
              width: isHandControlActive ? 2 : 1,
            ),
            backgroundColor: isHandControlActive
                ? AppColors.accent.withOpacity(0.1)
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            shape: const StadiumBorder(),
          ),
          child: Text(
            isHandControlActive
                ? 'Disable Hand Control'
                : 'Enable Hand Control',
            style: AppTypography.buttonText.copyWith(
              color: isHandControlActive
                  ? AppColors.accent
                  : AppColors.btnGhostText,
            ),
          ),
        ),
      ],
    );
  }
}
