import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/course_card.dart';
import '../widgets/filter_chips_row.dart';
import 'course_detail_screen.dart';

/// Список курсов: поиск + фильтр по дню недели (визуально).
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Курсы')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск курса или преподавателя',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
              ),
            ),
          ),
          const FilterChipsRow(
            labels: ['Все', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт'],
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockCourses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final course = mockCourses[index];
                return CourseCard(
                  course: course,
                  showWeekday: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseDetailScreen(course: course),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
