import 'package:flutter/material.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/avatars/community_avatar.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/core/utils/utils.dart';
import 'package:thunder/src/shared/media/image_preview.dart';
import 'package:thunder/packages/ui/ui.dart';

/// A widget that displays a community's header information and related actions.
///
/// This widget can be displayed in two modes:
/// - Default: Shows the community banner, along with additional actions
/// - Condensed: Shows a compact version of the header without the banner and actions
class CommunityHeader extends StatefulWidget {
  /// Community to display in the header
  final ThunderCommunity community;

  /// Instance of the community
  final ThunderSite? instance;

  /// List of moderators for the community
  final List<ThunderUser> moderators;

  /// Whether to show the condensed version of the header
  final bool condensed;

  const CommunityHeader({super.key, required this.community, this.instance, required this.moderators, required this.condensed});

  @override
  State<CommunityHeader> createState() => _CommunityHeaderState();
}

class _CommunityHeaderState extends State<CommunityHeader> {
  @override
  Widget build(BuildContext context) {
    Widget content = _CommunityHeaderContent(community: widget.community);

    if (widget.condensed) {
      return content;
    }

    content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final account = resolveEffectiveAccount(context);

        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          enableDrag: true,
          useSafeArea: true,
          scrollControlDisabledMaxHeightRatio: 0.90,
          builder: (_) => wrapWithCapturedAccountContext(
            context,
            CommunityInformation(launchContext: context, account: account, community: widget.community, instance: widget.instance, moderators: widget.moderators),
          ),
        );
      },
      child: _CommunityHeaderWithBanner(community: widget.community, child: content),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,
      children: [
        content,
        CommunityHeaderActions(community: widget.community, instance: widget.instance, moderators: widget.moderators),
      ],
    );
  }
}

/// The main content of the community header, containing the avatar and community information.
class _CommunityHeaderContent extends StatelessWidget {
  /// Community to display in the header
  final ThunderCommunity community;

  const _CommunityHeaderContent({required this.community});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0, bottom: 12.0),
      child: Row(
        spacing: 20.0,
        children: [
          CommunityAvatar(community: community, radius: 45.0, showCommunityStatus: true),
          Expanded(child: _CommunityInfo(community: community)),
        ],
      ),
    );
  }
}

/// Displays the community's textual information including title, name, and statistics.
class _CommunityInfo extends StatelessWidget {
  /// Community to display information for
  final ThunderCommunity community;

  const _CommunityInfo({required this.community});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(community.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
        CommunityFullNameWidget(
          name: community.name,
          displayName: community.title,
          instance: fetchInstanceNameFromUrl(community.actorId),
          useDisplayName: false, // Override because we're showing title above
        ),
        const SizedBox(height: 8.0),
        _CommunityStats(community: community),
      ],
    );
  }
}

/// Displays community statistics including subscriber and post counts.
class _CommunityStats extends StatelessWidget {
  /// Community to display statistics for
  final ThunderCommunity community;

  const _CommunityStats({required this.community});

  @override
  Widget build(BuildContext context) {
    double iconSize = 16.0 * FontScale.base.textScaleFactor;

    return Row(
      spacing: 10.0,
      children: [
        ThunderIconLabel(
          icon: Icon(Icons.people_rounded, size: iconSize),
          label: formatNumberToK(community.counts.subscribers ?? 0),
        ),
        ThunderIconLabel(
          icon: Icon(Icons.library_books_rounded, size: iconSize),
          label: formatNumberToK(community.counts.posts ?? 0),
        ),
      ],
    );
  }
}

/// A wrapper widget that adds a banner and gradient overlay to the community header.
class _CommunityHeaderWithBanner extends StatelessWidget {
  /// Community to display in the header
  final ThunderCommunity community;

  /// Child widget to display in the header
  final Widget child;

  const _CommunityHeaderWithBanner({required this.community, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        if (community.banner != null) ...[_BannerImage(url: community.banner!), _BannerGradient()],
        Positioned(
          right: 20.0,
          child: Icon(
            Icons.info_outline_rounded,
            size: 24.0,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            shadows: [Shadow(color: theme.colorScheme.onSurface.withValues(alpha: 0.1), blurRadius: 16.0)],
          ),
        ),
        child,
      ],
    );
  }
}

/// Displays the community banner image as a background.
class _BannerImage extends StatelessWidget {
  /// URL of the banner image
  final String url;

  const _BannerImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ImagePreview(url: url, fit: BoxFit.cover),
    );
  }
}

/// Creates a gradient overlay for the banner to improve content readability.
class _BannerGradient extends StatelessWidget {
  const _BannerGradient();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [theme.colorScheme.surface, theme.colorScheme.surface.withValues(alpha: 0.9), theme.colorScheme.surface.withValues(alpha: 0.6), theme.colorScheme.surface.withValues(alpha: 0.3)],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }
}
