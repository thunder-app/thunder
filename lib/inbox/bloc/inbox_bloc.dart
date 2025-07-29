import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lemmy_api_client/v3.dart' hide CommentSortType;
import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/comment/models/thunder_comment.dart';

import 'package:thunder/core/enums/comment_sort_type.dart';
import 'package:thunder/comment/repository/comment_repository.dart';
import 'package:thunder/core/extensions/person_mention_view.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/comment/comment.dart';
import 'package:thunder/inbox/enums/inbox_type.dart';
import 'package:thunder/notification/repository/notification_repository.dart';
import 'package:thunder/utils/global_context.dart';

part 'inbox_event.dart';
part 'inbox_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 5);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  Account account;

  late CommentRepository commentRepository;
  late NotificationRepository notificationRepository;

  /// Constructor allowing an initial set of replies to be set in the state.
  InboxBloc.initWith({
    required List<ThunderComment> replies,
    required bool showUnreadOnly,
    required this.account,
  }) : super(InboxState(replies: replies, showUnreadOnly: showUnreadOnly)) {
    commentRepository = CommentRepositoryImpl(account: account);
    notificationRepository = NotificationRepositoryImpl(account: account);
    _init();
  }

  /// Unnamed constructor with default state
  InboxBloc({required this.account}) : super(const InboxState()) {
    commentRepository = CommentRepositoryImpl(account: account);
    notificationRepository = NotificationRepositoryImpl(account: account);
    _init();
  }

  void _init() {
    on<GetInboxEvent>(_getInboxEvent, transformer: restartable());
    on<InboxItemActionEvent>(_inboxItemActionEvent);
    on<MarkAllAsReadEvent>(_markAllAsRead);
  }

  Future<void> _getInboxEvent(GetInboxEvent event, emit) async {
    if (account.anonymous) {
      return emit(state.copyWith(
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
      ));
    }

    int limit = 20;

    try {
      PrivateMessagesResponse? privateMessagesResponse;
      GetPersonMentionsResponse? getPersonMentionsResponse;
      List<ThunderComment> repliesResponse = [];

      if (event.reset) {
        emit(state.copyWith(status: InboxStatus.loading, errorMessage: ''));

        switch (event.inboxType) {
          case InboxType.replies:
            repliesResponse = await notificationRepository.replies(
              unread: !event.showAll,
              limit: limit,
              sort: event.commentSortType,
              page: 1,
            );
            break;
          case InboxType.mentions:
            getPersonMentionsResponse = await notificationRepository.mentions(
              unread: !event.showAll,
              limit: limit,
              sort: event.commentSortType,
              page: 1,
            );
            break;
          case InboxType.messages:
            privateMessagesResponse = await notificationRepository.messages(
              unread: !event.showAll,
              limit: limit,
              page: 1,
            );
            break;
          case InboxType.all:
            repliesResponse = await notificationRepository.replies(
              unread: !event.showAll,
              limit: limit,
              sort: event.commentSortType,
              page: 1,
            );

            getPersonMentionsResponse = await notificationRepository.mentions(
              unread: !event.showAll,
              limit: limit,
              sort: event.commentSortType,
              page: 1,
            );

            privateMessagesResponse = await notificationRepository.messages(
              unread: !event.showAll,
              limit: limit,
              page: 1,
            );
            break;
          default:
            break;
        }

        final unread = await notificationRepository.unreadNotificationsCount();
        int totalUnreadCount = unread.privateMessages + unread.mentions + unread.replies;

        return emit(
          state.copyWith(
            status: InboxStatus.success,
            privateMessages: cleanDeletedMessages(privateMessagesResponse?.privateMessages ?? []),
            mentions: cleanDeletedMentions(getPersonMentionsResponse?.mentions ?? []),
            replies: repliesResponse,
            showUnreadOnly: !event.showAll,
            inboxMentionPage: 2,
            inboxReplyPage: 2,
            inboxPrivateMessagePage: 2,
            totalUnreadCount: totalUnreadCount,
            repliesUnreadCount: unread.replies,
            mentionsUnreadCount: unread.mentions,
            messagesUnreadCount: unread.privateMessages,
            hasReachedInboxReplyEnd: repliesResponse.isEmpty || repliesResponse.length < limit,
            hasReachedInboxMentionEnd: getPersonMentionsResponse?.mentions.isEmpty == true || (getPersonMentionsResponse?.mentions.length ?? 0) < limit,
            hasReachedInboxPrivateMessageEnd: privateMessagesResponse?.privateMessages.isEmpty == true || (privateMessagesResponse?.privateMessages.length ?? 0) < limit,
          ),
        );
      }

      // Prevent fetching if we're already fetching
      if (state.status == InboxStatus.refreshing) return;
      emit(state.copyWith(status: InboxStatus.refreshing, errorMessage: ''));

      switch (event.inboxType) {
        case InboxType.replies:
          if (state.hasReachedInboxReplyEnd) return;
          repliesResponse = await notificationRepository.replies(
            unread: state.showUnreadOnly,
            limit: limit,
            sort: event.commentSortType,
            page: state.inboxReplyPage,
          );
          break;
        case InboxType.mentions:
          if (state.hasReachedInboxMentionEnd) return;
          getPersonMentionsResponse = await notificationRepository.mentions(
            unread: state.showUnreadOnly,
            limit: limit,
            sort: event.commentSortType,
            page: state.inboxMentionPage,
          );
          break;
        case InboxType.messages:
          if (state.hasReachedInboxPrivateMessageEnd) return;
          privateMessagesResponse = await notificationRepository.messages(
            unread: state.showUnreadOnly,
            limit: limit,
            page: state.inboxPrivateMessagePage,
          );
          break;
        default:
          break;
      }

      List<ThunderComment> replies = List.from(state.replies)..addAll(repliesResponse);
      List<PersonMentionView> mentions = List.from(state.mentions)..addAll(getPersonMentionsResponse?.mentions ?? []);
      List<PrivateMessageView> privateMessages = List.from(state.privateMessages)..addAll(privateMessagesResponse?.privateMessages ?? []);

      return emit(
        state.copyWith(
          status: InboxStatus.success,
          privateMessages: cleanDeletedMessages(privateMessages),
          mentions: cleanDeletedMentions(mentions),
          replies: replies,
          showUnreadOnly: state.showUnreadOnly,
          inboxMentionPage: state.inboxMentionPage + 1,
          inboxReplyPage: state.inboxReplyPage + 1,
          inboxPrivateMessagePage: state.inboxPrivateMessagePage + 1,
          hasReachedInboxReplyEnd: repliesResponse.isEmpty || repliesResponse.length < limit,
          hasReachedInboxMentionEnd: getPersonMentionsResponse?.mentions.isEmpty == true || (getPersonMentionsResponse?.mentions.length ?? 0) < limit,
          hasReachedInboxPrivateMessageEnd: privateMessagesResponse?.privateMessages.isEmpty == true || (privateMessagesResponse?.privateMessages.length ?? 0) < limit,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        status: InboxStatus.failure,
        errorMessage: e.toString(),
        totalUnreadCount: 0,
        repliesUnreadCount: 0,
        mentionsUnreadCount: 0,
        messagesUnreadCount: 0,
      ));
    }
  }

  /// Handles comment related actions on a given item within the inbox
  Future<void> _inboxItemActionEvent(InboxItemActionEvent event, Emitter<InboxState> emit) async {
    assert(!(event.commentReplyId == null && event.personMentionId == null && event.privateMessageId == null));
    emit(state.copyWith(status: InboxStatus.refreshing, errorMessage: ''));

    int existingIndex = -1;

    ThunderComment? existingCommentReplyView;
    PersonMentionView? existingPersonMentionView;
    PrivateMessageView? existingPrivateMessageView;

    if (event.commentReplyId != null) {
      existingIndex = state.replies.indexWhere((element) => element.id == event.commentReplyId);
      existingCommentReplyView = state.replies[existingIndex];
    } else if (event.personMentionId != null) {
      existingIndex = state.mentions.indexWhere((element) => element.personMention.id == event.personMentionId);
      existingPersonMentionView = state.mentions[existingIndex];
    } else if (event.privateMessageId != null) {
      existingIndex = state.privateMessages.indexWhere((element) => element.privateMessage.id == event.privateMessageId);
      existingPrivateMessageView = state.privateMessages[existingIndex];
    }

    if (existingCommentReplyView == null && existingPersonMentionView == null && existingPrivateMessageView == null) return emit(state.copyWith(status: InboxStatus.failure));

    /// Convert the reply or mention to a comment
    ThunderComment? comment;

    if (existingCommentReplyView != null) {
      comment = existingCommentReplyView;
    } else if (existingPersonMentionView != null) {
      comment = existingPersonMentionView.toComment();
    }

    switch (event.action) {
      case CommentAction.read:
        try {
          // Optimistically remove the reply from the list or change the status (depending on whether we're showing all)
          if (existingCommentReplyView != null) {
            if (!state.showUnreadOnly) {
              state.replies[existingIndex] = existingCommentReplyView.copyWith(read: event.value);
            } else if (event.value == true) {
              state.replies.remove(existingCommentReplyView);
            }
          } else if (existingPersonMentionView != null) {
            if (!state.showUnreadOnly) {
              state.mentions[existingIndex] = existingPersonMentionView.copyWith(personMention: existingPersonMentionView.personMention.copyWith(read: event.value));
            } else if (event.value == true) {
              state.mentions.remove(existingPersonMentionView);
            }
          } else if (existingPrivateMessageView != null) {
            if (!state.showUnreadOnly) {
              state.privateMessages[existingIndex] = existingPrivateMessageView.copyWith(privateMessage: existingPrivateMessageView.privateMessage.copyWith(read: event.value));
            } else if (event.value == true) {
              state.privateMessages.remove(existingPrivateMessageView);
            }
          }

          if (existingCommentReplyView != null) {
            await notificationRepository.markReplyAsRead(
              replyId: event.commentReplyId!,
              read: event.value,
            );
          } else if (existingPersonMentionView != null) {
            await notificationRepository.markMentionAsRead(
              mentionId: event.personMentionId!,
              read: event.value,
            );
          } else if (existingPrivateMessageView != null) {
            await notificationRepository.markMessageAsRead(
              messageId: event.privateMessageId!,
              read: event.value,
            );
          }

          final unread = await notificationRepository.unreadNotificationsCount();
          int totalUnreadCount = unread.privateMessages + unread.mentions + unread.replies;

          return emit(state.copyWith(
            status: InboxStatus.success,
            totalUnreadCount: totalUnreadCount,
            repliesUnreadCount: unread.replies,
            mentionsUnreadCount: unread.mentions,
            messagesUnreadCount: unread.privateMessages,
            inboxReplyMarkedAsRead: event.commentReplyId,
          ));
        } catch (e) {
          return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
        }
      case CommentAction.vote:
        try {
          ThunderComment updatedComment = optimisticallyVoteComment(comment!, event.value);

          if (existingCommentReplyView != null) {
            state.replies[existingIndex] = existingCommentReplyView.copyWith(
              score: updatedComment.score,
              upvotes: updatedComment.upvotes,
              downvotes: updatedComment.downvotes,
              myVote: updatedComment.myVote,
            );
          } else if (existingPersonMentionView != null) {
            state.mentions[existingIndex] = existingPersonMentionView.copyWith(
              counts: existingPersonMentionView.counts.copyWith(
                score: updatedComment.score!,
                upvotes: updatedComment.upvotes!,
                downvotes: updatedComment.downvotes!,
              ),
              myVote: updatedComment.myVote,
            );
          }

          // Immediately set the status, and continue
          emit(state.copyWith(status: InboxStatus.success));
          emit(state.copyWith(status: InboxStatus.refreshing));

          await commentRepository.vote(comment, event.value).timeout(timeout, onTimeout: () {
            // Restore the original comment if vote fails
            if (existingCommentReplyView != null) {
              state.replies[existingIndex] = existingCommentReplyView;
            } else if (existingPersonMentionView != null) {
              state.mentions[existingIndex] = existingPersonMentionView;
            }

            throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutUpvoteComment);
          });

          return emit(state.copyWith(status: InboxStatus.success));
        } catch (e) {
          return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
        }
      case CommentAction.save:
        try {
          ThunderComment updatedComment = optimisticallySaveComment(comment!, event.value);

          if (existingCommentReplyView != null) {
            state.replies[existingIndex] = existingCommentReplyView.copyWith(saved: updatedComment.saved!);
          } else if (existingPersonMentionView != null) {
            state.mentions[existingIndex] = existingPersonMentionView.copyWith(saved: updatedComment.saved!);
          }

          // Immediately set the status, and continue
          emit(state.copyWith(status: InboxStatus.success));
          emit(state.copyWith(status: InboxStatus.refreshing));

          await commentRepository.save(comment, event.value).timeout(timeout, onTimeout: () {
            // Restore the original comment if saving fails
            if (existingCommentReplyView != null) {
              state.replies[existingIndex] = existingCommentReplyView;
            } else if (existingPersonMentionView != null) {
              state.mentions[existingIndex] = existingPersonMentionView;
            }

            throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutSaveComment);
          });

          return emit(state.copyWith(status: InboxStatus.success));
        } catch (e) {
          return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
        }
      case CommentAction.delete:
        try {
          ThunderComment updatedComment = optimisticallyDeleteComment(comment!, event.value);

          if (existingCommentReplyView != null) {
            state.replies[existingIndex] = existingCommentReplyView.copyWith(
              deleted: updatedComment.deleted,
            );
          } else if (existingPersonMentionView != null) {
            state.mentions[existingIndex] = existingPersonMentionView.copyWith(
              comment: existingPersonMentionView.comment.copyWith(deleted: updatedComment.deleted),
            );
          }

          // Immediately set the status, and continue
          emit(state.copyWith(status: InboxStatus.success));
          emit(state.copyWith(status: InboxStatus.refreshing));

          await commentRepository.delete(comment, event.value).timeout(timeout, onTimeout: () {
            // Restore the original comment if deleting fails
            if (existingCommentReplyView != null) {
              state.replies[existingIndex] = existingCommentReplyView;
            } else if (existingPersonMentionView != null) {
              state.mentions[existingIndex] = existingPersonMentionView;
            }

            throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutErrorMessage);
          });

          return emit(state.copyWith(status: InboxStatus.success));
        } catch (e) {
          return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
        }
      default:
        return emit(state.copyWith(status: InboxStatus.failure, errorMessage: AppLocalizations.of(GlobalContext.context)!.unexpectedError));
    }
  }

  Future<void> _markAllAsRead(MarkAllAsReadEvent event, emit) async {
    try {
      emit(state.copyWith(status: InboxStatus.refreshing, errorMessage: ''));
      await notificationRepository.markAllNotificationsAsRead();

      // Update all the replies, mentions, and messages to be read locally
      List<ThunderComment> updatedReplies = state.replies.map((comment) => comment.copyWith(read: true)).toList();
      List<PersonMentionView> updatedMentions = state.mentions.map((personMentionView) => personMentionView.copyWith(personMention: personMentionView.personMention.copyWith(read: true))).toList();
      List<PrivateMessageView> updatedPrivateMessages =
          state.privateMessages.map((privateMessageView) => privateMessageView.copyWith(privateMessage: privateMessageView.privateMessage.copyWith(read: true))).toList();

      return emit(state.copyWith(
        status: InboxStatus.success,
        replies: state.showUnreadOnly ? [] : updatedReplies,
        mentions: state.showUnreadOnly ? [] : updatedMentions,
        privateMessages: state.showUnreadOnly ? [] : updatedPrivateMessages,
        totalUnreadCount: 0,
        repliesUnreadCount: 0,
        mentionsUnreadCount: 0,
        messagesUnreadCount: 0,
      ));
    } catch (e) {
      emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
    }
  }

  List<PrivateMessageView> cleanDeletedMessages(List<PrivateMessageView> messages) {
    List<PrivateMessageView> cleanMessages = [];

    for (PrivateMessageView message in messages) {
      cleanMessages.add(cleanDeletedPrivateMessage(message));
    }

    return cleanMessages;
  }

  List<PersonMentionView> cleanDeletedMentions(List<PersonMentionView> mentions) {
    List<PersonMentionView> cleanedMentions = [];

    for (PersonMentionView mention in mentions) {
      cleanedMentions.add(cleanDeletedMention(mention));
    }

    return cleanedMentions;
  }

  PrivateMessageView cleanDeletedPrivateMessage(PrivateMessageView message) {
    if (message.privateMessage.deleted) {
      return message.copyWith(
        privateMessage: message.privateMessage.copyWith(
          content: "_deleted by creator_",
        ),
      );
    }

    return message;
  }

  PersonMentionView cleanDeletedMention(PersonMentionView mention) {
    if (mention.comment.removed) {
      return mention.copyWith(
        comment: mention.comment.copyWith(
          content: "_deleted by moderator_",
        ),
      );
    }

    if (mention.comment.deleted) {
      return mention.copyWith(
        comment: mention.comment.copyWith(
          content: "_deleted by creator_",
        ),
      );
    }

    return mention;
  }
}
