import 'package:flutter/material.dart';
import 'package:tectonas_ems/core/di/initial_dependencies.dart';
import 'package:tectonas_ems/employee/listing-submodule/screen/employee_listing_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.indigoAccent)),
      home: const EmployeeListingScreen(),
    );
  }
}
