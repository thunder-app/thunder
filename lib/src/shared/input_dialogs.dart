import 'dart:async';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/account/data/cache/profile_site_info_cache.dart';
import 'package:thunder/src/shared/avatars/community_avatar.dart';
import 'package:thunder/src/shared/avatars/user_avatar.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/core/utils/utils.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

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
        final response = await createUserRepository(account).getUser(username: normalizedUsername);
        final user = response!.user;

        onUserSelected(user);
        Navigator.of(context).pop();
        return null;
      } catch (e) {
        return l10n.unableToFindUser;
      }
    }

    return l10n.unableToFindUser;
  }

  showThunderTypeaheadDialog<ThunderUser>(
    context: context,
    title: title,
    inputLabel: l10n.username,
    primaryButtonText: l10n.ok,
    secondaryButtonText: l10n.cancel,
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

  final response = await createSearchRepository(account).search(
    query: query,
    type: MetaSearchType.users,
    limit: 20,
  );

  return response.users;
}

Widget buildUserSuggestionWidget(BuildContext context, ThunderUser payload, {void Function(ThunderUser)? onSelected}) {
  final tooltip = generateUserFullName(
    context,
    payload.name,
    payload.displayName,
    fetchInstanceNameFromUrl(payload.actorId),
  );

  return Tooltip(
    message: tooltip,
    preferBelow: false,
    child: InkWell(
      onTap: onSelected == null ? null : () => onSelected(payload),
      child: ListTile(
        leading: UserAvatar(user: payload),
        title: Text(payload.displayNameOrName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Semantics(
          excludeSemantics: true,
          child: ThunderMarquee(
            animationDuration: const Duration(seconds: 2),
            backDuration: const Duration(seconds: 2),
            pauseDuration: const Duration(seconds: 1),
            child: UserFullNameWidget(
              name: payload.name,
              displayName: payload.displayName,
              instance: fetchInstanceNameFromUrl(payload.actorId),
              useDisplayName: false, // Override because we're showing display name above
            ),
          ),
        ),
      ),
    ),
  );
}

/// Shows a dialog which allows typing/search for a community. Favourited and subscribed communities are prioritized in suggestions.
void showCommunityInputDialog(
  BuildContext context, {
  required String title,
  required Account account,
  required void Function(ThunderCommunity community) onCommunitySelected,
  List<ThunderCommunity>? suggestions,
}) async {
  final l10n = GlobalContext.l10n;

  List<ThunderCommunity>? favouritedCommunities;

  try {
    final favourites = await createFavoriteRepository().favorites(account.id);
    final subscriptions = await createAccountRepository(account).subscriptions();
    favouritedCommunities = subscriptions.where((community) => favourites.any((favorite) => favorite.communityId == community.id)).toList();

    suggestions ??= prioritizeFavorites(subscriptions, favouritedCommunities);
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
        final response = await createCommunityRepository(account).getCommunity(name: normalizedCommunity);
        final community = response.community;

        onCommunitySelected(community);
        Navigator.of(context).pop();
        return null;
      } catch (e) {
        return l10n.unableToFindCommunity;
      }
    }

    return l10n.unableToFindCommunity;
  }

  showThunderTypeaheadDialog<ThunderCommunity>(
    context: context,
    title: title,
    inputLabel: l10n.community,
    primaryButtonText: l10n.ok,
    secondaryButtonText: l10n.cancel,
    onSubmitted: onSubmitted,
    getSuggestions: (query) => getCommunitySuggestions(context, query: query, account: account, suggestions: suggestions, favouritedCommunities: favouritedCommunities),
    suggestionBuilder: (payload) => buildCommunitySuggestionWidget(context, payload, favouriteCommunityIds: favouritedCommunities?.map((community) => community.id).toSet()),
  );
}

Future<List<ThunderCommunity>> getCommunitySuggestions(
  BuildContext context, {
  required String query,
  required Account account,
  List<ThunderCommunity>? favouritedCommunities,
  List<ThunderCommunity>? suggestions,
}) async {
  if (query.isEmpty) return suggestions ?? [];

  final response = await createSearchRepository(account).search(
    query: query,
    type: MetaSearchType.communities,
    limit: 20,
    sort: SearchSortType.topAll,
  );

  return prioritizeFavorites(response.communities, favouritedCommunities) ?? [];
}

