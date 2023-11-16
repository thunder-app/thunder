import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:link_preview_generator/link_preview_generator.dart';

import 'package:markdown/markdown.dart' as md;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/shared/image_preview.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/markdown/extended_markdown.dart';

class CommonMarkdownBody extends StatelessWidget {
  final String body;
  final bool isSelectableText;
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
    final l10n = AppLocalizations.of(context)!;

    final ThunderState state = context.watch<ThunderBloc>().state;

    return ExtendedMarkdownBody(
      // TODO We need spoiler support here
      data: body,
      inlineSyntaxes: [LemmyLinkSyntax()],
      imageBuilder: (uri, title, alt) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ImagePreview(
                url: uri.toString(),
                isExpandable: true,
                isComment: isComment,
                showFullHeightImages: true,
              ),
            ],
          ),
        );
      },
      selectable: isSelectableText,
      onTapLink: (text, url, title) => _handleLinkTap(context, state, text, url),
      onLongPressLink: (text, url, title) {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (ctx) {
            bool isValidUrl = url?.startsWith('http') ?? false;

            return BottomSheetListPicker(
              title: l10n.linkActions,
              heading: Column(
                children: [
                  if (isValidUrl) ...[
                    LinkPreviewGenerator(
                      link: url!,
                      placeholderWidget: const CircularProgressIndicator(),
                      linkPreviewStyle: LinkPreviewStyle.large,
                      cacheDuration: Duration.zero,
                      onTap: () {},
                      bodyTextOverflow: TextOverflow.fade,
                      graphicFit: BoxFit.scaleDown,
                      removeElevation: true,
                      backgroundColor: theme.dividerColor.withOpacity(0.25),
                      borderRadius: 10,
                    ),
                    const SizedBox(height: 10),
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(url!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              items: [
                ListPickerItem(label: l10n.open, payload: 'open', icon: Icons.language),
                ListPickerItem(label: l10n.copy, payload: 'copy', icon: Icons.copy_rounded),
                ListPickerItem(label: l10n.share, payload: 'share', icon: Icons.share_rounded),
              ],
              onSelect: (value) {
                switch (value.payload) {
                  case 'open':
                    _handleLinkTap(context, state, text, url);
                    break;
                  case 'copy':
                    Clipboard.setData(ClipboardData(text: url));
                    break;
                  case 'share':
                    Share.share(url);
                    break;
                }
              },
            );
          },
        );
      },
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

Future<void> _handleLinkTap(BuildContext context, ThunderState state, String text, String? url) async {
  Uri? parsedUri = Uri.tryParse(text);

  String parsedUrl = text;

  if (parsedUri != null && parsedUri.host.isNotEmpty) {
    parsedUrl = parsedUri.toString();
  } else {
    parsedUrl = url ?? '';
  }

  // The markdown link processor treats URLs with @ as emails and prepends "mailto:".
  // If the URL contains that, but the text doesn't, we can remove it.
  if (parsedUrl.startsWith('mailto:') && !text.startsWith('mailto:')) {
    parsedUrl = parsedUrl.replaceFirst('mailto:', '');
  }

  if (context.mounted) {
    handleLink(context, url: parsedUrl);
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
