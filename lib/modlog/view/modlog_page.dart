import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/full_name_separator.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/modlog/modlog.dart';
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
  });

  /// The filtering to be applied to the feed.
  final ModlogActionType? modlogActionType;

  /// The id of the community to display modlog events for.
  final int? communityId;

  /// The id of the user to display modlog events for.
  final int? userId;

  /// The id of the moderator to display modlog events for.
  final int? moderatorId;

  @override
  State<ModlogFeedPage> createState() => _ModlogFeedPageState();
}

class _ModlogFeedPageState extends State<ModlogFeedPage> with AutomaticKeepAliveClientMixin<ModlogFeedPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider<ModlogBloc>(
      create: (_) => ModlogBloc(lemmyClient: LemmyClient.instance)
        ..add(ModlogFeedFetchedEvent(
          communityId: widget.communityId,
          userId: widget.userId,
          reset: true,
        )),
      child: const ModlogFeedView(),
    );
  }
}

class ModlogFeedView extends StatefulWidget {
  const ModlogFeedView({super.key});

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

  @override
  Widget build(BuildContext context) {
    ThunderBloc thunderBloc = context.watch<ThunderBloc>();

    bool hideTopBarOnScroll = thunderBloc.state.hideTopBarOnScroll;

    return Scaffold(
      body: SafeArea(
        top: hideTopBarOnScroll, // Don't apply to top of screen to allow for the status bar colour to extend
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
              bool isScrollable = _scrollController.position.maxScrollExtent > _scrollController.position.viewportDimension;
              if (!isScrollable) context.read<ModlogBloc>().add(const ModlogFeedFetchedEvent());
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
                context.read<ModlogBloc>().add(ModlogFeedFetchedEvent(communityId: state.communityId, userId: state.userId, moderatorId: state.moderatorId, reset: true));
              },
              edgeOffset: 95.0, // This offset is placed to allow the correct positioning of the refresh indicator
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                      ModlogFeedPageAppBar(showAppBarTitle: state.status != ModlogStatus.initial ? true : showAppBarTitle),
                      // Display loading indicator until the feed is fetched
                      if (state.status == ModlogStatus.initial)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        ),

                      // Widget representing the list of posts on the feed
                      SliverList.builder(
                        itemBuilder: (context, index) {
                          TextStyle? metaTextStyle = theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75));
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
                                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: event.getModlogEventColor().withOpacity(0.2),
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
                                                size: 16.0 * thunderBloc.state.metadataFontSizeScale.textScaleFactor,
                                                color: theme.colorScheme.onBackground,
                                              ),
                                            ),
                                            ScalableText(
                                              event.getModlogEventTypeName(),
                                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                              fontScale: thunderBloc.state.titleFontSizeScale,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    ScalableText(
                                      event.getModlogEventTypeDescription(),
                                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                      fontScale: thunderBloc.state.titleFontSizeScale,
                                    ),
                                    const SizedBox(height: 6.0),
                                    if (event.reason != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6.0, top: 4.0),
                                        child: ScalableText(
                                          event.reason!,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          fontScale: thunderBloc.state.contentFontSizeScale,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.90),
                                          ),
                                        ),
                                      ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ScalableText(
                                          event.moderator != null ? event.moderator?.name ?? 'Moderator' : event.admin?.name ?? 'Admin',
                                          fontScale: thunderBloc.state.metadataFontSizeScale,
                                          style: metaTextStyle,
                                        ),
                                        DateTimePostCardMetaData(dateTime: event.dateTime),
                                      ],
                                    ),
                                    const SizedBox(height: 12.0),
                                    Wrap(
                                      runSpacing: 4.0,
                                      children: [
                                        if (event.post != null) ModlogItemContextCard(title: event.post!.name, post: event.post),
                                        if (event.comment != null) ModlogItemContextCard(title: event.comment!.content, comment: event.comment),
                                        if (event.community != null)
                                          ModlogItemContextCard(
                                            title: generateCommunityFullName(context, event.community!.name, fetchInstanceNameFromUrl(event.community!.actorId)),
                                            community: event.community,
                                          ),
                                        if (event.user != null)
                                          ModlogItemContextCard(
                                            title: generateUserFullName(context, event.user!.name, fetchInstanceNameFromUrl(event.user!.actorId)),
                                            user: event.user,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        itemCount: state.modlogEventItems.length,
                      ),

                      // Widget representing the bottom of the feed (reached end or loading more posts indicators)
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
