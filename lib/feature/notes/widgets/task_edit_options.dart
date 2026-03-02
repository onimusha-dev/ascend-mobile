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
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull Bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Text(
                "Task Actions",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: cs.onSurface.withAlpha(150),
                ),
              ),
              const SizedBox(height: 24),

              _OptionItem(
                label: isCompleted ? "Mark as Unfinished" : "Mark as Completed",
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
              const SizedBox(height: 12),

              _OptionItem(
                label: "Edit Task Details",
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
              const SizedBox(height: 12),

              _OptionItem(
                label: "Delete Permanently",
                icon: Icons.delete_forever_rounded,
                color: cs.error,
                isCritical: true,
                onTap: () {
                  ref.read(noteViewModelProvider.notifier).deleteNote(id);
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
      color: isCritical
          ? color.withAlpha(20)
          : cs.surfaceContainerHighest.withAlpha(100),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isCritical ? 0.3 : 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
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
