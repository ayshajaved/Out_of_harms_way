import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BackgroundLayers extends StatelessWidget {
  const BackgroundLayers({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        // Layer 0: Grid Overlay (40px grid, 25% opacity, soft-light blend)
        GridOverlay(),

        // Layer 1: Radial Spotlight (center glow, 40% opacity)
        SpotlightOverlay(),
      ],
    );
  }
}

class GridOverlay extends StatelessWidget {
  const GridOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.25,
        child: CustomPaint(
          size: Size.infinite,
          painter: GridPainter(gridSize: 40, lineColor: AppColors.gridLines),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;
  final Color lineColor;

  GridPainter({required this.gridSize, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpotlightOverlay extends StatelessWidget {
  const SpotlightOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.55,
            colors: [
              Color(0x24FFFFFF), // 14% white
              Colors.transparent,
            ],
            stops: [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
