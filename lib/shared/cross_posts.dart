import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/post/utils/navigate_create_post.dart';
import 'package:thunder/post/utils/navigate_post.dart';

import '../community/widgets/post_card_metadata.dart';

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

    return InkWell(
      onTap: (widget.isNewPost == true && widget.crossPosts.length == 1) ? null : () => setState(() => _areCrossPostsExpanded = !_areCrossPostsExpanded),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.isNewPost == true ? l10n.alreadyPostedTo : l10n.crossPostedTo,
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              (widget.crossPosts.length == 1)
                  ? const Icon(null)
                  : _areCrossPostsExpanded
                      ? const Icon(Icons.expand_less_rounded, size: 18)
                      : const Icon(Icons.expand_more_rounded, size: 18),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Row(
            children: [
              Expanded(
                // The rich text handles overflow across multiple sections (TextSpan) of text
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(
                          Icons.repeat_rounded,
                          size: 14.0,
                          color: theme.colorScheme.onBackground.withOpacity(0.9),
                        ),
                      ),
                      const WidgetSpan(
                        child: SizedBox(width: 6.0),
                      ),
                      TextSpan(
                        text: 'to',
                        style: crossPostTextStyle,
                      ),
                      const WidgetSpan(
                        child: SizedBox(width: 6.0),
                      ),
                      WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: InkWell(
                            onTap: () async => navigateToPost(context, postViewMedia: (await parsePostViews([widget.crossPosts[0]])).first),
                            child: Text(
                              '${generateCommunityFullName(context, widget.crossPosts[0].community.name, fetchInstanceNameFromUrl(widget.crossPosts[0].community.actorId))} ',
                              style: crossPostLinkTextStyle,
                              // This text is not tappable; there is an invisible widget above this that handles the InkWell and the tap gesture
                            ),
                          )),
                      if (widget.crossPosts.length > 1 && !_areCrossPostsExpanded)
                        TextSpan(
                          text: l10n.andXMore(widget.crossPosts.length - 1),
                          style: crossPostTextStyle,
                        ),
                    ],
                  ),
                ),
              ),
              CrossPostMetaData(
                score: widget.crossPosts[0].counts.score,
                comments: widget.crossPosts[0].counts.comments,
                unreadComments: widget.crossPosts[0].unreadComments,
                hasBeenEdited: widget.crossPosts[0].post.updated != null ? true : false,
                published: widget.crossPosts[0].post.published,
                saved: widget.crossPosts[0].saved,
              ),
            ],
          ),
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
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              const Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                            child: Icon(
                                              Icons.repeat_rounded,
                                              size: 14.0,
                                              color: theme.colorScheme.onBackground.withOpacity(0.9),
                                            ),
                                          ),
                                          const WidgetSpan(
                                            child: SizedBox(width: 6.0),
                                          ),
                                          TextSpan(
                                            text: 'to',
                                            style: crossPostTextStyle,
                                          ),
                                          const WidgetSpan(
                                            child: SizedBox(width: 6.0),
                                          ),
                                          WidgetSpan(
                                              alignment: PlaceholderAlignment.middle,
                                              child: InkWell(
                                    onTap: () async => navigateToPost(context, postViewMedia: (await parsePostViews([widget.crossPosts[index + 1]])).first),
                                                onTap: () async => navigateToPost(context, postViewMedia: (await parsePostViews([widget.crossPosts[index + 1]])).first),
                                                child: Text(
                                                  '${generateCommunityFullName(context, widget.crossPosts[index + 1].community.name, fetchInstanceNameFromUrl(widget.crossPosts[index + 1].community.actorId))} ',
                                                  style: crossPostLinkTextStyle,
                                                  // This text is not tappable; there is an invisible widget above this that handles the InkWell and the tap gesture
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                  CrossPostMetaData(
                                    score: widget.crossPosts[index + 1].counts.score,
                                    comments: widget.crossPosts[index + 1].counts.comments,
                                    unreadComments: widget.crossPosts[index + 1].unreadComments,
                                    hasBeenEdited: widget.crossPosts[index + 1].post.updated != null ? true : false,
                                    published: widget.crossPosts[index + 1].post.published,
                                    saved: widget.crossPosts[index + 1].saved,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                        itemCount: widget.crossPosts.length - 1,
                      ),
                    ],
                  )
                : Container(),
          ),
        ],
      ),
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
