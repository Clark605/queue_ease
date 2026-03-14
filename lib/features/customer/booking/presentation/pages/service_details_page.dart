import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/form_app_bar.dart';
import '../../../../shared_domain/entities/service_entity.dart';
import 'slot_picker_page.dart';

typedef ServiceDetailsArgs = ({
  String orgId,
  String orgName,
  String slug,
  ServiceEntity service,
});

class ServiceDetailsPage extends StatelessWidget {
  const ServiceDetailsPage({super.key, required this.args});

  final ServiceDetailsArgs args;

  @override
  Widget build(BuildContext context) {
    final service = args.service;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: FormAppBar(title: 'Service Details', onBack: context.pop),
      bottomNavigationBar: _ContinueBar(
        onContinue: () => _navigateToSlots(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_HeroSection(service: service)],
        ),
      ),
    );
  }

  void _navigateToSlots(BuildContext context) {
    final SlotPickerArgs slotArgs = (
      orgId: args.orgId,
      orgName: args.orgName,
      slug: args.slug,
      serviceId: args.service.id,
      service: args.service,
      durationMinutes: args.service.durationMinutes,
      serviceName: args.service.name,
    );
    context.push('/c/org/${args.slug}/slots', extra: slotArgs);
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.bottomLeft,
      children: [
        Container(
          width: double.infinity,
          height: 220,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.2),
                AppColors.primary.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (service.description != null &&
                  service.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  service.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _StatsGrid(service: service),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.service});

  final ServiceEntity service;

  @override
  Widget build(BuildContext context) {
    final stats = <({IconData icon, String label, String value})>[
      (
        icon: Icons.schedule_outlined,
        label: 'Duration',
        value: '${service.durationMinutes} min',
      ),
      if (service.price != null)
        (
          icon: Icons.attach_money,
          label: 'Price',
          value: '\$${service.price!.toStringAsFixed(2)}',
        ),
      if (service.queueType != null)
        (
          icon: Icons.confirmation_number_outlined,
          label: 'Queue Type',
          value: service.queueType!,
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 96,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) => _StatCard(stat: stats[i]),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final ({IconData icon, String label, String value}) stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(stat.icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  stat.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onContinue,
            child: const Text('Continue to Booking'),
          ),
        ),
      ),
    );
  }
}
