import 'package:flutter/material.dart';

/// Диалог подтверждения. Возвращает true только при явном «Да».
///
/// Закрывается через dialogCtx (а не context экрана): под вложенными
/// навигаторами shell-а pop на context экрана закрыл бы не тот навигатор.
/// Результат сравнивается через `== true`: диалог, закрытый мимо кнопок
/// (тап по фону, «назад»), возвращает null.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text(title),
      content: message != null ? Text(message) : null,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, false),
          child: const Text('Нет'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogCtx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok == true;
}
