import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_buttons.dart';
import 'package:markdown_editable_textinput/markdown_text_input_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/community/bloc/image_bloc.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/community_icon.dart';
import 'package:thunder/shared/link_preview_card.dart';
import 'package:thunder/user/widgets/user_indicator.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/debounce.dart';
import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/instance.dart';

class CreatePostPage extends StatefulWidget {
  final int communityId;
  final FullCommunityView? communityInfo;
  final void Function(DraftPost? draftPost)? onUpdateDraft;
  final DraftPost? previousDraftPost;

  const CreatePostPage({
    super.key,
    required this.communityId,
    this.communityInfo,
    this.previousDraftPost,
    this.onUpdateDraft,
  });

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
  DraftPost newDraftPost = DraftPost();

  final TextEditingController _bodyTextController = TextEditingController();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _urlTextController = TextEditingController();
  final FocusNode _bodyFocusNode = FocusNode();
  final imageBloc = ImageBloc();

  @override
  void initState() {
    super.initState();

    _titleTextController.addListener(() {
      if (_titleTextController.text.isEmpty && !isSubmitButtonDisabled) setState(() => isSubmitButtonDisabled = true);
      if (_titleTextController.text.isNotEmpty && isSubmitButtonDisabled) setState(() => isSubmitButtonDisabled = false);

      widget.onUpdateDraft?.call(newDraftPost..title = _titleTextController.text);
    });

    _urlTextController.addListener(() {
      url = _urlTextController.text;
      debounce(const Duration(milliseconds: 1000), _updatePreview, [url]);

      widget.onUpdateDraft?.call(newDraftPost..url = _urlTextController.text);
    });

    _bodyTextController.addListener(() {
      widget.onUpdateDraft?.call(newDraftPost..text = _bodyTextController.text);
    });

    if (widget.previousDraftPost != null) {
      _titleTextController.text = widget.previousDraftPost!.title ?? '';
      _urlTextController.text = widget.previousDraftPost!.url ?? '';
      _bodyTextController.text = widget.previousDraftPost!.text ?? '';

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await Future.delayed(const Duration(milliseconds: 300));
        showSnackbar(context, AppLocalizations.of(context)!.restoredPostFromDraft);
      });
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
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when we go tap anywhere on the screen
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createPost),
          toolbarHeight: 70.0,
          actions: [
            IconButton(
              onPressed: isSubmitButtonDisabled
                  ? null
                  : () {
                      newDraftPost.saveAsDraft = false;
                      url != ''
                          ? context.read<FeedBloc>().add(CreatePostEvent(communityId: widget.communityId, name: _titleTextController.text, body: _bodyTextController.text, nsfw: isNSFW, url: url))
                          : context.read<FeedBloc>().add(CreatePostEvent(communityId: widget.communityId, name: _titleTextController.text, body: _bodyTextController.text, nsfw: isNSFW));
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
                        const SizedBox(height: 12.0),
                        Row(
                          children: [
                            CommunityIcon(community: widget.communityInfo?.communityView.community, radius: 16),
                            const SizedBox(
                              width: 12,
                            ),
                            Text(
                              '${widget.communityInfo?.communityView.community.name} '
                              '· ${fetchInstanceNameFromUrl(widget.communityInfo?.communityView.community.actorId)}',
                              style: theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
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
                            ],
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
