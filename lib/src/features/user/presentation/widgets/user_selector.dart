import 'package:flutter/material.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/shared/snackbar.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/app/utils/global_context.dart';

/// A widget that displays the currently selected user account with the ability to switch between accounts.
///
/// This widget provides a method for switching between different user accounts and ensures that the
/// target community, post, or comment is federated to the new account's instance before allowing
/// the switch. If the content cannot be resolved on the new instance, the switch is blocked.
///
/// **Usage Examples:**
///
/// For creating a post in a community:
/// ```dart
/// UserSelector(
///   account: currentAccount,
///   onUserChanged: (account) => handleAccountChange(account),
///   communityActorId: community.actorId,
///   onCommunityChanged: (community) => handleCommunityChange(community),
/// )
/// ```
///
/// For creating a comment on a post:
/// ```dart
/// UserSelector(
///   account: currentAccount,
///   onUserChanged: (account) => handleAccountChange(account),
///   postActorId: post.actorId,
///   onPostChanged: (post) => handlePostChange(post),
/// )
/// ```
class UserSelector extends StatefulWidget {
  /// The currently selected account.
  /// This is the account that will be displayed in the selector.
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData(widget.account));
  }

  @override
  void didUpdateWidget(UserSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account.id != widget.account.id) _loadUserData(widget.account);
  }

  /// Loads user data for the specified account
  Future<void> _loadUserData(Account? account) async {
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

      final response = await UserRepositoryImpl(account: targetAccount).getUser(username: username);
      final user = response?['user'] as ThunderUser?;

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

    final newAccount = await showModalBottomSheet<Account>(
      context: context,
      showDragHandle: true,
      builder: (context) => _UserProfileSelector(widget.account),
    );

    if (newAccount == null || !mounted || widget.account.id == newAccount.id) return;

    final resolvedItems = await _performAccountSwitch(newAccount);
    if (resolvedItems != null) {
      await _loadUserData(newAccount);
      _invokeCallbacks(newAccount, resolvedItems);
    }
  }

  /// Performs federation checks and resolves content on the new account's instance
  Future<Map<String, dynamic>?> _performAccountSwitch(Account newAccount) async {
    final l10n = GlobalContext.l10n;

    try {
      ThunderCommunity? community;
      ThunderPost? post;
      ThunderComment? parentComment;

      // Resolve community if needed
      if (widget.communityActorId?.isNotEmpty == true) {
        community = await _resolveCommunity(newAccount, widget.communityActorId!);
        if (community == null) {
          showSnackbar(l10n.unableToFindCommunityOnInstance);
          return null;
        }
      }

      // Resolve post if needed
      if (widget.postActorId?.isNotEmpty == true) {
        post = await _resolvePost(newAccount, widget.postActorId!);
        if (post == null) {
          showSnackbar(l10n.accountSwitchPostNotFound(newAccount.instance));
          return null;
        }
      }

      // Resolve parent comment if needed
      if (widget.parentCommentActorId?.isNotEmpty == true) {
        parentComment = await _resolveParentComment(newAccount, widget.parentCommentActorId!);
        if (parentComment == null) {
          showSnackbar(l10n.accountSwitchParentCommentNotFound(newAccount.instance));
          return null;
        }
      }

      return {
        'community': community,
        'post': post,
        'parentComment': parentComment,
      };
    } catch (e) {
      showSnackbar(e.toString());
      return null;
    }
  }

  /// Resolves a community on the new account's instance
  Future<ThunderCommunity?> _resolveCommunity(Account account, String actorId) async {
    try {
      final response = await SearchRepositoryImpl(account: account).resolve(query: actorId);
      return response.community != null ? ThunderCommunity.fromLemmyCommunityView(response.community!.toJson()) : null;
    } catch (e) {
      debugPrint('Failed to resolve community: $e');
      return null;
    }
  }

  /// Resolves a post on the new account's instance
  Future<ThunderPost?> _resolvePost(Account account, String actorId) async {
    try {
      final response = await SearchRepositoryImpl(account: account).resolve(query: actorId);
      if (response.post == null) return null;

      final thunderPost = ThunderPost.fromLemmyPostView(response.post!.toJson());
      final parsedPosts = await parsePosts([thunderPost]);
      return parsedPosts.isNotEmpty ? parsedPosts.first : null;
    } catch (e) {
      debugPrint('Failed to resolve post: $e');
      return null;
    }
  }

  /// Resolves a parent comment on the new account's instance
  Future<ThunderComment?> _resolveParentComment(Account account, String actorId) async {
    try {
      final response = await SearchRepositoryImpl(account: account).resolve(query: actorId);
      return response.comment != null ? ThunderComment.fromLemmyCommentView(response.comment!.toJson()) : null;
    } catch (e) {
      debugPrint('Failed to resolve parent comment: $e');
      return null;
    }
  }

  /// Invokes the appropriate callbacks after a successful account switch
  void _invokeCallbacks(Account newAccount, Map<String, dynamic> resolvedItems) {
    widget.onUserChanged?.call(newAccount);

    if (widget.communityActorId != null) {
      widget.onCommunityChanged?.call(resolvedItems['community']);
    }
    if (widget.postActorId != null && resolvedItems['post'] != null) {
      widget.onPostChanged?.call(resolvedItems['post'] as ThunderPost);
    }
    if (widget.parentCommentActorId != null && resolvedItems['parentComment'] != null) {
      widget.onParentCommentChanged?.call(resolvedItems['parentComment'] as ThunderComment);
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

/// Modal bottom sheet widget for selecting user accounts
class _UserProfileSelector extends StatefulWidget {
  /// The current account
  final Account account;

  const _UserProfileSelector(this.account);

  @override
  State<_UserProfileSelector> createState() => _UserProfileSelectorState();
}

class _UserProfileSelectorState extends State<_UserProfileSelector> {
  /// The list of available user accounts
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAccounts());
  }

  /// Loads all available user accounts
  Future<void> _loadAccounts() async {
    try {
      final accounts = await Account.accounts().then((accounts) => accounts.where((account) => account.id != widget.account.id).toList());

      if (!mounted) return;
      setState(() => _accounts = accounts);
    } catch (e) {
      if (!mounted) return;
      setState(() => _accounts = []);
      debugPrint('Failed to load accounts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(l10n.account(2), style: theme.textTheme.titleLarge),
        ),
        _accounts.isEmpty
            ? Center(child: Text(l10n.noAccountsAdded))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _accounts.length,
                itemBuilder: (context, index) {
                  final account = _accounts[index];
                  return ListTile(
                    title: Text(account.username ?? '-', style: theme.textTheme.titleMedium),
                    subtitle: Text(account.instance),
                    onTap: () => Navigator.of(context).pop(account),
                  );
                },
              ),
      ],
    );
  }
}
