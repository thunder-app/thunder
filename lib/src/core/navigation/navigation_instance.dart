import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/navigation/link_navigation_utils.dart';
import 'package:thunder/src/core/navigation/loading_page.dart';
import 'package:thunder/src/core/navigation/route_scope.dart';
import 'package:thunder/src/core/navigation/swipeable_page_route.dart';
import 'package:thunder/src/core/services/platform_detection_service.dart';
import 'package:thunder/src/core/utils/platform_version_cache.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart' hide detectPlatformFromNodeInfo;
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/settings/settings.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

/// Navigates to the instance page for the given [instanceHost].
///
/// When [instanceId] is provided, the instance page will allow the option to block that given instance. This value represents
/// the id of the navigated instance from the original instance (e.g., lemmy.ml's instance id from lemmy.world).
Future<void> navigateToInstancePage(BuildContext context, {Account? account, required String instanceHost, required int? instanceId}) async {
  showLoadingPage(context);

  final reduceAnimations = context.read<ThemePreferencesCubit>().state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = context.read<GesturePreferencesCubit>().state.enableFullScreenSwipeNavigationGesture;

  final canonicalInstanceHost = normalizeInstanceHost(instanceHost) ?? instanceHost;
  final platformInfo = await detectPlatformFromNodeInfo(canonicalInstanceHost);
  final platform = platformInfo?['platform'] ?? ThreadiversePlatform.lemmy; // Fallback to Lemmy if we can't detect the platform
  PlatformVersionCache().trySet(canonicalInstanceHost, platformInfo?['version']?.toString());

  ThunderSiteResponse? site;

  try {
    // Get the site information by connecting to the given instance
    final account = Account(id: '', index: -1, instance: canonicalInstanceHost, platform: platform);
    site = await createInstanceRepository(account).info().timeout(const Duration(seconds: 5));
  } catch (e) {
    // Continue if we can't get the site
  }

  final fallbackAccount = Account(id: '', index: -1, anonymous: true, instance: canonicalInstanceHost, platform: platform);
  final routeScope = resolveAccountAwareRouteScope(context, account: account, fallbackAccount: fallbackAccount, useActiveAccount: true, includeThunderCubit: true);
  final effectiveAccount = routeScope.account;

  final route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
        ? const Duration(milliseconds: 100)
        : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: true,
    builder: (_) => MultiBlocProvider(
      providers: routeScope.providers(provideThunderCubit: true),
      child: InstancePage(
        account: effectiveAccount,
        instance: ThunderInstanceInfo(
          id: instanceId,
          domain: site!.site.actorId,
          name: site.site.name,
          description: site.site.description,
          sidebar: site.site.sidebar,
          icon: site.site.icon,
          users: site.site.users,
          version: site.version,
          platform: platform,
          contentWarning: site.site.contentWarning,
        ),
      ),
    ),
  );

  if (site != null) {
    pushOnTopOfLoadingPage(context, route);
  } else {
    final l10n = GlobalContext.l10n;

    showThunderSnackbar(
      l10n.unableToNavigateToInstance(instanceHost),
      trailingAction: () => handleLink(context, url: "https://$instanceHost", forceOpenInBrowser: true),
      trailingIcon: Icons.open_in_browser_rounded,
    );

    hideLoadingPage(context);
  }
}
