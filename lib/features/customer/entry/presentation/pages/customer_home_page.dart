import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../../authentication/presentation/cubit/auth_state.dart';
import '../cubit/customer_dashboard_cubit.dart';
import '../cubit/customer_dashboard_state.dart';
import '../widgets/active_queue_status_card.dart';
import '../widgets/customer_action_buttons.dart';
import '../widgets/customer_dashboard_empty_state.dart';
import '../widgets/customer_home_drawer.dart';
import '../widgets/customer_home_header.dart';
import '../widgets/customer_welcome_section.dart';
import '../widgets/upcoming_appointment_card.dart';
import '../../../../shared_domain/entities/appointment_entity.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final displayName = authState is Authenticated
        ? (authState.user.displayName ?? 'there')
        : 'there';
    final email = authState is Authenticated ? authState.user.email : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: CustomerHomeDrawer(displayName: displayName, email: email),
      body: BlocBuilder<CustomerDashboardCubit, CustomerDashboardState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) => CustomerHomeHeader(
                    onMenuTap: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: CustomerWelcomeSection(displayName: displayName),
              ),
              ..._buildContentSlivers(context, state),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildContentSlivers(
    BuildContext context,
    CustomerDashboardState state,
  ) {
    return switch (state) {
      CustomerDashboardInitial() || CustomerDashboardLoading() => [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      CustomerDashboardError(:final message) => [_errorSliver(message)],
      CustomerDashboardLoaded() => _loadedSlivers(context, state),
    };
  }

  Widget _errorSliver(String message) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _loadedSlivers(
    BuildContext context,
    CustomerDashboardLoaded state,
  ) {
    final dashboard = state.dashboard;

    if (dashboard.isEmpty) {
      return [
        SliverFillRemaining(
          child: CustomerDashboardEmptyState(
            onBookAppointment: () => context.push(Routes.customerAccess),
          ),
        ),
      ];
    }

    return [
      if (dashboard.hasActiveQueue)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ActiveQueueStatusCard(
              appointment: dashboard.activeAppointment!,
              queueStatus: dashboard.queueStatus,
            ),
          ),
        ),
      SliverToBoxAdapter(
        child: CustomerActionButtons(
          onBook: () => context.push(Routes.customerAccess),
          showViewQueue: dashboard.hasActiveQueue,
          onViewQueue: dashboard.hasActiveQueue
              ? () => context.push(
                  Routes.customerQueueStatus,
                  extra: dashboard.activeAppointment!.orgId,
                )
              : null,
        ),
      ),
      if (dashboard.hasUpcoming)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _UpcomingSection(
              onSeeAll: () => context.push(Routes.customerAccess),
              appointment: dashboard.upcomingAppointment!,
            ),
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 40)),
    ];
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection({required this.onSeeAll, required this.appointment});

  final VoidCallback onSeeAll;
  final AppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Next Appointment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        UpcomingAppointmentCard(appointment: appointment),
      ],
    );
  }
}
