import 'package:flutter/material.dart';

class SetupProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const SetupProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Padding(
      padding: const EdgeInsets.only(top:24, left: 24, right: 24),
      child: Column(
        children: [
          Text(
            'Step $currentStep of $totalSteps',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium
          ),
          const SizedBox(height: 12),
          FractionallySizedBox(
            widthFactor: 0.5,
            child:ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          )),
        ],
      ),
    );
  }
}
