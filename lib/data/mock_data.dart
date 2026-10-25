import '../models/assignment.dart';
import '../models/course.dart';


const mockCourses = [
  // ---- Понедельник ----
  Course(
    id: 1,
    name: 'PAM',
    teacher: 'asist. univ. Leah Arcadie',
    room: '215',
    weekday: 1,
    startTime: '09:45',
  ),
  Course(
    id: 2,
    name: 'lab. IP',
    teacher: 'asist. univ. Seniușin Anton',
    room: '215',
    weekday: 1,
    startTime: '11:30',
  ),
  Course(
    id: 3,
    name: 'ASR · нечётная неделя',
    teacher: 'conf. univ., dr. Moraru Victor',
    room: '312',
    weekday: 1,
    startTime: '13:30',
  ),
  Course(
    id: 4,
    name: 'c. Administrarea si securitatea retelelor · чётная неделя',
    teacher: 'conf. univ., dr. Moraru Victor',
    room: '401',
    weekday: 1,
    startTime: '13:30',
  ),
  Course(
    id: 5,
    name: 'CC',
    teacher: 'asist. univ. Kapusteanschi Maxim',
    room: '114',
    weekday: 1,
    startTime: '15:15',
  ),
  // ---- Вторник ----
  Course(
    id: 6,
    name: 'c. PAM',
    teacher: 'asist. univ. Antohi Ionel',
    room: '604',
    weekday: 2,
    startTime: '13:30',
  ),
  Course(
    id: 7,
    name: 'c. Cloud Computing',
    teacher: 'conf. univ., dr. hab. Șișianu Sergiu',
    room: '401',
    weekday: 2,
    startTime: '15:15',
  ),
  Course(
    id: 8,
    name: 'TH',
    teacher: 'asist. univ. Seniușin Anton',
    room: '215',
    weekday: 2,
    startTime: '17:00',
  ),
  // ---- Среда ----
  Course(
    id: 9,
    name: 'TTGE',
    teacher: 'asist. univ. Spatari Andrei',
    room: '215',
    weekday: 3,
    startTime: '17:00',
  ),
  Course(
    id: 10,
    name: 'c. Tehnici și tehnologii de guvernare electronică',
    teacher: 'lect. univ. Croitor Elena',
    room: '101',
    weekday: 3,
    startTime: '18:45',
  ),
  // ---- Четверг ----
  Course(
    id: 11,
    name: 'c. Administrarea si securitatea retelelor',
    teacher: 'conf. univ., dr. Moraru Victor',
    room: '401',
    weekday: 4,
    startTime: '13:30',
  ),
  Course(
    id: 12,
    name: 'c. Ingineria programării',
    teacher: 'conf. univ., dr. Cărbune Viorel',
    room: '401',
    weekday: 4,
    startTime: '15:15',
  ),
  Course(
    id: 13,
    name: 'lab. ASR',
    teacher: 'asist. univ. Seniușin Anton',
    room: '114',
    weekday: 4,
    startTime: '17:00',
  ),
  // ---- Пятница ----
  Course(
    id: 14,
    name: 'c. Testare Hardware',
    teacher: 'conf. univ., dr. Sudacevschi Viorica',
    room: '401',
    weekday: 5,
    startTime: '11:30',
  ),
  Course(
    id: 15,
    name: 'c. Proiectarea sistemelor încorporate',
    teacher: 'conf. univ., dr. Calmîcov Igor',
    room: '310',
    weekday: 5,
    startTime: '13:30',
  ),
  Course(
    id: 16,
    name: 'lab. PSÎ',
    teacher: 'conf. univ., dr. Calmîcov Igor',
    room: '215',
    weekday: 5,
    startTime: '15:15',
  ),
];

// DateTime не является const-конструктором, поэтому список — final.
final mockAssignments = <Assignment>[
  Assignment(
    id: 1,
    courseId: 1, // PAM
    title: 'Лабораторная 2: статический UI приложения',
    deadline: DateTime(2026, 10, 24),
    status: AssignmentStatus.inProgress,
    priority: Priority.high,
  ),
  Assignment(
    id: 2,
    courseId: 2, // lab. IP
    title: 'Отчёт по лабораторной: UML-диаграммы проекта',
    deadline: DateTime(2026, 10, 21),
    status: AssignmentStatus.todo,
    priority: Priority.high,
  ),
  Assignment(
    id: 3,
    courseId: 13, // lab. ASR
    title: 'Отчёт: настройка OSPF и маршрутизации',
    deadline: DateTime(2026, 10, 28),
    status: AssignmentStatus.todo,
    priority: Priority.medium,
  ),
  Assignment(
    id: 4,
    courseId: 5, // CC
    title: '30% проекта ',
    deadline: DateTime(2026, 11, 2),
    status: AssignmentStatus.inProgress,
    priority: Priority.high,
  ),
  Assignment(
    id: 5,
    courseId: 8, // TH
    title: '',
    deadline: DateTime(2026, 10, 19),
    status: AssignmentStatus.done,
    priority: Priority.medium,
  ),
  Assignment(
    id: 6,
    courseId: 9, // TTGE
    title: 'Создание, предоставление и отзыв электронной доверенности с использованием платформы MPower.',
    deadline: DateTime(2026, 11, 5),
    status: AssignmentStatus.todo,
    priority: Priority.medium,
  ),
  Assignment(
    id: 7,
    courseId: 16, // lab. PSÎ
    title: 'Лабораторная: работа с GPIO микроконтроллера',
    deadline: DateTime(2026, 10, 23),
    status: AssignmentStatus.todo,
    priority: Priority.low,
  ),
  Assignment(
    id: 8,
    courseId: 12, // c. Ingineria programării
    title: '',
    deadline: DateTime(2026, 11, 10),
    status: AssignmentStatus.done,
    priority: Priority.low,
  ),
];

Course courseById(int id) => mockCourses.firstWhere((c) => c.id == id);

Assignment assignmentById(int id) =>
    mockAssignments.firstWhere((a) => a.id == id);
