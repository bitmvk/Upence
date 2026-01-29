import 'package:flutter/material.dart';
import 'package:upence/services/navigation_service.dart';

/// A shared AppBar widget that displays a menu button for sidebar pages
/// and a back button for subpages.
///
/// This widget automatically determines whether to show a menu button or
/// back button based on the current route. Pages accessible via the sidebar
/// (Home, Accounts, Analytics, Settings) will show a menu button. Subpages
/// will show a back button.
class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a shared AppBar.
  ///
  /// Parameters:
  /// - [title]: The title to display in the AppBar
  /// - [scaffoldKey]: GlobalKey for the Scaffold to open the drawer
  /// - [actions]: Optional list of widgets to display in the actions area
  /// - [automaticallyImplyLeading]: Whether to automatically add a leading widget
  const SharedAppBar({
    super.key,
    required this.title,
    this.scaffoldKey,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  /// The title to display in the AppBar.
  final Widget title;

  /// GlobalKey for the Scaffold to open the drawer.
  final GlobalKey<ScaffoldState>? scaffoldKey;

  /// Optional list of widgets to display in the actions area.
  final List<Widget>? actions;

  /// Whether to automatically add a leading widget (menu or back button).
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    final currentRoute = NavigationService.getCurrentRoute(context);
    final isSidebarPage = NavigationService.isSidebarPage(currentRoute);

    return AppBar(
      title: title,
      leading: automaticallyImplyLeading
          ? _buildLeading(context, isSidebarPage)
          : null,
      actions: actions,
    );
  }

  Widget? _buildLeading(BuildContext context, bool isSidebarPage) {
    if (isSidebarPage) {
      // Show menu button for sidebar pages
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => scaffoldKey?.currentState?.openDrawer(),
      );
    } else {
      // Show back button for subpages (default behavior)
      return null; // AppBar will handle this automatically
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
