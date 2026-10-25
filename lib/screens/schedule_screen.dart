import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../models/course.dart';
import '../widgets/course_card.dart';

/// Недельное расписание: пары, сгруппированные по дням недели.
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Плоский список: int — заголовок дня, Course — карточка пары.
    final items = <Object>[];
    for (var day = 1; day <= 7; day++) {
      final dayCourses = mockCourses.where((c) => c.weekday == day).toList()
        ..sort((a, b) {
          final byTime = a.startTime.compareTo(b.startTime);
          return byTime != 0 ? byTime : a.id.compareTo(b.id);
        });
      if (dayCourses.isEmpty) continue;
      items.add(day);
      items.addAll(dayCourses);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Расписание на неделю')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is int) {
            return Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                weekdayNames[item - 1],
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: scheme.primary),
              ),
            );
          }
          final course = item as Course;
          return CourseCard(
            course: course,
            // push: «зайду и вернусь». Путешествует только id.
            onTap: () => context.push('/schedule/course/${course.id}'),
          );
        },
      ),
    );
  }
}
