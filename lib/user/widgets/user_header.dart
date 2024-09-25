import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/feed/feed.dart';

import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/utils/colors.dart';
import 'package:thunder/utils/numbers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserHeader extends StatefulWidget {
  final bool showUserSidebar;
  final GetPersonDetailsResponse getPersonDetailsResponse;
  final Function(bool toggled) onToggle;

  const UserHeader({
    super.key,
    required this.showUserSidebar,
    required this.getPersonDetailsResponse,
    required this.onToggle,
  });

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> with SingleTickerProviderStateMixin {
  late AnimationController _bannerImageFadeInController;
  late bool _hasBanner;

  @override
  void initState() {
    _bannerImageFadeInController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250), lowerBound: 0.0, upperBound: 1.0);
    _hasBanner = widget.getPersonDetailsResponse.personView.person.banner?.isNotEmpty == true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FeedBloc feedBloc = context.watch<FeedBloc>();
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Material(
      elevation: widget.showUserSidebar ? 5.0 : 0,
      child: GestureDetector(
        onTap: () => widget.onToggle(!widget.showUserSidebar),
        onHorizontalDragEnd: (DragEndDetails dragEndDetails) {
          if (dragEndDetails.velocity.pixelsPerSecond.dx >= 0) {
            widget.onToggle(false);
          } else if (dragEndDetails.velocity.pixelsPerSecond.dx < 0) {
            widget.onToggle(true);
          }
        },
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: getBackgroundColor(context))),
            if (_hasBanner)
              SizedBox(
                height: 100,
                width: MediaQuery.sizeOf(context).width,
                child: ExtendedImage.network(
                  widget.getPersonDetailsResponse.personView.person.banner!,
                  fit: BoxFit.cover,
                  loadStateChanged: (ExtendedImageState state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                        _bannerImageFadeInController.reset();
                        return const SizedBox.shrink();
                      case LoadState.failed:
                        _bannerImageFadeInController.reset();
                        return const SizedBox.shrink();
                      case LoadState.completed:
                        if (state.wasSynchronouslyLoaded) return state.completedWidget;

                        _bannerImageFadeInController.forward();

                        return FadeTransition(
                          opacity: _bannerImageFadeInController,
                          child: state.completedWidget,
                        );
                    }
                  },
                ),
              ),
            Positioned(
              left: 25,
              top: _hasBanner ? 60 : 10,
              child: Column(
                children: [
                  UserAvatar(
                    person: widget.getPersonDetailsResponse.personView.person,
                    radius: 25,
                    showBorder: true,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: _hasBanner ? 125 : 15),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: _hasBanner ? 0 : 45),
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.75,
                        child: Padding(
                          padding: EdgeInsets.only(left: _hasBanner ? 25 : 100),
                          child: Wrap(
                            runSpacing: 10,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: getBackgroundColorAlt(context),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.only(left: 4, right: 4),
                                child: IconText(
                                  icon: const Icon(Icons.wysiwyg_rounded, size: 15),
                                  text: formatNumberToK(widget.getPersonDetailsResponse.personView.counts.postCount),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: getBackgroundColorAlt(context),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.only(left: 4, right: 4),
                                child: IconText(
                                  icon: const Icon(Icons.chat_rounded, size: 15),
                                  text: formatNumberToK(widget.getPersonDetailsResponse.personView.counts.commentCount),
                                ),
                              ),
                              if (feedBloc.state.feedType == FeedType.user) ...[
                                const SizedBox(width: 8.0),
                                Container(
                                  decoration: BoxDecoration(
                                    color: getBackgroundColorAlt(context),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.only(left: 4, right: 4),
                                  child: IconText(
                                    icon: Icon(getSortIcon(feedBloc.state), size: 15),
                                    text: getSortName(feedBloc.state),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => widget.onToggle(!widget.showUserSidebar),
                          child: Container(
                            decoration: BoxDecoration(
                              color: getBackgroundColorAlt(context),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            child: IconText(
                              icon: const Icon(Icons.info_outline_rounded, size: 15),
                              text: l10n.about,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
