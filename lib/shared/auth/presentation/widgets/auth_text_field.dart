import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/app/theme/app_colors.dart';
import '../../../../core/app/theme/app_text_styles.dart';

/// Styled text field used on authentication screens.
///
/// Renders a label above the input (matching the mockup's layout), with
/// optional [labelSuffix] for inline actions such as "Forgot password?".
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.labelSuffix,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.autofillHints,
    this.inputFormatters,
    this.focusNode,
    this.enabled = true,
  });

  final TextEditingController controller;

  /// Label shown above the input.
  final String label;

  /// Optional widget placed at the trailing edge of the label row (e.g. a
  /// "Forgot password?" link).
  final Widget? labelSuffix;

  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  /// When [true] the field renders as a password input.
  /// For a built-in show/hide toggle prefer [PasswordField] instead.
  final bool obscureText;

  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool enabled;

  static OutlineInputBorder _border(Color color, {double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.labelLarge),
            ?labelSuffix,
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: _border(AppColors.outline),
            enabledBorder: _border(AppColors.outline),
            focusedBorder: _border(AppColors.primary, width: 2),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, width: 2),
          ),
        ),
      ],
    );
  }
}

/// A password field with a built-in show / hide toggle.
///
/// Manages its own [_obscure] state so callers stay simple.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.labelSuffix,
    this.hintText,
    this.textInputAction,
    this.validator,
    this.autofillHints,
    this.focusNode,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final Widget? labelSuffix;
  final String? hintText;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final bool enabled;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: widget.controller,
      label: widget.label,
      labelSuffix: widget.labelSuffix,
      hintText: widget.hintText ?? 'Enter your password',
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      autofillHints: widget.autofillHints,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      obscureText: _obscure,
      prefixIcon: const Icon(Icons.lock_outline_rounded),
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.onSurfaceVariant,
          size: 20,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
        tooltip: _obscure ? 'Show password' : 'Hide password',
      ),
    );
  }
}
