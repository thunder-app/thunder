import 'package:flutter/material.dart';

import 'package:jovial_svg/jovial_svg.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:thunder/src/shared/markdown/markdown_lemmy_link.dart';
import 'package:thunder/src/shared/markdown/markdown_spoiler.dart';
import 'package:thunder/src/shared/markdown/markdown_subsuperscript.dart';
import 'package:thunder/src/shared/markdown/markdown_utils.dart';
import 'package:thunder/src/shared/utils/media/image.dart';
import 'package:thunder/src/shared/utils/links.dart';
import 'package:thunder/src/shared/image_preview.dart';
import 'package:thunder/src/core/enums/font_scale.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';
import 'package:thunder/src/shared/markdown/extended_markdown.dart';

/// A widget that displays markdown content.
class CommonMarkdownBody extends StatefulWidget {
  /// The markdown content body
  final String body;

  /// Whether to hide the markdown content. This is mainly used for spoiler markdown
  final bool hidden;

  /// Indicates if the given markdown is a comment. Depending on the markdown content, different text scaling may be applied
  final bool? isComment;

  /// The maximum width of the image
  final double? imageMaxWidth;

  const CommonMarkdownBody({
    super.key,
    required this.body,
    this.hidden = false,
    this.isComment,
    this.imageMaxWidth,
  });

  @override
  State<CommonMarkdownBody> createState() => _CommonMarkdownBodyState();
}

class _CommonMarkdownBodyState extends State<CommonMarkdownBody> {
  MarkdownStyleSheet? _spoilerMarkdownStyleSheet;
  MarkdownStyleSheet? _normalMarkdownStyleSheet;

  static final md.ExtensionSet _customExtensionSet = _getExtensionSet();
  static final List<md.InlineSyntax> _inlineSyntaxes = _getInlineSyntaxes();
  static final Map<String, MarkdownElementBuilder> _builders = _getBuilders();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeStyleSheets();
  }

  void _initializeStyleSheets() {
    _spoilerMarkdownStyleSheet = getSpoilerStyleSheet(context);
    _normalMarkdownStyleSheet = getNormalStyleSheet(context);
  }

  static md.ExtensionSet _getExtensionSet() {
    final base = md.ExtensionSet.gitHubFlavored;

    return md.ExtensionSet(
      [...base.blockSyntaxes, SpoilerBlockSyntax()],
      [...base.inlineSyntaxes, SuperscriptInlineSyntax(), SubscriptInlineSyntax()],
    );
  }

  static List<md.InlineSyntax> _getInlineSyntaxes() {
    return [LemmyLinkSyntax(), SubscriptInlineSyntax(), SuperscriptInlineSyntax()];
  }

  static Map<String, MarkdownElementBuilder> _getBuilders() {
    return {
      'spoiler': SpoilerElementBuilder(),
      'sub': SubscriptElementBuilder(),
      'sup': SuperscriptElementBuilder(),
    };
  }

  double _getTextScaleFactor(ThunderState state) {
    final baseScale = MediaQuery.of(context).textScaleFactor;
    final fontScale = widget.isComment == true ? state.commentFontSizeScale.textScaleFactor : state.contentFontSizeScale.textScaleFactor;
    return baseScale * fontScale;
  }

  @override
  Widget build(BuildContext context) {
    if (_spoilerMarkdownStyleSheet == null || _normalMarkdownStyleSheet == null) _initializeStyleSheets();

    final state = context.watch<ThunderBloc>().state;
    final styleSheet = widget.hidden ? _spoilerMarkdownStyleSheet! : _normalMarkdownStyleSheet!;

    return RepaintBoundary(
      child: ExtendedMarkdownBody(
        data: widget.body,
        extensionSet: _customExtensionSet,
        inlineSyntaxes: _inlineSyntaxes,
        builders: _builders,
        sizedImageBuilder: (config) => widget.hidden
            ? const SizedBox.shrink()
            : MarkdownImageWidget(
                uri: config.uri,
                alt: config.alt,
                isComment: widget.isComment,
                imageMaxWidth: widget.imageMaxWidth,
              ),
        onTapLink: (text, url, title) => handleLinkTap(context, state, text, url),
        onLongPressLink: (text, url, title) => handleLinkLongPress(context, text, url),
        styleSheet: styleSheet.copyWith(textScaleFactor: _getTextScaleFactor(state)),
      ),
    );
  }
}

/// Given a markdown image, builds the image widget
class MarkdownImageWidget extends StatelessWidget {
  /// The URI of the image
  final Uri uri;

  /// The alt text of the image
  final String? alt;

  /// Whether the image is a comment
  final bool? isComment;

  /// The maximum width of the image
  final double? imageMaxWidth;

  const MarkdownImageWidget({
    super.key,
    required this.uri,
    required this.alt,
    this.isComment,
    this.imageMaxWidth,
  });

  Future<bool> _getCachedSvgResult(Uri uri) async {
    final key = uri.toString();
    if (_svgCache.containsKey(key)) return _svgCache[key]!;

    final result = await isImageUriSvg(uri);
    _svgCache[key] = result;
    return result;
  }

  static final Map<String, bool> _svgCache = {};

  @override
  Widget build(BuildContext context) {
    final decodedUri = Uri.decodeFull(uri.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FutureBuilder<bool>(
            future: _getCachedSvgResult(uri),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return _MarkdownSvgWidget(uri: uri, isComment: isComment, imageMaxWidth: imageMaxWidth);
              } else {
                return ImagePreview(
                  url: decodedUri,
                  isExpandable: true,
                  isComment: isComment,
                  showFullHeightImages: true,
                  maxWidth: imageMaxWidth,
                  altText: alt,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Builds an SVG image from markdown
class _MarkdownSvgWidget extends StatelessWidget {
  /// The URI of the SVG image
  final Uri uri;

  /// Whether the image is a comment
  final bool? isComment;

  /// The maximum width of the image
  final double? imageMaxWidth;

  const _MarkdownSvgWidget({required this.uri, this.isComment, this.imageMaxWidth});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      constraints: isComment == true ? BoxConstraints(maxHeight: width * 0.55, maxWidth: width * 0.60) : BoxConstraints(maxWidth: imageMaxWidth ?? width - 24),
      child: ScalableImageWidget.fromSISource(fit: BoxFit.contain, si: ScalableImageSource.fromSvgHttpUrl(uri)),
    );
  }
}
