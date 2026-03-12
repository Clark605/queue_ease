import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/app_snack_bar.dart';
import 'management_card.dart';

class ManagementGrid extends StatelessWidget {
  const ManagementGrid({super.key, this.onNavigateToQueue});

  final VoidCallback? onNavigateToQueue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MANAGEMENT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ManagementCard(
                  icon: Icons.medical_services_outlined,
                  label: 'Services',
                  iconColor: AppColors.primary,
                  iconBgColor: const Color(0xFFEFF6FF),
                  onTap: () => context.push(Routes.adminServices),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ManagementCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Working Hours',
                  iconColor: const Color(0xFF4F46E5),
                  iconBgColor: const Color(0xFFEEF2FF),
                  onTap: () => context.push(Routes.adminWorkingHours),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ManagementCard(
                  icon: Icons.reorder,
                  label: 'Full Queue',
                  iconColor: const Color(0xFF059669),
                  iconBgColor: const Color(0xFFECFDF5),
                  onTap:
                      onNavigateToQueue ??
                      () => _showComingSoon(context, 'Full Queue'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ManagementCard(
                  icon: Icons.assessment_outlined,
                  label: 'Daily Summary',
                  iconColor: const Color(0xFFD97706),
                  iconBgColor: const Color(0xFFFFFBEB),
                  onTap: () => _showComingSoon(context, 'Daily Summary'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    AppSnackBar.showInfo(context, '$feature - Coming soon');
  }
}
