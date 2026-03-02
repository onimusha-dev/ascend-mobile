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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(28),
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
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      fontSize: 22,
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      onPressed: _deleteCategory,
                      style: IconButton.styleFrom(
                        backgroundColor: cs.error.withValues(alpha: 0.1),
                        foregroundColor: cs.error,
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Emoji Circle
              Center(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _showEmojiPicker = !_showEmojiPicker),
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withAlpha(100),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.primary.withAlpha(50),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  "Tap to pick emoji",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant.withAlpha(150),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              if (_showEmojiPicker) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withAlpha(40),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
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
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cs.primary.withAlpha(40)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? cs.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 32),

              TextField(
                controller: _nameController,
                autofocus: !isEditing,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: 'Category Name',
                  hintStyle: TextStyle(
                    color: cs.onSurfaceVariant.withAlpha(100),
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withAlpha(80),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: cs.primary.withAlpha(150),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isEditing ? "UPDATE CATEGORY" : "SAVE CATEGORY",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withAlpha(150),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
