import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
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
