import 'package:markdown/markdown.dart' as md;

/// A custom inline syntax to handle Lemmy links.
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
