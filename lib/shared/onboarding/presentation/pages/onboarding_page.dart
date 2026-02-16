import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/app/di/injection.dart';
import '../../../../core/app/router/app_router.dart';
import '../../../../core/app/theme/app_colors.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../domain/models/onboarding_content_model.dart';
import '../widgets/fair_turns_illustration.dart';
import '../widgets/onboarding_content.dart';
import '../widgets/real_time_tracking_illustration.dart';
import '../widgets/skip_the_wait_illustration.dart';

/// Full-screen onboarding experience shown on first launch.
///
/// Contains three swipeable pages with illustrations and copy, a page
/// indicator, skip button, and a primary action button that toggles
/// between "Next" and "Get Started" on the last page.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;

  static final _pages = <OnboardingContentModel>[
    OnboardingContentModel(
      title: 'No more waiting in line',
      subtitle: 'Join the queue or book an appointment before you arrive.',
      illustrationBuilder: (_) => const SkipTheWaitIllustration(),
    ),
    OnboardingContentModel(
      title: 'Know your turn in ',
      highlightedTitle: 'real time',
      subtitle:
          'Track your position and get notified when it\'s almost your turn.',
      illustrationBuilder: (_) => const RealTimeTrackingIllustration(),
    ),
    OnboardingContentModel(
      title: 'Fair turns.\nNo confusion.',
      subtitle:
          'If someone doesn\'t arrive on time, the queue moves forward automatically.',
      illustrationBuilder: (_) => const FairTurnsIllustration(),
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await getIt<OnboardingService>().markOnboardingComplete();
    if (mounted) {
      context.go(Routes.login);
    }
  }

  void _onNext() {
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button.
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 24, top: 16),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            // PageView.
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return OnboardingContent(model: _pages[index]);
                },
              ),
            ),

            const SizedBox(height: 20),

            // Page indicator.
            SmoothPageIndicator(
              controller: _controller,
              count: _pages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.primary,
                dotColor: Colors.grey.shade300,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 4,
                spacing: 8,
              ),
            ),

            const SizedBox(height: 28),

            // Primary button.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLastPage ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
