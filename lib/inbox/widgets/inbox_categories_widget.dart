import 'package:flutter/material.dart';
import 'package:thunder/inbox/inbox.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InboxCategory {
  final InboxType type;
  final String title;
  final IconData icon;

  InboxCategory({required this.type, required this.title, required this.icon});
}

class InboxCategoryWidget extends StatelessWidget {
  const InboxCategoryWidget({
    super.key,
    required this.onSelected,
    required this.inboxType,
    required this.unreadCounts,
  });
  final ValueChanged<InboxType?> onSelected;
  final InboxType? inboxType;
  final Map<InboxType, int> unreadCounts;

  @override
  Widget build(BuildContext context) {
    List<InboxCategory> inboxCategories = [
      InboxCategory(
        type: InboxType.replies,
        title: AppLocalizations.of(context)!.reply(10),
        icon: Icons.comment_bank_rounded,
      ),
      InboxCategory(
        type: InboxType.mentions,
        title: AppLocalizations.of(context)!.mention(10),
        icon: Icons.comment_bank_rounded,
      ),
      InboxCategory(
        type: InboxType.messages,
        title: AppLocalizations.of(context)!.message(10),
        icon: Icons.message_rounded,
      ),
    ];
    return Wrap(
      spacing: 5.0,
      children: inboxCategories.map((InboxCategory inboxCategory) {
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(inboxCategory.title),
              if ((unreadCounts[inboxCategory.type] ?? 0) > 0) ...[
                const SizedBox(width: 5),
                Badge(label: Text((unreadCounts[inboxCategory.type] ?? 0) > 99 ? '99+' : unreadCounts[inboxCategory.type]?.toString() ?? '')),
              ],
            ],
          ),
          selected: inboxType == inboxCategory.type,
          onSelected: (selected) => onSelected(inboxCategory.type),
        );
      }).toList(),
    );
  }
}
