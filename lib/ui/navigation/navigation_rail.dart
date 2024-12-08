import 'package:flutter/material.dart';

class NavRail extends StatelessWidget {
  const NavRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      minWidth: 200,
      backgroundColor: Colors.black45,
      leading: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 50),
        child: FlutterLogo(size: 40),
      ),
      onDestinationSelected: onDestinationSelected,
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
