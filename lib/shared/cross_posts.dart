import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/models/models.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/community/widgets/post_card_metadata.dart';

/// Widget which displays a post's cross-posts
class CrossPosts extends StatefulWidget {
  final List<ThunderPost> crossPosts;
  final ThunderPost? originalPost;
  final bool? isNewPost;

  const CrossPosts({
    super.key,
    required this.crossPosts,
    this.originalPost,
    this.isNewPost,
  }) : assert(originalPost != null || isNewPost == true);

  @override
  State<CrossPosts> createState() => _CrossPostsState();
}

class _CrossPostsState extends State<CrossPosts> {
  bool _areCrossPostsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    final crossPostTextStyle = theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4));
    final crossPostLinkTextStyle = crossPostTextStyle?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75));

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 8.0),
        const Divider(height: 1.0),
        AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubicEmphasized,
          child: _areCrossPostsExpanded
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () async => navigateToPost(context, postId: widget.crossPosts[index].id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.repeat_rounded,
                                        size: 14.0,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                                      ),
                                      SizedBox(width: 4.0),
                                      Flexible(
                                        child: CommunityFullNameWidget(
                                          context,
                                          widget.crossPosts[index].community?.name,
                                          widget.crossPosts[index].community?.title,
                                          fetchInstanceNameFromUrl(widget.crossPosts[index].community?.url),
                                          textStyle: crossPostLinkTextStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CrossPostMetaData(post: widget.crossPosts[index]),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1.0),
                      ],
                    );
                  },
                  itemCount: widget.crossPosts.length,
                )
              : SizedBox(width: MediaQuery.sizeOf(context).width),
        ),
        InkWell(
          onTap: () => setState(() => _areCrossPostsExpanded = !_areCrossPostsExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _areCrossPostsExpanded
                              ? l10n.collapse
                              : widget.isNewPost == true
                                  ? '${l10n.alreadyPostedTo} '
                                  : '${l10n.crossPostedTo} ',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
                        ),
                        if (!_areCrossPostsExpanded)
                          WidgetSpan(
                            child: CommunityFullNameWidget(
                              context,
                              widget.crossPosts[0].community?.name,
                              widget.crossPosts[0].community?.title,
                              fetchInstanceNameFromUrl(widget.crossPosts[0].community?.url),
                              textStyle: theme.textTheme.bodySmall?.copyWith(color: crossPostLinkTextStyle?.color),
                            ),
                          ),
                        TextSpan(
                          text: _areCrossPostsExpanded || widget.crossPosts.length == 1 ? '' : ' ${l10n.andXMore(widget.crossPosts.length - 1)}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                ),
                _areCrossPostsExpanded ? const Icon(Icons.expand_less_rounded, size: 18) : const Icon(Icons.expand_more_rounded, size: 18),
              ],
            ),
          ),
        ),
        Divider(height: 1.0),
      ],
    );
  }
}

void createCrossPost(
  BuildContext context, {
  required String title,
  String? url,
  String? text,
  String? postUrl,
}) async {
  final l10n = AppLocalizations.of(context)!;

  final quotedText = text?.split('\n').map((value) => '> $value\n').join();
  text = "${l10n.crossPostedFrom(postUrl ?? '')}\n\n$quotedText";

  await navigateToCreatePostPage(
    context,
    title: title,
    url: url,
    text: text,
    prePopulated: true,
    isCrossPost: true,
  );
}
