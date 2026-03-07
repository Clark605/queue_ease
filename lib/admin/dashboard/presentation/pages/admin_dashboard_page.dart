import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:queue_ease/shared/auth/presentation/cubit/auth_cubit.dart';

import '../../../../core/app/router/app_router.dart';
import '../../../../core/app/theme/app_text_styles.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, Admin', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _DashboardCard(
                    icon: Icons.business,
                    label: 'Organization',
                    onTap: () => context.push(Routes.adminOrgProfile),
                  ),
                  _DashboardCard(
                    icon: Icons.medical_services_outlined,
                    label: 'Services',
                    onTap: () => context.push(Routes.adminServices),
                  ),
                  const _DashboardCard(
                    icon: Icons.access_time,
                    label: 'Working Hours',
                  ),
                  const _DashboardCard(icon: Icons.queue, label: 'Queue'),
                  const _DashboardCard(
                    icon: Icons.qr_code,
                    label: 'Share Access',
                  ),
                  const _DashboardCard(
                    icon: Icons.bar_chart,
                    label: 'Daily Summary',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap:
            onTap ??
            () {
              // Show coming soon message for unimplemented features
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label - Coming soon'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
