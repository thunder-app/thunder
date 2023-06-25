import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lemmy/lemmy.dart';
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
    on<CreateInboxCommentReplyEvent>(
      _createCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _getInboxEvent(GetInboxEvent event, emit) async {
    try {
      emit(state.copyWith(status: InboxStatus.loading));

      Account? account = await fetchActiveProfileAccount();
      Lemmy lemmy = LemmyClient.instance.lemmy;

      if (account?.jwt == null) {
        return emit(state.copyWith(status: InboxStatus.success));
      }

      // Fetch all the things
      PrivateMessagesResponse privateMessagesResponse = await lemmy.getPrivateMessages(
        GetPrivateMessages(auth: account!.jwt!, unreadOnly: event.showAll),
      );

      GetPersonMentionsResponse personMentions = await lemmy.getPersonMentions(GetPersonMentions(
        auth: account.jwt!,
        unreadOnly: event.showAll,
        sort: CommentSortType.New,
      ));

      GetRepliesResponse repliesResponse = await lemmy.getReplies(GetReplies(
        auth: account.jwt!,
        unreadOnly: !event.showAll,
      ));

      return emit(state.copyWith(
        status: InboxStatus.success,
        privateMessages: privateMessagesResponse.privateMessages,
        mentions: personMentions.mentions,
        replies: repliesResponse.replies,
      ));
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.message));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _markReplyAsReadEvent(MarkReplyAsReadEvent event, emit) async {
    try {
      emit(state.copyWith(status: InboxStatus.loading));

      Account? account = await fetchActiveProfileAccount();
      Lemmy lemmy = LemmyClient.instance.lemmy;

      if (account?.jwt == null) {
        return emit(state.copyWith(status: InboxStatus.success));
      }

      CommentReplyResponse response = await lemmy.markCommentReplyAsRead(
        MarkCommentReplyAsRead(
          auth: account!.jwt!,
          commentReplyId: event.commentReplyId,
          read: event.read,
        ),
      );

      return emit(state.copyWith(
        status: InboxStatus.success,
        privateMessages: state.privateMessages,
        mentions: state.mentions,
        replies: state.replies,
      ));
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.message));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _createCommentEvent(CreateInboxCommentReplyEvent event, Emitter<InboxState> emit) async {
    try {
      emit(state.copyWith(status: InboxStatus.refreshing));

      Account? account = await fetchActiveProfileAccount();
      Lemmy lemmy = LemmyClient.instance.lemmy;

      if (account?.jwt == null) {
        return emit(state.copyWith(status: InboxStatus.failure, errorMessage: 'You are not logged in. Cannot create a comment'));
      }

      CommentResponse createComment = await lemmy.createComment(
        CreateComment(
          auth: account!.jwt!,
          content: event.content,
          postId: event.postId,
          parentId: event.parentCommentId,
        ),
      );

      return emit(state.copyWith(status: InboxStatus.success));
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      if (e.type == DioExceptionType.receiveTimeout) {
        return emit(
          state.copyWith(
            status: InboxStatus.failure,
            errorMessage: 'Error: Network timeout when attempting to create a comment',
          ),
        );
      } else {
        return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
      }
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
    }
  }
}
