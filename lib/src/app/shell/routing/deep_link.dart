import 'package:flutter/material.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/app/shell/routing/deep_link_enums.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/app/shell/navigation/link_navigation_utils.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar;

/// Custom exception for deep link related errors
class DeepLinkException implements Exception {
  final String message;
  final String? url;
  final DeepLinkErrorType type;

  DeepLinkException(this.message, {this.url, this.type = DeepLinkErrorType.unknown});

  @override
  String toString() => message;
}

/// Enum representing different types of deep link errors
enum DeepLinkErrorType { invalidUrl, initialization, entityResolution, timeout, unknown }

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
/// The function handles various error cases and shows appropriate error messages
/// when navigation fails, with options to open failed links in an external browser.
Future<void> handleDeepLinkNavigation(BuildContext context, {required LinkType linkType, String? link}) async {
  if (!context.mounted) return;

  String? errorMessage;
  String? fallbackUrl;

  try {
    if (link == null || link.trim().isEmpty) {
      throw DeepLinkException(GlobalContext.l10n.invalidUrl, type: DeepLinkErrorType.invalidUrl);
    }

    await _initializeLemmyClient(context);

    final normalizedLink = _normalizeLink(link);
    if (normalizedLink.isEmpty) {
      throw DeepLinkException(GlobalContext.l10n.invalidUrl, url: link, type: DeepLinkErrorType.invalidUrl);
    }

    final result = await _handleNavigation(context, linkType, normalizedLink).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw DeepLinkException(GlobalContext.l10n.timeoutErrorMessage, url: link, type: DeepLinkErrorType.timeout),
    );

    if (!result.success) {
      errorMessage = result.errorMessage ?? GlobalContext.l10n.uriNotSupported;
      fallbackUrl = result.fallbackUrl;
    }
  } on DeepLinkException catch (e) {
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

/// Initializes the client with the currently active profile. Includes retry logic and validation.
Future<void> _initializeLemmyClient(BuildContext context) async {
  int maxRetries = 2;
  int attempts = 0;

  while (attempts < maxRetries) {
    try {
      final account = resolveActiveAccount(context);
      if (account.instance.isEmpty) {
        throw DeepLinkException(GlobalContext.l10n.errorNoActiveInstance, type: DeepLinkErrorType.initialization);
      }

      // Validate connection by making a simple request
      await InstanceRepositoryImpl(account: account).info();
      return;
    } catch (e) {
      attempts++;
      if (attempts >= maxRetries) {
        throw DeepLinkException('${GlobalContext.l10n.errorInitializingClient} (${e.toString()})', type: DeepLinkErrorType.initialization);
      }
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
  if (!context.mounted) {
    return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);
  }

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
    if (host.isEmpty) {
      throw DeepLinkException(GlobalContext.l10n.invalidUrl, url: link, type: DeepLinkErrorType.invalidUrl);
    }

    await navigateToInstancePage(context, instanceHost: host, instanceId: null);
    return DeepLinkResult.successful();
  } catch (e) {
    if (e is DeepLinkException) rethrow;
    throw DeepLinkException(GlobalContext.l10n.exceptionProcessingUri, url: link, type: DeepLinkErrorType.entityResolution);
  }
}

/// Navigates to a post page.
Future<DeepLinkResult> _navigateToPost(BuildContext context, String link) async {
  if (!context.mounted) {
    return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);
  }

  final postId = await getLemmyPostId(context, link);
  if (postId == null) {
    throw DeepLinkException(GlobalContext.l10n.exceptionProcessingUri, url: link, type: DeepLinkErrorType.entityResolution);
  }

  try {
    final account = resolveEffectiveAccount(context);
    final post = await PostRepositoryImpl(account: account).getPost(postId);

    if (!context.mounted) {
      return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);
    }

    navigateToPost(context, post: post?['post']);
    return DeepLinkResult.successful();
  } catch (e) {
    throw DeepLinkException(GlobalContext.l10n.exceptionProcessingUri, url: link, type: DeepLinkErrorType.entityResolution);
  }
}

