import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/form_app_bar.dart';
import '../../../../shared_domain/entities/service_entity.dart';
import '../widgets/service_details/service_detail_hero.dart';
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
          children: [ServiceDetailHero(service: service)],
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
