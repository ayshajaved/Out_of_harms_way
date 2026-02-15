import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';
import 'core/theme/app_colors.dart';
import 'presentation/screens/hero_screen.dart';

void main() {
  // Remove # from URLs
  setPathUrlStrategy();

  runApp(const ProviderScope(child: OutOfHarmsWayApp()));
}

class OutOfHarmsWayApp extends StatelessWidget {
  const OutOfHarmsWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Out of Harm\'s Way',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.outerBg,
        brightness: Brightness.dark,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.textMain),
        ),
      ),
      home: const HeroScreen(),
    );
  }
}
