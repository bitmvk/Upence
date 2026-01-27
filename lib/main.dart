import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:upence/core/theme/app_theme.dart';
import 'package:upence/core/providers/app_providers.dart';
import 'package:upence/core/widgets/navigation_sidebar.dart';
import 'package:upence/data/database/app_database.dart';
import 'package:upence/features/home/presentation/home_page.dart';
import 'package:upence/features/sms/presentation/unprocessed_sms_page.dart';
import 'package:upence/features/settings/presentation/settings_page.dart';
import 'package:upence/features/analytics/presentation/analytics_page.dart';
import 'package:upence/features/accounts/presentation/account_page.dart';
import 'package:upence/features/onboarding/presentation/setup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.getDatabase();

  // Set up SMS method channel
  const smsChannel = MethodChannel('com.example.upence/sms');
  smsChannel.setMethodCallHandler((call) async {
    if (call.method == 'onSMSReceived') {
      final sender = call.arguments['sender'] as String?;
      final message = call.arguments['message'] as String?;
      final timestamp = call.arguments['timestamp'] as int?;

      if (sender != null && message != null && timestamp != null) {
        // Store SMS in database
        // This would need to be handled via a service or provider
        // For now, we'll just log it
        debugPrint('SMS received: $sender - $message');
      }
    }
  });

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupCompletedAsync = ref.watch(setupCompletedProvider);
    final themeModeAsync = ref.watch(themeModeProvider);

    return setupCompletedAsync.when(
      data: (setupCompleted) {
        return themeModeAsync.when(
          data: (themeMode) => MaterialApp(
            title: 'Upence',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: setupCompleted ? const MainApp() : const SetupPage(),
          ),
          loading: () => MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
          error: (error, stack) => MaterialApp(
            home: Scaffold(body: Center(child: Text('Error: $error'))),
          ),
        );
      },
      loading: () => MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $error'))),
      ),
    );
  }
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  NavItem _selectedNavItem = NavItem.home;

  @override
  Widget build(BuildContext context) {
    final themeModeAsync = ref.watch(themeModeProvider);

    return themeModeAsync.when(
      data: (themeMode) => MaterialApp(
        title: 'Upence',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: _buildMainPage(),
      ),
      loading: () => MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $error'))),
      ),
    );
  }

  Widget _buildMainPage() {
    return Scaffold(
      key: _scaffoldKey,
      drawer: NavigationSidebar(
        selectedItem: _selectedNavItem,
        onItemSelected: (item) {
          setState(() => _selectedNavItem = item);
        },
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(_getAppBarTitle()),
        actions: _buildAppBarActions(),
      ),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedNavItem) {
      case NavItem.home:
        return 'Upence';
      case NavItem.accounts:
        return 'Accounts';
      case NavItem.analytics:
        return 'Analytics';
      case NavItem.settings:
        return 'Settings';
    }
  }

  List<Widget> _buildAppBarActions() {
    switch (_selectedNavItem) {
      case NavItem.home:
        return [
          Consumer(
            builder: (context, ref, child) {
              final unprocessedCountAsync = ref.watch(
                unprocessedSMSCountProvider,
              );
              return unprocessedCountAsync.when(
                data: (count) {
                  if (count > 0) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.sms),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const UnprocessedSMSPage(),
                              ),
                            );
                          },
                        ),
                        if (count > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                count > 99 ? '99+' : count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
              );
            },
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildBody() {
    switch (_selectedNavItem) {
      case NavItem.home:
        return const HomePage();
      case NavItem.accounts:
        return const AccountPage();
      case NavItem.analytics:
        return const AnalyticsPage();
      case NavItem.settings:
        return const SettingsPage();
    }
  }

  Widget _buildFAB() {
    switch (_selectedNavItem) {
      case NavItem.home:
        return Consumer(
          builder: (context, ref, child) {
            final unprocessedCountAsync = ref.watch(
              unprocessedSMSCountProvider,
            );
            return unprocessedCountAsync.when(
              data: (count) {
                if (count > 0) {
                  return FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UnprocessedSMSPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.sms),
                    label: Text('$count Unprocessed'),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
