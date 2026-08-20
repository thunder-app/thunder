import 'package:flutter/material.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/theme/color_utils.dart';

/// Chat bubble for one private message in a direct-message thread.
class PrivateMessageBubble extends StatefulWidget {
  /// Creates a bubble aligned based on whether the message was sent by [account].
  const PrivateMessageBubble({super.key, required this.account, required this.message});

  /// Account viewing the thread.
  final Account account;

  /// Private message to render.
  final ThunderPrivateMessage message;

  @override
  State<PrivateMessageBubble> createState() => _PrivateMessageBubbleState();
}

class _PrivateMessageBubbleState extends State<PrivateMessageBubble> {
  bool showFullDate = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final outgoing = widget.message.creatorId == widget.account.userId || widget.message.creator?.actorId == widget.account.actorId;
    final color = outgoing ? theme.colorScheme.primaryContainer : getBackgroundColor(context);
    final alignment = outgoing ? Alignment.centerRight : Alignment.centerLeft;
    final textColor = outgoing ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Column(
          crossAxisAlignment: outgoing ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Card(
              color: color,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: textColor),
                  child: CommonMarkdownBody(body: widget.message.content, isComment: true),
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => showFullDate = !showFullDate);
              },
              child: Text(
                showFullDate
                    ? '${MaterialLocalizations.of(context).formatMediumDate(widget.message.published)} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(widget.message.published))}'
                    : MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(widget.message.published)),
                style: theme.textTheme.labelSmall?.copyWith(color: textColor.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
