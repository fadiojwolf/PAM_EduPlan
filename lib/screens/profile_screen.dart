import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock_network.dart';
import '../models/assignment_model.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/info_row.dart';

/// Профиль: статистика заданий (из модели), выход с подтверждением и
/// переключатель аварии для демонстрации экрана ошибки.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Эфемерное состояние → setState (положение переключателя).
  late bool _simulateError;

  @override
  void initState() {
    super.initState();
    _simulateError = context.read<MockNetwork>().simulateError;
  }

  Future<void> _logout() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Выйти из аккаунта?',
      confirmLabel: 'Да, выйти',
    );
    if (ok && mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final model = context.watch<AssignmentModel>();

    final Widget stats;
    if (model.isLoading) {
      stats = const Center(child: CircularProgressIndicator());
    } else if (model.error != null) {
      stats = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(model.error!, style: textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.read<AssignmentModel>().load(),
            child: const Text('Повторить'),
          ),
        ],
      );
    } else {
      final done = model.doneCount;
      final total = model.totalCount;
      stats = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Выполнено $done из $total заданий',
              style: textTheme.titleMedium),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: total == 0 ? 0 : done / total,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }

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
              child: stats,
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
          const SizedBox(height: 8),
          // Леса демонстрации: единственное место UI, знающее о mock-е.
          Card(
            child: SwitchListTile(
              title: const Text('Симулировать сбой сети'),
              subtitle: const Text('Для демонстрации экрана ошибки'),
              value: _simulateError,
              onChanged: (value) {
                setState(() => _simulateError = value);
                context.read<MockNetwork>().simulateError = value;
              },
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
