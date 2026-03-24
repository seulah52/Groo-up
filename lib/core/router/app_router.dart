import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/garden/presentation/screens/garden_screen.dart';
import '../../features/garden/presentation/screens/groo_detail_screen.dart';
import '../../features/input/presentation/screens/input_screen.dart';
import '../../features/interview/presentation/screens/interview_screen.dart';
import '../../features/insight/presentation/screens/insight_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/garden',
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoginPage = state.matchedLocation == '/login';
      if (!isLoggedIn && !isLoginPage) return '/login';
      if (isLoggedIn && isLoginPage) return '/garden';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/garden',
        builder: (_, __) => const GardenScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, s) => GrooDetailScreen(grooId: s.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(path: '/input',   builder: (_, __) => const InputScreen()),
      GoRoute(
        path: '/interview/:grooId',
        builder: (_, s) => InterviewScreen(grooId: s.pathParameters['grooId']!),
      ),
      GoRoute(path: '/insight', builder: (_, __) => const InsightScreen()),
    ],
  );
}
