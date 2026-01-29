import 'package:flutter/material.dart';
import 'package:upence/core/widgets/navigation_sidebar.dart';

/// A wrapper widget that provides a Scaffold with a drawer for sidebar pages.
///
/// This widget wraps page content with a Scaffold that includes a navigation
/// drawer. It's used for all pages accessible via the sidebar menu.
class PageWrapper extends StatelessWidget {
  const PageWrapper({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = false,
  });

  final Widget body;
  final Widget title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  
  /// If true, shows a back button instead of the menu button.
  /// This is useful when the page is accessed from a subpage (e.g., Settings)
  /// instead of directly from the sidebar.
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      drawer: showBackButton ? null : NavigationSidebar(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        leading: _buildLeading(context, scaffoldKey),
        title: title,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget? _buildLeading(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    if (showBackButton) {
      // Show back button when accessed from a subpage
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      );
    } else {
      // Show menu button for sidebar pages
      return IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      );
    }
  }
}
