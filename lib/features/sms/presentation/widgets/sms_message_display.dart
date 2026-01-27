import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SMSMessageDisplay extends StatelessWidget {
  final String message;
  final Map<String, List<int>>? selectedFields;
  final Function(String, int) onWordTap;

  const SMSMessageDisplay({
    super.key,
    required this.message,
    this.selectedFields,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final words = message.split(' ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray300),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: words.asMap().entries.map((entry) {
          final index = entry.key;
          final word = entry.value;

          // Check if this word is part of a selected field
          final fieldType = _getFieldType(index);
          final isSelected = fieldType != null;

          return GestureDetector(
            onTap: () => onWordTap(word, index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getFieldColor(fieldType),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _getFieldBorderColor(fieldType),
                  width: 1,
                ),
              ),
              child: Text(
                word,
                style: TextStyle(
                  color: _getFieldTextColor(fieldType),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String? _getFieldType(int index) {
    if (selectedFields == null) return null;

    for (final entry in selectedFields!.entries) {
      if (entry.value.contains(index)) {
        return entry.key;
      }
    }
    return null;
  }

  Color _getFieldColor(String? fieldType) {
    switch (fieldType) {
      case 'amount':
        return AppColors.income.withOpacity(0.2);
      case 'counterparty':
        return AppColors.primary.withOpacity(0.2);
      case 'reference':
        return AppColors.warning.withOpacity(0.2);
      default:
        return Colors.white;
    }
  }

  Color _getFieldBorderColor(String? fieldType) {
    switch (fieldType) {
      case 'amount':
        return AppColors.income;
      case 'counterparty':
        return AppColors.primary;
      case 'reference':
        return AppColors.warning;
      default:
        return AppColors.gray300;
    }
  }

  Color _getFieldTextColor(String? fieldType) {
    switch (fieldType) {
      case 'amount':
        return AppColors.incomeDark;
      case 'counterparty':
        return AppColors.primaryDark;
      case 'reference':
        return Colors.brown[700]!;
      default:
        return AppColors.textLight;
    }
  }
}
