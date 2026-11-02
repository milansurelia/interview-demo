import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:tectonas_ems/employee/model/employee_model.dart';

class HiveOfflineService {
  HiveOfflineService({required Box<String> box}) : _box = box;

  static const _employeeListKey = 'employee_ids';
  static const _employeeKeyPrefix = 'employee_';

  final Box<String> _box;

  Future<void> saveEmployees(List<EmployeeModel> employees) async {
    final employeeJson = <String, String>{
      for (final employee in employees)
        fetchEmployeeKey(employee.id): employee.toJson(),
    };
    await _box.putAll(employeeJson);
    await _box.put(
      _employeeListKey,
      jsonEncode(employees.map((employee) => employee.id).toList()),
    );
  }

  Future<void> saveEmployee(EmployeeModel employee) async {
    await _box.put(fetchEmployeeKey(employee.id), employee.toJson());
    final employeeIds = fetchEmployeeIds() ?? <int>[];
    if (!employeeIds.contains(employee.id)) {
      employeeIds.add(employee.id);
      await _box.put(_employeeListKey, jsonEncode(employeeIds));
    }
  }

  EmployeeModel? fetchEmployee(int employeeId) {
    final employeeJson = _box.get(fetchEmployeeKey(employeeId));
    return employeeJson == null ? null : EmployeeModel.fromJson(employeeJson);
  }

  List<EmployeeModel>? fetchEmployeeList() {
    final employeeIds = fetchEmployeeIds();
    return employeeIds?.map(fetchEmployee).whereType<EmployeeModel>().toList();
  }

  List<int>? fetchEmployeeIds() {
    final employeeIdsJson = _box.get(_employeeListKey);
    if (employeeIdsJson == null) return null;
    return (jsonDecode(employeeIdsJson) as List<dynamic>).cast<int>();
  }

  String fetchEmployeeKey(int employeeId) => '$_employeeKeyPrefix$employeeId';
}
