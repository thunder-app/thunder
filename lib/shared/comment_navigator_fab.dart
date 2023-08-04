import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommentNavigatorFab extends StatefulWidget {
  final ItemPositionsListener itemPositionsListener;

  const CommentNavigatorFab({
    super.key,
    required this.itemPositionsListener,
  });

  @override
  State<CommentNavigatorFab> createState() => _CommentNavigatorFabState();
}

class _CommentNavigatorFabState extends State<CommentNavigatorFab> {
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
    int? currentIndex = widget.itemPositionsListener.itemPositions.value.firstWhereOrNull((item) => item.itemLeadingEdge < 0.0)?.index;

    if (currentIndex != null) {
      currentIndex;
    } else {
      currentIndex = widget.itemPositionsListener.itemPositions.value.firstWhereOrNull((item) => item.itemLeadingEdge <= 0.0)?.index;
      if (currentIndex != null) {
        currentIndex -= 1;
      }
    }

    if (currentIndex != null) {
      context.read<PostBloc>().add(NavigateCommentEvent(targetIndex: currentIndex, direction: NavigateCommentDirection.up));
    }
  }

  void navigateDown() {
    final int? currentIndex = widget.itemPositionsListener.itemPositions.value.lastWhereOrNull((item) => item.itemLeadingEdge <= 0.01)?.index;
    if (currentIndex != null) {
      context.read<PostBloc>().add(NavigateCommentEvent(targetIndex: currentIndex + 1, direction: NavigateCommentDirection.down));
    }
  }
}
