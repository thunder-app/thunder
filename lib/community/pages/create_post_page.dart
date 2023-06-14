import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

const List<Widget> postTypes = <Widget>[Text('Text'), Text('Image'), Text('Link')];

class CreatePostPage extends StatefulWidget {
  final int communityId;

  const CreatePostPage({super.key, required this.communityId});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  bool showPreview = false;
  bool isClearButtonDisabled = false;
  bool isSubmitButtonDisabled = true;

  String description = '';
  TextEditingController controller = TextEditingController();
  final TextEditingController _titleTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (controller.text.isEmpty && !isClearButtonDisabled) setState(() => isClearButtonDisabled = true);
      if (controller.text.isNotEmpty && isClearButtonDisabled) setState(() => isClearButtonDisabled = false);

      print(controller.text);
    });

    _titleTextController.addListener(() {
      if (_titleTextController.text.isEmpty && !isSubmitButtonDisabled) setState(() => isSubmitButtonDisabled = true);
      if (_titleTextController.text.isNotEmpty && isSubmitButtonDisabled) setState(() => isSubmitButtonDisabled = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        centerTitle: false,
        toolbarHeight: 70.0,
        actions: [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ToggleButtons(children: [], isSelected: []),
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
                      height: 350,
                      child: showPreview
                          ? Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.all(12),
                              child: SingleChildScrollView(
                                child: MarkdownBody(
                                  data: description,
                                  shrinkWrap: true,
                                ),
                              ),
                            )
                          : MarkdownTextInput(
                              (String value) => setState(() => description = value),
                              description,
                              label: 'Post Body',
                              maxLines: 10,
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
                              controller: controller,
                              textStyle: const TextStyle(fontSize: 16),
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
                                  controller.clear();
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: isSubmitButtonDisabled
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
