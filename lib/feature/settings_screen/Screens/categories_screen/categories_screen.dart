import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/feature/tasks/view_models/task_category_view_model.dart';
import 'package:ascend/core/utils/icon_utils.dart';
import 'package:ascend/core/constants/constants.dart';
import 'package:ascend/feature/settings_screen/Screens/categories_screen/widgets/custom_emoji_picker.dart';
import 'package:ascend/data/db/app_database.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final categoriesState = ref.watch(taskCategoryViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Categories',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: cs.primary,
            size: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: cs.surface,
                    title: const Text('Reset Categories?'),
                    content: const Text(
                      'This will delete all custom categories and restore the default list. Are you sure?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(taskCategoryViewModelProvider.notifier)
                              .resetToDefault();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Categories reset to default',
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: cs.primaryContainer,
                            ),
                          );
                        },
                        child: Text(
                          'RESET',
                          style: TextStyle(
                            color: cs.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(
              Icons.restore_rounded,
              color: cs.onSurfaceVariant,
              size: 24,
            ),
            tooltip: 'Reset to Defaults',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: categoriesState.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: cs.outline.withAlpha(50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories yet',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return CategoryListItem(cat: categories[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 48.0), // moved up slightly
        child: FloatingActionButton(
          onPressed: () {
            ref
                .read(taskCategoryViewModelProvider.notifier)
                .addCategory('Untitled', '58905'); // Icons.work_rounded
          },
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}

class CategoryListItem extends ConsumerStatefulWidget {
  final TaskCategoriesTableData cat;
  const CategoryListItem({super.key, required this.cat});

  @override
  ConsumerState<CategoryListItem> createState() => _CategoryListItemState();
}

class _CategoryListItemState extends ConsumerState<CategoryListItem> {
  final LayerLink _iconLink = LayerLink();
  final LayerLink _editLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showIconPicker() {
    _removeOverlay();
    final cs = Theme.of(context).colorScheme;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    // Determine if we should show above or below
    bool showAbove = (offset.dy + size.height + 260) > screenHeight;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _removeOverlay,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: 300,
            child: CompositedTransformFollower(
              link: _iconLink,
              showWhenUnlinked: false,
              targetAnchor: showAbove
                  ? Alignment.topLeft
                  : Alignment.bottomLeft,
              followerAnchor: showAbove
                  ? Alignment.bottomLeft
                  : Alignment.topLeft,
              offset: Offset(0, showAbove ? -10 : 10),
              child: Material(
                elevation: 12,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(24),
                color: cs.surface,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: CustomEmojiPicker(
                    selectedEmoji: widget.cat.icon,
                    onEmojiSelected: (emoji) {
                      String newName = widget.cat.name;
                      if (newName == "Untitled" || newName.isEmpty) {
                        for (var item in CategoryIcons.predefinedCategories) {
                          if (item['icon'] == emoji) {
                            newName = item['name']!;
                            break;
                          }
                        }
                      }
                      ref
                          .read(taskCategoryViewModelProvider.notifier)
                          .updateCategory(
                            widget.cat.copyWith(icon: emoji, name: newName),
                          );
                      _removeOverlay();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _showEditOptions() {
    _removeOverlay();
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final controller = TextEditingController(text: widget.cat.name);
    String currentIcon = widget.cat.icon;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        'Edit Category',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),
                      const Spacer(),
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
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showIconPickerInSheet(context, currentIcon, (
                            newIcon,
                          ) {
                            setSheetState(() => currentIcon = newIcon);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withAlpha(100),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconUtils.buildCategoryIcon(
                            currentIcon,
                            color: cs.primary,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          autofocus: true,
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
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          ref
                              .read(taskCategoryViewModelProvider.notifier)
                              .deleteCategory(widget.cat.id);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Delete Category",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: cs.primary,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (controller.text.trim().isNotEmpty) {
                                ref
                                    .read(
                                      taskCategoryViewModelProvider.notifier,
                                    )
                                    .updateCategory(
                                      widget.cat.copyWith(
                                        name: controller.text.trim(),
                                        icon: currentIcon,
                                      ),
                                    );
                              }
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'SAVE CHANGES',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showIconPickerInSheet(
    BuildContext context,
    String currentIcon,
    Function(String) onSelected,
  ) {
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
              selectedEmoji: currentIcon,
              onEmojiSelected: (iconCode) {
                onSelected(iconCode);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cat = widget.cat;

    return Material(
      color: cs.surfaceContainerHighest.withAlpha(80),
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CompositedTransformTarget(
              link: _iconLink,
              child: GestureDetector(
                onTap: _showIconPicker,
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: cs.primary.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: IconUtils.buildCategoryIcon(
                    cat.icon,
                    size: 22,
                    color: cs.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                cat.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ),
            CompositedTransformTarget(
              link: _editLink,
              child: IconButton(
                onPressed: _showEditOptions,
                icon: Icon(
                  Icons.edit_note_rounded,
                  color: cs.primary.withAlpha(150),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
