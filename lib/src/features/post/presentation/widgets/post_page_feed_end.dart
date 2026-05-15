import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/settings/api.dart';

/// Displays the post comment footer and bottom spacer at the end of the list.
class PostPageFeedEnd extends StatefulWidget {
  const PostPageFeedEnd({super.key, required this.appBarKey});

  /// Key for the sliver app bar used to size the bottom spacer.
  final GlobalKey appBarKey;

  @override
  State<PostPageFeedEnd> createState() => _PostPageFeedEndState();
}

class _PostPageFeedEndState extends State<PostPageFeedEnd> {
  final GlobalKey _reachedEndKey = GlobalKey();
  double _bottomSpacerHeight = 0.0;
  bool _measureScheduled = false;

  void _scheduleSpacerMeasurement() {
    if (_measureScheduled) return;
    _measureScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      if (!mounted) return;
      _measureBottomSpacer();
    });
  }

  void _measureBottomSpacer() {
    final deviceHeight = MediaQuery.sizeOf(context).height;
    final reachedEndHeight = (_reachedEndKey.currentContext?.findRenderObject() as RenderBox?)?.size.height;
    final renderObject = widget.appBarKey.currentContext?.findRenderObject() as RenderSliverFloatingPersistentHeader?;
    final appBarHeight = renderObject?.geometry?.maxPaintExtent;

    if (appBarHeight == null || reachedEndHeight == null) return;

    final nextHeight = deviceHeight - appBarHeight - reachedEndHeight;
    if ((_bottomSpacerHeight - nextHeight).abs() < 0.5) return;

    setState(() => _bottomSpacerHeight = nextHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    final comments = context.select<PostBloc, List<CommentNode>>((bloc) => bloc.state.comments);
    final hasReachedCommentEnd = context.select<PostBloc, bool>((bloc) => bloc.state.hasReachedCommentEnd);
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    Widget child = Container(
      height: 100.0,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: const CircularProgressIndicator(),
    );

    if (hasReachedCommentEnd) {
      _scheduleSpacerMeasurement();
      child = Container(
        key: _reachedEndKey,
        color: theme.dividerColor.withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: ScalableText(
          comments.isEmpty ? l10n.noCommentsFound : l10n.endOfComments,
          textScaleFactor: metadataFontSizeScale.textScaleFactor,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall,
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: _bottomSpacerHeight),
      child: child,
    );
  }
}
