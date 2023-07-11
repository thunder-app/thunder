import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/shared/image_preview.dart';
import 'package:thunder/utils/font_size.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/shared/webview.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';

class CommonMarkdownBody extends StatelessWidget {
  final String body;
  final bool isSelectableText;

  const CommonMarkdownBody({super.key, required this.body, this.isSelectableText = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.watch<ThunderBloc>().state;

    bool openInExternalBrowser = state.openInExternalBrowser;

    return MarkdownBody(
      data: body,
      imageBuilder: (uri, title, alt) {
        return ImagePreview(
          url: uri.toString(),
          width: MediaQuery.of(context).size.width - 24,
          isExpandable: true,
          showFullHeightImages: true,
        );
      },
      selectable: isSelectableText,
      onTapLink: (text, url, title) {
        Uri? parsedUri = Uri.tryParse(text);

        String parsedUrl = text;

        if (parsedUri != null && parsedUri.host.isNotEmpty) {
          parsedUrl = parsedUri.toString();
        } else {
          parsedUrl = url ?? '';
        }

        String? communityName = checkLemmyInstanceUrl(parsedUrl);

        if (communityName != null) {
          // Push navigation
          AccountBloc accountBloc = context.read<AccountBloc>();
          AuthBloc authBloc = context.read<AuthBloc>();
          ThunderBloc thunderBloc = context.read<ThunderBloc>();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: accountBloc),
                  BlocProvider.value(value: authBloc),
                  BlocProvider.value(value: thunderBloc),
                ],
                child: CommunityPage(communityName: communityName),
              ),
            ),
          );
        } else if (url != null) {
          if (openInExternalBrowser == true) {
            launchUrl(Uri.parse(parsedUrl), mode: LaunchMode.externalApplication);
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => WebView(url: parsedUrl)));
          }
        }
      },
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        textScaleFactor: state.contentFontSizeScale.textScaleFactor,
        p: theme.textTheme.bodyMedium,
        blockquoteDecoration: const BoxDecoration(
          color: Colors.transparent,
          border: Border(left: BorderSide(color: Colors.grey, width: 4)),
        ),
      ),
    );
  }
}
