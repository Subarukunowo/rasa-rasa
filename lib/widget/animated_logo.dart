// lib/widget/animated_logo.dart
import 'package:flutter/material.dart';

class AnimatedLogo extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  final int currentStep;

  const AnimatedLogo({
    Key? key,
    required this.scaleAnimation,
    required this.fadeAnimation,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([scaleAnimation, fadeAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Opacity(
            opacity: fadeAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                    Colors.blue.shade100,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.spa_outlined,
                  size: 60,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}