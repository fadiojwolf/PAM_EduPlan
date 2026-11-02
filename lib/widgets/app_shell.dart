import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/assignment_model.dart';

/// Обёртка с постоянными вкладками. Значок на вкладке «Задания» —
/// невыполненные задания: «живой угол» через Consumer.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_view_week_outlined),
            selectedIcon: Icon(Icons.calendar_view_week),
            label: 'Расписание',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Курсы',
          ),
          NavigationDestination(
            icon: _PendingBadge(icon: Icon(Icons.assignment_outlined)),
            selectedIcon: _PendingBadge(icon: Icon(Icons.assignment)),
            label: 'Задания',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  final Widget icon;

  const _PendingBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssignmentModel>(
      builder: (context, model, child) {
        final n = model.pendingCount;
        return Badge(
          label: Text('$n'),
          isLabelVisible: n > 0,
          child: child!,
        );
      },
      child: icon, // иконка не перестраивается — строится один раз
    );
  }
}
