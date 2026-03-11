import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/organization/domain/entities/organization_entity.dart';

/// Reusable form widget for creating and editing organization profiles.
///
/// This form contains fields for:
/// - Organization name (required, max 100 chars)
/// - Address (optional, max 200 chars)
/// - Description (optional, max 500 chars)
/// - Logo URL (optional)
///
/// Use [initialOrganization] to pre-populate fields for editing.
/// Call [validate] to trigger validation, and [getOrganization] to
/// retrieve the updated organization entity with form data.
class OrganizationProfileForm extends StatefulWidget {
  const OrganizationProfileForm({
    super.key,
    this.initialOrganization,
    required this.formKey,
  });

  /// Optional organization to pre-populate fields (for edit mode).
  final OrganizationEntity? initialOrganization;

  /// Form key provided by the parent to control validation.
  final GlobalKey<FormState> formKey;

  @override
  State<OrganizationProfileForm> createState() =>
      OrganizationProfileFormState();
}

class OrganizationProfileFormState extends State<OrganizationProfileForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _logoUrlController;

  @override
  void initState() {
    super.initState();
    final org = widget.initialOrganization;
    _nameController = TextEditingController(text: org?.name ?? '');
    _addressController = TextEditingController(text: org?.address ?? '');
    _descriptionController = TextEditingController(
      text: org?.description ?? '',
    );
    _logoUrlController = TextEditingController(text: org?.logoUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  /// Returns an [OrganizationEntity] with updated values from the form.
  ///
  /// Must be called after [validate] returns true.
  OrganizationEntity getOrganization() {
    final org = widget.initialOrganization!;
    return OrganizationEntity(
      id: org.id,
      name: _nameController.text.trim(),
      adminUid: org.adminUid,
      bookingLinkSlug: org.bookingLinkSlug,
      isOpen: org.isOpen,
      createdAt: org.createdAt,
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      logoUrl: _logoUrlController.text.trim().isEmpty
          ? null
          : _logoUrlController.text.trim(),
      qrCodeUrl: org.qrCodeUrl,
    );
  }

  /// Validates all form fields.
  bool validate() {
    return widget.formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Organization Name',
              hintText: 'Enter organization name',
              prefixIcon: Icon(Icons.business),
            ),
            style: AppTextStyles.bodyLarge,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Organization name is required';
              }
              if (value.trim().length > 100) {
                return 'Name must not exceed 100 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address (Optional)',
              hintText: 'Enter physical address',
              prefixIcon: Icon(Icons.location_on),
            ),
            style: AppTextStyles.bodyLarge,
            textCapitalization: TextCapitalization.words,
            maxLines: 2,
            validator: (value) {
              if (value != null && value.trim().length > 200) {
                return 'Address must not exceed 200 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Brief description of your organization',
              prefixIcon: Icon(Icons.description),
            ),
            style: AppTextStyles.bodyLarge,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 4,
            maxLength: 500,
            validator: (value) {
              if (value != null && value.trim().length > 500) {
                return 'Description must not exceed 500 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _logoUrlController,
            decoration: const InputDecoration(
              labelText: 'Logo URL (Optional)',
              hintText: 'https://example.com/logo.png',
              prefixIcon: Icon(Icons.image),
            ),
            style: AppTextStyles.bodyLarge,
            keyboardType: TextInputType.url,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                final uri = Uri.tryParse(value.trim());
                if (uri == null || !uri.hasScheme) {
                  return 'Please enter a valid URL';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
