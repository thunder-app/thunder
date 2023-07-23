import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thunder/shared/markdown_text_editing_controller.dart';

class MarkdownButtonsView extends StatelessWidget {
  final MarkdownTextEditingController controller;

  const MarkdownButtonsView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                controller.makeLink();
              },
              icon: const Icon(Icons.link)),
          IconButton(
              onPressed: () {
                controller.makeBold();
              },
              icon: const Icon(Icons.format_bold)),
          IconButton(
              onPressed: () {
                controller.makeItalic();
              },
              icon: const Icon(Icons.format_italic)),
          IconButton(
              onPressed: () {
                controller.makeQuote();
              },
              icon: const Icon(Icons.format_quote)),
          IconButton(
              onPressed: () {
                controller.makeStrikethrough();
              },
              icon: const Icon(Icons.format_strikethrough)),
          IconButton(
              onPressed: () {
                controller.makeList();
              },
              icon: const Icon(Icons.format_list_bulleted)),
          IconButton(
              onPressed: () {
                controller.makeSeparator();
              },
              icon: const Icon(Icons.horizontal_rule)),
          IconButton(
              onPressed: () {
                controller.makeCode();
              },
              icon: const Icon(Icons.code)),
        ],
      ),
    );
  }
}
