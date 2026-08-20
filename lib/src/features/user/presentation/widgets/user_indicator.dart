import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/shared/avatars/user_avatar.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';

class UserIndicator extends StatefulWidget {
  /// The user to display.
  final ThunderUser? user;

  const UserIndicator({super.key, this.user});

  @override
  State<StatefulWidget> createState() => _UserIndicatorState();
}

class _UserIndicatorState extends State<UserIndicator> {
  /// The user to display.
  ThunderUser? user;

  /// Whether an error occurred while fetching the account information.
  bool error = false;

  @override
  void initState() {
    super.initState();

    if (widget.user != null) return setState(() => user = widget.user);

    final state = context.read<ProfileBloc>().state;

    if (state.user != null) {
      setState(() => user = state.user);
    } else {
      context.read<ProfileBloc>().add(const FetchProfileInformation());
    }
  }

  @override
  void didUpdateWidget(UserIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id) {
      setState(() => user = widget.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (listenerContext, state) {
        if (state.status == ProfileStatus.success) {
          if (state.user != null) setState(() => user = state.user);
        } else if (state.status != ProfileStatus.loading) {
          setState(() => error = true);
        }
      },
      builder: (context, state) {
        if (error) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.warning_rounded),
              const SizedBox(width: 8.0),
              Text(l10n.fetchAccountError, overflow: TextOverflow.ellipsis),
              TextButton.icon(
                label: Text(l10n.retry),
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  context.read<ProfileBloc>().add(const FetchProfileInformation());
                  setState(() => error = false);
                },
              ),
            ],
          );
        }

        if (user == null) {
          return SizedBox(
            height: 40,
            child: Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator())),
          );
        }

        return SizedBox(
          height: 40,
          child: Row(
            spacing: 12.0,
            children: [
              if (user != null) UserAvatar(user: user!),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user!.displayNameOrName),
                  UserFullNameWidget(
                    name: user!.name,
                    displayName: user!.displayName,
                    instance: fetchInstanceNameFromUrl(user!.actorId) ?? '-',
                    // Override because we're showing display name above
                    useDisplayName: false,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
