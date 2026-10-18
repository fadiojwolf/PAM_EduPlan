import 'package:flutter/material.dart';
import '../models/assignment.dart';

/// Бейдж статуса задания. Цвета берутся из ColorScheme, а не зашиты в код.
class StatusBadge extends StatelessWidget {
  final AssignmentStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (status) {
      AssignmentStatus.todo => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant
        ),
      AssignmentStatus.inProgress => (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer
        ),
      AssignmentStatus.done => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
      ),
    );
  }
}
