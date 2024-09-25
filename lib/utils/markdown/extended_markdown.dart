import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:markdown/markdown.dart' as md;

/// Used as a dictionary key to index into an Element's attributes and assign a unique key
const String elementKey = 'element_key';

/// A non-scrolling widget that parses and displays Markdown. This is modified from [MarkdownBody]
/// to allow it to extend from [ExtendedMarkdownWidget] rather than the original [MarkdownWidget].
///
/// This change allows additional support for links. The overall logic for this widget has not changed.
///
/// See also:
///
///  * [MarkdownBody], which is the original implementation of this widget.
///  * [ExtendedMarkdownBody], which is the modified version of [MarkdownBody] to support additional functionality.
class ExtendedMarkdownBody extends ExtendedMarkdownWidget {
  /// Creates a non-scrolling widget that parses and displays Markdown.
  ExtendedMarkdownBody({
    super.key,
    required super.data,
    super.selectable,
    super.styleSheet,
    super.styleSheetTheme = null,
    super.syntaxHighlighter,
    super.onTapLink,
    super.onTapText,
    super.imageDirectory,
    super.blockSyntaxes,
    super.inlineSyntaxes,
    super.extensionSet,
    super.imageBuilder,
    super.checkboxBuilder,
    super.bulletBuilder,
    super.builders,
    super.paddingBuilders,
    super.listItemCrossAxisAlignment,
    this.shrinkWrap = true,
    super.fitContent = true,
    super.softLineBreak,
  });

  /// If [shrinkWrap] is `true`, [MarkdownBody] will take the minimum height
  /// that wraps its content. Otherwise, [MarkdownBody] will expand to the
  /// maximum allowed height.
  final bool shrinkWrap;

