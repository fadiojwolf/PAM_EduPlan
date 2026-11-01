import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../models/course_model.dart';
import '../widgets/course_card.dart';
import '../widgets/error_view.dart';
import '../widgets/filter_chips_row.dart';

/// Список курсов: поиск + фильтр по дню недели.
/// Данные — в CourseModel (разделяемое), а текст поиска и выбранный день —
/// эфемерное состояние экрана (setState).
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  static const _dayLabels = ['Все', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт'];

  String _query = '';
  int _dayIndex = 0; // 0 = все дни, 1..5 = пн..пт (совпадает с weekday)

  List<Course> _filter(List<Course> all) {
    return all.where((c) {
      final matchesDay = _dayIndex == 0 || c.weekday == _dayIndex;
      final matchesQuery = _query.isEmpty ||
          c.name.toLowerCase().contains(_query) ||
          c.teacher.toLowerCase().contains(_query);
      return matchesDay && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CourseModel>();

    final Widget body;
    if (model.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (model.error != null) {
      body = ErrorView(
        message: model.error!,
        onRetry: () => context.read<CourseModel>().load(),
      );
    } else {
      final courses = _filter(model.courses);
      body = courses.isEmpty
          ? const Center(child: Text('Ничего не найдено'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final course = courses[index];
                return CourseCard(
                  key: ValueKey(course.id),
                  course: course,
                  showWeekday: true,
                  onTap: () => context.push('/courses/${course.id}'),
                );
              },
            );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Курсы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: () => context.read<CourseModel>().load(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Поиск курса или преподавателя',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
              ),
            ),
          ),
          FilterChipsRow(
            labels: _dayLabels,
            selectedIndex: _dayIndex,
            onSelected: (i) => setState(() => _dayIndex = i),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
