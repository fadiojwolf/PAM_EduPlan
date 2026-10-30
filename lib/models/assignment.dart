/// Модель задания. Поля соответствуют модели backend из ТЗ темы:
/// Assignment(id, courseId, title, deadline, status, priority)
enum AssignmentStatus { todo, inProgress, done }

enum Priority { low, medium, high }

extension AssignmentStatusLabel on AssignmentStatus {
  String get label => switch (this) {
        AssignmentStatus.todo => 'К выполнению',
        AssignmentStatus.inProgress => 'В процессе',
        AssignmentStatus.done => 'Выполнено',
      };
}

extension PriorityLabel on Priority {
  String get label => switch (this) {
        Priority.low => 'Низкий',
        Priority.medium => 'Средний',
        Priority.high => 'Высокий',
      };
}

class Assignment {
  final int id;
  final int courseId;
  final String title;
  final DateTime deadline;
  final AssignmentStatus status;
  final Priority priority;

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.deadline,
    required this.status,
    required this.priority,
  });

  /// «То же задание, но с другими полями» (id выдаёт хранилище).
  Assignment copyWith({
    int? id,
    int? courseId,
    String? title,
    DateTime? deadline,
    AssignmentStatus? status,
    Priority? priority,
  }) =>
      Assignment(
        id: id ?? this.id,
        courseId: courseId ?? this.courseId,
        title: title ?? this.title,
        deadline: deadline ?? this.deadline,
        status: status ?? this.status,
        priority: priority ?? this.priority,
      );
}

String formatDeadline(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
