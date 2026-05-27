import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/shared/sort_picker.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show ThunderActionChip, showSnackbar;

/// A widget that displays relevant actions for a community in a scrollable chip list.
class CommunityHeaderActions extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  /// Instance of the community
  final ThunderSite? instance;

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
    return _CommunityActionsContent(community: community, instance: instance, moderators: moderators);
  }
}

/// The main content of the community actions.
class _CommunityActionsContent extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  /// Instance of the community
  final ThunderSite? instance;

  /// List of moderators for the community
  final List<ThunderUser> moderators;

  const _CommunityActionsContent({
    required this.community,
    this.instance,
    required this.moderators,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0).copyWith(bottom: 8.0),
        child: _ActionChipsList(community: community, instance: instance, moderators: moderators),
      ),
    );
  }
}

/// Displays the list of action chips for community interactions.
class _ActionChipsList extends StatelessWidget {
  /// Community to display actions for
  final ThunderCommunity community;

  /// Instance of the community
  final ThunderSite? instance;

  /// List of moderators for the community
  final List<ThunderUser> moderators;

  const _ActionChipsList({
    required this.community,
    this.instance,
    required this.moderators,
  });

  @override
  Widget build(BuildContext context) {
    final account = context.read<ProfileBloc>().state.account;

    return Row(
      spacing: 8.0,
      children: [
        _SortActionChip(),
        ..._getAuthenticatedActions(context),
        _SearchActionChip(),
        if (account.platform == ThreadiversePlatform.lemmy) _ModlogActionChip(community: community),
        _ShareActionChip(community: community),
      ],
    );
  }

  /// Returns the list of actions available to authenticated users.
  List<Widget> _getAuthenticatedActions(BuildContext context) {
    final isLoggedIn = context.read<ProfileBloc>().state.isLoggedIn;
    if (!isLoggedIn) return [_AnonymousSubscriptionChip(community: community)];

    final blocked = context.select<ProfileBloc, bool>((bloc) => bloc.state.siteResponse?.myUser?.communityBlocks.any((c) => c.id == community.id) ?? false);
    if (blocked) return [_BlockActionChip(community: community)];

    final subscriptionStatus = community.context.subscribed ?? SubscriptionStatus.notSubscribed;

    return [
      _SubscriptionActionChip(community: community),
      if (subscriptionStatus != SubscriptionStatus.notSubscribed) _FavoritesActionChip(community: community),
      _CreatePostActionChip(community: community),
      if (subscriptionStatus == SubscriptionStatus.notSubscribed) _BlockActionChip(community: community),
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

    final feedBloc = context.read<FeedBloc>();
    final state = feedBloc.state;

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
          builder: (builderContext) => SortPicker<PostSortType>(
            account: feedBloc.account,
            title: l10n.sortOptions,
            onSelect: (selected) async {
              try {
                context.read<FeedBloc>().add(FeedChangePostSortTypeEvent(selected.payload));
              } catch (e) {
                debugPrint('Failed to update sort type: $e');
              }
            },
            previouslySelected: state.postSortType,
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
    final subscriptionStatus = community.context.subscribed ?? SubscriptionStatus.notSubscribed;

    return ThunderActionChip(
      icon: _getSubscriptionIcon(subscriptionStatus),
      label: _getSubscriptionLabel(subscriptionStatus),
      onPressed: () async {
        HapticFeedback.mediumImpact();
        final updatedCommunity = await handleSubscription(context, community);

        if (community.context.subscribed != updatedCommunity?.context.subscribed) {
          context.read<ProfileBloc>().add(FetchProfileSubscriptions());
        }
        if (updatedCommunity != null) {
          context.read<FeedBloc>().add(FeedCommunityUpdatedEvent(community: updatedCommunity));
        }
      },
    );
  }

  IconData _getSubscriptionIcon(SubscriptionStatus subscribed) {
    return switch (subscribed) {
      SubscriptionStatus.notSubscribed => Icons.add_circle_outline_rounded,
      SubscriptionStatus.pending => Icons.pending_outlined,
      SubscriptionStatus.subscribed => Icons.remove_circle_outline_rounded,
    };
  }

  String _getSubscriptionLabel(SubscriptionStatus subscribed) {
    final l10n = GlobalContext.l10n;

    return switch (subscribed) {
      SubscriptionStatus.notSubscribed => l10n.subscribe,
      SubscriptionStatus.pending => l10n.pending,
      SubscriptionStatus.subscribed => l10n.unsubscribe,
    };
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
    final subscriptions = context.watch<AnonymousSubscriptionsCubit>().state.urls;
    final isSubscribed = subscriptions.contains(community.actorId);

    return ThunderActionChip(
      icon: isSubscribed ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded,
      label: isSubscribed ? l10n.unsubscribe : l10n.subscribe,
      onPressed: () {
        HapticFeedback.mediumImpact();

        if (isSubscribed) {
          context.read<AnonymousSubscriptionsCubit>().removeSubscriptions({community.actorId});
          showSnackbar(l10n.unsubscribed);
        } else {
          context.read<AnonymousSubscriptionsCubit>().addSubscriptions({community});
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
    if (community.context.subscribed != SubscriptionStatus.subscribed) {
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
          onPressed: () async {
            HapticFeedback.heavyImpact();

            final repository = CommunityRepositoryImpl(account: state.account);
            final updatedCommunity = await repository.block(community.id, !blocked);

            context.read<ProfileBloc>().add(FetchProfileSettings());
            context.read<FeedBloc>().add(FeedCommunityUpdatedEvent(community: updatedCommunity));
          },
        );
      },
    );
  }

  bool _isCommunityBlocked(ProfileState state) {
    if (state.siteResponse?.myUser?.communityBlocks == null) {
      return false;
    }

    final blockedCommunities = state.siteResponse!.myUser!.communityBlocks;
    return blockedCommunities.any((c) => c.id == community.id);
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
          fetchInstanceNameFromUrl(community.actorId),
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
