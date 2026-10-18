import 'package:flutter/material.dart';
import '../models/course.dart';

/// Карточка пары/курса. Используется на экранах «Расписание» и «Курсы».
class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;
  final bool showWeekday;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.showWeekday = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final place = showWeekday
        ? '${weekdayNames[course.weekday - 1]} · ауд. ${course.room}'
        : 'Ауд. ${course.room}';

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 56,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                course.startTime,
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                course.endTime,
                style: textTheme.labelSmall
                    ?.copyWith(color: scheme.onPrimaryContainer),
              ),
            ],
          ),
        ),
        title: Text(
          course.name,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(place, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(course.teacher, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      ),
    );
  }
}
