import 'package:flutter/material.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:thunder/src/foundation/config/global_context.dart';

class CreatePostTitleField extends StatelessWidget {
  const CreatePostTitleField({
    super.key,
    required this.controller,
    required this.onSuggestFromLink,
  });

  /// The controller for the title input field.
  final TextEditingController controller;

  /// Callback function to be called when the user requests a title suggestion based on the post URL.
  final Future<String?> Function() onSuggestFromLink;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return TypeAheadField<String>(
      controller: controller,
      suggestionsCallback: (pattern) async {
        if (pattern.isEmpty) {
          final linkTitle = await onSuggestFromLink();
          if (linkTitle?.isNotEmpty == true) {
            return [linkTitle!];
          }
        }

        return [];
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
          subtitle: Text(l10n.suggestedTitle),
        );
      },
      onSelected: (suggestion) => controller.text = suggestion,
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
