// Быстрая проверка контракта сущностей EduPlan (courses, assignments).
// Сервер должен быть запущен:  dart run tool/smoke_eduplan.dart [http://localhost:8080]
// Это дополнение к набору conformance: он проверяет базовый контракт (notes,
// auth, files), а этот скрипт — то, что добавлено для темы.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

late String base;
var passed = 0;
var failed = 0;

void check(String name, bool ok, [Object? detail]) {
  if (ok) {
    passed++;
    print('  ✓ $name');
  } else {
    failed++;
    print('  ✗ $name${detail == null ? '' : '  →  $detail'}');
  }
}

Future<http.Response> call(
  String method,
  String path, {
  String? token,
  Object? body,
}) async {
  final req = http.Request(method, Uri.parse('$base$path'));
  req.headers['Content-Type'] = 'application/json';
  if (token != null) req.headers['Authorization'] = 'Bearer $token';
  if (body != null) req.body = jsonEncode(body);
  return http.Response.fromStream(await req.send());
}

Map<String, dynamic> obj(http.Response r) =>
    jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;

String code(http.Response r) =>
    ((obj(r)['error'] as Map<String, dynamic>)['code']) as String;

Future<String> register(String email) async {
  final r = await call('POST', '/auth/register',
      body: {'email': email, 'password': 'parola123', 'name': 'Smoke'});
  return obj(r)['token'] as String;
}

