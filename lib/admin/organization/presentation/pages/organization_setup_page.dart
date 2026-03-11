import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/error/result.dart';
import '../../../../shared/auth/presentation/cubit/auth_cubit.dart';
import '../../../../shared/auth/presentation/cubit/auth_state.dart';
import '../../domain/repositories/admin_organization_repository.dart';

/// Shown to newly registered admin users whose account is not yet linked to
/// an organization.
///
/// On submit, creates the organization document atomically in Firestore (org
/// doc + user.organizationId update via WriteBatch), then refreshes the auth
/// state so the router redirects to the admin dashboard.
class OrganizationSetupPage extends StatefulWidget {
  const OrganizationSetupPage({super.key});

  @override
  State<OrganizationSetupPage> createState() => _OrganizationSetupPageState();
}

class _OrganizationSetupPageState extends State<OrganizationSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final orgRepo = getIt<AdminOrganizationRepository>();
    final result = await orgRepo.createOrganization(
      adminUid: authState.user.uid,
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    switch (result) {
      case Success():
        // Refresh the auth state so the router picks up the new organizationId
        // and redirects to the dashboard.
        await context.read<AuthCubit>().refreshCurrentUser();
      case Failure(:final exception):
        setState(() {
          _isSubmitting = false;
          _errorMessage = exception.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Brand header ────────────────────────────────────────
                    Icon(
                      Icons.business_outlined,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Set up your organization',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is the name your customers will see when they '
                      'book with you.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // ── Org name field ───────────────────────────────────────
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) =>
                          _isSubmitting ? null : _onSubmit(),
                      decoration: InputDecoration(
                        labelText: 'Organization name',
                        hintText: 'e.g. Sunrise Clinic',
                        prefixIcon: const Icon(Icons.store_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Organization name cannot be empty.';
                        }
                        if (trimmed.length > 100) {
                          return 'Name must be 100 characters or fewer.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // ── Inline error message ─────────────────────────────────
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── Submit button ────────────────────────────────────────
                    FilledButton(
                      onPressed: _isSubmitting ? null : _onSubmit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Create organization',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
