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
        GetPrivateMessages(auth: account!.jwt!),
      );

      GetPersonMentionsResponse personMentions = await lemmy.getPersonMentions(GetPersonMentions(
        auth: account.jwt!,
        sort: CommentSortType.New,
      ));

      GetRepliesResponse repliesResponse = await lemmy.getReplies(GetReplies(
        auth: account.jwt!,
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
}
