import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:queue_ease/core/widgets/widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/organization/domain/entities/service_entity.dart';
import '../cubit/service_selection_cubit.dart';
import '../cubit/service_selection_state.dart';
import '../widgets/service_card.dart';
import 'service_details_page.dart';

class ServiceSelectionPage extends StatelessWidget {
  const ServiceSelectionPage({
    super.key,
    required this.orgId,
    required this.orgName,
    required this.slug,
  });

  final String orgId;
  final String orgName;
  final String slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: FormAppBar(title: 'Select Service', onBack: context.pop),
      body: BlocBuilder<ServiceSelectionCubit, ServiceSelectionState>(
        builder: (context, state) => switch (state) {
          ServiceSelectionInitial() ||
          ServiceSelectionLoading() => const AppLoadingIndicator(),
          ServiceSelectionLoaded(:final services) when services.isEmpty =>
            const EmptyStateView(
              icon: Icons.medical_services_outlined,
              title: 'No Services Available',
              subtitle: 'This organisation has no active services right now.',
            ),
          ServiceSelectionLoaded(:final services) => _ServiceList(
            services: services,
            onTap: (s) => _navigateToDetails(context, s),
          ),
          ServiceSelectionError(:final message) => ErrorView(
            message: message,
            onRetry: () =>
                context.read<ServiceSelectionCubit>().loadServices(orgId),
          ),
        },
      ),
    );
  }

  void _navigateToDetails(BuildContext context, ServiceEntity service) {
    final ServiceDetailsArgs args = (
      orgId: orgId,
      orgName: orgName,
      slug: slug,
      service: service,
    );
    context.push('/c/org/$slug/service-details', extra: args);
  }
}

class _ServiceList extends StatelessWidget {
  const _ServiceList({required this.services, required this.onTap});

  final List<ServiceEntity> services;
  final ValueChanged<ServiceEntity> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            'Available Services',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: services.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final service = services[index];
              return ServiceCard(service: service, onTap: () => onTap(service));
            },
          ),
        ),
      ],
    );
  }
}
