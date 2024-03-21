import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/instance/pages/instance_page.dart';
import 'package:thunder/shared/pages/loading_page.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

Future<void> navigateToInstancePage(BuildContext context, {required String instanceHost, required int? instanceId}) async {
  showLoadingPage(context);

  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final ThunderBloc thunderBloc = context.read<ThunderBloc>();
  final bool reduceAnimations = thunderBloc.state.reduceAnimations;
  final Account? account = await fetchActiveProfileAccount();

  GetSiteResponse? getSiteResponse;
  bool? isBlocked;

  try {
    getSiteResponse = await LemmyApiV3(instanceHost).run(const GetSite()).timeout(const Duration(seconds: 5));

    // Check whether this instance is blocked (we have to get our user from our current site first).
    final GetSiteResponse localSite = await LemmyClient.instance.lemmyApiV3.run(GetSite(auth: account?.jwt)).timeout(const Duration(seconds: 5));
    isBlocked = localSite.myUser?.instanceBlocks?.any((i) => i.instance.domain == instanceHost) == true;
  } catch (e) {}

  if (context.mounted) {
    if (getSiteResponse?.siteView.site != null) {
      pushOnTopOfLoadingPage(
        context,
        SwipeablePageRoute(
          transitionDuration: isLoadingPageShown
              ? Duration.zero
              : reduceAnimations
                  ? const Duration(milliseconds: 100)
                  : null,
          reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
          backGestureDetectionWidth: 45,
          canOnlySwipeFromEdge: !thunderBloc.state.enableFullScreenSwipeNavigationGesture,
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: thunderBloc),
            ],
            child: InstancePage(
              getSiteResponse: getSiteResponse!,
              isBlocked: isBlocked,
              instanceId: instanceId,
            ),
          ),
        ),
      );
    } else {
      showSnackbar(l10n.unableToNavigateToInstance(instanceHost), usePostFrameCallback: false);
      hideLoadingPage(context);
    }
  }
}
