// Assignments (задания с дедлайнами): CRUD на пользователя — паттерн notes.dart.
//
//   GET    /assignments?page=&limit=&search=  -> {items, page, limit, total}
//   POST   /assignments                        -> 201 assignment
//   GET    /assignments/{id}                   -> 200 assignment | 404
//   PUT    /assignments/{id}                   -> 200 assignment | 400 | 404
//   DELETE /assignments/{id}                   -> 204 | 404
//
// JSON: {id, courseId, title, deadline (ISO-8601), status, priority, createdAt}
//   status:   todo | in_progress | done          (по умолчанию todo)
//   priority: low  | medium      | high          (по умолчанию medium)

import 'dart:math';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

const _statuses = {'todo', 'in_progress', 'done'};
const _priorities = {'low', 'medium', 'high'};

Map<String, Object?> _toJson(Row row) => {
      'id': row['id'],
      'courseId': row['course_id'],
      'title': row['title'],
      'deadline': row['deadline'],
      'status': row['status'],
      'priority': row['priority'],
      'createdAt': row['created_at'],
    };

/// Finds an assignment by id, but only among the current user's assignments.
Row? _find(int userId, String? idParam) {
  final id = int.tryParse(idParam ?? '');
  if (id == null) return null;
  final rows = db.select(
    'SELECT * FROM assignments WHERE id = ? AND user_id = ?',
    [id, userId],
  );
  return rows.isEmpty ? null : rows.first;
}

/// Validates the body. Returns (fields, null) or (null, error response).
(Map<String, Object?>?, Response?) _validate(
  Map<String, dynamic> body,
  int userId,
) {
  final title = stringField(body, 'title');
  if (title == null) return (null, validationError('title is required'));

  final courseId = body['courseId'];
  if (courseId is! int) {
    return (null, validationError('courseId must be an integer'));
  }
  final ownCourse = db.select(
    'SELECT id FROM courses WHERE id = ? AND user_id = ?',
    [courseId, userId],
  );
  if (ownCourse.isEmpty) {
    return (null, validationError('courseId must refer to one of your courses'));
  }

  final deadline = body['deadline'];
  if (deadline is! String || DateTime.tryParse(deadline) == null) {
    return (null, validationError('deadline must be an ISO-8601 date string'));
  }

  final status = body['status'] ?? 'todo';
  if (status is! String || !_statuses.contains(status)) {
    return (null, validationError('status must be todo, in_progress or done'));
  }
  final priority = body['priority'] ?? 'medium';
  if (priority is! String || !_priorities.contains(priority)) {
    return (null, validationError('priority must be low, medium or high'));
  }

  return (
    {
      'title': title,
      'courseId': courseId,
      'deadline': deadline,
      'status': status,
      'priority': priority,
    },
    null,
  );
}

/// GET /assignments?page=1&limit=20&search=  -> {items, page, limit, total}
/// Сортировка — по дедлайну (ближайшие первыми), затем по id. Поиск — по
/// названию, без учёта регистра (в т.ч. кириллица), поэтому фильтруем в Dart.
Future<Response> listAssignments(Request request) async {
  final query = request.url.queryParameters;
  final page = max(int.tryParse(query['page'] ?? '') ?? 1, 1);
  final limit = (int.tryParse(query['limit'] ?? '') ?? 20).clamp(1, 100).toInt();
  final search = (query['search'] ?? '').trim().toLowerCase();

  final rows = db.select(
    'SELECT * FROM assignments WHERE user_id = ? ORDER BY deadline ASC, id ASC',
    [currentUserId(request)],
  );
  final matching = search.isEmpty
      ? rows.toList()
      : rows
          .where((r) => (r['title'] as String).toLowerCase().contains(search))
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

/// POST /assignments -> 201 assignment (id выдаёт сервер)
Future<Response> createAssignment(Request request) async {
  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final userId = currentUserId(request);
  final (fields, error) = _validate(body, userId);
  if (error != null) return error;
  final f = fields!;

  db.execute(
    'INSERT INTO assignments '
    '(user_id, course_id, title, deadline, status, priority, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?)',
    [
      userId,
      f['courseId'],
      f['title'],
      f['deadline'],
      f['status'],
      f['priority'],
      nowIso(),
    ],
  );
  final row = _find(userId, '${db.lastInsertRowId}')!;
  return jsonResponse(_toJson(row), status: 201);
}

/// GET /assignments/{id} -> 200 assignment | 404
Future<Response> getAssignment(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Assignment not found');
  return jsonResponse(_toJson(row));
}

/// PUT /assignments/{id} -> 200 updated assignment | 400 | 404
Future<Response> updateAssignment(Request request) async {
  final userId = currentUserId(request);
  final row = _find(userId, request.params['id']);
  if (row == null) return notFound('Assignment not found');

  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');
  final (fields, error) = _validate(body, userId);
  if (error != null) return error;
  final f = fields!;

  db.execute(
    'UPDATE assignments SET course_id = ?, title = ?, deadline = ?, '
    'status = ?, priority = ? WHERE id = ?',
    [f['courseId'], f['title'], f['deadline'], f['status'], f['priority'], row['id']],
  );
  final updated = _find(userId, '${row['id']}')!;
  return jsonResponse(_toJson(updated));
}

/// DELETE /assignments/{id} -> 204 | 404
Future<Response> deleteAssignment(Request request) async {
  final row = _find(currentUserId(request), request.params['id']);
  if (row == null) return notFound('Assignment not found');
  db.execute('DELETE FROM assignments WHERE id = ?', [row['id']]);
  return Response(204);
}
