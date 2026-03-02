import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/data/db/app_database.dart';
import 'package:ascend/feature/tasks/view_models/task_category_view_model.dart';
import 'package:ascend/core/utils/icon_utils.dart';
import 'package:ascend/feature/settings_screen/Screens/categories_screen/widgets/custom_emoji_picker.dart';
import 'package:ascend/core/constants/constants.dart';

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
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.categoryToEdit?.name ?? '',
    );
    _selectedIcon =
        widget.categoryToEdit?.icon ?? '58905'; // Icons.work_rounded
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
              widget.categoryToEdit!.copyWith(name: name, icon: _selectedIcon),
            );
      } else {
        await ref
            .read(taskCategoryViewModelProvider.notifier)
            .addCategory(name, _selectedIcon);
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

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Icon",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 24),
            CustomEmojiPicker(
              selectedEmoji: _selectedIcon,
              onEmojiSelected: (iconCode) {
                setState(() {
                  _selectedIcon = iconCode;

                  // Auto-fill logic
                  if (_nameController.text.isEmpty ||
                      _nameController.text == "Untitled") {
                    for (var item in CategoryIcons.predefinedCategories) {
                      if (item['icon'] == iconCode) {
                        _nameController.text = item['name']!;
                        break;
                      }
                    }
                  }
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isEditing = widget.categoryToEdit != null;

    return Dialog(
      backgroundColor: cs.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                      fontSize: 20,
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
                    )
                  else
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: cs.surfaceContainerHighest.withAlpha(
                          100,
                        ),
                        padding: const EdgeInsets.all(8),
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        color: cs.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  GestureDetector(
                    onTap: _showIconPicker,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withAlpha(100),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconUtils.buildCategoryIcon(
                        _selectedIcon,
                        color: cs.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      autofocus: !isEditing,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Category Name',
                        hintStyle: TextStyle(
                          color: cs.onSurfaceVariant.withAlpha(100),
                        ),
                        filled: true,
                        fillColor: cs.surfaceContainerHighest.withAlpha(50),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ],
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
