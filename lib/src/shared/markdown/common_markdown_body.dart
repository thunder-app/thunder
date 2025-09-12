import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:jovial_svg/jovial_svg.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:thunder/src/core/enums/media_type.dart';
import 'package:thunder/src/core/enums/view_mode.dart';
import 'package:thunder/src/core/models/media.dart';
import 'package:thunder/src/shared/link_information.dart';
import 'package:thunder/src/shared/markdown/markdown_lemmy_link.dart';
import 'package:thunder/src/shared/markdown/markdown_spoiler.dart';
import 'package:thunder/src/shared/markdown/markdown_subsuperscript.dart';
import 'package:thunder/src/shared/markdown/markdown_utils.dart';
import 'package:thunder/src/shared/utils/media/image.dart';
import 'package:thunder/src/shared/utils/links.dart';
import 'package:thunder/src/core/enums/font_scale.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';
import 'package:thunder/src/shared/markdown/extended_markdown.dart';
import 'package:thunder/src/shared/utils/media/video.dart';
import 'package:thunder/src/shared/widgets/media/media_view.dart';

/// A widget that displays markdown content.
class CommonMarkdownBody extends StatefulWidget {
  /// The markdown content body
  final String body;

  /// Whether to hide the markdown content. This is mainly used for spoiler markdown
  final bool hidden;

  /// Whether the markdown content is NSFW. This blurs any images within the markdown content.
  final bool nsfw;

  /// Indicates if the given markdown is a comment. Depending on the markdown content, different text scaling may be applied
  final bool? isComment;

  /// The maximum width of the image
  final double? imageMaxWidth;

  const CommonMarkdownBody({
    super.key,
    required this.body,
    this.hidden = false,
    this.nsfw = false,
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

    // Disable semantics if the accessibility feature is disabled. This allows the widget to be more performant as it doesn't need to compute the semantics tree.
    // This is useful especially for complex markdown content.
    final accessibilityOn = SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation;

    return ExcludeSemantics(
      excluding: !accessibilityOn,
      child: RepaintBoundary(
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
                  nsfw: widget.nsfw,
                  isComment: widget.isComment,
                  imageMaxWidth: widget.imageMaxWidth,
                ),
          onTapLink: (text, url, title) => handleLinkTap(context, state, text, url),
          onLongPressLink: (text, url, title) => handleLinkLongPress(context, text, url),
          styleSheet: styleSheet.copyWith(textScaleFactor: _getTextScaleFactor(state)),
        ),
      ),
    );
  }
}

/// Given a markdown image, builds the image widget
class MarkdownImageWidget extends StatefulWidget {
  /// The URI of the image
  final Uri uri;

  /// The alt text of the image
  final String? alt;

  /// Whether the image is NSFW
  final bool nsfw;

  /// Whether the image is a comment
  final bool? isComment;

  /// The maximum width of the image
  final double? imageMaxWidth;

  const MarkdownImageWidget({
    super.key,
    required this.uri,
    required this.alt,
    required this.nsfw,
    this.isComment,
    this.imageMaxWidth,
  });

  /// Holds a cache of previously retrieved SVG results
  static final Map<String, bool> _svgCache = {};

  /// Holds a cache of previously retrieved image dimensions
  static final Map<String, Size> _imageDimensionsCache = {};

  @override
  State<MarkdownImageWidget> createState() => _MarkdownImageWidgetState();
}

class _MarkdownImageWidgetState extends State<MarkdownImageWidget> {
  /// The decoded URI of the image
  String? uri;

  /// The media type of the URL
  MediaType? mediaType;

  @override
  void initState() {
    super.initState();

    uri = Uri.decodeFull(widget.uri.toString());

    if (isImageUrl(uri!)) {
      mediaType = MediaType.image;
      _getImageDimensions();
    } else if (isVideoUrl(uri!)) {
      mediaType = MediaType.video;
    } else {
      _checkSVG();
    }
  }

  Future<void> _getImageDimensions() async {
    try {
      if (MarkdownImageWidget._imageDimensionsCache.containsKey(uri)) return;

      Size dimensions = await retrieveImageDimensions(imageUrl: uri);
      dimensions = getScaledMediaSize(width: dimensions.width, height: dimensions.height, offset: 0, tabletMode: true)!;

      MarkdownImageWidget._imageDimensionsCache[uri!] = dimensions;
      setState(() {});
    } catch (e) {
      debugPrint('Error getting image dimensions: $uri - $e');
    }
  }

  Future<void> _checkSVG() async {
    try {
      if (MarkdownImageWidget._svgCache.containsKey(uri)) return;
      final result = await isImageUriSvg(widget.uri);

      MarkdownImageWidget._svgCache[uri!] = result;
      setState(() {});
    } catch (e) {
      debugPrint('Error checking SVG: $uri - $e');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (mediaType == MediaType.video) {
      debugPrint('Video link: $uri');
      return LinkInformation(viewMode: ViewMode.comfortable, mediaType: mediaType, url: uri, showEdgeToEdgeImages: false);
    }

    final isSvg = MarkdownImageWidget._svgCache.containsKey(uri);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          isSvg
              ? _MarkdownSvgWidget(uri: widget.uri, isComment: widget.isComment, imageMaxWidth: widget.imageMaxWidth)
              : MediaView(
                  viewMode: ViewMode.comment,
                  hideNsfwPreviews: widget.nsfw,
                  media: Media(
                    mediaType: MediaType.image,
                    mediaUrl: uri,
                    nsfw: widget.nsfw,
                    width: MarkdownImageWidget._imageDimensionsCache[uri]?.width,
                    height: MarkdownImageWidget._imageDimensionsCache[uri]?.height,
                  ),
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
