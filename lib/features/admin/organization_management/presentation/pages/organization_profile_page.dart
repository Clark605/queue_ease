import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:queue_ease/core/router/app_router.dart';
import 'package:queue_ease/core/theme/app_colors.dart';
import 'package:queue_ease/core/theme/app_text_styles.dart';
import 'package:queue_ease/core/utils/app_snack_bar.dart';

import '../cubit/organization_cubit.dart';
import '../cubit/organization_state.dart';

/// Organization profile view page (read-only).
///
/// Displays all organization details in a card-based layout.
/// FAB navigates to edit page.
///
/// Stitch reference: Organization Landing Screen Variant 3
/// (screen ID: 2561164f987a4e7c84c9c59d56576da7)
class OrganizationProfilePage extends StatelessWidget {
  const OrganizationProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Organization Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<OrganizationCubit, OrganizationState>(
        builder: (context, state) {
          if (state is OrganizationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrganizationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text('Error', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is OrganizationLoaded) {
            final org = state.organization;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Header Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Logo or Icon
                          if (org.logoUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                org.logoUrl!,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.business,
                                      size: 80,
                                      color: AppColors.primary,
                                    ),
                              ),
                            )
                          else
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.business,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                          const SizedBox(height: 16),
                          // Organization Name
                          Text(
                            org.name,
                            style: AppTextStyles.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: org.isOpen
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  org.isOpen
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 16,
                                  color: org.isOpen
                                      ? Colors.green[700]
                                      : Colors.grey[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  org.isOpen ? 'Open' : 'Closed',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: org.isOpen
                                        ? Colors.green[700]
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Booking Link Card
                  _InfoCard(
                    icon: Icons.link,
                    title: 'Booking Link',
                    content: org.bookingLinkSlug,
                    subtitle: 'Share this link with your customers',
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: org.bookingLinkSlug),
                      );
                      AppSnackBar.showInfo(
                        context,
                        'Booking link copied to clipboard',
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Address Card
                  if (org.address != null)
                    _InfoCard(
                      icon: Icons.location_on,
                      title: 'Address',
                      content: org.address!,
                    ),
                  if (org.address != null) const SizedBox(height: 12),

                  // Description Card
                  if (org.description != null)
                    _InfoCard(
                      icon: Icons.description,
                      title: 'Description',
                      content: org.description!,
                    ),
                  if (org.description != null) const SizedBox(height: 12),

                  // Admin Info Card
                  _InfoCard(
                    icon: Icons.admin_panel_settings,
                    title: 'Admin ID',
                    content: org.adminUid,
                    subtitle: 'Organization owner',
                  ),
                  const SizedBox(height: 12),

                  // Created Date Card
                  _InfoCard(
                    icon: Icons.calendar_today,
                    title: 'Created',
                    content: _formatDate(org.createdAt),
                  ),

                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(Routes.adminOrgEdit);
        },
        icon: const Icon(Icons.edit),
        label: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Reusable info card widget for displaying organization details.
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String content;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.copy, size: 18, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}
