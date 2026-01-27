import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TextFieldSelector extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final String? hintText;
  final IconData icon;

  const TextFieldSelector({
    super.key,
    required this.label,
    this.value,
    required this.onTap,
    this.hintText,
    this.icon = Icons.edit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: value != null ? AppColors.gray50 : Colors.white,
              border: Border.all(
                color: value != null ? AppColors.primary : AppColors.gray300,
                width: value != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: value != null ? AppColors.primary : AppColors.gray400,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? hintText ?? 'Select $label',
                    style: TextStyle(
                      color: value != null
                          ? AppColors.textLight
                          : AppColors.gray400,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.gray400),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
