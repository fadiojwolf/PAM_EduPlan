import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/assignment.dart';
import '../models/assignment_model.dart';
import '../models/course_model.dart';
import '../widgets/assignment_actions.dart';
import '../widgets/assignment_card.dart';
import '../widgets/error_view.dart';
import '../widgets/filter_chips_row.dart';

/// Список заданий: фильтры по статусу и сроку, сортировка по сроку,
/// отметка выполнения. Данные и сортировка — в модели (разделяемое),
/// выбранные чипы — эфемерное состояние экрана.
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  static const _statusLabels = [
    'Все',
    'К выполнению',
    'В процессе',
    'Выполнено',
  ];
  static const _deadlineLabels = [
    'Любой срок',
    'На этой неделе',
    'Просроченные',
  ];

  int _statusIndex = 0;
  int _deadlineIndex = 0;

  List<Assignment> _filter(List<Assignment> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));

    return all.where((a) {
      final matchesStatus = switch (_statusIndex) {
        1 => a.status == AssignmentStatus.todo,
        2 => a.status == AssignmentStatus.inProgress,
        3 => a.status == AssignmentStatus.done,
        _ => true,
      };
      final matchesDeadline = switch (_deadlineIndex) {
        1 => !a.deadline.isBefore(today) && a.deadline.isBefore(weekEnd),
        2 => a.deadline.isBefore(today) && a.status != AssignmentStatus.done,
        _ => true,
      };
      return matchesStatus && matchesDeadline;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AssignmentModel>();
    final courses = context.watch<CourseModel>();

    final Widget body;
    if (model.isLoading) {
      body = const Center(child: CircularProgressIndicator()); // 1) грузится
    } else if (model.error != null) {
      body = ErrorView(
        message: model.error!, // 2) упало
        onRetry: () => context.read<AssignmentModel>().load(),
      );
    } else {
      final items = _filter(model.items); // 3) данные
      body = items.isEmpty
          ? const Center(child: Text('Нет заданий по выбранным фильтрам'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final a = items[index];
                return AssignmentCard(
                  key: ValueKey(a.id), // идентичность из данных
                  assignment: a,
                  courseName: courses.byId(a.courseId)?.name,
                  onTap: () => context.push('/assignments/${a.id}'),
                  onToggleDone: () => toggleAssignmentDone(context, a),
                );
              },
            );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Задания'),
        actions: [
          IconButton(
            icon: Icon(
              model.sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            tooltip: model.sortAscending
                ? 'Сначала ближайшие дедлайны'
                : 'Сначала дальние дедлайны',
            onPressed: () => context.read<AssignmentModel>().toggleSort(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: () => context.read<AssignmentModel>().load(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/assignments/new'),
        icon: const Icon(Icons.add),
        label: const Text('Новое задание'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          FilterChipsRow(
            labels: _statusLabels,
            selectedIndex: _statusIndex,
            onSelected: (i) => setState(() => _statusIndex = i),
          ),
          FilterChipsRow(
            labels: _deadlineLabels,
            selectedIndex: _deadlineIndex,
            onSelected: (i) => setState(() => _deadlineIndex = i),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
