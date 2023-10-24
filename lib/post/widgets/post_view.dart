import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'package:thunder/account/bloc/account_bloc.dart' as account_bloc;
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/pages/create_comment_page.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/shared/advanced_share_sheet.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/thunder/thunder_icons.dart';
import 'package:thunder/user/utils/special_user_checks.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigate_post.dart';
import 'package:thunder/utils/navigate_user.dart';
import 'package:thunder/utils/numbers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/shared/snackbar.dart';

class PostSubview extends StatefulWidget {
  final PostViewMedia postViewMedia;
  final bool useDisplayNames;
  final int? selectedCommentId;
  final List<CommunityModeratorView>? moderators;
  final List<PostView>? crossPosts;

  const PostSubview({
    super.key,
    this.selectedCommentId,
    required this.useDisplayNames,
    required this.postViewMedia,
    required this.moderators,
    required this.crossPosts,
  });

  @override
  State<PostSubview> createState() => _PostSubviewState();
}

class _PostSubviewState extends State<PostSubview> with SingleTickerProviderStateMixin {
  bool _areCrossPostsExpanded = false;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final bool useAdvancedShareSheet = context.read<ThunderBloc>().state.useAdvancedShareSheet;
    final bool showCrossPosts = context.read<ThunderBloc>().state.showCrossPosts;

    final PostView postView = widget.postViewMedia.postView;
    final Post post = postView.post;

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
    final bool downvotesEnabled = context.read<AuthBloc>().state.downvotesEnabled;
    final ThunderState thunderState = context.read<ThunderBloc>().state;

    final bool scrapeMissingPreviews = thunderState.scrapeMissingPreviews;
    final bool hideNsfwPreviews = thunderState.hideNsfwPreviews;
    final bool markPostReadOnMediaView = thunderState.markPostReadOnMediaView;

    final bool isOwnComment = postView.creator.id == context.read<AuthBloc>().state.account?.userId;

    final List<PostView> sortedCrossPosts = List.from(widget.crossPosts ?? [])..sort((a, b) => b.counts.upvotes.compareTo(a.counts.upvotes));

