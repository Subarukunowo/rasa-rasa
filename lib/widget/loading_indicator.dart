import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const LoadingIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        bool isActive = index <= currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 16 : 12,
          height: isActive ? 16 : 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : Colors.white38,
          ),
        );
      }),
    );
  }
}
