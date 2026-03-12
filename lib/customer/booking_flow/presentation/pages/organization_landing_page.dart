import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:queue_ease/core/widgets/form_app_bar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../shared/organization/domain/entities/organization_entity.dart';
import '../../../../shared/organization/domain/entities/working_hours_entity.dart';
import '../cubit/organization_landing_cubit.dart';
import '../cubit/organization_landing_state.dart';
import '../widgets/booking_action_bar.dart';
import '../widgets/org_info_card.dart';
import '../widgets/org_profile_header.dart';

class OrganizationLandingPage extends StatelessWidget {
  const OrganizationLandingPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizationLandingCubit, OrganizationLandingState>(
      builder: (context, state) {
        return switch (state) {
          OrganizationLandingInitial() || OrganizationLandingLoading() =>
            const Scaffold(body: AppLoadingIndicator()),
          OrganizationLandingNotFound() => const Scaffold(
            body: ErrorView(
              title: 'Organization not found',
              message:
                  'The booking link you followed is no longer active or does not exist.',
            ),
          ),
          OrganizationLandingError(:final message) => Scaffold(
            body: ErrorView(
              message: message,
              onRetry: () => context
                  .read<OrganizationLandingCubit>()
                  .loadOrganization(slug),
            ),
          ),
          OrganizationLandingLoaded(
            :final org,
            :final isCurrentlyOpen,
            :final todayWorkingHours,
          ) =>
            _LandingBody(
              org: org,
              isCurrentlyOpen: isCurrentlyOpen,
              todayWorkingHours: todayWorkingHours,
            ),
        };
      },
    );
  }
}

class _LandingBody extends StatelessWidget {
  const _LandingBody({
    required this.org,
    required this.isCurrentlyOpen,
    required this.todayWorkingHours,
  });

  final OrganizationEntity org;
  final bool isCurrentlyOpen;
  final WorkingHoursEntity? todayWorkingHours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormAppBar(title: 'QueueEase', onBack: context.pop),
      backgroundColor: AppColors.background,
      bottomNavigationBar: BookingActionBar(
        enabled: isCurrentlyOpen,
        onTap: () => context.push(
          '/c/org/${org.bookingLinkSlug}/services',
          extra: (orgId: org.id, orgName: org.name),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OrgProfileHeader(org: org, isCurrentlyOpen: isCurrentlyOpen),
              const SizedBox(height: 8),
              if (org.address != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OrgInfoCard(
                    icon: Icons.location_on_outlined,
                    title: org.address!,
                  ),
                ),
              if (todayWorkingHours != null && todayWorkingHours!.isOpen) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OrgInfoCard(
                    icon: Icons.schedule_outlined,
                    title:
                        '${_formatTime(todayWorkingHours!.openTime)} – ${_formatTime(todayWorkingHours!.closeTime)}',
                    subtitle: "Today's hours",
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Converts "HH:mm" (24-hour) to "h:mm AM/PM" display format.
  String _formatTime(String hhmm) {
    final parts = hhmm.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }
}
