import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePageNoDevice extends StatelessWidget {

  const HomePageNoDevice({super.key});

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
            onPressed: () => context.go('/devices'),
            child: const Text('Přejít na kartu zařízení'),
          ),
        ],
      ),
    );
  }
}