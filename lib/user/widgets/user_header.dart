import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:path/path.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/account/models/account.dart';

import 'package:thunder/shared/icon_text.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/numbers.dart';

class UserHeader extends StatelessWidget {

  final PersonViewSafe? userInfo;

  const UserHeader({super.key, this.userInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(userInfo!.person.published);
    final totalScore = (userInfo?.counts.postScore)! + (userInfo!.counts.commentScore);
    final totalContributions = (userInfo?.counts.postCount)! + (userInfo!.counts.commentCount);

    Duration accountAge = DateTime.now().difference(userInfo!.person.published);
    String accountAgeDays = (accountAge.inDays).toString();

    return Container(
      decoration: userInfo?.person.banner != null ? BoxDecoration(
        image: DecorationImage(
            image: CachedNetworkImageProvider(userInfo!.person.banner!),
            fit: BoxFit.cover
        ),
      ) : null,
      child: Container(
        decoration: userInfo?.person.banner != null ? BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.background,
              theme.colorScheme.background.withOpacity(0.85),
              theme.colorScheme.background.withOpacity(0.4),
              Colors.transparent,
            ],
          ),
        ) : null,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 24.0, right: 24.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: userInfo?.person.avatar != null ? Colors.transparent : theme.colorScheme.onBackground,
                    foregroundImage: userInfo?.person.avatar != null ? CachedNetworkImageProvider(userInfo!.person.avatar!) : null,
                    maxRadius: 45,
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                        children: [
                          Text(
                            userInfo?.person.displayName != null ? userInfo?.person.displayName ?? '-' : userInfo?.person.name ?? '-',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                showDragHandle: true,
                                context: context,
                                builder: (context) {
                                  return SizedBox(
                                    height: 375,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    const Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.wysiwyg_rounded),
                                                          Text(' Post Count:', style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),),
                                                        ]
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(formatNumberToK(userInfo!.counts.postCount), style: const TextStyle(fontSize: 15),),
                                                    const SizedBox(height: 18),
                                                    const Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.chat_rounded),
                                                        Text(' Comment Count:', style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(formatNumberToK(userInfo!.counts.commentCount), style: const TextStyle(fontSize: 15),),
                                                    const SizedBox(height: 18),
                                                    const Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.create_rounded),
                                                        Text(' Total Count:', style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(formatNumberToK(totalContributions), style: const TextStyle(fontSize: 15),),
                                                    const SizedBox(height: 18),
                                                    const Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.calendar_month_rounded),
                                                        Text(' Account Age:', style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text( '${(accountAgeDays)} days', style: const TextStyle(fontSize: 15),),
                                                    const SizedBox(height: 18),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    const Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.wysiwyg_rounded),
                                                          Text(' Post Score:', style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),),
                                                        ]
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(formatNumberToK(userInfo!.counts.postScore), style: const TextStyle(fontSize: 15),),
                                                    const SizedBox(height: 18),
                                                    const Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.chat_rounded),
                                                        Text(' Comment Score:', style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(formatNumberToK(userInfo!.counts.commentScore), style: const TextStyle(fontSize: 15),),
                                                    const SizedBox(height: 18),
                                                    const Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.score_rounded),
                                                        Text(' Total Score:', style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(formatNumberToK(totalScore), style: const TextStyle(fontSize: 15),),
                                                    const SizedBox(height: 18),
                                                    const Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.cake_rounded),
                                                        Text(' Cake Day:', style: TextStyle(fontSize: 16 , fontWeight: FontWeight.bold),),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(formatted, style: const TextStyle(fontSize: 15),),
                                                    const SizedBox(height: 18),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                  ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.info_rounded),
                          )
                        ]
                        ),
                        Text(
                          '${userInfo?.person.name ?? '-'}@${fetchInstanceNameFromUrl(userInfo?.person.actorId) ?? '-'}',
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                             IconText(
                               icon: const Icon(Icons.wysiwyg_rounded,
                                 size: 18.0,
                               ),
                               text: formatNumberToK(userInfo?.counts.postCount ?? 0),
                             ),
                             const SizedBox(width: 8.0),
                             IconText(
                               icon: const Icon(Icons.chat_rounded,
                                 size:  18.0,
                               ),
                               text: formatNumberToK(userInfo?.counts.commentCount ?? 0),
                             ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
