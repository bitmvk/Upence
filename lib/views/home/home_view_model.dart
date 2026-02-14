import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upence/core/di/providers.dart';
import 'package:upence/data/local/database/database.dart';
import 'package:upence/domain/models/composite_transaction.dart';
import 'package:upence/repositories/sms_repository.dart';
import 'package:upence/repositories/transactions_repository.dart';
import 'package:upence/repositories/categories_repository.dart';
import 'package:upence/repositories/bank_account_repository.dart';
import 'package:upence/repositories/tags_repository.dart';

class HomeState {
  final DateTime selectedMonth;
  final int totalIncome;
  final int totalExpense;
  final List<CompositeTransaction> recentTransactions;
  final List<Sms> unprocessedSms;
  final List<Category> categories;
  final List<BankAccount> accounts;
  final List<Tag> tags;
  final bool isLoading;
  final bool isLoadingSms;
  final bool isLoaded;
  final String? errorMessage;

  int get netSpend => totalIncome - totalExpense;

  int get unprocessedCount => unprocessedSms.length;

  HomeState({
    required this.selectedMonth,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.recentTransactions = const [],
    this.unprocessedSms = const [],
    this.categories = const [],
    this.accounts = const [],
    this.tags = const [],
    this.isLoading = false,
    this.isLoadingSms = false,
    this.isLoaded = false,
    this.errorMessage,
  });

  HomeState copyWith({
    DateTime? selectedMonth,
    int? totalIncome,
    int? totalExpense,
    List<CompositeTransaction>? recentTransactions,
    List<Sms>? unprocessedSms,
    List<Category>? categories,
    List<BankAccount>? accounts,
    List<Tag>? tags,
    bool? isLoading,
    bool? isLoadingSms,
    bool? isLoaded,
    String? errorMessage,
  }) {
    return HomeState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      unprocessedSms: unprocessedSms ?? this.unprocessedSms,
      categories: categories ?? this.categories,
      accounts: accounts ?? this.accounts,
      tags: tags ?? this.tags,
      isLoading: isLoading ?? this.isLoading,
      isLoadingSms: isLoadingSms ?? this.isLoadingSms,
      isLoaded: isLoaded ?? this.isLoaded,
      errorMessage: errorMessage,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  late final TransactionsRepository _transactionsRepo;
  late final SmsRepository _smsRepo;
  late final CategoriesRepository _categoriesRepo;
  late final BankAccountRepository _accountsRepo;
  late final TagsRepository _tagsRepo;

  @override
  HomeState build() {
    _transactionsRepo = ref.read(transactionsRepositoryProvider);
    _smsRepo = ref.read(smsRepositoryProvider);
    _categoriesRepo = ref.read(categoriesRepositoryProvider);
    _accountsRepo = ref.read(bankAccountRepositoryProvider);
    _tagsRepo = ref.read(tagsRepositoryProvider);

    final now = DateTime.now();
    final initialMonth = DateTime(now.year, now.month);

    Future.microtask(() => loadInitialData());

    return HomeState(selectedMonth: initialMonth);
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      loadDashboardData(),
      loadUnprocessedSms(),
      loadReferenceData(),
    ]);
  }

  Future<void> loadReferenceData() async {
    try {
      log('HomeViewModel: Loading reference data...');
      final categories = await _categoriesRepo.getAllCategories();
      log('HomeViewModel: Loaded ${categories.length} categories');
      final accounts = await _accountsRepo.getAllBankAccounts();
      log('HomeViewModel: Loaded ${accounts.length} accounts');
      final tags = await _tagsRepo.getAllTags();
      log('HomeViewModel: Loaded ${tags.length} tags');

      state = state.copyWith(
        categories: categories,
        accounts: accounts,
        tags: tags,
        isLoaded: true,
      );
      log(
        'HomeViewModel: State updated, accounts in state: ${state.accounts.length}',
      );
    } catch (e, stackTrace) {
      log('HomeViewModel: Failed to load data: $e');
      log('Stack trace: $stackTrace');
      state = state.copyWith(
        errorMessage: 'Failed to load data: $e',
        isLoaded: true,
      );
    }
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final monthStart = DateTime(
        state.selectedMonth.year,
        state.selectedMonth.month,
        1,
      );
      final monthEnd = DateTime(
        state.selectedMonth.year,
        state.selectedMonth.month + 1,
        0,
        23,
        59,
        59,
      );

      final allTransactions = await _transactionsRepo.getTransactions(
        null,
        null,
        null,
        null,
        DateTimeRange(start: monthStart, end: monthEnd),
        null,
        null,
        null,
        null,
        null,
      );

      int income = 0;
      int expense = 0;

      for (final tx in allTransactions) {
        if (tx.type == 'credit') {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
      }

      final recentTxIds = allTransactions.take(10).map((tx) => tx.id).toList();

      final compositeTransactions = await _transactionsRepo
          .getCompositeTransactions(recentTxIds);

      state = state.copyWith(
        totalIncome: income,
        totalExpense: expense,
        recentTransactions: compositeTransactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load dashboard: $e',
      );
    }
  }

  Future<void> loadUnprocessedSms() async {
    state = state.copyWith(isLoadingSms: true);

    try {
      final smsList = await _smsRepo.getUnprocessedSms();
      state = state.copyWith(unprocessedSms: smsList, isLoadingSms: false);
    } catch (e) {
      state = state.copyWith(isLoadingSms: false);
    }
  }

  Future<void> changeMonth(DateTime newMonth) async {
    state = state.copyWith(selectedMonth: newMonth);
    await loadDashboardData();
  }

  Future<void> previousMonth() async {
    final newMonth = DateTime(
      state.selectedMonth.year,
      state.selectedMonth.month - 1,
    );
    await changeMonth(newMonth);
  }

  Future<void> nextMonth() async {
    final newMonth = DateTime(
      state.selectedMonth.year,
      state.selectedMonth.month + 1,
    );
    await changeMonth(newMonth);
  }

  Future<void> addTransaction(
    Transaction transaction, {
    List<int> tagIds = const [],
  }) async {
    try {
      await _transactionsRepo.createTransaction(transaction, tagIds: tagIds);
      await loadDashboardData();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to add transaction: $e');
    }
  }

  Future<void> createTransactionFromSms(
    Sms sms,
    Transaction transaction, {
    List<int> tagIds = const [],
  }) async {
    try {
      await _transactionsRepo.createTransaction(transaction, tagIds: tagIds);
      await _smsRepo.markAsProcessed(sms.id);
      await Future.wait([loadDashboardData(), loadUnprocessedSms()]);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to create transaction: $e');
    }
  }

  Future<void> markSmsAsIgnored(int smsId) async {
    try {
      await _smsRepo.markAsIgnored(smsId);
      await loadUnprocessedSms();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to mark SMS as ignored: $e');
    }
  }

  Future<void> deleteSms(int smsId) async {
    try {
      await _smsRepo.softDeleteSms(smsId);
      await loadUnprocessedSms();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete SMS: $e');
    }
  }

  Future<void> refresh() async {
    await loadInitialData();
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(() {
  return HomeViewModel();
});
