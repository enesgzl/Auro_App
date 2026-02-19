import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../data/models/task_model.dart';
import '../../../data/providers/task_provider.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const AddTaskSheet({super.key, this.initialDate});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(
    text: '30',
  ); // Default 30 min
  int _detectedDifficulty = 3;
  bool _showDifficultyHint = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    final title = _titleController.text;
    if (title.isNotEmpty) {
      final newDifficulty = Task.calculateDifficultyFromTitle(title);
      if (newDifficulty != _detectedDifficulty) {
        setState(() {
          _detectedDifficulty = newDifficulty;
          _showDifficultyHint = true;
        });
        HapticFeedback.selectionClick();
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentTeal,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      difficultyScore: _detectedDifficulty,
      createdAt: DateTime.now(),
      dueDate: _selectedDate ?? DateTime.now(),
      duration: int.tryParse(_durationController.text) ?? 30,
    );

    await ref.read(taskProvider.notifier).addTask(task);
    HapticFeedback.mediumImpact();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Harika! Yeni bir hedef belirledin 🚀',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppTheme.accentTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Color _getDifficultyColor() {
    switch (_detectedDifficulty) {
      case 1:
        return const Color(0xFF4ECDC4);
      case 2:
        return const Color(0xFF95E1D3);
      case 3:
        return const Color(0xFFFFD93D);
      case 4:
        return const Color(0xFFFF8B5A);
      case 5:
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFFFFD93D);
    }
  }

  String _getDifficultyLabel() {
    switch (_detectedDifficulty) {
      case 1:
        return 'Çok Kolay';
      case 2:
        return 'Kolay';
      case 3:
        return 'Orta';
      case 4:
        return 'Zor';
      case 5:
        return 'Çok Zor';
      default:
        return 'Orta';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isDark = AppTheme.isDark(context);
    final textPrimary = AppTheme.textPrimary(context);
    final textSecondary = AppTheme.textSecondary(context);
    final surfaceColor = isDark ? Colors.white : Colors.black;

    return GlassmorphicContainer(
      width: double.infinity,
      height: 500 + bottomPadding, // Increased height to prevent overflow
      borderRadius: 24,
      blur: 20,
      alignment: Alignment.topCenter,
      border: 1,
      linearGradient: LinearGradient(
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ]
            : [
                AppTheme.surfaceLight.withValues(alpha: 0.9),
                AppTheme.surfaceLight.withValues(alpha: 0.7),
              ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderGradient: LinearGradient(
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.1),
              ]
            : [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.05),
              ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white30 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Yeni Görev',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Task title input
            TextField(
              controller: _titleController,
              autofocus: true,
              style: TextStyle(color: textPrimary),
              cursorColor: AppTheme.accentTeal,
              decoration: InputDecoration(
                hintText: 'Görev adı...',
                hintStyle: TextStyle(
                  color: textSecondary.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: surfaceColor.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.accentTeal,
                    width: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Difficulty Slider
            Text(
              'Zorluk Seviyesi: ${_getDifficultyLabel()}',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  '1',
                  style: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _getDifficultyColor(),
                      inactiveTrackColor: surfaceColor.withValues(alpha: 0.1),
                      thumbColor: isDark ? Colors.white : AppTheme.accentPurple,
                      overlayColor: _getDifficultyColor().withValues(
                        alpha: 0.2,
                      ),
                    ),
                    child: Slider(
                      value: _detectedDifficulty.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (value) {
                        setState(() {
                          _detectedDifficulty = value.toInt();
                          _showDifficultyHint = false; // User manually set it
                        });
                        HapticFeedback.selectionClick();
                      },
                    ),
                  ),
                ),
                Text(
                  '5',
                  style: TextStyle(color: textSecondary.withValues(alpha: 0.5)),
                ),
              ],
            ),

            // Auto-detected hint
            if (_showDifficultyHint) ...[
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getDifficultyColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: _getDifficultyColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Otomatik tespit edildi',
                      style: TextStyle(
                        color: _getDifficultyColor(),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Date Picker Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'Bugün'
                                  : DateFormat('d.MM').format(_selectedDate!),
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textPrimary, fontSize: 14),
                            cursorColor: AppTheme.accentTeal,
                            decoration: InputDecoration(
                              hintText: 'dk',
                              hintStyle: TextStyle(
                                color: textSecondary.withValues(alpha: 0.5),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isNotEmpty) {
                    _saveTask();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen görev adı girin')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Görev Ekle',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
