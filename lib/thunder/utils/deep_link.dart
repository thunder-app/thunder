import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/utils/profiles.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/enums/deep_link_enums.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/utils/navigation.dart';

/// Custom exception for deep link navigation errors
class DeepLinkNavigationException implements Exception {
  final String message;
  final String? url;

  DeepLinkNavigationException(this.message, [this.url]);

  @override
  String toString() => message;
}

/// Custom exception for initialization errors
class ClientInitializationException implements Exception {
  final String message;

  ClientInitializationException(this.message);

  @override
  String toString() => message;
}

/// Custom exception for invalid URL format
class InvalidUrlException extends DeepLinkNavigationException {
  InvalidUrlException([String? url]) : super(GlobalContext.l10n.invalidUrl, url);
}

/// Custom exception for unable to resolve entity (post, comment, user etc)
class EntityResolutionException extends DeepLinkNavigationException {
  EntityResolutionException([String? url]) : super(GlobalContext.l10n.exceptionProcessingUri, url);
}

/// Custom exception for navigation operation timeout
class NavigationTimeoutException extends DeepLinkNavigationException {
  NavigationTimeoutException([String? url]) : super(GlobalContext.l10n.timeoutErrorMessage, url);
}

/// Represents the result of a navigation attempt through deep linking.
///
/// This class encapsulates the success/failure state of a deep link navigation operation,
/// along with relevant error information and fallback URLs when applicable.
///
/// Example:
/// ```dart
/// final result = DeepLinkResult.successful();
/// final failureResult = DeepLinkResult.failure('Invalid link format', 'https://example.com');
/// ```
class DeepLinkResult {
  /// Indicates whether the navigation was successful
  final bool success;

  /// Optional error message in case of navigation failure
  final String? errorMessage;

  /// Optional fallback URL that can be opened in an external browser
  final String? fallbackUrl;

  const DeepLinkResult({
    required this.success,
    this.errorMessage,
    this.fallbackUrl,
  });

  /// Creates a successful navigation result
  static DeepLinkResult successful() => const DeepLinkResult(success: true);

  /// Creates a failed navigation result with an optional fallback URL
  static DeepLinkResult failure(String message, [String? url]) => DeepLinkResult(
        success: false,
        errorMessage: message,
        fallbackUrl: url,
      );
}

/// Main entry point for handling deep link navigation.
///
/// This function processes both thunder:// protocol links and regular https:// links,
/// routing them to the appropriate handler based on the [linkType].
///
/// Parameters:
/// - [context]: The BuildContext for navigation
/// - [linkType]: The type of link being processed (e.g., post, comment, user)
/// - [link]: The actual URL string to process
///
/// The function handles various error cases and shows appropriate error messages
/// when navigation fails, with options to open failed links in an external browser.
Future<void> handleDeepLinkNavigation(BuildContext context, {required LinkType linkType, String? link}) async {
  if (!context.mounted) return;

  String? errorMessage;
  String? fallbackUrl;

  try {
    if (link == null || link.trim().isEmpty) throw InvalidUrlException();

    await _initializeLemmyClient();

    final normalizedLink = _normalizeLink(link);
    if (normalizedLink.isEmpty) throw InvalidUrlException(link);

    final result = await _handleNavigation(context, linkType, normalizedLink).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw NavigationTimeoutException(link),
    );

    if (!result.success) {
      errorMessage = result.errorMessage ?? GlobalContext.l10n.uriNotSupported;
      fallbackUrl = result.fallbackUrl;
    }
  } on InvalidUrlException catch (e) {
    errorMessage = e.message;
    fallbackUrl = e.url;
  } on ClientInitializationException catch (e) {
    errorMessage = e.message;
    fallbackUrl = link;
  } on NavigationTimeoutException catch (e) {
    errorMessage = e.message;
    fallbackUrl = e.url;
  } on EntityResolutionException catch (e) {
    errorMessage = e.message;
    fallbackUrl = e.url;
  } catch (e) {
    errorMessage = GlobalContext.l10n.exceptionProcessingUri;
    fallbackUrl = link;
  }

  if (errorMessage != null && context.mounted) {
    showNavigationError(context, errorMessage, fallbackUrl);
  }
}

