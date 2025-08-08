import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/core/models/thunder_site_response.dart';
import 'package:thunder/instance/repository/instance_repository.dart';

/// A cache that holds a given [account]'s site info.
class ProfileSiteInfoCache {
  static final instance = ProfileSiteInfoCache._internal();

  ProfileSiteInfoCache._internal();

  /// Cache entry per account key
  final _cacheByAccountKey = HashMap();

  /// Default time-to-live for cache entries
  final defaultTTL = const Duration(seconds: 30);

  /// Returns a unique key for the given [account]
  String _accountKey(Account account) => '${account.instance}:${account.anonymous}:${account.id}';

  /// Fetches the site info using cache if valid; otherwise hits the network and updates cache.
  Future<ThunderSiteResponse> get(Account account, {Duration? ttl}) async {
    final key = _accountKey(account);
    final entry = _cacheByAccountKey[key];

    final now = DateTime.now();
    final effectiveTTL = ttl ?? defaultTTL;

    final isFresh = entry != null && !entry.isDirty && now.difference(entry.fetchedAt) < effectiveTTL;
    if (isFresh) {
      debugPrint('ProfileSiteInfoCache: Returning cached site info for $key');
      return entry.response;
    }

    final repository = InstanceRepositoryImpl(account: account);
    final response = await repository.getSiteInfo();

    _cacheByAccountKey[key] = _CacheEntry(response: response, fetchedAt: now, isDirty: false);
    debugPrint('ProfileSiteInfoCache: Cached site info for $key');
    return response;
  }

  /// Marks the cache dirty for the given [account].
  void markDirty(Account account) {
    final key = _accountKey(account);
    final entry = _cacheByAccountKey[key];

    if (entry == null) return;
    _cacheByAccountKey[key] = entry.copyWith(isDirty: true);
  }

  /// Clears the cache for the given [account].
  void clear(Account account) {
    _cacheByAccountKey.remove(_accountKey(account));
  }

  /// Clears all cached entries.
  void clearAll() => _cacheByAccountKey.clear();
}

class _CacheEntry {
  /// The site info response
  final ThunderSiteResponse response;

  /// The date and time the site info was fetched
  final DateTime fetchedAt;

  /// Whether the cache is dirty
  final bool isDirty;

  _CacheEntry({required this.response, required this.fetchedAt, required this.isDirty});

  _CacheEntry copyWith({ThunderSiteResponse? response, DateTime? fetchedAt, bool? isDirty}) {
    return _CacheEntry(
      response: response ?? this.response,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}
