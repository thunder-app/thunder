import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_buttons.dart';
import 'package:markdown_editable_textinput/markdown_text_input_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/account/bloc/account_bloc.dart';

import 'package:thunder/community/bloc/image_bloc.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/community_icon.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/link_preview_card.dart';
import 'package:thunder/user/widgets/user_indicator.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/debounce.dart';
import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/instance.dart';

class CreatePostPage extends StatefulWidget {
  final int? communityId;
  final CommunityView? communityView;
  final void Function(DraftPost? draftPost)? onUpdateDraft;
  final DraftPost? previousDraftPost;
  final bool isEdit;
  final PostView? postView;

  const CreatePostPage({
    super.key,
    required this.communityId,
    this.communityView,
    this.previousDraftPost,
    this.onUpdateDraft,
    this.isEdit = false,
    this.postView,
  }) :
        // If we're editing, we need a post to edit
        assert(!isEdit || postView != null);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool showPreview = false;
  bool isSubmitButtonDisabled = true;
  bool isNSFW = false;
  bool imageUploading = false;
  bool postImageUploading = false;
  String url = "";
  String? urlError;
  DraftPost newDraftPost = DraftPost();

  int? communityId;
  CommunityView? communityView;

  final TextEditingController _bodyTextController = TextEditingController();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _urlTextController = TextEditingController();
  final FocusNode _bodyFocusNode = FocusNode();
  final imageBloc = ImageBloc();

