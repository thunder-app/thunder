import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/community/bloc/anonymous_subscriptions_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/feed/utils/community.dart';
import 'package:thunder/feed/utils/community_share.dart';
import 'package:thunder/shared/chips/thunder_action_chip.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigation.dart';

/// A widget that displays relevant actions for a community in a scrollable chip list.
class CommunityHeaderActions extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  /// Instance of the community
  final ThunderInstance? instance;

  /// List of moderators for the community
  final List<ThunderUser> moderators;

  const CommunityHeaderActions({
    super.key,
    required this.community,
    this.instance,
    required this.moderators,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommunityBloc>(
      create: (context) => CommunityBloc(lemmyClient: LemmyClient.instance),
      child: _CommunityActionsContent(community: community, instance: instance, moderators: moderators),
    );
  }
}

/// The main content of the community actions.
class _CommunityActionsContent extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  /// Instance of the community
  final ThunderInstance? instance;

  /// List of moderators for the community
  final List<ThunderUser> moderators;

  const _CommunityActionsContent({
    required this.community,
    this.instance,
    required this.moderators,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {},
      listenWhen: (previous, current) => _handleCommunityStateChange(context, previous, current),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0).copyWith(bottom: 8.0),
          child: _ActionChipsList(community: community, instance: instance, moderators: moderators),
        ),
      ),
    );
  }

  /// Handles community state changes and updates the feed accordingly.
  bool _handleCommunityStateChange(BuildContext context, CommunityState previous, CommunityState current) {
    if (previous.status == current.status) return false;

    if (previous.community?.subscribed != current.community?.subscribed) {
      context.read<ProfileBloc>().add(FetchProfileSubscriptions());
    }

    if (previous.community?.blocked != current.community?.blocked) {
      context.read<ProfileBloc>().add(FetchProfileSettings());
    }

    if (current.community != null) context.read<FeedBloc>().add(FeedCommunityUpdatedEvent(community: current.community!));
    return true;
  }
}

/// Displays the list of action chips for community interactions.
class _ActionChipsList extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  /// Instance of the community
  final ThunderInstance? instance;

  /// List of moderators for the community
  final List<ThunderUser> moderators;

  const _ActionChipsList({
    required this.community,
    this.instance,
    required this.moderators,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8.0,
      children: [
        _SortActionChip(),
        ..._getAuthenticatedActions(context),
        _SearchActionChip(),
        _ModlogActionChip(community: community),
        _ShareActionChip(community: community),
      ],
    );
  }

  /// Returns the list of actions available to authenticated users.
  List<Widget> _getAuthenticatedActions(BuildContext context) {
    final isLoggedIn = context.read<ProfileBloc>().state.isLoggedIn;
    if (!isLoggedIn) return [_AnonymousSubscriptionChip(community: community)];

    final blocked = context.select<ProfileBloc, bool>((bloc) => bloc.state.getSiteResponse?.myUser?.communityBlocks.any((block) => block.community.id == community.id) ?? false);
    if (blocked) return [_BlockActionChip(community: community)];

    return [
      _SubscriptionActionChip(community: community),
      if (community.subscribed != SubscribedType.notSubscribed) _FavoritesActionChip(community: community),
      _CreatePostActionChip(community: community),
      if (community.subscribed == SubscribedType.notSubscribed) _BlockActionChip(community: community),
    ];
  }
}

/// Action chip for community sorting options.
class _SortActionChip extends StatelessWidget {
  const _SortActionChip();

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final feedBlocProvider = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>();

    if (feedBlocProvider == null) {
      debugPrint('FeedBloc not available for sort picker');
      return const SizedBox.shrink();
    }

    final state = context.read<FeedBloc>().state;

    return ThunderActionChip(
      icon: getSortIcon(state) ?? Icons.sort_rounded,
      label: getSortName(state),
      trailingIcon: Icons.arrow_drop_down_rounded,
      onPressed: () {
        HapticFeedback.mediumImpact();

        showModalBottomSheet<void>(
          showDragHandle: true,
          context: context,
          isScrollControlled: true,
          builder: (builderContext) => SortPicker(
            title: l10n.sortOptions,
            onSelect: (selected) async {
              try {
                context.read<FeedBloc>().add(FeedChangeSortTypeEvent(selected.payload));
              } catch (e) {
                debugPrint('Failed to update sort type: $e');
              }
            },
            previouslySelected: state.sortType,
            minimumVersion: LemmyClient.instance.version,
          ),
        );
      },
    );
  }
}

