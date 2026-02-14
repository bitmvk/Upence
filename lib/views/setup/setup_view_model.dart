import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upence/core/di/providers.dart';
import 'package:upence/core/utils/logger.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/repositories/bank_account_repository.dart';
import 'package:upence/repositories/categories_repository.dart';
import 'package:upence/repositories/tags_repository.dart';

enum SetupStep { welcome, permissions, accounts, categories, tags }

enum AppPermissionStatus { granted, denied, permanentlyDenied, checking }

class SetupState {
  final SetupStep currentStep;
  final bool isLoading;
  final String? errorMessage;
  final List<Category> categories;
  final List<BankAccount> accounts;
  final List<Tag> tags;
  final Map<String, AppPermissionStatus> permissionsGranted;
  final bool canProceed;

  SetupState({
    required this.currentStep,
    this.isLoading = false,
    this.errorMessage,
    this.categories = const [],
    this.accounts = const [],
    this.tags = const [],
    this.permissionsGranted = const {},
    this.canProceed = true,
  });

  SetupState copyWith({
    SetupStep? currentStep,
    bool? isLoading,
    String? errorMessage,
    List<Category>? categories,
    List<BankAccount>? accounts,
    List<Tag>? tags,
    Map<String, AppPermissionStatus>? permissionsGranted,
    bool? canProceed,
  }) {
    return SetupState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      categories: categories ?? this.categories,
      accounts: accounts ?? this.accounts,
      tags: tags ?? this.tags,
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      canProceed: canProceed ?? this.canProceed,
    );
  }
}

class SetupViewModel extends Notifier<SetupState> {
  late final CategoriesRepository _categoriesRepo;
  late final BankAccountRepository _accountsRepo;
  late final TagsRepository _tagsRepo;

  static const int totalSteps = 5;

  static List<Category> getDefaultCategories() {
    return [
      Category(
        id: -1,
        name: 'Food & Dining',
        icon: 'restaurant',
        color: 0xFFFF6B6B,
        description: 'Restaurants, cafes, groceries, and food delivery',
      ),
      Category(
        id: -2,
        name: 'Entertainment',
        icon: 'theater_comedy',
        color: 0xFF4ECDC4,
        description: 'Movies, games, concerts, and leisure activities',
      ),
      Category(
        id: -3,
        name: 'Travel',
        icon: 'flight',
        color: 0xFF45B7D1,
        description: 'Flights, hotels, transportation, and vacation expenses',
      ),
      Category(
        id: -4,
        name: 'Subscriptions',
        icon: 'subscriptions',
        color: 0xFF96CEB4,
        description: 'Streaming services, software, and recurring payments',
      ),
      Category(
        id: -5,
        name: 'Shopping',
        icon: 'shopping_cart',
        color: 0xFFDDA0DD,
        description: 'Online shopping, retail purchases, and gifts',
      ),
      Category(
        id: -6,
        name: 'Health & Wellness',
        icon: 'medical_services',
        color: 0xFF98D8C8,
        description: 'Medical expenses, pharmacy, fitness, and self-care',
      ),
      Category(
        id: -7,
        name: 'Utilities',
        icon: 'bolt',
        color: 0xFFF7DC6F,
        description: 'Electricity, water, internet, and household bills',
      ),
    ];
  }

  @override
  SetupState build() {
    _categoriesRepo = ref.read(categoriesRepositoryProvider);
    _accountsRepo = ref.read(bankAccountRepositoryProvider);
    _tagsRepo = ref.read(tagsRepositoryProvider);

    return SetupState(
      currentStep: SetupStep.welcome,
      categories: getDefaultCategories(),
      permissionsGranted: {
        'SMS': AppPermissionStatus.checking,
        'Notifications': AppPermissionStatus.checking,
      },
    );
  }

  void nextStep() {
    if (state.currentStep.index < totalSteps - 1) {
      state = state.copyWith(
        currentStep: SetupStep.values[state.currentStep.index + 1],
        errorMessage: null,
      );
    }
  }

  void previousStep() {
    if (state.currentStep.index > 0) {
      state = state.copyWith(
        currentStep: SetupStep.values[state.currentStep.index - 1],
        errorMessage: null,
      );
    }
  }

  void goToStep(SetupStep step) {
    state = state.copyWith(currentStep: step, errorMessage: null);
  }

  void addCategory(Category category) {
    state = state.copyWith(categories: [...state.categories, category]);
  }

