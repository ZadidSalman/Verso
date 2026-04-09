import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';

/// Bottom sheet for mood and tag selection in the poem editor
class MoodTagSheet extends StatefulWidget {
  final List<String> selectedMoods;
  final ValueChanged<List<String>> onMoodsChanged;

  const MoodTagSheet({
    super.key,
    required this.selectedMoods,
    required this.onMoodsChanged,
  });

  @override
  State<MoodTagSheet> createState() => _MoodTagSheetState();

  /// Show the mood tag sheet and return selected moods
  static Future<List<String>> show(
    BuildContext context, {
    List<String> initialMoods = const [],
  }) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      shape: AppShapes.sheet,
      enableDrag: true,
      builder: (context) => _MoodTagSheetWrapper(initialMoods: initialMoods),
    );
    return result ?? initialMoods;
  }
}

class _MoodTagSheetState extends State<MoodTagSheet> {
  late List<String> _selectedMoods;

  @override
  void initState() {
    super.initState();
    _selectedMoods = List.from(widget.selectedMoods);
  }

  void _toggleMood(String mood) {
    setState(() {
      if (_selectedMoods.contains(mood)) {
        _selectedMoods.remove(mood);
      } else {
        _selectedMoods.add(mood);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                'Choose the mood of your verse',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Mood grid
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: AppColors.moodKeys.length,
                itemBuilder: (context, index) {
                  final mood = AppColors.moodKeys[index];
                  final isSelected = _selectedMoods.contains(mood);
                  final moodColor = AppColors.mood(mood);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => _toggleMood(mood),
                      borderRadius: AppShapes.radiusSm,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? moodColor.withValues(alpha: 0.12)
                              : AppColors.surfaceVariant,
                          borderRadius: AppShapes.radiusSm,
                          border: Border.all(
                            color: isSelected
                                ? moodColor
                                : AppColors.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: moodColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _capitalize(mood),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isSelected
                                      ? moodColor
                                      : AppColors.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: moodColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Done button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      widget.onMoodsChanged(_selectedMoods);
                      Navigator.of(context).pop(_selectedMoods);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: AppShapes.sm,
                    ),
                    child: Text(
                      _selectedMoods.isEmpty
                          ? 'Skip for now'
                          : 'Apply ${_selectedMoods.length} mood${_selectedMoods.length > 1 ? 's' : ''}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _MoodTagSheetWrapper extends StatefulWidget {
  final List<String> initialMoods;
  const _MoodTagSheetWrapper({required this.initialMoods});

  @override
  State<_MoodTagSheetWrapper> createState() => _MoodTagSheetWrapperState();
}

class _MoodTagSheetWrapperState extends State<_MoodTagSheetWrapper> {
  late List<String> _selectedMoods;

  @override
  void initState() {
    super.initState();
    _selectedMoods = List.from(widget.initialMoods);
  }

  void _toggleMood(String mood) {
    setState(() {
      if (_selectedMoods.contains(mood)) {
        _selectedMoods.remove(mood);
      } else {
        _selectedMoods.add(mood);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                'Choose the mood of your verse',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: AppColors.moodKeys.length,
                itemBuilder: (context, index) {
                  final mood = AppColors.moodKeys[index];
                  final isSelected = _selectedMoods.contains(mood);
                  final moodColor = AppColors.mood(mood);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => _toggleMood(mood),
                      borderRadius: AppShapes.radiusSm,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? moodColor.withValues(alpha: 0.12)
                              : AppColors.surfaceVariant,
                          borderRadius: AppShapes.radiusSm,
                          border: Border.all(
                            color: isSelected
                                ? moodColor
                                : AppColors.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: moodColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _capitalize(mood),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isSelected
                                      ? moodColor
                                      : AppColors.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: moodColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_selectedMoods),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: AppShapes.sm,
                    ),
                    child: Text(
                      _selectedMoods.isEmpty
                          ? 'Skip for now'
                          : 'Apply ${_selectedMoods.length} mood${_selectedMoods.length > 1 ? 's' : ''}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
