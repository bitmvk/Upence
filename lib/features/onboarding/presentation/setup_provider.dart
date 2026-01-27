import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upence/core/providers/app_providers.dart';
import 'package:upence/data/models/category.dart';
import 'package:upence/data/models/tag.dart';
import 'package:upence/data/models/bank_account.dart';
import 'package:upence/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

enum SetupStep { welcome, permissions, bankAccount, categories, tags }

class SetupState {
  final SetupStep currentPage;
  final bool smsPermissionGranted;
  final bool notificationPermissionGranted;
  final int smsPermissionRequestCount;
  final int notificationPermissionRequestCount;
  final bool smsPermissionDeniedOnce;
  final bool notificationPermissionDeniedOnce;
  final bool smsPermissionPermanentlyDenied;
  final bool notificationPermissionPermanentlyDenied;
  final List<BankAccount> bankAccounts;
  final List<Category> categories;
  final List<Tag> tags;
  final bool isCompleted;

  SetupState({
    this.currentPage = SetupStep.welcome,
    this.smsPermissionGranted = false,
    this.notificationPermissionGranted = false,
    this.smsPermissionRequestCount = 0,
    this.notificationPermissionRequestCount = 0,
    this.smsPermissionDeniedOnce = false,
    this.notificationPermissionDeniedOnce = false,
    this.smsPermissionPermanentlyDenied = false,
    this.notificationPermissionPermanentlyDenied = false,
    this.bankAccounts = const [],
    this.categories = const [],
    this.tags = const [],
    this.isCompleted = false,
  });

