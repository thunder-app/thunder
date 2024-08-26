import 'package:flutter/material.dart';

import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/widgets/post_action_bottom_sheet.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/utils/instance.dart';

/// Defines the general actions that can be taken on a post
enum GeneralPostAction {
  general(icon: Icons.more_horiz),
  user(icon: Icons.person),
  community(icon: Icons.group),
  instance(icon: Icons.language),
  share(icon: Icons.share);

  String get name => switch (this) {
        GeneralPostAction.user => l10n.user,
        GeneralPostAction.community => l10n.community,
        GeneralPostAction.instance => l10n.instance(1),
        GeneralPostAction.share => l10n.share,
        GeneralPostAction.general => l10n.actions,
      };

  /// The title to use for the action. This is shown when the given page is active
  String get title => switch (this) {
        GeneralPostAction.user => l10n.userActions,
        GeneralPostAction.community => l10n.communityActions,
        GeneralPostAction.instance => l10n.instanceActions,
        GeneralPostAction.share => l10n.share,
        GeneralPostAction.general => l10n.actions,
      };

  /// The icon to use for the action
  final IconData icon;

  const GeneralPostAction({required this.icon});
}

/// Defines the general top-levelactions that can be taken on a post.
/// Given a [postViewMedia] and a [onSwitchActivePage] callback, this widget will display a list of actions that can be taken on the post.
class GeneralPostActionBottomSheetPage extends StatefulWidget {
  const GeneralPostActionBottomSheetPage({super.key, required this.postViewMedia, required this.onSwitchActivePage});

  /// The post information
  final PostViewMedia postViewMedia;

  /// Called when the active page is changed
  final Function(GeneralPostAction page) onSwitchActivePage;

  @override
  State<GeneralPostActionBottomSheetPage> createState() => _GeneralPostActionBottomSheetPageState();
}

class _GeneralPostActionBottomSheetPageState extends State<GeneralPostActionBottomSheetPage> {
  String generateSubtitle(GeneralPostAction page) {
    PostViewMedia postViewMedia = widget.postViewMedia;

    switch (page) {
      case GeneralPostAction.user:
        return generateUserFullName(context, postViewMedia.postView.creator.name, postViewMedia.postView.creator.displayName, fetchInstanceNameFromUrl(postViewMedia.postView.creator.actorId));
      case GeneralPostAction.community:
        return generateCommunityFullName(context, postViewMedia.postView.community.name, postViewMedia.postView.community.title, fetchInstanceNameFromUrl(postViewMedia.postView.community.actorId));
      case GeneralPostAction.instance:
        return fetchInstanceNameFromUrl(postViewMedia.postView.post.apId) ?? '';
      case GeneralPostAction.share:
        return l10n.share;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: GeneralPostAction.values
          .where((page) => page != GeneralPostAction.general)
          .map(
            (page) => BottomSheetAction(
              leading: Icon(page.icon),
              trailing: const Icon(Icons.chevron_right_rounded),
              title: page.name,
              subtitle: generateSubtitle(page),
              onTap: () => widget.onSwitchActivePage(page),
            ),
          )
          .toList() as List<Widget>,
    );
  }
}
