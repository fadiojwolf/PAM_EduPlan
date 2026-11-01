import 'package:flutter/material.dart';

/// Горизонтальный ряд фильтров-чипов. Выбранный индекс хранит экран
/// (эфемерное состояние → setState), виджет только рисует и сообщает о нажатии.
class FilterChipsRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const FilterChipsRow({
    super.key,
    required this.labels,
    this.selectedIndex = 0,
    this.onSelected,
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
          onSelected: (_) => onSelected?.call(i),
        ),
      ),
    );
  }
}
