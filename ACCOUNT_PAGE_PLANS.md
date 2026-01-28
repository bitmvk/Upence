## Account Page Overhaul Plan

### Overview
Transform **AccountPage** into main account management page with full CRUD operations and per-account analytics. Remove **AccountManagementPage** and update Settings to navigate to AccountPage.

### Phase 1: Database & Repository Layer

#### 1.1 Add Account Analytics Methods to TransactionDao
**File**: `lib/data/database/dao/transaction_dao.dart`

Add these new methods:
- `getAccountBalance(int accountId)` - Sum of (credit - debit) for specific account
- `getAccountIncome(int accountId)` - Total income for specific account
- `getAccountExpense(int accountId)` - Total expense for specific account
- `getAccountTransactionCount(int accountId)` - Count of transactions for specific account
- `getAccountMonthlyAvgIncome(int accountId)` - Average monthly income
- `getAccountMonthlyAvgExpense(int accountId)` - Average monthly expense
- `getAccountLastTransactionDate(int accountId)` - Date of last transaction

**Implementation Details**:
- Use SQL queries with `WHERE accountId = ?`
- For monthly averages: Total income/expense divided by months since first transaction

#### 1.2 Add Account Analytics to TransactionRepository
**File**: `lib/data/repositories/transaction_repository.dart`

Add corresponding methods that call TransactionDao:
- `getAccountBalance(int accountId)`
- `getAccountIncome(int accountId)`
- `getAccountExpense(int accountId)`
- `getAccountTransactionCount(int accountId)`
- `getAccountMonthlyAvgIncome(int accountId)`
- `getAccountMonthlyAvgExpense(int accountId)`
- `getAccountLastTransactionDate(int accountId)`

### Phase 2: Provider Layer

#### 2.1 Create Account Analytics Provider
**File**: `lib/core/providers/app_providers.dart`

Add provider for account analytics:
```dart
final accountAnalyticsProvider = FutureProvider.family<AccountAnalytics, int>((ref, accountId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return await repo.getAccountAnalytics(accountId);
});
```

Create `AccountAnalytics` model class in `lib/data/models/account_analytics.dart`:
```dart
class AccountAnalytics {
  final double balance;
  final double totalIncome;
  final double totalExpense;
  final int transactionCount;
  final double avgMonthlyIncome;
  final double avgMonthlyExpense;
  final DateTime? lastTransactionDate;
}
```

### Phase 3: Account Page UI Overhaul

#### 3.1 Redesign Account Card
**File**: `lib/features/accounts/presentation/account_page.dart`

**New Account Card Structure**:
```
┌─────────────────────────────────────────┐
│ [Icon]  Account Name                 ⋮  │
│          Account: ••••1234               │
│ ─────────────────────────────────────     │
│ 💰 Balance: ₹15,234.56                │
│ 📊 42 Transactions                     │
│ 📈 ₹12,345.67 avg/mo (income)        │
│ 📉 ₹8,234.45 avg/mo (expense)        │
│ Last: 2 days ago                      │
└─────────────────────────────────────────┘
```

**Analytics Display**:
- Current Balance with color (green for positive, red for negative)
- Transaction Count
- Average Monthly Income
- Average Monthly Expense
- Last transaction date (formatted as "X days ago" or date)

#### 3.2 Add CRUD Operations

**Add Account Bottom Sheet**:
- Use similar pattern from `setup_page.dart` line 568-646
- Fields: Account Name (required), Account Number (optional), Description (optional)
- Save to database via `bankAccountRepositoryProvider`
- Invalidate `bankAccountsProvider` after save

**Edit Account Bottom Sheet**:
- Reuse same bottom sheet UI
- Pre-fill with existing account data
- Update via `bankAccountRepositoryProvider.updateAccount()`
- Invalidate `bankAccountsProvider` after update

**Delete Account**:
- Keep existing dialog (lines 146-177)
- Implement actual deletion via `bankAccountRepositoryProvider.deleteAccount(id)`
- Show success snackbar
- Invalidate `bankAccountsProvider` after deletion

#### 3.3 Update FAB and Empty State
- Empty state button: Opens add account bottom sheet
- FAB: Opens add account bottom sheet
- Remove "Navigate to" TODOs

### Phase 4: Settings Integration

#### 4.1 Update Settings Page
**File**: `lib/features/settings/presentation/settings_page.dart`

Change to navigate to AccountPage via named route `/accounts`

#### 4.2 Remove AccountManagementPage Import
- Remove import from settings_page.dart

### Phase 5: Cleanup

#### 5.1 Delete AccountManagementPage
**File**: `lib/features/settings/presentation/subpages/account_management_page.dart`
- Delete entire file

#### 5.2 Check for Other References
Search for `AccountManagementPage` references and remove all imports/usages

### Phase 6: Testing & Validation

#### 6.1 Run Code Analysis
```bash
flutter analyze
```

#### 6.2 Regenerate Database Code
```bash
dart run build_runner build
```

#### 6.3 Manual Testing Checklist
- [ ] Account list displays correctly with analytics
- [ ] Add account bottom sheet opens and saves
- [ ] Edit account bottom sheet opens with pre-filled data and updates
- [ ] Delete account dialog deletes account
- [ ] Analytics calculate correctly (balance, income, expense, averages)
- [ ] Settings > Bank Accounts navigates to AccountPage
- [ ] Empty state shows when no accounts exist
- [ ] FAB works correctly

---

## Account Page Design Decisions

### Navigation
- Settings > Bank Accounts → Navigate to AccountPage via **named route** `/accounts`
- Add route to `main.dart`

### Account Card Display
- **All analytics in card**:
  - Balance (green/red based on positive/negative)
  - Transaction Count
  - Average Monthly Income
  - Average Monthly Expense
  - Last Transaction Date

### Monthly Average Calculation
- Formula: `Total Income/Expense ÷ (Months Since First Transaction)`
- Example: First transaction 3 months ago = divide by 3
