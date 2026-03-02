import 'package:flutter/material.dart';
import 'package:ascend/core/constants/constants.dart';

class CustomEmojiPicker extends StatelessWidget {
  final String selectedEmoji;
  final ValueChanged<String> onEmojiSelected;

  const CustomEmojiPicker({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withAlpha(50)),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: CategoryIcons.premiumIcons.length,
        itemBuilder: (context, index) {
          final iconCode = CategoryIcons.premiumIcons[index];
          final isSelected = iconCode == selectedEmoji;

          return InkWell(
            onTap: () => onEmojiSelected(iconCode),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primary.withAlpha(30)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? cs.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                CategoryIcons.iconMap[iconCode] ?? Icons.category_rounded,
                size: 24,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}
