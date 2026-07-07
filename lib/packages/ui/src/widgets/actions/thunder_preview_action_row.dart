import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thunder/packages/ui/src/widgets/common/thunder_icon_label.dart';
import 'package:thunder/packages/ui/src/widgets/feedback/thunder_snackbar.dart';
import 'package:thunder/packages/ui/src/widgets/layout/thunder_divider.dart';

/// Icon-label action row for reply preview toolbars.
@immutable
class ThunderPreviewActionRow extends StatelessWidget {
  const ThunderPreviewActionRow({
    super.key,
    required this.text,
    required this.viewSource,
    required this.onViewSourceToggled,
    required this.viewSourceLabel,
    required this.viewOriginalLabel,
    required this.copyLabel,
    required this.copiedMessage,
  });

  /// Content text copied when the copy action is tapped.
  final String text;

  /// Whether source view mode is currently active.
  final bool viewSource;

  /// Called when the view-source toggle is tapped.
  final void Function()? onViewSourceToggled;

  /// Label shown when [viewSource] is false.
  final String viewSourceLabel;

  /// Label shown when [viewSource] is true.
  final String viewOriginalLabel;

  /// Label for the copy action.
  final String copyLabel;

  /// Snackbar message shown after copying [text].
  final String copiedMessage;

  @override
  Widget build(BuildContext context) {
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
                _ThunderPreviewActionButton(
                  onTap: onViewSourceToggled,
                  icon: const Icon(Icons.edit_document, size: 15.0),
                  label: viewSource ? viewOriginalLabel : viewSourceLabel,
                ),
                _ThunderPreviewActionButton(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: text));
                    showThunderSnackbar(copiedMessage);
                  },
                  icon: const Icon(Icons.copy_rounded, size: 15.0),
                  label: copyLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon-label button for a single preview toolbar action.
class _ThunderPreviewActionButton extends StatelessWidget {
  const _ThunderPreviewActionButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  /// Called when the button is tapped.
  final void Function()? onTap;

  /// Icon widget shown before the label.
  final Widget icon;

  /// Button label text.
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        child: ThunderIconLabel(gap: 5.0, icon: icon, label: label),
      ),
    );
  }
}
