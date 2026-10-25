import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../models/assignment.dart';
import '../widgets/confirm_dialog.dart';

/// Форма нового задания / редактирования. Функциональна локально:
/// валидирует, подтверждает SnackBar-ом и закрывается. Данные не сохраняются
/// (состояние приходит на L4).
class AssignmentFormScreen extends StatefulWidget {
  final int? assignmentId; // не null → режим редактирования
  final int? initialCourseId; // предвыбранный курс (из query-параметра)

  const AssignmentFormScreen({
    super.key,
    this.assignmentId,
    this.initialCourseId,
  });

  @override
  State<AssignmentFormScreen> createState() => _AssignmentFormScreenState();
}

class _AssignmentFormScreenState extends State<AssignmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  int? _courseId;
  DateTime? _deadline;
  Priority _priority = Priority.medium;

  bool get _isEdit => widget.assignmentId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      // Экран сам ищет объект по id из адреса.
      final a = assignmentById(widget.assignmentId!);
      _titleCtrl.text = a.title;
      _courseId = a.courseId;
      _deadline = a.deadline;
      _deadlineCtrl.text = formatDeadline(a.deadline);
      _priority = a.priority;
    } else {
      _courseId = widget.initialCourseId;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); // кто создаёт, тот освобождает
    _deadlineCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 1);
    final last = DateTime(now.year + 3);
    var initial = _deadline ?? now.add(const Duration(days: 1));
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    // Прошлые даты выбираемы намеренно: валидатор должен их отклонять.
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _deadline = picked;
      _deadlineCtrl.text = formatDeadline(picked);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return; // ошибки уже на экране
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEdit
              ? 'Изменения сохранены: ${_titleCtrl.text.trim()}'
              : 'Задание добавлено: ${_titleCtrl.text.trim()}',
        ),
      ),
    );
    context.pop(); // открыто push-ем → закрывается pop-ом
  }

  Future<void> _delete() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Удалить задание?',
      message: _titleCtrl.text.trim(),
      confirmLabel: 'Да, удалить',
    );
    if (!ok || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Задание удалено')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Редактирование задания' : 'Новое задание'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Удалить',
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              inputFormatters: [LengthLimitingTextInputFormatter(80)],
              decoration: const InputDecoration(
                labelText: 'Название задания',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Название обязательно'
                  : null, // null = валидно
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _courseId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Курс',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in mockCourses)
                  DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) => _courseId = value,
              validator: (value) => value == null ? 'Выберите курс' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _deadlineCtrl,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: 'Дедлайн',
                hintText: 'Выберите дату',
                suffixIcon: Icon(Icons.calendar_month),
                border: OutlineInputBorder(),
              ),
              validator: (_) {
                final d = _deadline;
                if (d == null) return 'Выберите дедлайн';
                if (!d.isAfter(DateTime.now())) {
                  return 'Дедлайн должен быть в будущем';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text('Приоритет', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<Priority>(
              segments: [
                for (final p in Priority.values)
                  ButtonSegment(value: p, label: Text(p.label)),
              ],
              selected: {_priority},
              onSelectionChanged: (s) => setState(() => _priority = s.first),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Text(_isEdit ? 'Сохранить изменения' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
