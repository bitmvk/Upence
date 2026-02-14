import 'package:flutter/material.dart';
import 'package:upence/core/utils/formatters.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoNext;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onPrevious,
    required this.onNext,
    this.canGoNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final monthName = DateFormatter.formatMonthName(selectedMonth.month);
    final year = selectedMonth.year;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          icon: Icons.chevron_left_rounded,
          onTap: onPrevious,
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                monthName,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                year.toString(),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildButton(
          icon: Icons.chevron_right_rounded,
          onTap: canGoNext ? onNext : null,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    VoidCallback? onTap,
    required ColorScheme colorScheme,
  }) {
    final isEnabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 22,
            color: isEnabled
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
