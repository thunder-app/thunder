import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/post/presentation/state/create_post_cubit.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/domain/domain.dart';

class CreatePostAdditionalSettingsPage extends StatelessWidget {
  const CreatePostAdditionalSettingsPage({
    super.key,
    required this.customThumbnailController,
    required this.tagsController,
  });

  /// The controller for the custom thumbnail field.
  final TextEditingController customThumbnailController;

  /// The controller for the tags field.
  final TextEditingController tagsController;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return BlocBuilder<CreatePostCubit, CreatePostState>(
      builder: (context, state) {
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.createPost),
                Text(
                  'Additional Settings',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  key: const Key('create-post-thumbnail-field'),
                  controller: customThumbnailController,
                  decoration: InputDecoration(
                    labelText: l10n.thumbnailUrl,
                    errorText: state.customThumbnailError,
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (state.isPiefedComposer) ...[
                  const SizedBox(height: 16.0),
                  _CreatePostTagEditor(
                    key: const Key('create-post-tags-field'),
                    controller: tagsController,
                  ),
                  const SizedBox(height: 16.0),
                  _CreatePostFlairSection(state: state),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CreatePostTagEditor extends StatefulWidget {
  const _CreatePostTagEditor({
    super.key,
    required this.controller,
  });

  /// The controller for the tags input field.
  final TextEditingController controller;

  @override
  State<_CreatePostTagEditor> createState() => _CreatePostTagEditorState();
}

class _CreatePostTagEditorState extends State<_CreatePostTagEditor> {
  /// The controller for the pending tags input field.
  final TextEditingController _pendingController = TextEditingController();

  /// The focus node for the tags input field.
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleVisualStateChanged);
    _pendingController.addListener(_handleVisualStateChanged);
    widget.controller.addListener(_handleVisualStateChanged);
  }

  @override
  void didUpdateWidget(covariant _CreatePostTagEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }

    oldWidget.controller.removeListener(_handleVisualStateChanged);
    widget.controller.addListener(_handleVisualStateChanged);
    _handleVisualStateChanged();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleVisualStateChanged);
    _focusNode.removeListener(_handleVisualStateChanged);
    _pendingController.removeListener(_handleVisualStateChanged);
    _pendingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final tags = decodePiefedComposerTags(widget.controller.text);
    final isEmpty = tags.isEmpty && _pendingController.text.isEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _focusNode.requestFocus(),
      child: InputDecorator(
        isFocused: _focusNode.hasFocus,
        isEmpty: isEmpty,
        decoration: InputDecoration(
          labelText: l10n.postTags,
          helperText: l10n.postTagsHelperText,
          border: const OutlineInputBorder(),
        ),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final tag in tags)
              _TagChip(
                tag: tag,
                onDeleted: () => _updateTags(
                  normalizePiefedTags(
                    tags.where((existingTag) => existingTag != tag),
                  ),
                ),
              ),
            SizedBox(
              width: 120,
              child: Focus(
                onKeyEvent: (_, event) {
                  if (event is! KeyDownEvent) {
                    return KeyEventResult.ignored;
                  }

                  if (event.logicalKey == LogicalKeyboardKey.backspace && _pendingController.text.isEmpty && tags.isNotEmpty) {
                    _removeLastTag(tags);
                    return KeyEventResult.handled;
                  }

                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _pendingController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  minLines: 1,
                  maxLines: 1,
                  onChanged: _handlePendingChanged,
                  onSubmitted: (_) => _commitPendingInput(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePendingChanged(String value) {
    if (!value.contains(',')) {
      return;
    }

    _commitPendingInput();
  }

  void _handleVisualStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _commitPendingInput() {
    final pendingTags = normalizePiefedTags(_pendingController.text.split(','));
    if (pendingTags.isEmpty) {
      _pendingController.clear();
      return;
    }

    final existingTags = decodePiefedComposerTags(widget.controller.text);
    _updateTags([...existingTags, ...pendingTags]);
    _pendingController.clear();
  }

  void _removeLastTag(List<String> tags) {
    if (tags.isEmpty) {
      return;
    }

    _updateTags(tags.take(tags.length - 1));
  }

  void _updateTags(Iterable<String> tags) {
    final normalizedTags = normalizePiefedTags(tags);
    final encodedTags = encodePiefedTags(normalizedTags);
    if (widget.controller.text != encodedTags) {
      widget.controller.value = widget.controller.value.copyWith(
        text: encodedTags,
        selection: TextSelection.collapsed(offset: encodedTags.length),
        composing: TextRange.empty,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.tag,
    required this.onDeleted,
  });

  /// The tag to display.
  final String tag;

  /// Callback function to be called when the user requests to delete the tag.
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InputChip(
      label: Text('#$tag'),
      onDeleted: onDeleted,
      labelPadding: EdgeInsets.only(left: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        height: 1.1,
      ),
      shape: const StadiumBorder(),
      side: BorderSide.none,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      deleteIconColor: theme.colorScheme.onSurfaceVariant,
      deleteIcon: const Icon(Icons.close_rounded, size: 14.0),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _CreatePostFlairSection extends StatelessWidget {
  const _CreatePostFlairSection({
    required this.state,
  });

  /// The current state of the post creation process, used to display errors and loading states.
  final CreatePostState state;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.postFlairs,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12.0),
        switch (state.piefedMetadataStatus) {
          CreatePostPiefedMetadataStatus.loading => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          CreatePostPiefedMetadataStatus.empty || CreatePostPiefedMetadataStatus.error => Text(
              l10n.postFlairsUnavailable,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
          _ => Wrap(
              key: const Key('create-post-flairs-field'),
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                for (final flair in state.availablePiefedFlairs)
                  _SelectableFlairChip(
                    flair: flair,
                    selected: state.selectedPiefedFlairIds.contains(flair.id),
                    onTap: () {
                      final selectedIds = state.selectedPiefedFlairIds.toSet();
                      if (selectedIds.contains(flair.id)) {
                        selectedIds.remove(flair.id);
                      } else {
                        selectedIds.add(flair.id);
                      }

                      context.read<CreatePostCubit>().updateFlairs(selectedIds.toList());
                    },
                  ),
              ],
            ),
        },
      ],
    );
  }
}

class _SelectableFlairChip extends StatelessWidget {
  const _SelectableFlairChip({
    required this.flair,
    required this.selected,
    required this.onTap,
  });

  /// The flair to display.
  final ThunderFlair flair;

  /// Whether the flair is selected.
  final bool selected;

  /// Callback function to be called when the user taps the flair.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fallbackForeground = theme.colorScheme.onSecondaryContainer;
    final resolvedBackground = selected ? flair.parsedBackgroundColor : null;
    final resolvedForeground = selected ? flair.parsedTextColor : fallbackForeground;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: resolvedBackground,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? resolvedBackground ?? theme.dividerColor : theme.dividerColor),
        ),
        child: Text(
          flair.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: resolvedForeground,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
