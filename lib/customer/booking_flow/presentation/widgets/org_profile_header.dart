import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/initials_avatar.dart';
import '../../../../shared/organization/domain/entities/organization_entity.dart';
import 'open_closed_badge.dart';

class OrgProfileHeader extends StatelessWidget {
  const OrgProfileHeader({
    super.key,
    required this.org,
    required this.isCurrentlyOpen,
  });

  final OrganizationEntity org;
  final bool isCurrentlyOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          _OrgLogo(logoUrl: org.logoUrl, name: org.name),
          const SizedBox(height: 16),
          Text(
            org.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (org.description != null) ...[
            const SizedBox(height: 4),
            Text(
              org.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          OpenClosedBadge(isOpen: isCurrentlyOpen),
        ],
      ),
    );
  }
}

class _OrgLogo extends StatelessWidget {
  const _OrgLogo({required this.logoUrl, required this.name});

  final String? logoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null) {
      return CircleAvatar(
        radius: 52,
        backgroundImage: NetworkImage(logoUrl!),
        backgroundColor: AppColors.outline,
      );
    }
    return InitialsAvatar(name: name, size: 104);
  }
}
