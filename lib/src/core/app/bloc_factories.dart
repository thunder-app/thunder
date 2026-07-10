import 'package:thunder/src/core/state/app_version_cubit.dart';
import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/core/state/deep_links_cubit.dart';
import 'package:thunder/src/core/state/network_checker_cubit.dart';
import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

import 'package:thunder/src/features/account/api.dart';
import 'package:thunder/src/features/account/presentation/state/instance_validation_cubit.dart';
import 'package:thunder/src/features/account/presentation/state/profile_modal_cubit.dart';
import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/inbox/api.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart' show fetchInstanceNameFromUrl;
import 'package:thunder/src/features/moderator/api.dart';
import 'package:thunder/src/features/post/api.dart';
import 'package:thunder/src/features/private_message/api.dart';
import 'package:thunder/src/features/search/api.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/features/user/api.dart';
import 'package:thunder/src/features/instance/presentation/state/instance_page_bloc.dart';

AppVersionCubit createAppVersionCubit() {
  return AppVersionCubit(
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
    sessionRepository: createSessionRepository(),
    quickSelectMode: quickSelectMode,
    instanceInfoLookup: (instance) => getInstanceInfo(instance).timeout(
      const Duration(seconds: 5),
      onTimeout: () => ThunderInstanceInfo(
        domain: instance,
        name: fetchInstanceNameFromUrl(instance) ?? instance,
        success: false,
      ),
    ),
    unreadCountLookup: (account) async {
      final unread = await createNotificationRepository(account).unreadNotificationsCount();
      return unread.total == 0 ? null : unread.total;
    },
  );
}

SessionBloc createSessionBloc() {
  return SessionBloc(
    sessionRepository: createSessionRepository(),
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
  final instanceAuthority = normalizeInstanceHost(instanceInfo.domain) ?? instanceInfo.domain;
  final remoteAccount = Account(
    instance: instanceAuthority,
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
    draftRepository: createDraftRepository(),
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