  @override
  void initState() {
    super.initState();

    communityId = widget.communityId;
    communityView = widget.communityView;

    _titleTextController.addListener(() {
      _validateSubmission();

      widget.onUpdateDraft?.call(newDraftPost..title = _titleTextController.text);
    });

    _urlTextController.addListener(() {
      _validateSubmission();

      url = _urlTextController.text;
      debounce(const Duration(milliseconds: 1000), _updatePreview, [url]);

      widget.onUpdateDraft?.call(newDraftPost..url = _urlTextController.text);
    });

    _bodyTextController.addListener(() {
      widget.onUpdateDraft?.call(newDraftPost..text = _bodyTextController.text);
    });

    if (widget.previousDraftPost != null &&
        (_titleTextController.text != (widget.previousDraftPost!.title ?? '') ||
            _urlTextController.text != (widget.previousDraftPost!.url ?? '') ||
            _bodyTextController.text != (widget.previousDraftPost!.text ?? ''))) {
      _titleTextController.text = widget.previousDraftPost!.title ?? '';
      _urlTextController.text = widget.previousDraftPost!.url ?? '';
      _bodyTextController.text = widget.previousDraftPost!.text ?? '';

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await Future.delayed(const Duration(milliseconds: 300));
        showSnackbar(context, AppLocalizations.of(context)!.restoredPostFromDraft);
      });
    } else if (widget.isEdit && widget.postView != null) {
      _titleTextController.text = widget.postView!.post.name;
      _urlTextController.text = widget.postView!.post.url ?? '';
      _bodyTextController.text = widget.postView!.post.body ?? '';
      isNSFW = widget.postView!.post.nsfw;
    }
  }

  @override
  void dispose() {
    _bodyTextController.dispose();
    _titleTextController.dispose();
    _urlTextController.dispose();
    _bodyFocusNode.dispose();

    FocusManager.instance.primaryFocus?.unfocus();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AccountState accountState = context.read<AccountBloc>().state;

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when we go tap anywhere on the screen
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Edit Post' : AppLocalizations.of(context)!.createPost), // TODO
          toolbarHeight: 70.0,
          actions: [
            IconButton(
              onPressed: isSubmitButtonDisabled
                  ? null
                  : () {
                      newDraftPost.saveAsDraft = false;

                      url != ''
                          ? context.read<FeedBloc>().add(CreatePostEvent(
                                communityId: communityId!,
                                name: _titleTextController.text,
                                body: _bodyTextController.text,
                                nsfw: isNSFW,
                                isEdit: widget.isEdit,
                                postId: widget.postView?.post.id,
                                url: url,
                              ))
                          : context.read<FeedBloc>().add(CreatePostEvent(
                                communityId: communityId!,
                                name: _titleTextController.text,
                                body: _bodyTextController.text,
                                nsfw: isNSFW,
                                isEdit: widget.isEdit,
                                postId: widget.postView?.post.id,
                              ));

                      Navigator.of(context).pop();
                    },
              icon: Icon(
                Icons.send_rounded,
                semanticLabel: AppLocalizations.of(context)!.createPost,
              ),
            ),
          ],
        ),
        body: BlocListener<ImageBloc, ImageState>(
          listenWhen: (previous, current) => (previous.status != current.status),
          listener: (context, state) {
            if (state.status == ImageStatus.success) {
              _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end, "![](${state.imageUrl})");
              setState(() => imageUploading = false);
            }
            if (state.status == ImageStatus.successPostImage) {
              _urlTextController.text = state.imageUrl;
              setState(() => postImageUploading = false);
            }
            if (state.status == ImageStatus.uploading) {
              setState(() => imageUploading = true);
            }
            if (state.status == ImageStatus.uploadingPostImage) {
              setState(() => postImageUploading = true);
            }
            if (state.status == ImageStatus.failure) {
              showSnackbar(context, AppLocalizations.of(context)!.postUploadImageError, leadingIcon: Icons.warning_rounded, leadingIconColor: theme.colorScheme.errorContainer);
              setState(() {
                imageUploading = false;
                postImageUploading = false;
              });
            }
          },
          bloc: imageBloc,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Transform.translate(
                          offset: const Offset(-8, 0),
                          child: InkWell(
                            onTap: widget.isEdit
                                ? null
                                : () {
                                    showCommunityInputDialog(
                                      context,
                                      title: AppLocalizations.of(context)!.community,
                                      onCommunitySelected: (cv) {
                                        setState(() {
                                          communityId = cv.community.id;
                                          communityView = cv;
                                        });
                                        _validateSubmission();
                                      },
                                      emptySuggestions: accountState.subsciptions,
                                    );
                                  },
                            borderRadius: const BorderRadius.all(Radius.circular(50)),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8, top: 12, bottom: 12),
                              child: Row(
                                children: [
                                  CommunityIcon(community: communityView?.community, radius: 16),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  communityId != null
                                      ? Text(
                                          '${communityView?.community.name} '
                                          '· ${fetchInstanceNameFromUrl(communityView?.community.actorId)}',
                                          style: theme.textTheme.titleSmall,
                                        )
                                      : Text(
                                          AppLocalizations.of(context)!.selectCommunity,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontStyle: FontStyle.italic,
                                            color: theme.colorScheme.error,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const UserIndicator(),
                        const SizedBox(height: 12.0),
                        TextFormField(
                          controller: _titleTextController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.postTitle,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: _urlTextController,
                          decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.postURL,
                              errorText: urlError,
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    if (!postImageUploading) {
                                      uploadImage(context, imageBloc, postImage: true);
                                    }
                                  },
                                  icon: postImageUploading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Center(
                                              child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(),
                                          )))
                                      : Icon(Icons.image, semanticLabel: AppLocalizations.of(context)!.uploadImage))),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: url.isNotEmpty,
                          child: LinkPreviewCard(
                            hideNsfw: false,
                            scrapeMissingPreviews: false,
                            originURL: url,
                            mediaURL: isImageUrl(url) ? url : null,
                            mediaHeight: null,
                            mediaWidth: null,
                            showFullHeightImages: false,
                            edgeToEdgeImages: false,
                            viewMode: ViewMode.comfortable,
                            postId: null,
                            markPostReadOnMediaView: false,
                            isUserLoggedIn: true,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(children: <Widget>[
                          Expanded(child: Text(AppLocalizations.of(context)!.postNSFW)),
                          Switch(
                              value: isNSFW,
                              onChanged: (bool value) {
                                setState(() {
                                  isNSFW = value;
                                });
                              }),
                        ]),
                        const SizedBox(
                          height: 10,
                        ),
                        showPreview
                            ? Container(
                                constraints: const BoxConstraints(minWidth: double.infinity),
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.all(12),
                                child: SingleChildScrollView(
                                  child: CommonMarkdownBody(
                                    body: _bodyTextController.text,
                                    isComment: true,
                                  ),
                                ),
                              )
                            : MarkdownTextInputField(
                                controller: _bodyTextController,
                                focusNode: _bodyFocusNode,
                                label: AppLocalizations.of(context)!.postBody,
                                minLines: 8,
                                maxLines: null,
                                textStyle: theme.textTheme.bodyLarge,
                              ),
                      ]),
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: MarkdownButtons(
                            controller: _bodyTextController,
                            focusNode: _bodyFocusNode,
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
                              MarkdownType.username,
                              MarkdownType.community,
                            ],
                            customTapActions: {
                              MarkdownType.username: () {
                                showUserInputDialog(context, title: AppLocalizations.of(context)!.username, onUserSelected: (person) {
                                  _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end,
                                      '[@${person.person.name}@${fetchInstanceNameFromUrl(person.person.actorId)}](${person.person.actorId})');
                                });
                              },
                              MarkdownType.community: () {
                                showCommunityInputDialog(context, title: AppLocalizations.of(context)!.community, onCommunitySelected: (community) {
                                  _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end,
                                      '[@${community.community.title}@${fetchInstanceNameFromUrl(community.community.actorId)}](${community.community.actorId})');
                                });
                              },
                            },
                            imageIsLoading: imageUploading,
                            customImageButtonAction: () => uploadImage(context, imageBloc)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                        child: IconButton(
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() => showPreview = !showPreview);
                              if (!showPreview) {
                                _bodyFocusNode.requestFocus();
                              }
                            },
                            icon: Icon(
                              showPreview ? Icons.visibility_outlined : Icons.visibility,
                              color: theme.colorScheme.onSecondary,
                              semanticLabel: AppLocalizations.of(context)!.postTogglePreview,
                            ),
                            visualDensity: const VisualDensity(horizontal: 1.0, vertical: 1.0),
                            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updatePreview(String text) {
    if (url == text) {
      setState(() {});
    }
  }

  void _validateSubmission() {
    final Uri? parsedUrl = Uri.tryParse(_urlTextController.text);

    if (isSubmitButtonDisabled) {
      // It's disabled, check if we can enable it.
      if (_titleTextController.text.isNotEmpty && parsedUrl != null && communityId != null) {
        setState(() {
          isSubmitButtonDisabled = false;
          urlError = null;
        });
      }
    } else {
      // It's enabled, check if we need to disable it.
      if (_titleTextController.text.isEmpty || parsedUrl == null || communityId == null) {
        setState(() {
          isSubmitButtonDisabled = true;
          urlError = parsedUrl == null ? AppLocalizations.of(context)!.notValidUrl : null;
        });
      }
    }
  }
}

class DraftPost {
  String? title;
  String? url;
  String? text;
  bool saveAsDraft = true;

  DraftPost({this.title, this.url, this.text});

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'text': text,
      };

  static fromJson(Map<String, dynamic> json) => DraftPost(
        title: json['title'],
        url: json['url'],
        text: json['text'],
      );

  bool get isNotEmpty => title?.isNotEmpty == true || url?.isNotEmpty == true || text?.isNotEmpty == true;
}