/// Navigates to a community page.
Future<DeepLinkResult> _navigateToCommunity(BuildContext context, String link) async {
  if (!context.mounted) {
    return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);
  }

  final communityName = await getLemmyCommunity(link);
  if (communityName == null) {
    throw DeepLinkException(GlobalContext.l10n.exceptionProcessingUri, url: link, type: DeepLinkErrorType.entityResolution);
  }

  try {
    await navigateToFeedPage(context, feedType: FeedType.community, communityName: communityName);
    return DeepLinkResult.successful();
  } catch (e) {
    throw DeepLinkException(GlobalContext.l10n.exceptionProcessingUri, url: link, type: DeepLinkErrorType.entityResolution);
  }
}

/// Navigates to the modlog page with optional filter parameters for action type, community, user, and moderator.
Future<DeepLinkResult> _navigateToModlog(BuildContext context, String link) async {
  if (!context.mounted) {
    return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);
  }

  try {
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasAuthority) {
      throw DeepLinkException(GlobalContext.l10n.invalidUrl, url: link, type: DeepLinkErrorType.invalidUrl);
    }

    ModlogActionType actionType;
    try {
      actionType = ModlogActionType.values.firstWhere(
        (type) => type.name.toLowerCase() == uri.queryParameters['actionType']?.toLowerCase(),
        orElse: () => ModlogActionType.all,
      );
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
      subtitle: uri.host,
    );

    return DeepLinkResult.successful();
  } catch (e) {
    if (e is DeepLinkException) rethrow;
    throw DeepLinkException(GlobalContext.l10n.exceptionProcessingUri, url: link, type: DeepLinkErrorType.entityResolution);
  }
}

/// Navigates to a specific comment.
Future<DeepLinkResult> _navigateToComment(BuildContext context, String link) async {
  if (!context.mounted) {
    return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);
  }

  final commentId = await getLemmyCommentId(context, link);
  if (commentId == null) {
    throw DeepLinkException(GlobalContext.l10n.exceptionProcessingUri, url: link, type: DeepLinkErrorType.entityResolution);
  }

  try {
    if (!context.mounted) {
      return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);
    }
    final account = resolveEffectiveAccount(context);
    final comment = await CommentRepositoryImpl(account: account).getComment(commentId);

    navigateToComment(context, comment);
    return DeepLinkResult.successful();
  } catch (e) {
    throw DeepLinkException(GlobalContext.l10n.exceptionProcessingUri, url: link, type: DeepLinkErrorType.entityResolution);
  }
}

/// Navigates to a user profile page.
Future<DeepLinkResult> _navigateToUser(BuildContext context, String link) async {
  if (!context.mounted) {
    return DeepLinkResult.failure(GlobalContext.l10n.unexpectedError);
  }

  final username = await getLemmyUser(link);
  if (username == null) {
    throw DeepLinkException(GlobalContext.l10n.exceptionProcessingUri, url: link, type: DeepLinkErrorType.entityResolution);
  }

  try {
    await navigateToFeedPage(context, feedType: FeedType.user, username: username);
    return DeepLinkResult.successful();
  } catch (e) {
    throw DeepLinkException(GlobalContext.l10n.exceptionProcessingUri, url: link, type: DeepLinkErrorType.entityResolution);
  }
}

/// Handles Thunder-specific internal navigation. This includes navigation to specific settings pages using 'setting-' prefix
///
/// Throws [DeepLinkException] if the link format is invalid or the target setting cannot be found
Future<DeepLinkResult> _navigateToInternal(BuildContext context, String link) async {
  link = link.replaceFirst('https://', '');
  if (!link.startsWith('setting-')) {
    throw DeepLinkException(GlobalContext.l10n.invalidUrl, url: link, type: DeepLinkErrorType.invalidUrl);
  }

  final setting = link.replaceFirst('setting-', '');

  try {
    final localSetting = LocalSettings.values.firstWhere(
      (localSetting) => localSetting.name == setting,
      orElse: () => throw DeepLinkException(GlobalContext.l10n.exceptionProcessingUri, url: link, type: DeepLinkErrorType.entityResolution),
    );

    navigateToSettingPage(context, localSetting, settingToHighlight: localSetting);
    return DeepLinkResult.successful();
  } catch (e) {
    if (e is DeepLinkException) rethrow;
    throw DeepLinkException(GlobalContext.l10n.invalidUrl, url: link, type: DeepLinkErrorType.invalidUrl);
  }
}
