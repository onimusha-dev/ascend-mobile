import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuck_your_todos/data/db/tables/note_table.dart';
import 'package:fuck_your_todos/domain/models/note_model.dart';
import 'package:fuck_your_todos/feature/notes/view_models/note_view_model.dart';
import 'package:fuck_your_todos/feature/notes/view_models/task_category_view_model.dart';
import 'package:intl/intl.dart';

import 'note_chip.dart';
import 'note_text_field.dart';
import 'add_category_dialog.dart';

class CreateNoteView extends ConsumerStatefulWidget {
  final NoteModel? noteToEdit;
  final DateTime? initialDate;

  const CreateNoteView({super.key, this.noteToEdit, this.initialDate});

  @override
  ConsumerState<CreateNoteView> createState() => _CreateNoteViewState();
}

class _CreateNoteViewState extends ConsumerState<CreateNoteView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _selectedDateTime;
  Priority _selectedPriority = Priority.none;
  List<int> _selectedCategoryIds = [];

  final _priorityMenuKey = GlobalKey<PopupMenuButtonState<Priority>>();
  final _categoryMenuKey = GlobalKey<PopupMenuButtonState<int>>();

  bool get _isEditMode => widget.noteToEdit != null;

  bool get _canSave {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    return title.isNotEmpty && title.length <= 50 && description.length <= 200;
  }

  @override
  void initState() {
    super.initState();
    final note = widget.noteToEdit;
    _titleController = TextEditingController(text: note?.title ?? '')
      ..addListener(_onTitleChanged);
    _descriptionController = TextEditingController(
      text: note?.description ?? '',
    );
    _selectedDateTime = note?.dueDate ?? widget.initialDate;
    _selectedPriority = note?.priority ?? Priority.none;

    // Parse categories from comma-separated string
    if (note?.taskType != null && note!.taskType!.isNotEmpty) {
      _selectedCategoryIds = note.taskType!
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList();
    }
  }

  void _onTitleChanged() => setState(() {});

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Color _priorityColor(Priority p, ColorScheme cs) {
    return switch (p) {
      Priority.high => cs.error,
      Priority.medium => cs.tertiary,
      Priority.low => cs.primary,
      Priority.none => cs.outline,
    };
  }

  String _priorityLabel(Priority p) {
    return switch (p) {
      Priority.high => 'High',
      Priority.medium => 'Medium',
      Priority.low => 'Low',
      Priority.none => 'Priority',
    };
  }

  IconData _priorityIcon(Priority p) {
    return switch (p) {
      Priority.high => Icons.flag_rounded,
      Priority.medium => Icons.flag_outlined,
      Priority.low => Icons.outlined_flag,
      Priority.none => Icons.outlined_flag_rounded,
    };
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today, ${DateFormat('h:mm a').format(dt)}';
    }
    return DateFormat('MMM d, h:mm a').format(dt);
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedDateTime != null
          ? TimeOfDay.fromDateTime(_selectedDateTime!)
          : TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final dueDateStr = _selectedDateTime?.toIso8601String();
    final taskTypeStr = _selectedCategoryIds.isEmpty
        ? null
        : _selectedCategoryIds.join(',');

    if (_isEditMode) {
      final note = widget.noteToEdit!;
      await ref
          .read(noteViewModelProvider.notifier)
          .updateNote(note.id, title, description, dueDateStr, taskTypeStr);
      if (_selectedPriority != note.priority) {
        await ref
            .read(noteViewModelProvider.notifier)
            .updateNotePriority(note.id, _selectedPriority);
      }
    } else {
      await ref
          .read(noteViewModelProvider.notifier)
          .insertNote(
            title,
            description,
            dueDateStr,
            _selectedPriority,
            taskTypeStr,
          );
    }
    if (mounted) Navigator.pop(context);
  }

  void _showAddCategory() {
    showDialog(
      context: context,
      builder: (_) => const AddCategoryInlineDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: keyboardHeight > 0 ? keyboardHeight + 16 : bottomPadding + 32,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ──
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: cs.outlineVariant.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──
          Row(
            children: [
              Text(
                _isEditMode ? 'Edit Task' : 'New Task',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              if (_isEditMode)
                Text(
                  "UNFINISHED",
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.primary.withAlpha(180),
                    letterSpacing: 1.2,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Input Fields ──
          NoteTextField(
            controller: _titleController,
            hint: 'E.g. Design app screens…',
            type: TextFieldType.title,
          ),
          const SizedBox(height: 16),
          NoteTextField(
            controller: _descriptionController,
            hint: 'Notes or subtasks…',
            type: TextFieldType.description,
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // ── Row 1: Date & Priority ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                NoteChip(
                  icon: Icons.calendar_month_rounded,
                  label: _selectedDateTime != null
                      ? _formatDateTime(_selectedDateTime!)
                      : 'Set Due Date',
                  color: _selectedDateTime != null
                      ? cs.primary
                      : cs.onSurfaceVariant.withAlpha(150),
                  onTap: _pickDateTime,
                  onClear: _selectedDateTime != null
                      ? () => setState(() => _selectedDateTime = null)
                      : null,
                ),
                const SizedBox(width: 10),
                PopupMenuButton<Priority>(
                  key: _priorityMenuKey,
                  onSelected: (p) => setState(() => _selectedPriority = p),
                  offset: const Offset(0, -180),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: NoteChip(
                    icon: _priorityIcon(_selectedPriority),
                    label: _priorityLabel(_selectedPriority),
                    color: _selectedPriority == Priority.none
                        ? cs.onSurfaceVariant.withAlpha(150)
                        : _priorityColor(_selectedPriority, cs),
                    onTap: () {
                      if (_selectedPriority != Priority.none) {
                        setState(() => _selectedPriority = Priority.none);
                      } else {
                        _priorityMenuKey.currentState?.showButtonMenu();
                      }
                    },
                  ),
                  itemBuilder: (_) =>
                      [Priority.high, Priority.medium, Priority.low]
                          .map(
                            (p) => PopupMenuItem(
                              value: p,
                              child: Row(
                                children: [
                                  Icon(
                                    _priorityIcon(p),
                                    color: _priorityColor(p, cs),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _priorityLabel(p),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Row 2: Categories (Up to 3) ──
          Consumer(
            builder: (context, ref, _) {
              final categoriesState = ref.watch(taskCategoryViewModelProvider);
              return categoriesState.maybeWhen(
                data: (categories) {
                  final selectedCats = categories
                      .where((c) => _selectedCategoryIds.contains(c.id))
                      .toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        ...selectedCats.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: NoteChip(
                              icon: Icons.category_rounded,
                              label: '${c.icon} ${c.name}',
                              color: cs.primary,
                              onClear: () => setState(
                                () => _selectedCategoryIds.remove(c.id),
                              ),
                            ),
                          ),
                        ),
                        if (_selectedCategoryIds.length < 3)
                          PopupMenuButton<int>(
                            key: _categoryMenuKey,
                            onSelected: (id) {
                              if (id == -1) {
                                _showAddCategory();
                              } else if (!_selectedCategoryIds.contains(id)) {
                                setState(() => _selectedCategoryIds.add(id));
                              }
                            },
                            offset: const Offset(0, -180),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            itemBuilder: (_) => [
                              ...categories
                                  .where(
                                    (c) => !_selectedCategoryIds.contains(c.id),
                                  )
                                  .map(
                                    (c) => PopupMenuItem(
                                      value: c.id,
                                      child: Row(
                                        children: [
                                          Text(
                                            c.icon,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            c.name,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              if (categories.isNotEmpty)
                                const PopupMenuDivider(),
                              PopupMenuItem(
                                value: -1,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add_rounded,
                                      color: cs.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "New Category",
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: cs.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: NoteChip(
                              icon: Icons.add_circle_outline_rounded,
                              label: _selectedCategoryIds.isEmpty
                                  ? 'Category'
                                  : 'Add',
                              color: cs.onSurfaceVariant.withAlpha(150),
                              onTap: () => _categoryMenuKey.currentState
                                  ?.showButtonMenu(),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              );
            },
          ),
          const SizedBox(height: 32),

          // ── Save Button ──
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _canSave ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: cs.surfaceContainerHighest,
              ),
              child: Text(
                _isEditMode ? 'Update Task' : 'Create Task',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
