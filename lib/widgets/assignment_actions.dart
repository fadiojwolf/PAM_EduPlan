import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/assignment.dart';
import '../models/assignment_model.dart';

/// Отметка выполнения из любого экрана: read (действие), SnackBar при отказе.
Future<void> toggleAssignmentDone(BuildContext context, Assignment a) async {
  final error = await context.read<AssignmentModel>().toggleDone(a);
  if (error != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }
}
