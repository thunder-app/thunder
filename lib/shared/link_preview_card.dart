import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

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
import 'package:thunder/utils/navigate_community.dart';
import 'package:thunder/utils/navigate_user.dart';

class LinkPreviewCard extends StatelessWidget {
  const LinkPreviewCard({
    super.key,
    this.originURL,
    this.mediaURL,
    this.mediaHeight,
    this.mediaWidth,
    this.scrapeMissingPreviews = false,
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

  final bool scrapeMissingPreviews;
  final bool showFullHeightImages;

  final bool edgeToEdgeImages;

  final bool markPostReadOnMediaView;
  final bool isUserLoggedIn;

  final bool hideNsfw;

  final ViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if ((mediaURL != null || originURL != null) && viewMode == ViewMode.comfortable) {
      return Semantics(
        label: originURL ?? mediaURL,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((edgeToEdgeImages ? 0 : 12)),
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            fit: StackFit.passthrough,
            children: [
              if (mediaURL != null) ...[
                ImagePreview(
                  url: mediaURL ?? originURL!,
                  height: showFullHeightImages ? mediaHeight : 150,
                  width: mediaWidth ?? MediaQuery.of(context).size.width - (edgeToEdgeImages ? 0 : 24),
                  isExpandable: false,
                )
              ] else if (scrapeMissingPreviews)
                SizedBox(
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
                  child: Column(
                    children: [
                      const Icon(Icons.warning_rounded, size: 55),
                      // This won't show but it does cause the icon above to center
                      Text("NSFW - Tap to reveal", textScaleFactor: MediaQuery.of(context).textScaleFactor * 1.5),
                    ],
                  ),
                ),
              linkInformation(context),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: theme.colorScheme.primary.withOpacity(0.4),
                    onTap: () => triggerOnTap(context),
                    borderRadius: BorderRadius.circular((edgeToEdgeImages ? 0 : 12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if ((mediaURL != null || originURL != null) && viewMode == ViewMode.compact) {
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.passthrough,
          children: [
            mediaURL != null
                ? ImagePreview(
                    url: mediaURL!,
                    height: 75,
                    width: 75,
                    isExpandable: false,
                  )
                : scrapeMissingPreviews
                    ? SizedBox(
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
                      )
                    : Container(
                        height: 75,
                        width: 75,
                        color: theme.cardColor.darken(5),
                        child: Icon(
                          Icons.language,
                          color: theme.colorScheme.onSecondaryContainer,
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
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashColor: theme.colorScheme.primary.withOpacity(0.4),
                  onTap: () => triggerOnTap(context),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      var inkWell = InkWell(
        onTap: () => triggerOnTap(context),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: const Stack(
            alignment: Alignment.center,
            fit: StackFit.passthrough,
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

    if (originURL != null) {
      String? communityName = await getLemmyCommunity(originURL!);

      if (communityName != null) {
        try {
          await navigateToCommunityByName(context, communityName);
          return;
        } catch (e) {
          // Ignore exception, if it's not a valid community we'll perform the next fallback
        }
      }

      String? username = await getLemmyUser(originURL!);

      if (username != null) {
        try {
          await navigateToUserByName(context, username);
          return;
        } catch (e) {
          // Ignore exception, if it's not a valid user, we'll perform the next fallback
        }
      }

      openLink(context, url: originURL!, openInExternalBrowser: openInExternalBrowser);
    }
  }

  Widget linkInformation(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      excludeSemantics: true,
      child: Container(
        color: ElevationOverlay.applySurfaceTint(
          Theme.of(context).colorScheme.surface.withOpacity(0.8),
          Theme.of(context).colorScheme.surfaceTint,
          10,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
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
      ),
    );
  }
}
