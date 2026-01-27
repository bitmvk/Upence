import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/sms_parsing_pattern.dart';

class PatternMatchInfo extends StatelessWidget {
  final SMSParsingPattern? pattern;
  final double? matchScore;

  const PatternMatchInfo({super.key, this.pattern, this.matchScore});

  @override
  Widget build(BuildContext context) {
    if (pattern == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.gray400),
            const SizedBox(height: 8),
            Text(
              'No matching pattern found',
              style: TextStyle(color: AppColors.gray600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Select fields manually or create a new pattern',
              style: TextStyle(color: AppColors.gray400, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getMatchScoreColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getMatchScoreColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getMatchScoreIcon(), color: _getMatchScoreColor()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pattern!.patternName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sender: ${pattern!.senderName}',
                      style: TextStyle(fontSize: 14, color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
              if (matchScore != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getMatchScoreColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(matchScore! * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Transaction Type',
            pattern!.transactionType.toString().split('.').last.toUpperCase(),
          ),
          _buildInfoRow('Default Category', pattern!.defaultCategoryId),
          _buildInfoRow('Default Account', pattern!.defaultAccountId),
          _buildInfoRow(
            'Auto Select Account',
            pattern!.autoSelectAccount ? 'Yes' : 'No',
          ),
          if (pattern!.sampleSms.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Sample SMS',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pattern!.sampleSms,
              style: TextStyle(fontSize: 13, color: AppColors.gray500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 13, color: AppColors.gray600),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Color _getMatchScoreColor() {
    if (matchScore == null) return AppColors.gray400;

    if (matchScore! >= 0.8) return AppColors.income;
    if (matchScore! >= 0.5) return AppColors.warning;
    return AppColors.expense;
  }

  IconData _getMatchScoreIcon() {
    if (matchScore == null) return Icons.help_outline;

    if (matchScore! >= 0.8) return Icons.check_circle;
    if (matchScore! >= 0.5) return Icons.info;
    return Icons.warning;
  }
}
