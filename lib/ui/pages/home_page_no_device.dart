import 'package:flutter/material.dart';

class HomePageNoDevice extends StatelessWidget {
  final Function(int) onNavigate;

  const HomePageNoDevice({
    super.key,
    required this.onNavigate
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Žádné zařízení není připojeno',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => onNavigate(1),
            child: const Text('Přejít na kartu zařízení'),
          ),
        ],
      ),
    );
  }
}