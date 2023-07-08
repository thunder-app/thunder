import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

part 'inbox_event.dart';
part 'inbox_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 3);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) =>
      droppable<E>().call(events.throttle(duration), mapper);
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
    try {
      emit(state.copyWith(status: InboxStatus.loading));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(state.copyWith(status: InboxStatus.success));
      }

      // Fetch all the things
      List<PrivateMessageView> privateMessageViews =
          await lemmy.run(GetPrivateMessages(
        auth: account!.jwt!,
        unreadOnly: !event.showAll,
      ));

      List<PersonMentionView> personMentionViews =
          await lemmy.run(GetPersonMentions(
        auth: account.jwt!,
        unreadOnly: !event.showAll,
        sort: SortType.new_,
      ));

      List<CommentView> commentViews = await lemmy.run(GetReplies(
        auth: account.jwt!,
        unreadOnly: !event.showAll,
      ));

      // This depends on the fact that by default we request UNREAD by default.
      // Might be problems if the user clicks "Show All" before the default
      // unread completes the request
      int unreadCount = 0;
      if (!event.showAll) {
        int unreadCount = privateMessageViews.length +
            personMentionViews.length +
            commentViews.length;
      }

      return emit(state.copyWith(
        status: InboxStatus.success,
        privateMessages: privateMessageViews,
        mentions: personMentionViews,
        replies: commentViews,
        unreadCount: unreadCount,
        showUnreadOnly: !event.showAll,
      ));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(
          status: InboxStatus.failure,
          errorMessage: e.toString()
      ));
    }
  }

  Future<void> _markReplyAsReadEvent(MarkReplyAsReadEvent event, emit) async {
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

      FullCommentReplyView response = await lemmy.run(MarkCommentAsRead(
        auth: account!.jwt!,
        commentReplyId: event.commentReplyId,
        read: event.read,
      ));

      add(GetInboxEvent(showAll: !state.showUnreadOnly));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(
          status: InboxStatus.failure,
          errorMessage: e.toString()
      ));
    }
  }

  Future<void> _markMentionAsReadEvent(
      MarkMentionAsReadEvent event, emit) async {
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

      PersonMentionView personMentionView =
          await lemmy.run(MarkPersonMentionAsRead(
        auth: account!.jwt!,
        personMentionId: event.personMentionId,
        read: event.read,
      ));

      add(GetInboxEvent(showAll: !state.showUnreadOnly));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(
          status: InboxStatus.failure,
          errorMessage: e.toString()
      ));
    }
  }

  Future<void> _createCommentEvent(
      CreateInboxCommentReplyEvent event, Emitter<InboxState> emit) async {
    try {
      emit(state.copyWith(status: InboxStatus.refreshing));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(state.copyWith(
            status: InboxStatus.failure,
            errorMessage: 'You are not logged in. Cannot create a comment'));
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
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(
          status: InboxStatus.failure, errorMessage: e.toString()));
    }
  }
}
