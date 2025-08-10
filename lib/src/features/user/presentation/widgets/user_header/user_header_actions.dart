import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/widgets/chips/thunder_action_chip.dart';
import 'package:thunder/src/shared/sort_picker.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/src/app/utils/global_context.dart';

/// A widget that displays relevant actions for a user in a scrollable chip list.
class UserHeaderActions extends StatelessWidget {
  /// User to display actions for
  final ThunderUser user;

  /// Communities the user moderates
  final List<ThunderCommunity> moderates;

  /// The current feed type (posts/comments)
  final FeedTypeSubview? feedType;

  /// Callback to be called when the feed type is changed (posts/comments)
  final Function(FeedTypeSubview)? onChangeFeedType;

  const UserHeaderActions({
    super.key,
    required this.user,
    required this.moderates,
    required this.feedType,
    required this.onChangeFeedType,
  });

  @override
  Widget build(BuildContext context) {
    return _UserActionsContent(
      user: user,
      moderates: moderates,
      feedType: feedType,
      onChangeFeedType: onChangeFeedType,
    );
  }
}

/// The main content of the user actions.
class _UserActionsContent extends StatelessWidget {
  /// User to display actions for
  final ThunderUser user;

  /// Communities the user moderates
  final List<ThunderCommunity> moderates;

  /// The current feed type (posts/comments)
  final FeedTypeSubview? feedType;

  /// Callback to be called when the feed type is changed (posts/comments)
  final Function(FeedTypeSubview)? onChangeFeedType;

  const _UserActionsContent({
    required this.user,
    required this.moderates,
    required this.feedType,
    required this.onChangeFeedType,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0).copyWith(bottom: 8.0),
        child: _ActionChipsList(
          user: user,
          moderates: moderates,
          feedType: feedType,
          onChangeFeedType: onChangeFeedType,
        ),
      ),
    );
  }
}

/// Displays the list of action chips for user interactions.
class _ActionChipsList extends StatelessWidget {
  /// User to display actions for
  final ThunderUser user;

  /// Communities the user moderates
  final List<ThunderCommunity> moderates;

  /// The current feed type (posts/comments)
  final FeedTypeSubview? feedType;

  /// Callback to be called when the feed type is changed (posts/comments)
  final Function(FeedTypeSubview)? onChangeFeedType;

  const _ActionChipsList({
    required this.user,
    required this.moderates,
    required this.feedType,
    required this.onChangeFeedType,
  });

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.read<ProfileBloc>().state.isLoggedIn;
    final myUserId = context.read<ProfileBloc>().state.siteResponse?.myUser?.localUserView.person.id;
    final isOwnProfile = user.id == myUserId;

    return Row(
      spacing: 8.0,
      children: [
        if (feedType != null && onChangeFeedType != null) _FeedTypeActionChip(feedType: feedType!, onChangeFeedType: onChangeFeedType!),
        if (isOwnProfile) _SavedActionChip(),
        _SortActionChip(),
        if (!isOwnProfile) _LabelActionChip(user: user),
        if (isLoggedIn && !isOwnProfile && user.isAdmin != true) _BlockActionChip(user: user),
        _ShareActionChip(user: user),
      ],
    );
  }
}

/// Action chip for toggling saved posts/comments.
class _SavedActionChip extends StatefulWidget {
  @override
  State<_SavedActionChip> createState() => _SavedActionChipState();
}

class _SavedActionChipState extends State<_SavedActionChip> {
  /// Whether or not to show saved posts. We store a local variable here so that the icon can be optimistically updated
  bool showSaved = false;

  @override
  void didUpdateWidget(covariant _SavedActionChip oldWidget) {
    super.didUpdateWidget(oldWidget);

    final status = context.read<FeedBloc>().state.status;
    final showSaved = context.read<FeedBloc>().state.showSaved;

    if (this.showSaved != showSaved && status == FeedStatus.success) {
      setState(() => this.showSaved = showSaved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return ThunderActionChip(
      icon: showSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
      label: l10n.saved,
      backgroundColor: showSaved ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25) : null,
      onPressed: () {
        HapticFeedback.mediumImpact();
        setState(() => showSaved = !showSaved);

        final state = context.read<FeedBloc>().state;
        context.read<FeedBloc>().add(
              FeedFetchedEvent(
                feedType: FeedType.account,
                feedListType: state.feedListType,
                postSortType: state.postSortType,
                communityId: state.communityId,
                communityName: state.communityName,
                userId: state.userId,
                username: state.username,
                reset: true,
                showHidden: state.showHidden,
                showSaved: showSaved,
              ),
            );
      },
    );
  }
}

/// Action chip for selecting feed type (posts/comments).
class _FeedTypeActionChip extends StatelessWidget {
  /// The current feed type (posts/comments)
  final FeedTypeSubview feedType;

