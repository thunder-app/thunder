import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/feed/feed.dart';
import 'package:thunder/modlog/modlog.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/modlog/repository/modlog_repository.dart';
import 'package:thunder/utils/constants.dart';

/// Creates a [ModlogPage] which holds a list of modlog events.
class ModlogFeedPage extends StatefulWidget {
  const ModlogFeedPage({
    super.key,
    this.modlogActionType,
    this.communityId,
    this.userId,
    this.moderatorId,
    this.commentId,
    required this.subtitle,
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

  /// An optional string to display as the subtitle on the app bar.
  /// If not specified, this will be the instance or community name.
  final String subtitle;

  @override
  State<ModlogFeedPage> createState() => _ModlogFeedPageState();
}

class _ModlogFeedPageState extends State<ModlogFeedPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ModlogCubit>(
      create: (_) => ModlogCubit(
        repository: ModlogRepositoryImpl(),
      )..fetchModlogFeed(
          modlogActionType: widget.modlogActionType,
          communityId: widget.communityId,
          userId: widget.userId,
          moderatorId: widget.moderatorId,
          commentId: widget.commentId,
          reset: true,
        ),
      child: ModlogFeedView(subtitle: widget.subtitle),
    );
  }
}

class ModlogFeedView extends StatefulWidget {
  /// Subtitle to display on app bar
  final String subtitle;

  const ModlogFeedView({super.key, required this.subtitle});

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
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent * 0.7 && context.read<ModlogCubit>().state.status != ModlogStatus.fetching) {
        context.read<ModlogCubit>().fetchModlogFeed();
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
    final hideTopBarOnScroll = context.select<ThunderBloc, bool>((bloc) => bloc.state.hideTopBarOnScroll);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocConsumer<ModlogCubit, ModlogState>(
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
                if (!isScrollable) context.read<ModlogCubit>().fetchModlogFeed();
              });
            }

            if ((state.status == ModlogStatus.failure) && state.message != null) {
              showSnackbar(state.message!);
              context.read<ModlogCubit>().clearMessage(); // Clear the message so that it does not spam
            }
          },
          builder: (context, state) {
            final theme = Theme.of(context);

            return RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                context.read<ModlogCubit>().fetchModlogFeed(
                      modlogActionType: state.modlogActionType,
                      communityId: state.communityId,
                      userId: state.userId,
                      moderatorId: state.moderatorId,
                      commentId: state.commentId,
                      reset: true,
                    );
              },
              edgeOffset: MediaQuery.of(context).padding.top + APP_BAR_HEIGHT, // This offset is placed to allow the correct positioning of the refresh indicator
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                      ModlogFeedPageAppBar(subtitle: Text(widget.subtitle)),
                      // Display loading indicator until the feed is fetched
                      if (state.status == ModlogStatus.initial)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        ),

                      // Widget representing the list of modlog events on the feed
                      SliverList.builder(
                        itemBuilder: (context, index) => ModlogItemCard(event: state.modlogEventItems[index]),
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
                  if (hideTopBarOnScroll)
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
