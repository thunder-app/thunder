import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/community/widgets/post_card_view_compact.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/media.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/moderator/bloc/report_bloc.dart';
import 'package:thunder/moderator/widgets/report_feed_page_app_bar.dart';
import 'package:thunder/post/utils/navigate_post.dart';
import 'package:thunder/shared/comment_reference.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/global_context.dart';

enum ReportFeedType { post, comment }

/// Creates a [ReportFeedPage] which holds a list of reported posts/comments.
class ReportFeedPage extends StatefulWidget {
  const ReportFeedPage({super.key});

  @override
  State<ReportFeedPage> createState() => _ReportFeedPageState();
}

class _ReportFeedPageState extends State<ReportFeedPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportBloc>(
      create: (_) => ReportBloc(lemmyClient: LemmyClient.instance)..add(const ReportFeedFetchedEvent(reportFeedType: ReportFeedType.post, reset: true)),
      child: const ReportFeedView(),
    );
  }
}

class ReportFeedView extends StatefulWidget {
  const ReportFeedView({super.key});

  @override
  State<ReportFeedView> createState() => _ReportFeedViewState();
}

class _ReportFeedViewState extends State<ReportFeedView> {
  final ScrollController _scrollController = ScrollController();

  /// The type of the reports to look at
  ReportFeedType reportFeedType = ReportFeedType.post;

  /// Boolean which indicates whether the title on the app bar should be shown
  bool showAppBarTitle = false;

  /// Boolean which indicates whether resolved reports should be shown
  bool showResolved = false;

  /// Indicates which "tab" is selected. This is used for user profiles, where we can switch between posts and comments
  List<bool> selectedUserOption = [true, false];

