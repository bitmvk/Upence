import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:upence/core/providers/app_providers.dart';
import 'package:upence/data/models/category.dart' as models;
import 'package:upence/data/models/tag.dart';
import 'package:upence/data/models/bank_account.dart';
import 'package:upence/services/permission_service.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

enum SetupStep { welcome, permissions, bankAccount, categories, tags }

class SetupState {
  final SetupStep currentPage;
  final bool smsPermissionGranted;
  final bool notificationPermissionGranted;
  final bool smsPermissionDeniedOnce;
  final bool notificationPermissionDeniedOnce;
  final bool smsPermissionPermanentlyDenied;
  final bool notificationPermissionPermanentlyDenied;
  final List<BankAccount> bankAccounts;
  final List<models.Category> categories;
  final List<Tag> tags;
  final bool isCompleted;
  final bool isLoading;
  final String? errorMessage;

  SetupState({
    this.currentPage = SetupStep.welcome,
    this.smsPermissionGranted = false,
    this.notificationPermissionGranted = false,
    this.smsPermissionDeniedOnce = false,
    this.notificationPermissionDeniedOnce = false,
    this.smsPermissionPermanentlyDenied = false,
    this.notificationPermissionPermanentlyDenied = false,
    this.bankAccounts = const [],
    this.categories = const [],
    this.tags = const [],
    this.isCompleted = false,
    this.isLoading = false,
    this.errorMessage,
  });

