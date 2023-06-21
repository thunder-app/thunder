import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy/lemmy.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
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

class CommunityDrawer extends StatefulWidget {
  const CommunityDrawer({super.key});

  @override
  State<CommunityDrawer> createState() => _CommunityDrawerState();
}

class _CommunityDrawerState extends State<CommunityDrawer> {
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
    bool isLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    return Drawer(
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
<<<<<<< HEAD
                    context.read<CommunityBloc>().add(GetCommunityPostsEvent(reset: true, listingType: destination.listingType));
=======
                    context.read<CommunityBloc>().add(GetCommunityPostsEvent(
                          reset: true,
                          listingType: destination.listingType,
                          communityId: null,
                        ));
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
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
                                    context.read<CommunityBloc>().add(
                                          GetCommunityPostsEvent(
                                            reset: true,
                                            communityId: context.read<AccountBloc>().state.subsciptions[index].community.id,
                                          ),
                                        );

                                    Navigator.of(context).pop();
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.read<AccountBloc>().state.subsciptions[index].community.title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        context.read<AccountBloc>().state.subsciptions[index].community.name,
                                        style: theme.textTheme.bodyMedium,
                                      )
                                    ],
                                  ),
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
    );
  }
}
