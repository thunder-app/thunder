import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/user/widgets/user_indicator.dart';

/// Creates a widget which displays a preview of the currently selected account, with the ability to change accounts.
///
/// By passing in a [communityActorId], it will attempt to resolve the community to the new user's instance (if changed),
/// and will invoke [onCommunityChanged]. If the community could not be resolved, the callback will pass [null].
class UserSelector extends StatefulWidget {
  final String? communityActorId;
  final void Function(CommunityView?)? onCommunityChanged;
  final void Function()? onUserChanged;
  final String? profileModalHeading;

  const UserSelector({
    super.key,
    this.communityActorId,
    this.onCommunityChanged,
    this.onUserChanged,
    this.profileModalHeading,
  });

  @override
  State<UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Transform.translate(
      offset: const Offset(-8, 0),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        onTap: () async {
          final Account? originalUser = context.read<AuthBloc>().state.account;

          await showProfileModalSheet(
            context,
            quickSelectMode: true,
            customHeading: widget.profileModalHeading,
            reloadOnSwitch: false,
          );

          // Wait slightly longer than the duration that is waited in the account switcher logic.
          await Future.delayed(const Duration(milliseconds: 1500));

          if (context.mounted) {
            Account? newUser = context.read<AuthBloc>().state.account;

            if (originalUser != null && newUser != null && originalUser.id != newUser.id) {
              // The user changed. Reload the widget.
              setState(() {});
              widget.onUserChanged?.call();

              //If there is a selected community, see if we can resolve it to the new user's instance.
              if (widget.communityActorId?.isNotEmpty == true && widget.onCommunityChanged != null) {
                CommunityView? resolvedCommunity;
                try {
                  final ResolveObjectResponse resolveObjectResponse = await LemmyApiV3(newUser.instance!).run(ResolveObject(q: widget.communityActorId!));
                  resolvedCommunity = resolveObjectResponse.community;
                } catch (e) {
                  // We'll just return null if we can't find it.
                }
                widget.onCommunityChanged!(resolvedCommunity);
              }
            }
          }
        },
        child: const Padding(
          padding: EdgeInsets.only(left: 8, top: 4, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UserIndicator(),
              Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
