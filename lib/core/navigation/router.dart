import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upence/views/home/home_view.dart';
import 'package:upence/core/ui/widgets/app_drawer.dart';
import '../../views/setup/setup_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceholderPage extends StatelessWidget {
  final String title;
  final String currentRoute;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(currentRoute: currentRoute),
      appBar: AppBar(
        title: Text(title),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '$title Coming Soon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

final routerProvider = FutureProvider<GoRouter>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final setupCompleted = prefs.getBool('setup_completed') ?? false;

  return GoRouter(
    initialLocation: setupCompleted ? '/' : '/setup',
    routes: [
      GoRoute(
        name: 'setup',
        path: '/setup',
        builder: (context, state) => const SetupView(),
      ),
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        name: 'transactions',
        path: '/transactions',
        builder: (context, state) => const PlaceholderPage(
          title: 'Transactions',
          currentRoute: '/transactions',
        ),
      ),
      GoRoute(
        name: 'categories',
        path: '/categories',
        builder: (context, state) => const PlaceholderPage(
          title: 'Categories',
          currentRoute: '/categories',
        ),
      ),
      GoRoute(
        name: 'tags',
        path: '/tags',
        builder: (context, state) =>
            const PlaceholderPage(title: 'Tags', currentRoute: '/tags'),
      ),
      GoRoute(
        name: 'accounts',
        path: '/accounts',
        builder: (context, state) => const PlaceholderPage(
          title: 'Bank Accounts',
          currentRoute: '/accounts',
        ),
      ),
      GoRoute(
        name: 'settings',
        path: '/settings',
        builder: (context, state) =>
            const PlaceholderPage(title: 'Settings', currentRoute: '/settings'),
      ),
    ],
  );
});
