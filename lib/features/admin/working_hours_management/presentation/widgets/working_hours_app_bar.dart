import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// AppBar for the Working Hours configuration page.
class WorkingHoursAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const WorkingHoursAppBar({super.key});

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
        icon: const Icon(Icons.chevron_left),
        color: AppColors.primary,
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Working Hours',
        style: AppTextStyles.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
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
