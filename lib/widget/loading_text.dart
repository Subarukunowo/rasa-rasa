import 'package:flutter/material.dart';

class LoadingText extends StatelessWidget {
  final int currentStep;

  const LoadingText({
    Key? key,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingMessages = [
      'Memuat data...',
      'Menyiapkan aset...',
      'Menghubungkan...',
      'Hampir selesai...',
      'Selesai!',
    ];

    String message = currentStep < loadingMessages.length
        ? loadingMessages[currentStep]
        : 'Selesai!';

    return Text(
      message,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
      ),
    );
  }
}
