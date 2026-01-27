# Implementation Plan: Navigation Fix, Setup Flow & Permission Handling

## Overview
Fix navigation sidebar animation, create mandatory 5-page setup flow with permission handling, and integrate with existing app infrastructure.

---

## Phase 1: Fix Navigation Sidebar Animation (Option 2)

### Problem
NavigationSidebar has custom animation controller but `open()`/`close()` methods are never called. Flutter's Drawer handles visibility but doesn't trigger custom animations.

### Solution
Integrate drawer state monitoring to trigger animations when drawer opens/closes.

### Files to Modify
- `lib/core/widgets/navigation_sidebar.dart`

### Implementation Steps

#### 1.1 Add Drawer State Callback
Modify `_NavigationSidebarState` to add drawer state tracking:
```dart
bool _isDrawerOpen = false;

@override
Widget build(BuildContext context) {
  // Monitor drawer state changes
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final isOpen = Scaffold.of(context).isDrawerOpen;
    if (isOpen != _isDrawerOpen) {
      _isDrawerOpen = isOpen;
      if (isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  });
  
  return SlideTransition(...);
}
```

#### 1.2 Alternative Approach (Preferred)
Use `DrawerController` and `DrawerControllerState` for proper integration:
```dart
class NavigationSidebar extends ConsumerWidget {
  final NavItem selectedItem;
  final Function(NavItem) onItemSelected;
  
  const NavigationSidebar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Build sidebar without custom animation
    // Let Flutter's Drawer widget handle animation
    return Container(
      width: 280,
      child: Column(...), // Keep all existing content
    );
  }
}
```

**Recommendation**: Remove custom animation entirely and use Flutter's built-in drawer animation. This is simpler, more reliable, and provides smooth animations.

---

## Phase 2: Create Onboarding Feature Structure

### Directory Structure
```
lib/features/onboarding/
├── presentation/
│   ├── setup_page.dart
│   ├── setup_provider.dart
│   └── widgets/
│       ├── permission_card.dart
│       ├── welcome_content.dart
│       ├── account_form.dart
│       ├── categories_list.dart
│       ├── add_category_dialog.dart
│       ├── tags_list.dart
│       └── add_tag_dialog.dart
```

### 2.1 Create Setup Provider
**File**: `lib/features/onboarding/presentation/setup_provider.dart`

**State Management**:
```dart
enum SetupPage {
  welcome,
  permissions,
  bankAccount,
  categories,
  tags,
}

class SetupState {
  final SetupPage currentPage;
  final bool smsPermissionGranted;
  final bool notificationPermissionGranted;
  final int smsPermissionRequestCount;
  final int notificationPermissionRequestCount;
  final List<BankAccount> bankAccounts;
  final List<Category> categories;
  final List<Tag> tags;
  
  // Getters
  bool get canProceedToNext => 
    currentPage == SetupPage.welcome ||
    (currentPage == SetupPage.permissions && smsPermissionGranted) ||
    (currentPage == SetupPage.bankAccount && bankAccounts.isNotEmpty) ||
    (currentPage == SetupPage.categories) ||
    (currentPage == SetupPage.tags);
  
  bool get isLastPage => currentPage == SetupPage.tags;
  bool get isFirstPage => currentPage == SetupPage.welcome;
}

class SetupNotifier extends StateNotifier<SetupState> {
  // Methods to update state
}
```

**Provider**:
```dart
final setupProvider = StateNotifierProvider<SetupNotifier, SetupState>((ref) {
  return SetupNotifier();
});
```

---

## Phase 3: Implement 5 Setup Pages

### 3.1 Welcome Page
**File**: `lib/features/onboarding/presentation/setup_page.dart`

**Content**:
- App logo/branding
- Welcome message: "Welcome to Upence! We'll walk you through the setup process."
- App description
- "Let's get started" indicator
- Illustration (optional)

### 3.2 Permissions Page
**File**: `lib/features/onboarding/presentation/setup_page.dart` (second page)

