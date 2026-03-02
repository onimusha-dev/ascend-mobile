import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/feature/notes/view_models/task_category_view_model.dart';

class AddCategoryInlineDialog extends ConsumerStatefulWidget {
  const AddCategoryInlineDialog({super.key});

  @override
  ConsumerState<AddCategoryInlineDialog> createState() =>
      _AddCategoryInlineDialogState();
}

class _AddCategoryInlineDialogState
    extends ConsumerState<AddCategoryInlineDialog> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '📝';
  bool _showEmojiPicker = false;

  final List<String> _emojiList = [
    '📝',
    '💼',
    '🛒',
    '🏠',
    '❤️',
    '💡',
    '🔥',
    '📚',
    '⚽',
    '✈️',
    '🎮',
    '🍔',
    '🎨',
    '🚀',
    '🏖️',
    '🏋️',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      await ref
          .read(taskCategoryViewModelProvider.notifier)
          .addCategory(name, _selectedEmoji);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "New Category",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      setState(() => _showEmojiPicker = !_showEmojiPicker),
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withAlpha(120),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Work, Home, etc.',
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withAlpha(80),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cs.primary, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showEmojiPicker) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _emojiList.length,
                  itemBuilder: (context, index) {
                    final emoji = _emojiList[index];
                    return InkWell(
                      onTap: () => setState(() {
                        _selectedEmoji = emoji;
                        _showEmojiPicker = false;
                      }),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedEmoji == emoji
                              ? cs.primary.withAlpha(40)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedEmoji == emoji
                                ? cs.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: cs.outline)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Create"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
