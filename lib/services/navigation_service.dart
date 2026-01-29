import 'package:flutter/material.dart';

/// Service for managing navigation with stack management for sidebar pages.
class NavigationService {
  /// Routes that are accessible via the sidebar navigation menu.
  static const Set<String> sidebarRoutes = {
    '/',
    '/accounts',
    '/analytics',
    '/settings',
  };

  /// Checks if the given route is accessible via the sidebar menu.
  static bool isSidebarPage(String? route) {
    if (route == null) return false;
    return sidebarRoutes.contains(route);
  }

  /// Gets the current route name from the context.
  static String? getCurrentRoute(BuildContext context) {
    return ModalRoute.of(context)?.settings.name;
  }

  /// Navigates to a sidebar-accessible page with stack management.
  ///
  /// If the current page is not the home page, this method will pop all
  /// pages until reaching the home page, then navigate to the target route.
  /// This prevents deep navigation stacks when using the sidebar menu.
  ///
  /// Parameters:
  /// - [context]: The BuildContext for navigation
  /// - [targetRoute]: The route to navigate to (must be a sidebar route)
  /// - [scaffoldKey]: Optional GlobalKey for the Scaffold to close drawer
  static Future<void> navigateToSidebarPage(
    BuildContext context,
    String targetRoute, {
    GlobalKey<ScaffoldState>? scaffoldKey,
  }) async {
    assert(
      sidebarRoutes.contains(targetRoute),
      'Target route must be a sidebar route',
    );

    final navigator = Navigator.of(context);
    final currentRoute = getCurrentRoute(context);

    // Close the drawer if provided
    scaffoldKey?.currentState?.closeDrawer();

    // If already on the target route, do nothing
    if (currentRoute == targetRoute) {
      return;
    }

    // If not on home page, pop until home
    if (currentRoute != '/') {
      navigator.popUntil((route) => route.isFirst || route.settings.name == '/');
    }

    // Navigate to target if not home
    if (targetRoute != '/') {
      navigator.pushNamed(targetRoute);
    }
  }

  /// Navigates to a subpage using standard navigation (push).
  ///
  /// This method is used for pages that are not accessible via the sidebar.
  /// These pages will have a back button instead of a menu button.
  ///
  /// Parameters:
  /// - [context]: The BuildContext for navigation
  /// - [page]: The widget page to navigate to
  static Future<T?> navigateToSubpage<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
