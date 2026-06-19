import 'package:flutter/material.dart';

class EQButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool fullWidth;

  const EQButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF58CC02),
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}