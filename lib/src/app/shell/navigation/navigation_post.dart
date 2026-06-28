part of 'navigation_utils.dart';

({String accountId, String postApId, post_bloc.PostBloc postBloc})? _cachedPostBloc;

/// Navigates to the post page with the given [post] or [postId].
///
/// One of [post] or [postId] must be provided. If [post] is provided, the post page will use that data to display the post.
/// Otherwise, the post page will fetch the post with the given [postId].
Future<void> navigateToPost(
  BuildContext context, {
  Account? account,
  int? postId,
  ThunderPost? post,
  int? highlightedCommentId,
  Function(ThunderPost post)? onPostUpdated,
}) async {
  assert((postId != null || post != null), 'One of the parameters must be provided');

  final routeScope = resolveAccountAwareRouteScope(context, account: account, includeThunderCubit: true);
  final effectiveAccount = routeScope.account;

  // Optional blocs
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>();
  final feedBloc = hasFeedBloc != null ? context.read<FeedBloc>() : null;

  ThunderPost? pvm = post;

  if (pvm == null) {
    final response = await PostRepositoryImpl(account: effectiveAccount).getPost(postId!);
    pvm = response?.post;
  }

  // Mark post as read when tapped
  if (!effectiveAccount.anonymous) {
    feedBloc?.add(FeedItemActionedEvent(postId: pvm!.id, postAction: PostAction.read, actionInput: const ReadPostInput(true)));
  }

  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  final post_bloc.PostBloc postBloc = _cachedPostBloc?.accountId == effectiveAccount.id && _cachedPostBloc?.postApId == pvm!.apId
      ? _cachedPostBloc!.postBloc
      : (_cachedPostBloc = (
          accountId: effectiveAccount.id,
          postApId: pvm!.apId,
          postBloc: createPostBloc(effectiveAccount),
        ))
          .postBloc;

  final route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    backGestureDetectionStartOffset: !kIsWeb && Platform.isAndroid ? 45 : 0,
    backGestureDetectionWidth: 45,
    canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: !effectiveAccount.anonymous, state: gestureCubit.state, isPostPage: true) || !enableFullScreenSwipeNavigationGesture,
    builder: (_) {
      final postNavigationCubit = PostNavigationCubit();
      if (highlightedCommentId != null) {
        postNavigationCubit.setHighlightedCommentId(highlightedCommentId);
      }

      return MultiBlocProvider(
        providers: routeScope.providers(
          provideThunderCubit: true,
          extraProviders: [
            BlocProvider<post_bloc.PostBloc>.value(value: postBloc),
            BlocProvider<PostNavigationCubit>.value(value: postNavigationCubit),
            BlocProvider<AnonymousSubscriptionsCubit>(create: (context) => AnonymousSubscriptionsCubit()..loadSubscribedCommunities()),
          ],
        ),
        child: PostPage(
          initialPost: postBloc.state.post ?? pvm!,
          highlightedCommentId: highlightedCommentId,
          onPostUpdated: (ThunderPost post) {
            // Manually marking the read attribute as true when navigating to post since there is a case where the API call to mark the post as read from the feed page is not completed in time
            feedBloc?.add(FeedItemUpdatedEvent(post: post.copyWith(context: post.context.copyWith(read: true))));
          },
        ),
      );
    },
  );

  pushOnTopOfLoadingPage(context, route);
}

Future<ThunderPost> getPostFromComment(ThunderComment comment, Account account) async {
  if (comment.post != null) return comment.post!;

  final response = await PostRepositoryImpl(account: account).getPost(comment.postId, commentId: comment.id);
  return response!.post;
}

Future<void> navigateToComment(BuildContext context, ThunderComment comment) async {
  final routeScope = resolveAccountAwareRouteScope(context, includeThunderCubit: true);
  final gestureCubit = context.read<GesturePreferencesCubit>();

  final effectiveAccount = routeScope.account;

  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;

  final route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    backGestureDetectionWidth: 45,
    canSwipe: !kIsWeb && Platform.isIOS || gestureCubit.state.enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: !effectiveAccount.anonymous, state: gestureCubit.state, isPostPage: true) || !gestureCubit.state.enableFullScreenSwipeNavigationGesture,
    builder: (context) {
      final postNavigationCubit = PostNavigationCubit();
      postNavigationCubit.setHighlightedCommentId(comment.id);

      return MultiBlocProvider(
        providers: routeScope.providers(
          provideThunderCubit: true,
          extraProviders: [
            BlocProvider<PostBloc>(create: (context) => createPostBloc(effectiveAccount)),
            BlocProvider<PostNavigationCubit>.value(value: postNavigationCubit),
          ],
        ),
        child: FutureBuilder<ThunderPost>(
          future: getPostFromComment(comment, effectiveAccount),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return PostPage(
                initialPost: snapshot.data!,
                highlightedCommentId: comment.id,
                commentPath: comment.path,
                onPostUpdated: (ThunderPost post) {},
              );
            }

            return LoadingPage();
          },
        ),
      );
    },
  );

  pushOnTopOfLoadingPage(context, route);
}

