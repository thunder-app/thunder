import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/app/shell/navigation/link_navigation_utils.dart';
import 'package:thunder/src/shared/links/widgets/link_bottom_sheet.dart';

import 'package:jovial_svg/jovial_svg.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:thunder/src/shared/content/utils/media/media_utils.dart';
import 'package:thunder/src/shared/content/widgets/markdown/extended_markdown.dart';
import 'package:thunder/src/shared/content/widgets/markdown/markdown_lemmy_link.dart';
import 'package:thunder/src/shared/content/widgets/markdown/markdown_spoiler.dart';
import 'package:thunder/src/shared/content/widgets/markdown/markdown_subsuperscript.dart';
import 'package:thunder/src/shared/content/utils/markdown/markdown_utils.dart';
import 'package:thunder/src/shared/content/widgets/media/link_information.dart';
import 'package:thunder/src/shared/content/widgets/media/media_view.dart';

/// A widget that displays markdown content.
class CommonMarkdownBody extends StatefulWidget {
  /// The markdown content body.
  final String body;

  /// Whether to hide the markdown content.
  final bool hidden;

  /// Whether the markdown content is NSFW.
  final bool nsfw;

  /// Indicates if the given markdown is a comment.
  final bool? isComment;

  /// The maximum width of the image.
  final double? imageMaxWidth;

  /// Optional source context used for link handling when this markdown is shown in an overlay.
  final BuildContext? launchContext;

  const CommonMarkdownBody({
    super.key,
    required this.body,
    this.hidden = false,
    this.nsfw = false,
    this.isComment,
    this.imageMaxWidth,
    this.launchContext,
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
    return [
      LemmyLinkSyntax(),
      SubscriptInlineSyntax(),
      SuperscriptInlineSyntax(),
    ];
  }

  static Map<String, MarkdownElementBuilder> _getBuilders() {
    return {
      'spoiler': SpoilerElementBuilder(),
      'sub': SubscriptElementBuilder(),
      'sup': SuperscriptElementBuilder(),
    };
  }

  double _getTextScaleFactor() {
    final baseScale = MediaQuery.textScalerOf(context).scale(1.0);
    final resolvedCommentTextScaleFactor = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.commentFontSizeScale).textScaleFactor;
    final resolvedContentTextScaleFactor = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.contentFontSizeScale).textScaleFactor;
    final fontScale = widget.isComment == true ? resolvedCommentTextScaleFactor : resolvedContentTextScaleFactor;
    return baseScale * fontScale;
  }

  @override
  Widget build(BuildContext context) {
    if (_spoilerMarkdownStyleSheet == null || _normalMarkdownStyleSheet == null) {
      _initializeStyleSheets();
    }

    final styleSheet = widget.hidden ? _spoilerMarkdownStyleSheet! : _normalMarkdownStyleSheet!;

    final accessibilityOn = SemanticsBinding.instance.accessibilityFeatures.accessibleNavigation;

    final navigationContext = widget.launchContext ?? context;

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
          onTapLink: (text, url, title) {
            if (url != null) handleLink(navigationContext, url: url);
          },
          onLongPressLink: (text, url, title) {
            if (url != null) handleLinkLongPress(navigationContext, text, url);
          },
          styleSheet: styleSheet.copyWith(textScaleFactor: _getTextScaleFactor()),
        ),
      ),
    );
  }
}

/// Given a markdown image, builds the image widget.
class MarkdownImageWidget extends StatefulWidget {
  /// The URI of the image.
  final Uri uri;

  /// The alt text of the image.
  final String? alt;

  /// Whether the image is NSFW.
  final bool nsfw;

  /// Whether the image is a comment.
  final bool? isComment;

  /// The maximum width of the image.
  final double? imageMaxWidth;

  const MarkdownImageWidget({
    super.key,
    required this.uri,
    required this.alt,
    required this.nsfw,
    this.isComment,
    this.imageMaxWidth,
  });

  /// Holds a cache of previously retrieved SVG results.
  static final Map<String, bool> _svgCache = {};

  @override
  State<MarkdownImageWidget> createState() => _MarkdownImageWidgetState();
}

class _MarkdownImageWidgetState extends State<MarkdownImageWidget> {
  /// The decoded URI of the image.
  String? uri;

  /// The media type of the URL.
  MediaType? mediaType;

  /// The dimensions of the image.
  Size? dimensions;

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
      dimensions = await retrieveImageDimensions(imageUrl: uri!);
      if (dimensions == null) return;

      dimensions = getScaledMediaSize(
        width: dimensions!.width,
        height: dimensions!.height,
        offset: 0,
        tabletMode: true,
      )!;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error getting image dimensions: $uri - $e');
    }
  }

  Future<void> _checkSVG() async {
    try {
      if (MarkdownImageWidget._svgCache.containsKey(uri)) {
        if (mounted) setState(() {});
        return;
      }

      final result = await isImageUriSvg(widget.uri);

      MarkdownImageWidget._svgCache[uri!] = result;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error checking SVG: $uri - $e');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (mediaType == MediaType.video) {
      return LinkInformation(
        viewMode: ViewMode.comfortable,
        mediaType: mediaType,
        url: uri,
        showEdgeToEdgeImages: false,
        onTap: () {
          if (uri != null) handleLink(context, url: uri!);
        },
        onLongPress: () {
          if (uri != null) {
            handleLinkLongPress(context, uri!, uri);
          }
        },
      );
    }

    final isSvg = MarkdownImageWidget._svgCache[uri] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          isSvg
              ? _MarkdownSvgWidget(
                  uri: widget.uri,
                  isComment: widget.isComment,
                  imageMaxWidth: widget.imageMaxWidth,
                )
              : MediaView(
                  viewMode: ViewMode.comment,
                  hideNsfwPreviews: widget.nsfw,
                  media: Media(
                    mediaType: MediaType.image,
                    mediaUrl: uri,
                    nsfw: widget.nsfw,
                    width: dimensions?.width,
                    height: dimensions?.height,
                  ),
                ),
        ],
      ),
    );
  }
}

/// Builds an SVG image from markdown.
class _MarkdownSvgWidget extends StatelessWidget {
  /// The URI of the SVG image.
  final Uri uri;

  /// Whether the image is a comment.
  final bool? isComment;

  /// The maximum width of the image.
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
