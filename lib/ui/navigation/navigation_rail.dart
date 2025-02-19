import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavRail extends StatelessWidget {
  final int selectedIndex;

  const NavRail({
    super.key,
    required this.selectedIndex,
  });

  void _onDestinationSelected(BuildContext context, int index) {
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
    return NavigationRail(
      selectedIndex: selectedIndex,
      minWidth: 200,
      backgroundColor: Colors.black45,
      leading: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 50),
        child: Image(
          image: AssetImage('assets/icons/logo-nobg-white.png'),
          width: 80,
        ),
      ),
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home),
          selectedIcon: Icon(Icons.home_filled),
          label: Text('Domů'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.devices),
          selectedIcon: Icon(Icons.devices),
          label: Text('Zařízení'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          selectedIcon: Icon(Icons.settings),
          label: Text('Nastavení'),
        ),
      ],
    );
  }
}
