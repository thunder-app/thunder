import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/shared/avatars/user_avatar.dart';

/// Leading app bar button that opens the drawer on root feeds or pops pushed feeds.
class FeedDrawerButton extends StatelessWidget {
  const FeedDrawerButton({super.key, required this.showProfilePicture, required this.onTap, required this.isRoot});

  /// Whether the feed is the main feed with a subscriptions drawer.
  final bool isRoot;

  /// Whether to display the current user's avatar instead of a menu icon.
  final bool showProfilePicture;

  /// Callback invoked when the user taps the button.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isRoot && showProfilePicture) return _buildProfilePictureButton(context);
    return _buildIconButton(context);
  }

  Widget _buildProfilePictureButton(BuildContext context) {
    final state = context.read<ProfileBloc>().state;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Semantics(
        label: MaterialLocalizations.of(context).openAppDrawerTooltip,
        child: Stack(
          children: [
            if (state.user != null)
              Align(
                alignment: Alignment.center,
                child: UserAvatar(user: state.user!),
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(customBorder: const CircleBorder(), onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context) {
    final IconData icon;
    final String semanticLabel;

    if (isRoot) {
      icon = Icons.menu;
      semanticLabel = MaterialLocalizations.of(context).openAppDrawerTooltip;
    } else {
      icon = (!kIsWeb && Platform.isIOS) ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_rounded;
      semanticLabel = MaterialLocalizations.of(context).backButtonTooltip;
    }

    return IconButton(
      icon: Icon(icon, semanticLabel: semanticLabel),
      onPressed: onTap,
    );
  }
}
