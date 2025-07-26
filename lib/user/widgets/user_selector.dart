import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/comment/models/thunder_comment.dart';
import 'package:thunder/community/models/thunder_community.dart';

import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/post/models/thunder_post.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/search/repository/search_repository.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/user/widgets/user_indicator.dart';

/// Creates a widget which displays a preview of the currently selected account, with the ability to change accounts.
///
/// By passing in a [communityActorId], it will attempt to resolve the community to the new user's instance (if changed),
/// and will invoke [onCommunityChanged]. If the community could not be resolved, the callback will pass [null].
class UserSelector extends StatefulWidget {
  final void Function()? onUserChanged;
  final String? profileModalHeading;

  // Pass these when dealing with a community (i.e., creating a post)
  final String? communityActorId;
  final void Function(ThunderCommunity? community)? onCommunityChanged;

  // Pass these when dealing with a post (i.e., creating a comment)
  // Unlike posts, where it's valid to have a null community (i.e., you're forced to pick a different one)
  // It's not valid to have a null parent post/comment. Therefore if we can't resolve the objects,
  // we will block the account switch, and the onChanged methods will never pass a null value.
  final String? postActorId;
  final void Function(ThunderPost post)? onPostChanged;
  final String? parentCommentActorId;
  final void Function(ThunderComment parentComment)? onParentCommentChanged;

  /// Whether the user is allowed to change the active account
  /// (e.g., it should not be allowed during edit)
  final bool enableAccountSwitching;

  const UserSelector({
    super.key,
    this.onUserChanged,
    this.profileModalHeading,
    this.communityActorId,
    this.onCommunityChanged,
    this.postActorId,
    this.onPostChanged,
    this.parentCommentActorId,
    this.onParentCommentChanged,
    this.enableAccountSwitching = true,
  });

  @override
  State<UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector> {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-8, 0),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        onTap: !widget.enableAccountSwitching
            ? null
            : () async => await temporarilySwitchAccount(
                  context,
                  setState: setState,
                  profileModalHeading: widget.profileModalHeading,
                  onUserChanged: widget.onUserChanged,
                  communityActorId: widget.communityActorId,
                  onCommunityChanged: widget.onCommunityChanged,
                  postActorId: widget.postActorId,
                  onPostChanged: widget.onPostChanged,
                  parentCommentActorId: widget.parentCommentActorId,
                  onParentCommentChanged: widget.onParentCommentChanged,
                ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const UserIndicator(),
              if (widget.enableAccountSwitching) const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> temporarilySwitchAccount(
  BuildContext context, {
  void Function(VoidCallback fn)? setState,
  String? profileModalHeading,
  void Function()? onUserChanged,
  String? communityActorId,
  void Function(ThunderCommunity? community)? onCommunityChanged,
  String? postActorId,
  void Function(ThunderPost post)? onPostChanged,
  String? parentCommentActorId,
  void Function(ThunderComment parentComment)? onParentCommentChanged,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  final Account originalUser = context.read<ProfileBloc>().state.account;

  await showProfileModalSheet(
    context,
    quickSelectMode: true,
    customHeading: profileModalHeading,
    reloadOnSwitch: false,
  );

  // Wait slightly longer than the duration that is waited in the account switcher logic.
  await Future.delayed(const Duration(milliseconds: 1500));

  if (context.mounted) {
    Account? newUser = context.read<ProfileBloc>().state.account;

    if (originalUser.id != newUser.id) {
      // The user changed. Reload the widget.
      setState?.call(() {});
      onUserChanged?.call();

      // If there is a selected community, see if we can resolve it to the new user's instance.
      if (communityActorId?.isNotEmpty == true && onCommunityChanged != null) {
        try {
          final response = await SearchRepositoryImpl(account: newUser).resolve(query: communityActorId!);

          if (response.community != null) {
            final community = ThunderCommunity.fromLemmyCommunityView(response.community!.toJson());
            onCommunityChanged(community);
          }
        } catch (e) {
          // We'll just return null if we can't find it.
        }
      }

      // If there is a selected post, see if we can resolve it to the new user's instance.
      if (postActorId?.isNotEmpty == true && onPostChanged != null) {
        try {
          final response = await SearchRepositoryImpl(account: newUser).resolve(query: postActorId!);

          if (response.post != null) {
            onPostChanged((await parsePosts([ThunderPost.fromLemmyPostView(response.post!.toJson())])).first);
          }

          showSnackbar(l10n.accountSwitchPostNotFound(newUser.instance));
          if (context.mounted) context.read<ProfileBloc>().add(SwitchProfile(accountId: originalUser.id, reload: false));
        } catch (e) {
          // We will handle this below.
        }
      }

      // If there is a selected parent comment, see if we can resolve it to the new user's instance.
      if (parentCommentActorId?.isNotEmpty == true && onParentCommentChanged != null) {
        try {
          final response = await SearchRepositoryImpl(account: newUser).resolve(query: parentCommentActorId!);

          if (response.comment != null) {
            final comment = ThunderComment.fromLemmyCommentView(response.comment!.toJson());
            onParentCommentChanged(comment);
          }

          showSnackbar(l10n.accountSwitchParentCommentNotFound(newUser.instance));
          if (context.mounted) context.read<ProfileBloc>().add(SwitchProfile(accountId: originalUser.id, reload: false));
        } catch (e) {
          // We will handle this below.
        }
      }
    }
  }
}
