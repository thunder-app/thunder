import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/utils/instance.dart';

const List<Widget> postTypes = <Widget>[Text('Text'), Text('Image'), Text('Link')];

class CreatePostPage extends StatefulWidget {
  final int communityId;
  final GetCommunityResponse? communityInfo;

  const CreatePostPage({super.key, required this.communityId, this.communityInfo});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool showPreview = false;
  bool isClearButtonDisabled = false;
  bool isSubmitButtonDisabled = true;

  // final List<bool> _selectedPostType = <bool>[true, false, false];

  String description = '';
  TextEditingController _bodyTextController = TextEditingController();
  final TextEditingController _titleTextController = TextEditingController();

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
      appBar: AppBar(toolbarHeight: 70.0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text('Create Post', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12.0),
                Text(widget.communityInfo?.communityView.community.name ?? 'N/A', style: theme.textTheme.titleLarge),
                Text(
                  fetchInstanceNameFromUrl(widget.communityInfo?.communityView.community.actorId) ?? 'N/A',
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
                ListView(shrinkWrap: true, children: <Widget>[
                  TextFormField(
                    controller: _titleTextController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 200,
                        child: showPreview
                            ? Container(
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.all(12),
                                child: SingleChildScrollView(
                                  child: MarkdownBody(
                                    data: description,
                                    shrinkWrap: true,
                                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                                      p: theme.textTheme.bodyLarge,
                                      blockquoteDecoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border(left: BorderSide(color: Colors.grey, width: 4)),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : MarkdownTextInput(
                                (String value) => setState(() => description = value),
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
                            onPressed: () => setState(() => showPreview = !showPreview),
                            child: Text(showPreview == true ? 'Show Markdown' : 'Show Preview'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ]),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: isSubmitButtonDisabled
                      ? null
                      : () {
                          context.read<CommunityBloc>().add(CreatePostEvent(name: _titleTextController.text, body: _bodyTextController.text));
                          Navigator.of(context).pop();
                        },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
