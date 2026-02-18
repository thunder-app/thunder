import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/packages/ui/ui.dart' as content;
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/app/shell/navigation/link_navigation_utils.dart';
import 'package:thunder/src/shared/links/widgets/link_bottom_sheet.dart';

/// App adapter for package-generic markdown renderer.
class CommonMarkdownBody extends StatelessWidget {
  /// The markdown content body.
  final String body;

  /// Whether to hide the markdown content.
  final bool hidden;

  /// Whether the markdown content is NSFW.
  final bool nsfw;

  /// Indicates if the given markdown is a comment.
  final bool? isComment;

  /// The maximum width of the image.
  final double? imageMaxWidth;

  /// Optional action handlers that decouple media and navigation behavior.
  final content.ContentActionHandlers handlers;

  const CommonMarkdownBody({
    super.key,
    required this.body,
    this.hidden = false,
    this.nsfw = false,
    this.isComment,
    this.imageMaxWidth,
    this.handlers = const content.ContentActionHandlers(),
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final commentFontSizeScale = context.select<ThemePreferencesCubit, FontScale>(
      (cubit) => cubit.state.commentFontSizeScale,
    );
    final contentFontSizeScale = context.select<ThemePreferencesCubit, FontScale>(
      (cubit) => cubit.state.contentFontSizeScale,
    );

    final effectiveHandlers = content.ContentActionHandlers(
      onOpenLink: handlers.onOpenLink ??
          (context, url) {
            handleLink(context, url: url);
          },
      onLongPressLink: handlers.onLongPressLink ??
          (context, text, url) {
            if (url != null) {
              handleLinkLongPress(context, text, url);
            }
          },
      onOpenImage: handlers.onOpenImage,
      onOpenVideo: handlers.onOpenVideo ??
          (context, url) {
            handleVideoLink(context, url: url);
          },
      onMarkRead: handlers.onMarkRead,
    );

    return content.CommonMarkdownBody(
      body: body,
      hidden: hidden,
      nsfw: nsfw,
      isComment: isComment,
      imageMaxWidth: imageMaxWidth,
      handlers: effectiveHandlers,
      commentTextScaleFactor: commentFontSizeScale.textScaleFactor,
      contentTextScaleFactor: contentFontSizeScale.textScaleFactor,
      retryTooltip: l10n.retry,
      nsfwWarningLabel: l10n.nsfwWarning,
    );
  }
}
