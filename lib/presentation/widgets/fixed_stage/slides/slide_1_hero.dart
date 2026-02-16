import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../components/common.dart';

class Slide1Hero extends StatelessWidget {
  final VoidCallback? onStartHandControl;
  final bool showButtons;

  const Slide1Hero({
    super.key,
    this.onStartHandControl,
    this.showButtons = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'secure',
              style: AppTypography.heroTitle(
                context,
              ).copyWith(color: Colors.white),
            ),
            Text(
              'every',
              style: AppTypography.heroTitle(
                context,
              ).copyWith(color: Colors.white),
            ),
            Text(
              'line',
              style: AppTypography.heroTitle(
                context,
              ).copyWith(color: Colors.white),
            ),

            const SizedBox(height: 24),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Text(
                'An AI coding agent that generates secure code by default. '
                'No vulnerabilities. No patches. Just production-ready security.',
                style: AppTypography.heroSub.copyWith(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 32),

            if (showButtons)
              HeroButtons(onStartHandControl: onStartHandControl),
          ],
        ),
      ),
    );
  }
}
