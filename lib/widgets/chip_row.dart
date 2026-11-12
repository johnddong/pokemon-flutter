import 'package:flutter/material.dart';
import 'package:pokemon/extensions/string_capitalized.dart';
import 'package:pokemon/theme/spacing.dart';

class ChipRow extends StatelessWidget {
  const ChipRow({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.colorOf,
  });

  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelected;
  final Color Function(String item)? colorOf;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0,
        AppSpacing.belowTitle,
        0,
        AppSpacing.belowTitle,
      ),
      child: SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.gridGap),
          itemBuilder: (context, index) {
            final item = items[index];
            final color = colorOf?.call(item);
            final isSelected = item == selected;
            final colorScheme = Theme.of(context).colorScheme;
            final fill = colorScheme.surfaceContainerLowest;
            final accent = color ?? colorScheme.onSurface;

            return ChoiceChip(
              avatar: color == null
                  ? null
                  : Icon(Icons.circle, size: 10, color: color),
              label: Text(item.capitalized),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: fill,
              backgroundColor: fill,
              labelStyle: TextStyle(
                color: isSelected ? accent : colorScheme.onSurfaceVariant,
              ),
              side: BorderSide(color: isSelected ? accent : fill),
              onSelected: isSelected ? (_) {} : (_) => onSelected(item),
            );
          },
        ),
      ),
    );
  }
}