    final TextStyle? crossPostTextStyle = theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic);
    final TextStyle? crossPostLinkTextStyle = crossPostTextStyle?.copyWith(color: Colors.blue);

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              HtmlUnescape().convert(post.name),
              textScaleFactor: MediaQuery.of(context).textScaleFactor * thunderState.titleFontSizeScale.textScaleFactor,
              style: theme.textTheme.titleMedium,
            ),
          ),
          MediaView(
            scrapeMissingPreviews: scrapeMissingPreviews,
            post: post,
            postView: widget.postViewMedia,
            hideNsfwPreviews: hideNsfwPreviews,
            markPostReadOnMediaView: markPostReadOnMediaView,
            isUserLoggedIn: isUserLoggedIn,
          ),
          if (widget.postViewMedia.postView.post.body != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CommonMarkdownBody(
                body: post.body ?? '',
              ),
            ),
          if (showCrossPosts && sortedCrossPosts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _areCrossPostsExpanded = !_areCrossPostsExpanded),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  // The rich text handles overflow across multiple sections (TextSpan) of text
                                  child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: l10n.crossPostedTo,
                                          style: crossPostTextStyle,
                                        ),
                                        TextSpan(
                                          text: ' ${sortedCrossPosts[0].community.name}@${fetchInstanceNameFromUrl(sortedCrossPosts[0].community.actorId)} ',
                                          style: crossPostLinkTextStyle,
                                          // This text is not tappable; there is an invisible widget above this that handles the InkWell and the tap gesture
                                        ),
                                        if (sortedCrossPosts.length > 1)
                                          TextSpan(
                                            text: l10n.andXMore(sortedCrossPosts.length - 1),
                                            style: crossPostTextStyle,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                _areCrossPostsExpanded ? const Icon(Icons.arrow_drop_up_rounded) : const Icon(Icons.arrow_drop_down_rounded),
                              ],
                            ),
                            // This Row widget exists purely so that we can get an InkWell on the community link.
                            // However, the text is insvisible because we actually want the RichText to manage the text,
                            // including overflow.
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    l10n.crossPostedTo,
                                    style: crossPostTextStyle?.copyWith(color: Colors.transparent),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(5),
                                    onTap: () async => navigateToPost(context, postViewMedia: (await parsePostViews([sortedCrossPosts[0]])).first),
                                    child: Text(
                                      ' ${sortedCrossPosts[0].community.name}@${fetchInstanceNameFromUrl(sortedCrossPosts[0].community.actorId)} ',
                                      style: crossPostLinkTextStyle?.copyWith(color: Colors.transparent),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          child: SlideTransition(position: _offsetAnimation, child: child),
                        );
                      },
                      child: _areCrossPostsExpanded
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Row(
                                        children: [
                                          Text(
                                            ' • ',
                                            style: crossPostTextStyle,
                                          ),
                                          InkWell(
                                            onTap: () async => navigateToPost(context, postViewMedia: (await parsePostViews([sortedCrossPosts[index + 1]])).first),
                                            borderRadius: BorderRadius.circular(5),
                                            child: Text(
                                              '${sortedCrossPosts[index + 1].community.name}@${fetchInstanceNameFromUrl(sortedCrossPosts[index + 1].community.actorId)}',
                                              style: crossPostLinkTextStyle,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  itemCount: sortedCrossPosts.length - 1,
                                ),
                                InkWell(
                                  onTap: () async {
                                    // TODO: Use navigateToCreatePostPage
                                    // https://github.com/thunder-app/thunder/blob/4bc8763d597c2fdb6a1e8ae1422cd7f222d2fb58/lib/utils/navigate_create_post.dart
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Row(
                                      children: [
                                        Text(
                                          l10n.createNewCrossPost,
                                          style: crossPostTextStyle,
                                        ),
                                        const Icon(Icons.arrow_right_rounded)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.only(left: isSpecialUser(context, isOwnComment, post, null, postView.creator, widget.moderators) ? 8.0 : 3.0, right: 8.0, top: 16.0),
            child: Row(
              // Row for post view: author, community, comment count and post time
              children: [
                Tooltip(
                  excludeFromSemantics: true,
                  message:
                      '${postView.creator.name}@${fetchInstanceNameFromUrl(postView.creator.actorId) ?? '-'}${fetchUsernameDescriptor(isOwnComment, post, null, postView.creator, widget.moderators)}',
                  preferBelow: false,
                  child: Material(
                    color: isSpecialUser(context, isOwnComment, post, null, postView.creator, widget.moderators)
                        ? fetchUsernameColor(context, isOwnComment, post, null, postView.creator, widget.moderators) ?? theme.colorScheme.onBackground
                        : Colors.transparent,
                    borderRadius: isSpecialUser(context, isOwnComment, post, null, postView.creator, widget.moderators) ? const BorderRadius.all(Radius.elliptical(5, 5)) : null,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        navigateToUserPage(context, userId: postView.creator.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          children: [
                            Text(
                              postView.creator.displayName != null && widget.useDisplayNames ? postView.creator.displayName! : postView.creator.name,
                              textScaleFactor: MediaQuery.of(context).textScaleFactor * thunderState.metadataFontSizeScale.textScaleFactor,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: (isSpecialUser(context, isOwnComment, post, null, postView.creator, widget.moderators) ? theme.colorScheme.onBackground : theme.textTheme.bodyMedium?.color)
                                    ?.withOpacity(0.75),
                              ),
                            ),
                            if (isSpecialUser(context, isOwnComment, post, null, postView.creator, widget.moderators)) const SizedBox(width: 2.0),
                            if (isOwnComment)
                              Padding(
                                padding: const EdgeInsets.only(left: 1),
                                child: Icon(
                                  Icons.person,
                                  size: 15.0 * thunderState.metadataFontSizeScale.textScaleFactor,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                            if (isAdmin(postView.creator))
                              Padding(
                                padding: const EdgeInsets.only(left: 1),
                                child: Icon(
                                  Thunder.shield_crown,
                                  size: 14.0 * thunderState.metadataFontSizeScale.textScaleFactor,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                            if (isModerator(postView.creator, widget.moderators))
                              Padding(
                                padding: const EdgeInsets.only(left: 1),
                                child: Icon(
                                  Thunder.shield,
                                  size: 14.0 * thunderState.metadataFontSizeScale.textScaleFactor,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                            if (isBot(postView.creator))
                              Padding(
                                padding: const EdgeInsets.only(left: 1, right: 2),
                                child: Icon(
                                  Thunder.robot,
                                  size: 13.0 * thunderState.metadataFontSizeScale.textScaleFactor,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (isSpecialUser(context, isOwnComment, post, null, postView.creator, widget.moderators)) const SizedBox(width: 8.0),
                Text(
                  'to',
                  textScaleFactor: MediaQuery.of(context).textScaleFactor * thunderState.metadataFontSizeScale.textScaleFactor,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () {
                    navigateToFeedPage(context, feedType: FeedType.community, communityId: postView.community.id);
                  },
                  child: Tooltip(
                    excludeFromSemantics: true,
                    message: '${postView.community.name}@${fetchInstanceNameFromUrl(postView.community.actorId) ?? 'N/A'}',
                    preferBelow: false,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        postView.community.name,
                        textScaleFactor: MediaQuery.of(context).textScaleFactor * thunderState.metadataFontSizeScale.textScaleFactor,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(), // use Spacer
                Padding(
                  padding: const EdgeInsets.only(right: 0.0),
                  child: PostViewMetaData(
                    comments: widget.postViewMedia.postView.counts.comments,
                    unreadComments: widget.postViewMedia.postView.unreadComments,
                    hasBeenEdited: widget.postViewMedia.postView.post.updated != null ? true : false,
                    published: post.published,
                    saved: postView.saved,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: isUserLoggedIn
                      ? () {
                          HapticFeedback.mediumImpact();
                          context.read<PostBloc>().add(VotePostEvent(postId: post.id, score: postView.myVote == VoteType.up ? VoteType.none : VoteType.up));
                        }
                      : null,
                  style: TextButton.styleFrom(
                    fixedSize: const Size.fromHeight(40),
                    foregroundColor: postView.myVote == VoteType.up ? theme.textTheme.bodyMedium?.color : Colors.orange,
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        semanticLabel: postView.myVote == VoteType.up ? 'Upvoted' : 'Upvote',
                        color: isUserLoggedIn ? (postView.myVote == VoteType.up ? Colors.orange : theme.textTheme.bodyMedium?.color) : null,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        formatNumberToK(widget.postViewMedia.postView.counts.upvotes),
                        style: TextStyle(
                          color: isUserLoggedIn ? (postView.myVote == VoteType.up ? Colors.orange : theme.textTheme.bodyMedium?.color) : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (downvotesEnabled)
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: isUserLoggedIn
                        ? () {
                            HapticFeedback.mediumImpact();
                            context.read<PostBloc>().add(VotePostEvent(postId: post.id, score: postView.myVote == VoteType.down ? VoteType.none : VoteType.down));
                          }
                        : null,
                    style: TextButton.styleFrom(
                      fixedSize: const Size.fromHeight(40),
                      foregroundColor: postView.myVote == VoteType.down ? theme.textTheme.bodyMedium?.color : Colors.blue,
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          semanticLabel: postView.myVote == VoteType.up ? 'Downvoted' : 'Downvote',
                          color: isUserLoggedIn ? (postView.myVote == VoteType.down ? Colors.blue : theme.textTheme.bodyMedium?.color) : null,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          formatNumberToK(widget.postViewMedia.postView.counts.downvotes),
                          style: TextStyle(
                            color: isUserLoggedIn ? (postView.myVote == VoteType.down ? Colors.blue : theme.textTheme.bodyMedium?.color) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: isUserLoggedIn
                      ? () {
                          HapticFeedback.mediumImpact();
                          context.read<PostBloc>().add(SavePostEvent(postId: post.id, save: !postView.saved));
                        }
                      : null,
                  icon: Icon(
                    postView.saved ? Icons.star_rounded : Icons.star_border_rounded,
                    semanticLabel: postView.saved ? 'Saved' : 'Save',
                    color: isUserLoggedIn ? (postView.saved ? Colors.purple : theme.textTheme.bodyMedium?.color) : null,
                  ),
                  style: IconButton.styleFrom(
                    foregroundColor: postView.saved ? null : Colors.purple,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: isUserLoggedIn
                      ? () async {
                          if (postView.post.locked) {
                            showSnackbar(context, l10n.postLocked);
                            return;
                          }

                          PostBloc postBloc = context.read<PostBloc>();
                          ThunderBloc thunderBloc = context.read<ThunderBloc>();
                          account_bloc.AccountBloc accountBloc = context.read<account_bloc.AccountBloc>();

                          final ThunderState state = context.read<ThunderBloc>().state;
                          final bool reduceAnimations = state.reduceAnimations;

                          SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
                          DraftComment? newDraftComment;
                          DraftComment? previousDraftComment;
                          String draftId = '${LocalSettings.draftsCache.name}-${widget.postViewMedia.postView.post.id}';
                          String? draftCommentJson = prefs.getString(draftId);
                          if (draftCommentJson != null) {
                            previousDraftComment = DraftComment.fromJson(jsonDecode(draftCommentJson));
                          }
                          Timer timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
                            if (newDraftComment?.isNotEmpty == true) {
                              prefs.setString(draftId, jsonEncode(newDraftComment!.toJson()));
                            }
                          });

                          Navigator.of(context)
                              .push(
                            SwipeablePageRoute(
                              transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
                              canOnlySwipeFromEdge: true,
                              backGestureDetectionWidth: 45,
                              builder: (context) {
                                return MultiBlocProvider(
                                  providers: [
                                    BlocProvider<PostBloc>.value(value: postBloc),
                                    BlocProvider<ThunderBloc>.value(value: thunderBloc),
                                    BlocProvider<account_bloc.AccountBloc>.value(value: accountBloc),
                                  ],
                                  child: CreateCommentPage(
                                    postView: widget.postViewMedia,
                                    previousDraftComment: previousDraftComment,
                                    onUpdateDraft: (c) => newDraftComment = c,
                                  ),
                                );
                              },
                            ),
                          )
                              .whenComplete(() async {
                            timer.cancel();

                            if (newDraftComment?.saveAsDraft == true && newDraftComment?.isNotEmpty == true) {
                              await Future.delayed(const Duration(milliseconds: 300));
                              showSnackbar(context, l10n.commentSavedAsDraft);
                              prefs.setString(draftId, jsonEncode(newDraftComment!.toJson()));
                            } else {
                              prefs.remove(draftId);
                            }
                          });
                        }
                      : null,
                  icon: postView.post.locked ? Icon(Icons.lock, semanticLabel: l10n.postLocked, color: Colors.red) : Icon(Icons.reply_rounded, semanticLabel: l10n.reply(0)),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: const Icon(Icons.share_rounded, semanticLabel: 'Share'),
                  onPressed: useAdvancedShareSheet
                      ? () => showAdvancedShareSheet(context, widget.postViewMedia)
                      : widget.postViewMedia.media.isEmpty
                          ? () => Share.share(post.apId)
                          : () => showPostActionBottomModalSheet(
                                context,
                                widget.postViewMedia,
                                actionsToInclude: [PostCardAction.sharePost, PostCardAction.shareMedia, PostCardAction.shareLink],
                              ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
