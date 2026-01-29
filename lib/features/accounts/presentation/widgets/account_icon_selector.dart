import 'package:flutter/material.dart';

class AccountIconSelector extends StatelessWidget {
  final String selectedIcon;
  final Function(String) onIconSelected;

  static const List<Map<String, dynamic>> accountIcons = [
    {'icon': Icons.account_balance_wallet, 'name': 'account_balance_wallet'},
    {'icon': Icons.account_balance, 'name': 'account_balance'},
    {'icon': Icons.credit_card, 'name': 'credit_card'},
    {'icon': Icons.savings, 'name': 'savings'},
  ];

  const AccountIconSelector({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Icon', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: accountIcons.map((iconData) {
            final isSelected = selectedIcon == iconData['name'];
            return Expanded(
              child: GestureDetector(
                onTap: () => onIconSelected(iconData['name']),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    iconData['icon'],
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade600,
                    size: 32,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
