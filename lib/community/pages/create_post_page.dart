import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_buttons.dart';
import 'package:markdown_editable_textinput/markdown_text_input_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/bloc/image_bloc.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/community_icon.dart';
import 'package:thunder/shared/link_preview_card.dart';
import 'package:thunder/utils/debounce.dart';
import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/instance.dart';

import 'package:image_picker/image_picker.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/account/models/account.dart';

const List<Widget> postTypes = <Widget>[Text('Text'), Text('Image'), Text('Link')];

class CreatePostPage extends StatefulWidget {
  final int communityId;
  final FullCommunityView? communityInfo;

  const CreatePostPage({super.key, required this.communityId, this.communityInfo});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool showPreview = false;
  bool isSubmitButtonDisabled = true;
  bool isNSFW = false;
  String url = "";

  final TextEditingController _bodyTextController = TextEditingController();
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _urlTextController = TextEditingController();
  final FocusNode _markdownFocusNode = FocusNode();
  final imageBloc = ImageBloc();

  @override
  void initState() {
    super.initState();

    _titleTextController.addListener(() {
      if (_titleTextController.text.isEmpty && !isSubmitButtonDisabled) setState(() => isSubmitButtonDisabled = true);
      if (_titleTextController.text.isNotEmpty && isSubmitButtonDisabled) setState(() => isSubmitButtonDisabled = false);
    });

    _urlTextController.addListener(() {
      url = _urlTextController.text;
      debounce(const Duration(milliseconds: 1000), _updatePreview, [url]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createPost),
        toolbarHeight: 70.0,
        actions: [
          IconButton(
            onPressed: isSubmitButtonDisabled
                ? null
                : () {
                    url != ''
                        ? context.read<CommunityBloc>().add(CreatePostEvent(name: _titleTextController.text, body: _bodyTextController.text, nsfw: isNSFW, url: url))
                        : context.read<CommunityBloc>().add(CreatePostEvent(name: _titleTextController.text, body: _bodyTextController.text, nsfw: isNSFW));
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
          }
          if (state.status == ImageStatus.successPostImage) {
            _urlTextController.text = state.imageUrl;
          }
          if (state.status == ImageStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.postUploadImageError)));
          }
        },
        bloc: imageBloc,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          CommunityIcon(community: widget.communityInfo?.communityView.community, radius: 16),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            '${widget.communityInfo?.communityView.community.name} '
                            '· ${fetchInstanceNameFromUrl(widget.communityInfo?.communityView.community.actorId)}',
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
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
                                  _uploadImage(postImage: true);
                                },
                                icon: const Icon(Icons.image))),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: url.isNotEmpty,
                        child: LinkPreviewCard(
                          hideNsfw: false,
                          showLinkPreviews: true,
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
                                child: CommonMarkdownBody(body: _bodyTextController.text),
                              ),
                            )
                          : MarkdownTextInputField(
                              controller: _bodyTextController,
                              focusNode: _markdownFocusNode,
                              initialValue: _bodyTextController.text,
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
                        focusNode: _markdownFocusNode,
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
                        customImageButtonAction: _uploadImage,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                      child: IconButton(
                          onPressed: () => setState(() => showPreview = !showPreview),
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
    );
  }

  void _uploadImage({bool postImage = false}) async {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    try {
      Account? account = await fetchActiveProfileAccount();
      String path = file!.path;
      imageBloc.add(ImageUploadEvent(imageFile: path, instance: account!.instance!, jwt: account.jwt!, postImage: postImage));
    } catch (e) {
      null;
    }
  }

  void _updatePreview(String text) {
    if (url == text) {
      setState(() {});
    }
  }
}
