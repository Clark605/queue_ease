import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../shared/organization/domain/entities/organization_entity.dart';
import '../cubit/organization_landing_cubit.dart';
import '../cubit/organization_landing_state.dart';

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
          OrganizationLandingLoaded(:final org, :final isCurrentlyOpen) =>
            _LandingBody(org: org, isCurrentlyOpen: isCurrentlyOpen),
        };
      },
    );
  }
}

class _LandingBody extends StatelessWidget {
  const _LandingBody({required this.org, required this.isCurrentlyOpen});

  final OrganizationEntity org;
  final bool isCurrentlyOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(org.name, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              _OpenClosedBadge(isOpen: isCurrentlyOpen),
              if (org.description != null) ...[
                const SizedBox(height: 16),
                Text(org.description!, style: theme.textTheme.bodyMedium),
              ],
              if (org.address != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        org.address!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: isCurrentlyOpen
                    ? () => context.push(
                        '/c/org/${org.bookingLinkSlug}/services',
                        extra: org.id,
                      )
                    : null,
                child: const Text('Book Appointment'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpenClosedBadge extends StatelessWidget {
  const _OpenClosedBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? Colors.green : Colors.red;
    final label = isOpen ? 'Open Now' : 'Closed';
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
