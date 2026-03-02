import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';
import 'package:fuck_your_todos/feature/notes/widgets/create_note/create_note_view.dart';

void showTaskOptions(
  BuildContext context,
  WidgetRef ref,
  int id,
  bool isCompleted,
) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle & Header
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      "Task Actions",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
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

              // Options Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withAlpha(60),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      _OptionItem(
                        label: isCompleted
                            ? "Mark as Unfinished"
                            : "Mark Complete",
                        icon: isCompleted
                            ? Icons.undo_rounded
                            : Icons.check_circle_rounded,
                        color: isCompleted ? cs.tertiary : cs.primary,
                        onTap: () {
                          ref
                              .read(noteViewModelProvider.notifier)
                              .toggleNoteCompletion(id);
                          Navigator.pop(context);
                        },
                      ),
                      Divider(
                        height: 1,
                        indent: 72,
                        endIndent: 24,
                        color: cs.outlineVariant.withAlpha(50),
                      ),
                      _OptionItem(
                        label: "Edit Details",
                        icon: Icons.edit_note_rounded,
                        color: cs.secondary,
                        onTap: () {
                          final taskState = ref.read(noteViewModelProvider);
                          final actualNote = taskState.notes.firstWhere(
                            (t) => t.id == id,
                          );
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            enableDrag: false,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                CreateNoteView(noteToEdit: actualNote),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        indent: 72,
                        endIndent: 24,
                        color: cs.outlineVariant.withAlpha(50),
                      ),
                      _OptionItem(
                        label: "Delete Task",
                        icon: Icons.delete_forever_rounded,
                        color: cs.error,
                        isCritical: true,
                        onTap: () {
                          ref
                              .read(noteViewModelProvider.notifier)
                              .deleteNote(id);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Task deleted successfully'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: cs.errorContainer,
                              showCloseIcon: true,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _OptionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isCritical;

  const _OptionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCritical ? color.withAlpha(20) : cs.surface,
                  shape: BoxShape.circle,
                  border: isCritical
                      ? null
                      : Border.all(color: cs.outlineVariant.withAlpha(50)),
                  boxShadow: isCritical
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 10,
                          ),
                        ],
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isCritical ? color : cs.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant.withAlpha(100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
