import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/pages/create_post_page.dart';
import 'package:thunder/community/widgets/post_card_list.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

class Destination {
  const Destination(this.label, this.listingType, this.icon);

  final String label;
  final ListingType listingType;
  final IconData icon;
}

const List<Destination> destinations = <Destination>[
  Destination('Subscriptions', ListingType.Subscribed, Icons.view_list_rounded),
  Destination('Local Posts', ListingType.Local, Icons.home_rounded),
  Destination('All Posts', ListingType.All, Icons.grid_view_rounded),
];

class SortTypeItem {
  const SortTypeItem({required this.sortType, required this.icon, required this.label});

  final SortType sortType;
  final IconData icon;
  final String label;
}

const sortTypeItems = [
  SortTypeItem(
    sortType: SortType.Hot,
    icon: Icons.local_fire_department_rounded,
    label: 'Hot',
  ),
  SortTypeItem(
    sortType: SortType.Active,
    icon: Icons.rocket_launch_rounded,
    label: 'Active',
  ),
  SortTypeItem(
    sortType: SortType.New,
    icon: Icons.auto_awesome_rounded,
    label: 'New',
  ),
  SortTypeItem(
    sortType: SortType.Old,
    icon: Icons.history_toggle_off_rounded,
    label: 'Old',
  ),
  SortTypeItem(
    sortType: SortType.MostComments,
    icon: Icons.comment_bank_rounded,
    label: 'Most Comments',
  ),
  SortTypeItem(
    sortType: SortType.NewComments,
    icon: Icons.add_comment_rounded,
    label: 'New Comments',
  ),
];

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  SortType? sortType = SortType.Hot;
  IconData sortTypeIcon = Icons.local_fire_department_rounded;

  final ScrollController _scrollController = ScrollController();

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

    return BlocConsumer<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state.status == CommunityStatus.networkFailure) {
          SnackBar snackBar = SnackBar(
            content: Text(state.errorMessage ?? 'No error message available'),
            behavior: SnackBarBehavior.floating,
          );
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ScaffoldMessenger.of(context).showSnackBar(snackBar));
        }
      },
      builder: (context, state) {
        return BlocBuilder<CommunityBloc, CommunityState>(
          builder: (context, state) {
            bool isLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  state.communityId == null ? (destinations.firstWhere((destination) => destination.listingType == state.listingType).label) : (state.postViews?.first.community.name ?? ''),
                ),
                centerTitle: false,
                toolbarHeight: 70.0,
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(sortTypeIcon),
                        onPressed: () {
                          showModalBottomSheet<void>(
                            showDragHandle: true,
                            context: context,
                            builder: (BuildContext bottomSheetContext) {
                              return SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Sort Options',
                                          style: theme.textTheme.titleLarge!.copyWith(),
                                        ),
                                      ),
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: sortTypeItems.length,
                                      itemBuilder: (BuildContext itemBuilderContext, int index) {
                                        return ListTile(
                                          title: Text(
                                            sortTypeItems[index].label,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          leading: Icon(sortTypeItems[index].icon),
                                          onTap: () {
                                            setState(() {
                                              sortType = sortTypeItems[index].sortType;
                                              sortTypeIcon = sortTypeItems[index].icon;
                                            });

                                            context.read<CommunityBloc>().add(GetCommunityPostsEvent(sortType: sortTypeItems[index].sortType, reset: true));
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16.0),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 8.0),
                    ],
                  )
                ],
              ),
              drawer: Drawer(
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                        child: Text('Feeds', style: Theme.of(context).textTheme.titleSmall),
                      ),
                      Column(
                        children: destinations.map((Destination destination) {
                          return DrawerItem(
                            disabled: destination.listingType == ListingType.Subscribed && isLoggedIn == false,
                            onTap: () {
                              context.read<CommunityBloc>().add(GetCommunityPostsEvent(reset: true, listingType: destination.listingType));
                              Navigator.of(context).pop();
                            },
                            label: destination.label,
                            icon: destination.icon,
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                        child: Text('Subscriptions', style: Theme.of(context).textTheme.titleSmall),
                      ),
                      (context.read<AccountBloc>().state.subsciptions.isNotEmpty)
                          ? Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Scrollbar(
                                  controller: _scrollController,
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: context.read<AccountBloc>().state.subsciptions.length,
                                        itemBuilder: (context, index) {
                                          return TextButton(
                                            style: TextButton.styleFrom(
                                              alignment: Alignment.centerLeft,
                                              minimumSize: const Size.fromHeight(50),
                                            ),
                                            onPressed: () {
                                              context.read<CommunityBloc>().add(GetCommunityPostsEvent(reset: true, communityId: context.read<AccountBloc>().state.subsciptions[index].community.id));

                                              Navigator.of(context).pop();
                                            },
                                            child: Text(context.read<AccountBloc>().state.subsciptions[index].community.name),
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
                              child: Text(
                                'No subscriptions available',
                                style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor),
                              ),
                            )
                    ],
                  ),
                ),
              ),
              floatingActionButton: (state.communityId != null)
                  ? FloatingActionButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreatePostPage(communityId: state.communityId!)));
                      },
                      child: const Icon(Icons.add),
                    )
                  : null,
              body: SafeArea(child: _getBody(context, state)),
            );
          },
        );
      },
    );
  }

  Widget _getBody(BuildContext context, CommunityState state) {
    final theme = Theme.of(context);

    switch (state.status) {
      case CommunityStatus.initial:
        context.read<CommunityBloc>().add(const GetCommunityPostsEvent(reset: true));
        return const Center(child: CircularProgressIndicator());
      case CommunityStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case CommunityStatus.refreshing:
      case CommunityStatus.networkFailure:
      case CommunityStatus.success:
        return PostCardList(postViews: state.postViews);
      case CommunityStatus.empty:
      case CommunityStatus.failure:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 100,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 32.0),
                Text('Oops, something went wrong!', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8.0),
                Text(
                  state.errorMessage ?? 'No error message available',
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  onPressed: () => {context.read<CommunityBloc>().add(const GetCommunityPostsEvent(reset: true))},
                  child: const Text('Refresh Content'),
                ),
              ],
            ),
          ),
        );
    }
  }
}

class DrawerItem extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  final bool disabled;

  const DrawerItem({super.key, required this.onTap, required this.label, required this.icon, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        height: 56.0,
        child: InkWell(
          splashColor: disabled ? Colors.transparent : null,
          highlightColor: Colors.transparent,
          onTap: disabled ? null : onTap,
          customBorder: const StadiumBorder(),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const SizedBox(width: 16),
                  Icon(icon, color: disabled ? theme.dividerColor : null),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: disabled ? theme.textTheme.bodyMedium?.copyWith(color: theme.dividerColor) : null,
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
