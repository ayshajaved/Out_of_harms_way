import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
        ),
        title: Text(
          'Out of Harm\'s Way',
          style: AppTypography.stepBadge,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'welcome, ${user?.displayName ?? user?.email ?? 'user'}',
              style: AppTypography.heroTitle(context).copyWith(fontSize: 32),
            ),
            const SizedBox(height: 48),
            
            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 1,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 2,
              children: const [
                _StatCard(
                  title: 'SESSIONS',
                  value: '0',
                ),
                _StatCard(
                  title: 'SECURITY SCORE',
                  value: '0%',
                ),
                _StatCard(
                  title: 'CODE LINES',
                  value: '0',
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/generate_code');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8C1CF),
                foregroundColor: const Color(0xFF141414),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'START CODING',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            
            const SizedBox(height: 64),
            
            Text(
              'recent history',
              style: AppTypography.heroTitle(context).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF3F3F3F)),
              ),
              child: Center(
                child: Text(
                  'No code history yet.',
                  style: GoogleFonts.spaceGrotesk(color: AppColors.textMuted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textMuted,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.heroTitle(context).copyWith(fontSize: 32),
          ),
        ],
      ),
    );
  }
}
