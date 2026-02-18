import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thunder/src/foundation/contracts/localization_service.dart';
import 'package:thunder/src/foundation/primitives/enums/comment_sort_type.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/notification/notification.dart';

class _MockCommentRepository extends Mock implements CommentRepository {}

class _MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  group('InboxBloc', () {
    late _MockCommentRepository commentRepository;
    late _MockNotificationRepository notificationRepository;

    setUp(() {
      commentRepository = _MockCommentRepository();
      notificationRepository = _MockNotificationRepository();
    });

    blocTest<InboxBloc, InboxState>(
      'increments only mention page on mention reset fetch',
      build: () {
        when(() => notificationRepository.mentions(
            unread: true,
            limit: 20,
            sort: CommentSortType.new_,
            page: 1)).thenAnswer((_) async => <ThunderComment>[]);
        when(() => notificationRepository.unreadNotificationsCount())
            .thenAnswer((_) async => const UnreadNotificationsCount(
                  privateMessages: 0,
                  mentions: 0,
                  replies: 0,
                ));

        return InboxBloc(
          account: const Account(id: '1', index: 0, instance: 'example.com'),
          commentRepository: commentRepository,
          notificationRepository: notificationRepository,
          localizationService: const GlobalContextLocalizationService(),
        );
      },
      act: (bloc) => bloc
          .add(const GetInboxEvent(reset: true, inboxType: InboxType.mentions)),
      expect: () => [
        isA<InboxState>()
            .having((state) => state.status, 'status', InboxStatus.loading),
        isA<InboxState>()
            .having((state) => state.status, 'status', InboxStatus.success)
            .having((state) => state.inboxMentionPage, 'mention page', 2)
            .having((state) => state.inboxReplyPage, 'reply page', 1)
            .having((state) => state.inboxPrivateMessagePage,
                'private message page', 1),
      ],
      verify: (_) {
        verify(() => notificationRepository.mentions(
            unread: true,
            limit: 20,
            sort: CommentSortType.new_,
            page: 1)).called(1);
      },
    );
  });
}
