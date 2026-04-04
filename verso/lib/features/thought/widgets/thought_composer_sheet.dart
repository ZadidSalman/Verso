import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';

/// Visibility option for thoughts
enum VisibilityOption {
  public(Icons.public_outlined, 'Public'),
  mutual(Icons.group_outlined, 'Mutual'),
  private(Icons.lock_outline, 'Private');

  final IconData icon;
  final String label;
  const VisibilityOption(this.icon, this.label);
}

/// Thought composer bottom sheet with A22 visibility picker
class ThoughtComposerSheet extends StatefulWidget {
  const ThoughtComposerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const ThoughtComposerSheet(),
    );
  }

  @override
  State<ThoughtComposerSheet> createState() => _ThoughtComposerSheetState();
}

class _ThoughtComposerSheetState extends State<ThoughtComposerSheet> {
  final _controller = TextEditingController();
  VisibilityOption _visibility = VisibilityOption.public;
  bool _isPosting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _post() {
    if (_controller.text.trim().isEmpty || _isPosting) return;

    setState(() => _isPosting = true);

    // TODO: Call API to post thought
    // For now, just close the sheet
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_visibilityMessage(_visibility)),
            backgroundColor: AppColors.primary,
          ),
        );
        context.pop();
      }
    });
  }

  String _visibilityMessage(VisibilityOption v) {
    switch (v) {
      case VisibilityOption.public:
        return 'Your thought is out in the world.';
      case VisibilityOption.mutual:
        return 'Your thought is with your circle.';
      case VisibilityOption.private:
        return 'Your thought is safe with you.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    final charCount = _controller.text.length;
    final canPost = charCount > 0 && charCount <= 280;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.95,
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

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share a thought',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 36,
                      child: FilledButton(
                        onPressed: canPost ? _post : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: canPost
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                          shape: AppShapes.sm,
                        ),
                        child: _isPosting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.surface,
                                ),
                              )
                            : Text(
                                'Post',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: canPost
                                      ? AppColors.surface
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // Visibility picker (A22)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _VisibilityPicker(
                  selected: _visibility,
                  onChanged: (v) => setState(() => _visibility = v),
                  disableAnimations: disableAnimations,
                ),
              ),

              const SizedBox(height: 16),

              // Text field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _controller,
                  onChanged: (_) => setState(() {}),
                  maxLength: 280,
                  maxLines: null,
                  minLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  decoration: InputDecoration(
                    hintText: 'A thought for the world…',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Character counter
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$charCount/280',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: charCount > 280
                            ? AppColors.error
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

/// A22 visibility picker with sliding pill
class _VisibilityPicker extends StatefulWidget {
  final VisibilityOption selected;
  final ValueChanged<VisibilityOption> onChanged;
  final bool disableAnimations;

  const _VisibilityPicker({
    required this.selected,
    required this.onChanged,
    required this.disableAnimations,
  });

  @override
  State<_VisibilityPicker> createState() => _VisibilityPickerState();
}

class _VisibilityPickerState extends State<_VisibilityPicker> {
  final _options = VisibilityOption.values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIndex = _options.indexOf(widget.selected);

    return LayoutBuilder(
      builder: (context, constraints) {
        final pillWidth = (constraints.maxWidth - 16) / 3;

        return Stack(
          children: [
            // Sliding pill background (A22)
            AnimatedPositioned(
              duration: widget.disableAnimations
                  ? Duration.zero
                  : AppDurations.standard,
              curve: AppCurves.standard,
              left: selectedIndex * (pillWidth + 4) + 4,
              top: 4,
              bottom: 4,
              width: pillWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppShapes.radiusSm,
                ),
              ),
            ),

            // Labels row
            SizedBox(
              height: 40,
              child: Row(
                children: _options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isActive = index == selectedIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onChanged(option),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            option.icon,
                            size: 16,
                            color: isActive
                                ? AppColors.surface
                                : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            option.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isActive
                                  ? AppColors.surface
                                  : AppColors.onSurfaceVariant,
                              fontWeight: isActive
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
