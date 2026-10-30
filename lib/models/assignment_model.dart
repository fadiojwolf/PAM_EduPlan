import 'package:flutter/foundation.dart';

import '../data/assignment_repository.dart';
import '../data/result.dart';
import 'assignment.dart';

/// Разделяемое состояние темы: список заданий, отметка выполнения,
/// сортировка по сроку. Читают несколько экранов, живёт дольше любого из них.
class AssignmentModel extends ChangeNotifier {
  AssignmentModel(this._repository);

  final AssignmentRepository _repository;

  bool _loading = false;
  String? _error;
  List<Assignment> _items = const [];
  bool _sortAscending = true; // true: сначала ближайшие дедлайны

  bool get isLoading => _loading;
  String? get error => _error;
  bool get sortAscending => _sortAscending;

  /// Задания, отсортированные по сроку; наружу — только read-only.
  List<Assignment> get items {
    final sorted = [..._items]..sort((a, b) => _sortAscending
        ? a.deadline.compareTo(b.deadline)
        : b.deadline.compareTo(a.deadline));
    return List.unmodifiable(sorted);
  }

  List<Assignment> forCourse(int courseId) =>
      List.unmodifiable(items.where((a) => a.courseId == courseId));

  int get totalCount => _items.length;
  int get doneCount =>
      _items.where((a) => a.status == AssignmentStatus.done).length;
  int get pendingCount => totalCount - doneCount;

  Assignment? byId(int id) {
    for (final a in _items) {
      if (a.id == id) return a;
    }
    return null;
  }

  void toggleSort() {
    _sortAscending = !_sortAscending;
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _items = value;
      case Err(:final msg):
        _error = msg;
    }

    _loading = false;
    notifyListeners();
  }

  // Конвенция возврата мутаций: null — успех, строка — сообщение об ошибке
  // (та же логика, что у validator).

  Future<String?> add(Assignment draft) async {
    switch (await _repository.create(draft)) {
      case Ok(:final value):
        _items = [..._items, value]; // с id, полученным от хранилища
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg; // состояние не тронуто — экран решает, что показать
    }
  }

  Future<String?> update(Assignment assignment) async {
    switch (await _repository.update(assignment)) {
      case Ok(:final value):
        _items = [
          for (final a in _items) a.id == value.id ? value : a,
        ];
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> remove(int id) async {
    switch (await _repository.delete(id)) {
      case Ok():
        _items = _items.where((a) => a.id != id).toList();
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  /// Отметка выполнения: done ↔ todo.
  Future<String?> toggleDone(Assignment a) => update(
        a.copyWith(
          status: a.status == AssignmentStatus.done
              ? AssignmentStatus.todo
              : AssignmentStatus.done,
        ),
      );
}
