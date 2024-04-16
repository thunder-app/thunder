import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/comment/utils/comment.dart';

part 'inbox_event.dart';
part 'inbox_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 5);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  /// Constructor allowing an initial set of replies to be set in the state.
  InboxBloc.withReplies(List<CommentReplyView> replies) : super(InboxState(replies: replies)) {
    _init();
  }

  /// Unnamed constructor with default state
  InboxBloc() : super(const InboxState()) {
    _init();
  }

  void _init() {
    on<GetInboxEvent>(
      _getInboxEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<MarkReplyAsReadEvent>(
      _markReplyAsReadEvent,
      // Do not throttle mark as read because it's something
      // a user might try to do in quick succession to multiple messages
      transformer: throttleDroppable(Duration.zero),
    );
    on<MarkMentionAsReadEvent>(
      _markMentionAsReadEvent,
      // Do not throttle mark as read because it's something
      // a user might try to do in quick succession to multiple messages
      transformer: throttleDroppable(Duration.zero),
    );
    on<CreateInboxCommentReplyEvent>(
      _createCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<MarkAllAsReadEvent>(
      _markAllAsRead,
      // Do not throttle mark as read because it's something
      // a user might try to do in quick succession to multiple messages
      transformer: throttleDroppable(Duration.zero),
    );
  }

  Future<void> _getInboxEvent(GetInboxEvent event, emit) async {
    int attemptCount = 0;
    int limit = 20;

    try {
      Object? exception;

      Account? account = await fetchActiveProfileAccount();

      while (attemptCount < 2) {
        try {
          LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

          if (event.reset) {
            emit(state.copyWith(status: InboxStatus.loading));
            // Fetch all the things
            PrivateMessagesResponse privateMessagesResponse = await lemmy.run(
              GetPrivateMessages(
                auth: account!.jwt!,
                unreadOnly: !event.showAll,
                limit: limit,
                page: 1,
              ),
            );

            GetPersonMentionsResponse getPersonMentionsResponse = await lemmy.run(
              GetPersonMentions(
                auth: account.jwt!,
                unreadOnly: !event.showAll,
                sort: CommentSortType.new_,
                limit: limit,
                page: 1,
              ),
            );

            GetRepliesResponse getRepliesResponse = await lemmy.run(
              GetReplies(
                auth: account.jwt!,
                unreadOnly: !event.showAll,
                limit: limit,
                sort: CommentSortType.new_,
                page: 1,
              ),
            );

            GetUnreadCountResponse getUnreadCountResponse = await lemmy.run(
              GetUnreadCount(
                auth: account.jwt!,
              ),
            );

            int totalUnreadCount = getUnreadCountResponse.privateMessages + getUnreadCountResponse.mentions + getUnreadCountResponse.replies;

            return emit(
              state.copyWith(
                status: InboxStatus.success,
                privateMessages: cleanDeletedMessages(privateMessagesResponse.privateMessages),
                mentions: cleanDeletedMentions(getPersonMentionsResponse.mentions),
                replies: getRepliesResponse.replies,
                showUnreadOnly: !event.showAll,
                inboxMentionPage: 2,
                inboxReplyPage: 2,
                inboxPrivateMessagePage: 2,
                totalUnreadCount: totalUnreadCount,
                repliesUnreadCount: getUnreadCountResponse.replies,
                mentionsUnreadCount: getUnreadCountResponse.mentions,
                messagesUnreadCount: getUnreadCountResponse.privateMessages,
                hasReachedInboxReplyEnd: getRepliesResponse.replies.isEmpty || getRepliesResponse.replies.length < limit,
                hasReachedInboxMentionEnd: getPersonMentionsResponse.mentions.isEmpty || getPersonMentionsResponse.mentions.length < limit,
                hasReachedInboxPrivateMessageEnd: privateMessagesResponse.privateMessages.isEmpty || privateMessagesResponse.privateMessages.length < limit,
              ),
            );
          }

          // Prevent duplicate requests if we're done fetching
          if (state.hasReachedInboxReplyEnd && state.hasReachedInboxMentionEnd && state.hasReachedInboxPrivateMessageEnd) return;
          emit(state.copyWith(status: InboxStatus.refreshing));

          // Fetch all the things
          PrivateMessagesResponse privateMessagesResponse = await lemmy.run(
            GetPrivateMessages(
              auth: account!.jwt!,
              unreadOnly: !event.showAll,
              limit: limit,
              page: state.inboxPrivateMessagePage,
            ),
          );

          GetPersonMentionsResponse getPersonMentionsResponse = await lemmy.run(
            GetPersonMentions(
              auth: account.jwt!,
              unreadOnly: !event.showAll,
              sort: CommentSortType.new_,
              limit: limit,
              page: state.inboxMentionPage,
            ),
          );

          GetRepliesResponse getRepliesResponse = await lemmy.run(
            GetReplies(
              auth: account.jwt!,
              unreadOnly: !event.showAll,
              limit: limit,
              sort: CommentSortType.new_,
              page: state.inboxReplyPage,
            ),
          );

          List<CommentReplyView> replies = List.from(state.replies)..addAll(getRepliesResponse.replies);
          List<PersonMentionView> mentions = List.from(state.mentions)..addAll(getPersonMentionsResponse.mentions);
          List<PrivateMessageView> privateMessages = List.from(state.privateMessages)..addAll(privateMessagesResponse.privateMessages);

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
              hasReachedInboxReplyEnd: getRepliesResponse.replies.isEmpty || getRepliesResponse.replies.length < limit,
              hasReachedInboxMentionEnd: getPersonMentionsResponse.mentions.isEmpty || getPersonMentionsResponse.mentions.length < limit,
              hasReachedInboxPrivateMessageEnd: privateMessagesResponse.privateMessages.isEmpty || privateMessagesResponse.privateMessages.length < limit,
            ),
          );
        } catch (e) {
          exception = e;
          attemptCount++;
        }
      }

      emit(state.copyWith(
        status: InboxStatus.failure,
        errorMessage: exception.toString(),
        totalUnreadCount: 0,
        repliesUnreadCount: 0,
        mentionsUnreadCount: 0,
        messagesUnreadCount: 0,
      ));
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

  Future<void> _markReplyAsReadEvent(MarkReplyAsReadEvent event, emit) async {
    try {
      emit(state.copyWith(status: InboxStatus.refreshing));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(state.copyWith(status: InboxStatus.success));
      }

      CommentReplyResponse response = await lemmy.run(MarkCommentReplyAsRead(
        auth: account!.jwt!,
        commentReplyId: event.commentReplyId,
        read: event.read,
      ));

      // Remove the post from the current reply list, or just mark it as read
      List<CommentReplyView> replies = List.from(state.replies);
      bool matchMarkedComment(CommentReplyView commentView) => commentView.commentReply.id == response.commentReplyView.commentReply.id;
      if (event.showAll) {
        final CommentReplyView markedComment = replies.firstWhere(matchMarkedComment);
        final int index = replies.indexOf(markedComment);
        replies[index] = markedComment.copyWith(comment: response.commentReplyView.comment);
      } else {
        replies.removeWhere(matchMarkedComment);
      }

      GetUnreadCountResponse getUnreadCountResponse = await lemmy.run(
        GetUnreadCount(
          auth: account.jwt!,
        ),
      );

      int totalUnreadCount = getUnreadCountResponse.privateMessages + getUnreadCountResponse.mentions + getUnreadCountResponse.replies;

      emit(state.copyWith(
        status: InboxStatus.success,
        replies: replies,
        totalUnreadCount: totalUnreadCount,
        repliesUnreadCount: getUnreadCountResponse.replies,
        mentionsUnreadCount: getUnreadCountResponse.mentions,
        messagesUnreadCount: getUnreadCountResponse.privateMessages,
      ));
    } catch (e) {
      return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _markMentionAsReadEvent(MarkMentionAsReadEvent event, emit) async {
    try {
      emit(state.copyWith(
        status: InboxStatus.loading,
        privateMessages: state.privateMessages,
        mentions: state.mentions,
        replies: state.replies,
      ));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(state.copyWith(status: InboxStatus.success));
      }

      await lemmy.run(MarkPersonMentionAsRead(
        auth: account!.jwt!,
        personMentionId: event.personMentionId,
        read: event.read,
      ));

      add(GetInboxEvent(showAll: !state.showUnreadOnly));
    } catch (e) {
      return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _createCommentEvent(CreateInboxCommentReplyEvent event, Emitter<InboxState> emit) async {
    try {
      emit(state.copyWith(status: InboxStatus.refreshing));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(state.copyWith(status: InboxStatus.failure, errorMessage: 'You are not logged in. Cannot create a comment'));
      }

      await lemmy.run(CreateComment(
        auth: account!.jwt!,
        content: event.content,
        postId: event.postId,
        parentId: event.parentCommentId,
      ));

      add(GetInboxEvent(showAll: !state.showUnreadOnly));
      return emit(state.copyWith(status: InboxStatus.success));
    } catch (e) {
      return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _markAllAsRead(MarkAllAsReadEvent event, emit) async {
    try {
      emit(state.copyWith(
        status: InboxStatus.refreshing,
      ));
      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(state.copyWith(status: InboxStatus.success));
      }
      await lemmy.run(MarkAllAsRead(
        auth: account!.jwt!,
      ));

      add(GetInboxEvent(reset: true, showAll: !state.showUnreadOnly));
    } catch (e) {
      emit(state.copyWith(
        status: InboxStatus.failure,
        errorMessage: e.toString(),
      ));
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
