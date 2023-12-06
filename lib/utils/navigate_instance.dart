import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/instance/instance_page.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/swipe.dart';

Future<void> navigateToInstancePage(BuildContext context, {required String instanceHost, required int? instanceId}) async {
  ThunderBloc thunderBloc = context.read<ThunderBloc>();
  AuthBloc authBloc = context.read<AuthBloc>();

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

  if (getSiteResponse?.siteView.site != null && context.mounted) {
    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        backGestureDetectionWidth: 45,
        canOnlySwipeFromEdge: !thunderBloc.state.enableFullScreenSwipeNavigationGesture,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: thunderBloc),
          ],
          child: InstancePage(
            site: getSiteResponse!.siteView.site,
            isBlocked: isBlocked,
            instanceId: instanceId,
          ),
        ),
      ),
    );
  }
}