**Content**:
- Title: "Permissions Required"
- SMS Permission Card:
  - Icon: `Icons.sms`
  - Title: "SMS Permission"
  - Description: "Required to find transactions from your bank SMS messages"
  - Status indicator (granted/denied)
  - Request/Settings button
- Notification Permission Card:
  - Icon: `Icons.notifications`
  - Title: "Notification Permission"
  - Description: "Required to remind you about new transactions that need to be classified"
  - Status indicator (granted/denied)
  - Request/Continue Anyway button

**Permission Handling Logic**:
```dart
// State-based UI
if (smsPermissionGranted && notificationPermissionGranted) {
  // Show both granted status
  // Next button enabled
} else if (!smsPermissionGranted) {
  // Show: "App cannot operate without SMS permission"
  // Button: "Grant Permission" (opens dialog)
  // Next button disabled
} else if (smsPermissionGranted && !notificationPermissionGranted) {
  // Show: "Notifications help you classify transactions"
  // Buttons: "Continue Anyway" AND "Grant Permission"
  // Next button enabled (since SMS is granted)
}
```

### 3.3 Bank Account Page
**File**: `lib/features/onboarding/presentation/setup_page.dart` (third page)

**Content**:
- Title: "Add Bank Account"
- Form:
  - Account Name (required) - TextField
  - Account Number (optional) - TextField
  - Description (optional) - TextField
- "Add Another" button
- List of added accounts
- Next button disabled until at least 1 account

**Validation**:
- Account name cannot be empty
- Account number must be numeric if provided
- Show error messages for invalid input

### 3.4 Categories Page
**File**: `lib/features/onboarding/presentation/setup_page.dart` (fourth page)

**Content**:
- Title: "Categories"
- Prefilled Categories (displayed as cards):
  1. food - icon: `restaurant` - color: AppColors.expense
  2. transport - icon: `directions_car` - color: AppColors.warning
  3. shopping - icon: `shopping_cart` - color: AppColors.primary
  4. bills - icon: `receipt` - color: AppColors.expense
  5. entertainment - icon: `movie` - color: AppColors.primary
  6. health - icon: `local_hospital` - color: AppColors.income
  7. groceries - icon: `grocery` - color: AppColors.expense
- "Add Category" button → Shows dialog with:
  - Name (required)
  - Icon picker (Material Icons, NOT emoji)
  - Color picker (predefined colors)
  - Description (optional)
- List of all categories (prefilled + added)

**Icon Picker Implementation**:
- Show grid of common Material Icons for categories
- Store icon name as String (e.g., "restaurant", "shopping_cart")
- Convert to IconData when displaying: `Icons.valueOf(iconName)`

### 3.5 Tags Page
**File**: `lib/features/onboarding/presentation/setup_page.dart` (fifth page)

**Content**:
- Title: "Tags"
- No prefilled tags
- "Add Tag" button → Shows dialog with:
  - Name (required)
  - Color picker (predefined colors)
- List of added tags
- Next button always enabled (tags are optional)

### 3.6 Navigation Buttons
All pages have navigation at bottom:

```dart
Padding(
  padding: EdgeInsets.all(16),
  child: Row(
    children: [
      if (!isFirstPage)
        TextButton(
          onPressed: () => onBack(),
          child: Text('Back'),
        ),
      Spacer(),
      ElevatedButton(
        onPressed: canProceedToNext ? onNext : null,
        child: Text(isLastPage ? 'Complete Setup' : 'Next'),
      ),
    ],
  ),
)
```

---

## Phase 4: Permission Handling Implementation

### 4.1 Permission Request Logic
**File**: `lib/services/permission_service.dart` (enhance)

