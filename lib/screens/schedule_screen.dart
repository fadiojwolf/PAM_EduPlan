import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/course_model.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';

/// Недельное расписание: пары, сгруппированные по дням недели.
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CourseModel>(); // watch в build

    final Widget body;
    if (model.isLoading) {
      body = const Center(child: CircularProgressIndicator()); // 1) грузится
    } else if (model.error != null) {
      body = ErrorView(
        message: model.error!, // 2) упало
        onRetry: () => context.read<CourseModel>().load(), // read: действие
      );
    } else {
      body = _buildList(context, model.courses); // 3) данные
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание на неделю'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: () => context.read<CourseModel>().load(),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget _buildList(BuildContext context, List<Course> courses) {
    final scheme = Theme.of(context).colorScheme;

    // Плоский список: int — заголовок дня, Course — карточка пары.
    final items = <Object>[];
    for (var day = 1; day <= 7; day++) {
      final dayCourses = courses.where((c) => c.weekday == day).toList()
        ..sort((a, b) {
          final byTime = a.startTime.compareTo(b.startTime);
          return byTime != 0 ? byTime : a.id.compareTo(b.id);
        });
      if (dayCourses.isEmpty) continue;
      items.add(day);
      items.addAll(dayCourses);
    }

    return ListView.builder(
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
          key: ValueKey(course.id),
          course: course,
          onTap: () => context.push('/schedule/course/${course.id}'),
        );
      },
    );
  }
}
