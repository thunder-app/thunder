import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thunder/account/models/user_label.dart';
import 'package:thunder/comment/utils/comment.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/instance/bloc/instance_bloc.dart';
import 'package:thunder/instance/enums/instance_action.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/utils/user_label_utils.dart';
import 'package:thunder/post/widgets/report_comment_dialog.dart';
import 'package:thunder/shared/multi_picker_item.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/shared/text/selectable_text_modal.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/instance/utils/navigate_instance.dart';

import '../../core/auth/bloc/auth_bloc.dart';

enum CommentCardAction {
  save,
  share,
  shareLink,
  shareLinkLocal,
  delete,
  upvote,
  downvote,
  reply,
  edit,
  textActions,
  selectText,
  copyText,
  viewSource,
  report,
  userActions,
  visitProfile,
  blockUser,
  userLabel,
  instanceActions,
  visitInstance,
  blockInstance,
}

class ExtendedCommentCardActions {
  const ExtendedCommentCardActions({
    required this.commentCardAction,
    required this.icon,
    this.getTrailingIcon,
    required this.label,
    this.getColor,
    this.getForegroundColor,
    this.getOverrideIcon,
    this.getOverrideLabel,
    this.getSubtitleLabel,
    this.shouldShow,
    this.shouldEnable,
  });

  final CommentCardAction commentCardAction;
  final IconData icon;
  final IconData Function()? getTrailingIcon;
  final String label;
  final Color Function(BuildContext context)? getColor;
  final Color? Function(BuildContext context, CommentView commentView)?
      getForegroundColor;
  final IconData? Function(CommentView commentView)? getOverrideIcon;
  final String Function(
          BuildContext context, CommentView commentView, bool viewSource)?
      getOverrideLabel;
  final String Function(BuildContext context, CommentView commentView)?
      getSubtitleLabel;
  final bool Function(BuildContext context, CommentView commentView)?
      shouldShow;
  final bool Function(bool isUserLoggedIn)? shouldEnable;
}

final l10n = AppLocalizations.of(GlobalContext.context)!;

final List<ExtendedCommentCardActions> commentCardDefaultActionItems = [
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.userActions,
    icon: Icons.person_rounded,
    label: l10n.user,
    getSubtitleLabel: (context, commentView) => generateUserFullName(
      context,
      commentView.creator.name,
      commentView.creator.displayName,
      fetchInstanceNameFromUrl(commentView.creator.actorId),
    ),
    getTrailingIcon: () => Icons.chevron_right_rounded,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.visitProfile,
    icon: Icons.person_search_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.visitUserProfile,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.blockUser,
    icon: Icons.block,
    label: AppLocalizations.of(GlobalContext.context)!.blockUser,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.userLabel,
    icon: Icons.label_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.addUserLabel,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.instanceActions,
    icon: Icons.language_rounded,
    label: l10n.instance(1),
    getSubtitleLabel: (context, postView) =>
        fetchInstanceNameFromUrl(postView.creator.actorId) ?? '',
    getTrailingIcon: () => Icons.chevron_right_rounded,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.visitInstance,
    icon: Icons.language,
    label: AppLocalizations.of(GlobalContext.context)!.visitInstance,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.blockInstance,
    icon: Icons.block_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.blockInstance,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.textActions,
    icon: Icons.comment_rounded,
    label: l10n.textActions,
    getTrailingIcon: () => Icons.chevron_right_rounded,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.selectText,
    icon: Icons.select_all_rounded,
    label: l10n.selectText,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.copyText,
    icon: Icons.copy_rounded,
    label: AppLocalizations.of(GlobalContext.context)!.copyComment,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.viewSource,
    icon: Icons.edit_document,
    label: l10n.viewCommentSource,
    getOverrideLabel: (context, commentView, viewSource) =>
        viewSource ? l10n.viewOriginal : l10n.viewCommentSource,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.report,
    icon: Icons.report_outlined,
    label: AppLocalizations.of(GlobalContext.context)!.reportComment,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.shareLink,
    icon: Icons.share_rounded,
    label: l10n.shareComment,
    getSubtitleLabel: (context, commentView) => commentView.comment.apId,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.shareLinkLocal,
    icon: Icons.share_rounded,
    label: l10n.shareCommentLocal,
    getSubtitleLabel: (context, commentView) =>
        LemmyClient.instance.generateCommentUrl(commentView.comment.id),
  ),
];

