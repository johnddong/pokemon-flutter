import 'package:flutter/material.dart';
import 'package:pokemon/theme/spacing.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (subtitle != null || trailing != null)
            Row(
              children: [
                if (subtitle != null) Text(subtitle!, style: subtitleStyle),
                const Spacer(),
                if (trailing != null) Text(trailing!, style: subtitleStyle),
              ],
            ),
        ],
      ),
    );
  }
}
