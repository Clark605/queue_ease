import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../cubit/service_selection_cubit.dart';
import '../cubit/service_selection_state.dart';
import '../widgets/service_card.dart';

class ServiceSelectionPage extends StatelessWidget {
  const ServiceSelectionPage({super.key, required this.orgId});

  final String orgId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Service')),
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
          ServiceSelectionLoaded(:final services) => ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ServiceCard(
                service: service,
                onTap: () => _onServiceSelected(context, service.id),
              );
            },
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

  void _onServiceSelected(BuildContext context, String serviceId) {
    // TODO(T020): navigate to date/time picker with orgId + serviceId
  }
}
