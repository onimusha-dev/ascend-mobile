import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/feature/notes/view_models/task_category_view_model.dart';
import 'package:fuck_your_todos/feature/notes/widgets/create_note/add_category_dialog.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _showCategoryDialog(BuildContext context, {dynamic category}) {
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
            onPressed: () => _showCategoryDialog(context),
            icon: Icon(Icons.add_rounded, color: cs.primary),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Material(
                color: cs.surfaceContainerHighest.withAlpha(80),
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: () => _showCategoryDialog(context, category: cat),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: cs.primary.withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cat.icon,
                            style: const TextStyle(fontSize: 26),
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
                        IconButton(
                          onPressed: () =>
                              _showCategoryDialog(context, category: cat),
                          icon: Icon(
                            Icons.edit_note_rounded,
                            color: cs.primary.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(context),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "New Category",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
