import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/mood_tag_sheet.dart';
import '../providers/poem_provider.dart';
import '../../feed/providers/feed_provider.dart';

/// Poem editor screen
///
/// Features:
/// - Title + content text fields
/// - EN/BN language toggle
/// - Editor toolbar (bold, italic, indent, stanza break)
/// - Mood picker bottom sheet
/// - Auto-save draft (3s debounce)
/// - Publish button
class PoemEditorScreen extends ConsumerStatefulWidget {
  final String? poemId;

  const PoemEditorScreen({super.key, this.poemId});

  @override
  ConsumerState<PoemEditorScreen> createState() => _PoemEditorScreenState();
}

class _PoemEditorScreenState extends ConsumerState<PoemEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();

  String _language = 'en';
  List<String> _selectedMoods = [];
  final List<String> _selectedTags = [];
  bool _isBold = false;
  bool _isItalic = false;
  bool _isPublishing = false;
  bool _hasChanges = false;
  bool _isSaved = false;

  Timer? _debounceTimer;
  String? _draftId;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() => _hasChanges = true);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), _autoSaveDraft);
  }

  Future<void> _autoSaveDraft() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      return;
    }

    try {
      await ref
          .read(poemRepositoryProvider)
          .saveDraft(
            id: _draftId,
            title: _titleController.text.isEmpty
                ? 'Untitled'
                : _titleController.text,
            content: _contentController.text,
            language: _language,
            mood: _selectedMoods,
            tags: _selectedTags,
          );
      if (mounted) {
        setState(() => _isSaved = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isSaved = false);
        });
      }
    } catch (_) {
      // Silently fail — auto-save is non-critical
    }
  }

  Future<void> _publish() async {
    if (_titleController.text.isEmpty ||
        _contentController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final poem = await ref
          .read(poemRepositoryProvider)
          .createPoem(
            title: _titleController.text,
            content: _contentController.text,
            language: _language,
            mood: _selectedMoods,
            tags: _selectedTags,
            status: 'published',
          );

      if (mounted && poem.id.isNotEmpty) {
        // Refresh feed so new poem appears
        ref.invalidate(feedProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your words are now part of the world.'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.go('${AppRoutes.poem}/${poem.id}');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Published, but could not open it.'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.pop();
      }
    } catch (e, stack) {
      debugPrint('[PUBLISH] Error: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not publish. ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  bool get _canPublish =>
      _titleController.text.isNotEmpty &&
      _contentController.text.trim().isNotEmpty;

  void _insertStanzaBreak() {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final before = text.substring(0, selection.start);
    final after = text.substring(selection.end);
    _contentController.text = '$before\n\n───\n\n$after';
    _contentController.selection = TextSelection.collapsed(
      offset: before.length + 7,
    );
  }

  void _indentSelection() {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final before = text.substring(0, selection.start);
    final after = text.substring(selection.end);
    _contentController.text = '$before    $after';
    _contentController.selection = TextSelection.collapsed(
      offset: before.length + 4,
    );
  }

  Future<void> _openMoodPicker() async {
    final result = await MoodTagSheet.show(
      context,
      initialMoods: _selectedMoods,
    );
    if (result.isNotEmpty) {
      setState(() {
        _selectedMoods = result;
        _hasChanges = true;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final choice = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: AppShapes.sheet,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Save draft?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(1),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: AppShapes.sm,
                    ),
                    child: Text(
                      'Save',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.of(context).pop(2),
                    style: FilledButton.styleFrom(shape: AppShapes.sm),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(3),
                    child: Text(
                      'Cancel',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );

    if (choice == 1) {
      await _autoSaveDraft();
      return true;
    }
    return choice == 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _onWillPop().then((shouldPop) {
              if (shouldPop && context.mounted) context.pop();
            }),
          ),
          title: Text(
            'New Poem',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            // Language toggle
            Container(
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppShapes.radiusSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LangToggle(
                    label: 'EN',
                    isActive: _language == 'en',
                    onTap: () => setState(() => _language = 'en'),
                  ),
                  _LangToggle(
                    label: 'BN',
                    isActive: _language == 'bn',
                    onTap: () => setState(() => _language = 'bn'),
                  ),
                ],
              ),
            ),
            // Publish button
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                height: 36,
                child: AnimatedContainer(
                  duration: AppDurations.quick,
                  curve: AppCurves.standard,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: _canPublish
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    borderRadius: AppShapes.radiusSm,
                  ),
                  child: _isPublishing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surface,
                          ),
                        )
                      : Center(
                          child: Text(
                            'Publish',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: _canPublish
                                  ? AppColors.surface
                                  : AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Title field
                    TextField(
                      controller: _titleController,
                      focusNode: _titleFocus,
                      style: AppTypography.storyTitle(_language),
                      decoration: InputDecoration(
                        hintText: 'A title for your verse...',
                        hintStyle: AppTypography.storyTitle(_language).copyWith(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: 1,
                    ),

                    const SizedBox(height: 12),

                    // Divider
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.outlineVariant,
                    ),

                    const SizedBox(height: 12),

                    // Poem body with A01 cursor pulse
                    Stack(
                      children: [
                        TextField(
                          controller: _contentController,
                          focusNode: _contentFocus,
                          style: _language == 'en'
                              ? AppTypography.englishPoem
                              : AppTypography.banglaPoem,
                          decoration: InputDecoration(
                            hintText: 'Begin here...',
                            hintStyle:
                                (_language == 'en'
                                        ? AppTypography.englishPoem
                                        : AppTypography.banglaPoem)
                                    .copyWith(
                                      color: AppColors.onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                      fontStyle: FontStyle.italic,
                                    ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          maxLines: null,
                          minLines: 10,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        // A01 Sage cursor pulse — shown when field is focused
                        if (_contentFocus.hasFocus)
                          Positioned(
                            left: 2,
                            top: 8,
                            child: _CursorPulse(),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Mood/Tags row
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        InkWell(
                          onTap: _openMoodPicker,
                          borderRadius: AppShapes.radiusXs,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text(
                              _selectedMoods.isEmpty
                                  ? '+ Add mood'
                                  : _selectedMoods
                                        .map((m) => _cap(m))
                                        .join(', '),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Bottom toolbar
            _EditorToolbar(
              isBold: _isBold,
              isItalic: _isItalic,
              isSaved: _isSaved,
              onBold: () => setState(() => _isBold = !_isBold),
              onItalic: () => setState(() => _isItalic = !_isItalic),
              onIndent: _indentSelection,
              onStanzaBreak: _insertStanzaBreak,
              onPublish: _canPublish ? _publish : null,
            ),
          ],
        ),
      ),
    );
  }

  static String _cap(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

/// Language toggle button
class _LangToggle extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _LangToggle({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.quick,
        curve: AppCurves.standard,
        width: 40,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: AppShapes.radiusSm,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Editor toolbar with formatting buttons
class _EditorToolbar extends StatelessWidget {
  final bool isBold;
  final bool isItalic;
  final bool isSaved;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onIndent;
  final VoidCallback onStanzaBreak;
  final VoidCallback? onPublish;

  const _EditorToolbar({
    required this.isBold,
    required this.isItalic,
    required this.isSaved,
    required this.onBold,
    required this.onItalic,
    required this.onIndent,
    required this.onStanzaBreak,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _ToolbarButton(label: 'B', isActive: isBold, onTap: onBold),
            _ToolbarButton(
              label: 'I',
              isActive: isItalic,
              onTap: onItalic,
              isItalic: true,
            ),
            _ToolbarButton(icon: Icons.format_indent_increase, onTap: onIndent),
            _ToolbarButton(label: '───', onTap: onStanzaBreak),
            const SizedBox(width: 8),
            // Divider
            Container(width: 1, height: 24, color: AppColors.outlineVariant),
            const SizedBox(width: 8),
            // Publish button in toolbar
            if (onPublish != null)
              _ToolbarButton(icon: Icons.send_outlined, onTap: onPublish!),
            const Spacer(),
            // Saved indicator
            if (isSaved)
              Text(
                'Saved',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.tertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Individual toolbar button
class _ToolbarButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isActive;
  final bool isItalic;
  final VoidCallback onTap;

  const _ToolbarButton({
    this.label,
    this.icon,
    this.isActive = false,
    this.isItalic = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: AppDurations.quick,
      curve: AppCurves.standard,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: isActive ? AppShapes.radiusXs : null,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: label != null
            ? Text(
                label!,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isItalic ? FontWeight.w400 : FontWeight.w700,
                  fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              )
            : Icon(
                icon,
                size: 20,
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
        iconSize: 20,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

/// A01 Sage cursor pulse — gentle breathing glow at the text cursor position.
class _CursorPulse extends StatefulWidget {
  const _CursorPulse();

  @override
  State<_CursorPulse> createState() => _CursorPulseState();
}

class _CursorPulseState extends State<_CursorPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.prose,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.15, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noMotion = MediaQuery.of(context).disableAnimations;
    if (noMotion) {
      return Container(
        width: 2,
        height: 24,
        color: AppColors.primary.withValues(alpha: 0.3),
      );
    }

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Container(
          width: 2,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: _opacity.value),
            borderRadius: AppShapes.radiusXs,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: _opacity.value * 0.4,
                ),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
