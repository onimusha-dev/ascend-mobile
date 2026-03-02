import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/data/db/app_database.dart';
import 'package:fuck_your_todos/feature/notes/view_models/task_category_view_model.dart';
import 'add_category_dialog.dart';

class CategoryPickerBottomSheet extends ConsumerWidget {
  final List<int> selectedIds;
  final Function(int) onSelect;

  const CategoryPickerBottomSheet({
    super.key,
    required this.selectedIds,
    required this.onSelect,
  });

  void _showCategoryDialog(
    BuildContext context, {
    TaskCategoriesTableData? category,
  }) {
    showDialog(
      context: context,
      builder: (_) => AddCategoryInlineDialog(categoryToEdit: category),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final categoriesState = ref.watch(taskCategoryViewModelProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: cs.outlineVariant.withAlpha(80),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pick Category",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              IconButton(
                onPressed: () => _showCategoryDialog(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add_rounded, color: cs.primary, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: categoriesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
              data: (categories) {
                if (categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 48,
                          color: cs.outline.withAlpha(100),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No categories yet",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: cs.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selectedIds.contains(cat.id);

                    return InkWell(
                      onTap: () {
                        onSelect(cat.id);
                        Navigator.pop(context);
                      },
                      onLongPress: () =>
                          _showCategoryDialog(context, category: cat),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cs.primary.withAlpha(25)
                              : cs.surfaceContainerHighest.withAlpha(80),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? cs.primary : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: cs.surface.withAlpha(100),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                cat.icon,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? cs.primary : cs.onSurface,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: cs.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Text(
            "Long press to edit or delete any category",
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.outline,
              fontStyle: FontStyle.italic,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
