import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class EmptyInfoTiles extends StatelessWidget {
  const EmptyInfoTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;
        final tileWidth = isWide
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;
        final tiles = const [
          _InfoTileData(
            icon: Icons.flash_on,
            title: 'Book in seconds',
            description:
                'Reserve a spot with a few taps and get real-time updates.',
          ),
          _InfoTileData(
            icon: Icons.qr_code_2,
            title: 'Use a QR code or link',
            description:
                'Scan a code or open a link from your business to get started.',
          ),
          _InfoTileData(
            icon: Icons.notifications_active,
            title: 'Stay in control',
            description: 'Track your place in line and keep your day moving.',
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: tiles
              .map(
                (tile) => SizedBox(
                  width: tileWidth,
                  child: _InfoTile(data: tile),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _InfoTileData {
  const _InfoTileData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.data});

  final _InfoTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
