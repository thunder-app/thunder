import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/post/widgets/post_action_bottom_sheet.dart';
import 'package:thunder/shared/bottom_sheet_action.dart';
import 'package:thunder/shared/multi_picker_item.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';

/// Defines the general actions that can be taken on a post
enum GeneralPostAction {
  general(icon: Icons.more_horiz),
  post(icon: Icons.splitscreen_rounded),
  user(icon: Icons.person_rounded),
  community(icon: Icons.people_rounded),
  instance(icon: Icons.language_rounded),
  share(icon: Icons.share);

  String get name => switch (this) {
        GeneralPostAction.post => "Post",
        GeneralPostAction.user => l10n.user,
        GeneralPostAction.community => l10n.community,
        GeneralPostAction.instance => l10n.instance(1),
        GeneralPostAction.share => l10n.share,
        GeneralPostAction.general => l10n.actions,
      };

  /// The title to use for the action. This is shown when the given page is active
  String get title => switch (this) {
        GeneralPostAction.post => "Post Actions",
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

enum GeneralQuickPostAction {
  upvote(enabledIcon: Icons.arrow_upward_rounded, disabledIcon: Icons.arrow_upward_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  downvote(enabledIcon: Icons.arrow_downward_rounded, disabledIcon: Icons.arrow_downward_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  save(enabledIcon: Icons.star_rounded, disabledIcon: Icons.star_outline_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  read(enabledIcon: Icons.mark_email_read_outlined, disabledIcon: Icons.mark_email_unread_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  hide(enabledIcon: Icons.visibility_off_rounded, disabledIcon: Icons.visibility_rounded, permissionType: PermissionType.user, requiresAuthentication: true),
  ;

  /// The icon to use for the action when it is enabled
  final IconData enabledIcon;

  /// The icon to use for the action when it is disabled
  final IconData disabledIcon;

  /// The permission type to use for the action
  final PermissionType permissionType;

  /// Whether or not the action requires user authentication
  final bool requiresAuthentication;

  const GeneralQuickPostAction({required this.enabledIcon, required this.disabledIcon, required this.permissionType, required this.requiresAuthentication});
}

/// Defines the general top-levelactions that can be taken on a post.
/// Given a [postViewMedia] and a [onSwitchActivePage] callback, this widget will display a list of actions that can be taken on the post.
class GeneralPostActionBottomSheetPage extends StatefulWidget {
  const GeneralPostActionBottomSheetPage({super.key, required this.context, required this.postViewMedia, required this.onSwitchActivePage});

  /// The outer context
  final BuildContext context;

  /// The post information
  final PostViewMedia postViewMedia;

  /// Called when the active page is changed
  final Function(GeneralPostAction page) onSwitchActivePage;

  @override
  State<GeneralPostActionBottomSheetPage> createState() => _GeneralPostActionBottomSheetPageState();
}

class _GeneralPostActionBottomSheetPageState extends State<GeneralPostActionBottomSheetPage> {
  String? generateSubtitle(GeneralPostAction page) {
    PostViewMedia postViewMedia = widget.postViewMedia;

    String? communityInstance = fetchInstanceNameFromUrl(postViewMedia.postView.community.actorId);
    String? userInstance = fetchInstanceNameFromUrl(postViewMedia.postView.creator.actorId);

    switch (page) {
      case GeneralPostAction.user:
        return generateUserFullName(context, postViewMedia.postView.creator.name, postViewMedia.postView.creator.displayName, fetchInstanceNameFromUrl(postViewMedia.postView.creator.actorId));
      case GeneralPostAction.community:
        return generateCommunityFullName(context, postViewMedia.postView.community.name, postViewMedia.postView.community.title, fetchInstanceNameFromUrl(postViewMedia.postView.community.actorId));
      case GeneralPostAction.instance:
        return (communityInstance == userInstance) ? '$communityInstance' : '$communityInstance • $userInstance';
      default:
        return null;
    }
  }

  void performAction(GeneralQuickPostAction action) {
    final postViewMedia = widget.postViewMedia;

    switch (action) {
      case GeneralQuickPostAction.upvote:
        widget.context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.vote, postId: postViewMedia.postView.post.id, value: postViewMedia.postView.myVote == 1 ? 0 : 1));
        break;
      case GeneralQuickPostAction.downvote:
        widget.context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.vote, postId: postViewMedia.postView.post.id, value: postViewMedia.postView.myVote == -1 ? 0 : -1));
        break;
      case GeneralQuickPostAction.save:
        widget.context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.save, postId: postViewMedia.postView.post.id, value: !postViewMedia.postView.saved));
        break;
      case GeneralQuickPostAction.read:
        widget.context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.read, postId: postViewMedia.postView.post.id, value: !postViewMedia.postView.read));
        break;
      case GeneralQuickPostAction.hide:
        widget.context.read<FeedBloc>().add(FeedItemActionedEvent(postAction: PostAction.hide, postId: postViewMedia.postView.post.id, value: postViewMedia.postView.hidden == true ? false : true));
        break;
    }

    context.pop();
  }

  IconData getIcon(GeneralQuickPostAction action) {
    final postViewMedia = widget.postViewMedia;

    switch (action) {
      case GeneralQuickPostAction.upvote:
        return postViewMedia.postView.myVote == 1 ? GeneralQuickPostAction.upvote.enabledIcon : GeneralQuickPostAction.upvote.disabledIcon;
      case GeneralQuickPostAction.downvote:
        return postViewMedia.postView.myVote == -1 ? GeneralQuickPostAction.downvote.enabledIcon : GeneralQuickPostAction.downvote.disabledIcon;
      case GeneralQuickPostAction.save:
        return postViewMedia.postView.saved ? GeneralQuickPostAction.save.enabledIcon : GeneralQuickPostAction.save.disabledIcon;
      case GeneralQuickPostAction.read:
        return postViewMedia.postView.read ? GeneralQuickPostAction.read.enabledIcon : GeneralQuickPostAction.read.disabledIcon;
      case GeneralQuickPostAction.hide:
        return postViewMedia.postView.hidden == true ? GeneralQuickPostAction.hide.enabledIcon : GeneralQuickPostAction.hide.disabledIcon;
    }
  }

  String getLabel(GeneralQuickPostAction action) {
    final postViewMedia = widget.postViewMedia;

    switch (action) {
      case GeneralQuickPostAction.upvote:
        return postViewMedia.postView.myVote == 1 ? l10n.upvoted : l10n.upvote;
      case GeneralQuickPostAction.downvote:
        return postViewMedia.postView.myVote == -1 ? l10n.downvoted : l10n.downvote;
      case GeneralQuickPostAction.save:
        return postViewMedia.postView.saved ? l10n.saved : l10n.save;
      case GeneralQuickPostAction.read:
        return postViewMedia.postView.read ? "Read" : l10n.markAsRead;
      case GeneralQuickPostAction.hide:
        return postViewMedia.postView.hidden == true ? l10n.hidden : l10n.hide;
    }
  }

  Color? getForegroundColor(GeneralQuickPostAction action) {
    final state = context.read<ThunderBloc>().state;
    final postViewMedia = widget.postViewMedia;

    switch (action) {
      case GeneralQuickPostAction.upvote:
        return postViewMedia.postView.myVote == 1 ? state.upvoteColor.color : null;
      case GeneralQuickPostAction.downvote:
        return postViewMedia.postView.myVote == -1 ? state.downvoteColor.color : null;
      case GeneralQuickPostAction.save:
        return postViewMedia.postView.saved ? state.saveColor.color : null;
      case GeneralQuickPostAction.read:
        return postViewMedia.postView.read ? state.markReadColor.color : null;
      case GeneralQuickPostAction.hide:
        return postViewMedia.postView.hidden == true ? state.hideColor.color : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState.isLoggedIn;

    List<GeneralQuickPostAction> quickActions = GeneralQuickPostAction.values.where((element) => element.permissionType == PermissionType.user).toList();

    if (!isLoggedIn) {
      quickActions = quickActions.where((action) => action.requiresAuthentication == false).toList();
    } else {
      // Hide hidden if instance does not support it
      if (!LemmyClient.instance.supportsFeature(LemmyFeature.hidePosts)) {
        quickActions = quickActions.where((action) => action != GeneralQuickPostAction.hide).toList();
      }

      // Hide downvoted if instance does not support it
      if (!authState.downvotesEnabled) {
        quickActions = quickActions.where((action) => action != GeneralQuickPostAction.downvote).toList();
      }
    }

    // Determine the available sub-menus to display
    List<GeneralPostAction> submenus = GeneralPostAction.values.where((page) => page != GeneralPostAction.general).toList();

    if (!isLoggedIn) {
      submenus = submenus.where((action) => action != GeneralPostAction.post).toList();
    }

    return Column(
      children: [
        if (quickActions.isNotEmpty)
          MultiPickerItem(
            pickerItems: GeneralQuickPostAction.values
                .map((generalQuickPostAction) => PickerItemData(
                      icon: getIcon(generalQuickPostAction),
                      label: getLabel(generalQuickPostAction),
                      foregroundColor: getForegroundColor(generalQuickPostAction),
                      onSelected: isLoggedIn ? () => performAction(generalQuickPostAction) : null,
                    ))
                .toList(),
          ),
        ...submenus
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
      ],
    );
  }
}
