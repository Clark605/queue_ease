import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:queue_ease/core/dialogs/delete_confirmation_dialog.dart';
import 'package:queue_ease/core/theme/app_colors.dart';
import 'package:queue_ease/core/theme/app_text_styles.dart';
import 'package:queue_ease/core/utils/app_snack_bar.dart';
import 'package:queue_ease/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:queue_ease/features/authentication/presentation/cubit/auth_state.dart';
import 'package:queue_ease/features/shared_domain/entities/service_entity.dart';

import '../../../../../core/widgets/widgets.dart';
import '../cubit/service_cubit.dart';
import '../cubit/service_form_cubit.dart';
import '../cubit/service_form_state.dart';
import '../cubit/service_state.dart';
import '../widgets/service_main_card.dart';
import '../widgets/service_settings_card.dart';

/// Shared add / edit form for a [ServiceEntity].
///
/// Provisions a [ServiceFormCubit] scoped to this route to manage the
/// reactive stepper and toggle state. The inner [_ServiceFormBody] is a
/// [StatefulWidget] solely for [TextEditingController] lifecycle management —
/// it contains zero [State.setState] calls.
///
/// Stitch references:
///   Add  — `eb5dc21cc1624d30877ae249112e941a`
///   Edit — `dd7e56c4ee974bc2a41b13443f8b0b75`
class ServiceFormPage extends StatelessWidget {
  const ServiceFormPage({super.key, this.service});

  final ServiceEntity? service;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceFormCubit(initial: service),
      child: _ServiceFormBody(service: service),
    );
  }
}

// ---------------------------------------------------------------------------
// Body — StatefulWidget only for TextEditingController lifecycle
// ---------------------------------------------------------------------------

class _ServiceFormBody extends StatefulWidget {
  const _ServiceFormBody({this.service});

  final ServiceEntity? service;

  @override
  State<_ServiceFormBody> createState() => _ServiceFormBodyState();
}

class _ServiceFormBodyState extends State<_ServiceFormBody> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  bool get _isEditMode => widget.service != null;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameController = TextEditingController(text: s?.name ?? '');
    _priceController = TextEditingController(
      text: s?.price != null ? s!.price!.toStringAsFixed(2) : '',
    );
    _descriptionController = TextEditingController(text: s?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceCubit, ServiceState>(
      listenWhen: (_, current) =>
          current is ServiceOperationSuccess || current is ServiceMutationError,
      listener: _onServiceCubitChange,
      child: BlocBuilder<ServiceFormCubit, ServiceFormState>(
        builder: (context, formState) {
          final isLoading =
              context.watch<ServiceCubit>().state is ServiceLoading;
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: FormAppBar(
              title: _isEditMode ? 'Edit Service' : 'Add Service',
              onBack: () => context.pop(),
            ),
            bottomNavigationBar: FormActionBar(
              label: 'Save Service',
              onSave: _onSave,
              isLoading: isLoading,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ServiceMainCard(
                      nameController: _nameController,
                      priceController: _priceController,
                      descriptionController: _descriptionController,
                      duration: formState.duration,
                      margin: formState.margin,
                      onDurationDecrement:
                          formState.duration > ServiceFormCubit.durationMin
                          ? context.read<ServiceFormCubit>().decrementDuration
                          : null,
                      onDurationIncrement:
                          formState.duration < ServiceFormCubit.durationMax
                          ? context.read<ServiceFormCubit>().incrementDuration
                          : null,
                      onMarginDecrement:
                          formState.margin > ServiceFormCubit.marginMin
                          ? context.read<ServiceFormCubit>().decrementMargin
                          : null,
                      onMarginIncrement:
                          formState.margin < ServiceFormCubit.marginMax
                          ? context.read<ServiceFormCubit>().incrementMargin
                          : null,
                    ),
                    const SizedBox(height: 16),
                    ServiceSettingsCard(
                      isActive: formState.isActive,
                      onChanged: context.read<ServiceFormCubit>().setActive,
                    ),
                    if (_isEditMode) ...[
                      const SizedBox(height: 16),
                      _buildDangerZone(),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onServiceCubitChange(BuildContext context, ServiceState state) {
    if (state is ServiceOperationSuccess) {
      AppSnackBar.showSuccess(
        context,
        _isEditMode
            ? 'Service updated successfully'
            : 'Service added successfully',
      );
      if (mounted) context.pop();
    } else if (state is ServiceMutationError) {
      AppSnackBar.showError(context, state.message);
    }
  }

  Widget _buildDangerZone() {
    return Center(
      child: TextButton.icon(
        onPressed: _onDelete,
        icon: const Icon(Icons.delete_outline_rounded, size: 18),
        label: const Text('Delete Service'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red[600],
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated || authState.user.organizationId == null) {
      AppSnackBar.showError(context, 'Unable to determine organization');
      return;
    }

    final formState = context.read<ServiceFormCubit>().state;
    final orgId = authState.user.organizationId!;
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    if (_isEditMode) {
      context.read<ServiceCubit>().updateService(
        ServiceEntity(
          id: widget.service!.id,
          orgId: widget.service!.orgId,
          name: name,
          durationMinutes: formState.duration,
          timeMarginMinutes: formState.margin,
          isActive: formState.isActive,
          createdAt: widget.service!.createdAt,
          price: price,
          description: description,
        ),
      );
    } else {
      context.read<ServiceCubit>().createService(
        ServiceEntity(
          id: '',
          orgId: orgId,
          name: name,
          durationMinutes: formState.duration,
          timeMarginMinutes: formState.margin,
          isActive: formState.isActive,
          createdAt: DateTime.now(),
          price: price,
          description: description,
        ),
      );
    }
  }

  Future<void> _onDelete() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated || authState.user.organizationId == null) {
      return;
    }
    final orgId = authState.user.organizationId!;
    final cubit = context.read<ServiceCubit>();

    final confirmed = await showDeleteConfirmationDialog(
      context,
      title: 'Delete Service',
      itemName: widget.service!.name,
    );

    if (confirmed && mounted) {
      cubit.deleteService(orgId: orgId, serviceId: widget.service!.id);
    }
  }
}
