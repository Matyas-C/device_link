import 'package:go_router/go_router.dart';
import 'package:device_link/ui/app_shell.dart';
import 'package:device_link/ui/pages/home_page.dart';
import 'package:device_link/ui/pages/devices_page.dart';
import 'package:device_link/ui/pages/settings_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
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
