import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:markdown_editor/markdown_editor.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/shared/input_dialogs.dart';
import 'package:thunder/src/shared/theme/color_utils.dart';

class CreatePostBottomBar extends StatelessWidget {
  const CreatePostBottomBar({
    super.key,
    required this.account,
    required this.state,
    required this.bodyController,
    required this.bodyFocusNode,
    required this.post,
    required this.showPreview,
    required this.onTogglePreview,
    required this.onUploadBodyImages,
  });

  /// The account of the user creating the post.
  final Account account;

  /// The current state of the post creation process.
  final CreatePostState state;

  /// The controller for the body input field.
  final TextEditingController bodyController;

  /// The focus node for the body input field.
  final FocusNode bodyFocusNode;

  /// The post being edited, if any.
  final ThunderPost? post;

  /// Whether to show the markdown preview or the editor input field.
  final bool showPreview;

  /// Callback function to toggle between showing the markdown preview and the editor input field.
  final VoidCallback onTogglePreview;

  /// Callback function to be called when the user requests to upload images for the post body.
  final Future<void> Function() onUploadBodyImages;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return Container(
      color: theme.cardColor,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Row(
        children: [
          Expanded(
            child: MarkdownToolbar(
              controller: bodyController,
              focusNode: bodyFocusNode,
              actions: const [
                MarkdownType.image,
                MarkdownType.link,
                MarkdownType.bold,
                MarkdownType.italic,
                MarkdownType.blockquote,
                MarkdownType.strikethrough,
                MarkdownType.title,
                MarkdownType.list,
                MarkdownType.separator,
                MarkdownType.code,
                MarkdownType.spoiler,
                MarkdownType.username,
                MarkdownType.community,
              ],
              customTapActions: {
                MarkdownType.username: () {
                  showUserInputDialog(
                    context,
                    title: l10n.username,
                    account: account,
                    onUserSelected: (user) {
                      bodyController.text = bodyController.text.replaceRange(
                        bodyController.selection.end,
                        bodyController.selection.end,
                        '[@${user.name}@${fetchInstanceNameFromUrl(user.actorId)}](${user.actorId})',
                      );
                    },
                  );
                },
                MarkdownType.community: () {
                  showCommunityInputDialog(
                    context,
                    title: l10n.community,
                    account: account,
                    onCommunitySelected: (community) {
                      bodyController.text = bodyController.text.replaceRange(
                        bodyController.selection.end,
                        bodyController.selection.end,
                        '!${community.name}@${fetchInstanceNameFromUrl(community.actorId)}',
                      );
                    },
                  );
                },
              },
              imageIsLoading: state.status == CreatePostStatus.imageUploadInProgress,
              customImageButtonAction: onUploadBodyImages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0, top: 2.0, left: 4.0, right: 2.0),
            child: IconButton(
              onPressed: onTogglePreview,
              icon: Icon(
                showPreview ? Icons.visibility_off_rounded : Icons.visibility,
                color: theme.colorScheme.onSecondary,
                semanticLabel: l10n.postTogglePreview,
              ),
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondaryContainer),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0, top: 2.0, left: 2.0, right: 8.0),
            child: SizedBox(
              width: 60,
              child: IconButton(
                key: const Key('create-post-submit-button'),
                onPressed: !state.canSubmit || state.status == CreatePostStatus.submitting ? null : () => context.read<CreatePostCubit>().submitPost(),
                icon: state.status == CreatePostStatus.submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )
                    : Icon(
                        post != null ? Icons.edit_rounded : Icons.send_rounded,
                        color: theme.colorScheme.onSecondary,
                        semanticLabel: post != null ? l10n.editPost : l10n.createPost,
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  disabledBackgroundColor: getBackgroundColor(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
