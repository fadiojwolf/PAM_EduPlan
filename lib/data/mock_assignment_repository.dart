import '../models/assignment.dart';
import 'assignment_repository.dart';
import 'mock_data.dart';
import 'mock_network.dart';
import 'result.dart';

/// Память с повадками сети: задержка + переключаемая авария.
class MockAssignmentRepository implements AssignmentRepository {
  MockAssignmentRepository(this._net);

  final MockNetwork _net;
  final List<Assignment> _items = List.of(mockAssignments); // seed из L2
  int _nextId = 1000; // выше любого id из seed-а
  static const _errNotFound = 'Задание не существует';

  @override
  Future<Result<List<Assignment>>> fetchAll() async {
    await Future.delayed(MockNetwork.latency);
    if (_net.simulateError) return const Err(MockNetwork.errNetwork);
    return Ok(List.of(_items));
  }

  @override
  Future<Result<Assignment>> fetchById(int id) async {
    await Future.delayed(MockNetwork.latency);
    if (_net.simulateError) return const Err(MockNetwork.errNetwork);
    final i = _items.indexWhere((a) => a.id == id);
    if (i < 0) return const Err(_errNotFound);
    return Ok(_items[i]);
  }

  @override
  Future<Result<Assignment>> create(Assignment assignment) async {
    await Future.delayed(MockNetwork.latency);
    if (_net.simulateError) return const Err(MockNetwork.errNetwork);
    final created = assignment.copyWith(id: _nextId++);
    _items.add(created);
    return Ok(created);
  }

  @override
  Future<Result<Assignment>> update(Assignment assignment) async {
    await Future.delayed(MockNetwork.latency);
    if (_net.simulateError) return const Err(MockNetwork.errNetwork);
    final i = _items.indexWhere((a) => a.id == assignment.id);
    if (i < 0) return const Err(_errNotFound);
    _items[i] = assignment;
    return Ok(assignment);
  }

  @override
  Future<Result<void>> delete(int id) async {
    await Future.delayed(MockNetwork.latency);
    if (_net.simulateError) return const Err(MockNetwork.errNetwork);
    final before = _items.length;
    _items.removeWhere((a) => a.id == id);
    if (_items.length == before) return const Err(_errNotFound);
    return const Ok(null);
  }
}
