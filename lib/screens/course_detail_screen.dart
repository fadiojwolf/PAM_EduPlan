import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/assignment_model.dart';
import '../models/course.dart';
import '../models/course_model.dart';
import '../widgets/assignment_actions.dart';
import '../widgets/assignment_card.dart';
import '../widgets/error_view.dart';
import '../widgets/info_row.dart';

/// Карточка курса: экран получает только id и ищет курс через модель.
class CourseDetailScreen extends StatelessWidget {
  final int id;

  const CourseDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final courses = context.watch<CourseModel>();
    final assignments = context.watch<AssignmentModel>();
    final course = courses.byId(id);

    // null имеет два смысла: «ещё грузится» / «ошибка» / «не существует».
    if (course == null) {
      final Widget body;
      if (courses.isLoading) {
        body = const Center(child: CircularProgressIndicator());
      } else if (courses.error != null) {
        body = ErrorView(
          message: courses.error!,
          onRetry: () => context.read<CourseModel>().load(),
        );
      } else {
        body = const Center(child: Text('Курс не существует'));
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Карточка курса')),
        body: body,
      );
    }

    // Секция заданий — свои три состояния.
    final Widget assignmentsSection;
    if (assignments.isLoading) {
      assignmentsSection = const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (assignments.error != null) {
      assignmentsSection = ErrorView(
        message: assignments.error!,
        onRetry: () => context.read<AssignmentModel>().load(),
      );
    } else {
      final related = assignments.forCourse(course.id);
      assignmentsSection = related.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Для этого курса заданий пока нет.'),
            )
          : Column(
              children: [
                for (final a in related)
                  AssignmentCard(
                    key: ValueKey(a.id),
                    assignment: a,
                    onTap: () => context.push('/assignments/${a.id}'),
                    onToggleDone: () => toggleAssignmentDone(context, a),
                  ),
              ],
            );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Карточка курса')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/assignments/new?courseId=${course.id}'),
        icon: const Icon(Icons.add),
        label: const Text('Задание'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(course.name, style: textTheme.headlineSmall),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.person_outline,
                    label: 'Преподаватель',
                    value: course.teacher,
                  ),
                  InfoRow(
                    icon: Icons.meeting_room_outlined,
                    label: 'Аудитория',
                    value: course.room,
                  ),
                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'День недели',
                    value: weekdayNames[course.weekday - 1],
                  ),
                  InfoRow(
                    icon: Icons.schedule,
                    label: 'Время',
                    value: '${course.startTime}–${course.endTime}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Задания по курсу', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          assignmentsSection,
          const SizedBox(height: 72), // место под FAB
        ],
      ),
    );
  }
}
