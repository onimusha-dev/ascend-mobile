import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TextFieldType { title, description }

class NoteTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextFieldType type;
  final int maxLines;

  const NoteTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.type,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final maxLength = type == TextFieldType.title ? 50 : 200;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final length = value.text.length;
        final isOverLimit = length > maxLength;
        final showCounter = length > (maxLength * 0.7);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: controller,
              maxLines: maxLines,
              maxLength: maxLength,
              maxLengthEnforcement: MaxLengthEnforcement.none,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurface,
                fontWeight: type == TextFieldType.title
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant.withAlpha(100),
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withAlpha(80),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: isOverLimit ? cs.error : cs.primary.withAlpha(180),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide(
                    color: isOverLimit
                        ? cs.error.withAlpha(100)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                counterText: '',
              ),
            ),
            if (showCounter)
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 8),
                child: Text(
                  '$length / $maxLength',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isOverLimit
                        ? cs.error
                        : cs.onSurfaceVariant.withAlpha(180),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
