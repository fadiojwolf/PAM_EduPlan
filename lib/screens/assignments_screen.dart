import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/assignment_card.dart';
import '../widgets/filter_chips_row.dart';
import 'assignment_form_screen.dart';

/// Список заданий: фильтр по статусу и по сроку (визуально).
class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [...mockAssignments]
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Scaffold(
      appBar: AppBar(title: const Text('Задания')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AssignmentFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Новое задание'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          const FilterChipsRow(
            labels: ['Все', 'К выполнению', 'В процессе', 'Выполнено'],
          ),
          const FilterChipsRow(
            labels: ['Любой срок', 'На этой неделе', 'Просроченные'],
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final a = items[index];
                return AssignmentCard(
                  assignment: a,
                  courseName: courseById(a.courseId).name,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
