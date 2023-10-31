import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/instance/instance_page.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

Future<void> navigateToInstancePage(BuildContext context, {required String instanceHost}) async {
  ThunderBloc thunderBloc = context.read<ThunderBloc>();
  AuthBloc authBloc = context.read<AuthBloc>();

  final bool reduceAnimations = thunderBloc.state.reduceAnimations;

  GetSiteResponse? getSiteResponse;
  try {
    getSiteResponse = await LemmyApiV3(instanceHost).run(const GetSite()).timeout(const Duration(seconds: 5));
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
          ),
        ),
      ),
    );
  }
}
