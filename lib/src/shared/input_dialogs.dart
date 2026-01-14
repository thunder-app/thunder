import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:collection/collection.dart';

import 'package:thunder/src/core/enums/search_sort_type.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/meta_search_type.dart';
import 'package:thunder/src/core/models/thunder_language.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/full_name.dart';
import 'package:thunder/src/core/enums/subscription_status.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/shared/widgets/avatars/community_avatar.dart';
import 'package:thunder/src/shared/dialogs.dart';
import 'package:thunder/src/shared/widgets/avatars/user_avatar.dart';
import 'package:thunder/src/shared/full_name_widgets.dart';
import 'package:thunder/src/shared/marquee_widget.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/shared/utils/instance.dart';
import 'package:thunder/src/shared/utils/numbers.dart';

/// Shows a dialog which allows typing/search for a user
void showUserInputDialog(
  BuildContext context, {
  required String title,
  required Account account,
  required void Function(ThunderUser) onUserSelected,
}) async {
  final l10n = GlobalContext.l10n;

  Future<String?> onSubmitted({ThunderUser? payload, String? value}) async {
    if (payload == null && value == null) return null;

    if (payload != null) {
      onUserSelected(payload);
      Navigator.of(context).pop();
      return null;
    }

    // Normalize the username
    final normalizedUsername = await getLemmyUser(value!);

    if (normalizedUsername != null) {
      try {
        final response = await UserRepositoryImpl(account: account).getUser(username: normalizedUsername);
        final user = response!['user'];

        onUserSelected(user);
        Navigator.of(context).pop();
        return null;
      } catch (e) {
        return l10n.unableToFindUser;
      }
    }

    return l10n.unableToFindUser;
  }

  showInputDialog<ThunderUser>(
    context: context,
    title: title,
    inputLabel: l10n.username,
    onSubmitted: onSubmitted,
    getSuggestions: (query) => getUserSuggestions(context, query: query, account: account),
    suggestionBuilder: (payload) => buildUserSuggestionWidget(context, payload),
  );
}

Future<List<ThunderUser>> getUserSuggestions(
  BuildContext context, {
  required String query,
  required Account account,
}) async {
  if (query.isEmpty) return [];

  final response = await SearchRepositoryImpl(account: account).search(
    query: query,
    type: MetaSearchType.users,
    limit: 20,
  );

  return response['users'];
}

