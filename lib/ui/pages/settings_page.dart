import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Nastavení',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
