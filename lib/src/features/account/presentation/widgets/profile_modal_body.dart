import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/navigation/swipeable_page_route.dart';
import 'package:thunder/src/core/app/dependency_factories.dart';
import 'package:thunder/src/features/account/presentation/pages/login_page.dart';
import 'package:thunder/src/features/account/presentation/widgets/profile_modal/profile_select.dart';
import 'package:thunder/src/features/settings/api.dart';

/// Displays the account-selection and account-management flow in a modal.
///
/// The widget owns a nested navigator so the login page can be opened without dismissing the surrounding modal sheet.
class ProfileModalBody extends StatefulWidget {
  const ProfileModalBody({super.key, this.showLogoutDialog = false, this.quickSelectMode = false, this.customHeading});

  /// Whether to show the logout confirmation dialog after the modal opens.
  final bool showLogoutDialog;

  /// Whether to show only authenticated accounts and hide management actions.
  final bool quickSelectMode;

  /// Optional title displayed above the authenticated account list.
  final String? customHeading;

  @override
  State<ProfileModalBody> createState() => _ProfileModalBodyState();
}

class _ProfileModalBodyState extends State<ProfileModalBody> {
  final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  void _pushRegister({bool anonymous = false}) {
    _shellNavigatorKey.currentState!.pushNamed('/login', arguments: {'anonymous': anonymous});
  }

  void _popRegister() {
    _shellNavigatorKey.currentState!.pop();
  }

  void _popModal() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createProfileModalCubit(quickSelectMode: widget.quickSelectMode)..load(),
      child: Navigator(
        key: _shellNavigatorKey,
        onDidRemovePage: (_) {},
        pages: [MaterialPage(canPop: false, child: _buildProfileSelect())],
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Widget _buildProfileSelect() {
    return ProfileSelect(pushRegister: _pushRegister, showLogoutDialog: widget.showLogoutDialog, quickSelectMode: widget.quickSelectMode, customHeading: widget.customHeading);
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      '/login' => LoginPage(popRegister: _popRegister, popModal: _popModal, anonymous: ((settings.arguments as Map<String, bool>?)?['anonymous']) ?? false),
      _ => _buildProfileSelect(),
    };

    final gestureCubit = context.read<GesturePreferencesCubit>();
    return SwipeablePageRoute<dynamic>(
      canSwipe: (!kIsWeb && Platform.isIOS) || gestureCubit.state.enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: !gestureCubit.state.enableFullScreenSwipeNavigationGesture,
      builder: (context) => page,
      settings: settings,
    );
  }
}