final List<ExtendedCommentCardActions> commentCardDefaultMultiActionItems = [
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.upvote,
    label: AppLocalizations.of(GlobalContext.context)!.upvote,
    icon: Icons.arrow_upward_rounded,
    getColor: (context) => context.read<ThunderBloc>().state.upvoteColor.color,
    getForegroundColor: (context, commentView) => commentView.myVote == 1
        ? context.read<ThunderBloc>().state.upvoteColor.color
        : null,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.downvote,
    label: AppLocalizations.of(GlobalContext.context)!.downvote,
    icon: Icons.arrow_downward_rounded,
    getColor: (context) =>
        context.read<ThunderBloc>().state.downvoteColor.color,
    getForegroundColor: (context, commentView) => commentView.myVote == -1
        ? context.read<ThunderBloc>().state.downvoteColor.color
        : null,
    shouldShow: (context, commentView) =>
        context.read<AuthBloc>().state.downvotesEnabled,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.save,
    label: AppLocalizations.of(GlobalContext.context)!.save,
    icon: Icons.star_border_rounded,
    getColor: (context) => context.read<ThunderBloc>().state.saveColor.color,
    getForegroundColor: (context, commentView) => commentView.saved
        ? context.read<ThunderBloc>().state.saveColor.color
        : null,
    getOverrideIcon: (commentView) =>
        commentView.saved ? Icons.star_rounded : null,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.reply,
    label: AppLocalizations.of(GlobalContext.context)!.reply(0),
    icon: Icons.reply_rounded,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.edit,
    label: AppLocalizations.of(GlobalContext.context)!.edit,
    icon: Icons.edit,
    shouldShow: (context, commentView) =>
        commentView.creator.id ==
        context.read<AuthBloc>().state.account?.userId,
    shouldEnable: (isUserLoggedIn) => isUserLoggedIn,
  ),
  ExtendedCommentCardActions(
    commentCardAction: CommentCardAction.share,
    icon: Icons.share_rounded,
    label: l10n.share,
  ),
];

enum CommentActionBottomSheetPage {
  general,
  user,
  instance,
  share,
  text,
}

