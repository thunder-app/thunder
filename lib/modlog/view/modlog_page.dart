import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/modlog/modlog.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';

/// Creates a [ModlogPage] which holds a list of modlog events.
class ModlogFeedPage extends StatefulWidget {
  const ModlogFeedPage({
    super.key,
    this.modlogActionType,
    this.communityId,
    this.userId,
    this.moderatorId,
    this.lemmyClient,
    this.subtitle,
    this.commentId,
  });

  /// The filtering to be applied to the feed.
  final ModlogActionType? modlogActionType;

  /// The id of the community to display modlog events for.
  final int? communityId;

  /// The id of the user to display modlog events for.
  final int? userId;

  /// The id of the moderator to display modlog events for.
  final int? moderatorId;

  /// The id of a specific comment to show in the modlog (optional)
  final int? commentId;

  /// An optional lemmy client to use a different instance and override the singleton
  final LemmyClient? lemmyClient;

  /// An optional widget to display as the subtitle on the app bar.
  /// If not specified, this will be the instance or community name.
  final Widget? subtitle;

  @override
  State<ModlogFeedPage> createState() => _ModlogFeedPageState();
}

class _ModlogFeedPageState extends State<ModlogFeedPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ModlogBloc>(
      create: (_) => ModlogBloc(lemmyClient: widget.lemmyClient ?? LemmyClient.instance)
        ..add(ModlogFeedFetchedEvent(
          modlogActionType: widget.modlogActionType,
          communityId: widget.communityId,
          userId: widget.userId,
          moderatorId: widget.moderatorId,
          commentId: widget.commentId,
          reset: true,
        )),
      child: ModlogFeedView(lemmyClient: widget.lemmyClient ?? LemmyClient.instance, subtitle: widget.subtitle),
    );
  }
}

class ModlogFeedView extends StatefulWidget {
  /// The current Lemmy client
  final LemmyClient lemmyClient;

  /// Subtitle to display on app bar
  final Widget? subtitle;

  const ModlogFeedView({super.key, required this.lemmyClient, required this.subtitle});

  @override
  State<ModlogFeedView> createState() => _ModlogFeedViewState();
}

class _ModlogFeedViewState extends State<ModlogFeedView> {
  final ScrollController _scrollController = ScrollController();

  /// Boolean which indicates whether the title on the app bar should be shown
  bool showAppBarTitle = false;

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

