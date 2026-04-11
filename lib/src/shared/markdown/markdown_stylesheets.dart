import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

/// Returns a [MarkdownStyleSheet] for a spoiler.
///
/// This config is used to hide the contents of the spoiler.
MarkdownStyleSheet getSpoilerStyleSheet(BuildContext context) {
  final theme = Theme.of(context);

  return MarkdownStyleSheet(
    a: const TextStyle(color: Colors.transparent),
    p: theme.textTheme.bodyMedium!.copyWith(color: Colors.transparent),
    pPadding: EdgeInsets.zero,
    code: theme.textTheme.bodyMedium!.copyWith(
      backgroundColor: Colors.transparent,
      fontFamily: 'monospace',
      fontSize: theme.textTheme.bodyMedium!.fontSize! * 0.85,
      color: Colors.transparent,
    ),
    h1: theme.textTheme.headlineSmall!.copyWith(color: Colors.transparent),
    h1Padding: EdgeInsets.zero,
    h2: theme.textTheme.titleLarge!.copyWith(color: Colors.transparent),
    h2Padding: EdgeInsets.zero,
    h3: theme.textTheme.titleMedium!.copyWith(color: Colors.transparent),
    h3Padding: EdgeInsets.zero,
    h4: theme.textTheme.bodyLarge!.copyWith(color: Colors.transparent),
    h4Padding: EdgeInsets.zero,
    h5: theme.textTheme.bodyLarge!.copyWith(color: Colors.transparent),
    h5Padding: EdgeInsets.zero,
    h6: theme.textTheme.bodyLarge!.copyWith(color: Colors.transparent),
    h6Padding: EdgeInsets.zero,
    em: const TextStyle(fontStyle: FontStyle.italic, color: Colors.transparent),
    strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.transparent),
    del: const TextStyle(decoration: TextDecoration.none, color: Colors.transparent),
    blockquote: theme.textTheme.bodyMedium!.copyWith(color: Colors.transparent),
    img: theme.textTheme.bodyMedium!.copyWith(color: Colors.transparent),
    checkbox: theme.textTheme.bodyMedium!.copyWith(color: Colors.transparent),
    blockSpacing: 8.0,
    listIndent: 24.0,
    listBullet: theme.textTheme.bodyMedium!.copyWith(color: Colors.transparent),
    listBulletPadding: const EdgeInsets.only(right: 4),
    tableHead: const TextStyle(fontWeight: FontWeight.w600, color: Colors.transparent),
    tableBody: theme.textTheme.bodyMedium?.copyWith(color: Colors.transparent),
    tableHeadAlign: TextAlign.center,
    tableBorder: TableBorder.all(color: Colors.transparent),
    tableColumnWidth: const FlexColumnWidth(),
    tableCellsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    tableCellsDecoration: const BoxDecoration(color: Colors.transparent),
    blockquotePadding: const EdgeInsets.all(8.0),
    blockquoteDecoration: const BoxDecoration(
      color: Colors.transparent,
      border: Border(left: BorderSide(color: Colors.transparent, width: 4)),
    ),
    codeblockPadding: const EdgeInsets.all(8.0),
    codeblockDecoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(2.0),
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(width: theme.textTheme.bodyMedium!.fontSize!, color: Colors.transparent)),
    ),
  );
}

/// Returns a [MarkdownStyleSheet] for a normal markdown body.
MarkdownStyleSheet getNormalStyleSheet(BuildContext context) {
  final theme = Theme.of(context);
  final surface = theme.colorScheme.surfaceContainerHighest;

  return MarkdownStyleSheet.fromTheme(theme).copyWith(
    blockquoteDecoration: BoxDecoration(
      color: surface,
      border: Border(left: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.75), width: 4)),
      borderRadius: BorderRadius.circular(5),
    ),
    codeblockDecoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(10)),
    code: theme.textTheme.bodyMedium?.copyWith(
      backgroundColor: surface,
      fontFamily: 'monospace',
      fontSize: theme.textTheme.bodyMedium!.fontSize! * 0.85,
    ),
    tableBorder: TableBorder.all(
      color: Colors.grey,
      width: 1,
      borderRadius: const BorderRadius.all(Radius.circular(5)),
    ),
    horizontalRuleDecoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      border: Border(
        top: BorderSide(
          width: 3,
          color: theme.colorScheme.primary.withValues(alpha: 0.75),
        ),
      ),
    ),
  );
}