Widget buildUserSuggestionWidget(BuildContext context, ThunderUser payload, {void Function(ThunderUser)? onSelected}) {
  return Tooltip(
    message: generateUserFullName(
      context,
      payload.name,
      payload.displayName,
      fetchInstanceNameFromUrl(payload.actorId),
    ),
    preferBelow: false,
    child: InkWell(
      onTap: onSelected == null ? null : () => onSelected(payload),
      child: ListTile(
        leading: UserAvatar(user: payload),
        title: Text(payload.displayNameOrName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Semantics(
          excludeSemantics: true,
          child: Marquee(
            animationDuration: const Duration(seconds: 2),
            backDuration: const Duration(seconds: 2),
            pauseDuration: const Duration(seconds: 1),
            child: UserFullNameWidget(
              context,
              payload.name,
              payload.displayName,
              fetchInstanceNameFromUrl(payload.actorId),
              // Override because we're showing display name above
              useDisplayName: false,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Shows a dialog which allows typing/search for a community.
/// Given an [account], the dialog will show subscriptions and favorites of that account.
///
/// When searching for communities, it will use the provided [account]'s instance.
void showCommunityInputDialog(
  BuildContext context, {
  required String title,
  required Account account,
  required void Function(ThunderCommunity community) onCommunitySelected,
  List<ThunderCommunity>? emptySuggestions,
}) async {
  final l10n = GlobalContext.l10n;

  List<ThunderCommunity>? favoritedCommunities;

  try {
    // Fetch subscriptions from the given account
    final favorites = await Favorite.favorites(account.id);
    final subscriptions = await AccountRepositoryImpl(account: account).subscriptions();
    favoritedCommunities = subscriptions.where((community) => favorites.any((favorite) => favorite.communityId == community.id)).toList();

    emptySuggestions ??= prioritizeFavorites(subscriptions, favoritedCommunities);
  } catch (e) {
    // If this is unavailable, continue
  }

  Future<String?> onSubmitted({ThunderCommunity? payload, String? value}) async {
    if (payload == null && value == null) return null;

    if (payload != null) {
      onCommunitySelected(payload);
      Navigator.of(context).pop();
      return null;
    }

    // Normalize the community name
    final normalizedCommunity = await getLemmyCommunity(value!);

    if (normalizedCommunity != null) {
      try {
        final response = await CommunityRepositoryImpl(account: account).getCommunity(name: normalizedCommunity);
        final community = response['community'];

        onCommunitySelected(community);
        Navigator.of(context).pop();
        return null;
      } catch (e) {
        return l10n.unableToFindCommunity;
      }
    }

    return l10n.unableToFindCommunity;
  }

  showInputDialog<ThunderCommunity>(
    context: context,
    title: title,
    inputLabel: l10n.community,
    onSubmitted: onSubmitted,
    getSuggestions: (query) => getCommunitySuggestions(context, query: query, account: account, emptySuggestions: emptySuggestions, favoritedCommunities: favoritedCommunities),
    suggestionBuilder: (payload) => buildCommunitySuggestionWidget(context, payload),
  );
}

Future<List<ThunderCommunity>> getCommunitySuggestions(
  BuildContext context, {
  required String query,
  required Account account,
  List<ThunderCommunity>? favoritedCommunities,
  List<ThunderCommunity>? emptySuggestions,
}) async {
  if (query.isEmpty) return emptySuggestions ?? [];

  final response = await SearchRepositoryImpl(account: account).search(
    query: query,
    type: MetaSearchType.communities,
    limit: 20,
    sort: SearchSortType.topAll,
  );

  return prioritizeFavorites(response['communities'], favoritedCommunities) ?? [];
}

Widget buildCommunitySuggestionWidget(BuildContext context, ThunderCommunity payload, {void Function(ThunderCommunity)? onSelected}) {
  final l10n = GlobalContext.l10n;

  return Tooltip(
    message: generateCommunityFullName(
      context,
      payload.name,
      payload.title,
      fetchInstanceNameFromUrl(payload.actorId),
    ),
    preferBelow: false,
    child: InkWell(
      onTap: onSelected == null ? null : () => onSelected(payload),
      child: ListTile(
        leading: CommunityAvatar(community: payload),
        title: Text(payload.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Semantics(
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Marquee(
                animationDuration: const Duration(seconds: 2),
                backDuration: const Duration(seconds: 2),
                pauseDuration: const Duration(seconds: 1),
                child: CommunityFullNameWidget(
                  context,
                  payload.name,
                  payload.title,
                  fetchInstanceNameFromUrl(payload.actorId),
                  // Override because we're showing display name above
                  useDisplayName: false,
                ),
              ),
              if (payload.subscribed != null && payload.subscribers != null) ...[
                Row(
                  children: [
                    Icon(Icons.people_rounded, size: 16.0),
                    SizedBox(width: 5.0),
                    Text(formatNumberToK(payload.subscribers ?? -1)),
                    Text(' · ${switch (payload.subscribed) {
                      SubscriptionStatus.pending => l10n.pending,
                      SubscriptionStatus.subscribed => l10n.subscribed,
                      SubscriptionStatus.notSubscribed => '',
                      _ => '',
                    }}'),
                    if (_getFavoriteStatus(context, payload)) ...[
                      Text(' · '),
                      Icon(Icons.star_rounded, size: 15.0),
                    ],
                  ],
                )
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

/// Checks whether the current community is a favorite of the current user
bool _getFavoriteStatus(BuildContext context, ThunderCommunity community) {
  final state = context.read<ProfileBloc>().state;
  return state.favorites.any((c) => c.id == community.id);
}

/// Shows a dialog which allows typing/search for an instance
void showInstanceInputDialog(
  BuildContext context, {
  required String title,
  required void Function(Map<String, dynamic>) onInstanceSelected,
  Iterable<Map<String, dynamic>>? emptySuggestions,
}) async {
  Account? account = await fetchActiveProfile();

  final federatedInstances = await InstanceRepositoryImpl(account: account).federated();
  final linkedInstances = federatedInstances['linked'];

  Future<String?> onSubmitted({Map<String, dynamic>? payload, String? value}) async {
    if (payload != null) {
      onInstanceSelected(payload);
      Navigator.of(context).pop();
    } else if (value != null) {
      final Map<String, dynamic>? instance = linkedInstances.firstWhereOrNull((Map<String, dynamic> instance) => instance['domain'] == value);

      if (instance != null) {
        onInstanceSelected(instance);
        Navigator.of(context).pop();
      } else {
        return AppLocalizations.of(context)!.unableToFindInstance;
      }
    }

    return null;
  }

  if (context.mounted) {
    showInputDialog<Map<String, dynamic>>(
      context: context,
      title: title,
      inputLabel: AppLocalizations.of(context)!.instance(1),
      onSubmitted: onSubmitted,
      getSuggestions: (query) => getInstanceSuggestions(query, linkedInstances),
      suggestionBuilder: (payload) => buildInstanceSuggestionWidget(payload, context: context),
    );
  }
}

Future<List<Map<String, dynamic>>> getInstanceSuggestions(String query, List<Map<String, dynamic>>? emptySuggestions) async {
  if (query.isEmpty) {
    return [];
  }

  List<Map<String, dynamic>> filteredInstances = emptySuggestions?.where((Map<String, dynamic> instance) => instance['domain'].contains(query)).toList() ?? [];
  return filteredInstances;
}

Widget buildInstanceSuggestionWidget(Map<String, dynamic> payload, {void Function(Map<String, dynamic>)? onSelected, BuildContext? context}) {
  final theme = Theme.of(context!);

  return Tooltip(
    message: '${payload['domain']}',
    preferBelow: false,
    child: InkWell(
      onTap: onSelected == null ? null : () => onSelected(payload),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          maxRadius: 16.0,
          child: Text(
            payload['domain'][0].toUpperCase(),
            semanticsLabel: '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
        title: Text(
          payload['domain'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );
}

/// Shows a dialog which allows typing/search for an language
void showLanguageInputDialog(BuildContext context,
    {required String title, required void Function(ThunderLanguage) onLanguageSelected, Iterable<int>? excludedLanguageIds, Iterable<ThunderLanguage>? emptySuggestions}) async {
  ProfileState state = context.read<ProfileBloc>().state;
  final AppLocalizations l10n = AppLocalizations.of(context)!;

  List<ThunderLanguage> languages = [ThunderLanguage(id: -1, code: '', name: l10n.noLanguage), ...(state.siteResponse?.allLanguages ?? [])];
  languages = languages.where((language) {
    if (excludedLanguageIds != null && excludedLanguageIds.isNotEmpty) {
      return !excludedLanguageIds.contains(language.id);
    }
    return true;
  }).toList();

  Future<String?> onSubmitted({ThunderLanguage? payload, String? value}) async {
    if (payload != null) {
      onLanguageSelected(payload);
      Navigator.of(context).pop();
    } else if (value != null) {
      final ThunderLanguage? language = languages.firstWhereOrNull((ThunderLanguage language) => language.name.toLowerCase().contains(value.toLowerCase()));

      if (language != null) {
        onLanguageSelected(language);
        Navigator.of(context).pop();
      } else {
        return AppLocalizations.of(context)!.unableToFindLanguage;
      }
    }

    return null;
  }

  if (context.mounted) {
    showInputDialog<ThunderLanguage>(
      context: context,
      title: title,
      inputLabel: AppLocalizations.of(context)!.language,
      onSubmitted: onSubmitted,
      getSuggestions: (query) => getLanguageSuggestions(context, query, languages),
      suggestionBuilder: (payload) => buildLanguageSuggestionWidget(payload, context: context),
    );
  }
}

Future<List<ThunderLanguage>> getLanguageSuggestions(BuildContext context, String query, List<ThunderLanguage>? emptySuggestions) async {
  final Locale currentLocale = Localizations.localeOf(context);

  final ThunderLanguage? currentLanguage = emptySuggestions?.firstWhereOrNull((ThunderLanguage l) => l.code == currentLocale.languageCode);
  if (currentLanguage != null && (emptySuggestions?.length ?? 0) >= 2) {
    emptySuggestions = emptySuggestions?.toList()
      ?..remove(currentLanguage)
      ..insert(2, currentLanguage);
  }

  if (query.isEmpty) {
    return emptySuggestions ?? [];
  }

  List<ThunderLanguage> filteredLanguages = emptySuggestions?.where((ThunderLanguage language) => language.name.toLowerCase().contains(query.toLowerCase())).toList() ?? [];
  return filteredLanguages;
}

Widget buildLanguageSuggestionWidget(ThunderLanguage payload, {void Function(ThunderLanguage)? onSelected, BuildContext? context}) {
  return Tooltip(
    message: payload.name,
    preferBelow: false,
    child: InkWell(
      onTap: onSelected == null ? null : () => onSelected(payload),
      child: ListTile(
        title: Text(
          payload.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );
}

/// Shows a dialog which allows typing/search for a keyword
void showKeywordInputDialog(BuildContext context, {required String title, required void Function(String) onKeywordSelected}) async {
  final l10n = AppLocalizations.of(context)!;

  Future<String?> onSubmitted({String? payload, String? value}) async {
    String? formattedPayload = payload?.trim();
    String? formattedValue = value?.trim();

    if (formattedPayload != null && formattedPayload.isNotEmpty) {
      onKeywordSelected(formattedPayload);
      Navigator.of(context).pop();
    } else if (formattedValue != null && formattedValue.isNotEmpty) {
      onKeywordSelected(formattedValue);
      Navigator.of(context).pop();
    }

    return null;
  }

  if (context.mounted) {
    showInputDialog<String>(
      context: context,
      title: title,
      inputLabel: l10n.addKeywordFilter,
      onSubmitted: onSubmitted,
      getSuggestions: (query) => [],
      suggestionBuilder: (payload) => Container(),
    );
  }
}

/// Shows a dialog which takes input and offers suggestions
void showInputDialog<T>({
  required BuildContext context,
  required String title,
  required String inputLabel,
  required Future<String?> Function({T? payload, String? value}) onSubmitted,
  required FutureOr<List<T>?> Function(String query) getSuggestions,
  required Widget Function(T payload) suggestionBuilder,
}) async {
  final textController = TextEditingController();
  // Capture our content widget's setState function so we can call it outside the widget
  StateSetter? contentWidgetSetState;
  String? contentWidgetError;

  await showThunderDialog(
    context: context,
    title: title,
    onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
    secondaryButtonText: AppLocalizations.of(context)!.cancel,
    primaryButtonInitialEnabled: false,
    onPrimaryButtonPressed: (dialogContext, setPrimaryButtonEnabled) async {
      setPrimaryButtonEnabled(false);
      final String? submitError = await onSubmitted(value: textController.text);
      contentWidgetSetState?.call(() => contentWidgetError = submitError);
    },
    primaryButtonText: AppLocalizations.of(context)!.ok,
    // Use a stateful widget for the content so we can update the error message
    contentWidgetBuilder: (setPrimaryButtonEnabled) => StatefulBuilder(builder: (context, setState) {
      contentWidgetSetState = setState;
      return SizedBox(
        width: min(MediaQuery.of(context).size.width, 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TypeAheadField<T>(
              controller: textController,
              builder: (context, controller, focusNode) => TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: (value) {
                  setPrimaryButtonEnabled(value.trim().isNotEmpty);
                  setState(() => contentWidgetError = null);
                },
                autofocus: true,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: inputLabel,
                  errorText: contentWidgetError,
                ),
                onSubmitted: (text) async {
                  setPrimaryButtonEnabled(false);
                  final String? submitError = await onSubmitted(value: text);
                  setState(() => contentWidgetError = submitError);
                },
              ),
              suggestionsCallback: getSuggestions,
              itemBuilder: (context, payload) => suggestionBuilder(payload),
              onSelected: (payload) async {
                setPrimaryButtonEnabled(false);
                final String? submitError = await onSubmitted(payload: payload);
                setState(() => contentWidgetError = submitError);
              },
              hideOnEmpty: true,
              hideOnLoading: true,
              hideOnError: true,
            ),
          ],
        ),
      );
    }),
  );
}