      // Fetches new modlog events when the user has scrolled past 70% list
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent * 0.7 && context.read<ModlogBloc>().state.status != ModlogStatus.fetching) {
        context.read<ModlogBloc>().add(const ModlogFeedFetchedEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Returns the name of the moderator or admin of the modlog event if it exists
  String getModeratorName(ModlogEventItem modlogEventItem) {
    final l10n = AppLocalizations.of(context)!;

    if (modlogEventItem.moderator != null) {
      return modlogEventItem.moderator!.name;
    }

    if (modlogEventItem.admin != null) {
      return modlogEventItem.admin!.name;
    }

    switch (modlogEventItem.type) {
      case ModlogActionType.adminPurgeComment:
      case ModlogActionType.adminPurgePost:
      case ModlogActionType.adminPurgeCommunity:
      case ModlogActionType.adminPurgePerson:
        return l10n.admin;
      default:
        return l10n.moderator(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final thunderState = context.watch<ThunderBloc>().state;
    final l10n = AppLocalizations.of(context)!;

    Widget? subtitle = widget.subtitle;

    if (subtitle == null) {
      try {
        FeedState feedState = context.read<FeedBloc>().state;

        subtitle = feedState.fullCommunityView != null
            ? CommunityFullNameWidget(
                context,
                feedState.fullCommunityView!.communityView.community.name,
                feedState.fullCommunityView!.communityView.community.title,
                fetchInstanceNameFromUrl(feedState.fullCommunityView!.communityView.community.actorId),
              )
            : Text(widget.lemmyClient.lemmyApiV3.host);
      } catch (e) {
        // Ignore if we can't get the FeedBloc from this context
      }
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocConsumer<ModlogBloc, ModlogState>(
          listenWhen: (previous, current) {
            if (current.status == ModlogStatus.initial) {
              setState(() => showAppBarTitle = false);
              _scrollController.jumpTo(0);
            }
            return true;
          },
          listener: (context, state) {
            // Continue to fetch more modlog events as long as the device view is not scrollable.
            // This is to avoid cases where more modlog events cannot be fetched because the conditions are not met
            if (state.status == ModlogStatus.success && state.hasReachedEnd == false) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                // Wait until the layout is complete before performing check
                bool isScrollable = _scrollController.position.maxScrollExtent > _scrollController.position.viewportDimension;
                if (!isScrollable) context.read<ModlogBloc>().add(const ModlogFeedFetchedEvent());
              });
            }

            if ((state.status == ModlogStatus.failure) && state.message != null) {
              showSnackbar(state.message!);
              context.read<ModlogBloc>().add(ModlogFeedClearMessageEvent()); // Clear the message so that it does not spam
            }
          },
          builder: (context, state) {
            final theme = Theme.of(context);

            return RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                context.read<ModlogBloc>().add(ModlogFeedFetchedEvent(
                      modlogActionType: state.modlogActionType,
                      communityId: state.communityId,
                      userId: state.userId,
                      moderatorId: state.moderatorId,
                      commentId: state.commentId,
                      reset: true,
                    ));
              },
              edgeOffset: 95.0, // This offset is placed to allow the correct positioning of the refresh indicator
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                      ModlogFeedPageAppBar(
                        showAppBarTitle: state.status != ModlogStatus.initial ? true : showAppBarTitle,
                        subtitle: subtitle,
                      ),
                      // Display loading indicator until the feed is fetched
                      if (state.status == ModlogStatus.initial)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        ),

                      // Widget representing the list of modlog events on the feed
                      SliverList.builder(
                        itemBuilder: (context, index) {
                          TextStyle? metaTextStyle = theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75));
                          ModlogEventItem event = state.modlogEventItems[index];

                          return Column(
                            children: [
                              Divider(
                                height: 1.0,
                                thickness: 4.0,
                                color: ElevationOverlay.applySurfaceTint(
                                  theme.colorScheme.surface,
                                  theme.colorScheme.surfaceTint,
                                  10,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: event.getModlogEventColor().withValues(alpha: 0.2),
                                              borderRadius: const BorderRadius.all(Radius.elliptical(5, 5)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 4.0),
                                                    child: Icon(
                                                      event.getModlogEventIcon(),
                                                      size: 16.0 * thunderState.metadataFontSizeScale.textScaleFactor,
                                                      color: theme.colorScheme.onSurface,
                                                    ),
                                                  ),
                                                  ScalableText(
                                                    event.getModlogEventTypeName(),
                                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                                    fontScale: thunderState.titleFontSizeScale,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Wrap(
                                            spacing: 8.0,
                                            children: [
                                              ScalableText(
                                                getModeratorName(event),
                                                fontScale: thunderState.metadataFontSizeScale,
                                                style: metaTextStyle,
                                              ),
                                              const Text('·'),
                                              DateTimePostCardMetaData(dateTime: event.dateTime),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    ModlogItemContextCard(type: event.type, post: event.post, comment: event.comment, community: event.community, user: event.user),
                                    if (event.reason != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Divider(thickness: 1.0, color: theme.dividerColor.withValues(alpha: 0.3)),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 6.0),
                                              child: ScalableText(
                                                l10n.detailedReason('${event.reason}'),
                                                maxLines: 4,
                                                overflow: TextOverflow.ellipsis,
                                                fontScale: thunderState.contentFontSizeScale,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.90),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        itemCount: state.modlogEventItems.length,
                      ),

                      // Widget representing the bottom of the feed (reached end or loading more events indicators)
                      SliverToBoxAdapter(
                        child: state.hasReachedEnd
                            ? const FeedReachedEnd()
                            : Container(
                                height: state.status == ModlogStatus.initial ? MediaQuery.of(context).size.height * 0.5 : null, // Might have to adjust this to be more robust
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: const CircularProgressIndicator(),
                              ),
                      ),
                    ],
                  ),
                  if (thunderState.hideTopBarOnScroll)
                    Positioned(
                      child: Container(
                        height: MediaQuery.of(context).padding.top,
                        color: theme.colorScheme.surface,
                      ),
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
