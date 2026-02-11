import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/bloc/auth_bloc.dart';
import '../../presentation/auth/pages/login_page.dart';
import '../../presentation/auth/pages/register_page.dart';
import '../../presentation/family/pages/family_setup_page.dart';
import '../../presentation/pets/pages/pet_detail_page.dart';
import '../../presentation/pets/pages/form/pet_form_page.dart';
import '../../presentation/pets/pages/pets_list_page.dart';
import '../../presentation/tasks/pages/task_form_page.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggedIn = authState.isAuthenticated;
      final hasFamily = authState.hasFamily;

      final isOnAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isOnFamilySetup = state.matchedLocation == '/family-setup';

      // Not logged in - redirect to login
      if (!isLoggedIn && !isOnAuthRoute) {
        return '/login';
      }

      // Logged in but on auth route
      if (isLoggedIn && isOnAuthRoute) {
        return hasFamily ? '/pets' : '/family-setup';
      }

      // Logged in but no family and not on family setup
      if (isLoggedIn && !hasFamily && !isOnFamilySetup && !isOnAuthRoute) {
        return '/family-setup';
      }

      // Logged in with family but on family setup - redirect to pets
      if (isLoggedIn && hasFamily && isOnFamilySetup) {
        return '/pets';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/family-setup',
        name: 'family-setup',
        builder: (context, state) => const FamilySetupPage(),
      ),
      GoRoute(
        path: '/pets',
        name: 'pets',
        builder: (context, state) => const PetsListPage(),
        routes: [
          GoRoute(
            path: 'add',
            name: 'pet-add',
            builder: (context, state) => const PetFormPage(),
          ),
          GoRoute(
            path: ':petId',
            name: 'pet-detail',
            builder: (context, state) {
              final petId = state.pathParameters['petId']!;
              return PetDetailPage(petId: petId);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'pet-edit',
                builder: (context, state) {
                  final petId = state.pathParameters['petId']!;
                  return PetFormPage(petId: petId);
                },
              ),
              GoRoute(
                path: 'tasks/add',
                name: 'task-add',
                builder: (context, state) {
                  final petId = state.pathParameters['petId']!;
                  return TaskFormPage(petId: petId);
                },
              ),
              GoRoute(
                path: 'tasks/:taskId/edit',
                name: 'task-edit',
                builder: (context, state) {
                  final petId = state.pathParameters['petId']!;
                  final taskId = state.pathParameters['taskId']!;
                  return TaskFormPage(petId: petId, taskId: taskId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    stream.listen((_) {
      notifyListeners();
    });
  }
}
