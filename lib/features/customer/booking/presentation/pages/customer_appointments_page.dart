import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../shared_domain/entities/appointment_entity.dart';
import '../../../../shared_domain/entities/appointment_status.dart';
import '../cubit/customer_appointments_cubit.dart';
import '../cubit/customer_appointments_state.dart';

class CustomerAppointmentsPage extends StatelessWidget {
  const CustomerAppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
      ),
      body: BlocBuilder<CustomerAppointmentsCubit, CustomerAppointmentsState>(
        builder: (context, state) {
          return switch (state) {
            CustomerAppointmentsInitial() || CustomerAppointmentsLoading() =>
              const Center(child: CircularProgressIndicator()),
            CustomerAppointmentsError(:final message) => _ErrorState(
              message: message,
            ),
            CustomerAppointmentsLoaded(:final appointments) => _LoadedState(
              appointments: appointments,
            ),
          };
        },
      ),
    );
  }
}

class _LoadedState extends StatelessWidget {
  const _LoadedState({required this.appointments});

  final List<AppointmentEntity> appointments;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const Center(
        child: Text(
          'No appointments yet.',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _AppointmentCard(appointment: appointment);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: appointments.length,
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final AppointmentEntity appointment;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE, MMM d').format(appointment.scheduledAt);
    final time = DateFormat('h:mm a').format(appointment.scheduledAt);
    final serviceLabel =
        appointment.serviceName ?? 'Service #${appointment.serviceId}';
    final orgLabel = appointment.orgName ?? appointment.orgId;
    final statusConfig = _statusConfig(appointment.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orgLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(label: statusConfig.label, color: statusConfig.color),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 18,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.schedule,
                size: 18,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ({String label, Color color}) _statusConfig(AppointmentStatus status) {
    return switch (status) {
      AppointmentStatus.booked => (label: 'Booked', color: AppColors.primary),
      AppointmentStatus.inQueue => (
        label: 'In queue',
        color: AppColors.warning,
      ),
      AppointmentStatus.serving => (label: 'Serving', color: AppColors.info),
      AppointmentStatus.completed => (
        label: 'Completed',
        color: AppColors.success,
      ),
      AppointmentStatus.cancelled => (
        label: 'Cancelled',
        color: AppColors.error,
      ),
      AppointmentStatus.noShow => (label: 'No-show', color: AppColors.error),
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