  void updateCategory(Category category, int index) {
    final newCategories = [...state.categories];
    newCategories[index] = category;
    state = state.copyWith(categories: newCategories);
  }

  void removeCategory(int index) {
    state = state.copyWith(categories: [...state.categories]..removeAt(index));
  }

  void addAccount(BankAccount account) {
    state = state.copyWith(accounts: [...state.accounts, account]);
  }

  void updateAccount(BankAccount account, int index) {
    final newAccounts = [...state.accounts];
    newAccounts[index] = account;
    state = state.copyWith(accounts: newAccounts);
  }

  void removeAccount(int index) {
    state = state.copyWith(accounts: [...state.accounts]..removeAt(index));
  }

  void addTag(Tag tag) {
    state = state.copyWith(tags: [...state.tags, tag]);
  }

  void updateTag(Tag tag, int index) {
    final newTags = [...state.tags];
    newTags[index] = tag;
    state = state.copyWith(tags: newTags);
  }

  void removeTag(int index) {
    state = state.copyWith(tags: [...state.tags]..removeAt(index));
  }

  Future<void> checkPermissions() async {
    final smsStatus = await Permission.sms.status;
    final notificationStatus = await Permission.notification.status;

    state = state.copyWith(
      permissionsGranted: {
        'SMS': smsStatus.isGranted
            ? AppPermissionStatus.granted
            : (smsStatus.isDenied
                  ? AppPermissionStatus.denied
                  : AppPermissionStatus.permanentlyDenied),
        'Notifications': notificationStatus.isGranted
            ? AppPermissionStatus.granted
            : (notificationStatus.isDenied
                  ? AppPermissionStatus.denied
                  : AppPermissionStatus.permanentlyDenied),
      },
    );
  }

  Future<void> requestPermissions(String type) async {
    final currentPermissions = Map<String, AppPermissionStatus>.from(
      state.permissionsGranted,
    );

    if (type == "SMS") {
      final smsResult = await Permission.sms.request();
      currentPermissions['SMS'] = smsResult.isGranted
          ? AppPermissionStatus.granted
          : (smsResult.isDenied
                ? AppPermissionStatus.denied
                : AppPermissionStatus.permanentlyDenied);
    }
    if (type == "Notification") {
      final notificationResult = await Permission.notification.request();
      currentPermissions['Notifications'] = notificationResult.isGranted
          ? AppPermissionStatus.granted
          : (notificationResult.isDenied
                ? AppPermissionStatus.denied
                : AppPermissionStatus.permanentlyDenied);
    }
    state = state.copyWith(permissionsGranted: currentPermissions);
  }

  bool canProceedFromCurrentStep() {
    switch (state.currentStep) {
      case SetupStep.welcome:
        return true;
      case SetupStep.permissions:
        return state.permissionsGranted.values.every(
          (status) => status == AppPermissionStatus.granted,
        );
      case SetupStep.categories:
        return state.categories.isNotEmpty;
      case SetupStep.accounts:
        return state.accounts.isNotEmpty;
      case SetupStep.tags:
        return state.tags.isNotEmpty;
    }
  }

  Future<void> completeSetup() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _batchInsertCategories();
      await _batchInsertAccounts();
      await _batchInsertTags();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('setup_completed', true);

      state = state.copyWith(isLoading: false);

      ref.read(setupCompletedProvider.notifier).setCompleted();
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to complete setup',
        error: e,
        stackTrace: stackTrace,
        tag: 'SetupViewModel',
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to complete setup: ${e.toString()}',
      );
    }
  }

  Future<void> _batchInsertCategories() async {
    await Future.wait(
      state.categories.map(
        (category) => _categoriesRepo.createCategory(category),
      ),
    );
  }

  Future<void> _batchInsertAccounts() async {
    await Future.wait(
      state.accounts.map((account) => _accountsRepo.createBankAccount(account)),
    );
  }

  Future<void> _batchInsertTags() async {
    await Future.wait(state.tags.map((tag) => _tagsRepo.createTag(tag)));
  }
}

final setupViewModelProvider = NotifierProvider<SetupViewModel, SetupState>(() {
  return SetupViewModel();
});

class SetupCompletedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setCompleted() {
    state = true;
  }
}

final setupCompletedProvider = NotifierProvider<SetupCompletedNotifier, bool>(
  () {
    return SetupCompletedNotifier();
  },
);
