import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';
import 'core/theme/app_colors.dart';
import 'core/navigation/app_router.dart';

import 'package:firebase_core/firebase_core.dart';
import 'core/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.textMain),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
