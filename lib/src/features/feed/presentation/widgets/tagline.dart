import 'dart:math';

import 'package:flutter/material.dart';

import 'package:expandable/expandable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/shared/theme/color_utils.dart';

/// Displays a random tagline from the site whenever the feed is refreshed.
class TagLine extends StatefulWidget {
  const TagLine({super.key});

  @override
  State<TagLine> createState() => _TagLineState();
}

class _TagLineState extends State<TagLine> {
  final taglineBodyKey = GlobalKey();

  /// The tagline to display.
  String? tagline;

  /// Whether the tagline is long enough to be truncated.
  bool taglineIsLong = true;

  @override
  void initState() {
    super.initState();

    final taglines = context.read<ProfileBloc>().state.siteResponse?.taglines;
    if (taglines == null || taglines.isEmpty) return;

    if (taglines.length == 1) {
      tagline = taglines[0].content;
    } else {
      tagline = taglines[Random().nextInt(taglines.length - 1)].content;
    }

    // Check if the tagline is long enough to be truncated after the first frame is rendered.
    // This is necessary because the size of the text is not available until after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => taglineIsLong = (taglineBodyKey.currentContext?.size?.height ?? 0) > 80);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final showExpandedTaglines = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.showExpandedTaglines);

    if (tagline == null || tagline?.isEmpty == true) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(color: getBackgroundColor(context), borderRadius: const BorderRadius.all(Radius.elliptical(5.0, 5.0))),
      child: AnimatedCrossFade(
        crossFadeState: taglineIsLong ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 250),
        sizeCurve: Curves.easeInOutCubicEmphasized,
        firstChild: CommonMarkdownBody(key: taglineBodyKey, body: tagline!),
        secondChild: ExpandableNotifier(
          initialExpanded: showExpandedTaglines,
          child: Expandable(
            collapsed: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    LimitedBox(
                      maxHeight: 60,
                      // Note: This Wrap is critical to prevent the LimitedBox from having a render overflow
                      child: Wrap(children: [CommonMarkdownBody(body: tagline!)]),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.5, 1.0],
                            colors: [getBackgroundColor(context).withValues(alpha: 0.0), getBackgroundColor(context), getBackgroundColor(context)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: ExpandableButton(
                        theme: const ExpandableThemeData(useInkWell: false),
                        child: Text(l10n.showMore, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            expanded: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CommonMarkdownBody(body: tagline!),
                ExpandableButton(
                  theme: const ExpandableThemeData(useInkWell: false),
                  child: Text(l10n.showLess, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
