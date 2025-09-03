import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/shared/divider.dart';
import 'package:thunder/src/shared/icon_text.dart';
import 'package:thunder/src/shared/snackbar.dart';

/// Defines a widget which provides action buttons for the preview of a post or comment when replying
///
/// For example, actions to view the original source or copy the text to the clipboard.
class ReplyToPreviewActions extends StatelessWidget {
  /// The text to be copied to the clipboard.
  final String text;

  /// Whether to show the source text or the markdown text.
  final bool viewSource;

  /// Whether the view source is toggled or not.
  final void Function()? onViewSourceToggled;

  const ReplyToPreviewActions({
    super.key,
    required this.text,
    required this.viewSource,
    required this.onViewSourceToggled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            const ThunderDivider(sliver: false, padding: false),
            Row(
              spacing: 12.0,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: onViewSourceToggled,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                    child: IconText(
                      padding: 5.0,
                      icon: Icon(Icons.edit_document, size: 15.0),
                      text: viewSource ? l10n.viewOriginal : l10n.viewSource,
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: text));
                    showSnackbar(l10n.copiedToClipboard);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                    child: IconText(
                      padding: 5.0,
                      icon: Icon(Icons.copy_rounded, size: 15.0),
                      text: l10n.copyText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
