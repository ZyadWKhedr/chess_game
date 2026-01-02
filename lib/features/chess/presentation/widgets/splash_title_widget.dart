import 'package:flutter/material.dart';

class SplashTitleWidget extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final AnimationController animationController;

  const SplashTitleWidget({
    super.key,
    required this.fadeAnimation,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Opacity(opacity: fadeAnimation.value, child: child);
          },
          child: Text(
            'Grandmaster Chess',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return Opacity(opacity: fadeAnimation.value, child: child);
          },
          child: Text(
            'Master the Game',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    );
  }
}
