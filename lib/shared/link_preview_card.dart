import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/shared/webview.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/shared/image_preview.dart';

class LinkPreviewCard extends StatelessWidget {
  const LinkPreviewCard({
    super.key,
    this.originURL,
    this.mediaURL,
    this.mediaHeight,
    this.mediaWidth,
    this.showLinkPreviews = true,
    this.showFullHeightImages = false,
    this.edgeToEdgeImages = false,
    this.viewMode = ViewMode.comfortable,
    this.postId = 0,
  });

  final String? originURL;
  final String? mediaURL;

  final double? mediaHeight;
  final double? mediaWidth;

  final bool showLinkPreviews;
  final bool showFullHeightImages;

  final bool edgeToEdgeImages;

  final ViewMode viewMode;
  final int postId;

  @override
  Widget build(BuildContext context) {
    if (mediaURL != null && viewMode == ViewMode.comfortable) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(6), // Image border
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
            child: Stack(
              alignment: Alignment.bottomRight,
              fit: StackFit.passthrough,
              children: [
                if (showLinkPreviews)
                  ImagePreview(
                    url: mediaURL!,
                    height: showFullHeightImages ? mediaHeight : null,
                    width: mediaWidth ?? MediaQuery.of(context).size.width - 24,
                    isExpandable: false,
                    postId: postId,
                  ),
                linkInformation(context),
              ],
            ),
          ),
          onTap: () => triggerOnTap(context),
        ),
      );
    } else {
      var inkWell = InkWell(
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          child: Stack(
            alignment: Alignment.bottomRight,
            fit: StackFit.passthrough,
            children: [linkInformation(context)],
          ),
        ),
        onTap: () => triggerOnTap(context),
      );
      if (edgeToEdgeImages) {
        return Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 8.0, left: 12.0, right: 12.0),
          child: inkWell,
        );
      } else {
          return Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
            child: inkWell,
        );
      }
    }
  }

  void triggerOnTap(BuildContext context) {
    final ThunderState state = context.read<ThunderBloc>().state;

    final openInExternalBrowser = state.openInExternalBrowser;

    if (originURL != null && originURL!.contains('/c/')) {
      // Push navigation
      AccountBloc accountBloc = context.read<AccountBloc>();
      AuthBloc authBloc = context.read<AuthBloc>();
      ThunderBloc thunderBloc = context.read<ThunderBloc>();

      String? communityName = generateCommunityInstanceUrl(originURL);

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
    } else if (originURL != null) {
      if (openInExternalBrowser) {
        launchUrl(Uri.parse(originURL!), mode: LaunchMode.externalApplication);
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => WebView(url: originURL!)));
      }
    }
  }

  Widget linkInformation(BuildContext context) {
    final theme = Theme.of(context);
    final bool useDarkTheme = context.read<ThemeBloc>().state.useDarkTheme;

    if (viewMode == ViewMode.compact) {
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
        child: Container(
          color: useDarkTheme ? theme.colorScheme.background.lighten(7) : theme.colorScheme.background.darken(7),
          child: SizedBox(
            height: 75.0,
            width: 75.0,
            child: Icon(
              Icons.link_rounded,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: useDarkTheme ? theme.colorScheme.background.lighten(7) : theme.colorScheme.background.darken(7),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.link,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            if (viewMode != ViewMode.compact)
              Expanded(
                child: Text(
                  originURL!,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      );
    }
  }
}