void showCommentActionBottomModalSheet(
  BuildContext context,
  CommentView commentView,
  Function onSaveAction,
  Function onDeleteAction,
  Function onVoteAction,
  Function onReplyEditAction,
  Function onReportAction,
  Function onViewSourceToggled,
  bool viewSource,
) {
  final bool isOwnComment =
      commentView.creator.id == context.read<AuthBloc>().state.account?.userId;
  bool isDeleted = commentView.comment.deleted;

  // Generate the list of default actions for the general page
  final List<ExtendedCommentCardActions> defaultCommentCardActions =
      commentCardDefaultActionItems
          .where((extendedAction) => [
                CommentCardAction.userActions,
                CommentCardAction.instanceActions,
                CommentCardAction.textActions,
                CommentCardAction.report,
                CommentCardAction.delete,
              ].contains(extendedAction.commentCardAction))
          .toList();

  // Add the ability to delete one's own comment
  if (isOwnComment) {
    defaultCommentCardActions.add(ExtendedCommentCardActions(
      commentCardAction: CommentCardAction.delete,
      icon: isDeleted ? Icons.restore_from_trash_rounded : Icons.delete_rounded,
      label: isDeleted
          ? AppLocalizations.of(GlobalContext.context)!.restore
          : AppLocalizations.of(GlobalContext.context)!.delete,
    ));
  }

  // Hide the ability to block instance if not supported -- todo change this to instance list
  if (defaultCommentCardActions
          .any((c) => c.commentCardAction == CommentCardAction.blockInstance) &&
      !LemmyClient.instance.supportsFeature(LemmyFeature.blockInstance)) {
    defaultCommentCardActions.removeWhere(
        (c) => c.commentCardAction == CommentCardAction.blockInstance);
  }

  // Generate list of user actions
  final List<ExtendedCommentCardActions> userActions =
      commentCardDefaultActionItems
          .where((extendedAction) => [
                CommentCardAction.visitProfile,
                CommentCardAction.blockUser,
                CommentCardAction.userLabel,
              ].contains(extendedAction.commentCardAction))
          .toList();

  // Generate list of instance actions
  final List<ExtendedCommentCardActions> instanceActions =
      commentCardDefaultActionItems
          .where((extendedAction) => [
                CommentCardAction.visitInstance,
                CommentCardAction.blockInstance,
              ].contains(extendedAction.commentCardAction))
          .toList();

  // Generate the list of share actions
  final List<ExtendedCommentCardActions> shareActions =
      commentCardDefaultActionItems
          .where((extendedAction) => [
                CommentCardAction.shareLink,
                if (commentView.comment.apId !=
                    LemmyClient.instance
                        .generateCommentUrl(commentView.comment.id))
                  CommentCardAction.shareLinkLocal,
              ].contains(extendedAction.commentCardAction))
          .toList();

  // Generate list of text actions
  final List<ExtendedCommentCardActions> textActions =
      commentCardDefaultActionItems
          .where((extendedAction) => [
                CommentCardAction.selectText,
                CommentCardAction.copyText,
                CommentCardAction.viewSource,
              ].contains(extendedAction.commentCardAction))
          .toList();

  showModalBottomSheet<void>(
    showDragHandle: true,
    isScrollControlled: true,
    context: context,
    builder: (builderContext) => CommentActionPicker(
      outerContext: context,
      commentView: commentView,
      titles: {
        CommentActionBottomSheetPage.general: l10n.actions,
        CommentActionBottomSheetPage.user: l10n.userActions,
        CommentActionBottomSheetPage.instance: l10n.instanceActions,
        CommentActionBottomSheetPage.share: l10n.share,
        CommentActionBottomSheetPage.text: l10n.textActions,
      },
      multiCommentCardActions: {
        CommentActionBottomSheetPage.general: commentCardDefaultMultiActionItems
      },
      commentCardActions: {
        CommentActionBottomSheetPage.general: defaultCommentCardActions,
        CommentActionBottomSheetPage.user: userActions,
        CommentActionBottomSheetPage.instance: instanceActions,
        CommentActionBottomSheetPage.share: shareActions,
        CommentActionBottomSheetPage.text: textActions,
      },
      onSaveAction: onSaveAction,
      onDeleteAction: onDeleteAction,
      onVoteAction: onVoteAction,
      onReplyEditAction: onReplyEditAction,
      onReportAction: onReportAction,
      onViewSourceToggled: onViewSourceToggled,
      viewSource: viewSource,
    ),
  );
}

class CommentActionPicker extends StatefulWidget {
  /// The comment
  final CommentView commentView;

  /// This is the set of titles to show for each page
  final Map<CommentActionBottomSheetPage, String> titles;

  /// This is the list of quick actions that are shown horizontally across the top of the sheet
  final Map<CommentActionBottomSheetPage, List<ExtendedCommentCardActions>>
      multiCommentCardActions;

  /// This is the set of full actions to display vertically in a list
  final Map<CommentActionBottomSheetPage, List<ExtendedCommentCardActions>>
      commentCardActions;

  /// The context from whoever invoked this sheet (useful for blocs that would otherwise be missing)
  final BuildContext outerContext;

  // Callback functions
  final Function onSaveAction;
  final Function onDeleteAction;
  final Function onVoteAction;
  final Function onReplyEditAction;
  final Function onReportAction;
  final Function onViewSourceToggled;
  final bool viewSource;

