/// Модель курса (пары). Поля соответствуют модели backend из ТЗ темы:
/// Course(id, name, teacher, room, weekday, startTime)
const weekdayNames = [
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
  'Воскресенье',
];

const weekdayShort = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

class Course {
  final int id;
  final String name;
  final String teacher;
  final String room;
  final int weekday; // 1 = понедельник ... 7 = воскресенье
  final String startTime; // 'HH:mm'

  const Course({
    required this.id,
    required this.name,
    required this.teacher,
    required this.room,
    required this.weekday,
    required this.startTime,
  });

  /// «Тот же курс, другая идентичность» (id выдаёт хранилище).
  Course copyWith({int? id}) => Course(
        id: id ?? this.id,
        name: name,
        teacher: teacher,
        room: room,
        weekday: weekday,
        startTime: startTime,
      );

  /// Конец пары вычисляется (пара = 90 минут), в модели не хранится.
  String get endTime {
    final parts = startTime.split(':');
    final total = int.parse(parts[0]) * 60 + int.parse(parts[1]) + 90;
    final h = (total ~/ 60).toString().padLeft(2, '0');
    final m = (total % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}
