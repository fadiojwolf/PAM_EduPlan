import 'package:flutter/material.dart';
import '../models/assignment.dart';
import 'status_badge.dart';

/// Карточка задания. Используется на экранах «Задания» и «Карточка курса».
class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final String? courseName; // показываем, только если передан
  final VoidCallback? onTap;

  const AssignmentCard({
    super.key,
    required this.assignment,
    this.courseName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final priorityColor = switch (assignment.priority) {
      Priority.high => scheme.error,
      Priority.medium => scheme.tertiary,
      Priority.low => scheme.outline,
    };

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.flag, color: priorityColor),
        title: Text(
          assignment.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (courseName != null)
              Text(courseName!, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('до ${formatDeadline(assignment.deadline)}'),
          ],
        ),
        trailing: StatusBadge(status: assignment.status),
      ),
    );
  }
}
