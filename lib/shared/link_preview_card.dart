import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_preview_generator/link_preview_generator.dart';

import 'package:thunder/utils/links.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/view_mode.dart';
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
    this.postId,
    required this.hideNsfw,
    required this.isUserLoggedIn,
    required this.markPostReadOnMediaView,
  });

  final int? postId;

  final String? originURL;
  final String? mediaURL;

  final double? mediaHeight;
  final double? mediaWidth;

  final bool showLinkPreviews;
  final bool showFullHeightImages;

  final bool edgeToEdgeImages;

  final bool markPostReadOnMediaView;
  final bool isUserLoggedIn;

  final bool hideNsfw;

  final ViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    if ((mediaURL != null || originURL != null) && viewMode == ViewMode.comfortable) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(edgeToEdgeImages ? 0 : 12), // Image border
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(edgeToEdgeImages ? 0 : 12)),
            child: Stack(
              alignment: Alignment.bottomRight,
              fit: StackFit.passthrough,
              children: [
                if (showLinkPreviews)
                  mediaURL != null
                      ? ImagePreview(
                          url: mediaURL ?? originURL!,
                          height: showFullHeightImages ? mediaHeight : 150,
                          width: mediaWidth ?? MediaQuery.of(context).size.width - 24,
                          isExpandable: false,
                        )
                      : SizedBox(
                          height: 150,
                          child: hideNsfw
                              ? ImageFiltered(
                                  imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                  child: LinkPreviewGenerator(
                                    link: originURL!,
                                    showBody: false,
                                    showTitle: false,
                                    placeholderWidget: Container(
                                      margin: const EdgeInsets.all(15),
                                      child: const CircularProgressIndicator(),
                                    ),
                                    cacheDuration: Duration.zero,
                                  ))
                              : LinkPreviewGenerator(
                                  link: originURL!,
                                  showBody: false,
                                  showTitle: false,
                                  placeholderWidget: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  cacheDuration: Duration.zero,
                                ),
                        ),
                if (hideNsfw)
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    child: const Column(
                      children: [
                        Icon(Icons.warning_rounded, size: 55),
                        // Thid won't show but it does cause the icon above to center
                        Text("NSFW - Tap to reveal", textScaleFactor: 1.5),
                      ],
                    ),
                  ),
                linkInformation(context),
              ],
            ),
          ),
          onTap: () => triggerOnTap(context),
        ),
      );
    } else if ((mediaURL != null || originURL != null) && viewMode == ViewMode.compact) {
      return Padding(
        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
        child: InkWell(
          onTap: () => triggerOnTap(context),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.passthrough,
              children: [
                if (showLinkPreviews)
                  mediaURL != null
                      ? ImagePreview(
                          url: mediaURL!,
                          height: 75,
                          width: 75,
                          isExpandable: false,
                        )
                      : SizedBox(
                          height: 75,
                          width: 75,
                          child: hideNsfw
                              ? ImageFiltered(
                                  imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                  child: LinkPreviewGenerator(
                                    link: originURL!,
                                    showBody: false,
                                    showTitle: false,
                                    placeholderWidget: Container(
                                      margin: const EdgeInsets.all(15),
                                      child: const CircularProgressIndicator(),
                                    ),
                                    cacheDuration: Duration.zero,
                                  ))
                              : LinkPreviewGenerator(
                                  link: originURL!,
                                  showBody: false,
                                  showTitle: false,
                                  placeholderWidget: Container(
                                    margin: const EdgeInsets.all(15),
                                    child: const CircularProgressIndicator(),
                                  ),
                                  cacheDuration: Duration.zero,
                                ),
                        ),
                if (hideNsfw)
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    child: const Column(
                      children: [
                        Icon(Icons.warning_rounded, size: 30),
                      ],
                    ),
                  ),
                linkInformation(context),
              ],
            ),
          ),
        ),
      );
    } else {
      var inkWell = InkWell(
        onTap: () => triggerOnTap(context),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.passthrough,
            children: [linkInformation(context)],
          ),
        ),
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

  void triggerOnTap(BuildContext context) async {
    final ThunderState state = context.read<ThunderBloc>().state;
    final openInExternalBrowser = state.openInExternalBrowser;

    if (isUserLoggedIn && markPostReadOnMediaView) {
      try {
        UserBloc userBloc = BlocProvider.of<UserBloc>(context);
        userBloc.add(MarkUserPostAsReadEvent(postId: postId!, read: true));
      } catch (e) {
        CommunityBloc communityBloc = BlocProvider.of<CommunityBloc>(context);
        communityBloc.add(MarkPostAsReadEvent(postId: postId!, read: true));
      }
    }

    if (originURL != null && originURL!.contains('/c/')) {
      // Push navigation
      AccountBloc accountBloc = context.read<AccountBloc>();
      AuthBloc authBloc = context.read<AuthBloc>();
      ThunderBloc thunderBloc = context.read<ThunderBloc>();

      String? communityName = await getLemmyCommunity(originURL!);

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
      openLink(context, url: originURL!, openInExternalBrowser: openInExternalBrowser);
    }
  }

  Widget linkInformation(BuildContext context) {
    final theme = Theme.of(context);

    if (viewMode == ViewMode.compact) {
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 75,
          width: 75,
          color: (mediaURL != null || originURL != null) && viewMode == ViewMode.compact
              ? ElevationOverlay.applySurfaceTint(
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surfaceTint,
                  10,
                ).withOpacity(0.65)
              : ElevationOverlay.applySurfaceTint(
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surfaceTint,
                  10,
                ),
          child: Icon(
            Icons.link_rounded,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      );
    } else {
      return Container(
        color: ElevationOverlay.applySurfaceTint(
          Theme.of(context).colorScheme.surface,
          Theme.of(context).colorScheme.surfaceTint,
          10,
        ),
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
