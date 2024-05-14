import 'package:flutter/material.dart';

import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommentNavigatorFab extends StatefulWidget {
  /// The [ScrollController] for the scrollable list
  final ScrollController scrollController;

  /// The [ListController] for the scrollable list. This is used to navigate up and down
  final ListController listController;

  /// The initial index
  final int initialIndex;

  /// The maximum index that can be scrolled to
  final int maxIndex;

  const CommentNavigatorFab({
    super.key,
    this.initialIndex = 0,
    this.maxIndex = 0,
    required this.scrollController,
    required this.listController,
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
                      onTap: navigateUp,
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
                      onTap: navigateDown,
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
    if (currentIndex == 0) return;

    widget.listController.animateToItem(
      index: currentIndex - 1,
      scrollController: widget.scrollController,
      alignment: 0,
      duration: (estimatedDistance) => const Duration(milliseconds: 250),
      curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
    );

    setState(() {
      currentIndex = currentIndex - 1;
    });
  }

  void navigateDown() {
    if (currentIndex == widget.maxIndex) return;

    widget.listController.animateToItem(
      index: currentIndex + 1,
      scrollController: widget.scrollController,
      alignment: 0,
      duration: (estimatedDistance) => const Duration(milliseconds: 250),
      curve: (estimatedDistance) => Curves.easeInOutCubicEmphasized,
    );

    setState(() {
      currentIndex = currentIndex + 1;
    });
  }
}