  SetupState copyWith({
    SetupStep? currentPage,
    bool? smsPermissionGranted,
    bool? notificationPermissionGranted,
    int? smsPermissionRequestCount,
    int? notificationPermissionRequestCount,
    bool? smsPermissionDeniedOnce,
    bool? notificationPermissionDeniedOnce,
    bool? smsPermissionPermanentlyDenied,
    bool? notificationPermissionPermanentlyDenied,
    List<BankAccount>? bankAccounts,
    List<Category>? categories,
    List<Tag>? tags,
    bool? isCompleted,
  }) {
    return SetupState(
      currentPage: currentPage ?? this.currentPage,
      smsPermissionGranted: smsPermissionGranted ?? this.smsPermissionGranted,
      notificationPermissionGranted:
          notificationPermissionGranted ?? this.notificationPermissionGranted,
      smsPermissionRequestCount:
          smsPermissionRequestCount ?? this.smsPermissionRequestCount,
      notificationPermissionRequestCount:
          notificationPermissionRequestCount ??
          this.notificationPermissionRequestCount,
      smsPermissionDeniedOnce:
          smsPermissionDeniedOnce ?? this.smsPermissionDeniedOnce,
      notificationPermissionDeniedOnce:
          notificationPermissionDeniedOnce ??
          this.notificationPermissionDeniedOnce,
      smsPermissionPermanentlyDenied:
          smsPermissionPermanentlyDenied ?? this.smsPermissionPermanentlyDenied,
      notificationPermissionPermanentlyDenied:
          notificationPermissionPermanentlyDenied ??
          this.notificationPermissionPermanentlyDenied,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  bool get canProceedToNext {
    switch (currentPage) {
      case SetupStep.welcome:
        return true;
      case SetupStep.permissions:
        return smsPermissionGranted;
      case SetupStep.bankAccount:
        return bankAccounts.isNotEmpty;
      case SetupStep.categories:
        return true;
      case SetupStep.tags:
        return true;
    }
  }

  bool get isLastPage => currentPage == SetupStep.tags;
  bool get isFirstPage => currentPage == SetupStep.welcome;
}

class SetupNotifier extends StateNotifier<SetupState> {
  final Ref ref;
  final PermissionService _permissionService = PermissionService();

  SetupNotifier(this.ref) : super(SetupState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final smsGranted = await _permissionService.checkPermission(Permission.sms);
    final notificationGranted = await _permissionService.checkPermission(
      Permission.notification,
    );

    final smsPermanentlyDenied = await _permissionService.isPermanentlyDenied(
      Permission.sms,
    );
    final notificationPermanentlyDenied = await _permissionService
        .isPermanentlyDenied(Permission.notification);

    state = state.copyWith(
      smsPermissionGranted: smsGranted,
      notificationPermissionGranted: notificationGranted,
      smsPermissionPermanentlyDenied: smsPermanentlyDenied,
      notificationPermissionPermanentlyDenied: notificationPermanentlyDenied,
    );
  }

  Future<void> refreshPermissions() async {
    await _checkPermissions();
  }

  void nextPage() {
    if (!state.canProceedToNext) return;

    if (state.isLastPage) {
      completeSetup();
      return;
    }

    final currentPageIndex = SetupStep.values.indexOf(state.currentPage);
    final nextPage = SetupStep.values[currentPageIndex + 1];
    state = state.copyWith(currentPage: nextPage);
  }

  void previousPage() {
    if (state.isFirstPage) return;

    final currentPageIndex = SetupStep.values.indexOf(state.currentPage);
    final previousPage = SetupStep.values[currentPageIndex - 1];
    state = state.copyWith(currentPage: previousPage);
  }

  Future<void> requestSMSPermission() async {
    final granted = await _permissionService.requestPermission(Permission.sms);

    // Track if permission was denied at least once
    if (!granted) {
      state = state.copyWith(smsPermissionDeniedOnce: true);
    }

    // Check if permission is permanently denied
    final canRequest = await canRequestPermission(Permission.sms);
    state = state.copyWith(smsPermissionPermanentlyDenied: !canRequest);

    await _checkPermissions();
  }

  Future<void> requestNotificationPermission() async {
    final granted = await _permissionService.requestPermission(
      Permission.notification,
    );

    // Track if permission was denied at least once
    if (!granted) {
      state = state.copyWith(notificationPermissionDeniedOnce: true);
    }

    // Check if permission is permanently denied
    final canRequest = await canRequestPermission(Permission.notification);
    state = state.copyWith(
      notificationPermissionPermanentlyDenied: !canRequest,
    );

    await _checkPermissions();
  }

  Future<bool> canRequestPermission(Permission permission) async {
    return !(await _permissionService.isPermanentlyDenied(permission));
  }

  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  void addBankAccount(BankAccount account) {
    final updated = List<BankAccount>.from(state.bankAccounts);
    updated.add(account);
    state = state.copyWith(bankAccounts: updated);
  }

  void removeBankAccount(int index) {
    final updated = List<BankAccount>.from(state.bankAccounts);
    updated.removeAt(index);
    state = state.copyWith(bankAccounts: updated);
  }

  void addCategory(Category category) {
    final updated = List<Category>.from(state.categories);
    updated.add(category);
    state = state.copyWith(categories: updated);
  }

  void removeCategory(int index) {
    final updated = List<Category>.from(state.categories);
    updated.removeAt(index);
    state = state.copyWith(categories: updated);
  }

  void addTag(Tag tag) {
    final updated = List<Tag>.from(state.tags);
    updated.add(tag);
    state = state.copyWith(tags: updated);
  }

  void removeTag(int index) {
    final updated = List<Tag>.from(state.tags);
    updated.removeAt(index);
    state = state.copyWith(tags: updated);
  }

  List<Category> getPrefilledCategories() {
    final categories = [
      Category(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        name: 'Food',
        icon: 'restaurant',
        color: 0xFFEF476F,
        description: 'Food and dining expenses',
      ),
      Category(
        id: DateTime.now().millisecondsSinceEpoch + 2,
        name: 'Transport',
        icon: 'directions_car',
        color: 0xFFFFD166,
        description: 'Transportation expenses',
      ),
      Category(
        id: DateTime.now().millisecondsSinceEpoch + 3,
        name: 'Shopping',
        icon: 'shopping_cart',
        color: 0xFF4361EE,
        description: 'Shopping expenses',
      ),
      Category(
        id: DateTime.now().millisecondsSinceEpoch + 4,
        name: 'Bills',
        icon: 'receipt',
        color: 0xFFEF476F,
        description: 'Bills and utilities',
      ),
      Category(
        id: DateTime.now().millisecondsSinceEpoch + 5,
        name: 'Entertainment',
        icon: 'movie',
        color: 0xFF4361EE,
        description: 'Entertainment expenses',
      ),
      Category(
        id: DateTime.now().millisecondsSinceEpoch + 6,
        name: 'Health',
        icon: 'local_hospital',
        color: 0xFF06D6A0,
        description: 'Health and medical expenses',
      ),
      Category(
        id: DateTime.now().millisecondsSinceEpoch + 7,
        name: 'Groceries',
        icon: 'local_grocery_store',
        color: 0xFFEF476F,
        description: 'Grocery shopping',
      ),
    ];

    state = state.copyWith(categories: categories);
    return categories;
  }

  Future<void> completeSetup() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('setup_completed', true);

    final bankAccountRepo = ref.read(bankAccountRepositoryProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final tagRepo = ref.read(tagRepositoryProvider);

    for (final account in state.bankAccounts) {
      await bankAccountRepo.insertAccount(account);
    }

    for (final category in state.categories) {
      await categoryRepo.insertCategory(category);
    }

    for (final tag in state.tags) {
      await tagRepo.insertTag(tag);
    }

    ref.invalidate(bankAccountsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(tagsProvider);

    state = state.copyWith(isCompleted: true);
  }
}

final setupProvider = StateNotifierProvider<SetupNotifier, SetupState>((ref) {
  return SetupNotifier(ref);
});
