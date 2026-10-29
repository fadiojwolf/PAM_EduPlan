import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../models/assignment.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/info_row.dart';

/// Профиль пользователя + выход с подтверждением.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Выйти из аккаунта?',
      confirmLabel: 'Да, выйти',
    );
    // После await context используется только под context.mounted.
    if (ok && context.mounted) {
      context.go('/login'); // go: раздел с вкладками уходит из стека
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final total = mockAssignments.length;
    final done = mockAssignments
        .where((a) => a.status == AssignmentStatus.done)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                'ZD',
                style: textTheme.headlineMedium
                    ?.copyWith(color: scheme.onPrimaryContainer),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text('Zgurski Dmitri', style: textTheme.headlineSmall)),
          Center(
            child: Text(
              'Студент, группа CR-232',
              style: textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Выполнено $done из $total заданий',
                      style: textTheme.titleMedium),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: done / total,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.email_outlined,
                    label: 'E-mail',
                    value: 'dmitri.zgurski@iis.utm.md',
                  ),
                  InfoRow(
                    icon: Icons.groups_outlined,
                    label: 'Группа',
                    value: 'CR-232',
                  ),
                  InfoRow(
                    icon: Icons.account_balance_outlined,
                    label: 'Университет',
                    value: 'Технический университет Молдовы',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