Add methods:
```dart
class PermissionService {
  // Track request counts (in memory)
  Map<Permission, int> _requestCounts = {};
  
  Future<bool> requestPermissionWithCount(Permission permission) async {
    _requestCounts[permission] = (_requestCounts[permission] ?? 0) + 1;
    final status = await permission.request();
    _permissionStatuses[permission] = status;
    return status.isGranted;
  }
  
  int getRequestCount(Permission permission) {
    return _requestCounts[permission] ?? 0;
  }
  
  Future<bool> canRequestAgain(Permission permission) async {
    // Android handles this automatically
    // Once permanently denied, system won't show popup
    return !(await isPermanentlyDenied(permission));
  }
}
```

### 4.2 Permission UI Logic
**File**: `lib/features/onboarding/presentation/widgets/permission_card.dart`

```dart
Widget _buildPermissionCard({
  required String title,
  required String description,
  required bool granted,
  required bool required,
  required VoidCallback onRequest,
  required VoidCallback onContinueAnyway,
}) {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(granted ? Icons.check_circle : Icons.cancel, 
                   color: granted ? Colors.green : Colors.red),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(description, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if (!granted && required) ...[
            SizedBox(height: 12),
            Text("App cannot operate without this permission",
                 style: TextStyle(color: Colors.red)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRequest,
              child: Text("Grant Permission"),
            ),
          ] else if (!granted && !required) ...[
            SizedBox(height: 12),
            Text("This helps you classify transactions",
                 style: TextStyle(fontSize: 12)),
            SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: onRequest,
                  child: Text("Grant Permission"),
                ),
                SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onContinueAnyway,
                  child: Text("Continue Anyway"),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}
```

---

## Phase 5: Update Main App Flow

### 5.1 Update main.dart
**File**: `lib/main.dart`

**Changes**:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.getDatabase();
  
  // Initialize SMS method channel (keep existing)
  const smsChannel = MethodChannel('com.example.upence/sms');
  smsChannel.setMethodCallHandler((call) async {
    if (call.method == 'onSMSReceived') {
      final sender = call.arguments['sender'] as String?;
      final message = call.arguments['message'] as String?;
      final timestamp = call.arguments['timestamp'] as int?;
      
      if (sender != null && message != null && timestamp != null) {
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

// Move existing app logic to MainApp
class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});
  
  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  // Existing code from MyApp moves here
  // (scaffold key, selectedNavItem, etc.)
}
```

### 5.2 Update Setup Completion Logic
**File**: `lib/features/onboarding/presentation/setup_provider.dart`

```dart
Future<void> completeSetup() async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  await prefs.setBool('setup_completed', true);
  
  // Save data to database
  final bankAccountRepo = ref.read(bankAccountRepositoryProvider);
  final categoryRepo = ref.read(categoryRepositoryProvider);
  final tagRepo = ref.read(tagRepositoryProvider);
  
  // Insert bank accounts
  for (final account in state.bankAccounts) {
    await bankAccountRepo.insertAccount(account);
  }
  
  // Insert categories
  for (final category in state.categories) {
    await categoryRepo.insertCategory(category);
  }
  
  // Insert tags
  for (final tag in state.tags) {
    await tagRepo.insertTag(tag);
  }
  
  // Invalidate providers to refresh data
  ref.invalidate(bankAccountsProvider);
  ref.invalidate(categoriesProvider);
  ref.invalidate(tagsProvider);
}
```

---

## Phase 6: Database & Repository Integration

### 6.1 Prefilled Categories Data
**File**: `lib/features/onboarding/presentation/setup_provider.dart`

```dart
List<Category> getPrefilledCategories() {
  return [
    Category(
      id: 0,
      name: 'Food',
      icon: 'restaurant',
      color: AppColors.expense.value,
      description: 'Food and dining expenses',
    ),
    Category(
      id: 0,
      name: 'Transport',
      icon: 'directions_car',
      color: AppColors.warning.value,
      description: 'Transportation expenses',
    ),
    Category(
      id: 0,
      name: 'Shopping',
      icon: 'shopping_cart',
      color: AppColors.primary.value,
      description: 'Shopping expenses',
    ),
    Category(
      id: 0,
      name: 'Bills',
      icon: 'receipt',
      color: AppColors.expense.value,
      description: 'Bills and utilities',
    ),
    Category(
      id: 0,
      name: 'Entertainment',
      icon: 'movie',
      color: AppColors.primary.value,
      description: 'Entertainment expenses',
    ),
    Category(
      id: 0,
      name: 'Health',
      icon: 'local_hospital',
      color: AppColors.income.value,
      description: 'Health and medical expenses',
    ),
    Category(
      id: 0,
      name: 'Groceries',
      icon: 'grocery',
      color: AppColors.expense.value,
      description: 'Grocery shopping',
    ),
  ];
}
```

### 6.2 Icon to IconData Conversion
**File**: `lib/core/utils/icon_utils.dart` (new file)

```dart
import 'package:flutter/material.dart';

