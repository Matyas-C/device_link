import 'dart:io';

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
    final bool isPhone = Platform.isAndroid || Platform.isIOS; //pro nizsi nav rail pro mobily v landscape modu
    final double logoGap = isPhone ? 30 : 50;
    final double logoSize = isPhone ? 60 : 80;

    return NavigationRail(
      selectedIndex: selectedIndex,
      minWidth: 200,
      backgroundColor: Colors.black45,
      leading: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: logoGap),
        child: Image(
          image: const AssetImage('assets/icons/logo-nobg-white.png'),
          width: logoSize,
        ),
      ),
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      labelType: isPhone ? NavigationRailLabelType.none : NavigationRailLabelType.all,
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
