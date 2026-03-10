import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ascend/data/db/tables/note_table.dart';
import 'package:ascend/domain/models/note_model.dart';
import 'package:ascend/feature/tasks/view_models/note_view_model.dart';
import 'package:intl/intl.dart';
import 'package:ascend/view_model/gamification_provider.dart';

import 'note_text_field.dart';
import 'category_picker_sheet.dart';
import 'task_setting_tiles.dart';

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
  TaskDifficulty _selectedDifficulty = TaskDifficulty.easy;
  List<int> _selectedCategoryIds = [];

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
    _selectedDifficulty = note?.difficulty ?? TaskDifficulty.easy;

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
          .updateNote(
            note.id,
            title,
            description,
            dueDateStr,
            _selectedDifficulty,
            taskTypeStr,
          );
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
            _selectedDifficulty,
            taskTypeStr,
          );
    }
    if (mounted) Navigator.pop(context);
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryPickerBottomSheet(
        selectedIds: _selectedCategoryIds,
        onSelect: (id) {
          if (!_selectedCategoryIds.contains(id)) {
            setState(() => _selectedCategoryIds.add(id));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle & Header
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Column(
              children: [
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
                        _isEditMode ? 'Edit Task' : 'New Task',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                          letterSpacing: -0.5,
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
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                keyboardHeight > 0 ? keyboardHeight + 24 : bottomPadding + 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Title Input
                  NoteTextField(
                    controller: _titleController,
                    hint: 'What needs to be done?',
                    type: TextFieldType.title,
                  ),
                  const SizedBox(height: 12),
                  // Description Input
                  NoteTextField(
                    controller: _descriptionController,
                    hint: 'Add more details...',
                    type: TextFieldType.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  _buildSectionLabel(context, "Task Details"),
                  const SizedBox(height: 12),

                  // Settings Container
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withAlpha(60),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        // TODO: Fix potential bug where dates in the past can be selected
                        TaskSettingTile(
                          icon: Icons.calendar_today_rounded,
                          label: "Due Date",
                          value: _selectedDateTime != null
                              ? _formatDateTime(_selectedDateTime!)
                              : "Set schedule",
                          color: _selectedDateTime != null
                              ? cs.primary
                              : cs.outline,
                          onTap: _pickDateTime,
                          onClear: _selectedDateTime != null
                              ? () => setState(() => _selectedDateTime = null)
                              : null,
                        ),
                        Divider(
                          height: 1,
                          indent: 64,
                          endIndent: 16,
                          color: cs.outlineVariant.withAlpha(50),
                        ),
                        PrioritySettingTile(
                          priority: _selectedPriority,
                          onSelect: (p) =>
                              setState(() => _selectedPriority = p),
                          cs: cs,
                          theme: theme,
                          priorityIcon: _priorityIcon,
                          priorityLabel: _priorityLabel,
                          priorityColor: _priorityColor,
                        ),
                        Divider(
                          height: 1,
                          indent: 64,
                          endIndent: 16,
                          color: cs.outlineVariant.withAlpha(50),
                        ),
                        CategorySettingTile(
                          selectedIds: _selectedCategoryIds,
                          onTap: _showCategoryPicker,
                          onRemove: (id) =>
                              setState(() => _selectedCategoryIds.remove(id)),
                          cs: cs,
                          theme: theme,
                        ),
                        if (ref.watch(gamificationProvider)) ...[
                          Divider(
                            height: 1,
                            indent: 64,
                            endIndent: 16,
                            color: cs.outlineVariant.withAlpha(50),
                          ),
                          DifficultySettingTile(
                            difficulty: _selectedDifficulty,
                            onSelect: (d) =>
                                setState(() => _selectedDifficulty = d),
                            cs: cs,
                            theme: theme,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: _canSave
                            ? cs.primary
                            : cs.surfaceContainerHighest,
                      ),
                      child: ElevatedButton(
                        onPressed: _canSave ? _save : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canSave
                              ? cs.primary
                              : Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          _isEditMode ? 'UPDATE TASK' : 'CREATE TASK',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            fontSize: 14,
                            color: _canSave
                                ? Colors.white
                                : cs.onSurfaceVariant.withAlpha(100),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.outline,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
