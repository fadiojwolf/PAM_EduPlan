import 'package:flutter/material.dart';
import '../models/assignment.dart';
import 'status_badge.dart';

/// Карточка задания. Используется на экранах «Задания» и «Карточка курса».
/// Чекбокс — отметка выполнения (колбэк приходит от экрана).
class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final String? courseName; // показываем, только если передан
  final VoidCallback? onTap;
  final VoidCallback? onToggleDone;

  const AssignmentCard({
    super.key,
    required this.assignment,
    this.courseName,
    this.onTap,
    this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = assignment.status == AssignmentStatus.done;
    final priorityColor = switch (assignment.priority) {
      Priority.high => scheme.error,
      Priority.medium => scheme.tertiary,
      Priority.low => scheme.outline,
    };

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: done,
          onChanged: onToggleDone == null ? null : (_) => onToggleDone!(),
        ),
        title: Text(
          assignment.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: done
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: scheme.onSurfaceVariant,
                )
              : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (courseName != null)
              Text(courseName!, maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(
              children: [
                Icon(Icons.flag, size: 16, color: priorityColor),
                const SizedBox(width: 4),
                Text('до ${formatDeadline(assignment.deadline)}'),
              ],
            ),
          ],
        ),
        trailing: StatusBadge(status: assignment.status),
      ),
    );
  }
}
