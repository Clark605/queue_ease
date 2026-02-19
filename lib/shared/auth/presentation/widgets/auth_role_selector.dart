import 'package:flutter/material.dart';

import '../../../../core/app/theme/app_colors.dart';
import '../../../../core/app/theme/app_text_styles.dart';
import '../../domain/entities/user_role.dart';

/// Segmented control used on the Sign-Up screen to choose a role.
///
/// Uses a single sliding pill that moves between segments, giving a smooth
/// native-feeling animation instead of two independent fading backgrounds.
class AuthRoleSelector extends StatelessWidget {
  const AuthRoleSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final UserRole value;
  final ValueChanged<UserRole>? onChanged;

  static const _duration = Duration(milliseconds: 240);
  static const _curve = Curves.easeInOut;
  static const _padding = 4.0;

  @override
  Widget build(BuildContext context) {
    final isCustomer = value == UserRole.customer;

    return Semantics(
      label: 'Select your role',
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(_padding),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        // LayoutBuilder gives the exact inner width so the pill fits precisely.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pillWidth = constraints.maxWidth / 2;

            return Stack(
              children: [
                // ── Sliding pill (rendered below labels) ───────────────────
                AnimatedAlign(
                  duration: _duration,
                  curve: _curve,
                  alignment: isCustomer
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: pillWidth,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Tap areas + labels (rendered above pill) ───────────────
                Row(
                  children: [
                    _Segment(
                      icon: Icons.person_rounded,
                      label: 'Customer',
                      isSelected: isCustomer,
                      duration: _duration,
                      curve: _curve,
                      onTap: () => onChanged?.call(UserRole.customer),
                    ),
                    _Segment(
                      icon: Icons.store_rounded,
                      label: 'Business Admin',
                      isSelected: !isCustomer,
                      duration: _duration,
                      curve: _curve,
                      onTap: () => onChanged?.call(UserRole.admin),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.duration,
    required this.curve,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Duration duration;
  final Curve curve;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon color animates independently via TweenAnimationBuilder.
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  begin: isSelected
                      ? AppColors.onSurfaceVariant
                      : AppColors.primary,
                  end: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
                duration: duration,
                curve: curve,
                builder: (_, color, _) => Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(
                    begin: isSelected
                        ? AppColors.onSurfaceVariant
                        : AppColors.primary,
                    end: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                  duration: duration,
                  curve: curve,
                  builder: (_, color, _) => Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: color,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
