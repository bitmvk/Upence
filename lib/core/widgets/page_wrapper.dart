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
  });

  final Widget body;
  final Widget title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      drawer: NavigationSidebar(scaffoldKey: scaffoldKey),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
        title: title,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
