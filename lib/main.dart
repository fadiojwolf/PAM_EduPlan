import 'package:flutter/material.dart';
import 'router.dart';

void main() => runApp(const EduPlanApp());

class EduPlanApp extends StatelessWidget {
  const EduPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    // L3: навигацию принимает router, параметр home: исчез.
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
