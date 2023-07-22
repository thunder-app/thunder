import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/core/singletons/preferences.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/account/bloc/account_bloc.dart' as account_bloc;
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/instance.dart';

import '../../community/pages/community_page.dart';
import '../../shared/common_markdown_body.dart';
import '../../thunder/bloc/thunder_bloc.dart';
import '../../utils/date_time.dart';
import '../bloc/user_bloc.dart';

class UserSidebar extends StatefulWidget {
  final PersonViewSafe? userInfo;
  final List<CommunityModeratorView>? moderates;
  final bool isAccountUser;
  final List<PersonBlockView>? personBlocks;
  final BlockedPerson? blockedPerson;

  const UserSidebar({
    super.key,
    required this.userInfo,
    required this.moderates,
    required this.isAccountUser,
    this.personBlocks,
    this.blockedPerson,
  });

  @override
  State<UserSidebar> createState() => _UserSidebarState();
}

class _UserSidebarState extends State<UserSidebar> {
  final ScrollController _scrollController = ScrollController();
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    //custom stats
    final totalContributions = (widget.userInfo!.counts.postCount + widget.userInfo!.counts.commentCount);
    final totalScore = (widget.userInfo!.counts.postScore + widget.userInfo!.counts.commentScore);
    Duration accountAge = DateTime.now().difference(widget.userInfo!.person.published);
    final accountAgeMonths = ((accountAge.inDays)/30).toDouble();
    final num postsPerMonth;
    final num commentsPerMonth;
    final totalContributionsPerMonth = (totalContributions/accountAgeMonths);
    final ThunderState state = context.watch<ThunderBloc>().state;
    bool _disableScoreCounters = state.disableScoreCounters;

    if (widget.userInfo!.counts.postCount != 0){
      postsPerMonth = (widget.userInfo!.counts.postCount/accountAgeMonths);
    } else {
      postsPerMonth = 0;
    }

    if ((widget.userInfo!.counts.commentCount).toInt() != 0){
      commentsPerMonth = (widget.userInfo!.counts.commentCount/accountAgeMonths);
    } else {
      commentsPerMonth = 0;
    }

    bool isLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
    String locale = Localizations.localeOf(context).languageCode;

/*    if ( widget.personBlocks !=  null ) {
      for (var user in widget.personBlocks! ) {
        if ( user.person.id == widget.userInfo!.person.id ){
          isBlocked = true;
        }
      }
    }*/

    if (widget.blockedPerson != null) {
      isBlocked = widget.blockedPerson!.blocked;
    }

