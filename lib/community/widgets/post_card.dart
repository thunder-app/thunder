import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/utils/post_actions.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/community/widgets/post_card_view_comfortable.dart';
import 'package:thunder/community/widgets/post_card_view_compact.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/theme/theme.dart';
import 'package:thunder/post/bloc/post_bloc.dart' as post_bloc; // renamed to prevent clash with VotePostEvent, etc from community_bloc
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/post/utils/comment_actions.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class PostCard extends StatefulWidget {
  final PostViewMedia postViewMedia;
  final bool showInstanceName;

  final Function(VoteType) onVoteAction;
  final Function(bool) onSaveAction;

  const PostCard({
    super.key,
    required this.postViewMedia,
    this.showInstanceName = true,
    required this.onVoteAction,
    required this.onSaveAction,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  /// The current point at which the user drags the comment
  double dismissThreshold = 0;

  /// The current swipe action that would be performed if the user let go off the screen
  SwipeAction? swipeAction;

  /// Determines the direction that the user is allowed to drag (to enable/disable swipe gestures)
  DismissDirection? dismissDirection;

  /// The first action threshold to trigger the left or right actions (upvote/reply)
  double firstActionThreshold = 0.15;

  /// The second action threshold to trigger the left or right actions (downvote/save)
  double secondActionThreshold = 0.35;

  Map<String, SwipeAction> swipeActions = {
    'leftPrimary': SwipeAction.upvote,
    'leftSecondary': SwipeAction.downvote,
    'rightPrimary': SwipeAction.reply,
    'rightSecondary': SwipeAction.save,
  };

  @override
  void initState() {
    // Set the correct swipe actions from settings
    SharedPreferences? prefs = context.read<ThunderBloc>().state.preferences;

    if (prefs != null) {
      swipeActions = {
        'leftPrimary': SwipeAction.values.byName(prefs.getString('setting_gesture_post_left_primary_gesture') ?? SwipeAction.upvote.name),
        'leftSecondary': SwipeAction.values.byName(prefs.getString('setting_gesture_post_left_secondary_gesture') ?? SwipeAction.downvote.name),
        'rightPrimary': SwipeAction.values.byName(prefs.getString('setting_gesture_post_right_primary_gesture') ?? SwipeAction.reply.name),
        'rightSecondary': SwipeAction.values.byName(prefs.getString('setting_gesture_post_right_secondary_gesture') ?? SwipeAction.save.name),
      };
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    // Set the correct swipe actions from settings
    SharedPreferences? prefs = context.read<ThunderBloc>().state.preferences;

    if (prefs != null) {
      swipeActions = {
        'leftPrimary': SwipeAction.values.byName(prefs.getString('setting_gesture_post_left_primary_gesture') ?? SwipeAction.upvote.name),
        'leftSecondary': SwipeAction.values.byName(prefs.getString('setting_gesture_post_left_secondary_gesture') ?? SwipeAction.downvote.name),
        'rightPrimary': SwipeAction.values.byName(prefs.getString('setting_gesture_post_right_primary_gesture') ?? SwipeAction.reply.name),
        'rightSecondary': SwipeAction.values.byName(prefs.getString('setting_gesture_post_right_secondary_gesture') ?? SwipeAction.save.name),
      };
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    VoteType? myVote = widget.postViewMedia.postView.myVote;
    bool saved = widget.postViewMedia.postView.saved;

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
    final bool useCompactView = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_use_compact_view') ?? false;
    final bool disableSwipeActionsOnPost = context.read<ThunderBloc>().state.preferences?.getBool('setting_post_disable_swipe_actions') ?? false;
    final bool useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    final bool hideNsfwPreviews = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_hide_nsfw_previews') ?? true;
    final bool showThumbnailPreviewOnRight = context.read<ThunderBloc>().state.preferences?.getBool('setting_compact_show_thumbnail_on_right') ?? false;

    final bool showVoteActions = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_show_vote_actions') ?? true;
    final bool showSaveAction = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_show_save_action') ?? true;
    final bool showFullHeightImages = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_show_full_height_images') ?? false;
    final bool showTextContent = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_show_text_content') ?? false;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => {},
      onPointerUp: (event) => {
        triggerPostAction(
          context: context,
          swipeAction: swipeAction,
          onSaveAction: (int postId, bool saved) => widget.onSaveAction(saved),
          onVoteAction: (int postId, VoteType vote) => widget.onVoteAction(vote),
          voteType: myVote ?? VoteType.none,
          saved: saved,
          postViewMedia: widget.postViewMedia,
        ),
      },
      onPointerCancel: (event) => {},
      child: Dismissible(
        direction: (isUserLoggedIn && !disableSwipeActionsOnPost) ? DismissDirection.horizontal : DismissDirection.none,
        key: ObjectKey(widget.postViewMedia.postView.post.id),
        resizeDuration: Duration.zero,
        dismissThresholds: const {DismissDirection.endToStart: 1, DismissDirection.startToEnd: 1},
        confirmDismiss: (DismissDirection direction) async {
          return false;
        },
        onUpdate: (DismissUpdateDetails details) {
          SwipeAction? updatedSwipeAction;

          if (details.progress > firstActionThreshold && details.progress < secondActionThreshold && details.direction == DismissDirection.startToEnd) {
            updatedSwipeAction = swipeActions['leftPrimary'];
            if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
          } else if (details.progress > secondActionThreshold && details.direction == DismissDirection.startToEnd) {
            updatedSwipeAction = swipeActions['leftSecondary'];
            if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
          } else if (details.progress > firstActionThreshold && details.progress < secondActionThreshold && details.direction == DismissDirection.endToStart) {
            updatedSwipeAction = swipeActions['rightPrimary'];
            if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
          } else if (details.progress > secondActionThreshold && details.direction == DismissDirection.endToStart) {
            updatedSwipeAction = swipeActions['rightSecondary'];
            if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
          } else {
            updatedSwipeAction = null;
          }

          setState(() {
            dismissThreshold = details.progress;
            dismissDirection = details.direction;
            swipeAction = updatedSwipeAction;
          });
        },
        background: dismissDirection == DismissDirection.startToEnd
            ? AnimatedContainer(
                alignment: Alignment.centerLeft,
                color: swipeAction == null
                    ? getSwipeActionColor(swipeActions['leftPrimary'] ?? SwipeAction.none).withOpacity(dismissThreshold / firstActionThreshold)
                    : getSwipeActionColor(swipeAction ?? SwipeAction.none),
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * dismissThreshold,
                  child: swipeAction == null ? Container() : Icon(getSwipeActionIcon(swipeAction ?? SwipeAction.none)),
                ),
              )
            : AnimatedContainer(
                alignment: Alignment.centerRight,
                color: swipeAction == null
                    ? getSwipeActionColor(swipeActions['rightPrimary'] ?? SwipeAction.none).withOpacity(dismissThreshold / firstActionThreshold)
                    : getSwipeActionColor(swipeAction ?? SwipeAction.none),
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * dismissThreshold,
                  child: swipeAction == null ? Container() : Icon(getSwipeActionIcon(swipeAction ?? SwipeAction.none)),
                ),
              ),
        child: Column(
          children: [
            Divider(
              height: 1.0,
              thickness: 4.0,
              color: ElevationOverlay.applySurfaceTint(
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceTint,
                1,
              ),
            ),
            InkWell(
              child: useCompactView
                  ? PostCardViewCompact(
                      postViewMedia: widget.postViewMedia,
                      showThumbnailPreviewOnRight: showThumbnailPreviewOnRight,
                      hideNsfwPreviews: hideNsfwPreviews,
                      showInstanceName: widget.showInstanceName,
                    )
                  : PostCardViewComfortable(
                      postViewMedia: widget.postViewMedia,
                      showThumbnailPreviewOnRight: showThumbnailPreviewOnRight,
                      hideNsfwPreviews: hideNsfwPreviews,
                      showInstanceName: widget.showInstanceName,
                      showFullHeightImages: showFullHeightImages,
                      showVoteActions: showVoteActions,
                      showSaveAction: showSaveAction,
                      showTextContent: showTextContent,
                      isUserLoggedIn: isUserLoggedIn,
                      onVoteAction: widget.onVoteAction,
                      onSaveAction: widget.onSaveAction,
                    ),
              onLongPress: () => showPostActionBottomModalSheet(context, widget.postViewMedia),
              onTap: () async {
                AccountBloc accountBloc = context.read<AccountBloc>();
                AuthBloc authBloc = context.read<AuthBloc>();
                ThunderBloc thunderBloc = context.read<ThunderBloc>();
                CommunityBloc communityBloc = context.read<CommunityBloc>();

                // Mark post as read when tapped
                if (isUserLoggedIn) context.read<CommunityBloc>().add(MarkPostAsReadEvent(postId: widget.postViewMedia.postView.post.id, read: true));

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: accountBloc),
                          BlocProvider.value(value: authBloc),
                          BlocProvider.value(value: thunderBloc),
                          BlocProvider.value(value: communityBloc),
                          BlocProvider(create: (context) => post_bloc.PostBloc()),
                        ],
                        child: PostPage(
                          postView: widget.postViewMedia,
                          onPostUpdated: () {},
                        ),
                      );
                    },
                  ),
                );
                if (context.mounted) context.read<CommunityBloc>().add(ForceRefreshEvent());
              },
            ),
          ],
        ),
      ),
    );
  }
}
