import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:thunder/utils/colors.dart';

/// Represents a chip widget to display some metadata about a post/comment
/// Most likely you should pass a [PostCardMetaData] widget as the child (for reuse)
class MetadataChip extends StatelessWidget {
  final Widget child;

  const MetadataChip({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: Container(
          decoration: BoxDecoration(
            color: getBackgroundColor(context).darken(10),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
