import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_snack_bar.dart';
import '../cubit/organization_cubit.dart';
import '../cubit/organization_state.dart';
import '../widgets/organization_profile_form.dart';

/// Organization profile edit page.
///
/// Allows editing of mutable organization fields:
/// - name, address, description, logoUrl
///
/// Immutable fields (adminUid, bookingLinkSlug, createdAt) are preserved.
///
/// Stitch reference: Derived from Organization Landing Screen Variant 3
/// with form fields replacing read-only displays.
class OrganizationProfileEditPage extends StatefulWidget {
  const OrganizationProfileEditPage({super.key});

  @override
  State<OrganizationProfileEditPage> createState() =>
      _OrganizationProfileEditPageState();
}

class _OrganizationProfileEditPageState
    extends State<OrganizationProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _formWidgetKey = GlobalKey<OrganizationProfileFormState>();

  bool _isSaving = false;

  void _onSave() {
    final state = context.read<OrganizationCubit>().state;

    if (state is! OrganizationLoaded) {
      AppSnackBar.showError(context, 'Organization data not loaded');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get updated organization from form
    final updatedOrg = _formWidgetKey.currentState!.getOrganization();

    // Trigger update via cubit
    setState(() => _isSaving = true);
    context.read<OrganizationCubit>().updateOrganization(updatedOrg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<OrganizationCubit, OrganizationState>(
        listener: (context, state) {
          if (state is OrganizationError) {
            _isSaving = false;
            AppSnackBar.showError(context, state.message);
          }

          if (state is OrganizationLoaded && _isSaving) {
            _isSaving = false;
            AppSnackBar.showSuccess(context, 'Profile updated successfully');

            // Pop back to profile page
            Future.delayed(const Duration(milliseconds: 500), () {});
            if (mounted) {
              context.pop();
            }
          }
        },
        builder: (context, state) {
          if (state is OrganizationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrganizationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Error', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is OrganizationLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Information card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Update your organization details below',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form
                  OrganizationProfileForm(
                    key: _formWidgetKey,
                    formKey: _formKey,
                    initialOrganization: state.organization,
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save),
                        const SizedBox(width: 8),
                        Text(
                          'Save Changes',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cancel Button
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
