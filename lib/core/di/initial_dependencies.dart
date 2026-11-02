import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:tectonas_ems/core/cache/employee_cache.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  const employeeBoxName = 'employee_cache';
  await Hive.initFlutter();
  final employeeBox = Hive.isBoxOpen(employeeBoxName)
      ? Hive.box<String>(employeeBoxName)
      : await Hive.openBox<String>(employeeBoxName);

  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(Dio.new);
  }
  if (!getIt.isRegistered<HiveOfflineService>()) {
    getIt.registerSingleton<HiveOfflineService>(
      HiveOfflineService(box: employeeBox),
    );
  }
}
