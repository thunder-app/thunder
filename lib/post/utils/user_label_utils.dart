import 'package:flutter/material.dart';
import 'package:thunder/account/models/user_label.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Shows a dialog which allows the user to create/modify/edit a label for the given [username].
/// Tip: Call `UserLabel.usernameFromParts` to generate a [username] in the right format.
/// If an existing user label was found (regardless of whether it was changed or deleted) or a new user label was created,
/// it will be returned in the record.
/// If a user label was found and deleted, the deleted flag will be set in the record.
Future<({UserLabel? userLabel, bool deleted})> showUserLabelEditorDialog(
    BuildContext context, String username) async {
  final l10n = AppLocalizations.of(context)!;

  // Load up any existing label
  UserLabel? existingLabel = await UserLabel.fetchUserLabel(username);
  bool deleted = false;

  if (!context.mounted) return (userLabel: existingLabel, deleted: false);

  final TextEditingController controller =
      TextEditingController(text: existingLabel?.label);

  await showThunderDialog<UserLabel?>(
    // We're checking context.mounted above, so ignore this warning
    // ignore: use_build_context_synchronously
    context: context,
    title: l10n.addUserLabel,
    contentWidgetBuilder: (_) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              labelText: l10n.label,
              hintText: l10n.userLabelHint,
            ),
            autofocus: true,
          ),
        ],
      );
    },
    tertiaryButtonText: existingLabel != null ? l10n.delete : null,
    onTertiaryButtonPressed: (dialogContext) async {
      await UserLabel.deleteUserLabel(username);
      deleted = true;

      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
    },
    secondaryButtonText: l10n.cancel,
    onSecondaryButtonPressed: (dialogContext) =>
        Navigator.of(dialogContext).pop(),
    primaryButtonText: l10n.save,
    onPrimaryButtonPressed: (dialogContext, _) async {
      if (controller.text.isNotEmpty) {
        existingLabel = await UserLabel.upsertUserLabel(
            UserLabel(id: '', username: username, label: controller.text));
      } else {
        await UserLabel.deleteUserLabel(username);
        deleted = true;
      }

      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
    },
  );

  return (userLabel: existingLabel, deleted: deleted);
}