class IconUtils {
  static IconData getIcon(String iconName) {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_cart': Icons.shopping_cart,
      'receipt': Icons.receipt,
      'movie': Icons.movie,
      'local_hospital': Icons.local_hospital,
      'grocery': Icons.local_grocery_store,
      'home': Icons.home,
      'work': Icons.work,
      'school': Icons.school,
      'fitness': Icons.fitness_center,
      'travel': Icons.flight,
      'gift': Icons.card_giftcard,
      'money': Icons.money,
      'phone': Icons.phone,
      'internet': Icons.wifi,
      'electricity': Icons.power,
      'water': Icons.water_drop,
      'gas': Icons.local_gas_station,
    };
    
    return iconMap[iconName] ?? Icons.category;
  }
}
```

### 6.3 Icon Picker Widget
**File**: `lib/features/onboarding/presentation/widgets/icon_picker.dart` (new file)

```dart
class IconPicker extends StatelessWidget {
  final String selectedIcon;
  final Function(String) onIconSelected;
  
  const IconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });
  
  final List<String> categoryIcons = const [
    'restaurant',
    'directions_car',
    'shopping_cart',
    'receipt',
    'movie',
    'local_hospital',
    'local_grocery_store',
    'home',
    'work',
    'school',
    'fitness_center',
    'flight',
    'card_giftcard',
    'money',
    'phone',
    'wifi',
    'power',
    'water_drop',
    'local_gas_station',
  ];
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
      ),
      itemCount: categoryIcons.length,
      itemBuilder: (context, index) {
        final icon = categoryIcons[index];
        final isSelected = icon == selectedIcon;
        return GestureDetector(
          onTap: () => onIconSelected(icon),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(IconUtils.getIcon(icon)),
          ),
        );
      },
    );
  }
}
```

---

## Files to Create

### New Files
1. `lib/features/onboarding/presentation/setup_page.dart`
2. `lib/features/onboarding/presentation/setup_provider.dart`
3. `lib/features/onboarding/presentation/widgets/permission_card.dart`
4. `lib/features/onboarding/presentation/widgets/welcome_content.dart`
5. `lib/features/onboarding/presentation/widgets/account_form.dart`
6. `lib/features/onboarding/presentation/widgets/categories_list.dart`
7. `lib/features/onboarding/presentation/widgets/add_category_dialog.dart`
8. `lib/features/onboarding/presentation/widgets/tags_list.dart`
9. `lib/features/onboarding/presentation/widgets/add_tag_dialog.dart`
10. `lib/features/onboarding/presentation/widgets/icon_picker.dart`
11. `lib/core/utils/icon_utils.dart`

### Modified Files
1. `lib/main.dart` - Split into MyApp and MainApp, add setup flow routing
2. `lib/core/widgets/navigation_sidebar.dart` - Remove custom animation
3. `lib/services/permission_service.dart` - Add request count tracking

---

## Implementation Order

### Sprint 1: Fix Navigation (30-60 min)
1. Remove custom animation from NavigationSidebar
2. Test navigation functionality
3. Verify all nav items work

### Sprint 2: Create Onboarding Structure (1-2 hours)
1. Create directory structure
2. Create SetupProvider with state management
3. Create SetupPage widget skeleton
4. Create page navigation logic

### Sprint 3: Welcome & Permissions Pages (2-3 hours)
1. Implement Welcome page content
2. Implement Permissions page UI
3. Implement permission request logic
4. Implement permission status tracking
5. Add permission card widgets
6. Test permission requests

### Sprint 4: Bank Account Page (1-2 hours)
1. Implement bank account form
2. Add validation logic
3. Implement "Add Another" functionality
4. List added accounts
5. Test account creation

### Sprint 5: Categories Page (2-3 hours)
1. Implement icon picker widget
2. Create IconUtils for icon conversion
3. Display prefilled categories
4. Implement add category dialog
5. Test category creation
6. Update Category model to use Material Icons

### Sprint 6: Tags Page (1-2 hours)
1. Implement tag list
2. Implement add tag dialog
3. Test tag creation

### Sprint 7: Integration & Database (2-3 hours)
1. Integrate setup flow into main.dart
2. Implement setup completion logic
3. Save data to database
4. Persist setup status
5. Test end-to-end flow

### Sprint 8: Testing & Polish (1-2 hours)
1. Test all permission scenarios
2. Test on real device
3. Fix bugs
4. Add animations/transitions
5. Polish UI

---

## Testing Checklist

### Navigation
- [ ] Sidebar opens when menu button tapped
- [ ] Sidebar content is visible
- [ ] Navigation items are clickable
- [ ] Sidebar closes when item selected
- [ ] Smooth animation

### Setup Flow
- [ ] Setup page shows on first launch
- [ ] All 5 pages navigate correctly
- [ ] Back/Next buttons work properly
- [ ] Next button disabled when appropriate
- [ ] Setup completion persists

### Permissions
- [ ] Both permissions requested at once
- [ ] SMS permission can be requested multiple times
- [ ] Notification permission can be requested multiple times
- [ ] Next button disabled until SMS granted
- [ ] "Continue Anyway" works for notification
- [ ] Settings navigation works for permanently denied

### Bank Accounts
- [ ] Account name validation works
- [ ] Account number is optional
- [ ] Description is optional
- [ ] Multiple accounts can be added
- [ ] Accounts saved to database

### Categories
- [ ] Prefilled categories display correctly
- [ ] Icon picker shows Material Icons
- [ ] Color picker works
- [ ] New categories can be added
- [ ] Categories saved to database

### Tags
- [ ] No prefilled tags
- [ ] New tags can be added
- [ ] Tags saved to database
- [ ] Tags page can be skipped

### Integration
- [ ] App flows from setup to main
- [ ] Data persists after setup
- [ ] Setup doesn't show again
- [ ] Main app features work

---

## Risk Assessment

### Low Risk
- Removing custom animation from sidebar
- Creating onboarding UI
- Adding permission request buttons

### Medium Risk
- Changing main app navigation flow
- Database data insertion during setup
- Permission state tracking

### High Risk
- Permission request count tracking (Android OS limitations)
- Icon to IconData conversion edge cases

---

## Known Limitations & Notes

### Permission Request Counting
- Android OS controls permission request popups
- Once user selects "Don't ask again", system won't show popup
- We can't force more requests after user denies permanently
- Solution: Always show "Open Settings" button when `isPermanentlyDenied`

### Icon System
- Category model stores icon as String (icon name)
- Need to convert to IconData when displaying
- Use `IconUtils.getIcon()` helper method
- Invalid icon names fallback to `Icons.category`

### Theme Support
- Setup pages should support both light and dark themes
- Use theme colors instead of hardcoded colors
- Follow Material 3 design guidelines

---

## Success Criteria

1. ✅ Navigation sidebar works correctly
2. ✅ Setup flow appears on first launch
3. ✅ All 5 setup pages navigate correctly
4. ✅ Permissions requested with proper handling
5. ✅ Bank accounts can be created
6. ✅ Categories can be created with icons
7. ✅ Tags can be created
8. ✅ Setup completion persists
9. ✅ Data saved to database
10. ✅ Main app works after setup

---

*Last Updated: January 27, 2026*
