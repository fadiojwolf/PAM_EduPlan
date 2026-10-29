import '../models/course.dart';
import 'result.dart';

/// Контракт: ЧТО можно просить, а не КАК.
/// На L5 каждый метод отображается на REST: GET/POST /courses,
/// GET/PUT/DELETE /courses/{id}.
abstract class CourseRepository {
  Future<Result<List<Course>>> fetchAll(); // GET /courses
  Future<Result<Course>> fetchById(int id); // GET /courses/{id}
  Future<Result<Course>> create(Course course); // POST /courses
  Future<Result<Course>> update(Course course); // PUT /courses/{id}
  Future<Result<void>> delete(int id); // DELETE /courses/{id}
}
