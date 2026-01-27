import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../data/models/category.dart';
import '../../../data/models/tag.dart';
import '../../../data/models/bank_account.dart';
import 'setup_provider.dart';
import 'widgets/icon_picker.dart';

class SetupPage extends ConsumerWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(setupProvider);
    final setupNotifier = ref.read(setupProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildPage(context, setupState, setupNotifier)),
            _buildNavigationButtons(context, setupState, setupNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    SetupState state,
    SetupNotifier notifier,
  ) {
    switch (state.currentPage) {
      case SetupStep.welcome:
        return _buildWelcomePage(context);
      case SetupStep.permissions:
        return _buildPermissionsPage(context, state, notifier);
      case SetupStep.bankAccount:
        return _buildBankAccountPage(context, state, notifier);
      case SetupStep.categories:
        return _buildCategoriesPage(context, state, notifier);
      case SetupStep.tags:
        return _buildTagsPage(context, state, notifier);
    }
  }

  Widget _buildWelcomePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            size: 120,
            color: AppColors.primary,
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to Upence!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'We\'ll walk you through the setup process to get you started with tracking your SMS transactions.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsPage(
    BuildContext context,
    SetupState state,
    SetupNotifier notifier,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.refreshPermissions();
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Permissions Required',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'We need these permissions to provide the best experience.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildPermissionCard(
            context: context,
            icon: Icons.sms,
            title: 'SMS Permission',
            description:
                'Required to find transactions from your bank SMS messages',
            granted: state.smsPermissionGranted,
            required: true,
            hasBeenDeniedOnce: state.smsPermissionDeniedOnce,
            isPermanentlyDenied: state.smsPermissionPermanentlyDenied,
            onRequest: () => notifier.requestSMSPermission(),
            openSettings: () => notifier.openAppSettings(),
          ),
          const SizedBox(height: 16),
          _buildPermissionCard(
            context: context,
            icon: Icons.notifications,
            title: 'Notification Permission',
            description:
                'Required to remind you about new transactions that need to be classified',
            granted: state.notificationPermissionGranted,
            required: false,
            hasBeenDeniedOnce: state.notificationPermissionDeniedOnce,
            isPermanentlyDenied: state.notificationPermissionPermanentlyDenied,
            onRequest: () => notifier.requestNotificationPermission(),
            openSettings: () => notifier.openAppSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required bool granted,
    required bool required,
    required bool hasBeenDeniedOnce,
    required bool isPermanentlyDenied,
    required VoidCallback onRequest,
    required VoidCallback openSettings,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  granted ? Icons.check_circle : Icons.cancel,
                  color: granted ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!granted && required && hasBeenDeniedOnce) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'App cannot operate without this permission',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!granted && !required) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This helps you classify transactions',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!granted) ...[
              const SizedBox(height: 12),
              if (isPermanentlyDenied)
                ElevatedButton.icon(
                  onPressed: openSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Open Settings'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: onRequest,
                  icon: const Icon(Icons.add),
                  label: const Text('Grant Permission'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBankAccountPage(
    BuildContext context,
    SetupState state,
    SetupNotifier notifier,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Bank Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add at least one bank account to get started.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  _showAddBankAccountBottomSheet(context, notifier),
              icon: const Icon(Icons.add),
              label: const Text('Add Account'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 24),
            if (state.bankAccounts.isEmpty)
              const Center(
                child: Text(
                  'No accounts added yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...state.bankAccounts.asMap().entries.map((entry) {
                final index = entry.key;
                final account = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: Text(account.accountName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (account.accountNumber.isNotEmpty)
                          Text(account.accountNumber),
                        if (account.description.isNotEmpty)
                          Text(account.description),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => notifier.removeBankAccount(index),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesPage(
    BuildContext context,
    SetupState state,
    SetupNotifier notifier,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Categories',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select prefilled categories or add your own.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddCategoryDialog(context, notifier),
                icon: const Icon(Icons.add),
                label: const Text('Add Category'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No categories yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => notifier.getPrefilledCategories(),
                        child: const Text('Use Default Categories'),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return Card(
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(category.color),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    IconUtils.getIcon(category.icon),
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => notifier.removeCategory(index),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTagsPage(
    BuildContext context,
    SetupState state,
    SetupNotifier notifier,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tags',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add tags to organize your transactions. (Optional)',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddTagDialog(context, notifier),
                icon: const Icon(Icons.add),
                label: const Text('Add Tag'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.tags.isEmpty
              ? const Center(
                  child: Text(
                    'No tags yet. Click "Add Tag" to create one.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.tags.map((tag) {
                      return Chip(
                        label: Text(tag.name),
                        backgroundColor: Color(
                          int.parse(tag.color.replaceFirst('#', '0xFF')),
                        ),
                        deleteIconColor: Colors.white,
                        onDeleted: () =>
                            notifier.removeTag(state.tags.indexOf(tag)),
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(BuildContext context, int current, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= current ? AppColors.primary : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    SetupState state,
    SetupNotifier notifier,
  ) {
    final currentPageIndex = SetupStep.values.indexOf(state.currentPage);

    return Column(
      children: [
        _buildStepIndicator(context, currentPageIndex, 5),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              if (!state.isFirstPage)
                TextButton(
                  onPressed: () => notifier.previousPage(),
                  child: const Text('Back'),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: state.canProceedToNext
                    ? () => notifier.nextPage()
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 48),
                ),
                child: Text(state.isLastPage ? 'Complete Setup' : 'Next'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showAddBankAccountBottomSheet(
    BuildContext context,
    SetupNotifier notifier,
  ) {
    final accountNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Bank Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: accountNameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Account Number (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (accountNameController.text.isNotEmpty) {
                    notifier.addBankAccount(
                      BankAccount(
                        id: DateTime.now().millisecondsSinceEpoch,
                        accountName: accountNameController.text,
                        accountNumber: accountNumberController.text,
                        description: descriptionController.text,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Account'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, SetupNotifier notifier) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedIcon = 'restaurant';
    int selectedColor = AppColors.primary.toARGB32();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name *'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                const Text('Icon'),
                const SizedBox(height: 8),
                IconPicker(
                  selectedIcon: selectedIcon,
                  onIconSelected: (icon) => setState(() => selectedIcon = icon),
                ),
                const SizedBox(height: 16),
                const Text('Color'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildColorOption(
                      AppColors.primary.toARGB32(),
                      selectedColor,
                      setState,
                    ),
                    _buildColorOption(
                      AppColors.income.toARGB32(),
                      selectedColor,
                      setState,
                    ),
                    _buildColorOption(
                      AppColors.expense.toARGB32(),
                      selectedColor,
                      setState,
                    ),
                    _buildColorOption(
                      AppColors.warning.toARGB32(),
                      selectedColor,
                      setState,
                    ),
                    _buildColorOption(
                      AppColors.gray600.toARGB32(),
                      selectedColor,
                      setState,
                    ),
                    _buildColorOption(
                      AppColors.gray800.toARGB32(),
                      selectedColor,
                      setState,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty) {
                            notifier.addCategory(
                              Category(
                                id: DateTime.now().millisecondsSinceEpoch,
                                name: nameController.text,
                                icon: selectedIcon,
                                color: selectedColor,
                                description: descriptionController.text,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(
    int colorValue,
    int selectedColor,
    StateSetter setState,
  ) {
    final isSelected = colorValue == selectedColor;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = colorValue),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Color(colorValue),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _showAddTagDialog(BuildContext context, SetupNotifier notifier) {
    final nameController = TextEditingController();
    int selectedColor = AppColors.primary.toARGB32();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Tag',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name *'),
                ),
                const SizedBox(height: 16),
                const Text('Color'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildColorOption(
                      AppColors.primary.toARGB32(),
                      selectedColor,
                      setState,
                    ),
                    _buildColorOption(
                      AppColors.income.toARGB32(),
                      selectedColor,
                      setState,
                    ),
                    _buildColorOption(
                      AppColors.expense.toARGB32(),
                      selectedColor,
                      setState,
                    ),
                    _buildColorOption(
                      AppColors.warning.toARGB32(),
                      selectedColor,
                      setState,
                    ),
                    _buildColorOption(
                      AppColors.gray600.toARGB32(),
                      selectedColor,
                      setState,
                    ),
                    _buildColorOption(
                      AppColors.gray800.toARGB32(),
                      selectedColor,
                      setState,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isNotEmpty) {
                            final colorHex =
                                '#${selectedColor.toRadixString(16).substring(2)}';
                            notifier.addTag(
                              Tag(
                                id: DateTime.now().millisecondsSinceEpoch,
                                name: nameController.text,
                                color: colorHex,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
