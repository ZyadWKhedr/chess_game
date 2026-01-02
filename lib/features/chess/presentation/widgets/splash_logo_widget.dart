import 'package:flutter/material.dart';

class SplashLogoWidget extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final AnimationController animationController;

  const SplashLogoWidget({
    super.key,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: Transform.scale(scale: scaleAnimation.value, child: child),
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(Icons.castle, size: 80, color: colorScheme.primary),
      ),
    );
  }
}
