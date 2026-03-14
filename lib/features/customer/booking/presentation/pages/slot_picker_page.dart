import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:queue_ease/core/widgets/widgets.dart';
import '../../../../authentication/presentation/cubit/auth_cubit.dart';
import '../../../../authentication/presentation/cubit/auth_state.dart';
import '../../../../shared_domain/entities/service_entity.dart';
import '../cubit/slot_picker_cubit.dart';
import '../cubit/slot_picker_state.dart';
import '../widgets/slot_picker/date_selector.dart';
import '../widgets/slot_picker/service_summary_strip.dart';
import '../widgets/slot_picker/slot_picker_footer.dart';
import '../widgets/slot_picker/time_slot_grid.dart';
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
        ServiceSummaryStrip(
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

        SlotPickerFooter(
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
