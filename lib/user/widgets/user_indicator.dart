import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/enums/full_name_separator.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/utils/instance.dart';

class UserIndicator extends StatefulWidget {
  const UserIndicator({super.key});

  @override
  State<StatefulWidget> createState() => _UserIndicatorState();
}

class _UserIndicatorState extends State<UserIndicator> {
  bool accountError = false;
  Person? person;

  @override
  void initState() {
    super.initState();

    person = context.read<AccountBloc>().state.personView?.person;
    if (person == null) context.read<AccountBloc>().add(GetAccountInformation());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AccountBloc, AccountState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (listenerContext, state) {
        if (state.status == AccountStatus.success) {
          setState(() => person = state.personView?.person);
        } else if (state.status != AccountStatus.loading) {
          setState(() => accountError = true);
        }
      },
      child: SizedBox(
        height: 40,
        child: accountError
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_rounded),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Expanded(
                      child: Text(
                    AppLocalizations.of(context)!.fetchAccountError,
                    overflow: TextOverflow.ellipsis,
                  )),
                  TextButton.icon(
                      onPressed: () {
                        context.read<AccountBloc>().add(GetAccountInformation());
                        setState(() => accountError = false);
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(AppLocalizations.of(context)!.retry))
                ],
              )
            : person != null
                ? Row(
                    children: [
                      if (person != null) UserAvatar(person: person!),
                      const SizedBox(
                        width: 12.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(person!.displayName ?? person!.name),
                          Text(
                            generateUserFullName(context, person!.name, fetchInstanceNameFromUrl(person!.actorId) ?? '-'),
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  )
                : const SizedBox(
                    width: 32,
                    height: 32,
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
      ),
    );
  }
}
