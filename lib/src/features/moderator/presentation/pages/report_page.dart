import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/wiring/state_factories.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/moderator/moderator.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/features/comment/presentation/widgets/comment_reference.dart';
import 'package:thunder/src/shared/identity/widgets/full_name_widgets.dart';
import 'package:thunder/src/features/session/api.dart';

import 'package:thunder/packages/ui/ui.dart' show ScalableText;
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar;

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
    final account = resolveActiveAccount(context);

    return BlocProvider<ReportBloc>(
      create: (_) => createReportBloc(account)..add(const ReportFeedFetchedEvent(reportFeedType: ReportFeedType.post, reset: true)),
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
  /// The global key for the [NestedScrollView]. This allows us to access the inner [ScrollController]
  final GlobalKey<NestedScrollViewState> globalKey = GlobalKey();

  /// The type of the reports to look at
  ReportFeedType reportFeedType = ReportFeedType.post;

  /// Boolean which indicates whether resolved reports should be shown
  bool showResolved = false;

  /// List of tabs for the report page
  /// TODO: Add support for private messages
  List<String> reportOptionTypes = [AppLocalizations.of(GlobalContext.context)!.posts, AppLocalizations.of(GlobalContext.context)!.comments];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      globalKey.currentState?.innerController.addListener(() {
        // Fetches new post/comment reports when the user has scrolled past 70% list
        if (globalKey.currentState!.innerController.position.pixels > globalKey.currentState!.innerController.position.maxScrollExtent * 0.7 &&
            context.read<ReportBloc>().state.status != ReportStatus.fetching) {
          context.read<ReportBloc>().add(ReportFeedFetchedEvent(reportFeedType: reportFeedType));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.contentFontSizeScale);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: reportOptionTypes.length,
      child: Scaffold(
        body: NestedScrollView(
          key: globalKey,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  pinned: true,
                  centerTitle: false,
                  forceElevated: innerBoxIsScrolled,
                  title: Text(l10n.report(2), style: theme.textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                  leading: IconButton(
                    icon: (!kIsWeb && Platform.isIOS
                        ? Icon(Icons.arrow_back_ios_new_rounded, semanticLabel: MaterialLocalizations.of(context).backButtonTooltip)
                        : Icon(Icons.arrow_back_rounded, semanticLabel: MaterialLocalizations.of(context).backButtonTooltip)),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).maybePop();
                    },
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ReportBloc reportBloc = context.read<ReportBloc>();

                        reportBloc.add(ReportFeedFetchedEvent(
                          reportFeedType: reportFeedType,
                          showResolved: showResolved,
                          communityId: reportBloc.state.communityId,
                          reset: true,
                        ));
                      },
                      icon: Icon(Icons.refresh_rounded, semanticLabel: l10n.refresh),
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_alt_rounded, semanticLabel: l10n.filters),
                      onPressed: () {
                        HapticFeedback.mediumImpact();

                        showModalBottomSheet<void>(
                          showDragHandle: true,
                          context: context,
                          builder: (builderContext) => ReportFilterBottomSheet(
                            account: context.read<ReportBloc>().account,
                            status: showResolved ? ReportResolveStatus.all : ReportResolveStatus.unresolved,
                            onSubmit: (ReportResolveStatus status, ThunderCommunity? community) async => {
                              HapticFeedback.mediumImpact(),
                              Navigator.of(context).maybePop(),
                              setState(() => showResolved = status != ReportResolveStatus.unresolved),
                              BlocProvider.of<ReportBloc>(context).add(ReportFeedChangeFilterTypeEvent(
                                showResolved: status != ReportResolveStatus.unresolved,
                                communityId: community?.id,
                              ))
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                  ],
                  bottom: TabBar(
                    tabs: reportOptionTypes.map((String title) => Tab(text: title)).toList(),
                    onTap: (index) {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        if (index == 0) {
                          reportFeedType = ReportFeedType.post;
                        } else {
                          reportFeedType = ReportFeedType.comment;
                        }
                      });
                    },
                  ),
                ),
              ),
            ];
          },
          body: BlocConsumer<ReportBloc, ReportState>(
            listenWhen: (previous, current) {
              if (current.status == ReportStatus.initial) {
                globalKey.currentState?.innerController.jumpTo(0);
              }
              return true;
            },
            listener: (context, state) {
              if ((state.status == ReportStatus.failure) && state.message != null) {
                showSnackbar(state.message!);
                context.read<ReportBloc>().add(ReportFeedClearMessageEvent()); // Clear the message so that it does not spam
              }
            },
            builder: (BuildContext context, ReportState state) => TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: reportOptionTypes.map((String title) {
                return SafeArea(
                  top: false,
                  bottom: false,
                  child: Builder(
                    builder: (BuildContext context) {
                      return CustomScrollView(
                        key: PageStorageKey<String>(title),
                        slivers: <Widget>[
                          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
                          // Display loading indicator until the feed is fetched
                          if (state.status == ReportStatus.initial)
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(child: CircularProgressIndicator()),
                            ),

                          // Widget representing the list of reports on the feed
                          if (reportFeedType == ReportFeedType.post)
                            SliverList.builder(
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Wrap(
                                      spacing: 8.0,
                                      children: [
                                        InkWell(
                                          onTap: () => navigateToPost(context, postId: state.postReports[index].post!.id),
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: PostCardViewCompact(
                                              showMedia: false,
                                              post: state.postReports[index].post!,
                                              creator: state.postReports[index].creator!,
                                              community: state.postReports[index].community!,
                                              isLastTapped: false,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Divider(thickness: 1.0, color: theme.dividerColor.withValues(alpha: 0.3)),
                                              Wrap(
                                                children: [
                                                  Text(l10n.reporter, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                                  InkWell(
                                                    borderRadius: BorderRadius.circular(6),
                                                    onTap: () {
                                                      navigateToFeedPage(context, feedType: FeedType.user, userId: state.postReports[index].creator!.id);
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                      child: UserFullNameWidget(
                                                          name: state.postReports[index].creator?.name ?? '',
                                                          displayName: state.postReports[index].creator?.displayName ?? '',
                                                          instance: fetchInstanceNameFromUrl(state.postReports[index].creator?.actorId ?? '')),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4.0),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ScalableText(
                                                    l10n.detailedReason(state.postReports[index].reason),
                                                    maxLines: 4,
                                                    overflow: TextOverflow.ellipsis,
                                                    textScaleFactor: contentFontSizeScale.textScaleFactor,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: theme.colorScheme.error,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    onPressed: () {
                                                      HapticFeedback.mediumImpact();
                                                      context.read<ReportBloc>().add(ReportFeedItemActionedEvent(
                                                            reportAction: ReportAction.resolvePost,
                                                            postReportView: state.postReports[index],
                                                            actionInput: ResolveReportActionInput(!state.postReports[index].resolved),
                                                          ));
                                                    },
                                                    icon: Icon(state.postReports[index].resolved ? Icons.undo_rounded : Icons.check_rounded),
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
                            ),

                          if (reportFeedType == ReportFeedType.comment)
                            SliverList.builder(
                              itemBuilder: (context, index) {
                                final comment = state.commentReports[index].comment?.copyWith(
                                  creator: state.commentReports[index].creator,
                                  post: state.commentReports[index].post,
                                  community: state.commentReports[index].community,
                                  score: state.commentReports[index].score,
                                  upvotes: state.commentReports[index].upvotes,
                                  downvotes: state.commentReports[index].downvotes,
                                  childCount: state.commentReports[index].childCount,
                                  creatorBannedFromCommunity: state.commentReports[index].creatorBannedFromCommunity,
                                  bannedFromCommunity: false,
                                  creatorIsModerator: state.commentReports[index].creatorIsModerator,
                                  creatorIsAdmin: state.commentReports[index].creatorIsAdmin,
                                  subscribed: state.commentReports[index].subscribed,
                                  saved: state.commentReports[index].saved,
                                  creatorBlocked: state.commentReports[index].creatorBlocked,
                                  myVote: state.commentReports[index].myVote,
                                );

                                return Column(
                                  children: [
                                    Wrap(
                                      spacing: 8.0,
                                      children: [
                                        CommentReference(comment: comment!),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Divider(thickness: 1.0, color: theme.dividerColor.withValues(alpha: 0.3)),
                                              Wrap(
                                                children: [
                                                  Text(l10n.reporter, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                                  InkWell(
                                                    borderRadius: BorderRadius.circular(6),
                                                    onTap: () {
                                                      navigateToFeedPage(context, feedType: FeedType.user, userId: state.commentReports[index].creator!.id);
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                      child: UserFullNameWidget(
                                                          name: state.commentReports[index].creator?.name,
                                                          displayName: state.commentReports[index].creator?.displayName,
                                                          instance: fetchInstanceNameFromUrl(state.commentReports[index].creator?.actorId)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4.0),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ScalableText(
                                                    l10n.detailedReason(state.commentReports[index].reason),
                                                    maxLines: 4,
                                                    overflow: TextOverflow.ellipsis,
                                                    textScaleFactor: contentFontSizeScale.textScaleFactor,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: theme.colorScheme.error,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    visualDensity: VisualDensity.compact,
                                                    onPressed: () {
                                                      HapticFeedback.mediumImpact();

                                                      context.read<ReportBloc>().add(ReportFeedItemActionedEvent(
                                                            reportAction: ReportAction.resolveComment,
                                                            commentReportView: state.commentReports[index],
                                                            actionInput: ResolveReportActionInput(!state.commentReports[index].resolved),
                                                          ));
                                                    },
                                                    icon: Icon(state.commentReports[index].resolved ? Icons.undo_rounded : Icons.check_rounded),
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
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
