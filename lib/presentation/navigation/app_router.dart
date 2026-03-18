import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/connection/connection_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/diagnostics/diagnostics_screen.dart';
import '../screens/history/history_screen.dart';
import 'routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.connection,
        builder: (_, __) => const ConnectionScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            _MainShell(child: child, state: state),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: Routes.diagnostics,
            builder: (_, __) => const DiagnosticsScreen(),
          ),
          GoRoute(
            path: Routes.history,
            builder: (_, __) => const HistoryScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Bottom navigation shell shared by the three main tabs.
class _MainShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const _MainShell({required this.child, required this.state});

  int _currentIndex() {
    return switch (state.matchedLocation) {
      Routes.dashboard => 0,
      Routes.diagnostics => 1,
      Routes.history => 2,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(),
        onDestinationSelected: (i) {
          context.go(switch (i) {
            0 => Routes.dashboard,
            1 => Routes.diagnostics,
            2 => Routes.history,
            _ => Routes.dashboard,
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.speed),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_rounded),
            label: 'Diagnóstico',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}
