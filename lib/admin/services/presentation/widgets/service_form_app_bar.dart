import 'package:flutter/material.dart';

import '../../../../core/app/theme/app_colors.dart';
import '../../../../core/app/theme/app_text_styles.dart';

/// iOS-style AppBar for the service add/edit form.
///
/// Displays a back arrow on the leading side, the page title in the centre,
/// and a "Save" text action on the trailing side.
class ServiceFormAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ServiceFormAppBar({
    super.key,
    required this.isEditMode,
    required this.isLoading,
    required this.onSave,
    required this.onBack,
  });

  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onSave;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: AppColors.primary,
        onPressed: onBack,
      ),
      title: Text(
        isEditMode ? 'Edit Service' : 'Add Service',
        style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: isLoading ? null : onSave,
            child: Text(
              'Save',
              style: AppTextStyles.labelLarge.copyWith(
                color: isLoading ? AppColors.outline : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.outline.withValues(alpha: 0.4),
          height: 1,
        ),
      ),
    );
  }
}