  /// Callback to be called when the feed type is changed (posts/comments)
  final Function(FeedTypeSubview feedType) onChangeFeedType;

  const _FeedTypeActionChip({
    required this.feedType,
    required this.onChangeFeedType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final icon = feedType == FeedTypeSubview.post ? Icons.article_rounded : Icons.chat_rounded;
    final label = feedType == FeedTypeSubview.post ? l10n.posts : l10n.comments;

    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubicEmphasized,
      child: ThunderActionChip(
        icon: icon,
        trailingIcon: Icons.swap_horiz_rounded,
        trailingIconSize: 17.0,
        label: label,
        onPressed: () => onChangeFeedType(feedType == FeedTypeSubview.post ? FeedTypeSubview.comment : FeedTypeSubview.post),
      ),
    );
  }

  void _showFeedTypePicker(BuildContext context) {
    final l10n = GlobalContext.l10n;

    HapticFeedback.mediumImpact();

    showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      isScrollControlled: true,
      builder: (builderContext) => BottomSheetListPicker(
        title: l10n.selectFeedType,
        previouslySelected: feedType,
        items: [
          ListPickerItem(
            label: FeedTypeSubview.post.name,
            icon: Icons.article_rounded,
            payload: FeedTypeSubview.post,
          ),
          ListPickerItem(
            label: FeedTypeSubview.comment.name,
            icon: Icons.chat_rounded,
            payload: FeedTypeSubview.comment,
          ),
        ],
        onSelect: (selection) async {
          onChangeFeedType(selection.payload);
        },
      ),
    );
  }
}

/// Action chip for user sorting options.
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
      icon: getSortIcon(state),
      trailingIcon: Icons.arrow_drop_down_rounded,
      label: getSortName(state),
      onPressed: () {
        HapticFeedback.mediumImpact();

        showModalBottomSheet<void>(
          showDragHandle: true,
          context: context,
          isScrollControlled: true,
          builder: (builderContext) => SortPicker(
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

/// Action chip for managing user labels.
class _LabelActionChip extends StatelessWidget {
  /// User to display actions for
  final ThunderUser user;

  const _LabelActionChip({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return ThunderActionChip(
      icon: Icons.label_outline_rounded,
      label: l10n.label,
      onPressed: () async => await showUserLabelEditorDialog(
        context,
        UserLabel.usernameFromParts(user.displayNameOrName, user.actorId),
      ),
    );
  }
}

/// Action chip for blocking/unblocking users.
class _BlockActionChip extends StatelessWidget {
  /// User to display actions for
  final ThunderUser user;

  const _BlockActionChip({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final blocked = _isUserBlocked(state);

        return ThunderActionChip(
          icon: blocked ? Icons.undo_rounded : Icons.block_rounded,
          label: blocked ? l10n.unblock : l10n.block,
          onPressed: () async {
            HapticFeedback.heavyImpact();

            final repository = UserRepositoryImpl(account: state.account);
            await repository.block(user.id, !blocked);

            context.read<ProfileBloc>().add(FetchProfileSettings());
          },
        );
      },
    );
  }

  bool _isUserBlocked(ProfileState state) {
    if (state.siteResponse?.myUser?.personBlocks == null) {
      return false;
    }

    final blockedUsers = state.siteResponse!.myUser!.personBlocks;
    return blockedUsers.any((u) => u.id == user.id);
  }
}

/// Action chip for sharing the user.
class _ShareActionChip extends StatelessWidget {
  /// User to display actions for
  final ThunderUser user;

  const _ShareActionChip({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return ThunderActionChip(
      icon: Icons.share_rounded,
      label: l10n.share,
      onPressed: () {
        final feedBlocProvider = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>();

        if (feedBlocProvider == null) {
          debugPrint('FeedBloc not available for user sharing');
          return;
        }

        final state = context.read<FeedBloc>().state;

        if (state.user != null) {
          showUserShareSheet(context, state.user!);
        } else {
          debugPrint('Unable to share user: person view not available');
        }
      },
    );
  }
}
