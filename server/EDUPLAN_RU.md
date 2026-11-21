# EduPlan: что добавлено к шаблону

К шаблону (Dart + Shelf) добавлены две сущности темы T3 по образцу `notes`.
Базовый контракт (auth, notes, files) не тронут.

| Файл | Что изменено |
|---|---|
| `lib/db.dart` | + таблицы `courses` и `assignments` |
| `lib/courses.dart` | новый: CRUD курсов (пары расписания) |
| `lib/assignments.dart` | новый: CRUD заданий |
| `bin/server.dart` | + 10 маршрутов рядом с `/notes` (под `requireAuth`) |
| `tool/smoke_eduplan.dart` | новый: проверка контракта новых сущностей |

## Контракт

**Course** — `{id, name, teacher, room, weekday (1..7), startTime ("HH:mm"), createdAt}`
**Assignment** — `{id, courseId, title, deadline (ISO-8601), status, priority, createdAt}`
`status`: `todo` | `in_progress` | `done`; `priority`: `low` | `medium` | `high`.

Маршруты (все под Bearer-token):
`GET/POST /courses`, `GET/PUT/DELETE /courses/{id}`,
`GET/POST /assignments`, `GET/PUT/DELETE /assignments/{id}`.

- Список: `?page=&limit=&search=` → `{items, page, limit, total}`.
  Курсы отсортированы по дню и времени, задания — по дедлайну.
- Поиск без учёта регистра, в том числе для кириллицы (курсы: название и
  преподаватель; задания: название).
- `400 VALIDATION_ERROR` при неверном теле; `404 NOT_FOUND` для чужой или
  несуществующей записи (не 403 — сервер не раскрывает, что она есть).
- Задание должно ссылаться на существующий курс этого же пользователя.
- Удаление курса удаляет и его задания (каскад в коде, SQLite FK не включён).

## Запуск и проверка

```bash
dart pub get
dart run                                   # сервер на :8080
dart run tool/smoke_eduplan.dart           # проверка новых сущностей
# + набор conformance из kit-а (базовый контракт): должен остаться 37/37
```

Схема применяется при старте: **новые** таблицы создаются сами, но уже
существующие не меняются. Если правили колонки — удалите `app.db`.

## Сессия curl (для отчёта)

```bash
curl -i localhost:8080/courses                       # 401 UNAUTHORIZED
curl -X POST localhost:8080/auth/register -H 'Content-Type: application/json' \
  -d '{"email":"ana@test.md","password":"parola123","name":"Ana"}'   # 201, скопируйте token
T=eyJ...                                             # вставьте token
curl -X POST localhost:8080/courses -H "Authorization: Bearer $T" \
  -H 'Content-Type: application/json' \
  -d '{"name":"PAM","teacher":"Antohi Ionel","room":"604","weekday":2,"startTime":"13:30"}'
curl -G localhost:8080/courses --data-urlencode 'search=pam' -H "Authorization: Bearer $T"
curl -X POST localhost:8080/assignments -H "Authorization: Bearer $T" \
  -H 'Content-Type: application/json' \
  -d '{"courseId":1,"title":"Лабораторная 5","deadline":"2026-11-20T00:00:00.000","status":"todo","priority":"high"}'
curl -G localhost:8080/assignments --data-urlencode 'search=Лаборат' -H "Authorization: Bearer $T"
```
