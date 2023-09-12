import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/shared/community_icon.dart';
import 'package:thunder/shared/user_avatar.dart';
import 'package:thunder/utils/instance.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Shows a dialog which allows typing/search for a user
void showUserInputDialog(BuildContext context, {required String title, required void Function(PersonViewSafe) onUserSelected}) async {
  Future<String?> onSubmitted({PersonViewSafe? payload, String? value}) async {
    if (payload != null) {
      onUserSelected(payload);
      Navigator.of(context).pop();
    } else if (value != null) {
      // Normalize the username
      final String? normalizedUsername = await getLemmyUser(value);
      if (normalizedUsername != null) {
        try {
          Account? account = await fetchActiveProfileAccount();
          final FullPersonView fullPersonView = await LemmyClient.instance.lemmyApiV3.run(GetPersonDetails(
            auth: account?.jwt,
            username: normalizedUsername,
          ));

          onUserSelected(fullPersonView.personView);

          Navigator.of(context).pop();
        } catch (e) {
          return AppLocalizations.of(context)!.unableToFindUser;
        }
      } else {
        return AppLocalizations.of(context)!.unableToFindUser;
      }
    }
    return null;
  }

  showInputDialog<PersonViewSafe>(
    context: context,
    title: title,
    inputLabel: AppLocalizations.of(context)!.username,
    onSubmitted: onSubmitted,
    getSuggestions: (query) async {
      if (query.isNotEmpty != true) {
        return const Iterable.empty();
      }
      Account? account = await fetchActiveProfileAccount();
      final SearchResults searchReults = await LemmyClient.instance.lemmyApiV3.run(Search(
        q: query,
        auth: account?.jwt,
        type: SearchType.users,
        limit: 10,
      ));
      return searchReults.users;
    },
    suggestionBuilder: (payload) {
      return Tooltip(
        message: '${payload.person.name}@${fetchInstanceNameFromUrl(payload.person.actorId)}',
        preferBelow: false,
        child: ListTile(
          leading: UserAvatar(person: payload.person),
          title: Text(
            payload.person.displayName ?? payload.person.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: TextScroll(
            '${payload.person.name}@${fetchInstanceNameFromUrl(payload.person.actorId)}',
            delayBefore: const Duration(seconds: 2),
            pauseBetween: const Duration(seconds: 3),
            velocity: const Velocity(pixelsPerSecond: Offset(50, 0)),
          ),
        ),
      );
    },
  );
}

/// Shows a dialog which allows typing/search for a community
void showCommunityInputDialog(BuildContext context, {required String title, required void Function(CommunityView) onCommunitySelected}) async {
  Future<String?> onSubmitted({CommunityView? payload, String? value}) async {
    if (payload != null) {
      onCommunitySelected(payload);
      Navigator.of(context).pop();
    } else if (value != null) {
      // Normalize the community name
      final String? normalizedCommunity = await getLemmyCommunity(value);
      if (normalizedCommunity != null) {
        try {
          Account? account = await fetchActiveProfileAccount();
          final FullCommunityView fullCommunityView = await LemmyClient.instance.lemmyApiV3.run(GetCommunity(
            auth: account?.jwt,
            name: normalizedCommunity,
          ));

          onCommunitySelected(fullCommunityView.communityView);

          Navigator.of(context).pop();
        } catch (e) {
          return AppLocalizations.of(context)!.unableToFindCommunity;
        }
      } else {
        return AppLocalizations.of(context)!.unableToFindCommunity;
      }
    }
    return null;
  }

  showInputDialog<CommunityView>(
    context: context,
    title: title,
    inputLabel: AppLocalizations.of(context)!.community,
    onSubmitted: onSubmitted,
    getSuggestions: (query) async {
      if (query.isNotEmpty != true) {
        return const Iterable.empty();
      }
      Account? account = await fetchActiveProfileAccount();
      final SearchResults searchReults = await LemmyClient.instance.lemmyApiV3.run(Search(
        q: query,
        auth: account?.jwt,
        type: SearchType.communities,
        limit: 10,
      ));
      return searchReults.communities;
    },
    suggestionBuilder: (payload) {
      return Tooltip(
        message: '${payload.community.name}@${fetchInstanceNameFromUrl(payload.community.actorId)}',
        preferBelow: false,
        child: ListTile(
          leading: CommunityIcon(community: payload.community),
          title: Text(
            payload.community.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: TextScroll(
            '${payload.community.name}@${fetchInstanceNameFromUrl(payload.community.actorId)}',
            delayBefore: const Duration(seconds: 2),
            pauseBetween: const Duration(seconds: 3),
            velocity: const Velocity(pixelsPerSecond: Offset(50, 0)),
          ),
        ),
      );
    },
  );
}

/// Shows a dialog which takes input and offers suggestions
void showInputDialog<T>({
  required BuildContext context,
  required String title,
  required String inputLabel,
  required Future<String?> Function({T? payload, String? value}) onSubmitted,
  required Future<Iterable<T>> Function(String query) getSuggestions,
  required Widget Function(T payload) suggestionBuilder,
}) async {
  final textController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      bool okEnabled = false;
      String? error;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TypeAheadField<T>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: textController,
                    onChanged: (value) => setState(() {
                      okEnabled = value.isNotEmpty;
                      error = null;
                    }),
                    autofocus: true,
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      labelText: inputLabel,
                      errorText: error,
                    ),
                    onSubmitted: (text) async {
                      setState(() => okEnabled = false);
                      final String? submitError = await onSubmitted(value: text);
                      setState(() => error = submitError);
                    },
                  ),
                  suggestionsCallback: getSuggestions,
                  itemBuilder: (context, payload) => suggestionBuilder(payload),
                  onSuggestionSelected: (payload) async {
                    setState(() => okEnabled = false);
                    final String? submitError = await onSubmitted(payload: payload);
                    setState(() => error = submitError);
                  },
                  hideOnEmpty: true,
                  hideOnLoading: true,
                  hideOnError: true,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    const SizedBox(width: 5),
                    FilledButton(
                      onPressed: okEnabled
                          ? () async {
                              setState(() => okEnabled = false);
                              final String? submitError = await onSubmitted(value: textController.text);
                              setState(() => error = submitError);
                            }
                          : null,
                      child: Text(AppLocalizations.of(context)!.ok),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
