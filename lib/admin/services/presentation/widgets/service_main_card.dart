import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// The primary form card containing name, duration, margin, price, and
/// description fields.
class ServiceMainCard extends StatelessWidget {
  const ServiceMainCard({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.descriptionController,
    required this.duration,
    required this.margin,
    required this.onDurationDecrement,
    required this.onDurationIncrement,
    required this.onMarginDecrement,
    required this.onMarginIncrement,
  });

  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final int duration;
  final int margin;
  final VoidCallback? onDurationDecrement;
  final VoidCallback? onDurationIncrement;
  final VoidCallback? onMarginDecrement;
  final VoidCallback? onMarginIncrement;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormFieldLabel(text: 'Service Name'),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            style: AppTextStyles.bodyLarge,
            decoration: appFieldDecoration(
              hintText: 'e.g. General Consultation',
            ),
            validator: (value) {
              final v = value?.trim() ?? '';
              if (v.isEmpty) return 'Service name is required';
              if (v.length > 100) return 'Name must not exceed 100 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),
          NumericStepperRow(
            icon: Icons.timer_rounded,
            title: 'Duration',
            subtitle: 'How long is the session?',
            value: duration,
            unit: 'min',
            onDecrement: onDurationDecrement,
            onIncrement: onDurationIncrement,
          ),
          const SizedBox(height: 8),
          NumericStepperRow(
            icon: Icons.history_rounded,
            title: 'Time Margin',
            subtitle: 'Buffer between slots',
            value: margin,
            unit: 'min',
            onDecrement: onMarginDecrement,
            onIncrement: onMarginIncrement,
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.outline.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: 20),
          const FormFieldLabel(text: r'Price ($)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: AppTextStyles.bodyLarge,
            decoration: appFieldDecoration(hintText: 'Optional').copyWith(
              prefixText: '\$ ',
              prefixStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final v = double.tryParse(value);
              if (v == null || v < 0) return 'Enter a valid non-negative price';
              return null;
            },
          ),
          const SizedBox(height: 20),
          const FormFieldLabel(text: 'Description'),
          const SizedBox(height: 8),
          TextFormField(
            controller: descriptionController,
            maxLines: 4,
            maxLength: 500,
            style: AppTextStyles.bodyLarge,
            decoration: appFieldDecoration(
              hintText: 'Optional description for your customers',
            ),
          ),
        ],
      ),
    );
  }
}
