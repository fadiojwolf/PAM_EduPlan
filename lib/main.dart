import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() => runApp(const EduPlanApp());

class EduPlanApp extends StatelessWidget {
  const EduPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduPlan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Seed-цвет: насыщенный индиго — «учебный», спокойный, хорошо читается.
        // Вся палитра приложения выводится из этого одного цвета.
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3949AB)),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
