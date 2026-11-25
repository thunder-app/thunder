import 'package:material_ui/material_ui.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/packages/ui/src/widgets/feedback/thunder_overlay.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/navigation/link_navigation_utils.dart';

class UpdateNotificationCoordinator {
  bool _hasShownNotification = false;

  Version? nextNotification({required Version? version, required bool profileIsUsable, required bool enabled}) {
    if (_hasShownNotification || !profileIsUsable || !enabled || version?.hasUpdate != true) return null;

    _hasShownNotification = true;
    return version;
  }
}

// Update notification
void showUpdateNotification(BuildContext context, Version? version) {
  final theme = Theme.of(context);
  final title = AppLocalizations.of(context)!.updateReleased(version?.latestVersion ?? '');
  final dismissibleKey = UniqueKey();

  showThunderOverlay(
    overlay: Overlay.of(context, rootOverlay: true),
    duration: const Duration(seconds: 5),
    animationDuration: const Duration(milliseconds: 300),
    builder: (overlayContext, animation, dismiss) => Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: animation.drive(CurveTween(curve: Curves.easeInOut)).drive(Tween(begin: const Offset(0, -1), end: Offset.zero)),
        child: Dismissible(
          key: dismissibleKey,
          direction: DismissDirection.vertical,
          confirmDismiss: (_) async {
            dismiss();
            return false;
          },
          child: Material(
            color: theme.cardColor,
            elevation: 16,
            child: SafeArea(
              bottom: false,
              child: ListTile(
                title: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (context.mounted) handleLink(context, url: version?.latestVersionUrl ?? 'https://github.com/thunder-app/thunder/releases');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      Icon(Icons.arrow_forward, color: theme.colorScheme.onSurface),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
