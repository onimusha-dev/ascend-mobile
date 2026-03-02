import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/data/db/app_database.dart';
import 'package:fuck_your_todos/feature/notes/view_models/task_category_view_model.dart';

class AddCategoryInlineDialog extends ConsumerStatefulWidget {
  final TaskCategoriesTableData? categoryToEdit;
  const AddCategoryInlineDialog({super.key, this.categoryToEdit});

  @override
  ConsumerState<AddCategoryInlineDialog> createState() =>
      _AddCategoryInlineDialogState();
}

class _AddCategoryInlineDialogState
    extends ConsumerState<AddCategoryInlineDialog> {
  late final TextEditingController _nameController;
  late String _selectedEmoji;
  bool _showEmojiPicker = false;

  final List<String> _emojiList = [
    '📝',
    '💼',
    '🎓',
    '🏠',
    '🏋️',
    '✈️',
    '🛒',
    '❤️',
    '💡',
    '🔥',
    '📚',
    '⚽',
    '🎮',
    '🍔',
    '🎨',
    '🚀',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.categoryToEdit?.name ?? '',
    );
    _selectedEmoji = widget.categoryToEdit?.icon ?? '📝';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      if (widget.categoryToEdit != null) {
        await ref
            .read(taskCategoryViewModelProvider.notifier)
            .updateCategory(
              widget.categoryToEdit!.copyWith(name: name, icon: _selectedEmoji),
            );
      } else {
        await ref
            .read(taskCategoryViewModelProvider.notifier)
            .addCategory(name, _selectedEmoji);
      }
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _deleteCategory() async {
    if (widget.categoryToEdit != null) {
      await ref
          .read(taskCategoryViewModelProvider.notifier)
          .deleteCategory(widget.categoryToEdit!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEditing = widget.categoryToEdit != null;

    return Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? "Edit Category" : "New Category",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      onPressed: _deleteCategory,
                      icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
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
                        border: Border.all(
                          color: cs.outlineVariant,
                          width: 1.5,
                        ),
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
                      autofocus: !isEditing,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Category Name',
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _emojiList.length,
                  itemBuilder: (context, index) {
                    final emoji = _emojiList[index];
                    final isSelected = _selectedEmoji == emoji;
                    return InkWell(
                      onTap: () => setState(() {
                        _selectedEmoji = emoji;
                        _showEmojiPicker = false;
                      }),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.primary.withAlpha(40)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? cs.primary
                                : cs.outlineVariant.withAlpha(100),
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
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: cs.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEditing ? "Update" : "Create",
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
