import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/bloc/image_bloc.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/markdown_text_editing_controller.dart';
import 'package:thunder/utils/instance.dart';

import 'package:image_picker/image_picker.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/account/models/account.dart';
import 'package:extended_image/extended_image.dart';

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
  bool isClearButtonDisabled = false;
  bool isSubmitButtonDisabled = true;
  bool isNSFW = false;
  bool error = false;

  // final List<bool> _selectedPostType = <bool>[true, false, false];
  String image = '';
  final MarkDownTextEditingController _bodyTextController = MarkDownTextEditingController();
  final TextEditingController _titleTextController = TextEditingController();
  final imageBloc = ImageBloc();

  @override
  void initState() {
    super.initState();

    _bodyTextController.addListener(() {
      if (_bodyTextController.text.isEmpty && !isClearButtonDisabled) setState(() => isClearButtonDisabled = true);
      if (_bodyTextController.text.isNotEmpty && isClearButtonDisabled) setState(() => isClearButtonDisabled = false);
    });

    _titleTextController.addListener(() {
      if (_titleTextController.text.isEmpty && !isSubmitButtonDisabled) setState(() => isSubmitButtonDisabled = true);
      if (_titleTextController.text.isNotEmpty && isSubmitButtonDisabled) setState(() => isSubmitButtonDisabled = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        toolbarHeight: 70.0,
        actions: [
          IconButton(
            onPressed: isSubmitButtonDisabled
                ? null
                : () {
                    image != ''
                        ? context.read<CommunityBloc>().add(CreatePostEvent(name: _titleTextController.text, body: _bodyTextController.text, nsfw: isNSFW, url: image))
                        : context.read<CommunityBloc>().add(CreatePostEvent(name: _titleTextController.text, body: _bodyTextController.text, nsfw: isNSFW));
                    Navigator.of(context).pop();
                  },
            icon: const Icon(
              Icons.send_rounded,
              semanticLabel: 'Create Post',
            ),
          ),
        ],
      ),
      body: BlocListener<ImageBloc, ImageState>(
        listenWhen: (previous, current) => (previous.status != current.status),
        listener: (context, state) {
          if (state.status == ImageStatus.success && state.bodyImage!.isNotEmpty) {
            setState(() => _bodyTextController.text += "![](${state.bodyImage})");
            state.copyWith(bodyImage: '');
          }
          if (state.status == ImageStatus.success && image != state.imageUrl) {
            setState(() => image = state.imageUrl!);
          }
          if (state.status == ImageStatus.uploading && image == '') {
            setState(() => image = 'loading');
          }
          if (state.status == ImageStatus.failure) {
            setState(() {
              error = true;
              if (image == 'loading') image = '';
            });
          }
          if (state.status == ImageStatus.deleting) {
            setState(() => image = '');
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
                  // Text('Create Post', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      Text("Posting To: ", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 20,),
                      Text('${widget.communityInfo?.communityView.community.name} '
                          '· ${fetchInstanceNameFromUrl(
                          widget.communityInfo?.communityView.community.actorId)}',
                        style: theme.textTheme.titleSmall,),
                    ],
                  ),

                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: _titleTextController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                    ),
                  ),
                  const SizedBox(height: 20),
                  error
                    ? const Text(
                        'Error occured while uploading',
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox(height: 0),
                image != '' && image != 'loading'
                    ? Stack(children: [
                        ExtendedImage.network(
                          image,
                          fit: BoxFit.fitWidth,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            onPressed: () {
                              imageBloc.add(const ImageDeleteEvent());
                            },
                            icon: const Icon(
                              Icons.cancel,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 15.0)
                              ],
                            ),
                          ),
                        )
                      ])
                    : image == 'loading'
                        ? const Center(
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    TextButton(
                      child: image == '' ? const Text("Upload Image") : const Text("Upload Image to the Body"),
                      onPressed: () async {
                        error = false;
                        final ImagePicker picker = ImagePicker();
                        XFile? file = await picker.pickImage(source: ImageSource.gallery);
                        try {
                          Account? account = await fetchActiveProfileAccount();
                          String path = file!.path;
                          imageBloc.add(ImageUploadEvent(imageFile: path, instance: account!.instance!, jwt: account.jwt!));
                        } catch (e) {
                          null;
                        }
                      },
                    )
                  ]),
                  Expanded(
                  child: showPreview
                      ? Container(
                          constraints:
                              const BoxConstraints(minWidth: double.infinity),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.all(12),
                          child: SingleChildScrollView(
                            child: CommonMarkdownBody(
                                body: _bodyTextController.text),
                          ),
                        )
                      : TextField(
                          controller: _bodyTextController,
                          expands: true,
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            hintText: "Post Body",
                          ),
                        ),
                ),
                Visibility(visible: !showPreview,
                  child: SingleChildScrollView(scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              _bodyTextController.makeLink();
                            },
                            icon: const Icon(Icons.link)),
                        IconButton(
                            onPressed: () {
                              _bodyTextController.makeBold();
                            },
                            icon: const Icon(Icons.format_bold)),
                        IconButton(
                            onPressed: () {
                              _bodyTextController.makeItalic();
                            },
                            icon: const Icon(Icons.format_italic)),
                        IconButton(
                            onPressed: () {
                              _bodyTextController.makeQuote();
                            },
                            icon: const Icon(Icons.format_quote)),
                        IconButton(
                            onPressed: () {
                              _bodyTextController.makeStrikethrough();
                            },
                            icon: const Icon(Icons.format_strikethrough)),
                        IconButton(
                            onPressed: () {
                              _bodyTextController.makeList();
                            },
                            icon: const Icon(Icons.format_list_bulleted)),
                        IconButton(
                            onPressed: () {
                              _bodyTextController.makeSeparator();
                            },
                            icon: const Icon(Icons.horizontal_rule)),
                        IconButton(
                            onPressed: () {
                              _bodyTextController.makeCode();
                            },
                            icon: const Icon(Icons.code)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: isClearButtonDisabled
                              ? null
                              : () {
                            _bodyTextController.clear();
                            setState(() => showPreview = false);
                          },
                          child: const Text('Clear'),
                        ),
                        TextButton(
                          onPressed: () => setState(() => showPreview = !showPreview),
                          child: Text(showPreview == true ? 'Show Markdown' : 'Show Preview'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
