// Courses (пары расписания): CRUD на пользователя — копия паттерна notes.dart.
//
//   GET    /courses?page=&limit=&search=  -> {items, page, limit, total}
//   POST   /courses                        -> 201 course
//   GET    /courses/{id}                   -> 200 course | 404
//   PUT    /courses/{id}                   -> 200 course | 400 | 404
//   DELETE /courses/{id}                   -> 204 | 404  (задания курса — каскадом)
//
// JSON: {id, name, teacher, room, weekday (1..7), startTime ("HH:mm"), createdAt}

import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

Map<String, Object?> _toJson(Row row) => {
      'id': row['id'],
      'name': row['name'],
      'teacher': row['teacher'],
      'room': row['room'],
      'weekday': row['weekday'],
      'startTime': row['start_time'],
      'createdAt': row['created_at'],
    };

/// Finds a course by id, but only among the current user's courses.
/// Someone else's course is indistinguishable from a missing one (404).
Row? _find(int userId, String? idParam) {
  final id = int.tryParse(idParam ?? '');
  if (id == null) return null;
  final rows = db.select(
    'SELECT * FROM courses WHERE id = ? AND user_id = ?',
    [id, userId],
  );
  return rows.isEmpty ? null : rows.first;
}

final _timePattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

/// Optional string field: missing -> '', not a string -> null (invalid).
String? _optionalString(Object? value) =>
    value == null ? '' : (value is String ? value.trim() : null);

/// Validates the body. Returns (fields, null) or (null, error response).
(Map<String, Object?>?, Response?) _validate(Map<String, dynamic> body) {
  final name = stringField(body, 'name');
  if (name == null) return (null, validationError('name is required'));

  final teacher = _optionalString(body['teacher']);
  if (teacher == null) return (null, validationError('teacher must be a string'));
  final room = _optionalString(body['room']);
  if (room == null) return (null, validationError('room must be a string'));

  final weekday = body['weekday'];
  if (weekday is! int || weekday < 1 || weekday > 7) {
    return (null, validationError('weekday must be an integer from 1 to 7'));
  }
  final startTime = body['startTime'];
  if (startTime is! String || !_timePattern.hasMatch(startTime)) {
    return (null, validationError('startTime must look like HH:mm'));
  }

  return (
    {
      'name': name,
      'teacher': teacher,
      'room': room,
      'weekday': weekday,
      'startTime': startTime,
    },
    null,
  );
}

/// GET /courses?page=1&limit=20&search=  -> {items, page, limit, total}
/// Поиск — по названию и преподавателю, без учёта регистра (в т.ч. кириллица:
/// SQLite LIKE регистронезависим только для ASCII, поэтому фильтруем в Dart).
Future<Response> listCourses(Request request) async {
  final query = request.url.queryParameters;
  final page = max(int.tryParse(query['page'] ?? '') ?? 1, 1);
  final limit = (int.tryParse(query['limit'] ?? '') ?? 20).clamp(1, 100).toInt();
  final search = (query['search'] ?? '').trim().toLowerCase();

  final rows = db.select(
    'SELECT * FROM courses WHERE user_id = ? '
    'ORDER BY weekday ASC, start_time ASC, id ASC',
    [currentUserId(request)],
  );
  final matching = search.isEmpty
      ? rows.toList()
      : rows
          .where((r) =>
              (r['name'] as String).toLowerCase().contains(search) ||
              (r['teacher'] as String).toLowerCase().contains(search))
          .toList();

  final start = (page - 1) * limit;
  final items = start >= matching.length
      ? <Row>[]
      : matching.sublist(start, min(start + limit, matching.length));

  return jsonResponse({
    'items': items.map(_toJson).toList(),
    'page': page,
    'limit': limit,
    'total': matching.length,
  });
}

/// POST /courses  -> 201 course
Future<Response> createCourse(Request request) async {
  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final (fields, error) = _validate(body);
  if (error != null) return error;
  final f = fields!;

  db.execute(
    'INSERT INTO courses '
    '(user_id, name, teacher, room, weekday, start_time, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?)',
    [
      currentUserId(request),
      f['name'],
      f['teacher'],
      f['room'],
      f['weekday'],
      f['startTime'],
      nowIso(),
    ],
  );
  final row = _find(currentUserId(request), '${db.lastInsertRowId}')!;
  return jsonResponse(_toJson(row), status: 201);
}

/// GET /courses/{id} -> 200 course | 404
Future<Response> getCourse(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Course not found');
  return jsonResponse(_toJson(row));
}

/// PUT /courses/{id} -> 200 updated course | 400 | 404
Future<Response> updateCourse(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Course not found');

  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final (fields, error) = _validate(body);
  if (error != null) return error;
  final f = fields!;

  db.execute(
    'UPDATE courses SET name = ?, teacher = ?, room = ?, weekday = ?, '
    'start_time = ? WHERE id = ?',
    [f['name'], f['teacher'], f['room'], f['weekday'], f['startTime'], row['id']],
  );
  final updated = _find(currentUserId(request), '${row['id']}')!;
  return jsonResponse(_toJson(updated));
}

/// DELETE /courses/{id} -> 204 | 404. Задания этого курса удаляются каскадом.
Future<Response> deleteCourse(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Course not found');
  db.execute(
    'DELETE FROM assignments WHERE course_id = ? AND user_id = ?',
    [row['id'], currentUserId(request)],
  );
  db.execute('DELETE FROM courses WHERE id = ?', [row['id']]);
  return Response(204);
}
