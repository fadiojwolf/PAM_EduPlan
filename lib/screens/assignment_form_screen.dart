import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/assignment.dart';
import '../models/course.dart';

/// Форма нового задания / редактирования — только макет, без валидации
/// и сохранения (это материал L3–L4).
class AssignmentFormScreen extends StatelessWidget {
  final Course? course; // предвыбранный курс (если открыли из карточки курса)

  const AssignmentFormScreen({super.key, this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новое задание')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              labelText: 'Название задания',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownMenu<int>(
            initialSelection: course?.id ?? mockCourses.first.id,
            label: const Text('Курс'),
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: [
              for (final c in mockCourses)
                DropdownMenuEntry(value: c.id, label: c.name),
            ],
            onSelected: (_) {},
          ),
          const SizedBox(height: 16),
          const TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Дедлайн',
              hintText: 'ДД.ММ.ГГГГ',
              suffixIcon: Icon(Icons.calendar_month),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Text('Приоритет', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<Priority>(
            segments: [
              for (final p in Priority.values)
                ButtonSegment(value: p, label: Text(p.label)),
            ],
            selected: const {Priority.medium},
            onSelectionChanged: (_) {},
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {},
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
