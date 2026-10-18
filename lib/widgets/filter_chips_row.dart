import 'package:flutter/material.dart';

/// Горизонтальный ряд фильтров-чипов (визуальный элемент; логика — на L4).
/// Используется на экранах «Курсы» и «Задания».
class FilterChipsRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;

  const FilterChipsRow({
    super.key,
    required this.labels,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => ChoiceChip(
          label: Text(labels[i]),
          selected: i == selectedIndex,
          onSelected: (_) {}, // на L2 без эффекта
        ),
      ),
    );
  }
}
