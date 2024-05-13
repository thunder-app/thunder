import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/shared/snackbar.dart';

/// Defines a widget which provides action buttons for the preview of a post or comment when replying
class ReplyToPreviewActions extends StatelessWidget {
  final void Function()? onViewSourceToggled;
  final bool viewSource;
  final String text;

  const ReplyToPreviewActions({
    super.key,
    required this.onViewSourceToggled,
    required this.viewSource,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          InkWell(
            onTap: onViewSourceToggled,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 5),
                const Icon(Icons.edit_document, size: 15),
                const SizedBox(width: 5),
                Text(viewSource ? l10n.viewOriginal : l10n.viewSource),
                const SizedBox(width: 5),
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: text)).then((_) {
                showSnackbar(AppLocalizations.of(context)!.copiedToClipboard);
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 5),
                const Icon(Icons.copy_rounded, size: 15),
                const SizedBox(width: 5),
                Text(l10n.copyText),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
