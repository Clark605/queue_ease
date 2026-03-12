import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:queue_ease/core/dialogs/delete_confirmation_dialog.dart';
import 'package:queue_ease/core/router/app_router.dart';
import 'package:queue_ease/core/theme/app_colors.dart';
import 'package:queue_ease/core/theme/app_text_styles.dart';
import 'package:queue_ease/core/widgets/empty_state_view.dart';
import 'package:queue_ease/core/widgets/error_view.dart';
import 'package:queue_ease/features/shared_domain/entities/service_entity.dart';

import '../cubit/service_cubit.dart';
import '../cubit/service_state.dart';
import '../widgets/service_list_tile.dart';

/// Displays the list of services for the authenticated admin's organization.
///
/// Stitch references:
///   Empty State — `6390660a070a4727baea580118dd6bca`
///   List        — `eb2781a9ff3646ef87decaf682022a32`
class ServiceListPage extends StatelessWidget {
  const ServiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          'Services',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const IconButton(
            icon: Icon(Icons.search_rounded),
            color: AppColors.onSurfaceVariant,
            onPressed: null, // Future: implement search
            tooltip: 'Search',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.outline.withValues(alpha: 0.4),
            height: 1,
          ),
        ),
      ),
      body: BlocBuilder<ServiceCubit, ServiceState>(
        // Don't rebuild on success — keep the last ServiceLoaded view
        // visible while the stream pushes an updated ServiceLoaded.
        buildWhen: (_, current) => current is! ServiceOperationSuccess,
        builder: (context, state) {
          if (state is ServiceLoading || state is ServiceInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ServiceError) {
            return ErrorView(message: state.message);
          }
          if (state is ServiceLoaded) {
            if (state.services.isEmpty) {
              return EmptyStateView(
                icon: Icons.medical_services_outlined,
                title: 'No services yet',
                subtitle: 'Add your first service to start accepting bookings',
                actionLabel: 'Add Service',
                onAction: () => context.push(Routes.adminServiceForm),
              );
            }
            return _ServiceList(services: state.services);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Service'),
        onPressed: () => context.push(Routes.adminServiceForm),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _ServiceList extends StatelessWidget {
  const _ServiceList({required this.services});

  final List<ServiceEntity> services;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceListTile(
          service: service,
          onEdit: () => context.push(Routes.adminServiceForm, extra: service),
          onDelete: () => _confirmDelete(context, service),
          onToggle: () => context.read<ServiceCubit>().updateService(
            service.copyWith(isActive: !service.isActive),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ServiceEntity service,
  ) async {
    final cubit = context.read<ServiceCubit>();
    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: 'Delete Service',
      itemName: service.name,
    );
    if (confirmed) {
      cubit.deleteService(orgId: service.orgId, serviceId: service.id);
    }
  }
}
