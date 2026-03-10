import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/core/theme/app_themes.dart';
import 'package:ascend/core/theme/theme_provider.dart';

class ThemePreviewCard extends ConsumerWidget {
  final AppThemePreset preset;
  final bool isSelected;
  final bool pureDark;

  const ThemePreviewCard({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.pureDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final previewCs = ColorScheme.fromSeed(
      seedColor: preset.seedColor,
      brightness: Theme.of(context).brightness,
    );

    final cardBg = isDark && pureDark ? Colors.black : previewCs.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => ref.read(themeProvider.notifier).setPreset(preset),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 180,
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? previewCs.primary
                    : previewCs.outlineVariant.withAlpha(100),
                width: isSelected ? 3 : 1,
              ),
            ),
            child: _PreviewContent(previewCs: previewCs),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            preset.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected
                  ? previewCs.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

/// Builds the content of the theme preview card.
class _PreviewContent extends StatelessWidget {
  final ColorScheme previewCs;
  const _PreviewContent({required this.previewCs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 12,
              width: 45,
              decoration: BoxDecoration(
                color: previewCs.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: previewCs.secondaryContainer,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // HACK: Fake task lines manually generated. Consider abstracting if used elsewhere.
        _fakeTask(previewCs, 0.8),
        const SizedBox(height: 6),
        _fakeTask(previewCs, 0.5),
        const SizedBox(height: 6),
        _fakeTask(previewCs, 0.7, done: true),
        const Spacer(),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: previewCs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 14,
              color: previewCs.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

/// Builds a fake task for the theme preview card.
Widget _fakeTask(ColorScheme cs, double width, {bool done = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: done
          ? cs.surfaceContainerHighest.withAlpha(40)
          : cs.surfaceContainerHighest.withAlpha(80),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: done ? Colors.transparent : cs.primary.withAlpha(50),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        if (!done)
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
          )
        else
          Icon(Icons.check_circle_rounded, size: 10, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(
                widthFactor: width,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: done ? cs.outline : cs.onSurface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant.withAlpha(100),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
