import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:device_link/ui/app_shell.dart';
import 'package:device_link/ui/pages/home_page.dart';
import 'package:device_link/ui/pages/devices_page.dart';
import 'package:device_link/ui/pages/settings_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  navigatorKey: navigatorKey,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(
          currentIndex: _getSelectedIndex(state.uri.toString()),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: '/devices',
          pageBuilder: (context, state) => const NoTransitionPage(child: DevicesPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
        ),
      ],
    ),
  ],
);

GoRouter get router => _router;

int _getSelectedIndex(String location) {
  switch (Uri.parse(location).path) {
    case '/home':
      return 0;
    case '/devices':
      return 1;
    case '/settings':
      return 2;
    default:
      return 0;
  }
}
