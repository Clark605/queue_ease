import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Displays the customer's live queue position and estimated wait time.
///
/// Full BLoC wiring and live UI are added in Phase 4 (T026).
class CustomerQueueStatusPage extends StatelessWidget {
  const CustomerQueueStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO(T026): Replace with live CustomerQueueStatusCubit UI (Phase 4).
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Queue Status',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