    return Container(
      alignment: Alignment.topRight,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: theme.colorScheme.background,
            child: Column(
              children: [
                Container(
                  child: !widget.isAccountUser
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                left: 12,
                                right: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: null /*() {
                                  HapticFeedback.mediumImpact();
                                }*/
                                      ,
                                      style: TextButton.styleFrom(
                                        fixedSize: const Size.fromHeight(40),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.mail_outline_rounded,
                                            semanticLabel: 'Message User',
                                          ),
                                          SizedBox(width: 4.0),
                                          Text(
                                            'Message User',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                    height: 8,
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isLoggedIn
                                          ? () {
                                              HapticFeedback.heavyImpact();
                                              ScaffoldMessenger.of(context).clearSnackBars();
                                              context.read<UserBloc>().add(
                                                    BlockUserEvent(
                                                      personId: widget.userInfo!.person.id,
                                                      blocked: isBlocked == true ? false : true,
                                                    ),
                                                  );
                                            }
                                          : null,
                                      style: TextButton.styleFrom(
                                        fixedSize: const Size.fromHeight(40),
                                        foregroundColor: Colors.redAccent,
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isBlocked == true ? Icons.undo_rounded : Icons.block,
                                            semanticLabel: isBlocked == true ? 'Unblock User' : 'Block User',
                                          ),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            isBlocked == true ? 'Unblock User' : 'Block User',
                                            style: const TextStyle(
                                              color: null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                          ],
                        )
                      : null,
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5.0),
                            const Row(
                                children: [
                                  Text("Bio"),
                                  Expanded(
                                    child: Divider(
                                      height: 5,
                                      thickness: 2,
                                      indent: 15,
                                      endIndent: 15,
                                    ),),
                                ]
                            ),
                            const SizedBox(height: 5.0),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8,
                                bottom: 8,
                              ),
                              child: CommonMarkdownBody(
                                body: widget.userInfo?.person.bio ?? 'Nothing here. This user has not written a bio.',
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Row(
                                children: [
                                  Text("Stats"),
                                  Expanded(
                                    child: Divider(
                                      height: 5,
                                      thickness: 2,
                                      indent: 15,
                                      endIndent: 15,
                                    ),),
                                ]
                            ),
                            const SizedBox(height: 5.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 3.0),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                      child: Icon(
                                        Icons.cake_rounded,
                                        size: 18,
                                        color: theme.colorScheme.onBackground.withOpacity(0.65),
                                      ),
                                    ),
                                    // TODO Make this use device date format
                                    Text(
                                      'Joined ${DateFormat.yMMMMd().format(widget.userInfo!.person.published)} · ${formatTimeToString(dateTime: widget.userInfo!.person.published.toIso8601String())} ago',
                                      style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.65)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3.0),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                      child: Icon(
                                        Icons.wysiwyg_rounded,
                                        size: 18,
                                        color: theme.colorScheme.onBackground.withOpacity(0.65),
                                      ),
                                    ),
                                    Text(
                                      '${NumberFormat("#,###,###,###").format(widget.userInfo!.counts.postCount)} Posts · ${NumberFormat("#,###,###,###").format(widget.userInfo!.counts.postScore)} score',
                                      style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3.0),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                      child: Icon(
                                        Icons.chat_rounded,
                                        size: 18,
                                        color: theme.colorScheme.onBackground.withOpacity(0.65),
                                      ),
                                    ),
                                      Text('${NumberFormat("#,###,###,###").format(widget.userInfo!.counts.commentCount)} Comments ', style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),),
                                      Visibility(
                                        visible: _disableScoreCounters == false,
                                          child: Text('${NumberFormat("#,###,###,###").format(widget.userInfo!.counts.commentScore)} score', style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),),
                                      ),
                                      ],
                                ),
                                const SizedBox(height: 3.0),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                      child: Icon(
                                        Icons.celebration_rounded,
                                        size: 18,
                                        color: theme.colorScheme.onBackground.withOpacity(0.65),
                                      ),
                                    ),
                                    Text(
                                      '${NumberFormat("#,###,###,###").format(totalContributions)} Total · ${NumberFormat("#,###,###,###").format(totalScore)} total score', style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            const Row(
                                children: [
                                  Text("Activity"),
                                  Expanded(
                                    child: Divider(
                                      height: 5,
                                      thickness: 2,
                                      indent: 15,
                                      endIndent: 15,
                                    ),),
                                ]
                            ),

                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                  child: Icon(
                                    Icons.wysiwyg_rounded,
                                    size: 18,
                                    color: theme.colorScheme.onBackground.withOpacity(0.65),
                                  ),
                                ),
                                Text(
                                  '${NumberFormat("#,###,###,###").format(postsPerMonth)} Total Posts/mo', style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3.0),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                  child: Icon(
                                    Icons.chat_rounded,
                                    size: 18,
                                    color: theme.colorScheme.onBackground.withOpacity(0.65),
                                  ),
                                ),
                                Text(
                                  '${NumberFormat("#,###,###,###").format(commentsPerMonth)} Total Comments/mo', style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3.0),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                  child: Icon(
                                    Icons.score_rounded,
                                    size: 18,
                                    color: theme.colorScheme.onBackground.withOpacity(0.65),
                                  ),
                                ),
                                Text(
                                  '${NumberFormat("#,###,###,###").format(totalContributionsPerMonth)} Total Contributions/mo', style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40.0),
                            Container(
                              child: widget.moderates!.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Moderates:'),
                                        const Divider(),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Column(
                                            children: [
                                              for (var mods in widget.moderates!)
                                                GestureDetector(
                                                  onTap: () {
                                                    account_bloc.AccountBloc accountBloc = context.read<account_bloc.AccountBloc>();
                                                    AuthBloc authBloc = context.read<AuthBloc>();
                                                    ThunderBloc thunderBloc = context.read<ThunderBloc>();

                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) => MultiBlocProvider(
                                                          providers: [
                                                            BlocProvider.value(value: accountBloc),
                                                            BlocProvider.value(value: authBloc),
                                                            BlocProvider.value(value: thunderBloc),
                                                          ],
                                                          child: CommunityPage(communityId: mods.community.id),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(bottom: 8.0),
                                                    child: Row(
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundColor: mods.community.icon != null ? Colors.transparent : theme.colorScheme.secondaryContainer,
                                                          foregroundImage: mods.community.icon != null ? CachedNetworkImageProvider(mods.community.icon!) : null,
                                                          maxRadius: 20,
                                                          child: Text(
                                                            mods.community.name[0].toUpperCase() ?? '',
                                                            semanticsLabel: '',
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 16.0),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                mods.community.title ?? mods.community.name ?? '',
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${mods.community.name ?? ''} · ${fetchInstanceNameFromUrl(mods.community.actorId)}',
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 128,
                      )
                    ],
                  ),
                ),
                Container(
                  child: widget.isAccountUser
                      ? Column(
                          children: [
                            const Divider(
                              height: 5,
                              thickness: 2,
                              indent: 15,
                              endIndent: 15,
                            ),
                            const SizedBox(height: 10.0),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0, left: 12, right: 12),
                              child: ElevatedButton(
                                onPressed: null /*() {
                            HapticFeedback.mediumImpact();
                          }*/
                                ,
                                style: TextButton.styleFrom(
                                  fixedSize: const Size.fromHeight(40),
                                  foregroundColor: null,
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      semanticLabel: 'Edit Profile',
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        color: null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
