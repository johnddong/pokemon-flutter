// ChipRow skeleton
import 'package:flutter/material.dart';
import 'package:pokemon/theme/spacing.dart';
import 'package:pokemon/theme/type_colors.dart';

class ChipRowSkeleton extends StatelessWidget {
  const ChipRowSkeleton({super.key, this.itemCount = 8});

  final int itemCount;

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
          itemCount: itemCount,
          separatorBuilder: (_, __) =>
              const SizedBox(width: AppSpacing.gridGap),
          itemBuilder: (_, __) => Material(
            color: cardSurface(Theme.of(context).colorScheme),
            borderRadius: BorderRadius.circular(8),
            child: const SizedBox(width: 100, height: 44),
          ),
        ),
      ),
    );
  }
}
