import 'package:flutter/material.dart';

import '../../../../core/app/theme/app_colors.dart';
import '../../../../core/app/theme/app_text_styles.dart';
import '../../../../shared/organization/domain/entities/service_entity.dart';

/// Card tile for a [ServiceEntity] in the admin service list.
///
/// Shows an initials avatar, service name + time subtitle, an inline active
/// toggle switch, and a more-vert popup with edit / delete actions.
///
/// Stitch reference: Services Management List
/// (screen ID: eb2781a9ff3646ef87decaf682022a32)
class ServiceListTile extends StatelessWidget {
  const ServiceListTile({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final ServiceEntity service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Called when the active switch is toggled.
  final VoidCallback onToggle;

  String get _initials {
    final parts = service.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: service.isActive ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            _InitialsAvatar(initials: _initials),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${service.durationMinutes} mins \u2022 '
                    '${service.timeMarginMinutes} mins margin',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Switch(
              value: service.isActive,
              activeColor: AppColors.primary,
              onChanged: (_) => onToggle(),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: Colors.red[600])),
                    ],
                  ),
                ),
              ],
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