Future<void> main(List<String> args) async {
  base = args.isNotEmpty ? args[0] : 'http://localhost:8080';
  final stamp = DateTime.now().millisecondsSinceEpoch;

  print('Авторизация');
  final noToken = await call('GET', '/courses');
  check('GET /courses без token → 401 UNAUTHORIZED',
      noToken.statusCode == 401 && code(noToken) == 'UNAUTHORIZED');
  final a = await register('smoke_a_$stamp@test.md');
  final b = await register('smoke_b_$stamp@test.md');

  print('Courses');
  final empty = await call('GET', '/courses', token: a);
  check('GET /courses → пустой конверт',
      empty.statusCode == 200 &&
          obj(empty)['total'] == 0 &&
          obj(empty)['page'] == 1 &&
          obj(empty)['limit'] == 20 &&
          (obj(empty)['items'] as List).isEmpty);

  final course = {
    'name': 'Алгоритмы и структуры данных',
    'teacher': 'conf. univ., dr. Ciobanu Elena',
    'room': '3-118',
    'weekday': 2,
    'startTime': '13:30',
  };
  final created = await call('POST', '/courses', token: a, body: course);
  final courseId = obj(created)['id'] as int;
  check('POST /courses → 201 с id от сервера',
      created.statusCode == 201 && obj(created)['startTime'] == '13:30');

  final badDay = await call('POST', '/courses',
      token: a, body: {...course, 'weekday': 9});
  check('weekday=9 → 400 VALIDATION_ERROR',
      badDay.statusCode == 400 && code(badDay) == 'VALIDATION_ERROR');
  final badTime = await call('POST', '/courses',
      token: a, body: {...course, 'startTime': '25:99'});
  check('startTime=25:99 → 400', badTime.statusCode == 400);
  final noName = await call('POST', '/courses',
      token: a, body: {...course, 'name': '  '});
  check('пустое name → 400', noName.statusCode == 400);

  final got = await call('GET', '/courses/$courseId', token: a);
  check('GET /courses/{id} → 200', got.statusCode == 200);
  final upd = await call('PUT', '/courses/$courseId',
      token: a, body: {...course, 'room': '4-210'});
  check('PUT /courses/{id} → 200 и новая аудитория',
      upd.statusCode == 200 && obj(upd)['room'] == '4-210');

  final found = await call('GET', '/courses?search=${Uri.encodeQueryComponent('АЛГОРИТМ')}',
      token: a);
  check('search=АЛГОРИТМ (кириллица, регистр) находит курс',
      found.statusCode == 200 && obj(found)['total'] == 1);
  final byTeacher = await call('GET', '/courses?search=ciobanu', token: a);
  check('search по преподавателю', obj(byTeacher)['total'] == 1);

  final foreignGet = await call('GET', '/courses/$courseId', token: b);
  check('чужой курс → 404 NOT_FOUND (не 403)',
      foreignGet.statusCode == 404 && code(foreignGet) == 'NOT_FOUND');
  final bList = await call('GET', '/courses', token: b);
  check('список другого пользователя пуст', obj(bList)['total'] == 0);

  print('Assignments');
  final assignment = {
    'courseId': courseId,
    'title': 'Реализация AVL-дерева',
    'deadline': '2026-11-02T00:00:00.000',
    'status': 'todo',
    'priority': 'high',
  };
  final aCreated = await call('POST', '/assignments', token: a, body: assignment);
  final assignmentId = obj(aCreated)['id'] as int;
  check('POST /assignments → 201',
      aCreated.statusCode == 201 && obj(aCreated)['courseId'] == courseId);

  final badCourse = await call('POST', '/assignments',
      token: a, body: {...assignment, 'courseId': 99999});
  check('несуществующий courseId → 400', badCourse.statusCode == 400);
  final foreignCourse = await call('POST', '/assignments',
      token: b, body: assignment);
  check('чужой courseId → 400', foreignCourse.statusCode == 400);
  final badStatus = await call('POST', '/assignments',
      token: a, body: {...assignment, 'status': 'finished'});
  check('status=finished → 400', badStatus.statusCode == 400);
  final badDeadline = await call('POST', '/assignments',
      token: a, body: {...assignment, 'deadline': 'завтра'});
  check('deadline=«завтра» → 400', badDeadline.statusCode == 400);

  final done = await call('PUT', '/assignments/$assignmentId',
      token: a, body: {...assignment, 'status': 'done'});
  check('PUT → status=done',
      done.statusCode == 200 && obj(done)['status'] == 'done');

  final aFound = await call(
      'GET', '/assignments?search=${Uri.encodeQueryComponent('реализ')}',
      token: a);
  check('search=реализ находит задание', obj(aFound)['total'] == 1);

  print('Пагинация');
  for (var i = 1; i <= 25; i++) {
    await call('POST', '/assignments',
        token: a,
        body: {
          ...assignment,
          'title': 'Тест $i',
          'deadline': '2026-12-${(i % 28 + 1).toString().padLeft(2, '0')}T00:00:00.000',
        });
  }
  final p1 = await call('GET', '/assignments?page=1&limit=20', token: a);
  final p2 = await call('GET', '/assignments?page=2&limit=20', token: a);
  check('страница 1 — 20 элементов, total=26',
      (obj(p1)['items'] as List).length == 20 && obj(p1)['total'] == 26);
  check('страница 2 — 6 элементов',
      (obj(p2)['items'] as List).length == 6);
  final items = (obj(p1)['items'] as List).cast<Map<String, dynamic>>();
  final sorted = [...items]
    ..sort((x, y) => (x['deadline'] as String).compareTo(y['deadline'] as String));
  check('сортировка по дедлайну: ближайшие первыми',
      items.map((e) => e['id']).toList().toString() ==
          sorted.map((e) => e['id']).toList().toString());

  print('Удаление');
  final del = await call('DELETE', '/assignments/$assignmentId', token: a);
  check('DELETE /assignments/{id} → 204 и пустое тело',
      del.statusCode == 204 && del.body.isEmpty);
  final gone = await call('GET', '/assignments/$assignmentId', token: a);
  check('после удаления → 404', gone.statusCode == 404);

  final delCourse = await call('DELETE', '/courses/$courseId', token: a);
  check('DELETE /courses/{id} → 204', delCourse.statusCode == 204);
  final afterCascade = await call('GET', '/assignments', token: a);
  check('задания курса удалены каскадом', obj(afterCascade)['total'] == 0);

  print('\nИтог: ${failed == 0 ? 'PASS' : 'FAIL'} — $passed/${passed + failed} checks passed');
  exit(failed == 0 ? 0 : 1);
}