  const CommentActionPicker({
    super.key,
    required this.outerContext,
    required this.commentView,
    required this.titles,
    required this.multiCommentCardActions,
    required this.commentCardActions,
    required this.onSaveAction,
    required this.onDeleteAction,
    required this.onVoteAction,
    required this.onReplyEditAction,
    required this.onReportAction,
    required this.onViewSourceToggled,
    required this.viewSource,
  });

  @override
  State<CommentActionPicker> createState() => _CommentActionPickerState();
}

class _CommentActionPickerState extends State<CommentActionPicker> {
  /// The current page
  CommentActionBottomSheetPage page = CommentActionBottomSheetPage.general;

  @override
  void initState() {
    super.initState();

    BackButtonInterceptor.add(_handleBack);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_handleBack);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    return SingleChildScrollView(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Semantics(
                label:
                    '${widget.titles[page] ?? l10n.actions}, ${page == CommentActionBottomSheetPage.general ? '' : l10n.backButton}',
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Material(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: page == CommentActionBottomSheetPage.general
                          ? null
                          : () => setState(() =>
                              page = CommentActionBottomSheetPage.general),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 10, 16.0, 10.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              if (page !=
                                  CommentActionBottomSheetPage.general) ...[
                                const Icon(Icons.chevron_left, size: 30),
                                const SizedBox(width: 12),
                              ],
                              Semantics(
                                excludeSemantics: true,
                                child: Text(
                                  widget.titles[page] ?? l10n.actions,
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Post metadata chips
              Row(
                children: [
                  const SizedBox(width: 20),
                  LanguagePostCardMetaData(
                      languageId: widget.commentView.comment.languageId),
                ],
              ),
              if (widget.multiCommentCardActions[page]?.isNotEmpty == true)
                MultiPickerItem(
                  pickerItems: [
                    ...widget.multiCommentCardActions[page]!
                        .where((a) =>
                            a.shouldShow?.call(context, widget.commentView) ??
                            true)
                        .map(
                      (a) {
                        return PickerItemData(
                          label: a.label,
                          icon: a.getOverrideIcon?.call(widget.commentView) ??
                              a.icon,
                          backgroundColor: a.getColor?.call(context),
                          foregroundColor: a.getForegroundColor
                              ?.call(context, widget.commentView),
                          onSelected:
                              (a.shouldEnable?.call(isUserLoggedIn) ?? true)
                                  ? () => onSelected(a.commentCardAction)
                                  : null,
                        );
                      },
                    ),
                  ],
                ),
              if (widget.commentCardActions[page]?.isNotEmpty == true)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.commentCardActions[page]!.length,
                  itemBuilder: (BuildContext itemBuilderContext, int index) {
                    return PickerItem(
                      label: widget
                              .commentCardActions[page]![index].getOverrideLabel
                              ?.call(context, widget.commentView,
                                  widget.viewSource) ??
                          widget.commentCardActions[page]![index].label,
                      subtitle: widget
                          .commentCardActions[page]![index].getSubtitleLabel
                          ?.call(context, widget.commentView),
                      icon: widget
                              .commentCardActions[page]![index].getOverrideIcon
                              ?.call(widget.commentView) ??
                          widget.commentCardActions[page]![index].icon,
                      trailingIcon: widget
                          .commentCardActions[page]![index].getTrailingIcon
                          ?.call(),
                      onSelected: (widget
                                  .commentCardActions[page]![index].shouldEnable
                                  ?.call(isUserLoggedIn) ??
                              true)
                          ? () => onSelected(widget
                              .commentCardActions[page]![index]
                              .commentCardAction)
                          : null,
                    );
                  },
                ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  void onSelected(CommentCardAction commentCardAction) async {
    bool pop = true;
    Function action;

    switch (commentCardAction) {
      case CommentCardAction.save:
        action = () => widget.onSaveAction(
            widget.commentView.comment.id, !(widget.commentView.saved));
        break;
      case CommentCardAction.share:
        pop = false;
        action =
            () => setState(() => page = CommentActionBottomSheetPage.share);
        break;
      case CommentCardAction.shareLink:
        action = () => Share.share(widget.commentView.comment.apId);
        break;
      case CommentCardAction.shareLinkLocal:
        action = () => Share.share(LemmyClient.instance
            .generateCommentUrl(widget.commentView.comment.id));
        break;
      case CommentCardAction.delete:
        action = () => widget.onDeleteAction(widget.commentView.comment.id,
            !(widget.commentView.comment.deleted));
      case CommentCardAction.upvote:
        action = () => widget.onVoteAction(widget.commentView.comment.id,
            widget.commentView.myVote == 1 ? 0 : 1);
        break;
      case CommentCardAction.downvote:
        action = () => widget.onVoteAction(widget.commentView.comment.id,
            widget.commentView.myVote == -1 ? 0 : -1);
        break;
      case CommentCardAction.reply:
        action = () => widget.onReplyEditAction(widget.commentView, false);
        break;
      case CommentCardAction.edit:
        action = () => widget.onReplyEditAction(widget.commentView, true);
        break;
      case CommentCardAction.textActions:
        action = () => setState(() => page = CommentActionBottomSheetPage.text);
        pop = false;
        break;
      case CommentCardAction.selectText:
        action = () => showSelectableTextModal(
              context,
              text: widget.commentView.comment.content,
            );
        break;
      case CommentCardAction.copyText:
        action = () => Clipboard.setData(ClipboardData(
                    text: cleanCommentContent(widget.commentView.comment)))
                .then((_) {
              showSnackbar(
                  AppLocalizations.of(widget.outerContext)!.copiedToClipboard);
            });
        break;
      case CommentCardAction.viewSource:
        action = widget.onViewSourceToggled;
        break;

      case CommentCardAction.report:
        action = () => widget.onReportAction(widget.commentView.comment.id);
        break;
      case CommentCardAction.userActions:
        action = () => setState(() => page = CommentActionBottomSheetPage.user);
        pop = false;
        break;
      case CommentCardAction.visitProfile:
        action = () => navigateToFeedPage(widget.outerContext,
            feedType: FeedType.user, userId: widget.commentView.creator.id);
        break;
      case CommentCardAction.blockUser:
        action = () => widget.outerContext.read<UserBloc>().add(UserActionEvent(
            userAction: UserAction.block,
            userId: widget.commentView.creator.id,
            value: true));
        break;
      case CommentCardAction.userLabel:
        action = () async {
          await showUserLabelEditorDialog(
              context,
              UserLabel.usernameFromParts(widget.commentView.creator.name,
                  widget.commentView.creator.actorId));
        };
        break;
      case CommentCardAction.instanceActions:
        action =
            () => setState(() => page = CommentActionBottomSheetPage.instance);
        pop = false;

      case CommentCardAction.visitInstance:
        action = () => navigateToInstancePage(widget.outerContext,
            instanceHost:
                fetchInstanceNameFromUrl(widget.commentView.creator.actorId)!,
            instanceId: widget.commentView.community.instanceId);
        break;
      case CommentCardAction.blockInstance:
        action = () => widget.outerContext
            .read<InstanceBloc>()
            .add(InstanceActionEvent(
              instanceAction: InstanceAction.block,
              instanceId: widget.commentView.creator.instanceId,
              domain:
                  fetchInstanceNameFromUrl(widget.commentView.creator.actorId),
              value: true,
            ));
        break;
    }

    if (pop) {
      Navigator.of(context).pop();
    }

    action();
  }

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    if (page != CommentActionBottomSheetPage.general) {
      setState(() => page = CommentActionBottomSheetPage.general);
      return true;
    }

    return false;
  }
}

void showReportCommentActionBottomSheet(
  BuildContext context, {
  required int commentId,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: context.read<PostBloc>(),
      child: ReportCommentDialog(
        commentId: commentId,
      ),
    ),
  );
}
