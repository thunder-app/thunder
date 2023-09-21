import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<bool> showLogOutDialog(BuildContext context) async {
  bool result = false;
  await showDialog<bool>(
      context: context,
      builder: (context) => BlocProvider<AuthBloc>.value(
            value: context.read<AuthBloc>(),
            child: AlertDialog(
              title: Text(
                AppLocalizations.of(context)!.confirmLogOut,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      result = false;
                      context.pop();
                    },
                    child: Text(AppLocalizations.of(context)!.cancel)),
                const SizedBox(
                  width: 12,
                ),
                FilledButton(
                    onPressed: () {
                      result = true;
                      context.read<AuthBloc>().add(RemoveAccount(
                            accountId: context.read<AuthBloc>().state.account!.id,
                          ));
                      context.pop();
                    },
                    child: Text(AppLocalizations.of(context)!.logOut))
              ],
            ),
          ));
  return result;
}
