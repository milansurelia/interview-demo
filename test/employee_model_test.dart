import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:tectonas_ems/core/cache/employee_cache.dart';
import 'package:tectonas_ems/employee/model/employee_model.dart';

void main() {
  test('employee JSON serialization and Hive cache round-trip', () async {
    final employee = EmployeeModel.fromMap({
      'id': 7,
      'name': 'Taylor Morgan',
      'username': 'taylorm',
      'email': 'taylor@example.com',
      'address': {
        'street': 'Main Street',
        'suite': 'Suite 4',
        'city': 'Springfield',
        'zipcode': '12345',
        'geo': {'lat': '10.0', 'lng': '20.0'},
      },
      'phone': '555-0100',
      'website': 'example.com',
      'company': {
        'name': 'Example Inc',
        'catchPhrase': 'Building useful things',
        'bs': 'technology',
      },
    });

    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'employee_cache_test_',
    );
    try {
      Hive.init(temporaryDirectory.path);
      final box = await Hive.openBox<String>('employee_cache_test');
      try {
        final cache = HiveOfflineService(box: box);
        await cache.saveEmployee(employee);

        expect(EmployeeModel.fromJson(employee.toJson()), employee);
        expect(cache.fetchEmployee(employee.id), employee);
        expect(cache.fetchEmployeeList(), [employee]);
      } finally {
        await box.close();
      }
    } finally {
      await temporaryDirectory.delete(recursive: true);
    }
  });
}
