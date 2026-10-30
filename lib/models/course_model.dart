import 'package:flutter/foundation.dart';

import '../data/course_repository.dart';
import '../data/result.dart';
import 'course.dart';

/// Состояние списка курсов + триада loading / data / error (C8).
/// Репозиторий входит через конструктор и имеет тип ИНТЕРФЕЙСА.
class CourseModel extends ChangeNotifier {
  CourseModel(this._repository);

  final CourseRepository _repository;

  bool _loading = false;
  String? _error;
  List<Course> _courses = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<Course> get courses => List.unmodifiable(_courses);

  Course? byId(int id) {
    for (final c in _courses) {
      if (c.id == id) return c;
    }
    return null; // «ещё не загружено» или «не существует»
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners(); // экраны входят в состояние «грузится»

    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _courses = value;
      case Err(:final msg):
        _error = msg;
    }

    _loading = false;
    notifyListeners(); // …и выходят: с данными или с ошибкой
  }
}