  /// List of tabs for user profiles
  List<Widget> userOptionTypes = <Widget>[
    Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.of(GlobalContext.context)!.posts)),
    Padding(padding: const EdgeInsets.all(8.0), child: Text(AppLocalizations.of(GlobalContext.context)!.comments)),
  ];

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      // Updates the [showAppBarTitle] value when the user has scrolled past a given threshold
      if (_scrollController.position.pixels > 100.0 && showAppBarTitle == false) {
        setState(() => showAppBarTitle = true);
      } else if (_scrollController.position.pixels < 100.0 && showAppBarTitle == true) {
        setState(() => showAppBarTitle = false);
      }

      // Fetches new post/comment reports when the user has scrolled past 70% list
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent * 0.7 && context.read<ReportBloc>().state.status != ReportStatus.fetching) {
        context.read<ReportBloc>().add(ReportFeedFetchedEvent(reportFeedType: selectedUserOption[0] ? ReportFeedType.post : ReportFeedType.comment));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thunderState = context.watch<ThunderBloc>().state;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        top: thunderState.hideTopBarOnScroll, // Don't apply to top of screen to allow for the status bar colour to extend
        child: BlocConsumer<ReportBloc, ReportState>(
          listenWhen: (previous, current) {
            if (current.status == ReportStatus.initial) {
              setState(() => showAppBarTitle = false);
              _scrollController.jumpTo(0);
            }
            return true;
          },
          listener: (context, state) {
            // Continue to fetch more report items as long as the device view is not scrollable.
            // This is to avoid cases where more report items cannot be fetched because the conditions are not met
            if (state.status == ReportStatus.success &&
                (reportFeedType == ReportFeedType.post && state.hasReachedPostReportsEnd == false || reportFeedType == ReportFeedType.comment && state.hasReachedCommentReportsEnd == false)) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                // Wait until the layout is complete before performing check
                bool isScrollable = _scrollController.position.maxScrollExtent > _scrollController.position.viewportDimension;
                if (!isScrollable) context.read<ReportBloc>().add(const ReportFeedFetchedEvent());
              });
            }

            if ((state.status == ReportStatus.failure) && state.message != null) {
              showSnackbar(state.message!);
              context.read<ReportBloc>().add(ReportFeedClearMessageEvent()); // Clear the message so that it does not spam
            }
          },
          builder: (context, state) {
            final theme = Theme.of(context);

            return RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                context.read<ReportBloc>().add(ReportFeedFetchedEvent(reportFeedType: reportFeedType, reset: true));
              },
              edgeOffset: 95.0, // This offset is placed to allow the correct positioning of the refresh indicator
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                      ReportFeedPageAppBar(
                        showAppBarTitle: state.status != ReportStatus.initial ? true : showAppBarTitle,
                        onShowResolved: (bool showResolved) {
                          setState(() => showResolved = showResolved);
                          context.read<ReportBloc>().add(ReportFeedFetchedEvent(reportFeedType: reportFeedType, showResolved: showResolved, reset: true));
                        },
                      ),
                      // Display loading indicator until the feed is fetched
                      if (state.status == ReportStatus.initial)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: ToggleButtons(
                              constraints: BoxConstraints.expand(width: (MediaQuery.of(context).size.width / (userOptionTypes.length)) - 12.0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              direction: Axis.horizontal,
                              onPressed: (int index) {
                                setState(() {
                                  // The button that is tapped is set to true, and the others to false.
                                  for (int i = 0; i < selectedUserOption.length; i++) {
                                    selectedUserOption[i] = i == index;
                                  }
                                });
                              },
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                              isSelected: selectedUserOption,
                              children: userOptionTypes,
                            ),
                          ),
                        ),
                      ),
                      // Widget representing the list of reports on the feed
                      selectedUserOption[0]
                          ? SliverList.builder(
                              itemBuilder: (context, index) {
                                PostView postView = PostView(
                                  post: state.postReports[index].post,
                                  creator: state.postReports[index].creator,
                                  community: state.postReports[index].community,
                                  creatorBannedFromCommunity: state.postReports[index].creatorBannedFromCommunity,
                                  counts: state.postReports[index].counts,
                                  subscribed: SubscribedType.notSubscribed,
                                  saved: false,
                                  read: false,
                                  creatorBlocked: false,
                                  unreadComments: 0,
                                );

                                return Column(
                                  children: [
                                    Wrap(
                                      spacing: 8.0,
                                      children: [
                                        InkWell(
                                          onTap: () => navigateToPost(context, postId: state.postReports[index].post.id),
                                          child: PostCardViewCompact(
                                            showMedia: false,
                                            postViewMedia: PostViewMedia(postView: postView, media: [Media(mediaType: MediaType.text)]),
                                            communityMode: false,
                                            isUserLoggedIn: false,
                                            listingType: ListingType.all,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Divider(thickness: 1.0, color: theme.dividerColor.withOpacity(0.3)),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ScalableText(
                                                    l10n.detailedReason(state.postReports[index].postReport.reason),
                                                    maxLines: 4,
                                                    overflow: TextOverflow.ellipsis,
                                                    fontScale: thunderState.contentFontSizeScale,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.70),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    onPressed: () {
                                                      // context.read<ReportBloc>().add(ReportPostResolvedEvent(index: index));
                                                    },
                                                    icon: Icon(state.postReports[index].postReport.resolved ? Icons.undo_rounded : Icons.check_rounded),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      height: 1.0,
                                      thickness: 4.0,
                                      color: ElevationOverlay.applySurfaceTint(
                                        theme.colorScheme.surface,
                                        theme.colorScheme.surfaceTint,
                                        10,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              itemCount: state.postReports.length,
                            )
                          : SliverList.builder(
                              itemBuilder: (context, index) {
                                CommentView commentView = CommentView(
                                  comment: state.commentReports[index].comment,
                                  creator: state.commentReports[index].creator,
                                  post: state.commentReports[index].post,
                                  community: state.commentReports[index].community,
                                  counts: state.commentReports[index].counts,
                                  creatorBannedFromCommunity: state.commentReports[index].creatorBannedFromCommunity,
                                  subscribed: SubscribedType.notSubscribed, // Not available
                                  saved: false, // Not available
                                  creatorBlocked: false, // Not available
                                );

                                return Column(
                                  children: [
                                    Wrap(
                                      spacing: 8.0,
                                      children: [
                                        CommentReference(
                                          comment: commentView,
                                          now: DateTime.now(),
                                          onVoteAction: (int commentId, int voteType) {},
                                          onSaveAction: (int commentId, bool saved) {},
                                          onDeleteAction: (int commentId, bool deleted) {},
                                          isOwnComment: false,
                                          onReplyEditAction: (CommentView commentView, bool isEdit) {},
                                          onReportAction: (int commentId) {},
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Divider(thickness: 1.0, color: theme.dividerColor.withOpacity(0.3)),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ScalableText(
                                                    l10n.detailedReason(state.commentReports[index].commentReport.reason),
                                                    maxLines: 4,
                                                    overflow: TextOverflow.ellipsis,
                                                    fontScale: thunderState.contentFontSizeScale,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.70),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    onPressed: () {
                                                      // context.read<ReportBloc>().add(ReportPostResolvedEvent(index: index));
                                                    },
                                                    icon: Icon(state.commentReports[index].commentReport.resolved ? Icons.undo_rounded : Icons.check_rounded),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      height: 1.0,
                                      thickness: 4.0,
                                      color: ElevationOverlay.applySurfaceTint(
                                        theme.colorScheme.surface,
                                        theme.colorScheme.surfaceTint,
                                        10,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              itemCount: state.commentReports.length,
                            ),

                      // Widget representing the bottom of the feed (reached end or loading more events indicators)
                      SliverToBoxAdapter(
                        child: (reportFeedType == ReportFeedType.post && state.hasReachedPostReportsEnd) || (reportFeedType == ReportFeedType.comment && state.hasReachedCommentReportsEnd)
                            ? const FeedReachedEnd()
                            : Container(
                                height: state.status == ReportStatus.initial ? MediaQuery.of(context).size.height * 0.5 : null, // Might have to adjust this to be more robust
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: const CircularProgressIndicator(),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