  void Function()? forceParseMarkdown;

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    if (children!.length == 1 && shrinkWrap) {
      return children.single;
    }
    return Column(
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: fitContent ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// A modified version of [MarkdownWidget] that allows additional functionality.
///
/// Currently, the modifications allow for long press detection on links.
///
/// See also:
/// * [MarkdownWidget], which is the original implementation of this widget.
/// * [ExtendedMarkdownBody], which uses this widget to allow the additional functionality.
abstract class ExtendedMarkdownWidget extends MarkdownWidget {
  const ExtendedMarkdownWidget({
    super.key,
    required super.data,
    super.selectable = false,
    super.styleSheet,
    super.styleSheetTheme = MarkdownStyleSheetBaseTheme.material,
    super.syntaxHighlighter,
    super.onTapLink,
    super.onTapText,
    super.imageDirectory,
    super.blockSyntaxes,
    super.inlineSyntaxes,
    super.extensionSet,
    super.imageBuilder,
    super.checkboxBuilder,
    super.bulletBuilder,
    super.builders = const <String, MarkdownElementBuilder>{},
    super.paddingBuilders = const <String, MarkdownPaddingBuilder>{},
    super.fitContent = false,
    super.listItemCrossAxisAlignment = MarkdownListItemCrossAxisAlignment.baseline,
    super.softLineBreak = false,
  });

  @override
  State<ExtendedMarkdownWidget> createState() => _MarkdownWidgetState();
}

class _MarkdownWidgetState extends State<ExtendedMarkdownWidget> implements MarkdownBuilderDelegate {
  List<Widget>? _children;
  List<md.Node>? _astNodes;

  @override
  void didChangeDependencies() {
    _parseMarkdown();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(ExtendedMarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data || widget.styleSheet != oldWidget.styleSheet) {
      _parseMarkdown();
    }
  }

  void _parseMarkdown() {
    final MarkdownStyleSheet fallbackStyleSheet = kFallbackStyle(context, widget.styleSheetTheme);
    final MarkdownStyleSheet styleSheet = fallbackStyleSheet.merge(widget.styleSheet);

    final md.Document document = md.Document(
      blockSyntaxes: widget.blockSyntaxes,
      inlineSyntaxes: widget.inlineSyntaxes,
      extensionSet: widget.extensionSet ?? md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );

    // Parse the source Markdown data into nodes of an Abstract Syntax Tree.
    final List<String> lines = const LineSplitter().convert(widget.data);
    final List<md.Node> astNodes = document.parseLines(lines);

    // Configure a Markdown widget builder to traverse the AST nodes and
    // create a widget tree based on the elements.
    final MarkdownBuilder builder = MarkdownBuilder(
      delegate: this,
      selectable: widget.selectable,
      styleSheet: styleSheet,
      imageDirectory: widget.imageDirectory,
      imageBuilder: widget.imageBuilder,
      checkboxBuilder: widget.checkboxBuilder,
      bulletBuilder: widget.bulletBuilder,
      builders: widget.builders,
      paddingBuilders: widget.paddingBuilders,
      fitContent: widget.fitContent,
      listItemCrossAxisAlignment: widget.listItemCrossAxisAlignment,
      onTapText: widget.onTapText,
      softLineBreak: widget.softLineBreak,
    );

    // Recursively apply any custom attributes from the previously built set of ast nodes to the new one
    _applyCustomAttributes(_astNodes, astNodes, elementKey);

    _children = builder.build(_astNodes = astNodes);
  }

  void _applyCustomAttributes(List<md.Node>? previousAstNodes, List<md.Node>? newAstNodes, String customAttribute) {
    if (previousAstNodes == null || newAstNodes == null) return;

    int minLength = previousAstNodes.length < newAstNodes.length ? previousAstNodes.length : newAstNodes.length;

    for (int i = 0; i < minLength; i++) {
      if (previousAstNodes[i] is md.Element && newAstNodes[i] is md.Element) {
        md.Element oldNode = previousAstNodes[i] as md.Element;
        md.Element newNode = newAstNodes[i] as md.Element;

        if (oldNode.attributes[customAttribute] != null) {
          newNode.attributes[customAttribute] = oldNode.attributes[customAttribute]!;
        }

        if (oldNode.children?.isNotEmpty == true && newNode.children?.isNotEmpty == true) {
          _applyCustomAttributes(oldNode.children!, newNode.children!, customAttribute);
        }
      }
    }
  }

  @override
  TextSpan formatText(MarkdownStyleSheet styleSheet, String code) {
    code = code.replaceAll(RegExp(r'\n$'), '');
    if (widget.syntaxHighlighter != null) {
      return widget.syntaxHighlighter!.format(code);
    }
    return TextSpan(style: styleSheet.code, text: code);
  }

  @override
  Widget build(BuildContext context) {
    (widget as ExtendedMarkdownBody?)?.forceParseMarkdown = () => _parseMarkdown();
    return widget.build(context, _children);
  }

  @override
  GestureRecognizer createLink(String text, String? href, String title) {
    // Note: We need this override to satisfy the base class,
    // but this gesture recognizer is not actually used for links since we have a custom builder.
    return TapGestureRecognizer();
  }
}

/// A default style sheet generator.
final MarkdownStyleSheet Function(BuildContext, MarkdownStyleSheetBaseTheme?)
// ignore: prefer_function_declarations_over_variables
    kFallbackStyle = (
  BuildContext context,
  MarkdownStyleSheetBaseTheme? baseTheme,
) {
  MarkdownStyleSheet result;
  switch (baseTheme) {
    case MarkdownStyleSheetBaseTheme.platform:
      result = (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) ? MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context)) : MarkdownStyleSheet.fromTheme(Theme.of(context));
      break;
    case MarkdownStyleSheetBaseTheme.cupertino:
      result = MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context));
      break;
    case MarkdownStyleSheetBaseTheme.material:
    // ignore: no_default_cases
    default:
      result = MarkdownStyleSheet.fromTheme(Theme.of(context));
  }

  return result.copyWith(
    textScaleFactor: MediaQuery.textScaleFactorOf(context), // ignore: deprecated_member_use
  );
};
