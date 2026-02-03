import 'package:go_router/go_router.dart';
import 'package:upence/views/home/home_view.dart';
import '../../views/setup/setup_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final routerProvider = FutureProvider<GoRouter>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final setupCompleted = prefs.getBool('setup_completed') ?? false;

  return GoRouter(
    initialLocation: setupCompleted ? '/' : '/setup',
    routes: [
      GoRoute(name: 'setup', path: '/setup', builder: (context, state) => const SetupView()),
      GoRoute(name: 'home', path: '/', builder: (context, state) => const HomeView()),
    ],
  );
});
