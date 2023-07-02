import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:provider/provider.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/community/widgets/post_card_view_comfortable.dart';
import 'package:thunder/community/widgets/post_card_view_compact.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/theme/theme.dart';
import 'package:thunder/post/bloc/post_bloc.dart' as post_bloc; // renamed to prevent clash with VotePostEvent, etc from community_bloc
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/post/widgets/comment_card.dart';
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
  double dismissThreshold = 0;
  DismissDirection? dismissDirection;
  SwipeAction? swipeAction;

  int rebuildCount = 0;

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
      onPointerUp: (event) {
        if (swipeAction == SwipeAction.upvote) {
          widget.onVoteAction(myVote == VoteType.up ? VoteType.none : VoteType.up);
        }

        if (swipeAction == SwipeAction.downvote) {
          widget.onVoteAction(myVote == VoteType.down ? VoteType.none : VoteType.down);
        }

        if (swipeAction == SwipeAction.reply) {
          SnackBar snackBar = const SnackBar(
            content: Text('Replying from this view is currently not supported yet'),
            behavior: SnackBarBehavior.floating,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }

        if (swipeAction == SwipeAction.save) {
          widget.onSaveAction(!saved);
        }
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
          SwipeAction? _swipeAction;

          if (details.progress > 0.1 && details.progress < 0.3 && details.direction == DismissDirection.startToEnd) {
            _swipeAction = SwipeAction.upvote;
            if (swipeAction != _swipeAction) HapticFeedback.mediumImpact();
          } else if (details.progress > 0.3 && details.direction == DismissDirection.startToEnd) {
            _swipeAction = SwipeAction.downvote;
            if (swipeAction != _swipeAction) HapticFeedback.mediumImpact();
          } else if (details.progress > 0.1 && details.progress < 0.3 && details.direction == DismissDirection.endToStart) {
            _swipeAction = SwipeAction.reply;
            if (swipeAction != _swipeAction) HapticFeedback.mediumImpact();
          } else if (details.progress > 0.3 && details.direction == DismissDirection.endToStart) {
            _swipeAction = SwipeAction.save;
            if (swipeAction != _swipeAction) HapticFeedback.mediumImpact();
          } else {
            _swipeAction = null;
          }

          setState(() {
            dismissThreshold = details.progress;
            dismissDirection = details.direction;
            swipeAction = _swipeAction;
          });
        },
        background: dismissDirection == DismissDirection.startToEnd
            ? AnimatedContainer(
                alignment: Alignment.centerLeft,
                color: dismissThreshold < 0.3 ? Colors.orange.shade700 : Colors.blue.shade700,
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * dismissThreshold,
                  child: Icon(dismissThreshold < 0.3 ? Icons.north : Icons.south),
                ),
              )
            : AnimatedContainer(
                alignment: Alignment.centerRight,
                color: dismissThreshold < 0.3 ? Colors.green.shade700 : Colors.purple.shade700,
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * dismissThreshold,
                  child: Icon(dismissThreshold < 0.3 ? Icons.reply : Icons.star_rounded),
                ),
              ),
        child: Column(
          children: [
            Divider(
              height: 1.0,
              thickness: 4.0,
              color: useDarkTheme ? theme.colorScheme.background.lighten(7) : theme.colorScheme.background.darken(7),
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
