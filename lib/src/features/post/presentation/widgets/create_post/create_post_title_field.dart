import 'package:flutter/material.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:thunder/src/foundation/config/global_context.dart';

/// A title input field with support for link-based title suggestions.
class CreatePostTitleField extends StatefulWidget {
  /// The controller for the title input field.
  final TextEditingController controller;

  /// A title suggestion derived from the current post URL.
  final String? suggestedLinkTitle;

  const CreatePostTitleField({super.key, required this.controller, required this.suggestedLinkTitle});

  @override
  State<CreatePostTitleField> createState() => _CreatePostTitleFieldState();
}

class _CreatePostTitleFieldState extends State<CreatePostTitleField> {
  final SuggestionsController<String> _suggestionsController = SuggestionsController<String>();

  @override
  void didUpdateWidget(covariant CreatePostTitleField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.suggestedLinkTitle != widget.suggestedLinkTitle) {
      _suggestionsController.refresh();
    }
  }

  @override
  void dispose() {
    _suggestionsController.dispose();
    super.dispose();
  }

  List<String> _getSuggestedTitle(String pattern) {
    final suggestion = widget.suggestedLinkTitle?.trim();

    if (pattern.isEmpty && suggestion?.isNotEmpty == true) {
      return [suggestion!];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return TypeAheadField<String>(
      controller: widget.controller,
      suggestionsController: _suggestionsController,
      suggestionsCallback: _getSuggestedTitle,
      itemBuilder: (context, suggestion) => _SuggestionItem(suggestion: suggestion),
      onSelected: (suggestion) => widget.controller.text = suggestion,
      builder: (context, textEditingController, focusNode) => TextField(
        key: const Key('create-post-title-field'),
        controller: textEditingController,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: l10n.postTitle,
          border: const OutlineInputBorder(),
        ),
      ),
      hideOnEmpty: true,
      hideOnLoading: true,
      hideOnError: true,
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  const _SuggestionItem({required this.suggestion});

  /// The suggested title to be displayed in the suggestion list.
  final String suggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return ListTile(
      title: Text(suggestion),
      subtitle: Text(l10n.suggestedTitle),
    );
  }
}
