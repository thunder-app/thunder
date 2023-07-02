import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/utils/instance.dart';

import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class AccountHeader extends StatelessWidget {

  final PersonViewSafe? accountInfo;

  const AccountHeader({super.key, this.accountInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(accountInfo!.person.published);

    final bool profileSettings = context.read<ThunderBloc>().state.preferences?.getBool('setting_general_hide_profile_score') ?? true;
    final totalScore = accountInfo!.counts.commentScore + accountInfo!.counts.postScore;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 24.0, right: 24.0, bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: accountInfo?.person.avatar != null ? Colors.transparent : theme.colorScheme.onBackground,
                foregroundImage: accountInfo?.person.avatar != null ? CachedNetworkImageProvider(accountInfo!.person.avatar!) : null,
                maxRadius: 45,
              ),
              const SizedBox(width: 20.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    accountInfo?.person.displayName ?? accountInfo!.person.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    fetchInstanceNameFromUrl(accountInfo?.person.actorId) ?? 'N/A',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      IconText(
                        icon: const Icon(
                          Icons.cake,
                          size: 16.0,
                        ),
                        text: (accountInfo?.person.published != null) ? '${formatted}' : '-',
                      ),
                    ],
                  ),
                  Row(
                    children: [
                    if (profileSettings == false)(
                      IconText(
                          icon: const Icon(
                            Icons.arrow_upward_rounded,
                            size: 16,
                          ),
                          text: '${(accountInfo?.counts.postScore).toString()} · ${(accountInfo?.counts.commentScore).toString()} · ${(totalScore).toString()}')
                  )else if (profileSettings == true)(
                        IconText(
                          icon: const Icon(
                            Icons.note_rounded,
                            size:16,
                          ),
                          text: '${(accountInfo?.counts.postCount).toString()} · ${(accountInfo?.counts.commentCount)}'
                        )
                      )
                    ]
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
