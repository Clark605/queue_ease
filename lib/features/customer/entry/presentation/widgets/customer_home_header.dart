import 'package:flutter/material.dart';

/// Top header row replacing the Flutter AppBar.
///
/// Shows the menu icon (placeholder for Phase 9 navigation drawer), the
/// centered app name, and a notification bell with an unread indicator dot.
/// [onSignOut] is threaded through for Phase 9 to wire into the menu.
class CustomerHomeHeader extends StatelessWidget {
  const CustomerHomeHeader({super.key, required this.onSignOut});

  // Carried for Phase 9 — will be connected to the navigation drawer menu.
  // ignore: unused_field
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(4, topPadding + 4, 4, 4),
      child: Row(
        children: [
          const IconButton(
            icon: Icon(Icons.menu),
            onPressed: null, // Phase 9 — navigation drawer
          ),
          const Expanded(
            child: Text(
              'QueueEase',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const IconButton(
                icon: Icon(Icons.notifications_outlined),
                onPressed: null, // Phase 9 — notifications panel
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
