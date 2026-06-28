import 'package:dart_ping/dart_ping.dart';

import 'package:thunder/src/app/state/app_bootstrap_cubit/app_bootstrap_cubit.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/app/wiring/nodeinfo_platform_detection_service.dart';
import 'package:thunder/src/app/state/deep_links_cubit/deep_links_cubit.dart';
import 'package:thunder/src/app/state/network_checker_cubit/network_checker_cubit.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/account/api.dart';
import 'package:thunder/src/features/account/presentation/state/instance_validation_cubit.dart';
import 'package:thunder/src/features/account/presentation/state/profile_modal_cubit.dart';
import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/community/api.dart';
import 'package:thunder/src/features/drafts/drafts.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/inbox/api.dart';
import 'package:thunder/src/features/instance/api.dart';
import 'package:thunder/src/foundation/networking/discovery/instance_discovery_service.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart' show fetchInstanceNameFromUrl;
import 'package:thunder/src/features/moderator/api.dart';
import 'package:thunder/src/features/notification/api.dart';
import 'package:thunder/src/features/post/api.dart';
import 'package:thunder/src/features/private_message/api.dart';
import 'package:thunder/src/features/search/api.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/features/user/api.dart';
import 'package:thunder/src/features/instance/presentation/state/instance_page_bloc.dart';
import 'package:thunder/src/foundation/services/localization_service.dart';

AccountRepository createAccountRepository(Account account) => AccountRepositoryImpl(account: account);
CommentRepository createCommentRepository(Account account) => CommentRepositoryImpl(account: account);
CommunityRepository createCommunityRepository(Account account) => CommunityRepositoryImpl(account: account);
InstanceRepository createInstanceRepository(Account account) => InstanceRepositoryImpl(account: account);
LinkMetadataRepository createLinkMetadataRepository(Account account) => LinkMetadataRepositoryImpl(account: account);
NotificationRepository createNotificationRepository(Account account) => NotificationRepositoryImpl(account: account);
PostRepository createPostRepository(Account account) => PostRepositoryImpl(account: account);
PrivateMessageRepository createPrivateMessageRepository(Account account) => PrivateMessageRepositoryImpl(account: account);
ReportRepository createReportRepository(Account account) => ReportRepositoryImpl(account: account);
SearchRepository createSearchRepository(Account account) => SearchRepositoryImpl(account: account);
SearchService createSearchService(Account account) => SearchService(searchRepository: createSearchRepository(account));
UserRepository createUserRepository(Account account) => UserRepositoryImpl(account: account);

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
    localizationService: const ThunderLocalizationService(),
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
    instanceRepositoryFactory: createInstanceRepository,
    accountRepositoryFactory: createAccountRepository,
    userRepositoryFactory: createUserRepository,
    platformDetectionService: const NodeInfoPlatformDetectionService(),
    localizationService: const ThunderLocalizationService(),
  );
}

InstanceValidationCubit createInstanceValidationCubit() {
  return InstanceValidationCubit();
}

ProfileModalCubit createProfileModalCubit({required bool quickSelectMode}) {
  return ProfileModalCubit(
    sessionRepository: SessionRepositoryImpl(),
    quickSelectMode: quickSelectMode,
    instanceInfoLookup: (instance) => getInstanceInfo(instance).timeout(
      const Duration(seconds: 5),
      onTimeout: () => ThunderInstanceInfo(
        domain: instance,
        name: fetchInstanceNameFromUrl(instance) ?? instance,
        success: false,
      ),
    ),
    pingLookup: (instance) async {
      final pingData = await Ping(instance, count: 1, timeout: 5).stream.first;
      return pingData.response?.time;
    },
    unreadCountLookup: (account) async {
      final unread = await createNotificationRepository(account).unreadNotificationsCount();
      return unread.total == 0 ? null : unread.total;
    },
  );
}

SessionBloc createSessionBloc() {
  return SessionBloc(
    sessionRepository: SessionRepositoryImpl(),
    accountRepositoryFactory: createAccountRepository,
    instanceRepositoryFactory: createInstanceRepository,
    localizationService: const ThunderLocalizationService(),
  );
}