Future<ThunderComment?> navigateToCreateCommentPage(
  BuildContext context, {
  Account? account,
  ThunderPost? post,
  ThunderComment? comment,
  ThunderComment? parentComment,
  Function(ThunderComment comment, bool userChanged)? onCommentSuccess,
}) async {
  assert(!(post == null && parentComment == null && comment == null));
  assert(!(post != null && (parentComment != null || comment != null)));

  final routeScope = resolveAccountAwareRouteScope(context, account: account, includeThunderCubit: true);
  final effectiveAccount = routeScope.account;
  final createCommentCubit = createCreateCommentCubit(effectiveAccount);

  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  final SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: true,
    builder: (context) => MultiBlocProvider(
      providers: routeScope.providers(
        provideThunderCubit: true,
        extraProviders: [
          BlocProvider<CreateCommentCubit>.value(value: createCommentCubit),
        ],
      ),
      child: CreateCommentPage(
        account: effectiveAccount,
        post: post,
        comment: comment,
        parentComment: parentComment,
        onCommentSuccess: onCommentSuccess,
      ),
    ),
  );

  final result = await pushOnTopOfLoadingPage(context, route);
  if (result is ThunderComment) return result;
  return null;
}

Future<void> navigateToCreatePostPage(
  BuildContext context, {
  Account? account,
  String? title,
  String? text,
  File? image,
  String? url,
  bool? prePopulated,
  int? communityId,
  ThunderCommunity? community,
  ThunderPost? post,
  bool isCrossPost = false,
  Function(ThunderPost post, bool)? onPostSuccess,
}) async {
  try {
    final l10n = AppLocalizations.of(context)!;
    final routeScope = resolveAccountAwareRouteScope(context, account: account, includeThunderCubit: true);
    final effectiveAccount = routeScope.account;

    FeedBloc? feedBloc;
    PostBloc? postBloc;
    CreatePostCubit createPostCubit = createCreatePostCubit(effectiveAccount);

    final themeCubit = context.read<ThemePreferencesCubit>();
    final bool reduceAnimations = themeCubit.state.reduceAnimations;
    final gestureCubit = context.read<GesturePreferencesCubit>();
    final bool enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

    try {
      feedBloc = context.read<FeedBloc>();
    } catch (e) {
      // Don't need feed block if we're not opening post in the context of a feed.
    }

    try {
      postBloc = context.read<PostBloc>();
    } catch (e) {
      // It's ok if we don't get the PostBloc
    }

    ThunderCommunity? pvmCommunity;

    if (post != null) {
      pvmCommunity = post.community;
    }

    await Navigator.of(context).push(SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: true,
      backGestureDetectionWidth: 45,
      builder: (navigatorContext) {
        return MultiBlocProvider(
          providers: [
            feedBloc != null ? BlocProvider<FeedBloc>.value(value: feedBloc) : BlocProvider<FeedBloc>(create: (context) => createFeedBloc(effectiveAccount)),
            if (postBloc != null) BlocProvider<PostBloc>.value(value: postBloc),
            ...routeScope.providers(provideThunderCubit: true),
            BlocProvider<CreatePostCubit>.value(value: createPostCubit),
          ],
          child: CreatePostPage(
            account: effectiveAccount,
            title: title,
            text: text,
            image: image,
            url: url,
            prePopulated: prePopulated,
            communityId: communityId ?? post?.community!.id,
            community: community ?? (post != null ? pvmCommunity : null),
            post: post,
            isCrossPost: isCrossPost,
            onPostSuccess: (ThunderPost updatedPost, bool userChanged) {
              // Update the existing post view media if it exists
              if (feedBloc != null) {
                feedBloc.add(FeedItemUpdatedEvent(post: updatedPost));
              }
              if (postBloc != null) {
                postBloc.add(PostUpdatedEvent(post: updatedPost));
              }

              // Show snackbar message if the post was just created
              if (!userChanged && post == null) {
                try {
                  showSnackbar(
                    l10n.postCreatedSuccessfully,
                    trailingIcon: Icons.remove_red_eye_rounded,
                    trailingAction: () {
                      navigateToPost(context, account: effectiveAccount, post: updatedPost);
                    },
                  );
                } catch (e) {
                  if (context.mounted) {
                    showSnackbar("${AppLocalizations.of(context)!.unexpectedError}: $e");
                  }
                }
              }

              if (onPostSuccess != null) {
                onPostSuccess(updatedPost, userChanged);
              }
            },
          ),
        );
      },
    ));
  } catch (e) {
    if (context.mounted) {
      showSnackbar(AppLocalizations.of(context)!.unexpectedError);
    }
  }
}
