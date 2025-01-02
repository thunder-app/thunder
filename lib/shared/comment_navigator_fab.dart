import 'package:flutter/material.dart';

import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/comment/models/comment_node.dart';

class CommentNavigatorFab extends StatefulWidget {
  /// The [ScrollController] for the scrollable list
  final ScrollController scrollController;

  /// The [ListController] for the scrollable list. This is used to navigate up and down
  final ListController listController;

  /// The list of comments. This is used to determine the current and next parent
  final List<CommentNode>? comments;

  /// The initial index
  final int initialIndex;

  /// The maximum index that can be scrolled to
  final int maxIndex;

  /// The height of the OS status bar, needed to calculate an offset for scrolling comments to the top
  final double statusBarHeight;

  const CommentNavigatorFab({
    super.key,
    this.initialIndex = 0,
    this.maxIndex = 0,
    required this.scrollController,
    required this.listController,
    this.comments,
    required this.statusBarHeight,
  });

  @override
  State<CommentNavigatorFab> createState() => _CommentNavigatorFabState();
}

class _CommentNavigatorFabState extends State<CommentNavigatorFab> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant CommentNavigatorFab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialIndex != widget.initialIndex) {
      // Reset the index if it ever changes. This could be due to an external event
      currentIndex = widget.initialIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 135,
      child: Material(
        color: Colors.transparent,
        elevation: 3,
        borderRadius: BorderRadius.circular(50),
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                child: SizedBox(
                  height: 45,
                  child: Material(
                    borderRadius: BorderRadius.circular(50),
                    child: const InkWell(),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 45,
                  height: 45,
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: navigateToParent,
                      onLongPress: navigateUp,
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        semanticLabel: AppLocalizations.of(context)!.navigateUp,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 45),
                SizedBox(
                  width: 45,
                  height: 45,
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: navigateToNextParent,
                      onLongPress: navigateDown,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        semanticLabel: AppLocalizations.of(context)!.navigateDown,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void navigateUp() {
    var unobstructedVisibleRange = widget.listController.unobstructedVisibleRange;

    int previousIndex = (unobstructedVisibleRange?.$1 ?? 0) - 1;
    if (currentIndex == previousIndex) previousIndex--;
    if (previousIndex < 0) previousIndex = 0;

    setState(() => currentIndex = previousIndex);

    // Calculate alignment
    final double screenHeight = MediaQuery.of(context).size.height;
    final double alignmentOffset = widget.statusBarHeight / screenHeight;

    widget.listController.animateToItem(
      index: previousIndex,
      scrollController: widget.scrollController,
      alignment: alignmentOffset,
      duration: (estimatedDistance) => const Duration(milliseconds: 450),
      curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
    );
  }

  void navigateToParent() {
    if (widget.comments == null) {
      // This is a placeholder to allow the previous post page to function correctly.
      // TODO: Remove this logic when we deprecate the legacy post page
      navigateUp();
      return;
    }

    var unobstructedVisibleRange = widget.listController.unobstructedVisibleRange;

    int previousIndex = (unobstructedVisibleRange?.$1 ?? 0) - 1;
    if (currentIndex == previousIndex) previousIndex--;
    if (previousIndex < 0) previousIndex = 0;

    int parentCommentIndex = 0;

    for (int i = previousIndex; i >= 0; i--) {
      CommentNode currentComment = widget.comments![i - 1];

      List<String> pathSegments = currentComment.commentView!.comment.path.split('.');
      int depth = pathSegments.length > 2 ? pathSegments.length - 2 : 0;

      if (depth == 0) {
        parentCommentIndex = i;
        break;
      }
    }

    setState(() => currentIndex = parentCommentIndex);

    // Calculate alignment
    final double screenHeight = MediaQuery.of(context).size.height;
    final double alignmentOffset = widget.statusBarHeight / screenHeight;

    widget.listController.animateToItem(
      index: parentCommentIndex,
      scrollController: widget.scrollController,
      alignment: alignmentOffset,
      duration: (estimatedDistance) => const Duration(milliseconds: 450),
      curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
    );
  }

  void navigateDown() {
    var unobstructedVisibleRange = widget.listController.unobstructedVisibleRange;

    int nextIndex = (unobstructedVisibleRange?.$1 ?? 0) + 1;
    if (currentIndex == nextIndex) nextIndex++;

    setState(() => currentIndex = nextIndex);

    // Calculate alignment
    final double screenHeight = MediaQuery.of(context).size.height;
    final double alignmentOffset = widget.statusBarHeight / screenHeight;

    widget.listController.animateToItem(
      index: nextIndex,
      scrollController: widget.scrollController,
      alignment: alignmentOffset,
      duration: (estimatedDistance) => const Duration(milliseconds: 450),
      curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
    );
  }

  void navigateToNextParent() {
    if (widget.comments == null) {
      // This is a placeholder to allow the previous post page to function correctly.
      // TODO: Remove this logic when we deprecate the legacy post page
      navigateDown();
      return;
    }

    var unobstructedVisibleRange = widget.listController.unobstructedVisibleRange;

    int nextIndex = (unobstructedVisibleRange?.$1 ?? 0) + 1;
    if (currentIndex == nextIndex) nextIndex++;

    int parentCommentIndex = 0;

    for (int i = nextIndex; i < widget.comments!.length; i++) {
      CommentNode currentComment = widget.comments![i - 1];

      List<String> pathSegments = currentComment.commentView!.comment.path.split('.');
      int depth = pathSegments.length > 2 ? pathSegments.length - 2 : 0;

      if (depth == 0) {
        parentCommentIndex = i;
        break;
      }
    }

    setState(() => currentIndex = parentCommentIndex);

    // Calculate alignment
    final double screenHeight = MediaQuery.of(context).size.height;
    final double alignmentOffset = widget.statusBarHeight / screenHeight;

    widget.listController.animateToItem(
      index: parentCommentIndex,
      scrollController: widget.scrollController,
      alignment: alignmentOffset,
      duration: (estimatedDistance) => const Duration(milliseconds: 450),
      curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
    );
  }
}
