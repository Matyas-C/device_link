import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;

  const NavBar({
    super.key,
    required this.selectedIndex,
  });

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/devices');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _onTap(context, index),
      backgroundColor: Colors.black45,
      height: 100,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Domů',
        ),
        NavigationDestination(
          icon: Icon(Icons.devices),
          label: 'Zařízení',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Nastavení',
        ),
      ],
    );
  }
}
