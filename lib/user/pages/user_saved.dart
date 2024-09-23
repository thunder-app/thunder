import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:thunder/user/bloc/user_bloc_old.dart';
import 'package:thunder/user/pages/user_page_new.dart';

class UserSavedPage extends StatefulWidget {
  const UserSavedPage({super.key, this.userId, this.isAccountUser});
  final int? userId;
  final bool? isAccountUser;
  @override
  State<UserSavedPage> createState() => _UserSavedPageState();
}

class _UserSavedPageState extends State<UserSavedPage> with SingleTickerProviderStateMixin {
  /// The controller for the tab bar used for switching between inbox types.
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    context.read<UserBloc>().add(GetUserSavedEvent(
          userId: widget.userId,
          isAccountUser: widget.isAccountUser ?? false,
          reset: true,
        ));
    final userState = context.read<UserBloc>().state;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                pinned: true,
                centerTitle: false,
                toolbarHeight: 70.0,
                forceElevated: innerBoxIsScrolled,
                title: Text(l10n.saved),
                bottom: TabBar(
                  controller: tabController,
                  onTap: (index) {
                    // context.read<InboxBloc>().add(GetInboxEvent(inboxType: inboxType, reset: true, showAll: showAll));
                  },
                  tabs: [
                    Tab(
                      child: Wrap(
                        spacing: 4.0,
                        children: [
                          Text(l10n.posts),
                        ],
                      ),
                    ),
                    Tab(
                      child: Wrap(
                        spacing: 4.0,
                        children: [
                          Text(l10n.comments),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            PostCardTab(
              postViews: userState.savedPosts,
              userId: userState.userId,
              hasReachedSavedPostEnd: false,
              isAccountUser: widget.isAccountUser!,
              hasReachedPostEnd: false,
            ),
            CommentsCardTab(
              isAccountUser: widget.isAccountUser!,
              commentViewTrees: userState.savedComments,
              userId: userState.userId,
              hasReachedCommentsEnd: false,
            ),
          ],
        ),
      ),
    );
  }
}
