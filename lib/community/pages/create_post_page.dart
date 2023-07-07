import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/pictrs.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/utils/instance.dart';

import 'package:image_picker/image_picker.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/models/account.dart';

const List<Widget> postTypes = <Widget>[
  Text('Text'),
  Text('Image'),
  Text('Link')
];

class CreatePostPage extends StatefulWidget {
  final int communityId;
  final FullCommunityView? communityInfo;

  const CreatePostPage(
      {super.key, required this.communityId, this.communityInfo});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool showPreview = false;
  bool isClearButtonDisabled = false;
  bool isSubmitButtonDisabled = true;

  // final List<bool> _selectedPostType = <bool>[true, false, false];
  String image = '';
  String description = '';
  String url = '';
  final TextEditingController _bodyTextController = TextEditingController();
  final TextEditingController _titleTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _bodyTextController.addListener(() {
      if (_bodyTextController.text.isEmpty && !isClearButtonDisabled)
        setState(() => isClearButtonDisabled = true);
      if (_bodyTextController.text.isNotEmpty && isClearButtonDisabled)
        setState(() => isClearButtonDisabled = false);
    });

    _titleTextController.addListener(() {
      if (_titleTextController.text.isEmpty && !isSubmitButtonDisabled)
        setState(() => isSubmitButtonDisabled = true);
      if (_titleTextController.text.isNotEmpty && isSubmitButtonDisabled)
        setState(() => isSubmitButtonDisabled = false);
    });
  }

  Future<PictrsUploadFile> sendImageToTheServer(
      String uploadImage, String instance, String jwt) async {
    PictrsApi pictrs = PictrsApi(instance);
    print("Hereee");
    PictrsUpload result = await pictrs.upload(filePath: uploadImage, auth: jwt);
    print(result.files[0].file);
    return result.files[0];
  }

  Future<void> deleteFile(
      PictrsUploadFile fileToDelete, String instance) async {
    PictrsApi pictrs = PictrsApi(instance);
    pictrs.delete(fileToDelete);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.0,
        actions: [
          IconButton(
            onPressed: isSubmitButtonDisabled
                ? null
                : () {
                    context.read<CommunityBloc>().add(CreatePostEvent(
                        name: _titleTextController.text,
                        body: _bodyTextController.text));
                    Navigator.of(context).pop();
                  },
            icon: const Icon(
              Icons.send_rounded,
              semanticLabel: 'Create Post',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('Create Post',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12.0),
                Text(
                    widget.communityInfo?.communityView.community.name ?? 'N/A',
                    style: theme.textTheme.titleLarge),
                Text(
                  fetchInstanceNameFromUrl(widget
                          .communityInfo?.communityView.community.actorId) ??
                      'N/A',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.titleMedium?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 12.0),
                // Center(
                //   child: ToggleButtons(
                //     direction: Axis.horizontal,
                //     onPressed: (int index) {
                //       setState(() {
                //         // The button that is tapped is set to true, and the others to false.
                //         for (int i = 0; i < _selectedPostType.length; i++) {
                //           _selectedPostType[i] = i == index;
                //         }
                //       });
                //     },
                //     borderRadius: const BorderRadius.all(Radius.circular(8)),
                //     constraints: BoxConstraints.expand(width: (MediaQuery.of(context).size.width / postTypes.length) - 12.0),
                //     isSelected: _selectedPostType,
                //     children: postTypes,
                //   ),
                // ),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    TextFormField(
                      controller: _titleTextController,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(children: [
                      Image.file(
                        File(image), //TODO change this to fetch uploaded image for verification
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(height: 20);
                        },
                      ),
                      image != ''
                          ? Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    image = '';
                                  });
                                },
                                icon: const Icon(
                                  Icons.cancel,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black, blurRadius: 15.0)
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(height: 20),
                    ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextButton(
                            child: image == ''
                                ? const Text("Upload Image")
                                : const Text("Upload Image to the Body"),
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              XFile? file = await picker.pickImage(
                                  source: ImageSource.gallery);
                              try {
                                Account? account =
                                    await fetchActiveProfileAccount();
                                String lemmyUploadURL =
                                    "https://${account!.instance!}/pictrs/image/";
                                String path = file!.path;
                                print(path);
                                PictrsUploadFile tokens =
                                    await sendImageToTheServer(
                                        path, account.instance!, account.jwt!);
                                String upload_file = tokens.file;
                                print(upload_file);
                                String delete_token = tokens
                                    .deleteToken; //Will need to implement a storage for those
                                setState(() {
                                  if (image == '') {
                                    image = "$lemmyUploadURL$upload_file";
                                  } else {
                                    _bodyTextController.text =
                                        "${_bodyTextController.text}![]($lemmyUploadURL$upload_file)";
                                  }
                                });
                              } catch (e, s) {
                                null;
                              }
                            },
                          )
                        ]),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: 200,
                          child: showPreview
                              ? Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child:
                                        CommonMarkdownBody(body: description),
                                  ),
                                )
                              : MarkdownTextInput(
                                  (String value) =>
                                      setState(() => description = value),
                                  description,
                                  label: 'Post Body',
                                  maxLines: 5,
                                  actions: const [
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
                                  controller: _bodyTextController,
                                  textStyle: theme.textTheme.bodyLarge,
                                  // textStyle: const TextStyle(fontSize: 16),
                                ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
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
                              onPressed: () =>
                                  setState(() => showPreview = !showPreview),
                              child: Text(showPreview == true
                                  ? 'Show Markdown'
                                  : 'Show Preview'),
                            ),
                          ],
                        ),
                      ],
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
}
