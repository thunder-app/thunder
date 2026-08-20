import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/features/private_message/private_message.dart';
import 'package:thunder/src/core/services/localization_service.dart';

part 'inbox_event.dart';
part 'inbox_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 5);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  final Account account;

  final CommentRepository commentRepository;
  final NotificationRepository notificationRepository;
  final PrivateMessageRepository privateMessageRepository;
  final LocalizationService _localizationService;

  /// Constructor allowing an initial set of replies to be set in the state.
  InboxBloc.initWith({
    required List<ThunderComment> replies,
    required bool showUnreadOnly,
    required this.account,
    required this.commentRepository,
    required this.notificationRepository,
    required this.privateMessageRepository,
    required LocalizationService localizationService,
  }) : _localizationService = localizationService,
       super(InboxState(replies: replies, showUnreadOnly: showUnreadOnly)) {
    _init();
  }

  /// Unnamed constructor with default state
  InboxBloc({required this.account, required this.commentRepository, required this.notificationRepository, required this.privateMessageRepository, required LocalizationService localizationService})
    : _localizationService = localizationService,
      super(const InboxState()) {
    _init();
  }

  void _init() {
    on<GetInboxEvent>(_getInboxEvent, transformer: restartable());
    on<InboxItemActionEvent>(_inboxItemActionEvent);
    on<InboxPrivateMessageSentEvent>(_privateMessageSent);
    on<InboxPrivateMessageThreadUpdatedEvent>(_privateMessageThreadUpdated);
    on<MarkAllAsReadEvent>(_markAllAsRead);
  }

  void _privateMessageSent(InboxPrivateMessageSentEvent event, Emitter<InboxState> emit) {
    _upsertPrivateMessages([event.privateMessage], emit);
  }

  void _privateMessageThreadUpdated(InboxPrivateMessageThreadUpdatedEvent event, Emitter<InboxState> emit) {
    _upsertPrivateMessages(event.privateMessages, emit);
  }

  void _upsertPrivateMessages(List<ThunderPrivateMessage> privateMessages, Emitter<InboxState> emit) {
    if (privateMessages.isEmpty) return;

    final updatedIds = privateMessages.map((privateMessage) => privateMessage.id).toSet();
    final previousThreadUnreadCount = _privateMessageUnreadCount(state.privateMessages.where((privateMessage) => updatedIds.contains(privateMessage.id)));
    final nextThreadUnreadCount = _privateMessageUnreadCount(privateMessages);
    final unreadDelta = nextThreadUnreadCount - previousThreadUnreadCount;
    final updatedPrivateMessages = [...privateMessages, ...state.privateMessages.where((privateMessage) => !updatedIds.contains(privateMessage.id))]
      ..sort((a, b) => b.published.compareTo(a.published));

    emit(
      state.copyWith(
        status: InboxStatus.success,
        privateMessages: cleanDeletedMessages(updatedPrivateMessages),
        totalUnreadCount: (state.totalUnreadCount + unreadDelta).clamp(0, 1 << 31),
        messagesUnreadCount: (state.messagesUnreadCount + unreadDelta).clamp(0, 1 << 31),
        errorMessage: null,
        errorReason: null,
      ),
    );
  }

  int _privateMessageUnreadCount(Iterable<ThunderPrivateMessage> privateMessages) {
    return privateMessages.where((privateMessage) => !(privateMessage.notification?.read ?? false) && isIncomingPrivateMessage(privateMessage, account)).length;
  }

  Future<void> _getInboxEvent(GetInboxEvent event, emit) async {
    if (account.anonymous) {
      return emit(
        state.copyWith(
          status: InboxStatus.empty,
          privateMessages: [],
          mentions: [],
          replies: [],
          showUnreadOnly: !event.showAll,
          inboxMentionPage: 1,
          inboxReplyPage: 1,
          inboxPrivateMessagePage: 1,
          totalUnreadCount: 0,
          repliesUnreadCount: 0,
          mentionsUnreadCount: 0,
          messagesUnreadCount: 0,
          hasReachedInboxReplyEnd: true,
          hasReachedInboxMentionEnd: true,
          hasReachedInboxPrivateMessageEnd: true,
          errorReason: null,
        ),
      );
    }

    int limit = 20;

    try {
      List<ThunderPrivateMessage>? privateMessagesResponse = [];
      List<ThunderComment> mentionsResponse = [];
      List<ThunderComment> repliesResponse = [];

      if (event.reset) {
        emit(state.copyWith(status: InboxStatus.loading, errorMessage: ''));

        switch (event.inboxType) {
          case InboxType.replies:
            repliesResponse = await notificationRepository.replies(unread: !event.showAll, limit: limit, sort: event.commentSortType, page: 1);
            break;
          case InboxType.mentions:
            mentionsResponse = await notificationRepository.mentions(unread: !event.showAll, limit: limit, sort: event.commentSortType, page: 1);
            break;
          case InboxType.messages:
            privateMessagesResponse = await privateMessageRepository.messages(unread: false, limit: limit, page: 1);
            break;
          case InboxType.all:
            repliesResponse = await notificationRepository.replies(unread: !event.showAll, limit: limit, sort: event.commentSortType, page: 1);

            mentionsResponse = await notificationRepository.mentions(unread: !event.showAll, limit: limit, sort: event.commentSortType, page: 1);

            privateMessagesResponse = await privateMessageRepository.messages(unread: false, limit: limit, page: 1);
            break;
          default:
            break;
        }

        final unread = await notificationRepository.unreadNotificationsCount();
        int totalUnreadCount = unread.total;

        final fetchedReplies = event.inboxType == InboxType.replies || event.inboxType == InboxType.all;
        final fetchedMentions = event.inboxType == InboxType.mentions || event.inboxType == InboxType.all;
        final fetchedMessages = event.inboxType == InboxType.messages || event.inboxType == InboxType.all;
        final pages = resetPagesForType(event.inboxType);

        return emit(
          state.copyWith(
            status: InboxStatus.success,
            privateMessages: cleanDeletedMessages(privateMessagesResponse),
            mentions: cleanDeletedMentions(mentionsResponse),
            replies: repliesResponse,
            showUnreadOnly: !event.showAll,
            inboxMentionPage: pages.mentionPage,
            inboxReplyPage: pages.replyPage,
            inboxPrivateMessagePage: pages.messagePage,
            totalUnreadCount: totalUnreadCount,
            repliesUnreadCount: unread.replies,
            mentionsUnreadCount: unread.mentions,
            messagesUnreadCount: unread.privateMessages,
            hasReachedInboxReplyEnd: fetchedReplies ? (repliesResponse.isEmpty || repliesResponse.length < limit) : false,
            hasReachedInboxMentionEnd: fetchedMentions ? (mentionsResponse.isEmpty || mentionsResponse.length < limit) : false,
            hasReachedInboxPrivateMessageEnd: fetchedMessages ? (privateMessagesResponse.isEmpty || privateMessagesResponse.length < limit) : false,
            errorReason: null,
          ),
        );
      }

      // Prevent fetching if we're already fetching
      if (state.status == InboxStatus.refreshing) return;
      emit(state.copyWith(status: InboxStatus.refreshing, errorMessage: ''));

      switch (event.inboxType) {
        case InboxType.replies:
          if (state.hasReachedInboxReplyEnd) return;
          repliesResponse = await notificationRepository.replies(unread: state.showUnreadOnly, limit: limit, sort: event.commentSortType, page: state.inboxReplyPage);
          break;
        case InboxType.mentions:
          if (state.hasReachedInboxMentionEnd) return;
          mentionsResponse = await notificationRepository.mentions(unread: state.showUnreadOnly, limit: limit, sort: event.commentSortType, page: state.inboxMentionPage);
          break;
        case InboxType.messages:
          if (state.hasReachedInboxPrivateMessageEnd) return;
          privateMessagesResponse = await privateMessageRepository.messages(unread: false, limit: limit, page: state.inboxPrivateMessagePage);
          break;
        default:
          break;
      }

      List<ThunderComment> replies = List.from(state.replies)..addAll(repliesResponse);
      List<ThunderComment> mentions = List.from(state.mentions)..addAll(mentionsResponse);
      List<ThunderPrivateMessage> privateMessages = List.from(state.privateMessages)..addAll(privateMessagesResponse);

      final pages = incrementFetchedPage(type: event.inboxType, currentMentionPage: state.inboxMentionPage, currentReplyPage: state.inboxReplyPage, currentMessagePage: state.inboxPrivateMessagePage);

      return emit(
        state.copyWith(
          status: InboxStatus.success,
          privateMessages: cleanDeletedMessages(privateMessages),
          mentions: cleanDeletedMentions(mentions),
          replies: replies,
          showUnreadOnly: state.showUnreadOnly,
          inboxMentionPage: pages.mentionPage,
          inboxReplyPage: pages.replyPage,
          inboxPrivateMessagePage: pages.messagePage,
          hasReachedInboxReplyEnd: event.inboxType == InboxType.replies ? (repliesResponse.isEmpty || repliesResponse.length < limit) : state.hasReachedInboxReplyEnd,
          hasReachedInboxMentionEnd: event.inboxType == InboxType.mentions ? (mentionsResponse.isEmpty || mentionsResponse.length < limit) : state.hasReachedInboxMentionEnd,
          hasReachedInboxPrivateMessageEnd: event.inboxType == InboxType.messages
              ? (privateMessagesResponse.isEmpty || privateMessagesResponse.length < limit)
              : state.hasReachedInboxPrivateMessageEnd,
          errorReason: null,
        ),
      );
    } catch (e) {
      final message = e.toString();
      emit(
        state.copyWith(
          status: InboxStatus.failure,
          errorMessage: message,
          totalUnreadCount: 0,
          repliesUnreadCount: 0,
          mentionsUnreadCount: 0,
          messagesUnreadCount: 0,
          errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
        ),
      );
    }
  }

  /// Handles comment related actions on a given item within the inbox
  Future<void> _inboxItemActionEvent(InboxItemActionEvent event, Emitter<InboxState> emit) async {
    assert(!(event.commentReplyId == null && event.personMentionId == null && event.privateMessageId == null));
    emit(state.copyWith(status: InboxStatus.refreshing, errorMessage: ''));

    int existingReplyIndex = -1;
    int existingMentionIndex = -1;
    int existingPrivateMessageIndex = -1;

    ThunderComment? existingCommentReplyView;
    ThunderComment? existingPersonMentionView;
    ThunderPrivateMessage? existingPrivateMessageView;

    if (event.commentReplyId != null && event.action == CommentAction.read) {
      existingReplyIndex = state.replies.indexWhere((element) => element.notification?.id == event.commentReplyId);
      if (existingReplyIndex != -1) {
        existingCommentReplyView = state.replies[existingReplyIndex];
      }
    } else if (event.commentReplyId != null && event.action != CommentAction.read) {
      existingReplyIndex = state.replies.indexWhere((element) => element.id == event.commentReplyId);
      if (existingReplyIndex != -1) {
        existingCommentReplyView = state.replies[existingReplyIndex];
      }
    }

    if (event.personMentionId != null && event.action == CommentAction.read) {
      existingMentionIndex = state.mentions.indexWhere((element) => element.notification?.id == event.personMentionId);
      if (existingMentionIndex != -1) {
        existingPersonMentionView = state.mentions[existingMentionIndex];
      }
    } else if (event.personMentionId != null && event.action != CommentAction.read) {
      existingMentionIndex = state.mentions.indexWhere((element) => element.id == event.personMentionId);
      if (existingMentionIndex != -1) {
        existingPersonMentionView = state.mentions[existingMentionIndex];
      }
    }

    if (event.privateMessageId != null) {
      existingPrivateMessageIndex = state.privateMessages.indexWhere((element) => element.notification?.id == event.privateMessageId);
      if (existingPrivateMessageIndex != -1) {
        existingPrivateMessageView = state.privateMessages[existingPrivateMessageIndex];
      }
    }

    if (existingCommentReplyView == null && existingPersonMentionView == null && existingPrivateMessageView == null) {
      return emit(
        state.copyWith(
          status: InboxStatus.failure,
          errorReason: const AppErrorReason.actionFailed(message: 'Inbox item not found.'),
        ),
      );
    }

    /// Convert the reply or mention to a comment
    ThunderComment? comment;

    if (existingCommentReplyView != null) {
      comment = existingCommentReplyView;
    } else if (existingPersonMentionView != null) {
      comment = existingPersonMentionView;
    }

    switch (event.action) {
      case CommentAction.read:
        final input = event.actionInput;
        if (input is! ReadInboxActionInput) {
          return emit(
            state.copyWith(
              status: InboxStatus.failure,
              errorReason: const AppErrorReason.validation(message: 'Invalid payload for read action.'),
            ),
          );
        }
        final value = input.read;
        try {
          final updatedReplies = List<ThunderComment>.from(state.replies);
          final updatedMentions = List<ThunderComment>.from(state.mentions);
          final updatedPrivateMessages = List<ThunderPrivateMessage>.from(state.privateMessages);

          // Optimistically remove the reply from the list or change the status (depending on whether we're showing all)
          if (existingCommentReplyView != null && existingReplyIndex != -1) {
            if (!state.showUnreadOnly) {
              updatedReplies[existingReplyIndex] = existingCommentReplyView.copyWith(notification: existingCommentReplyView.notification?.copyWith(read: value));
            } else if (value) {
              updatedReplies.removeAt(existingReplyIndex);
            }
          } else if (existingPersonMentionView != null && existingMentionIndex != -1) {
            if (!state.showUnreadOnly) {
              updatedMentions[existingMentionIndex] = existingPersonMentionView.copyWith(notification: existingPersonMentionView.notification?.copyWith(read: value));
            } else if (value) {
              updatedMentions.removeAt(existingMentionIndex);
            }
          } else if (existingPrivateMessageView != null && existingPrivateMessageIndex != -1) {
            updatedPrivateMessages[existingPrivateMessageIndex] = existingPrivateMessageView.copyWith(notification: existingPrivateMessageView.notification?.copyWith(read: value));
          }

          if (existingCommentReplyView != null) {
            await notificationRepository.markReplyAsRead(replyId: event.commentReplyId!, read: value);
          } else if (existingPersonMentionView != null) {
            await notificationRepository.markMentionAsRead(mentionId: event.personMentionId!, read: value);
          } else if (existingPrivateMessageView != null) {
            await privateMessageRepository.markAsRead(notificationId: event.privateMessageId!, read: value);
          }

          final unread = await notificationRepository.unreadNotificationsCount();
          int totalUnreadCount = unread.total;

          return emit(
            state.copyWith(
              status: InboxStatus.success,
              replies: updatedReplies,
              mentions: updatedMentions,
              privateMessages: updatedPrivateMessages,
              totalUnreadCount: totalUnreadCount,
              repliesUnreadCount: unread.replies,
              mentionsUnreadCount: unread.mentions,
              messagesUnreadCount: unread.privateMessages,
              inboxReplyMarkedAsRead: event.commentReplyId,
              errorReason: null,
            ),
          );
        } catch (e) {
          final message = e.toString();
          return emit(
            state.copyWith(
              status: InboxStatus.failure,
              errorMessage: message,
              errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
            ),
          );
        }
      case CommentAction.vote:
        final originalReplies = List<ThunderComment>.from(state.replies);
        final originalMentions = List<ThunderComment>.from(state.mentions);
        final input = event.actionInput;
        if (input is! VoteInboxActionInput) {
          return emit(
            state.copyWith(
              status: InboxStatus.failure,
              errorReason: const AppErrorReason.validation(message: 'Invalid payload for vote action.'),
            ),
          );
        }
        final value = input.vote;
        try {
          final updatedReplies = List<ThunderComment>.from(state.replies);
          final updatedMentions = List<ThunderComment>.from(state.mentions);

          ThunderComment updatedComment = optimisticallyVoteComment(comment!, value);

          if (existingCommentReplyView != null && existingReplyIndex != -1) {
            updatedReplies[existingReplyIndex] = existingCommentReplyView.copyWith(
              counts: existingCommentReplyView.counts.copyWith(score: updatedComment.counts.score, upvotes: updatedComment.counts.upvotes, downvotes: updatedComment.counts.downvotes),
              context: existingCommentReplyView.context.copyWith(vote: updatedComment.context.vote),
            );
          } else if (existingPersonMentionView != null && existingMentionIndex != -1) {
            updatedMentions[existingMentionIndex] = existingPersonMentionView.copyWith(
              counts: existingPersonMentionView.counts.copyWith(score: updatedComment.counts.score, upvotes: updatedComment.counts.upvotes, downvotes: updatedComment.counts.downvotes),
              context: existingPersonMentionView.context.copyWith(vote: updatedComment.context.vote),
            );
          }

          // Immediately set the status, and continue
          emit(state.copyWith(status: InboxStatus.success, replies: updatedReplies, mentions: updatedMentions));
          emit(state.copyWith(status: InboxStatus.refreshing, replies: updatedReplies, mentions: updatedMentions));

          await commentRepository
              .vote(comment, value)
              .timeout(
                timeout,
                onTimeout: () {
                  throw Exception(_localizationService.l10n.timeoutUpvoteComment);
                },
              );

          return emit(state.copyWith(status: InboxStatus.success, replies: updatedReplies, mentions: updatedMentions, errorReason: null));
        } catch (e) {
          final message = e.toString();
          return emit(
            state.copyWith(
              status: InboxStatus.failure,
              errorMessage: message,
              replies: originalReplies,
              mentions: originalMentions,
              errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
            ),
          );
        }
      case CommentAction.save:
        final originalReplies = List<ThunderComment>.from(state.replies);
        final originalMentions = List<ThunderComment>.from(state.mentions);
        final input = event.actionInput;
        if (input is! SaveInboxActionInput) {
          return emit(
            state.copyWith(
              status: InboxStatus.failure,
              errorReason: const AppErrorReason.validation(message: 'Invalid payload for save action.'),
            ),
          );
        }
        final value = input.save;
        try {
          final updatedReplies = List<ThunderComment>.from(state.replies);
          final updatedMentions = List<ThunderComment>.from(state.mentions);

          ThunderComment updatedComment = optimisticallySaveComment(comment!, value);

          if (existingCommentReplyView != null && existingReplyIndex != -1) {
            updatedReplies[existingReplyIndex] = existingCommentReplyView.copyWith(context: existingCommentReplyView.context.copyWith(saved: updatedComment.context.saved!));
          } else if (existingPersonMentionView != null && existingMentionIndex != -1) {
            updatedMentions[existingMentionIndex] = existingPersonMentionView.copyWith(context: existingPersonMentionView.context.copyWith(saved: updatedComment.context.saved!));
          }

          // Immediately set the status, and continue
          emit(state.copyWith(status: InboxStatus.success, replies: updatedReplies, mentions: updatedMentions));
          emit(state.copyWith(status: InboxStatus.refreshing, replies: updatedReplies, mentions: updatedMentions));

          await commentRepository
              .save(comment, value)
              .timeout(
                timeout,
                onTimeout: () {
                  throw Exception(_localizationService.l10n.timeoutSaveComment);
                },
              );

          return emit(state.copyWith(status: InboxStatus.success, replies: updatedReplies, mentions: updatedMentions, errorReason: null));
        } catch (e) {
          final message = e.toString();
          return emit(
            state.copyWith(
              status: InboxStatus.failure,
              errorMessage: message,
              replies: originalReplies,
              mentions: originalMentions,
              errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
            ),
          );
        }
      case CommentAction.delete:
        final originalReplies = List<ThunderComment>.from(state.replies);
        final originalMentions = List<ThunderComment>.from(state.mentions);
        final input = event.actionInput;
        if (input is! DeleteInboxActionInput) {
          return emit(
            state.copyWith(
              status: InboxStatus.failure,
              errorReason: const AppErrorReason.validation(message: 'Invalid payload for delete action.'),
            ),
          );
        }
        final value = input.delete;
        try {
          final updatedReplies = List<ThunderComment>.from(state.replies);
          final updatedMentions = List<ThunderComment>.from(state.mentions);

          ThunderComment updatedComment = optimisticallyDeleteComment(comment!, value);

          if (existingCommentReplyView != null && existingReplyIndex != -1) {
            updatedReplies[existingReplyIndex] = existingCommentReplyView.copyWith(status: existingCommentReplyView.status.copyWith(deleted: updatedComment.status.deleted));
          } else if (existingPersonMentionView != null && existingMentionIndex != -1) {
            updatedMentions[existingMentionIndex] = existingPersonMentionView.copyWith(status: existingPersonMentionView.status.copyWith(deleted: updatedComment.status.deleted));
          }

          // Immediately set the status, and continue
          emit(state.copyWith(status: InboxStatus.success, replies: updatedReplies, mentions: updatedMentions));
          emit(state.copyWith(status: InboxStatus.refreshing, replies: updatedReplies, mentions: updatedMentions));

          await commentRepository
              .delete(comment, value)
              .timeout(
                timeout,
                onTimeout: () {
                  throw Exception(_localizationService.l10n.timeoutErrorMessage);
                },
              );

          return emit(state.copyWith(status: InboxStatus.success, replies: updatedReplies, mentions: updatedMentions, errorReason: null));
        } catch (e) {
          final message = e.toString();
          return emit(
            state.copyWith(
              status: InboxStatus.failure,
              errorMessage: message,
              replies: originalReplies,
              mentions: originalMentions,
              errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
            ),
          );
        }
      default:
        return emit(
          state.copyWith(
            status: InboxStatus.failure,
            errorMessage: _localizationService.l10n.unexpectedError,
            errorReason: AppErrorReason.unexpected(message: _localizationService.l10n.unexpectedError),
          ),
        );
    }
  }

  Future<void> _markAllAsRead(MarkAllAsReadEvent event, emit) async {
    try {
      emit(state.copyWith(status: InboxStatus.refreshing, errorMessage: ''));
      await notificationRepository.markAllNotificationsAsRead();

      // Update all the replies, mentions, and messages to be read locally
      List<ThunderComment> updatedReplies = state.replies.map((comment) => comment.copyWith(notification: comment.notification?.copyWith(read: true))).toList();
      List<ThunderComment> updatedMentions = state.mentions.map((comment) => comment.copyWith(notification: comment.notification?.copyWith(read: true))).toList();
      List<ThunderPrivateMessage> updatedPrivateMessages = state.privateMessages
          .map((privateMessage) => privateMessage.copyWith(notification: privateMessage.notification?.copyWith(read: true)))
          .toList();

      return emit(
        state.copyWith(
          status: InboxStatus.success,
          replies: state.showUnreadOnly ? [] : updatedReplies,
          mentions: state.showUnreadOnly ? [] : updatedMentions,
          privateMessages: updatedPrivateMessages,
          totalUnreadCount: 0,
          repliesUnreadCount: 0,
          mentionsUnreadCount: 0,
          messagesUnreadCount: 0,
          errorReason: null,
        ),
      );
    } catch (e) {
      final message = e.toString();
      emit(
        state.copyWith(
          status: InboxStatus.failure,
          errorMessage: message,
          errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
        ),
      );
    }
  }
}
