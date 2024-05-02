import 'dart:io';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/search/widgets/search_action_chip.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

void showSelectableTextModal(BuildContext context, {String? title, required String text}) {
  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final ThemeData theme = Theme.of(context);
  final ThunderState thunderState = context.read<ThunderBloc>().state;

  final ScrollController textScrollController = ScrollController();
  final ScrollController actionsScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final GlobalKey selectableRegionKey = GlobalKey();

  bool isAnythingSelected = false;

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      bool viewSource = false;
      bool copySuccess = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return FractionallySizedBox(
            heightFactor: 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                FadingEdgeScrollView.fromSingleChildScrollView(
                  gradientFractionOnStart: 0.1,
                  gradientFractionOnEnd: 0.1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: actionsScrollController,
                    child: Row(
                      children: [
                        const SizedBox(width: 26),
                        SearchActionChip(
                          onPressed: () => setState(() => viewSource = !viewSource),
                          backgroundColor: viewSource ? theme.colorScheme.primaryContainer.withOpacity(0.25) : null,
                          children: [
                            Text(l10n.viewSource),
                            if (viewSource) ...[
                              const SizedBox(width: 5),
                              const Icon(Icons.close_rounded, size: 15),
                            ],
                          ],
                        ),
                        const SizedBox(width: 10),
                        SearchActionChip(
                          children: [Text(l10n.selectAll)],
                          onPressed: () {},
                        ),
                        const SizedBox(width: 10),
                        SearchActionChip(
                          onPressed: isAnythingSelected
                              ? () async {
                                  setState(() => copySuccess = true);
                                  await Future.delayed(const Duration(seconds: 2));
                                  setState(() => copySuccess = false);
                                }
                              : null,
                          backgroundColor: copySuccess ? theme.colorScheme.primaryContainer.withOpacity(0.25) : null,
                          children: [
                            Text(l10n.copySelected),
                            if (copySuccess) ...[
                              const SizedBox(width: 5),
                              const Icon(Icons.check_rounded, size: 15),
                            ],
                          ],
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 26.0, right: 16.0),
                    child: FadingEdgeScrollView.fromSingleChildScrollView(
                      gradientFractionOnStart: 0.1,
                      gradientFractionOnEnd: 0.1,
                      child: SingleChildScrollView(
                        controller: textScrollController,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SelectableRegion(
                              onSelectionChanged: (value) {
                                setState(() => isAnythingSelected = value != null);
                              },
                              key: selectableRegionKey,
                              focusNode: focusNode,
                              // Note: material/cupertinoTextSelectionHandleControls will be deprecated eventually,
                              // but is still required in order to also use contextMenuBuilder.
                              // See https://github.com/flutter/flutter/issues/122421 for more info.
                              selectionControls: Platform.isIOS ? cupertinoTextSelectionHandleControls : materialTextSelectionHandleControls,
                              contextMenuBuilder: (context, selectableRegionState) {
                                // While this isn't strictly needed right now, it's here so that when we upgrade the Flutter version, we'll get "Share" for free.
                                // This comment canbe deleted at that time.
                                return AdaptiveTextSelectionToolbar.buttonItems(
                                  buttonItems: selectableRegionState.contextMenuButtonItems,
                                  anchors: selectableRegionState.contextMenuAnchors,
                                );
                              },
                              child: Column(
                                children: [
                                  if (title?.isNotEmpty == true) ...[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        HtmlUnescape().convert(title!),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: MediaQuery.textScalerOf(context).scale(theme.textTheme.bodyMedium!.fontSize! * thunderState.titleFontSizeScale.textScaleFactor),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: viewSource
                                        ? ScalableText(
                                            text,
                                            style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                                            fontScale: thunderState.contentFontSizeScale,
                                          )
                                        : CommonMarkdownBody(
                                            body: text,
                                            isComment: true,
                                          ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 26.0, right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.close),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          );
        },
      );
    },
  );
}
