import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/form_app_bar.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../shared/organization/domain/entities/service_entity.dart';
import '../cubit/booking_form_cubit.dart';
import '../cubit/booking_form_state.dart';
import '../widgets/booking_summary_card.dart';
import 'booking_confirmation_page.dart';

/// Arguments passed via GoRouter [extra] to [BookingFormPage].
typedef BookingFormArgs = ({
  String orgId,
  String orgName,
  String slug,
  ServiceEntity service,
  DateTime scheduledAt,
  String customerId,
  String prefillName,
});

/// Booking confirmation form: summary card + customer name + optional phone.
///
/// On success, navigates to [BookingConfirmationPage] using [go()] to clear
/// the booking stack. On conflict, surfaces a snackbar and pops back to the
/// slot picker. On network error, shows an inline banner with a Retry button
/// while preserving the form fields.
class BookingFormPage extends StatefulWidget {
  const BookingFormPage({super.key, required this.args});

  final BookingFormArgs args;

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.args.prefillName);
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingFormCubit, BookingFormState>(
      listener: _onStateChange,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: FormAppBar(title: 'Confirm Booking', onBack: context.pop),
        body: BlocBuilder<BookingFormCubit, BookingFormState>(
          builder: (context, state) {
            final isSubmitting = state is BookingFormSubmitting;
            final errorMessage = state is BookingFormError
                ? state.message
                : null;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BookingSummaryCard(
                          orgName: widget.args.orgName,
                          serviceName: widget.args.service.name,
                          scheduledAt: widget.args.scheduledAt,
                          durationMinutes: widget.args.service.durationMinutes,
                        ),
                        const SizedBox(height: 24),
                        _ContactFields(
                          formKey: _formKey,
                          nameController: _nameController,
                          phoneController: _phoneController,
                          enabled: !isSubmitting,
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          _ErrorBanner(
                            message: errorMessage,
                            onRetry: context
                                .read<BookingFormCubit>()
                                .retrySubmit,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _SubmitBar(
                  isLoading: isSubmitting,
                  onSubmit: isSubmitting ? null : () => _submit(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<BookingFormCubit>().submitBooking(
      customerName: _nameController.text,
      customerPhone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );
  }

  void _onStateChange(BuildContext context, BookingFormState state) {
    switch (state) {
      case BookingFormSuccess(:final appointment):
        final BookingConfirmationArgs confirmArgs = (
          orgName: widget.args.orgName,
          orgAddress: null,
          service: widget.args.service,
          appointment: appointment,
        );
        context.go(
          '/c/org/${widget.args.slug}/confirmation',
          extra: confirmArgs,
        );
      case BookingFormConflict(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      default:
        break;
    }
  }
}

class _ContactFields extends StatelessWidget {
  const _ContactFields({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.enabled,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: nameController,
            enabled: enabled,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: phoneController,
            enabled: enabled,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Phone Number (optional)',
              hintText: 'Enter your phone number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.isLoading, required this.onSubmit});

  final bool isLoading;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outline.withValues(alpha: 0.4)),
        ),
      ),
      child: LoadingButton(
        label: 'Confirm Booking',
        isLoading: isLoading,
        onPressed: onSubmit,
      ),
    );
  }
}
