import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy/lemmy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/community.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart' as post_bloc; // renamed to prevent clash with VotePostEvent, etc from community_bloc
import 'package:thunder/post/pages/post_page.dart';
import 'package:thunder/post/widgets/comment_card.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class PostCard extends StatefulWidget {
  final PostViewMedia postView;
  final bool showInstanceName;

  const PostCard({super.key, required this.postView, this.showInstanceName = true});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  double dismissThreshold = 0;
  DismissDirection? dismissDirection;
  SwipeAction? swipeAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    int? myVote = widget.postView.myVote;
    bool saved = widget.postView.saved;
    int score = widget.postView.counts.score;

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
    final bool useCompactView = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_use_compact_view') ?? false;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => {},
      onPointerUp: (event) {
        // Check to see what the swipe action is
        if (swipeAction == SwipeAction.upvote) {
          // @todo: optimistic update
          int vote = myVote == 1 ? 0 : 1;
          context.read<CommunityBloc>().add(VotePostEvent(postId: widget.postView.post.id, score: vote));
        }

        if (swipeAction == SwipeAction.downvote) {
          // @todo: optimistic update
          int vote = myVote == -1 ? 0 : -1;
          context.read<CommunityBloc>().add(VotePostEvent(postId: widget.postView.post.id, score: vote));
        }

        if (swipeAction == SwipeAction.reply) {}

        if (swipeAction == SwipeAction.save) {
          context.read<CommunityBloc>().add(SavePostEvent(postId: widget.postView.post.id, save: !saved));
        }
      },
      onPointerCancel: (event) => {},
      child: Dismissible(
        direction: isUserLoggedIn ? DismissDirection.horizontal : DismissDirection.none,
        key: ObjectKey(widget.postView.post.id),
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
              thickness: 2.0,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.20),
            ),
            InkWell(
              child: useCompactView ? compactPostLayout(context) : comfortablePostLayout(context),
              onTap: () async {
                AccountBloc accountBloc = context.read<AccountBloc>();
                AuthBloc authBloc = context.read<AuthBloc>();
                ThunderBloc thunderBloc = context.read<ThunderBloc>();
                CommunityBloc communityBloc = BlocProvider.of<CommunityBloc>(context);

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: accountBloc),
                        BlocProvider.value(value: authBloc),
                        BlocProvider.value(value: thunderBloc),
                        BlocProvider.value(value: communityBloc),
                        BlocProvider(create: (context) => post_bloc.PostBloc()),
                      ],
                      child: PostPage(postView: widget.postView),
                    ),
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

  Widget compactPostLayout(BuildContext context) {
    final Post post = widget.postView.post;
    final ThemeData theme = Theme.of(context);

    final bool hideNsfwPreviews = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_hide_nsfw_previews') ?? true;

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MediaView(
            postView: widget.postView,
            showFullHeightImages: false,
            hideNsfwPreviews: hideNsfwPreviews,
            viewMode: ViewMode.compact,
          ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(post.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4.0),
                    GestureDetector(
                      child: Text(
                        '${widget.postView.community.name}${widget.showInstanceName ? ' · ${fetchInstanceNameFromUrl(widget.postView.community.actorId)}' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                        ),
                      ),
                      onTap: () => onTapCommunityName(context),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
                postMetadata(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget comfortablePostLayout(BuildContext context) {
    final Post post = widget.postView.post;
    final ThemeData theme = Theme.of(context);

    final bool showFullHeightImages = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_show_full_height_images') ?? false;
    final bool hideNsfwPreviews = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_hide_nsfw_previews') ?? true;

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MediaView(
            postView: widget.postView,
            showFullHeightImages: showFullHeightImages,
            hideNsfwPreviews: hideNsfwPreviews,
          ),
          Text(post.name, style: theme.textTheme.titleMedium, softWrap: true),
          Padding(
            padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                          child: Text(
                            '${widget.postView.community.name}${widget.showInstanceName ? ' · ${fetchInstanceNameFromUrl(widget.postView.community.actorId)}' : ''}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: theme.textTheme.titleSmall!.fontSize! * 1.05,
                              color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
                            ),
                          ),
                          onTap: () {
                            AccountBloc accountBloc = context.read<AccountBloc>();
                            AuthBloc authBloc = context.read<AuthBloc>();
                            ThunderBloc thunderBloc = context.read<ThunderBloc>();

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider.value(value: accountBloc),
                                    BlocProvider.value(value: authBloc),
                                    BlocProvider.value(value: thunderBloc),
                                  ],
                                  child: CommunityPage(communityId: widget.postView.community.id),
                                ),
                              ),
                            );
                          }),
                      const SizedBox(height: 8.0),
                      postMetadata(context),
                    ],
                  ),
                ),
                if (isUserLoggedIn) postActions(context),
              ],
            ),
          )
        ],
      ),
    );
  }

  void onTapCommunityName(BuildContext context) {
    AccountBloc accountBloc = context.read<AccountBloc>();
    AuthBloc authBloc = context.read<AuthBloc>();
    ThunderBloc thunderBloc = context.read<ThunderBloc>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: accountBloc),
            BlocProvider.value(value: authBloc),
            BlocProvider.value(value: thunderBloc),
          ],
          child: CommunityPage(communityId: widget.postView.community.id),
        ),
      ),
    );
  }

  // Holds the counts for a given post
  Widget postMetadata(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Post post = widget.postView.post;
    final int? myVote = widget.postView.myVote;
    final bool saved = widget.postView.saved;

    final bool useCompactView = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_use_compact_view') ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconText(
              text: formatNumberToK(widget.postView.counts.score),
              icon: Icon(
                Icons.arrow_upward,
                size: 18.0,
                color: myVote == 1
                    ? Colors.orange
                    : myVote == -1
                        ? Colors.blue
                        : theme.textTheme.titleSmall?.color?.withOpacity(0.75),
              ),
              padding: 2.0,
            ),
            const SizedBox(width: 12.0),
            IconText(
              icon: Icon(
                Icons.chat,
                size: 17.0,
                color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
              ),
              text: formatNumberToK(widget.postView.counts.comments),
              padding: 5.0,
            ),
            const SizedBox(width: 10.0),
            IconText(
              icon: Icon(
                Icons.history_rounded,
                size: 19.0,
                color: theme.textTheme.titleSmall?.color?.withOpacity(0.75),
              ),
              text: formatTimeToString(dateTime: post.published),
            ),
            const SizedBox(width: 14.0),
            if (post.featuredCommunity == true || post.featuredLocal == true)
              Icon(
                Icons.campaign_rounded,
                size: 24.0,
                color: Colors.green.shade800,
              ),
          ],
        ),
        if (useCompactView)
          Icon(
            saved ? Icons.star_rounded : null,
            color: saved ? Colors.purple : null,
            size: 22.0,
          ),
      ],
    );
  }

  // Holds the various actions for a given post card (upvote, downvote, save)
  Widget postActions(BuildContext context) {
    final SharedPreferences? prefs = context.read<ThunderBloc>().state.preferences;

    final bool showVoteActions = prefs?.getBool('setting_general_show_vote_actions') ?? true;
    final bool showSaveAction = prefs?.getBool('setting_general_show_save_action') ?? true;

    final Post post = widget.postView.post;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showVoteActions)
          IconButton(
              icon: Icon(
                Icons.arrow_upward,
                semanticLabel: widget.postView.myVote == 1 ? 'Upvoted' : 'Upvote',
              ),
              color: widget.postView.myVote == 1 ? Colors.orange : null,
              visualDensity: VisualDensity.compact,
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.read<CommunityBloc>().add(VotePostEvent(postId: post.id, score: widget.postView.myVote == 1 ? 0 : 1));
              }),
        if (showVoteActions)
          IconButton(
            icon: Icon(
              Icons.arrow_downward,
              semanticLabel: widget.postView.myVote == -1 ? 'Downvoted' : 'Downvote',
            ),
            color: widget.postView.myVote == -1 ? Colors.blue : null,
            visualDensity: VisualDensity.compact,
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.read<CommunityBloc>().add(VotePostEvent(postId: post.id, score: widget.postView.myVote == -1 ? 0 : -1));
            },
          ),
        if (showSaveAction)
          IconButton(
            icon: Icon(
              widget.postView.saved ? Icons.star_rounded : Icons.star_border_rounded,
              semanticLabel: widget.postView.saved ? 'Saved' : 'Save',
            ),
            color: widget.postView.saved ? Colors.purple : null,
            visualDensity: VisualDensity.compact,
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.read<CommunityBloc>().add(SavePostEvent(
                    postId: post.id,
                    save: widget.postView.saved ? false : true,
                  ));
            },
          ),
      ],
    );
  }
}
