import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../components/common.dart';

class Slide2Analysis extends StatelessWidget {
  const Slide2Analysis({super.key});

  @override
  Widget build(BuildContext context) {
    return _StorySlide(
      badge: '01',
      title1: 'the',
      title2: 'analysis',
      subtitle: 'Real-time vulnerability detection before generation.\n',
      accent: 'SAST + DAST + AI reasoning',
    );
  }
}

class Slide3Generation extends StatelessWidget {
  const Slide3Generation({super.key});

  @override
  Widget build(BuildContext context) {
    return _StorySlide(
      badge: '02',
      title1: 'the',
      title2: 'generation',
      subtitle: 'Context-aware code that respects security boundaries.\n',
      accent: '"Code that doesn\'t need a secondary audit."',
    );
  }
}

class Slide4Security extends StatelessWidget {
  const Slide4Security({super.key});

  @override
  Widget build(BuildContext context) {
    return _StorySlide(
      badge: '03',
      title1: 'the',
      title2: 'security',
      subtitle: 'Automated remediation and zero-trust verification.\n',
      accent: '100% Google Cloud Verified Secure',
    );
  }
}

class _StorySlide extends StatelessWidget {
  final String badge;
  final String title1;
  final String title2;
  final String subtitle;
  final String accent;

  const _StorySlide({
    required this.badge,
    required this.title1,
    required this.title2,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StepBadge(number: badge),
            const SizedBox(height: 24),
            Text(
              title1,
              style: AppTypography.heroTitle(
                context,
              ).copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Text(
              title2,
              style: AppTypography.heroTitle(
                context,
              ).copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              subtitle,
              style: AppTypography.heroSub.copyWith(
                height: 1.8,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              accent,
              style: AppTypography.accentText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
