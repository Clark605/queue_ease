import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:queue_ease/core/widgets/widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/auth/presentation/cubit/auth_cubit.dart';
import '../../../../shared/auth/presentation/cubit/auth_state.dart';
import '../../../../shared/organization/domain/entities/service_entity.dart';
import '../cubit/slot_picker_cubit.dart';
import '../cubit/slot_picker_state.dart';
import '../widgets/date_selector.dart';
import '../widgets/time_slot_grid.dart';
import 'booking_form_page.dart';

/// Arguments passed via GoRouter [extra] to [SlotPickerPage].
typedef SlotPickerArgs = ({
  String orgId,
  String orgName,
  String slug,
  String serviceId,
  ServiceEntity service,
  int durationMinutes,
  String serviceName,
});

class SlotPickerPage extends StatelessWidget {
  const SlotPickerPage({super.key, required this.args});

  final SlotPickerArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormAppBar(title: 'Select Time Slot', onBack: context.pop),
      body: BlocBuilder<SlotPickerCubit, SlotPickerState>(
        builder: (context, state) => switch (state) {
          SlotPickerInitial() => const AppLoadingIndicator(),
          SlotPickerError(:final message) => ErrorView(
            message: message,
            onRetry: () => context.read<SlotPickerCubit>().init(
              orgId: args.orgId,
              serviceId: args.serviceId,
              durationMinutes: args.durationMinutes,
            ),
          ),
          SlotPickerLoading(:final selectedDate, :final closedDayIndices) =>
            _SlotPickerBody(
              args: args,
              selectedDate: selectedDate,
              closedDayIndices: closedDayIndices,
              availableSlots: const [],
              selectedSlot: null,
              isLoading: true,
            ),
          SlotPickerNoSlots(:final selectedDate, :final closedDayIndices) =>
            _SlotPickerBody(
              args: args,
              selectedDate: selectedDate,
              closedDayIndices: closedDayIndices,
              availableSlots: const [],
              selectedSlot: null,
              isLoading: false,
            ),
          SlotPickerLoaded(
            :final selectedDate,
            :final availableSlots,
            :final closedDayIndices,
            :final selectedSlot,
          ) =>
            _SlotPickerBody(
              args: args,
              selectedDate: selectedDate,
              closedDayIndices: closedDayIndices,
              availableSlots: availableSlots,
              selectedSlot: selectedSlot,
              isLoading: false,
            ),
        },
      ),
    );
  }
}

class _SlotPickerBody extends StatelessWidget {
  const _SlotPickerBody({
    required this.args,
    required this.selectedDate,
    required this.closedDayIndices,
    required this.availableSlots,
    required this.selectedSlot,
    required this.isLoading,
  });

  final SlotPickerArgs args;
  final DateTime selectedDate;
  final Set<int> closedDayIndices;
  final List<DateTime> availableSlots;
  final DateTime? selectedSlot;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Service info summary strip
        _ServiceSummaryStrip(
          serviceName: args.serviceName,
          durationMinutes: args.durationMinutes,
        ),
        // Date selector (always visible once working hours are loaded)
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: DateSelector(
            selectedDate: selectedDate,
            closedDayIndices: closedDayIndices,
            onDateSelected: (date) =>
                context.read<SlotPickerCubit>().loadSlotsForDate(date),
          ),
        ),
        const Divider(indent: 20, endIndent: 20),
        const SizedBox(height: 8),

        // Slot area
        Expanded(
          child: isLoading
              ? const AppLoadingIndicator()
              : availableSlots.isEmpty
              ? const EmptyStateView(
                  icon: Icons.event_busy_outlined,
                  title: 'No Slots Available',
                  subtitle:
                      'There are no available time slots for this day. '
                      'Please try another date.',
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: TimeSlotGrid(
                    slots: availableSlots,
                    selectedSlot: selectedSlot,
                    onSlotSelected: (slot) =>
                        context.read<SlotPickerCubit>().selectSlot(slot),
                  ),
                ),
        ),

        // Sticky footer
        _SlotPickerFooter(
          selectedSlot: selectedSlot,
          onConfirm: selectedSlot != null
              ? () => _onConfirm(context, selectedSlot!)
              : null,
        ),
      ],
    );
  }

  void _onConfirm(BuildContext context, DateTime slot) {
    final authState = context.read<AuthCubit>().state;
    final customerId = authState is Authenticated ? authState.user.uid : '';
    final prefillName = authState is Authenticated
        ? authState.user.displayName ?? ''
        : '';
    final BookingFormArgs bookingArgs = (
      orgId: args.orgId,
      orgName: args.orgName,
      slug: args.slug,
      service: args.service,
      scheduledAt: slot,
      customerId: customerId,
      prefillName: prefillName,
    );
    context.push('/c/org/${args.slug}/book', extra: bookingArgs);
  }
}

class _ServiceSummaryStrip extends StatelessWidget {
  const _ServiceSummaryStrip({
    required this.serviceName,
    required this.durationMinutes,
  });

  final String serviceName;
  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$durationMinutes min appointment',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotPickerFooter extends StatelessWidget {
  const _SlotPickerFooter({
    required this.selectedSlot,
    required this.onConfirm,
  });

  final DateTime? selectedSlot;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Info note — matches design
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Please arrive 10 minutes before your scheduled '
                    'appointment time.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.outline,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirm Booking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
