import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'slides/slide_1_hero.dart';
import 'slides/story_slides.dart';

class FixedStage extends StatelessWidget {
  final int currentSlide;
  final double scrollProgress;
  final VoidCallback? onStartHandControl;

  const FixedStage({
    super.key,
    required this.currentSlide,
    required this.scrollProgress,
    this.onStartHandControl,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Zoom effect: Scale 1.0 -> 0.9 during first slide scroll
    final scale = currentSlide == 0 ? 1.0 - (scrollProgress * 0.1) : 0.9;

    // Background opacity: Much more transparent to show 3D sphere
    final bgOpacity = currentSlide == 0 ? 0.15 - (scrollProgress * 0.05) : 0.1;

    return Center(
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size.width * 0.9 > 1400 ? 1400 : size.width * 0.9,
          constraints: const BoxConstraints(minHeight: 600),
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
          decoration: BoxDecoration(
            color: AppColors.innerBg.withOpacity(bgOpacity),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 40 + (scrollProgress * 20),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _getSlideWidget(currentSlide),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSlideWidget(int index) {
    switch (index) {
      case 0:
        return Slide1Hero(
          key: const ValueKey('slide1'),
          onStartHandControl: onStartHandControl,
          showButtons: false, // Buttons are on the interactive overlay
        );
      case 1:
        return const Slide2Analysis(key: ValueKey('slide2'));
      case 2:
        return const Slide3Generation(key: ValueKey('slide3'));
      case 3:
        return const Slide4Security(key: ValueKey('slide4'));
      default:
        return Slide1Hero(
          key: const ValueKey('slide1'),
          onStartHandControl: onStartHandControl,
          showButtons: false,
        );
    }
  }
}
