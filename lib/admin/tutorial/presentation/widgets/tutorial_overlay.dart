import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/tutorial_cubit.dart';
import '../cubit/tutorial_state.dart';

/// Step content for each tutorial step.
const _stepContent = {
  TutorialStep.confirmProfile: (
    title: 'Confirm Your Profile',
    description:
        'Review your organization details to make sure everything looks correct before customers can find you.',
  ),
  TutorialStep.addService: (
    title: 'Add Your First Service',
    description:
        'Create a service that your customers can queue up for. You can set the name, duration, and description.',
  ),
  TutorialStep.acknowledgeReady: (
    title: "You're All Set!",
    description:
        'Your organization is ready. Customers can now discover and join queues for your services.',
  ),
};

/// A full-screen overlay that guides a first-time admin through 3 setup steps.
///
/// Listens to [TutorialCubit] and renders itself only when the state is
/// [TutorialActive]. Emits no state itself — all actions are delegated to
/// [TutorialCubit.advance] and [TutorialCubit.skip].
///
/// Place this as the topmost child in a [Stack] on the admin dashboard.
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TutorialCubit, TutorialState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          (previous is TutorialActive &&
              current is TutorialActive &&
              previous.step != current.step),
      builder: (context, state) {
        if (state is! TutorialActive) return const SizedBox.shrink();

        final content = _stepContent[state.step]!;
        final steps = TutorialStep.values;
        final stepIndex = steps.indexOf(state.step);
        final isLastStep = stepIndex == steps.length - 1;

        return _TutorialOverlayContent(
          stepIndex: stepIndex,
          totalSteps: steps.length,
          title: content.title,
          description: content.description,
          isLastStep: isLastStep,
        );
      },
    );
  }
}

class _TutorialOverlayContent extends StatelessWidget {
  const _TutorialOverlayContent({
    required this.stepIndex,
    required this.totalSteps,
    required this.title,
    required this.description,
    required this.isLastStep,
  });

  final int stepIndex;
  final int totalSteps;
  final String title;
  final String description;
  final bool isLastStep;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TutorialCubit>();

    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Setup Guide',
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Step ${stepIndex + 1} of $totalSteps',
                          style: const TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Progress dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(totalSteps, (index) {
                            final isActive = index == stepIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 20 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.outline,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 24),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: cubit.skip,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.onSurfaceVariant,
                              ),
                              child: const Text('Skip'),
                            ),
                            FilledButton(
                              onPressed: cubit.advance,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size(100, 44),
                              ),
                              child: Text(isLastStep ? 'Finish' : 'Next'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
