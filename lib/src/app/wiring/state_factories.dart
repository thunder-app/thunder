import 'package:thunder/src/app/state/app_bootstrap_cubit/app_bootstrap_cubit.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/app/wiring/nodeinfo_platform_detection_service.dart';
import 'package:thunder/src/app/state/deep_links_cubit/deep_links_cubit.dart';
import 'package:thunder/src/app/state/network_checker_cubit/network_checker_cubit.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/account/api.dart';
import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/community/api.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/inbox/api.dart';
import 'package:thunder/src/features/instance/api.dart';
import 'package:thunder/src/features/moderator/api.dart';
import 'package:thunder/src/features/notification/api.dart';
import 'package:thunder/src/features/post/api.dart';
import 'package:thunder/src/features/search/api.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/features/user/api.dart';
import 'package:thunder/src/features/instance/presentation/state/instance_page_bloc.dart';

AppBootstrapCubit createAppBootstrapCubit() {
  return AppBootstrapCubit(
    versionChecker: const GithubVersionChecker(),
  );
}

ThunderCubit createThunderCubit() {
  return ThunderCubit(
    preferencesStore: const UserPreferencesStore(),
  );
}

DeepLinksCubit createDeepLinksCubit() {
  return DeepLinksCubit(
    deepLinkService: AppLinksDeepLinkService(),
    localizationService: const GlobalContextLocalizationService(),
  );
}

NetworkCheckerCubit createNetworkCheckerCubit() {
  return NetworkCheckerCubit(
    connectivityService: DefaultConnectivityService(),
  );
}

ProfileBloc createProfileBloc(Account account) {
  return ProfileBloc(
    account: account,
    instanceRepositoryFactory: (account) => InstanceRepositoryImpl(account: account),
    accountRepositoryFactory: (account) => AccountRepositoryImpl(account: account),
    userRepositoryFactory: (account) => UserRepositoryImpl(account: account),
    platformDetectionService: const NodeInfoPlatformDetectionService(),
    localizationService: const GlobalContextLocalizationService(),
  );
}

SessionBloc createSessionBloc() {
  return SessionBloc(
    sessionRepository: const PersistentSessionRepository(),
    accountRepositoryFactory: (account) => AccountRepositoryImpl(account: account),
    instanceRepositoryFactory: (account) => InstanceRepositoryImpl(account: account),
    platformDetectionService: const NodeInfoPlatformDetectionService(),
    localizationService: const GlobalContextLocalizationService(),
  );
}

FeedBloc createFeedBloc(Account account) {
  return FeedBloc(
    account: account,
    postRepository: PostRepositoryImpl(account: account),
    communityRepository: CommunityRepositoryImpl(account: account),
    userRepository: UserRepositoryImpl(account: account),
  );
}

InstancePageBloc createInstancePageBloc({
  required Account account,
  required ThunderInstanceInfo instanceInfo,
}) {
  final uri = Uri.parse(instanceInfo.domain);
  final remoteAccount = Account(
    instance: uri.host,
    id: '',
    index: -1,
    platform: instanceInfo.platform,
  );

  return InstancePageBloc(
    account: account,
    instanceInfo: instanceInfo,
    repository: SearchRepositoryImpl(account: remoteAccount),
    localRepository: SearchRepositoryImpl(account: account),
  );
}

SearchBloc createSearchBloc(Account account) {
  return SearchBloc(
    account: account,
    commentRepository: CommentRepositoryImpl(account: account),
    searchRepository: SearchRepositoryImpl(account: account),
    communityRepository: CommunityRepositoryImpl(account: account),
    userRepository: UserRepositoryImpl(account: account),
    instanceRepository: InstanceRepositoryImpl(account: account),
  );
}

InboxBloc createInboxBloc(Account account) {
  return InboxBloc(
    account: account,
    commentRepository: CommentRepositoryImpl(account: account),
    notificationRepository: NotificationRepositoryImpl(account: account),
    localizationService: const GlobalContextLocalizationService(),
  );
}

InboxBloc createInboxBlocWithInitial({
  required Account account,
  required List<ThunderComment> replies,
  required bool showUnreadOnly,
}) {
  return InboxBloc.initWith(
    account: account,
    replies: replies,
    showUnreadOnly: showUnreadOnly,
    commentRepository: CommentRepositoryImpl(account: account),
    notificationRepository: NotificationRepositoryImpl(account: account),
    localizationService: const GlobalContextLocalizationService(),
  );
}

PostBloc createPostBloc(Account account) {
  return PostBloc(
    account: account,
    postRepository: PostRepositoryImpl(account: account),
    commentRepository: CommentRepositoryImpl(account: account),
    communityRepository: CommunityRepositoryImpl(account: account),
    preferencesStore: const UserPreferencesStore(),
    localizationService: const GlobalContextLocalizationService(),
  );
}

CreatePostCubit createCreatePostCubit(Account account) {
  return CreatePostCubit(
    account: account,
    postRepositoryFactory: (account) => PostRepositoryImpl(account: account),
    accountRepositoryFactory: (account) => AccountRepositoryImpl(account: account),
    localizationService: const GlobalContextLocalizationService(),
  );
}

CreateCommentCubit createCreateCommentCubit(Account account) {
  return CreateCommentCubit(
    account: account,
    commentRepositoryFactory: (account) => CommentRepositoryImpl(account: account),
    accountRepositoryFactory: (account) => AccountRepositoryImpl(account: account),
    localizationService: const GlobalContextLocalizationService(),
  );
}

AccountSettingsCubit createAccountSettingsCubit(Account account, {ThunderSiteResponse? initialSiteResponse}) {
  return AccountSettingsCubit(
    account: account,
    accountRepository: AccountRepositoryImpl(account: account),
    localizationService: const GlobalContextLocalizationService(),
    initialSiteResponse: initialSiteResponse,
  );
}

UserBlocksCubit createUserBlocksCubit(Account account) {
  return UserBlocksCubit(
    account: account,
    instanceRepository: InstanceRepositoryImpl(account: account),
    communityRepository: CommunityRepositoryImpl(account: account),
    userRepository: UserRepositoryImpl(account: account),
    localizationService: const GlobalContextLocalizationService(),
  );
}

UserMediaCubit createUserMediaCubit(Account account) {
  return UserMediaCubit(
    account: account,
    accountRepository: AccountRepositoryImpl(account: account),
    searchRepository: SearchRepositoryImpl(account: account),
    localizationService: const GlobalContextLocalizationService(),
  );
}

ReportBloc createReportBloc(Account account) {
  return ReportBloc(
    account: account,
    localizationService: const GlobalContextLocalizationService(),
  );
}
