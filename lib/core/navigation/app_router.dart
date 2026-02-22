import 'package:flutter/material.dart';
import '../../presentation/screens/hero_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/dashboard/code_generator_screen.dart';
import '../../presentation/widgets/auth_guard.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
        '/': (context) => const HeroScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const AuthGuard(child: DashboardScreen()),
        '/generate_code': (context) => const AuthGuard(child: CodeGeneratorScreen()),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    return null;
  }
}
