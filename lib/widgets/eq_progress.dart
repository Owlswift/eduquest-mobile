import 'package:flutter/material.dart';

class EQProgress extends StatelessWidget {
  final int current;
  final int total;

  const EQProgress({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: current / total,
      minHeight: 10,
      borderRadius: BorderRadius.circular(20),
      backgroundColor: Colors.grey.shade300,
      valueColor: const AlwaysStoppedAnimation(
        Color(0xFF58CC02),
      ),
    );
  }
}