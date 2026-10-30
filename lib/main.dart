import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/mock_assignment_repository.dart';
import 'data/mock_course_repository.dart';
import 'data/mock_network.dart';
import 'models/assignment_model.dart';
import 'models/course_model.dart';
import 'router.dart';


void main() {
  final network = MockNetwork();
  final courseRepository = MockCourseRepository(network);
  final assignmentRepository = MockAssignmentRepository(network);

  runApp(
    MultiProvider(
      providers: [
        // леса демонстрации аварии — исчезают на L5
        Provider<MockNetwork>.value(value: network),
        ChangeNotifierProvider(
          create: (_) => CourseModel(courseRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => AssignmentModel(assignmentRepository)..load(),
        ),
      ],
      child: const EduPlanApp(),
    ),
  );
}

class EduPlanApp extends StatelessWidget {
  const EduPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EduPlan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3949AB)),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      routerConfig: router,
    );
  }
}
