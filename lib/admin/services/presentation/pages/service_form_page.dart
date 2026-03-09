import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/app/theme/app_colors.dart';
import '../../../../core/app/theme/app_text_styles.dart';
import '../../../../shared/auth/presentation/cubit/auth_cubit.dart';
import '../../../../shared/auth/presentation/cubit/auth_state.dart';
import '../../../../shared/organization/domain/entities/service_entity.dart';
import '../../../../shared/widgets/delete_confirmation_dialog.dart';
import '../cubit/service_cubit.dart';
import '../cubit/service_state.dart';
import '../widgets/service_form_app_bar.dart';
import '../widgets/service_form_bottom_bar.dart';
import '../widgets/service_main_card.dart';
import '../widgets/service_settings_card.dart';

/// Shared add / edit form for a [ServiceEntity].
///
/// Stitch references:
///   Add  — `eb5dc21cc1624d30877ae249112e941a`
///   Edit — `dd7e56c4ee974bc2a41b13443f8b0b75`
class ServiceFormPage extends StatefulWidget {
  const ServiceFormPage({super.key, this.service});

  final ServiceEntity? service;

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  late int _duration;
  late int _margin;
  late bool _isActive;

  bool get _isEditMode => widget.service != null;

  static const int _durationStep = 5;
  static const int _durationMin = 5;
  static const int _durationMax = 240;
  static const int _marginStep = 5;
  static const int _marginMin = 0;
  static const int _marginMax = 60;
  static const int _defaultDuration = 15;
  static const int _defaultMargin = 5;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameController = TextEditingController(text: s?.name ?? '');
    _priceController = TextEditingController(
      text: s?.price != null ? s!.price!.toStringAsFixed(2) : '',
    );
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _duration = s?.durationMinutes ?? _defaultDuration;
    _margin = s?.timeMarginMinutes ?? _defaultMargin;
    _isActive = s?.isActive ?? true;
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
      listenWhen: (previous, current) =>
          current is ServiceOperationSuccess || current is ServiceMutationError,
      listener: _onStateChange,
      child: BlocBuilder<ServiceCubit, ServiceState>(
        builder: (context, state) {
          final isLoading = state is ServiceLoading;
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: ServiceFormAppBar(
              isEditMode: _isEditMode,
              isLoading: isLoading,
              onSave: _onSave,
              onBack: () => context.pop(),
            ),
            bottomNavigationBar: ServiceFormBottomBar(
              isLoading: isLoading,
              onSave: _onSave,
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
                      duration: _duration,
                      margin: _margin,
                      onDurationDecrement: _duration > _durationMin
                          ? () => setState(() => _duration -= _durationStep)
                          : null,
                      onDurationIncrement: _duration < _durationMax
                          ? () => setState(() => _duration += _durationStep)
                          : null,
                      onMarginDecrement: _margin > _marginMin
                          ? () => setState(
                              () => _margin = (_margin - _marginStep).clamp(
                                _marginMin,
                                _marginMax,
                              ),
                            )
                          : null,
                      onMarginIncrement: _margin < _marginMax
                          ? () => setState(
                              () => _margin = (_margin + _marginStep).clamp(
                                _marginMin,
                                _marginMax,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    ServiceSettingsCard(
                      isActive: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
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

  void _onStateChange(BuildContext context, ServiceState state) {
    if (state is ServiceOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Service updated successfully'
                : 'Service added successfully',
          ),
          duration: const Duration(milliseconds: 1500),
        ),
      );
      // Delay pop to allow user to see the SnackBar
      Future.delayed(const Duration(milliseconds: 500), () {});
      if (mounted) context.pop();
    } else if (state is ServiceMutationError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red[600],
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to determine organization')),
      );
      return;
    }

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
          durationMinutes: _duration,
          timeMarginMinutes: _margin,
          isActive: _isActive,
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
          durationMinutes: _duration,
          timeMarginMinutes: _margin,
          isActive: _isActive,
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
