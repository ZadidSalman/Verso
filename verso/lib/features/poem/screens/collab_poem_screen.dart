import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_shapes.dart';
import '../../../core/theme/app_animations.dart';
import '../../../shared/models/collab_poem_model.dart';
import '../providers/collab_provider.dart';

/// Collaborative poem screen with live stanza chain
class CollabPoemScreen extends ConsumerStatefulWidget {
  final String poemId;

  const CollabPoemScreen({super.key, required this.poemId});

  @override
  ConsumerState<CollabPoemScreen> createState() => _CollabPoemScreenState();
}

class _CollabPoemScreenState extends ConsumerState<CollabPoemScreen> {
  final _stanzaController = TextEditingController();
  bool _isSubmitting = false;
  bool _showInput = false;

  @override
  void dispose() {
    _stanzaController.dispose();
    super.dispose();
  }

  Future<void> _submitStanza() async {
    if (_stanzaController.text.trim().isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await submitCollabStanza(
        ref,
        widget.poemId,
        _stanzaController.text.trim(),
      );
      _stanzaController.clear();
      setState(() => _showInput = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your line has been added.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add your line.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final poemAsync = ref.watch(collabPoemProvider(widget.poemId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Collaborative Poem',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          // Live pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer,
              borderRadius: AppShapes.radiusXs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Live',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: poemAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not find this poem.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
        data: (poem) => _buildContent(context, poem, theme),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CollabPoemModel poem,
    ThemeData theme,
  ) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                poem.title,
                style: AppTypography.englishPoem.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              // Meta row
              Row(
                children: [
                  // Collab type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: poem.collabType == 'open'
                          ? AppColors.primaryContainer
                          : AppColors.tertiaryContainer,
                      borderRadius: AppShapes.radiusXs,
                    ),
                    child: Text(
                      poem.collabType == 'open' ? 'Open' : 'Invite-only',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: poem.collabType == 'open'
                            ? AppColors.primary
                            : AppColors.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: poem.status == 'open'
                          ? AppColors.secondaryContainer
                          : AppColors.surfaceVariant,
                      borderRadius: AppShapes.radiusXs,
                    ),
                    child: Text(
                      poem.status == 'open' ? 'Accepting stanzas' : 'Complete',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: poem.status == 'open'
                            ? AppColors.secondary
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Contributors count
                  Text(
                    '${poem.contributorsCount} contributor${poem.contributorsCount != 1 ? 's' : ''}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Stanza chain
        Expanded(
          child: poem.stanzas.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.edit_note_outlined,
                          size: 48,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No stanzas yet.\nBe the first voice.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: poem.stanzas.length,
                  itemBuilder: (context, index) {
                    final stanza = poem.stanzas[index];
                    return _StanzaCard(
                      stanza: stanza,
                      order: index + 1,
                      isFirst: index == 0,
                    );
                  },
                ),
        ),

        // Add stanza section
        if (poem.status == 'open')
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.outlineVariant, width: 1),
              ),
            ),
            child: SafeArea(
              top: false,
              child: _showInput
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _stanzaController,
                            maxLines: 3,
                            maxLength: 2000,
                            decoration: InputDecoration(
                              hintText: 'Add your line…',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                                fontStyle: FontStyle.italic,
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: AppShapes.radiusSm,
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              contentPadding: const EdgeInsets.all(12),
                              counterText: '',
                            ),
                            style: AppTypography.englishPoem.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _submitStanza,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: AppShapes.sm,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.surface,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: AppColors.surface,
                                  ),
                          ),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () => setState(() => _showInput = true),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppShapes.radiusSm,
                          border: Border.all(
                            color: AppColors.outlineVariant,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_outlined,
                              size: 18,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add my line',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

/// Individual stanza card with mood-colored left border
class _StanzaCard extends StatelessWidget {
  final StanzaModel stanza;
  final int order;
  final bool isFirst;

  const _StanzaCard({
    required this.stanza,
    required this.order,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: isFirst ? 16 : 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.radiusSm,
        border: Border(
          left: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.6),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stanza number
          Text(
            'Stanza $order',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Content
          Text(
            stanza.content,
            style: AppTypography.englishPoem.copyWith(
              fontSize: 16,
              height: 1.7,
              fontStyle: isFirst ? FontStyle.normal : FontStyle.italic,
            ),
          ),

          const SizedBox(height: 8),

          // Author credit
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.surfaceVariant,
                child: const Icon(
                  Icons.person,
                  size: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'by Poet',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
