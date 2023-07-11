import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

part 'inbox_event.dart';
part 'inbox_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 3);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  InboxBloc() : super(const InboxState()) {
    on<GetInboxEvent>(
      _getInboxEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<MarkReplyAsReadEvent>(
      _markReplyAsReadEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<MarkMentionAsReadEvent>(
      _markMentionAsReadEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<CreateInboxCommentReplyEvent>(
      _createCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _getInboxEvent(GetInboxEvent event, emit) async {
    int attemptCount = 0;
    int limit = 20;

    try {
      var exception;

      Account? account = await fetchActiveProfileAccount();

      while (attemptCount < 2) {
        try {
          LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

          if (event.reset) {
            emit(state.copyWith(status: InboxStatus.loading));
            // Fetch all the things
            List<PrivateMessageView> privateMessageViews = await lemmy.run(
              GetPrivateMessages(
                auth: account!.jwt!,
                unreadOnly: !event.showAll,
                limit: limit,
                page: 1,
              ),
            );

            List<PersonMentionView> personMentionViews = await lemmy.run(
              GetPersonMentions(
                auth: account.jwt!,
                unreadOnly: !event.showAll,
                sort: SortType.new_,
                limit: limit,
                page: 1,
              ),
            );

            List<CommentView> commentViews = await lemmy.run(
              GetReplies(
                auth: account.jwt!,
                unreadOnly: !event.showAll,
                limit: limit,
                sort: SortType.new_,
                page: 1,
              ),
            );

            return emit(
              state.copyWith(
                status: InboxStatus.success,
                privateMessages: privateMessageViews,
                mentions: personMentionViews,
                replies: commentViews,
                showUnreadOnly: !event.showAll,
                inboxMentionPage: 2,
                inboxReplyPage: 2,
                inboxPrivateMessagePage: 2,
                hasReachedInboxReplyEnd: commentViews.isEmpty || commentViews.length < limit,
                hasReachedInboxMentionEnd: personMentionViews.isEmpty || personMentionViews.length < limit,
                hasReachedInboxPrivateMessageEnd: privateMessageViews.isEmpty || privateMessageViews.length < limit,
              ),
            );
          }

          // Prevent duplicate requests if we're done fetching
          if (state.hasReachedInboxReplyEnd && state.hasReachedInboxMentionEnd && state.hasReachedInboxPrivateMessageEnd) return;
          emit(state.copyWith(status: InboxStatus.refreshing));

          // Fetch all the things
          List<PrivateMessageView> privateMessageViews = await lemmy.run(
            GetPrivateMessages(
              auth: account!.jwt!,
              unreadOnly: !event.showAll,
              limit: limit,
              page: state.inboxPrivateMessagePage,
            ),
          );

          List<PersonMentionView> personMentionViews = await lemmy.run(
            GetPersonMentions(
              auth: account.jwt!,
              unreadOnly: !event.showAll,
              sort: SortType.new_,
              limit: limit,
              page: state.inboxMentionPage,
            ),
          );

          List<CommentView> commentViews = await lemmy.run(
            GetReplies(
              auth: account.jwt!,
              unreadOnly: !event.showAll,
              limit: limit,
              sort: SortType.new_,
              page: state.inboxReplyPage,
            ),
          );

          List<CommentView> replies = List.from(state.replies)..addAll(commentViews);
          List<PersonMentionView> mentions = List.from(state.mentions)..addAll(personMentionViews);
          List<PrivateMessageView> privateMessages = List.from(state.privateMessages)..addAll(privateMessageViews);

          return emit(
            state.copyWith(
              status: InboxStatus.success,
              privateMessages: privateMessages,
              mentions: mentions,
              replies: replies,
              showUnreadOnly: state.showUnreadOnly,
              inboxMentionPage: state.inboxMentionPage + 1,
              inboxReplyPage: state.inboxReplyPage + 1,
              inboxPrivateMessagePage: state.inboxPrivateMessagePage + 1,
              hasReachedInboxReplyEnd: commentViews.isEmpty || commentViews.length < limit,
              hasReachedInboxMentionEnd: personMentionViews.isEmpty || personMentionViews.length < limit,
              hasReachedInboxPrivateMessageEnd: privateMessageViews.isEmpty || privateMessageViews.length < limit,
            ),
          );
        } catch (e, s) {
          exception = e;
          attemptCount++;
        }
      }

      emit(state.copyWith(status: InboxStatus.failure, errorMessage: exception.toString()));
    } catch (e, s) {
      emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
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

      FullCommentReplyView response = await lemmy.run(MarkCommentAsRead(
        auth: account!.jwt!,
        commentReplyId: event.commentReplyId,
        read: event.read,
      ));

      // Remove the post from the current reply list
      List<CommentView> replies = List.from(state.replies)..removeWhere((element) => element.commentReply?.id == response.commentReplyView.commentReply.id);

      emit(state.copyWith(status: InboxStatus.success, replies: replies));
    } catch (e, s) {
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

      PersonMentionView personMentionView = await lemmy.run(MarkPersonMentionAsRead(
        auth: account!.jwt!,
        personMentionId: event.personMentionId,
        read: event.read,
      ));

      add(GetInboxEvent(showAll: !state.showUnreadOnly));
    } catch (e, s) {
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

      FullCommentView fullCommentView = await lemmy.run(CreateComment(
        auth: account!.jwt!,
        content: event.content,
        postId: event.postId,
        parentId: event.parentCommentId,
      ));

      add(GetInboxEvent(showAll: !state.showUnreadOnly));
      return emit(state.copyWith(status: InboxStatus.success));
    } catch (e, s) {
      return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
    }
  }
}
