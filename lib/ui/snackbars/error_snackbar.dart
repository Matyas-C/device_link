import 'package:flutter/material.dart';

class ErrorSnackBar extends StatelessWidget {
  final Text text;

  const ErrorSnackBar({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      constraints: const BoxConstraints(
          maxWidth: 100
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              text,
            ],
          ),
        ),
      ),
    );
  }
}