import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:markdown/markdown.dart' as md;

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
  const ExtendedMarkdownBody({
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
    super.onLongPressLink,
  });

  /// If [shrinkWrap] is `true`, [MarkdownBody] will take the minimum height
  /// that wraps its content. Otherwise, [MarkdownBody] will expand to the
  /// maximum allowed height.
  final bool shrinkWrap;

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
  /// Called when the user long presses a link.
  final MarkdownTapLinkCallback? onLongPressLink;

  /// The duration threshold for a long press on a link. It defaults to 350ms which is typically shorter
  /// than the default long press timeout of 500ms used by other widgets such as [InkWell].
  ///
  /// Having a shorter timeout allows the long-press action gesture to win over other long-press gestures. This reduces the
  /// potential for other gestures to be trigged at the same time.
  final Duration longPressLinkTimeout;

  const ExtendedMarkdownWidget({
    super.key,
    required super.data,
    super.selectable = false,
    super.styleSheet,
    super.styleSheetTheme = MarkdownStyleSheetBaseTheme.material,
    super.syntaxHighlighter,
    super.onTapLink,
    this.onLongPressLink,
    this.longPressLinkTimeout = const Duration(milliseconds: 350),
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
  Timer? _timer;
  late TapGestureRecognizer _tapGestureRecognizer;

  List<Widget>? _children;
  final List<GestureRecognizer> _recognizers = <GestureRecognizer>[];

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

  @override
  void dispose() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
    _disposeRecognizers();
    super.dispose();
  }

  void _parseMarkdown() {
    final MarkdownStyleSheet fallbackStyleSheet = kFallbackStyle(context, widget.styleSheetTheme);
    final MarkdownStyleSheet styleSheet = fallbackStyleSheet.merge(widget.styleSheet);

    _disposeRecognizers();

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

    _children = builder.build(astNodes);
  }

  void _disposeRecognizers() {
    if (_recognizers.isEmpty) {
      return;
    }
    final List<GestureRecognizer> localRecognizers = List<GestureRecognizer>.from(_recognizers);
    _recognizers.clear();
    for (final GestureRecognizer recognizer in localRecognizers) {
      recognizer.dispose();
    }
  }

  /// Modified function that allows for tap and long press detection on links.
  /// The long press detection is determined by a Timer with a given timeout of [longPressLinkTimeout].
  ///
  /// When tapped, the [onTapLink] callback is called. Similarly, when long pressed, the [onLongPressLink] callback is called.
  /// To see the original implementation of this function, see [MarkdownWidget].
  @override
  GestureRecognizer createLink(String text, String? href, String title) {
    _tapGestureRecognizer = TapGestureRecognizer();

    _tapGestureRecognizer.onTapUp = (_) {
      if (_timer != null && _timer!.isActive) {
        if (widget.onTapLink != null) {
          widget.onTapLink!(text, href, title);
        }
        _timer?.cancel();
      }
    };

    _tapGestureRecognizer.onTapDown = (TapDownDetails details) {
      _timer = Timer(widget.longPressLinkTimeout, () {
        _tapGestureRecognizer.resolve(GestureDisposition.accepted);

        if (widget.onLongPressLink != null) {
          widget.onLongPressLink!(text, href, title);
        }
      });
    };

    _recognizers.add(_tapGestureRecognizer);
    return _tapGestureRecognizer;
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
  Widget build(BuildContext context) => widget.build(context, _children);
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
