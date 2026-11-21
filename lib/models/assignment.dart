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

  /// Граница JSON: сервер → доменная модель.
  factory Assignment.fromJson(Map<String, dynamic> j) => Assignment(
        id: j['id'] as int,
        courseId: j['courseId'] as int,
        title: j['title'] as String,
        deadline: DateTime.parse(j['deadline'] as String),
        status: _statusFromApi(j['status'] as String? ?? 'todo'),
        priority: _priorityFromApi(j['priority'] as String? ?? 'medium'),
      );

  /// Без id — идентичность даёт сервер.
  Map<String, dynamic> toJson() => {
        'courseId': courseId,
        'title': title,
        'deadline': deadline.toIso8601String(),
        'status': _statusToApi(status),
        'priority': priority.name,
      };

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

// Значения enum-ов на проводе (контракт сервера).
String _statusToApi(AssignmentStatus s) => switch (s) {
      AssignmentStatus.todo => 'todo',
      AssignmentStatus.inProgress => 'in_progress',
      AssignmentStatus.done => 'done',
    };

AssignmentStatus _statusFromApi(String v) => switch (v) {
      'in_progress' => AssignmentStatus.inProgress,
      'done' => AssignmentStatus.done,
      _ => AssignmentStatus.todo,
    };

Priority _priorityFromApi(String v) => switch (v) {
      'low' => Priority.low,
      'high' => Priority.high,
      _ => Priority.medium,
    };
