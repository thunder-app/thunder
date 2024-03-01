import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/account/widgets/profile_modal_body.dart';

Future<void> showProfileModalSheet(
  BuildContext context, {
  bool showLogoutDialog = false,
  bool quickSelectMode = false,
  String? customHeading,
  bool reloadOnSwitch = true,
}) async {
  AuthBloc authBloc = context.read<AuthBloc>();
  ThunderBloc thunderBloc = context.read<ThunderBloc>();

  showModalBottomSheet(
    elevation: 0,
    isScrollControlled: true,
    context: context,
    showDragHandle: true,
    builder: (context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: thunderBloc),
        ],
        child: FractionallySizedBox(
          heightFactor: 0.8,
          child: ProfileModalBody(
            showLogoutDialog: showLogoutDialog,
            quickSelectMode: quickSelectMode,
            customHeading: customHeading,
            reloadOnSwitch: reloadOnSwitch,
          ),
        ),
      );
    },
  );
}
