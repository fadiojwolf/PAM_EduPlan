// SQLite setup. The database file is created automatically on first start.
//
// To add your own entity: add a CREATE TABLE below, then copy the pattern
// of lib/notes.dart for its routes.

import 'package:sqlite3/sqlite3.dart';

/// The single database connection, opened once at startup by [initDb].
late final Database db;

/// Opens (and creates, on first run) the database and its schema.
void initDb(String path) {
  db = sqlite3.open(path);
  db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      email         TEXT    NOT NULL UNIQUE,
      password_hash TEXT    NOT NULL,
      name          TEXT    NOT NULL,
      created_at    TEXT    NOT NULL
    );

    CREATE TABLE IF NOT EXISTS notes (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users (id),
      title      TEXT    NOT NULL,
      content    TEXT    NOT NULL DEFAULT '',
      created_at TEXT    NOT NULL
    );

    -- EduPlan: пары расписания (weekday: 1 = пн ... 7 = вс; start_time: 'HH:mm')
    CREATE TABLE IF NOT EXISTS courses (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users (id),
      name       TEXT    NOT NULL,
      teacher    TEXT    NOT NULL DEFAULT '',
      room       TEXT    NOT NULL DEFAULT '',
      weekday    INTEGER NOT NULL,
      start_time TEXT    NOT NULL,
      created_at TEXT    NOT NULL
    );

    -- EduPlan: задания с дедлайнами, привязанные к курсу
    CREATE TABLE IF NOT EXISTS assignments (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users (id),
      course_id  INTEGER NOT NULL REFERENCES courses (id),
      title      TEXT    NOT NULL,
      deadline   TEXT    NOT NULL,
      status     TEXT    NOT NULL DEFAULT 'todo',
      priority   TEXT    NOT NULL DEFAULT 'medium',
      created_at TEXT    NOT NULL
    );

    CREATE TABLE IF NOT EXISTS files (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id    INTEGER NOT NULL REFERENCES users (id),
      name       TEXT    NOT NULL,
      mime_type  TEXT    NOT NULL,
      size       INTEGER NOT NULL,
      path       TEXT    NOT NULL,
      created_at TEXT    NOT NULL
    );
  ''');
}

/// Current UTC time in ISO-8601, the format used for all timestamps.
String nowIso() => DateTime.now().toUtc().toIso8601String();