Widget buildCommunitySuggestionWidget(BuildContext context, ThunderCommunity payload, {Set<int>? favouriteCommunityIds, void Function(ThunderCommunity)? onSelected}) {
  final l10n = GlobalContext.l10n;

  final tooltip = generateCommunityFullName(
    context,
    payload.name,
    payload.title,
    fetchInstanceNameFromUrl(payload.actorId),
  );

  return Tooltip(
    message: tooltip,
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
              ThunderMarquee(
                animationDuration: const Duration(seconds: 2),
                backDuration: const Duration(seconds: 2),
                pauseDuration: const Duration(seconds: 1),
                child: CommunityFullNameWidget(
                  name: payload.name,
                  displayName: payload.title,
                  instance: fetchInstanceNameFromUrl(payload.actorId),
                  useDisplayName: false, // Override because we're showing display name above
                ),
              ),
              if (payload.context.subscribed != null && payload.counts.subscribers != null) ...[
                Row(
                  children: [
                    Icon(Icons.people_rounded, size: 16.0),
                    SizedBox(width: 5.0),
                    Text(formatNumberToK(payload.counts.subscribers ?? -1)),
                    Text(' · ${switch (payload.context.subscribed) {
                      SubscriptionStatus.pending => l10n.pending,
                      SubscriptionStatus.subscribed => l10n.subscribed,
                      SubscriptionStatus.notSubscribed => '',
                      _ => '',
                    }}'),
                    if (favouriteCommunityIds?.contains(payload.id) == true) ...[
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

/// Shows a dialog which allows typing/search for an instance. Federated instances are loaded in the background; suggestions appear as they load.
void showInstanceInputDialog(
  BuildContext context, {
  required String title,
  required Account account,
  required void Function(ThunderInstanceInfo) onInstanceSelected,
  Iterable<Map<String, dynamic>>? suggestions,
}) async {
  final l10n = GlobalContext.l10n;

  final instances = <ThunderInstanceInfo>[];
  unawaited(_loadLinkedInstances(account, instances));

  Future<String?> onSubmitted({ThunderInstanceInfo? payload, String? value}) async {
    if (payload == null && value == null) return null;

    if (payload != null) {
      onInstanceSelected(payload);
      Navigator.of(context).pop();
      return null;
    }

    if (value != null && value.trim().isNotEmpty) {
      final trimmed = value.trim();
      final instance = instances.firstWhereOrNull((i) => i.domain == trimmed);

      if (instance != null) {
        onInstanceSelected(instance);
        Navigator.of(context).pop();
        return null;
      }

      onInstanceSelected(ThunderInstanceInfo(domain: trimmed, name: trimmed));
      Navigator.of(context).pop();
      return null;
    }

    return null;
  }

  if (context.mounted) {
    showThunderTypeaheadDialog<ThunderInstanceInfo>(
      context: context,
      title: title,
      inputLabel: l10n.instance(1),
      primaryButtonText: l10n.ok,
      secondaryButtonText: l10n.cancel,
      onSubmitted: onSubmitted,
      getSuggestions: (query) => getInstanceSuggestions(query, instances),
      suggestionBuilder: (payload) => buildInstanceSuggestionWidget(context, payload, onSelected: (instance) => onSubmitted(payload: instance)),
    );
  }
}

Future<void> _loadLinkedInstances(Account account, List<ThunderInstanceInfo> out) async {
  try {
    final federated = await createInstanceRepository(account).federated();
    final linked = federated.linked
        .map(
          (instance) => ThunderInstanceInfo(id: instance.id, domain: instance.domain, name: instance.domain),
        )
        .toList();

    out
      ..clear()
      ..addAll(linked);
  } catch (_) {
    // Dialog still works with empty list; user can type a domain and submit.
  }
}

Future<List<ThunderInstanceInfo>> getInstanceSuggestions(String query, List<ThunderInstanceInfo>? suggestions) async {
  if (query.isEmpty) return suggestions ?? [];

  final instances = suggestions?.where((instance) => instance.domain.contains(query)).toList() ?? [] as List<ThunderInstanceInfo>;
  return instances;
}

Widget buildInstanceSuggestionWidget(BuildContext context, ThunderInstanceInfo payload, {void Function(ThunderInstanceInfo)? onSelected}) {
  final theme = Theme.of(context);

  return Tooltip(
    message: payload.domain,
    preferBelow: false,
    child: InkWell(
      onTap: onSelected == null ? null : () => onSelected(payload),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          maxRadius: 16.0,
          child: Text(
            payload.domain[0].toUpperCase(),
            semanticsLabel: '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
        title: Text(
          payload.domain,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );
}

/// Shows a dialog which allows typing/search for an language
void showLanguageInputDialog(
  BuildContext context, {
  required String title,
  required Account account,
  required void Function(ThunderLanguage) onLanguageSelected,
  Iterable<int>? excludedLanguageIds,
  Iterable<ThunderLanguage>? suggestions,
}) async {
  final l10n = GlobalContext.l10n;

  List<ThunderLanguage> languages = suggestions?.toList() ?? const <ThunderLanguage>[];

  if (languages.isEmpty) {
    final site = await ProfileSiteInfoCache.instance.get(account);
    languages = site.allLanguages ?? const <ThunderLanguage>[];
  }

  languages = [ThunderLanguage(id: -1, code: '', name: l10n.noLanguage), ...languages];

  // Exclude languages with IDs in excludedLanguageIds
  languages = languages.where((language) {
    if (excludedLanguageIds != null && excludedLanguageIds.isNotEmpty) {
      return !excludedLanguageIds.contains(language.id);
    }

    return true;
  }).toList();

  Future<String?> onSubmitted({ThunderLanguage? payload, String? value}) async {
    if (payload == null && value == null) return null;

    if (payload != null) {
      onLanguageSelected(payload);
      Navigator.of(context).pop();
      return null;
    }

    if (value != null) {
      final language = languages.firstWhereOrNull((language) => language.name.toLowerCase().contains(value.toLowerCase()));

      if (language != null) {
        onLanguageSelected(language);
        Navigator.of(context).pop();
        return null;
      } else {
        return l10n.unableToFindLanguage;
      }
    }

    return null;
  }

  if (context.mounted) {
    showThunderTypeaheadDialog<ThunderLanguage>(
      context: context,
      title: title,
      inputLabel: l10n.language,
      primaryButtonText: l10n.ok,
      secondaryButtonText: l10n.cancel,
      onSubmitted: onSubmitted,
      getSuggestions: (query) => getLanguageSuggestions(context, query, languages),
      suggestionBuilder: (payload) => buildLanguageSuggestionWidget(context, payload),
    );
  }
}

Future<List<ThunderLanguage>> getLanguageSuggestions(BuildContext context, String query, List<ThunderLanguage>? suggestions) async {
  final currentLocale = Localizations.localeOf(context);
  final currentLanguage = suggestions?.firstWhereOrNull((l) => l.code == currentLocale.languageCode);

  // Move the current language to the top of the suggestions list.
  if (currentLanguage != null && (suggestions?.length ?? 0) >= 2) {
    suggestions = suggestions?.toList()
      ?..remove(currentLanguage)
      ..insert(2, currentLanguage);
  }

  if (query.isEmpty) {
    return suggestions ?? [];
  }

  final languages = suggestions?.where((language) => language.name.toLowerCase().contains(query.toLowerCase())).toList() ?? [];
  return languages;
}

Widget buildLanguageSuggestionWidget(BuildContext context, ThunderLanguage payload, {void Function(ThunderLanguage)? onSelected}) {
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
void showKeywordInputDialog(
  BuildContext context, {
  required String title,
  required void Function(String) onKeywordSelected,
}) async {
  final l10n = GlobalContext.l10n;

  Future<String?> onSubmitted({String? payload, String? value}) async {
    final formattedPayload = payload?.trim();
    final formattedValue = value?.trim();

    if (formattedPayload != null && formattedPayload.isNotEmpty) {
      onKeywordSelected(formattedPayload);
      Navigator.of(context).pop();
      return null;
    }

    if (formattedValue != null && formattedValue.isNotEmpty) {
      onKeywordSelected(formattedValue);
      Navigator.of(context).pop();
      return null;
    }

    return null;
  }

  if (context.mounted) {
    showThunderTypeaheadDialog<String>(
      context: context,
      title: title,
      inputLabel: l10n.addKeywordFilter,
      primaryButtonText: l10n.ok,
      secondaryButtonText: l10n.cancel,
      onSubmitted: onSubmitted,
      getSuggestions: (query) => [],
      suggestionBuilder: (payload) => Container(),
    );
  }
}