/// Initializes the LemmyClient with the currently active profile. Includes retry logic and validation.
Future<void> _initializeLemmyClient() async {
  int maxRetries = 2;
  int attempts = 0;

  while (attempts < maxRetries) {
    try {
      final account = await fetchActiveProfile();
      if (account.instance.isEmpty) throw ClientInitializationException(GlobalContext.l10n.errorNoActiveInstance);

      final instance = account.instance.replaceAll('https://', '');
      LemmyClient.instance.changeBaseUrl(instance);

      // Validate connection by making a simple request
      await LemmyClient.instance.lemmyApiV3.run(GetSite());
      return;
    } catch (e) {
      attempts++;
      if (attempts >= maxRetries) throw ClientInitializationException('${GlobalContext.l10n.errorInitializingClient} (${e.toString()})');
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}

/// Normalizes link format by converting thunder:// protocol to https://.
/// Returns empty string for invalid URLs.
///
/// This allows consistent link handling regardless of the original protocol used.
String _normalizeLink(String? link) {
  if (link == null || link.trim().isEmpty) return "";

  String normalized = link.trim();
  normalized = normalized.replaceAll('thunder://', 'https://');

  // Validate basic URL structure
  try {
    final uri = Uri.parse(normalized);
    if (!uri.hasScheme || !uri.hasAuthority) return "";
    return normalized;
  } catch (_) {
    return "";
  }
}

/// Central handler for all navigation operations.
///
/// Routes the navigation request to the appropriate specific handler based on [linkType].
/// Returns a [DeepLinkResult] indicating success or failure of the navigation attempt.
Future<DeepLinkResult> _handleNavigation(BuildContext context, LinkType linkType, String link) async {
  if (!context.mounted) return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);

  switch (linkType) {
    case LinkType.comment:
      return _navigateToComment(context, link);
    case LinkType.user:
      return _navigateToUser(context, link);
    case LinkType.post:
      return _navigateToPost(context, link);
    case LinkType.community:
      return _navigateToCommunity(context, link);
    case LinkType.modlog:
      return _navigateToModlog(context, link);
    case LinkType.instance:
      return _navigateToInstance(context, link);
    case LinkType.thunder:
      return _navigateToInternal(context, link);
    case LinkType.unknown:
      return DeepLinkResult.failure(GlobalContext.l10n.uriNotSupported, link);
  }
}

/// Displays navigation errors to the user with optional fallback action.
///
/// If a fallback URL is provided, shows an additional action to open the link in an external browser.
void showNavigationError(BuildContext context, String error, String? fallbackUrl) {
  if (fallbackUrl == null) {
    showSnackbar(error);
    return;
  }

  showSnackbar(
    error,
    trailingIcon: Icons.open_in_browser_rounded,
    duration: const Duration(seconds: 10),
    trailingAction: () => handleLink(context, url: fallbackUrl),
  );
}

/// Navigates to an instance page.
Future<DeepLinkResult> _navigateToInstance(BuildContext context, String link) async {
  try {
    final host = link.replaceAll(RegExp(r'https?:\/\/'), '').replaceAll('/', '');
    if (host.isEmpty) throw InvalidUrlException(link);

    await navigateToInstancePage(context, instanceHost: host, instanceId: null);
    return DeepLinkResult.successful();
  } catch (e) {
    if (e is InvalidUrlException) rethrow;
    throw EntityResolutionException(link);
  }
}

/// Navigates to a post page.
Future<DeepLinkResult> _navigateToPost(BuildContext context, String link) async {
  if (!context.mounted) return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);

  final postId = await getLemmyPostId(context, link);
  if (postId == null) throw EntityResolutionException(link);

  try {
    final lemmy = LemmyClient.instance.lemmyApiV3;
    final account = await fetchActiveProfile();
    final response = await lemmy.run(GetPost(id: postId, auth: account.jwt));

    // Check context.mounted after long-running API operations
    if (!context.mounted) return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);

    navigateToPost(context, postViewMedia: (await parsePostViews([response.postView])).first);
    return DeepLinkResult.successful();
  } catch (e) {
    throw EntityResolutionException(link);
  }
}

