import 'package:flutter/material.dart';

import 'package:thunder/src/foundation/config/global_context.dart';

class CreatePostMetadataRow extends StatelessWidget {
  const CreatePostMetadataRow({
    super.key,
    required this.languageSelector,
    required this.nsfw,
    required this.onNsfwChanged,
  });

  /// The widget for selecting the post's language.
  final Widget languageSelector;

  /// Whether the post is marked as NSFW.
  final bool nsfw;

  /// Callback function to be called when the user toggles the NSFW switch.
  final ValueChanged<bool> onNsfwChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final width = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width * 0.60),
          child: languageSelector,
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4.0,
          children: [
            Text(l10n.nsfw),
            Switch(value: nsfw, onChanged: onNsfwChanged),
          ],
        ),
      ],
    );
  }
}
