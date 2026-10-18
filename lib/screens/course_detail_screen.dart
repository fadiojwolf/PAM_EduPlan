import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/course.dart';
import '../widgets/assignment_card.dart';
import '../widgets/info_row.dart';
import 'assignment_form_screen.dart';

/// Карточка курса: преподаватель, аудитория, время и связанные задания.
class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final related =
        mockAssignments.where((a) => a.courseId == course.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Карточка курса')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AssignmentFormScreen(course: course),
          ),
        ),
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
          if (related.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Для этого курса заданий пока нет.'),
            )
          else
            ...related.map((a) => AssignmentCard(assignment: a)),
          const SizedBox(height: 72), // место под FAB
        ],
      ),
    );
  }
}