/// Action chip for subscription management for authenticated users.
class _SubscriptionActionChip extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  const _SubscriptionActionChip({required this.community});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommunityBloc, CommunityState>(
      listener: _handleSubscriptionStateChange,
      builder: (context, state) => ThunderActionChip(
        icon: _getSubscriptionIcon(community.subscribed),
        label: _getSubscriptionLabel(community.subscribed),
        onPressed: () {
          HapticFeedback.mediumImpact();
          handleSubscription(context, community);
        },
      ),
    );
  }

  IconData _getSubscriptionIcon(SubscribedType? subscribed) {
    return switch (subscribed) {
      SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
      SubscribedType.pending => Icons.pending_outlined,
      SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
      _ => Icons.add_circle_outline_rounded,
    };
  }

  String _getSubscriptionLabel(SubscribedType? subscribed) {
    final l10n = GlobalContext.l10n;

    return switch (subscribed) {
      SubscribedType.notSubscribed => l10n.subscribe,
      SubscribedType.pending => l10n.pending,
      SubscribedType.subscribed => l10n.unsubscribe,
      _ => '',
    };
  }

  void _handleSubscriptionStateChange(BuildContext context, CommunityState state) {
    if (state.status == CommunityStatus.success && state.community != null) {
      try {
        context.read<FeedBloc>().add(FeedCommunityUpdatedEvent(community: state.community!));
      } catch (e) {
        debugPrint('Failed to update feed after subscription change: $e');
      }
    }
  }
}

/// Action chip for anonymous users to manage subscriptions.
class _AnonymousSubscriptionChip extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  const _AnonymousSubscriptionChip({required this.community});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final subscriptions = context.watch<AnonymousSubscriptionsBloc>().state.urls;
    final isSubscribed = subscriptions.contains(community.url);

    return ThunderActionChip(
      icon: isSubscribed ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded,
      label: isSubscribed ? l10n.unsubscribe : l10n.subscribe,
      onPressed: () {
        HapticFeedback.mediumImpact();

        if (isSubscribed) {
          context.read<AnonymousSubscriptionsBloc>().add(DeleteSubscriptionsEvent(urls: {community.url}));
          showSnackbar(l10n.unsubscribed);
        } else {
          context.read<AnonymousSubscriptionsBloc>().add(AddSubscriptionsEvent(communities: {community}));
          showSnackbar(l10n.subscribed);
        }
      },
    );
  }
}

/// Action chip for managing favorite communities.
class _FavoritesActionChip extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  const _FavoritesActionChip({required this.community});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final favorites = context.select<ProfileBloc, List<ThunderCommunity>>((bloc) => bloc.state.favorites);
    final favorited = favorites.any((c) => c.id == community.id);

    // Only show for subscribed communities
    if (community.subscribed != SubscribedType.subscribed) {
      return const SizedBox.shrink();
    }

    return ThunderActionChip(
      icon: favorited ? Icons.star_rounded : Icons.star_border_rounded,
      label: favorited ? l10n.unfavorite : l10n.favorite,
      onPressed: () => toggleFavoriteCommunity(context, community, favorited),
    );
  }
}

/// Action chip for creating posts in the community.
class _CreatePostActionChip extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  const _CreatePostActionChip({required this.community});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return ThunderActionChip(
      icon: Icons.library_books_rounded,
      label: l10n.newPost,
      onPressed: () {
        HapticFeedback.mediumImpact();
        navigateToCreatePostPage(context, communityId: community.id, community: community);
      },
    );
  }
}

/// Action chip for blocking/unblocking communities.
class _BlockActionChip extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  const _BlockActionChip({required this.community});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final blocked = _isCommunityBlocked(state);

        return ThunderActionChip(
          icon: blocked ? Icons.undo_rounded : Icons.block_rounded,
          label: blocked ? l10n.unblock : l10n.block,
          onPressed: () {
            HapticFeedback.heavyImpact();
            context.read<CommunityBloc>().add(CommunityActionEvent(communityAction: CommunityAction.block, communityId: community.id, value: !blocked));
          },
        );
      },
    );
  }

  bool _isCommunityBlocked(ProfileState state) {
    if (state.getSiteResponse?.myUser?.communityBlocks == null) {
      return false;
    }

    final blockedCommunities = state.getSiteResponse!.myUser!.communityBlocks.map((block) => ThunderCommunity(block.community)).toList();
    return blockedCommunities.any((blockedCommunity) => blockedCommunity.id == community.id);
  }
}

/// Action chip for searching within the community.
class _SearchActionChip extends StatelessWidget {
  const _SearchActionChip();

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return ThunderActionChip(
      icon: Icons.search_rounded,
      label: l10n.search,
      onPressed: () => navigateToSearchPage(context),
    );
  }
}

/// Action chip for accessing the community modlog.
class _ModlogActionChip extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  const _ModlogActionChip({required this.community});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return ThunderActionChip(
      icon: Icons.shield_rounded,
      label: l10n.modlog,
      onPressed: () => navigateToModlogPage(
        context,
        communityId: community.id,
        subtitle: generateCommunityFullName(
          context,
          community.name,
          community.title,
          fetchInstanceNameFromUrl(community.url),
        ),
      ),
    );
  }
}

/// Action chip for sharing the community.
class _ShareActionChip extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  const _ShareActionChip({required this.community});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return ThunderActionChip(
      icon: Icons.share_rounded,
      label: l10n.share,
      onPressed: () => showCommunityShareSheet(context, community),
    );
  }
}