FeedBloc createFeedBloc(Account account) {
  return FeedBloc(
    account: account,
    postRepository: createPostRepository(account),
    communityRepository: createCommunityRepository(account),
    userRepository: createUserRepository(account),
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
    repository: createSearchRepository(remoteAccount),
    localRepository: createSearchRepository(account),
  );
}

SearchBloc createSearchBloc(Account account) {
  return SearchBloc(
    account: account,
    commentRepository: createCommentRepository(account),
    searchService: createSearchService(account),
    communityRepository: createCommunityRepository(account),
    userRepository: createUserRepository(account),
    instanceRepository: createInstanceRepository(account),
  );
}

InboxBloc createInboxBloc(Account account) {
  return InboxBloc(
    account: account,
    commentRepository: createCommentRepository(account),
    notificationRepository: createNotificationRepository(account),
    privateMessageRepository: createPrivateMessageRepository(account),
    localizationService: const ThunderLocalizationService(),
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
    commentRepository: createCommentRepository(account),
    notificationRepository: createNotificationRepository(account),
    privateMessageRepository: createPrivateMessageRepository(account),
    localizationService: const ThunderLocalizationService(),
  );
}

PostBloc createPostBloc(Account account) {
  return PostBloc(
    account: account,
    postRepository: createPostRepository(account),
    commentRepository: createCommentRepository(account),
    communityRepository: createCommunityRepository(account),
    preferencesStore: const UserPreferencesStore(),
    localizationService: const ThunderLocalizationService(),
  );
}

CreatePostCubit createCreatePostCubit(Account account) {
  return CreatePostCubit(
    account: account,
    postRepository: createPostRepository,
    accountRepository: createAccountRepository,
    communityRepository: createCommunityRepository,
    searchRepository: createSearchRepository,
    linkMetadataRepository: createLinkMetadataRepository,
    draftRepository: DraftRepositoryImpl(database: database),
    localizationService: const ThunderLocalizationService(),
  );
}

CreateCommentCubit createCreateCommentCubit(Account account) {
  return CreateCommentCubit(
    account: account,
    commentRepositoryFactory: createCommentRepository,
    accountRepositoryFactory: createAccountRepository,
    localizationService: const ThunderLocalizationService(),
  );
}

CreatePrivateMessageCubit createCreatePrivateMessageCubit(Account account) {
  return CreatePrivateMessageCubit(
    account: account,
    privateMessageRepository: createPrivateMessageRepository,
    searchRepository: createSearchRepository,
    localizationService: const ThunderLocalizationService(),
  );
}

PrivateMessageThreadCubit createPrivateMessageThreadCubit(
  Account account, {
  required ThunderUser participant,
  List<ThunderPrivateMessage> initialMessages = const <ThunderPrivateMessage>[],
  int? conversationId,
}) {
  return PrivateMessageThreadCubit(
    account: account,
    participant: participant,
    repository: createPrivateMessageRepository(account),
    initialMessages: initialMessages,
    conversationId: conversationId,
  );
}

AccountSettingsCubit createAccountSettingsCubit(Account account, {ThunderSiteResponse? initialSiteResponse}) {
  return AccountSettingsCubit(
    account: account,
    accountRepository: createAccountRepository(account),
    localizationService: const ThunderLocalizationService(),
    initialSiteResponse: initialSiteResponse,
  );
}

UserBlocksCubit createUserBlocksCubit(Account account) {
  return UserBlocksCubit(
    account: account,
    instanceRepository: createInstanceRepository(account),
    communityRepository: createCommunityRepository(account),
    userRepository: createUserRepository(account),
    localizationService: const ThunderLocalizationService(),
  );
}

UserMediaCubit createUserMediaCubit(Account account) {
  return UserMediaCubit(
    account: account,
    accountRepository: createAccountRepository(account),
    searchRepository: createSearchRepository(account),
    localizationService: const ThunderLocalizationService(),
  );
}

ReportBloc createReportBloc(Account account) {
  return ReportBloc(
    account: account,
    reportRepository: createReportRepository(account),
    localizationService: const ThunderLocalizationService(),
  );
}
