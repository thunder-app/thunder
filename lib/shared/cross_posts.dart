import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/enums/full_name_separator.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/post/utils/navigate_create_post.dart';
import 'package:thunder/post/utils/navigate_post.dart';

/// Widget which displays a post's cross-posts
class CrossPosts extends StatefulWidget {
  final List<PostView> crossPosts;
  final PostViewMedia? originalPost;
  final bool? isNewPost;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  const CrossPosts({
    super.key,
    required this.crossPosts,
    this.originalPost,
    this.isNewPost,
    this.scaffoldMessengerKey,
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
    final TextStyle? crossPostTextStyle = theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic);
    final TextStyle? crossPostLinkTextStyle = crossPostTextStyle?.copyWith(color: Colors.blue);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: theme.dividerColor.withOpacity(0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: (widget.isNewPost == true && widget.crossPosts.length == 1) ? null : () => setState(() => _areCrossPostsExpanded = !_areCrossPostsExpanded),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          // The rich text handles overflow across multiple sections (TextSpan) of text
                          child: RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: widget.isNewPost == true ? l10n.alreadyPostedTo : l10n.crossPostedTo,
                                  style: crossPostTextStyle,
                                ),
                                TextSpan(
                                  text: ' ${generateCommunityFullName(context, widget.crossPosts[0].community.name, fetchInstanceNameFromUrl(widget.crossPosts[0].community.actorId))} ',
                                  style: crossPostLinkTextStyle,
                                  // This text is not tappable; there is an invisible widget above this that handles the InkWell and the tap gesture
                                ),
                                if (widget.crossPosts.length > 1)
                                  TextSpan(
                                    text: l10n.andXMore(widget.crossPosts.length - 1),
                                    style: crossPostTextStyle,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        (widget.isNewPost == true && widget.crossPosts.length == 1)
                            ? const Icon(null)
                            : _areCrossPostsExpanded
                                ? const Icon(Icons.arrow_drop_up_rounded)
                                : const Icon(Icons.arrow_drop_down_rounded),
                      ],
                    ),
                    // This Row widget exists purely so that we can get an InkWell on the community link.
                    // However, the text is insvisible because we actually want the RichText to manage the text,
                    // including overflow.
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.isNewPost == true ? l10n.alreadyPostedTo : l10n.crossPostedTo,
                            style: crossPostTextStyle?.copyWith(color: Colors.transparent),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(5),
                            onTap: () async => navigateToPost(context, postViewMedia: (await parsePostViews([widget.crossPosts[0]])).first),
                            child: Text(
                              ' ${generateCommunityFullName(context, widget.crossPosts[0].community.name, fetchInstanceNameFromUrl(widget.crossPosts[0].community.actorId))} ',
                              style: crossPostLinkTextStyle?.copyWith(color: Colors.transparent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                            return Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Row(
                                children: [
                                  Text(
                                    ' • ',
                                    style: crossPostTextStyle,
                                  ),
                                  InkWell(
                                    onTap: () async => navigateToPost(context, postViewMedia: (await parsePostViews([widget.crossPosts[index + 1]])).first),
                                    borderRadius: BorderRadius.circular(5),
                                    child: Text(
                                      generateCommunityFullName(context, widget.crossPosts[index + 1].community.name, fetchInstanceNameFromUrl(widget.crossPosts[index + 1].community.actorId)),
                                      style: crossPostLinkTextStyle,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          itemCount: widget.crossPosts.length - 1,
                        ),
                        widget.isNewPost != true
                            ? InkWell(
                                onTap: () => createCrossPost(
                                  context,
                                  title: widget.originalPost!.postView.post.name,
                                  url: widget.originalPost!.postView.post.url,
                                  scaffoldMessengerKey: widget.scaffoldMessengerKey,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Text(
                                        l10n.createNewCrossPost,
                                        style: crossPostTextStyle,
                                      ),
                                      const Icon(Icons.arrow_right_rounded)
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(height: 10),
                      ],
                    )
                  : Container(),
            ),
          ],
        ),
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
  GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey,
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
    scaffoldMessengerKey: scaffoldMessengerKey,
  );
}
