import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/shared/image_preview.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/utils/markdown/extended_markdown.dart';

class CommonMarkdownBody extends StatelessWidget {
  /// The markdown content body
  final String body;

  /// Whether the text is selectable - defaults to false
  final bool isSelectableText;

  /// Indicates if the given markdown is a comment. Depending on the markdown content, different text scaling may be applied
  /// TODO: This should be converted to an enum of possible markdown content (e.g., post, comment, general, metadata, etc.) to allow for more fined-tuned scaling of text
  final bool? isComment;

  const CommonMarkdownBody({
    super.key,
    required this.body,
    this.isSelectableText = false,
    this.isComment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.watch<ThunderBloc>().state;

    return ExtendedMarkdownBody(
      // TODO We need spoiler support here
      data: body,
      inlineSyntaxes: [LemmyLinkSyntax()],
      imageBuilder: (uri, title, alt) {
        return FutureBuilder(
          future: isImageUriSvg(uri),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  !snapshot.hasData
                      ? Container()
                      : snapshot.data == true
                          ? ScalableImageWidget.fromSISource(
                              si: ScalableImageSource.fromSvgHttpUrl(uri),
                            )
                          : ImagePreview(
                              url: uri.toString(),
                              isExpandable: true,
                              isComment: isComment,
                              showFullHeightImages: true,
                            ),
                ],
              ),
            );
          },
        );
      },
      selectable: isSelectableText,
      onTapLink: (text, url, title) => handleLinkTap(context, state, text, url),
      onLongPressLink: (text, url, title) => handleLinkLongPress(context, state, text, url),
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        textScaleFactor: MediaQuery.of(context).textScaleFactor * (isComment == true ? state.commentFontSizeScale.textScaleFactor : state.contentFontSizeScale.textScaleFactor),
        p: theme.textTheme.bodyMedium,
        blockquoteDecoration: const BoxDecoration(
          color: Colors.transparent,
          border: Border(left: BorderSide(color: Colors.grey, width: 4)),
        ),
      ),
    );
  }
}

class LemmyLinkSyntax extends md.InlineSyntax {
  // https://github.com/LemmyNet/lemmy-ui/blob/61255bf01a8d2acdbb77229838002bf8067ada70/src/shared/config.ts#L38
  static const String _pattern = r'(\/[cmu]\/|@|!)([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})';

  LemmyLinkSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final modifier = match[1]!;
    final name = match[2]!;
    final url = match[3]!;
    final anchor = md.Element.text('a', '$modifier$name@$url');

    anchor.attributes['href'] = '$modifier$name@$url';
    parser.addNode(anchor);

    return true;
  }
}
