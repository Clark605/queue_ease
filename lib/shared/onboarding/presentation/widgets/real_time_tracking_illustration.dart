import 'package:flutter/material.dart';

import '../../../../core/app/theme/app_colors.dart';

/// Illustration for the "Real-Time Tracking" onboarding page.
///
/// Shows a phone mockup with queue list items and a notification bell,
/// highlighting position #5 as the active user.
class RealTimeTrackingIllustration extends StatelessWidget {
  const RealTimeTrackingIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final phoneWidth = constraints.maxWidth * 0.62;
          final phoneHeight = constraints.maxHeight * 0.9;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Phone frame.
              Container(
                width: phoneWidth,
                height: phoneHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.grey.shade200, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(29),
                  child: Column(
                    children: [
                      // Status bar mockup.
                      _StatusBar(),
                      const SizedBox(height: 8),
                      // Queue items.
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 10,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _QueueItem(
                                number: '#4',
                                isActive: false,
                                isFaded: true,
                              ),
                              const SizedBox(height: 8),
                              _QueueItem(
                                number: '#5',
                                isActive: true,
                                isFaded: false,
                              ),
                              const SizedBox(height: 8),
                              _QueueItem(
                                number: '#6',
                                isActive: false,
                                isFaded: false,
                              ),
                              const SizedBox(height: 8),
                              _QueueItem(
                                number: '#7',
                                isActive: false,
                                isFaded: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Notification bell floating badge.
              Positioned(
                right: (constraints.maxWidth - phoneWidth) / 2 - 4,
                top: constraints.maxHeight * 0.12,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 6,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Row(children: [_dot(), const SizedBox(width: 4), _dot()]),
        ],
      ),
    );
  }

  Widget _dot() {
    return Container(
      height: 6,
      width: 6,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  const _QueueItem({
    required this.number,
    required this.isActive,
    required this.isFaded,
  });

  final String number;
  final bool isActive;
  final bool isFaded;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isFaded ? 0.4 : 1.0,
      child: Transform.scale(
        scale: isActive ? 1.05 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.grey.shade100,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Accent bar for active.
              if (isActive)
                Container(
                  width: 3,
                  height: 28,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

              // Number badge.
              Container(
                height: isActive ? 36 : 28,
                width: isActive ? 36 : 28,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.grey.shade100,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: isActive ? 12 : 10,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Placeholder lines.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: isActive ? 8 : 6,
                      width: isActive ? 80 : 60,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.onSurface
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    if (isActive || isFaded) ...[
                      const SizedBox(height: 4),
                      Container(
                        height: 5,
                        width: isActive ? 55 : 40,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.grey.shade400
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(
                width: isActive ? 20 : 0,
                child: isActive
                    ? Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.primary,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
