import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:upence/views/setup/setup_view_model.dart';
import 'package:upence/views/setup/widgets/accounts_setup_page.dart';
import 'package:upence/views/setup/widgets/categories_setup_page.dart';
import 'package:upence/views/setup/widgets/permissions_page.dart';
import 'package:upence/views/setup/widgets/setup_progress_indicator.dart';
import 'package:upence/views/setup/widgets/tags_setup_page.dart';
import 'package:upence/views/setup/widgets/welcome_page.dart';

class SetupView extends ConsumerStatefulWidget {
  const SetupView({super.key});

  @override
  ConsumerState<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends ConsumerState<SetupView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(setupViewModelProvider);
    final viewModel = ref.read(setupViewModelProvider.notifier);

    ref.listen<SetupState>(setupViewModelProvider, (previous, next) {
      if (previous?.currentStep != next.currentStep) {
        _pageController.animateToPage(
          next.currentStep.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  WelcomePage(),
                  PermissionsPage(),
                  AccountsSetupPage(),
                  CategoriesSetupPage(),
                  TagsSetupPage(),
                ],
              ),
            ),
            SetupProgressIndicator(
              currentStep: state.currentStep.index + 1,
              totalSteps: SetupViewModel.totalSteps,
            ),
            _buildNavigationButtons(context, state, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    SetupState state,
    dynamic viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              if (state.currentStep.index > 0)
                Expanded(
                  child: TextButton(
                    onPressed: () => viewModel.previousStep(),
                    child: const Text('Back'),
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: 16),
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton(
                        onPressed: viewModel.canProceedFromCurrentStep()
                            ? () async {
                                if (state.currentStep == SetupStep.tags) {
                                  await viewModel.completeSetup();
                                  if (context.mounted) {
                                    context.go("/");
                                  }
                                } else {
                                  viewModel.nextStep();
                                }
                              }
                            : null,
                        child: Text(
                          state.currentStep == SetupStep.tags
                              ? 'Complete'
                              : 'Next',
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
