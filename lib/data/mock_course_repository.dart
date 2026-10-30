import '../models/course.dart';
import 'course_repository.dart';
import 'mock_data.dart';
import 'mock_network.dart';
import 'result.dart';

/// Память с повадками сети: задержка + переключаемая авария.
class MockCourseRepository implements CourseRepository {
  MockCourseRepository(this._net);

  final MockNetwork _net;
  final List<Course> _items = List.of(mockCourses); // seed из L2
  int _nextId = 1000; // выше любого id из seed-а
  static const _errNotFound = 'Курс не существует';

  @override
  Future<Result<List<Course>>> fetchAll() async {
    await Future.delayed(MockNetwork.latency); // сеть не отвечает мгновенно
    if (_net.simulateError) return const Err(MockNetwork.errNetwork);
    return Ok(List.of(_items)); // копия — внутренность наружу не отдаём
  }

  @override
  Future<Result<Course>> fetchById(int id) async {
    await Future.delayed(MockNetwork.latency);
    if (_net.simulateError) return const Err(MockNetwork.errNetwork);
    final i = _items.indexWhere((c) => c.id == id);
    if (i < 0) return const Err(_errNotFound); // «404» mock-а
    return Ok(_items[i]);
  }

  @override
  Future<Result<Course>> create(Course course) async {
    await Future.delayed(MockNetwork.latency);
    if (_net.simulateError) return const Err(MockNetwork.errNetwork);
    final created = course.copyWith(id: _nextId++); // id даёт ХРАНИЛИЩЕ
    _items.add(created);
    return Ok(created);
  }

  @override
  Future<Result<Course>> update(Course course) async {
    await Future.delayed(MockNetwork.latency);
    if (_net.simulateError) return const Err(MockNetwork.errNetwork);
    final i = _items.indexWhere((c) => c.id == course.id);
    if (i < 0) return const Err(_errNotFound);
    _items[i] = course;
    return Ok(course);
  }

  @override
  Future<Result<void>> delete(int id) async {
    await Future.delayed(MockNetwork.latency);
    if (_net.simulateError) return const Err(MockNetwork.errNetwork);
    final before = _items.length;
    _items.removeWhere((c) => c.id == id);
    if (_items.length == before) return const Err(_errNotFound);
    return const Ok(null); // «удалил, отдать нечего» (204)
  }
}
