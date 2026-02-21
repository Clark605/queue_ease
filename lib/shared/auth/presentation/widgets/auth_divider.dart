import 'package:flutter/material.dart';

import '../../../../core/app/theme/app_text_styles.dart';

/// Horizontal divider with a centred "or" label, used between primary and
/// OAuth sign-in options on auth screens.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: AppTextStyles.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
