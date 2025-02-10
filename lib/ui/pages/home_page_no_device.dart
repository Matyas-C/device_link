import 'package:flutter/material.dart';

class HomePageNoDevice extends StatelessWidget {
  final Function(int) navigateTo;

  const HomePageNoDevice({
    super.key,
    required this.navigateTo
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
            onPressed: () => navigateTo(1),
            child: const Text('Přejít na kartu zařízení'),
          ),
        ],
      ),
    );
  }
}