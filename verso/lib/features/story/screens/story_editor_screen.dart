import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_typography.dart';

/// Story editor screen — 3-step flow
class StoryEditorScreen extends StatefulWidget {
  const StoryEditorScreen({super.key});

  @override
  State<StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<StoryEditorScreen> {
  int _currentStep = 0;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _language = 'en';
  String _storyMode = 'linear';
  String _collabMode = 'none';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'New Story',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: List.generate(3, (index) {
                final isActive = index <= _currentStep;
                return Expanded(
                  child: Row(
                    children: [
                      // Dot
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isActive
                                  ? AppColors.surface
                                  : AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // Line
                      if (index < 2)
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            color: index < _currentStep
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Step content
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _Step1Cover(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                  language: _language,
                  onLanguageChanged: (lang) => setState(() => _language = lang),
                ),
                _Step2Mode(
                  storyMode: _storyMode,
                  collabMode: _collabMode,
                  onStoryModeChanged: (mode) =>
                      setState(() => _storyMode = mode),
                  onCollabModeChanged: (mode) =>
                      setState(() => _collabMode = mode),
                ),
                _Step3Write(language: _language),
              ],
            ),
          ),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevStep,
                      style: OutlinedButton.styleFrom(shape: AppShapes.sm),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: _currentStep == 0 ? 1 : 1,
                  child: FilledButton(
                    onPressed: _nextStep,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: AppShapes.sm,
                    ),
                    child: Text(
                      _currentStep == 2 ? 'Publish' : 'Next',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.surface,
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
  }
}

/// Step 1: Cover & Identity
class _Step1Cover extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String language;
  final ValueChanged<String> onLanguageChanged;

  const _Step1Cover({
    required this.titleController,
    required this.descriptionController,
    required this.language,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cover & Identity',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Give your story a face and a voice.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Cover placeholder
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppShapes.radiusMd,
                border: Border.all(
                  color: AppColors.outlineVariant,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add a cover',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Story title',
              hintText: 'A name for your world...',
              border: const OutlineInputBorder(
                borderRadius: AppShapes.radiusSm,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
            ),
            style: AppTypography.englishPoem.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),

          // Description
          TextField(
            controller: descriptionController,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'What is your story about?',
              border: const OutlineInputBorder(
                borderRadius: AppShapes.radiusSm,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Language
          Text(
            'Language',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LangChip(
                label: 'English',
                isActive: language == 'en',
                onTap: () => onLanguageChanged('en'),
              ),
              const SizedBox(width: 8),
              _LangChip(
                label: 'বাংলা',
                isActive: language == 'bn',
                onTap: () => onLanguageChanged('bn'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Step 2: Mode & Collaboration
class _Step2Mode extends StatelessWidget {
  final String storyMode;
  final String collabMode;
  final ValueChanged<String> onStoryModeChanged;
  final ValueChanged<String> onCollabModeChanged;

  const _Step2Mode({
    required this.storyMode,
    required this.collabMode,
    required this.onStoryModeChanged,
    required this.onCollabModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mode & Collaboration',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How will your story unfold?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Story mode
          Text(
            'Story Mode',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _ModeCard(
            icon: Icons.linear_scale,
            title: 'Linear',
            description: 'Chapters in order. One path, one journey.',
            isActive: storyMode == 'linear',
            onTap: () => onStoryModeChanged('linear'),
          ),
          const SizedBox(height: 8),
          _ModeCard(
            icon: Icons.account_tree_outlined,
            title: 'Branching',
            description: 'Readers choose their path. Multiple endings.',
            isActive: storyMode == 'branching',
            onTap: () => onStoryModeChanged('branching'),
          ),

          const SizedBox(height: 24),

          // Collaboration mode
          Text(
            'Collaboration',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _CollabCard(
            icon: Icons.person,
            title: 'Just me',
            isActive: collabMode == 'none',
            onTap: () => onCollabModeChanged('none'),
          ),
          const SizedBox(height: 8),
          _CollabCard(
            icon: Icons.group_outlined,
            title: 'Open',
            description: 'Anyone can contribute a chapter.',
            isActive: collabMode == 'open',
            onTap: () => onCollabModeChanged('open'),
          ),
          const SizedBox(height: 8),
          _CollabCard(
            icon: Icons.mail_outline,
            title: 'Invite only',
            description: 'Only invited poets can write.',
            isActive: collabMode == 'invite-only',
            onTap: () => onCollabModeChanged('invite-only'),
          ),
        ],
      ),
    );
  }
}

/// Step 3: Write First Chapter
class _Step3Write extends StatelessWidget {
  final String language;

  const _Step3Write({required this.language});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Write Chapter One',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Every great story begins with a single word.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Part title
          TextField(
            decoration: InputDecoration(
              labelText: 'Chapter title',
              hintText: 'The beginning...',
              border: const OutlineInputBorder(
                borderRadius: AppShapes.radiusSm,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
            ),
            style: AppTypography.englishPoem.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Content
          TextField(
            maxLines: 12,
            decoration: InputDecoration(
              labelText: 'Content',
              hintText: 'Begin here...',
              border: const OutlineInputBorder(
                borderRadius: AppShapes.radiusSm,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              alignLabelWithHint: true,
            ),
            style:
                (language == 'en'
                        ? AppTypography.englishPoem
                        : AppTypography.banglaPoem)
                    .copyWith(fontSize: 16),
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _LangChip({
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryContainer
              : AppColors.surfaceVariant,
          borderRadius: AppShapes.radiusSm,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryContainer.withValues(alpha: 0.3)
              : AppColors.surfaceVariant,
          borderRadius: AppShapes.radiusMd,
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.outlineVariant,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isActive ? AppColors.primary : AppColors.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _CollabCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final bool isActive;
  final VoidCallback onTap;

  const _CollabCard({
    required this.icon,
    required this.title,
    this.description,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryContainer.withValues(alpha: 0.3)
              : AppColors.surfaceVariant,
          borderRadius: AppShapes.radiusMd,
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.outlineVariant,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isActive ? AppColors.primary : AppColors.onSurface,
                    ),
                  ),
                  if (description != null)
                    Text(
                      description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
