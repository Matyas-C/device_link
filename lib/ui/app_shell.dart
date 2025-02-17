import 'package:flutter/material.dart';
import 'package:device_link/ui/navigation/navigation_rail.dart';
import 'package:device_link/ui/navigation/navigation_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex
  });

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: isWideScreen ? _buildWideScreenLayout() : _buildNarrowScreenLayout(),
      bottomNavigationBar: isWideScreen ? null : NavBar(selectedIndex: currentIndex),
    );
  }

  Widget _buildWideScreenLayout() {
    return Row(
      children: [
        NavRail(selectedIndex: currentIndex),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildNarrowScreenLayout() {
    return child;
  }
}