  SetupState copyWith({
    SetupStep? currentPage,
    bool? smsPermissionGranted,
    bool? notificationPermissionGranted,
    bool? smsPermissionDeniedOnce,
    bool? notificationPermissionDeniedOnce,
    bool? smsPermissionPermanentlyDenied,
    bool? notificationPermissionPermanentlyDenied,
    List<BankAccount>? bankAccounts,
    List<models.Category>? categories,
    List<Tag>? tags,
    bool? isCompleted,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SetupState(
      currentPage: currentPage ?? this.currentPage,
      smsPermissionGranted: smsPermissionGranted ?? this.smsPermissionGranted,
      notificationPermissionGranted:
          notificationPermissionGranted ?? this.notificationPermissionGranted,
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
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
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
      case SetupStep.tags:
        return true;
      case SetupStep.categories:
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
    debugPrint('[Setup] Initializing setup...');
    await _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    debugPrint('[Setup] Checking permissions...');
    final smsGranted = await _permissionService.checkPermission(Permission.sms);
    final notificationGranted = await _permissionService.checkPermission(
      Permission.notification,
    );

    final smsPermanentlyDenied = await _permissionService.isPermanentlyDenied(
      Permission.sms,
    );
    final notificationPermanentlyDenied = await _permissionService
        .isPermanentlyDenied(Permission.notification);

    debugPrint('[Setup] SMS: $smsGranted, Notification: $notificationGranted');

    state = state.copyWith(
      smsPermissionGranted: smsGranted,
      notificationPermissionGranted: notificationGranted,
      smsPermissionPermanentlyDenied: smsPermanentlyDenied,
      notificationPermissionPermanentlyDenied: notificationPermanentlyDenied,
    );
  }

  Future<void> refreshPermissions() async {
    debugPrint('[Setup] Refreshing permissions...');
    await _checkPermissions();
  }

  Future<void> nextPage() async {
    if (!state.canProceedToNext) {
      debugPrint('[Setup] Cannot proceed to next page');
      return;
    }

    if (state.isLastPage) {
      debugPrint('[Setup] Completing setup...');
      state = state.copyWith(isLoading: true, errorMessage: null);
      final success = await completeSetup();
      if (success) {
        debugPrint('[Setup] Setup completed successfully');
        state = state.copyWith(isLoading: false, isCompleted: true);
      } else {
        debugPrint('[Setup] Setup failed');
        state = state.copyWith(isLoading: false);
      }
      return;
    }

    final currentPageIndex = SetupStep.values.indexOf(state.currentPage);
    final nextPage = SetupStep.values[currentPageIndex + 1];
    debugPrint('[Setup] Moving from ${state.currentPage} to $nextPage');
    state = state.copyWith(currentPage: nextPage);
  }

  void previousPage() {
    if (state.isFirstPage) {
      debugPrint('[Setup] Already on first page');
      return;
    }

    final currentPageIndex = SetupStep.values.indexOf(state.currentPage);
    final previousPage = SetupStep.values[currentPageIndex - 1];
    debugPrint('[Setup] Moving from ${state.currentPage} to $previousPage');
    state = state.copyWith(currentPage: previousPage);
  }

  Future<void> requestSMSPermission() async {
    debugPrint('[Setup] Requesting SMS permission...');
    final granted = await _permissionService.requestPermission(Permission.sms);

    if (!granted) {
      debugPrint('[Setup] SMS permission denied');
      state = state.copyWith(smsPermissionDeniedOnce: true);
    }

    final canRequest = await canRequestPermission(Permission.sms);
    state = state.copyWith(smsPermissionPermanentlyDenied: !canRequest);

    await _checkPermissions();
  }

  Future<void> requestNotificationPermission() async {
    debugPrint('[Setup] Requesting notification permission...');
    final granted = await _permissionService.requestPermission(
      Permission.notification,
    );

    if (!granted) {
      debugPrint('[Setup] Notification permission denied');
      state = state.copyWith(notificationPermissionDeniedOnce: true);
    }

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
    debugPrint('[Setup] Opening app settings...');
    await ph.openAppSettings();
  }

  void addBankAccount(BankAccount account) {
    debugPrint('[Setup] Adding bank account: ${account.accountName}');
    final updated = List<BankAccount>.from(state.bankAccounts);
    updated.add(account);
    state = state.copyWith(bankAccounts: updated);
  }

  void removeBankAccount(int index) {
    debugPrint('[Setup] Removing bank account at index $index');
    final updated = List<BankAccount>.from(state.bankAccounts);
    updated.removeAt(index);
    state = state.copyWith(bankAccounts: updated);
  }

  void addCategory(models.Category category) {
    debugPrint('[Setup] Adding category: ${category.name}');
    final updated = List<models.Category>.from(state.categories);
    updated.add(category);
    state = state.copyWith(categories: updated);
  }

  void removeCategory(int index) {
    debugPrint('[Setup] Removing category at index $index');
    final updated = List<models.Category>.from(state.categories);
    updated.removeAt(index);
    state = state.copyWith(categories: updated);
  }

  void addTag(Tag tag) {
    debugPrint('[Setup] Adding tag: ${tag.name}');
    final updated = List<Tag>.from(state.tags);
    updated.add(tag);
    state = state.copyWith(tags: updated);
  }

  void removeTag(int index) {
    debugPrint('[Setup] Removing tag at index $index');
    final updated = List<Tag>.from(state.tags);
    updated.removeAt(index);
    state = state.copyWith(tags: updated);
  }

  List<models.Category> getPrefilledCategories() {
    debugPrint('[Setup] Loading prefilled categories...');
    final categories = [
      models.Category(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        name: 'Food',
        icon: 'restaurant',
        color: 0xFFEF476F,
        description: 'Food and dining expenses',
      ),
      models.Category(
        id: DateTime.now().millisecondsSinceEpoch + 2,
        name: 'Transport',
        icon: 'directions_car',
        color: 0xFFFFD166,
        description: 'Transportation expenses',
      ),
      models.Category(
        id: DateTime.now().millisecondsSinceEpoch + 3,
        name: 'Shopping',
        icon: 'shopping_bag',
        color: 0xFF4361EE,
        description: 'Shopping expenses',
      ),
      models.Category(
        id: DateTime.now().millisecondsSinceEpoch + 4,
        name: 'Bills',
        icon: 'receipt',
        color: 0xFFEF476F,
        description: 'Bills and utilities',
      ),
      models.Category(
        id: DateTime.now().millisecondsSinceEpoch + 5,
        name: 'Entertainment',
        icon: 'movie',
        color: 0xFF4361EE,
        description: 'Entertainment expenses',
      ),
      models.Category(
        id: DateTime.now().millisecondsSinceEpoch + 6,
        name: 'Health',
        icon: 'local_hospital',
        color: 0xFF06D6A0,
        description: 'Health and medical expenses',
      ),
      models.Category(
        id: DateTime.now().millisecondsSinceEpoch + 7,
        name: 'Groceries',
        icon: 'local_grocery_store',
        color: 0xFFEF476F,
        description: 'Grocery shopping',
      ),
    ];

    state = state.copyWith(categories: categories);
    debugPrint('[Setup] Loaded ${categories.length} prefilled categories');
    return categories;
  }

  Future<bool> completeSetup() async {
    debugPrint('[Setup] Completing setup...');
    debugPrint('[Setup] Saving ${state.bankAccounts.length} bank accounts');
    debugPrint('[Setup] Saving ${state.categories.length} categories');
    debugPrint('[Setup] Saving ${state.tags.length} tags');

    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setBool('setup_completed', true);

      final bankAccountRepo = ref.read(bankAccountRepositoryProvider);
      final categoryRepo = ref.read(categoryRepositoryProvider);
      final tagRepo = ref.read(tagRepositoryProvider);

      for (final account in state.bankAccounts) {
        try {
          await bankAccountRepo.insertAccount(account);
          debugPrint('[Setup] Saved bank account: ${account.accountName}');
        } catch (e) {
          debugPrint(
            '[Setup] Failed to save bank account ${account.accountName}: $e',
          );
          state = state.copyWith(
            errorMessage: 'Failed to save bank account: ${account.accountName}',
          );
          return false;
        }
      }

      for (final category in state.categories) {
        try {
          await categoryRepo.insertCategory(category);
          debugPrint('[Setup] Saved category: ${category.name}');
        } catch (e) {
          debugPrint('[Setup] Failed to save category ${category.name}: $e');
          state = state.copyWith(
            errorMessage: 'Failed to save category: ${category.name}',
          );
          return false;
        }
      }

      for (final tag in state.tags) {
        try {
          await tagRepo.insertTag(tag);
          debugPrint('[Setup] Saved tag: ${tag.name}');
        } catch (e) {
          debugPrint('[Setup] Failed to save tag ${tag.name}: $e');
          state = state.copyWith(
            errorMessage: 'Failed to save tag: ${tag.name}',
          );
          return false;
        }
      }

      ref.invalidate(bankAccountsProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(tagsProvider);
      ref.invalidate(setupCompletedProvider);

      debugPrint('[Setup] Setup completed successfully');
      return true;
    } catch (e) {
      debugPrint('[Setup] Setup failed with error: $e');
      state = state.copyWith(errorMessage: 'Setup failed: $e');
      return false;
    }
  }
}

final setupProvider = StateNotifierProvider<SetupNotifier, SetupState>((ref) {
  return SetupNotifier(ref);
});
