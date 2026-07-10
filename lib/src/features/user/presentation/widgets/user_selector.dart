import 'package:flutter/material.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/user/presentation/widgets/account_picker_sheet.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

/// A widget that displays the currently selected user account with the ability to switch between accounts.
///
/// This widget provides a method for switching between different user accounts and ensures that the
/// target community, post, or comment is federated to the new account's instance before allowing
/// the switch. If the content cannot be resolved on the new instance, the switch is blocked.
class UserSelector extends StatefulWidget {
  /// The currently selected account. This is the account that will be displayed in the selector.
  final Account account;

  /// Callback invoked when the user successfully switches to a different account.
  ///
  /// This callback is triggered after all federation checks have passed and the
  /// new account has been confirmed to have access to the community, post, or comment.
  ///
  /// The [account] parameter contains the newly selected account.
  final void Function(Account account)? onUserChanged;

  // ========== Community-related parameters ==========
  // Used when the selector is being used in the context of a community (e.g., creating a post)

  /// The ActivityPub ID (actor ID) of the community to resolve when switching accounts.
  ///
  /// When provided, the widget will attempt to resolve this community on the new
  /// account's instance before allowing the account switch. If the community cannot
  /// be found on the new instance, the switch will be blocked.
  final String? communityActorId;

  /// Callback invoked when the community is successfully resolved on the new account's instance.
  ///
  /// This callback receives the resolved [ThunderCommunity] that corresponds to
  /// the [communityActorId] on the new instance. If the community cannot be resolved,
  /// this callback will receive `null` and the account switch will be blocked.
  ///
  /// Required when [communityActorId] is provided.
  final void Function(ThunderCommunity? community)? onCommunityChanged;

  // ========== Post-related parameters ==========
  // Used when the selector is being used in the context of a post (e.g., creating a comment to a post)

  /// The ActivityPub ID (actor ID) of the post to resolve when switching accounts.
  ///
  /// When provided, the widget will attempt to resolve this post on the new
  /// account's instance before allowing the account switch. Unlike communities,
  /// posts must be successfully resolved or the switch will be blocked.
  ///
  /// Used in conjunction with [onPostChanged].
  final String? postActorId;

  /// Callback invoked when the post is successfully resolved on the new account's instance.
  ///
  /// This callback receives the resolved [ThunderPost] that corresponds to
  /// the [postActorId] on the new instance. This callback will only be invoked
  /// if the post is successfully resolved - failed resolution blocks the account switch.
  ///
  /// Required when [postActorId] is provided.
  final void Function(ThunderPost post)? onPostChanged;

  // ========== Parent comment-related parameters ==========
  // Used when replying to a specific comment

  /// The ActivityPub ID (actor ID) of the parent comment to resolve when switching accounts.
  ///
  /// When provided, the widget will attempt to resolve this comment on the new
  /// account's instance before allowing the account switch. The comment must be
  /// successfully resolved or the switch will be blocked.
  ///
  /// Used in conjunction with [onParentCommentChanged].
  final String? parentCommentActorId;

  /// Callback invoked when the parent comment is successfully resolved on the new account's instance.
  ///
  /// This callback receives the resolved [ThunderComment] that corresponds to
  /// the [parentCommentActorId] on the new instance. This callback will only be invoked
  /// if the comment is successfully resolved - failed resolution blocks the account switch.
  ///
  /// Required when [parentCommentActorId] is provided.
  final void Function(ThunderComment parentComment)? onParentCommentChanged;

  /// Whether account switching is enabled.
  ///
  /// When `false`, the selector displays the current account but disables the ability
  /// to switch to a different account. This is useful during operations like editing
  /// where changing accounts would be inappropriate.
  ///
  /// Defaults to `true`.
  final bool enableAccountSwitching;

  /// Optional resolver used to re-resolve route content for the selected account.
  final FeatureAccountContentResolver? contentResolver;

  const UserSelector({
    super.key,
    required this.account,
    this.onUserChanged,
    this.communityActorId,
    this.onCommunityChanged,
    this.postActorId,
    this.onPostChanged,
    this.parentCommentActorId,
    this.onParentCommentChanged,
    this.enableAccountSwitching = true,
    this.contentResolver,
  });

  @override
  State<UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector> {
  /// The current user details for the selected account
  ThunderUser? _user;

  /// Whether the widget is currently loading user data
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(widget.account));
  }

  @override
  void didUpdateWidget(UserSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account.id != widget.account.id) {
      _load(widget.account);
    }
  }

  /// Loads user data for the specified account
  Future<void> _load(Account? account) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final targetAccount = account ?? widget.account;
      final username = targetAccount.username;

      if (username == null) {
        setState(() {
          _user = null;
          _isLoading = false;
        });
        return;
      }

      final response = await createUserRepository(targetAccount).getUser(username: username);
      final user = response?.user;

      if (!mounted) return;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _user = null;
        _isLoading = false;
      });

      debugPrint('Failed to load user data: $e');
    }
  }

  /// Initiates the account switching process
  Future<void> _switchProfile() async {
    if (!widget.enableAccountSwitching) return;

    final newAccount = await showAccountPickerSheet(
      context,
      currentAccount: widget.account,
    );

    if (newAccount == null || !mounted || widget.account.id == newAccount.id) {
      return;
    }

    final resolvedItems = await _performAccountSwitch(newAccount);
    if (resolvedItems != null) {
      await _load(newAccount);
      _invokeCallbacks(newAccount, resolvedItems);
    }
  }

  /// Performs federation checks and resolves content on the new account's instance
  Future<FeatureAccountResolvedContent?> _performAccountSwitch(Account newAccount) async {
    final l10n = GlobalContext.l10n;

    try {
      final resolvedContent = await (widget.contentResolver ?? FeatureAccountContentResolver()).resolve(
        account: newAccount,
        request: FeatureAccountResolutionRequest(
          communityActorId: widget.communityActorId,
          postActorId: widget.postActorId,
          parentCommentActorId: widget.parentCommentActorId,
        ),
      );

      if (widget.communityActorId?.isNotEmpty == true && resolvedContent.community == null) {
        showThunderSnackbar(l10n.unableToFindCommunityOnInstance);
        return null;
      }

      if (widget.postActorId?.isNotEmpty == true && resolvedContent.post == null) {
        showThunderSnackbar(l10n.accountSwitchPostNotFound(newAccount.instance));
        return null;
      }

      if (widget.parentCommentActorId?.isNotEmpty == true && resolvedContent.parentComment == null) {
        showThunderSnackbar(l10n.accountSwitchParentCommentNotFound(newAccount.instance));
        return null;
      }

      return resolvedContent;
    } catch (e) {
      showThunderSnackbar(e.toString());
      return null;
    }
  }

  /// Invokes the appropriate callbacks after a successful account switch
  void _invokeCallbacks(Account newAccount, FeatureAccountResolvedContent resolvedItems) {
    widget.onUserChanged?.call(newAccount);

    if (widget.communityActorId != null) {
      widget.onCommunityChanged?.call(resolvedItems.community);
    }
    if (widget.postActorId != null && resolvedItems.post != null) {
      widget.onPostChanged?.call(resolvedItems.post!);
    }
    if (widget.parentCommentActorId != null && resolvedItems.parentComment != null) {
      widget.onParentCommentChanged?.call(resolvedItems.parentComment!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-8.0, 0),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(50.0)),
        onTap: widget.enableAccountSwitching ? _switchProfile : null,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UserIndicator(user: _user),
              if (widget.enableAccountSwitching) const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
