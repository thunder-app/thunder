import 'package:flutter/services.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/packages/ui/ui.dart';

enum ActivityPubFullNameType {
  user,
  community,
}

/// Generates the full name of the given type.
///
/// For users, the full name is !name@instance.tld
/// For communities, the full name is !name@instance.tld
String? generateActivityPubFullName({
  required ActivityPubFullNameType type,
  required String? name,
  required String? displayName,
  required String? instance,
}) {
  if (name == null || name.isEmpty || instance == null || instance.isEmpty) return null;

  return switch (type) {
    ActivityPubFullNameType.user => generateUserFullName(
        null,
        name,
        displayName,
        instance,
        userSeparator: FullNameSeparator.lemmy,
        useDisplayName: false,
      ),
    ActivityPubFullNameType.community => generateCommunityFullName(
        null,
        name,
        displayName,
        instance,
        communitySeparator: FullNameSeparator.lemmy,
        useDisplayName: false,
      ),
  };
}

/// Copies the full name of the given type to the clipboard.
Future<void> copyActivityPubFullName({
  required ActivityPubFullNameType type,
  required String? name,
  required String? displayName,
  required String? instance,
}) async {
  final fullName = generateActivityPubFullName(
    type: type,
    name: name,
    displayName: displayName,
    instance: instance,
  );

  if (fullName == null || fullName.isEmpty) return;

  HapticFeedback.mediumImpact();
  await Clipboard.setData(ClipboardData(text: fullName));
  showThunderSnackbar(GlobalContext.l10n.copiedToClipboard);
}
