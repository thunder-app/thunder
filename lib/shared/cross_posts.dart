import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/post/utils/navigate_create_post.dart';
import 'package:thunder/post/utils/navigate_post.dart';

import 'package:thunder/community/widgets/post_card_metadata.dart';

/// Widget which displays a post's cross-posts
class CrossPosts extends StatefulWidget {
  final List<PostView> crossPosts;
  final PostViewMedia? originalPost;
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

class _CrossPostsState extends State<CrossPosts> with SingleTickerProviderStateMixin {
  bool _areCrossPostsExpanded = false;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TextStyle? crossPostTextStyle = theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4));
    final TextStyle? crossPostLinkTextStyle = crossPostTextStyle?.copyWith(
      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: SlideTransition(position: _offsetAnimation, child: child),
            );
          },
          child: _areCrossPostsExpanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(5),
                              onTap: () async => navigateToPost(context, postViewMedia: (await parsePostViews([widget.crossPosts[index]])).first),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.repeat_rounded,
                                    size: 14.0,
                                    color: theme.colorScheme.onBackground.withOpacity(0.9),
                                  ),
                                  Text(
                                    ' to ',
                                    style: crossPostTextStyle,
                                  ),
                                  Text(
                                    generateCommunityFullName(context, widget.crossPosts[index].community.name, fetchInstanceNameFromUrl(widget.crossPosts[index].community.actorId)),
                                    style: crossPostLinkTextStyle,
                                  ),
                                  const Spacer(),
                                  CrossPostMetaData(crossPost: widget.crossPosts[index]),
                                ],
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                      itemCount: widget.crossPosts.length,
                    ),
                  ],
                )
              : Container(),
        ),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () => setState(() => _areCrossPostsExpanded = !_areCrossPostsExpanded),
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
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                        ),
                        TextSpan(
                          text: _areCrossPostsExpanded
                              ? ''
                              : '${generateCommunityFullName(context, widget.crossPosts[0].community.name, fetchInstanceNameFromUrl(widget.crossPosts[0].community.actorId))} ',
                          style: crossPostLinkTextStyle?.copyWith(fontSize: 12),
                        ),
                        TextSpan(
                          text: _areCrossPostsExpanded || widget.crossPosts.length == 1 ? '' : l10n.andXMore(widget.crossPosts.length - 1),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
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
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  if (url?.isNotEmpty == true) {
    text = null;
  } else {
    final String? quotedText = text?.split('\n').map((value) => '> $value\n').join();
    text = "${l10n.crossPostedFrom(postUrl ?? '')}\n\n$quotedText";
  }

  await navigateToCreatePostPage(
    context,
    title: title,
    url: url,
    text: text,
    prePopulated: true,
  );
}
