import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:link_preview_generator/link_preview_generator.dart';

import 'package:markdown/markdown.dart' as md;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/shared/image_preview.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigate_comment.dart';
import 'package:thunder/utils/navigate_post.dart';
import 'package:thunder/utils/navigate_user.dart';

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
    final ThunderState state = context.watch<ThunderBloc>().state;

    return MarkdownBody(
      // TODO We need spoiler support here
      data: body,
      builders: {
        'a': LinkElementBuilder(context: context, state: state, isComment: isComment),
      },
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
      // Since we're now rending links ourselves, we do not want a separate onTapLink handler.
      // In fact, when this is here, it triggers on text that doesn't even represent a link.
      //onTapLink: (text, url, title) => _handleLinkTap(context, state, text, url),
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

/// Creates a [MarkdownElementBuilder] that renders links.
class LinkElementBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  final ThunderState state;
  final bool? isComment;

  LinkElementBuilder({required this.context, required this.state, required this.isComment});

  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element, TextStyle? preferredStyle, TextStyle? parentStyle) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    String? href = element.attributes['href'];
    if (href == null) {
      // Not a link
      return super.visitElementAfterWithContext(context, element, preferredStyle, parentStyle);
    } else if (href.startsWith('mailto:')) {
      href = href.replaceFirst('mailto:', '');
    }

    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () => _handleLinkTap(context, state, element.textContent, href),
              onLongPress: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (ctx) => BottomSheetListPicker(
                    title: l10n.linkActions,
                    heading: Column(
                      children: [
                        if (!element.attributes['href']!.startsWith('mailto:')) ...[
                          LinkPreviewGenerator(
                            link: href!,
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
                                child: Text(href!),
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
                          _handleLinkTap(context, state, element.textContent, href);
                          break;
                        case 'copy':
                          Clipboard.setData(ClipboardData(text: href!));
                          break;
                        case 'share':
                          Share.share(href!);
                          break;
                      }
                    },
                  ),
                );
              },
              child: Text(
                element.textContent,
                // Note that we don't need to specify a textScaleFactor here because it's already applied by the styleSheet of the parent
                style: theme.textTheme.bodyMedium?.copyWith(
                  // TODO: In the future, we could consider using a theme color (or a blend) here.
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
