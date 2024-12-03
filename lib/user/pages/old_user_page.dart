// import 'dart:io';

// import 'package:flutter/material.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:swipeable_page_route/swipeable_page_route.dart';

// import 'package:thunder/account/bloc/account_bloc.dart';
// import 'package:thunder/account/utils/profiles.dart';
// import 'package:thunder/core/singletons/lemmy_client.dart';
// import 'package:thunder/shared/primitive_wrapper.dart';
// import 'package:thunder/shared/snackbar.dart';
// import 'package:thunder/thunder/bloc/thunder_bloc.dart';
// import 'package:thunder/user/bloc/user_settings_bloc.dart';
// import 'package:thunder/user/pages/user_page_new.dart';
// import 'package:thunder/user/pages/user_page_success.dart';
// import 'package:thunder/shared/error_message.dart';
// import 'package:thunder/user/bloc/user_bloc_old.dart';
// import 'package:thunder/user/pages/user_settings_page.dart';

// class UserPage extends StatefulWidget {
//   final int? userId;
//   final bool isAccountUser;
//   final String? username;
//   final List<bool>? selectedUserOption;
//   final PrimitiveWrapper<bool>? savedToggle;

//   const UserPage({
//     super.key,
//     this.userId,
//     this.isAccountUser = false,
//     this.username,
//     this.selectedUserOption,
//     this.savedToggle,
//   });

//   @override
//   State<UserPage> createState() => _UserPageState();
// }

// class _UserPageState extends State<UserPage> {
//   UserBloc? userBloc;
//   String? userActorId;

//   @override
//   Widget build(BuildContext context) {
//     final ThunderState state = context.read<ThunderBloc>().state;
//     final bool reduceAnimations = state.reduceAnimations;

//     return BlocProvider<UserBloc>(
//       create: (BuildContext context) => UserBloc(lemmyClient: LemmyClient.instance),
//       child: BlocListener<UserBloc, UserState>(
//         listener: (context, state) {
//           if (userActorId == null && state.personView?.person.actorId != null) {
//             setState(() => userActorId = state.personView!.person.actorId);
//           }
//         },
//         child: Scaffold(
//           // appBar: AppBar(
//           //   scrolledUnderElevation: 0,
//           //   leading: widget.isAccountUser
//           //       ? Padding(
//           //           padding: const EdgeInsets.fromLTRB(0.0, 4.0, 4.0, 4.0),
//           //           child: IconButton(
//           //             onPressed: () => showProfileModalSheet(context),
//           //             icon: Icon(
//           //               Icons.people_alt_rounded,
//           //               semanticLabel: AppLocalizations.of(context)!.profiles,
//           //             ),
//           //             tooltip: AppLocalizations.of(context)!.profiles,
//           //           ),
//           //         )
//           //       : null,
//           //   actions: [
//           //     Padding(
//           //       padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
//           //       child: IconButton(
//           //         onPressed: () => userBloc?.add(ResetUserEvent()),
//           //         icon: Icon(
//           //           Icons.refresh_rounded,
//           //           semanticLabel: AppLocalizations.of(context)!.refresh,
//           //         ),
//           //         tooltip: AppLocalizations.of(context)!.refresh,
//           //       ),
//           //     ),
//           //     if (!widget.isAccountUser && userActorId != null)
//           //       Padding(
//           //         padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
//           //         child: IconButton(
//           //           onPressed: () => Share.share(userActorId!),
//           //           icon: Icon(
//           //             Icons.share_rounded,
//           //             semanticLabel: AppLocalizations.of(context)!.share,
//           //           ),
//           //           tooltip: AppLocalizations.of(context)!.share,
//           //         ),
//           //       ),
//           //     if (widget.userId != null && widget.isAccountUser)
//           //       Padding(
//           //         padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0, 4.0),
//           //         child: IconButton(
//           //           onPressed: () {
//           //             final AccountBloc accountBloc = context.read<AccountBloc>();
//           //             final ThunderBloc thunderBloc = context.read<ThunderBloc>();
//           //             final UserSettingsBloc userSettingsBloc = UserSettingsBloc();

//           //             Navigator.of(context).push(
//           //               SwipeablePageRoute(
//           //                 transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
//           //                 canSwipe: Platform.isIOS || state.enableFullScreenSwipeNavigationGesture,
//           //                 canOnlySwipeFromEdge: !state.enableFullScreenSwipeNavigationGesture,
//           //                 builder: (context) => MultiBlocProvider(
//           //                   providers: [
//           //                     BlocProvider.value(value: accountBloc),
//           //                     BlocProvider.value(value: thunderBloc),
//           //                     BlocProvider.value(value: userSettingsBloc),
//           //                   ],
//           //                   child: const UserSettingsPage(),
//           //                 ),
//           //               ),
//           //             );
//           //           },
//           //           icon: Icon(
//           //             Icons.settings_rounded,
//           //             semanticLabel: AppLocalizations.of(context)!.accountSettings,
//           //           ),
//           //           tooltip: AppLocalizations.of(context)!.accountSettings,
//           //         ),
//           //       ),
//           //   ],
//           // ),
//           body: BlocBuilder<UserBloc, UserState>(builder: (context, state) {
//             userBloc = context.read<UserBloc>();

//             if (state.status == UserStatus.failedToBlock) {
//               showSnackbar(state.errorMessage ?? AppLocalizations.of(context)!.missingErrorMessage);
//             }

//             switch (state.status) {
//               case UserStatus.initial:
//                 context.read<UserBloc>().add(GetUserEvent(userId: widget.userId, isAccountUser: widget.isAccountUser, username: widget.username, reset: true));
//                 return const Center(child: CircularProgressIndicator());
//               case UserStatus.loading:
//                 return const Center(child: CircularProgressIndicator());
//               case UserStatus.refreshing:
//               case UserStatus.success:
//               case UserStatus.failedToBlock:
//                 if (state.personView == null) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 return UserPageNew(
//                   userId: widget.userId,
//                   isAccountUser: widget.isAccountUser,
//                   personView: state.personView,
//                   moderates: state.moderates,
//                   commentViewTrees: state.comments,
//                   postViews: state.posts,
//                   savedPostViews: state.savedPosts,
//                   savedComments: state.savedComments,
//                   hasReachedPostEnd: state.hasReachedPostEnd,
//                   hasReachedSavedPostEnd: state.hasReachedSavedPostEnd,
//                   blockedPerson: state.blockedPerson,
//                   selectedUserOption: widget.selectedUserOption,
//                   savedToggle: widget.savedToggle,
//                   fullPersonView: state.fullPersonView,
//                 );
//               case UserStatus.empty:
//                 return Container();
//               case UserStatus.failure:
//                 return ErrorMessage(
//                   message: state.errorMessage,
//                   actions: [
//                     (
//                       text: AppLocalizations.of(context)!.refreshContent,
//                       action: () => context.read<UserBloc>().add(GetUserEvent(userId: widget.userId, reset: true)),
//                       loading: false,
//                     ),
//                   ],
//                 );
//             }
//           }),
//         ),
//       ),
//     );
//   }
// }
