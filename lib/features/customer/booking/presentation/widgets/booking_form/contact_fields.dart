import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class ContactFields extends StatelessWidget {
  const ContactFields({
    super.key,
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