/// Navigates to a community page.
Future<DeepLinkResult> _navigateToCommunity(BuildContext context, String link) async {
  if (!context.mounted) return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);

  final communityName = await getLemmyCommunity(link);
  if (communityName == null) throw EntityResolutionException(link);

  try {
    await navigateToFeedPage(context, feedType: FeedType.community, communityName: communityName);
    return DeepLinkResult.successful();
  } catch (e) {
    throw EntityResolutionException(link);
  }
}

/// Navigates to the modlog page with optional filter parameters for action type, community, user, and moderator.
Future<DeepLinkResult> _navigateToModlog(BuildContext context, String link) async {
  if (!context.mounted) return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);

  try {
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasAuthority) throw InvalidUrlException(link);

    final lemmyClient = LemmyClient()..changeBaseUrl(uri.host);

    ModlogActionType actionType;
    try {
      actionType = ModlogActionType.fromJson(uri.queryParameters['actionType'] ?? ModlogActionType.all.value);
    } catch (_) {
      actionType = ModlogActionType.all;
    }

    final communityId = int.tryParse(uri.queryParameters['communityId'] ?? '');
    final userId = int.tryParse(uri.queryParameters['userId'] ?? '');
    final moderatorId = int.tryParse(uri.queryParameters['modId'] ?? '');

    await navigateToModlogPage(
      context,
      modlogActionType: actionType,
      communityId: communityId,
      userId: userId,
      moderatorId: moderatorId,
      lemmyClient: lemmyClient,
    );

    return DeepLinkResult.successful();
  } catch (e) {
    if (e is InvalidUrlException) rethrow;
    throw EntityResolutionException(link);
  }
}

/// Navigates to a specific comment.
Future<DeepLinkResult> _navigateToComment(BuildContext context, String link) async {
  if (!context.mounted) return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);

  final commentId = await getLemmyCommentId(context, link);
  if (commentId == null) throw EntityResolutionException(link);

  try {
    final lemmy = LemmyClient.instance.lemmyApiV3;
    final account = await fetchActiveProfile();
    final response = await lemmy.run(GetComment(id: commentId, auth: account.jwt));

    // Check context.mounted after long-running API operations
    if (!context.mounted) return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);

    navigateToComment(context, response.commentView);
    return DeepLinkResult.successful();
  } catch (e) {
    throw EntityResolutionException(link);
  }
}

/// Navigates to a user profile page.
Future<DeepLinkResult> _navigateToUser(BuildContext context, String link) async {
  if (!context.mounted) return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);

  final username = await getLemmyUser(link);
  if (username == null) throw EntityResolutionException(link);

  try {
    await navigateToFeedPage(context, feedType: FeedType.user, username: username);
    return DeepLinkResult.successful();
  } catch (e) {
    throw EntityResolutionException(link);
  }
}

/// Handles Thunder-specific internal navigation. This includes navigation to specific settings pages using 'setting-' prefix
///
/// Throws [InvalidUrlException] if the link format is invalid
/// Throws [EntityResolutionException] if the target setting cannot be found
Future<DeepLinkResult> _navigateToInternal(BuildContext context, String link) async {
  link = link.replaceFirst('https://', '');
  if (!link.startsWith('setting-')) throw InvalidUrlException(link);

  final setting = link.replaceFirst('setting-', '');

  try {
    final localSetting = LocalSettings.values.firstWhere((localSetting) => localSetting.name == setting, orElse: () => throw EntityResolutionException(link));

    navigateToSettingPage(context, localSetting, settingToHighlight: localSetting);
    return DeepLinkResult.successful();
  } catch (e) {
    if (e is EntityResolutionException) rethrow;
    throw InvalidUrlException(link);
  }
}
