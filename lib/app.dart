import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/landing/presentation/screens/landing_screen.dart';
import 'features/projects/presentation/screens/dashboard_screen.dart';

class TramaApp extends ConsumerWidget {
  const TramaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Trama',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

/// Provider del router, para poder leer el estado de auth
/// y redirigir según haya sesión o no.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final isLoggedIn = user != null;
      final onAuthRoute = state.matchedLocation == '/auth';
      final onDashboardRoute = state.matchedLocation.startsWith('/dashboard');

      // Si no hay sesión y quiere ir al dashboard → al auth
      if (!isLoggedIn && onDashboardRoute) return '/auth';

      // Si hay sesión y está en auth → al dashboard
      if (isLoggedIn && onAuthRoute) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});