import 'dart:convert';

import '../models/course.dart';
import 'api_client.dart';
import 'course_repository.dart';
import 'result.dart';

/// Вторая реализация интерфейса L4: тот же контракт, но по сети.
class HttpCourseRepository implements CourseRepository {
  HttpCourseRepository(this._api);

  final ApiClient _api;

  Course _one(String body) =>
      Course.fromJson(jsonDecode(body) as Map<String, dynamic>);

  @override
  Future<Result<List<Course>>> fetchAll() => _api.call(
        method: 'GET',
        path: '/courses',
        query: {'page': '1', 'limit': '100'}, // расписание нужно целиком
        okStatuses: {200},
        parse: (body) {
          final data = jsonDecode(body) as Map<String, dynamic>; // конверт!
          return (data['items'] as List)
              .map((e) => Course.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

  @override
  Future<Result<Course>> fetchById(int id) => _api.call(
        method: 'GET',
        path: '/courses/$id',
        okStatuses: {200},
        parse: _one,
      );

  @override
  Future<Result<Course>> create(Course course) => _api.call(
        method: 'POST',
        path: '/courses',
        body: course.toJson(),
        okStatuses: {201},
        parse: _one,
      );

  @override
  Future<Result<Course>> update(Course course) => _api.call(
        method: 'PUT',
        path: '/courses/${course.id}',
        body: course.toJson(),
        okStatuses: {200},
        parse: _one,
      );

  @override
  Future<Result<void>> delete(int id) => _api.call<void>(
        method: 'DELETE',
        path: '/courses/$id',
        okStatuses: {200, 204},
        parse: (_) {}, // 204: тело пустое — jsonDecode на нём НЕ вызываем
      );
}
