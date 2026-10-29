import '../models/assignment.dart';
import 'result.dart';

/// Контракт: ЧТО можно просить, а не КАК.
/// На L5: GET/POST /assignments, GET/PUT/DELETE /assignments/{id}.
abstract class AssignmentRepository {
  Future<Result<List<Assignment>>> fetchAll(); // GET /assignments
  Future<Result<Assignment>> fetchById(int id); // GET /assignments/{id}
  Future<Result<Assignment>> create(Assignment assignment); // POST
  Future<Result<Assignment>> update(Assignment assignment); // PUT /{id}
  Future<Result<void>> delete(int id); // DELETE /{id}
}
