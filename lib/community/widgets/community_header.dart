import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';

import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/utils/colors.dart';
import 'package:thunder/utils/numbers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommunityHeader extends StatefulWidget {
  final bool showCommunitySidebar;
  final GetCommunityResponse getCommunityResponse;
  final Function(bool toggled) onToggle;

  const CommunityHeader({
    super.key,
    required this.showCommunitySidebar,
    required this.getCommunityResponse,
    required this.onToggle,
  });

  @override
  State<CommunityHeader> createState() => _CommunityHeaderState();
}

class _CommunityHeaderState extends State<CommunityHeader> with SingleTickerProviderStateMixin {
  late AnimationController _bannerImageFadeInController;
  late bool _hasBanner;

  @override
  void initState() {
    _bannerImageFadeInController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250), lowerBound: 0.0, upperBound: 1.0);
    _hasBanner = widget.getCommunityResponse.communityView.community.banner?.isNotEmpty == true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FeedBloc feedBloc = context.watch<FeedBloc>();
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Material(
      elevation: widget.showCommunitySidebar ? 5.0 : 0,
      child: GestureDetector(
        onTap: () => widget.onToggle(!widget.showCommunitySidebar),
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
                  widget.getCommunityResponse.communityView.community.banner!,
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
                  CommunityAvatar(
                    community: widget.getCommunityResponse.communityView.community,
                    radius: 25,
                    showCommunityStatus: true,
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
                                  icon: const Icon(Icons.people_rounded, size: 15),
                                  text: formatNumberToK(widget.getCommunityResponse.communityView.counts.subscribers),
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
                                  icon: const Icon(Icons.calendar_month_rounded, size: 15),
                                  text: formatNumberToK(widget.getCommunityResponse.communityView.counts.usersActiveMonth),
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
                                  icon: Icon(getSortIcon(feedBloc.state), size: 15),
                                  text: getSortName(feedBloc.state),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () => widget.onToggle(!widget.showCommunitySidebar),
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
