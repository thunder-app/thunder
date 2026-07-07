import 'dart:async';

import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/drafts/drafts.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/settings/domain/full_name.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

class DraftsSettingsPage extends StatefulWidget {
  const DraftsSettingsPage({super.key, required this.account});

  /// The account to use for the drafts
  final Account account;

  @override
  State<DraftsSettingsPage> createState() => _DraftsSettingsPageState();
}

class _DraftsSettingsPageState extends State<DraftsSettingsPage> with SingleTickerProviderStateMixin {
  final _draftRepository = DraftRepositoryImpl(database: database);

  /// Whether the drafts are loading
  bool _loading = true;

  /// The draft items
  List<_DraftListItemData> _draftItems = const <_DraftListItemData>[];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadDrafts();
    });
  }

  Future<void> _loadDrafts() async {
    final drafts = await _draftRepository.fetchAllDrafts();
    final items = await Future.wait(drafts.map(_buildDraftListItemData));

    if (!mounted) return;

    setState(() {
      _draftItems = items;
      _loading = false;
    });
  }

  Future<_DraftListItemData> _buildDraftListItemData(Draft draft) async {
    final l10n = GlobalContext.l10n;
    final account = widget.account;

    try {
      switch (draft.draftType) {
        case DraftType.postCreate:
        case DraftType.postCreateGeneral:
          ThunderCommunity? community;

          if (draft.replyId != null) {
            try {
              final details = await CommunityRepositoryImpl(account: account).getCommunity(id: draft.replyId);
              community = details.community;
            } catch (_) {}
          }

          return _DraftListItemData(
            draft: draft,
            icon: Icons.article_rounded,
            title: _resolvePostDraftTitle(draft),
            subtitle: _resolveCommunitySubtitle(community),
          );
        case DraftType.postEdit:
          ThunderCommunity? community;

          if (draft.existingId != null) {
            try {
              final response = await PostRepositoryImpl(account: account).getPost(draft.existingId!);
              final post = response?.post;
              if (post is ThunderPost) {
                community = post.community;
              }
            } catch (_) {}
          }

          return _DraftListItemData(
            draft: draft,
            icon: Icons.article_rounded,
            title: _resolvePostDraftTitle(draft),
            subtitle: _resolveCommunitySubtitle(community),
          );
        case DraftType.commentCreateFromPost:
          ThunderCommunity? community;

          if (draft.replyId != null) {
            try {
              final response = await PostRepositoryImpl(account: account).getPost(draft.replyId!);
              final post = response?.post;
              if (post is ThunderPost) {
                community = post.community;
              }
            } catch (_) {}
          }

          return _DraftListItemData(
            draft: draft,
            icon: Icons.comment_rounded,
            title: _resolveCommentDraftTitle(draft),
            subtitle: _resolveCommentSubtitle(l10n.replyToPost, community),
          );
        case DraftType.commentCreateFromComment:
          ThunderCommunity? community;

          if (draft.replyId != null) {
            try {
              final comment = await CommentRepositoryImpl(account: account).getComment(draft.replyId!);
              community = comment.community ?? comment.post?.community;
            } catch (_) {}
          }

          return _DraftListItemData(
            draft: draft,
            icon: Icons.comment_rounded,
            title: _resolveCommentDraftTitle(draft),
            subtitle: _resolveCommentSubtitle(l10n.replyToComment, community),
          );
        case DraftType.commentEdit:
          ThunderCommunity? community;

          if (draft.existingId != null) {
            try {
              final comment = await CommentRepositoryImpl(account: account).getComment(draft.existingId!);
              community = comment.community ?? comment.post?.community;
            } catch (_) {}
          }

          return _DraftListItemData(
            draft: draft,
            icon: Icons.comment_rounded,
            title: _resolveCommentDraftTitle(draft),
            subtitle: _resolveCommentSubtitle(l10n.editComment, community),
          );
        case DraftType.commentCreate:
          ThunderCommunity? community;
          var contextLabel = l10n.replyToComment;

          if (draft.replyId != null) {
            try {
              final comment = await CommentRepositoryImpl(account: account).getComment(draft.replyId!);
              community = comment.community ?? comment.post?.community;
              contextLabel = l10n.replyToComment;
            } catch (_) {
              try {
                final response = await PostRepositoryImpl(account: account).getPost(draft.replyId!);
                final post = response?.post;
                if (post is ThunderPost) {
                  community = post.community;
                  contextLabel = l10n.replyToPost;
                }
              } catch (_) {}
            }
          }

          return _DraftListItemData(
            draft: draft,
            icon: Icons.comment_rounded,
            title: _resolveCommentDraftTitle(draft),
            subtitle: _resolveCommentSubtitle(contextLabel, community),
          );
      }
    } catch (_) {
      return _DraftListItemData(
        draft: draft,
        icon: draft.isCommentNotEmpty ? Icons.comment_rounded : Icons.article_rounded,
        title: draft.isCommentNotEmpty ? _resolveCommentDraftTitle(draft) : _resolvePostDraftTitle(draft),
        subtitle: draft.isCommentNotEmpty ? _resolveCommentSubtitle(l10n.replyToComment, null) : l10n.noCommunitySelected,
      );
    }
  }

  String _resolvePostDraftTitle(Draft draft) {
    final l10n = GlobalContext.l10n;

    final title = draft.title?.trim();
    return title?.isNotEmpty == true ? title! : l10n.untitledPostDraft;
  }

  String _resolveCommentDraftTitle(Draft draft) {
    final l10n = GlobalContext.l10n;

    final body = draft.body ?? '';
    final line = body.split(RegExp(r'\r?\n')).map((line) => line.trim()).firstWhere((line) => line.isNotEmpty, orElse: () => '');
    return line.isNotEmpty ? line : l10n.untitledCommentDraft;
  }

  String _resolveCommunitySubtitle(ThunderCommunity? community) {
    final l10n = GlobalContext.l10n;

    final communityLabel = _resolveCommunityLabel(community);
    return communityLabel ?? l10n.noCommunitySelected;
  }

  String _resolveCommentSubtitle(String contextLabel, ThunderCommunity? community) {
    final communityLabel = _resolveCommunityLabel(community);
    return communityLabel == null ? contextLabel : '$contextLabel • $communityLabel';
  }

  String? _resolveCommunityLabel(ThunderCommunity? community) {
    if (community == null) return null;

    return generateCommunityFullName(
      context,
      community.name,
      community.title,
      fetchInstanceNameFromUrl(community.actorId),
    );
  }

  Future<void> _deleteDraft(_DraftListItemData item) async {
    final l10n = GlobalContext.l10n;
    var confirmed = false;

    await showThunderDialog<void>(
      context: context,
      title: l10n.confirm,
      contentText: l10n.deleteDraftConfirmation,
      onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
      secondaryButtonText: l10n.cancel,
      onPrimaryButtonPressed: (dialogContext, _) async {
        Navigator.of(dialogContext).pop();
        confirmed = true;
      },
      primaryButtonText: l10n.delete,
    );

    if (!confirmed) return;

    await _draftRepository.deleteDraft(
      item.draft.draftType,
      item.draft.existingId,
      item.draft.replyId,
    );

    if (!mounted) return;

    setState(() {
      _draftItems = _draftItems.where((draftItem) => draftItem.draft.id != item.draft.id).toList();
    });
  }

  Future<void> _openDraft(Draft draft) async {
    await _draftRepository.setActiveDraftById(draft.id);

    if (!mounted) return;

    final opened = await openDraftSession(
      repository: _draftRepository,
      draft: draft,
      account: widget.account,
      onPostCreateRestore: (account, communityId, community) async {
        if (!mounted) return;

        await navigateToCreatePostPage(
          context,
          account: account,
          communityId: communityId,
          community: community,
        );
      },
      onPostEditRestore: (account, post) async {
        if (!mounted) return;

        await navigateToCreatePostPage(
          context,
          account: account,
          post: post,
        );
      },
      onCommentCreateFromPostRestore: (account, post) async {
        if (!mounted) return;

        await navigateToCreateCommentPage(
          context,
          account: account,
          post: post,
        );
      },
      onCommentCreateFromCommentRestore: (account, comment) async {
        if (!mounted) return;

        await navigateToCreateCommentPage(
          context,
          account: account,
          parentComment: comment,
        );
      },
      onCommentEditRestore: (account, comment) async {
        if (!mounted) return;

        await navigateToCreateCommentPage(
          context,
          account: account,
          comment: comment,
        );
      },
    );

    if (opened != DraftOpenResult.opened) {
      await _draftRepository.clearActiveDraft();
      if (mounted) showThunderSnackbar(GlobalContext.l10n.unexpectedError);
    }

    if (mounted) await _loadDrafts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(l10n.drafts),
            centerTitle: false,
            toolbarHeight: APP_BAR_HEIGHT,
            pinned: true,
          ),
          SliverList.list(
            children: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_draftItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    l10n.noDrafts,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                )
              else
                ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _draftItems.length,
                  itemBuilder: (context, index) {
                    final item = _draftItems[index];

                    return ListTile(
                      contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 12.0),
                      leading: Icon(item.icon),
                      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(item.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: Icon(Icons.clear, semanticLabel: l10n.remove),
                        onPressed: () => _deleteDraft(item),
                      ),
                      onTap: () => _openDraft(item.draft),
                    );
                  },
                ),
              const SizedBox(height: 128.0),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraftListItemData {
  const _DraftListItemData({required this.draft, required this.icon, required this.title, required this.subtitle});

  /// The draft
  final Draft draft;

  /// The icon
  final IconData icon;

  /// The title
  final String title;

  /// The subtitle
  final String subtitle;
}
