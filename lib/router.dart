import 'package:go_router/go_router.dart';

import 'screens/assignment_form_screen.dart';
import 'screens/assignments_screen.dart';
import 'screens/course_detail_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/schedule_screen.dart';
import 'widgets/app_shell.dart';

/// Карта маршрутов всего приложения (построена один раз → после изменений
/// нужен hot RESTART (R), а не hot reload).
///
/// Порядок важен: маршруты пробуются сверху вниз, поэтому фиксированный
/// '/assignments/new' стоит ПЕРЕД переменным '/assignments/:id'.
final router = GoRouter(
  initialLocation: '/login',
  routes: [
    // Вне shell-а: экран без нижней панели.
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Постоянные вкладки: каждая ветка хранит свой стек и состояние.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        // Вкладка 1: расписание → карточка курса → задания
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const ScheduleScreen(),
            routes: [
              GoRoute(
                path: 'course/:id', // полный адрес: /schedule/course/6
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return CourseDetailScreen(id: id);
                },
              ),
            ],
          ),
        ]),

        // Вкладка 2: список курсов → карточка курса
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/courses',
            builder: (context, state) => const CoursesScreen(),
            routes: [
              GoRoute(
                path: ':id', // полный адрес: /courses/6
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return CourseDetailScreen(id: id);
                },
              ),
            ],
          ),
        ]),

        // Вкладка 3: список заданий
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/assignments',
            builder: (context, state) => const AssignmentsScreen(),
          ),
        ]),

        // Вкладка 4: профиль
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ]),
      ],
    ),

    // Форма задания открывается из нескольких вкладок (список заданий и
    // карточка курса), поэтому лежит поверх shell-а, на весь экран.
    GoRoute(
      path: '/assignments/new', // ФИКСИРОВАННЫЙ — перед ':id'
      builder: (context, state) {
        // Необязательный query-параметр: /assignments/new?courseId=6
        final courseId =
            int.tryParse(state.uri.queryParameters['courseId'] ?? '');
        return AssignmentFormScreen(initialCourseId: courseId);
      },
    ),
    GoRoute(
      path: '/assignments/:id', // редактирование существующего задания
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return AssignmentFormScreen(assignmentId: id);
      },
    ),
  ],
);
