import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/app/state/deep_links_cubit/deep_links_cubit.dart';
import 'package:thunder/src/app/shell/routing/deep_link_enums.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/notification/application/state/notifications_cubit.dart';
import 'package:thunder/src/foundation/errors/app_error_reason.dart';
import 'package:thunder/src/features/comment/presentation/state/create_comment_cubit.dart';
import 'package:thunder/src/features/inbox/presentation/state/inbox_bloc.dart';
import 'package:thunder/src/features/instance/presentation/state/instance_page_bloc.dart';
import 'package:thunder/src/features/moderator/presentation/state/report_bloc.dart';
import 'package:thunder/src/features/post/presentation/state/create_post_cubit.dart';
import 'package:thunder/src/features/search/presentation/state/search_bloc.dart';

void main() {
  group('Nullable copyWith semantics', () {
    test('ThunderState preserves and clears nullable fields explicitly', () {
      const state = ThunderState(
        errorMessage: 'error',
        appLanguageCode: 'en',
        currentAnonymousInstance: 'lemmy.world',
      );

      final preserved = state.copyWith(status: ThunderStatus.success);
      expect(preserved.errorMessage, 'error');
      expect(preserved.appLanguageCode, 'en');
      expect(preserved.currentAnonymousInstance, 'lemmy.world');

      final cleared = state.copyWith(
        errorMessage: null,
        appLanguageCode: null,
        currentAnonymousInstance: null,
      );
      expect(cleared.errorMessage, isNull);
      expect(cleared.appLanguageCode, isNull);
      expect(cleared.currentAnonymousInstance, isNull);
      expect(cleared.errorReason, isNull);
    });

    test('FeedUiState preserves dismiss IDs when unrelated fields update', () {
      const state = FeedUiState(
        dismissBlockedUserId: 10,
        dismissBlockedCommunityId: 20,
        dismissHiddenPostId: 30,
      );

      final preserved = state.copyWith(scrollId: 1);
      expect(preserved.dismissBlockedUserId, 10);
      expect(preserved.dismissBlockedCommunityId, 20);
      expect(preserved.dismissHiddenPostId, 30);

      final cleared = state.copyWith(
        dismissBlockedUserId: null,
        dismissBlockedCommunityId: null,
        dismissHiddenPostId: null,
      );
      expect(cleared.dismissBlockedUserId, isNull);
      expect(cleared.dismissBlockedCommunityId, isNull);
      expect(cleared.dismissHiddenPostId, isNull);
    });

    test('NotificationsState preserves ID/account when toggling pending', () {
      const state = NotificationsState(
        status: NotificationsStatus.reply,
        notificationId: 4,
        accountId: 'acct-1',
      );

      final pending = state.copyWith(pending: true);
      expect(pending.notificationId, 4);
      expect(pending.accountId, 'acct-1');

      final cleared = state.copyWith(notificationId: null, accountId: null);
      expect(cleared.notificationId, isNull);
      expect(cleared.accountId, isNull);
    });

    test('InboxState preserves and clears nullable fields explicitly', () {
      const state = InboxState(
        status: InboxStatus.failure,
        errorMessage: 'failed',
        inboxReplyMarkedAsRead: 9,
      );

      final preserved = state.copyWith(status: InboxStatus.loading);
      expect(preserved.errorMessage, 'failed');
      expect(preserved.inboxReplyMarkedAsRead, 9);

      final cleared = state.copyWith(
        status: InboxStatus.success,
        errorMessage: null,
        inboxReplyMarkedAsRead: null,
      );
      expect(cleared.errorMessage, isNull);
      expect(cleared.inboxReplyMarkedAsRead, isNull);
    });

    test('ReportState preserves and clears nullable fields explicitly', () {
      const state = ReportState(
        communityId: 42,
        message: 'failed',
      );

      final preserved = state.copyWith(status: ReportStatus.fetching);
      expect(preserved.communityId, 42);
      expect(preserved.message, 'failed');

      final cleared = state.copyWith(communityId: null, message: null);
      expect(cleared.communityId, isNull);
      expect(cleared.message, isNull);
    });

    test('Instance page states preserve and clear messages explicitly', () {
      const typeState = InstanceTypeState<String>(
        message: 'type-error',
        errorReason: AppErrorReason.unexpected(message: 'type-error'),
      );
      final typePreserved =
          typeState.copyWith(status: InstancePageStatus.loading);
      expect(typePreserved.message, 'type-error');
      expect(typePreserved.errorReason, isNotNull);

      final typeCleared = typeState.copyWith(message: null, errorReason: null);
      expect(typeCleared.message, isNull);
      expect(typeCleared.errorReason, isNull);

      const pageState = InstancePageState(
        message: 'page-error',
        errorReason: AppErrorReason.unexpected(message: 'page-error'),
      );
      final pagePreserved =
          pageState.copyWith(status: InstancePageStatus.loading);
      expect(pagePreserved.message, 'page-error');
      expect(pagePreserved.errorReason, isNotNull);

      final pageCleared = pageState.copyWith(message: null, errorReason: null);
      expect(pageCleared.message, isNull);
      expect(pageCleared.errorReason, isNull);
    });

    test('SearchState supports both explicit null and clear flags', () {
      const state = SearchState(
        message: 'error',
        errorReason: AppErrorReason.unexpected(message: 'error'),
        communityFilter: 1,
        communityFilterName: 'c/thunder',
      );

      final preserved = state.copyWith(status: SearchStatus.loading);
      expect(preserved.message, 'error');
      expect(preserved.communityFilter, 1);

      final explicitCleared = state.copyWith(
        message: null,
        errorReason: null,
        communityFilter: null,
        communityFilterName: null,
      );
      expect(explicitCleared.message, isNull);
      expect(explicitCleared.errorReason, isNull);
      expect(explicitCleared.communityFilter, isNull);
      expect(explicitCleared.communityFilterName, isNull);

      final flagCleared = state.copyWith(clearCommunityFilter: true);
      expect(flagCleared.communityFilter, isNull);
      expect(flagCleared.communityFilterName, isNull);
    });

    test('FeedPreferencesState preserves and clears nullable fields explicitly',
        () {
      final dateFormat = DateFormat.yMd();
      final state = FeedPreferencesState(
        dateFormat: dateFormat,
        feedCardDividerColor: const Color(0xff123456),
      );

      final preserved = state.copyWith(showHiddenPosts: true);
      expect(identical(preserved.dateFormat, dateFormat), isTrue);
      expect(preserved.feedCardDividerColor, const Color(0xff123456));

      final cleared = state.copyWith(
        dateFormat: null,
        feedCardDividerColor: null,
      );
      expect(cleared.dateFormat, isNull);
      expect(cleared.feedCardDividerColor, isNull);
    });

    test('DeepLinksState preserves and clears nullable typed error explicitly',
        () {
      const state = DeepLinksState(
        deepLinkStatus: DeepLinkStatus.error,
        error: 'bad',
        errorReason: AppErrorReason.validation(message: 'bad'),
      );

      final preserved = state.copyWith(linkType: LinkType.user);
      expect(preserved.error, 'bad');
      expect(preserved.errorReason, isNotNull);

      final cleared = state.copyWith(error: null, errorReason: null);
      expect(cleared.error, isNull);
      expect(cleared.errorReason, isNull);
    });

    test('CreatePostState supports explicit null clear for typed errors', () {
      const state = CreatePostState(
        status: CreatePostStatus.error,
        message: 'failed',
        errorReason: AppErrorReason.actionFailed(message: 'failed'),
      );

      final preserved = state.copyWith(status: CreatePostStatus.loading);
      expect(preserved.errorReason, isNotNull);

      final cleared = state.copyWith(
        status: CreatePostStatus.initial,
        message: null,
        errorReason: null,
      );
      expect(cleared.message, isNull);
      expect(cleared.errorReason, isNull);
    });

    test('CreateCommentState supports explicit null clear for typed errors',
        () {
      const state = CreateCommentState(
        status: CreateCommentStatus.error,
        message: 'failed',
        errorReason: AppErrorReason.actionFailed(message: 'failed'),
      );

      final preserved = state.copyWith(status: CreateCommentStatus.loading);
      expect(preserved.errorReason, isNotNull);

      final cleared = state.copyWith(
        status: CreateCommentStatus.initial,
        message: null,
        errorReason: null,
      );
      expect(cleared.message, isNull);
      expect(cleared.errorReason, isNull);
    });
  });
}
