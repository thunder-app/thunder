import 'package:flutter/material.dart';

import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/avatars/community_avatar.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';
import 'package:thunder/src/shared/input_dialogs.dart';

class CommunitySelector extends StatelessWidget {
  const CommunitySelector({
    super.key,
    required this.account,
    this.community,
    required this.onCommunitySelected,
  });

  /// The account of the user creating the post, used to fetch the list of communities they can post in.
  final Account account;

  /// The currently selected community for the post, if any, used to display the selected community and its avatar.
  final ThunderCommunity? community;

  /// Callback function to be called when the user selects a community from the input dialog.
  final ValueChanged<ThunderCommunity> onCommunitySelected;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    return Transform.translate(
      offset: const Offset(-8, 0),
      child: InkWell(
        onTap: () {
          showCommunityInputDialog(
            context,
            title: l10n.community,
            account: account,
            onCommunitySelected: onCommunitySelected,
          );
        },
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 12.0,
                children: [
                  if (community != null) CommunityAvatar(community: community!, radius: 16.0),
                  community != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${community!.title} '),
                            CommunityFullNameWidget(
                              name: community!.name,
                              displayName: community!.title,
                              instance: fetchInstanceNameFromUrl(community!.actorId),
                              useDisplayName: false,
                            ),
                          ],
                        )
                      : SizedBox(
                          height: 39.0,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.selectCommunity,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
