import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/assignment.dart';
import '../models/assignment_model.dart';
import '../models/course_model.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_view.dart';

/// Обёртка: сначала убеждается, что данные есть (три состояния), и только
/// потом строит саму форму. Режим редактирования ищет задание по id через модель.
class AssignmentFormScreen extends StatelessWidget {
  final int? assignmentId; // не null → редактирование
  final int? initialCourseId; // предвыбранный курс (query-параметр адреса)

  const AssignmentFormScreen({
    super.key,
    this.assignmentId,
    this.initialCourseId,
  });

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseModel>();
    final assignments = context.watch<AssignmentModel>();
    final id = assignmentId;
    final title = id == null ? 'Новое задание' : 'Редактирование задания';

    Widget? placeholder;
    if (courses.isLoading || (id != null && assignments.isLoading)) {
      placeholder = const Center(child: CircularProgressIndicator());
    } else if (courses.error != null) {
      placeholder = ErrorView(
        message: courses.error!,
        onRetry: () => context.read<CourseModel>().load(),
      );
    } else if (id != null && assignments.error != null) {
      placeholder = ErrorView(
        message: assignments.error!,
        onRetry: () => context.read<AssignmentModel>().load(),
      );
    } else if (id != null && assignments.byId(id) == null) {
      placeholder = const Center(child: Text('Задание не существует'));
    }

    if (placeholder != null) {
      return Scaffold(appBar: AppBar(title: Text(title)), body: placeholder);
    }

    return _AssignmentForm(
      initial: id == null ? null : assignments.byId(id),
      initialCourseId: initialCourseId,
    );
  }
}

class _AssignmentForm extends StatefulWidget {
  final Assignment? initial;
  final int? initialCourseId;

  const _AssignmentForm({this.initial, this.initialCourseId});

  @override
  State<_AssignmentForm> createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<_AssignmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  int? _courseId;
  DateTime? _deadline;
  Priority _priority = Priority.medium;
  bool _saving = false; // эфемерное состояние: идёт «запрос»

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    if (a != null) {
      _titleCtrl.text = a.title;
      _courseId = a.courseId;
      _deadline = a.deadline;
      _deadlineCtrl.text = formatDeadline(a.deadline);
      _priority = a.priority;
    } else {
      final id = widget.initialCourseId;
      if (id != null && context.read<CourseModel>().byId(id) != null) {
        _courseId = id;
      }
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return; // валидация L3, нетронута

    final draft = Assignment(
      id: widget.initial?.id ?? 0, // временный id — настоящий даст хранилище
      courseId: _courseId!,
      title: _titleCtrl.text.trim(),
      deadline: _deadline!,
      status: widget.initial?.status ?? AssignmentStatus.todo,
      priority: _priority,
    );

    setState(() => _saving = true);
    final model = context.read<AssignmentModel>();
    final error = _isEdit ? await model.update(draft) : await model.add(draft);
    if (!mounted) return; // экран может умереть, пока запрос летит
    setState(() => _saving = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error))); // данные остаются
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEdit
              ? 'Изменения сохранены: ${draft.title}'
              : 'Задание добавлено: ${draft.title}',
        ),
      ),
    );
    context.pop(); // список позади УЖЕ обновлён — notifyListeners сделал своё
  }

  Future<void> _delete() async {
    final ok = await showConfirmDialog(
      context,
      title: 'Удалить задание?',
      message: _titleCtrl.text.trim(),
      confirmLabel: 'Да, удалить',
    );
    if (!ok || !mounted) return;

    final error =
        await context.read<AssignmentModel>().remove(widget.initial!.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Задание удалено')));
    context.pop(); // объекта больше нет — его экран уходит из стека
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseModel>().courses;

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
                  : null,
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
                for (final c in courses)
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
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEdit ? 'Сохранить изменения' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
