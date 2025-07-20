import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:thunder/community/models/thunder_community.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/user/widgets/user_header/user_header_actions.dart';
import 'package:thunder/user/widgets/user_information.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

/// A widget that displays a user's header information and related actions.
///
/// This widget can be displayed in two modes:
/// - Default: Shows the user banner, along with additional actions
/// - Condensed: Shows a compact version of the header without the banner and actions
class UserHeader extends StatefulWidget {
  /// User to display in the header
  final ThunderUser user;

  /// Communities the user moderates
  final List<ThunderCommunity> moderates;

  /// The current feed type (posts/comments)
  final FeedTypeSubview? feedType;

  /// Callback to be called when the feed type is changed (posts/comments)
  final Function(FeedTypeSubview)? onChangeFeedType;

  /// Whether to show the condensed version of the header
  final bool condensed;

  const UserHeader({
    super.key,
    required this.user,
    required this.moderates,
    this.feedType,
    this.onChangeFeedType,
    this.condensed = false,
  });

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> {
  @override
  Widget build(BuildContext context) {
    Widget content = _UserHeaderContent(user: widget.user);

    if (widget.condensed) {
      return content;
    }

    content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        enableDrag: true,
        useSafeArea: true,
        scrollControlDisabledMaxHeightRatio: 0.90,
        builder: (context) => UserInformation(
          user: widget.user,
          moderates: widget.moderates,
        ),
      ),
      child: _UserHeaderWithBanner(user: widget.user, child: content),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,
      children: [
        content,
        UserHeaderActions(
          user: widget.user,
          moderates: widget.moderates,
          feedType: widget.feedType,
          onChangeFeedType: widget.onChangeFeedType,
        ),
      ],
    );
  }
}

/// The main content of the user header, containing the avatar and user information.
class _UserHeaderContent extends StatelessWidget {
  /// User to display in the header
  final ThunderUser user;

  const _UserHeaderContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0, bottom: 12.0),
      child: Row(
        spacing: 20.0,
        children: [
          UserAvatar(user: user, radius: 45.0),
          Expanded(child: _UserInfo(user: user)),
        ],
      ),
    );
  }
}

/// Displays the user's textual information including name, username, and statistics.
class _UserInfo extends StatelessWidget {
  /// User to display information for
  final ThunderUser user;

  const _UserInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AutoSizeText(
          user.displayNameOrName,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
        ),
        UserFullNameWidget(
          context,
          user.name,
          user.displayName,
          fetchInstanceNameFromUrl(user.actorId),
          autoSize: true,
          useDisplayName: false, // Override because we're showing display name above
        ),
        const SizedBox(height: 8.0),
        _UserStats(user: user),
      ],
    );
  }
}

/// Displays user statistics including post and comment counts.
class _UserStats extends StatelessWidget {
  /// User to display statistics for
  final ThunderUser user;

  const _UserStats({required this.user});

  @override
  Widget build(BuildContext context) {
    double iconSize = 16.0 * FontScale.base.textScaleFactor;

    return Row(
      spacing: 10.0,
      children: [
        IconText(
          icon: Icon(Icons.wysiwyg_rounded, size: iconSize),
          text: formatNumberToK(user.posts ?? 0),
        ),
        IconText(
          icon: Icon(Icons.chat_rounded, size: iconSize),
          text: formatNumberToK(user.comments ?? 0),
        ),
      ],
    );
  }
}

/// A wrapper widget that adds a banner and gradient overlay to the user header.
class _UserHeaderWithBanner extends StatelessWidget {
  /// User to display in the header
  final ThunderUser user;

  /// Child widget to display in the header
  final Widget child;

  const _UserHeaderWithBanner({required this.user, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        if (user.banner != null) ...[
          _BannerImage(url: user.banner!),
          _BannerGradient(),
        ],
        Positioned(
          right: 20.0,
          child: Icon(
            Icons.info_outline_rounded,
            size: 24.0,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            shadows: [
              Shadow(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                blurRadius: 16.0,
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

/// Displays the user banner image as a background.
class _BannerImage extends StatelessWidget {
  /// URL of the banner image
  final String url;

  const _BannerImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(url),
            fit: BoxFit.cover,
          ),
        ),
      ),
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
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withValues(alpha: 0.9),
              theme.colorScheme.surface.withValues(alpha: 0.6),
              theme.colorScheme.surface.withValues(alpha: 0.3),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
      ),
    );
  }
}
