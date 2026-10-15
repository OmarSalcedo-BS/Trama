import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/characters/presentation/screens/character_form_screen.dart';
import 'features/landing/presentation/screens/landing_screen.dart';
import 'features/project_detail/presentation/screens/project_detail_screen.dart';
import 'features/projects/presentation/screens/dashboard_screen.dart';
import 'features/world_entries/presentation/screens/world_category_form_screen.dart';
import 'features/world_entries/presentation/screens/world_entry_form_screen.dart';

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

/// Provider del router.
/// Se encarga de:
///  - Definir todas las rutas de la app.
///  - Redirigir según haya sesión o no (rutas protegidas).
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final isLoggedIn = user != null;

      final location = state.matchedLocation;
      final onAuthRoute = location == '/auth';
      final onProtectedRoute =
          location.startsWith('/dashboard') ||
          location.startsWith('/project');

      // Sin sesión + quiere ruta protegida → al login
      if (!isLoggedIn && onProtectedRoute) return '/auth';

      // Con sesión + está en auth → al dashboard
      if (isLoggedIn && onAuthRoute) return '/dashboard';

      return null;
    },
    routes: [
      // ============================================
      // PÚBLICAS
      // ============================================
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // ============================================
      // PROTEGIDAS
      // ============================================
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Detalle de proyecto + rutas anidadas
      GoRoute(
        path: '/project/:id',
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return ProjectDetailScreen(projectId: projectId);
        },
        routes: [
          // Crear personaje
          GoRoute(
            path: 'characters/new',
            builder: (context, state) {
              final projectId = state.pathParameters['id']!;
              return CharacterFormScreen(projectId: projectId);
            },
          ),
          // Editar personaje
          GoRoute(
            path: 'characters/:characterId',
            builder: (context, state) {
              final projectId = state.pathParameters['id']!;
              final characterId = state.pathParameters['characterId']!;
              return CharacterFormScreen(
                projectId: projectId,
                characterId: characterId,
              );
            },
          ),
          // Editar ficha de mundo
          GoRoute(
            path: 'world/categories/new',
            builder: (context, state) {
              final projectId = state.pathParameters['id']!;
              return WorldCategoryFormScreen(projectId: projectId);
            },
          ),
          GoRoute(
            path: 'world/categories/:categoryId',
            builder: (context, state) {
              final projectId = state.pathParameters['id']!;
              final categoryId = state.pathParameters['categoryId']!;
              return WorldCategoryFormScreen(
                projectId: projectId,
                categoryId: categoryId,
              );
            },
          ),
          // Fichas de mundo
        GoRoute(
        path: 'world/entries/new',
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          final initialCategoryId = state.extra as String?;
          return WorldEntryFormScreen(
            projectId: projectId,
            initialCategoryId: initialCategoryId,
          );
        },
      ),
        GoRoute(
        path: 'world/entries/:entryId',
        builder: (context, state) {
          final projectId = state.pathParameters['id']!;
          final entryId = state.pathParameters['entryId']!;
          return WorldEntryFormScreen(
            projectId: projectId,
            entryId: entryId,
          );
        },
      ),
        ],
      ),
    ],
  );
});