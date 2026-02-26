import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/packages/ui/ui.dart' show ScalableText;

class AdditionalCommentCard extends StatefulWidget {
  /// The function to call when tapped
  final Function()? onTap;

  /// The depth of the comment in the comment tree
  final int depth;

  /// The number of replies for the comment
  final int replies;

  const AdditionalCommentCard({
    super.key,
    this.onTap,
    this.depth = 0,
    this.replies = 0,
  });

  @override
  State<AdditionalCommentCard> createState() => _AdditionalCommentCardState();
}

class _AdditionalCommentCardState extends State<AdditionalCommentCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    final nestedCommentIndicatorStyle = context.select<CommentPreferencesCubit, NestedCommentIndicatorStyle>((cubit) => cubit.state.nestedCommentIndicatorStyle);
    final nestedCommentIndicatorColor = context.select<CommentPreferencesCubit, NestedCommentIndicatorColor>((cubit) => cubit.state.nestedCommentIndicatorColor);
    final commentFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.commentFontSizeScale);

    final padding = (nestedCommentIndicatorStyle == NestedCommentIndicatorStyle.thick ? widget.depth + 1 : widget.depth) * 4.0;
    final reply = widget.replies == 1 ? l10n.loadMoreSingular(widget.replies) : l10n.loadMorePlural(widget.replies);

    return Container(
      decoration: CommentDepthIndicatorDecoration(context, level: widget.depth + 1, style: nestedCommentIndicatorStyle, scheme: nestedCommentIndicatorColor),
      child: Padding(
        padding: EdgeInsets.only(left: padding),
        child: InkWell(
          onTap: () {
            setState(() => isLoading = true);
            widget.onTap?.call();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0.0, 12.0),
                    child: ScalableText(
                      reply,
                      textScaleFactor: commentFontSizeScale.textScaleFactor,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(width: 20.0, height: 20.0, child: CircularProgressIndicator()),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
