import 'dart:io';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:device_link/ui/constants/colors.dart';

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
      backgroundColor: raisedColor,
      leading: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: logoGap),
        child: Opacity(
          opacity: 0.8,
          child: Image(
            image: const AssetImage('assets/icons/logo-nobg-white.png'),
            width: logoSize,
          ),
        ),
      ),
      indicatorColor: primaryColorLight.withOpacity(0.8),
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      labelType: isPhone ? NavigationRailLabelType.none : NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(FluentIcons.home_24_filled),
          selectedIcon: Icon(FluentIcons.home_24_filled),
          label: Text('Domů'),
        ),
        NavigationRailDestination(
          icon: Icon(FluentIcons.phone_laptop_32_filled),
          selectedIcon: Icon(FluentIcons.phone_laptop_32_filled),
          label: Text('Zařízení'),
        ),
        NavigationRailDestination(
          icon: Icon(FluentIcons.settings_24_filled),
          selectedIcon: Icon(FluentIcons.settings_24_filled),
          label: Text('Nastavení'),
        ),
      ],
    );
  }
}
