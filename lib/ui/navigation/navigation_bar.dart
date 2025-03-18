import 'package:device_link/ui/constants/colors.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
      backgroundColor: raisedColor,
      height: 100,
      indicatorColor: primaryColorLight.withOpacity(0.8),
      destinations: const [
        NavigationDestination(
          icon: Icon(FluentIcons.home_32_filled),
          label: 'Domů',
        ),
        NavigationDestination(
          icon: Icon(FluentIcons.phone_laptop_32_filled),
          label: 'Zařízení',
        ),
        NavigationDestination(
          icon: Icon(FluentIcons.settings_32_filled),
          label: 'Nastavení',
        ),
      ],
    );
  }
}
