import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/comment/enums/comment_action.dart';
import 'package:thunder/comment/utils/comment.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/inbox/enums/inbox_type.dart';
import 'package:thunder/utils/global_context.dart';

part 'inbox_event.dart';
part 'inbox_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 5);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  /// Constructor allowing an initial set of replies to be set in the state.
  InboxBloc.initWith({required List<CommentReplyView> replies, required bool showUnreadOnly}) : super(InboxState(replies: replies, showUnreadOnly: showUnreadOnly)) {
    _init();
  }

  /// Unnamed constructor with default state
  InboxBloc() : super(const InboxState()) {
    _init();
  }

  void _init() {
    on<GetInboxEvent>(_getInboxEvent, transformer: restartable());
    on<InboxItemActionEvent>(_inboxItemActionEvent);
    on<MarkAllAsReadEvent>(_markAllAsRead);
  }

  Future<void> _getInboxEvent(GetInboxEvent event, emit) async {
    int limit = 20;

    Account? account = await fetchActiveProfileAccount();
    if (account?.jwt == null) {
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

    try {
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      PrivateMessagesResponse? privateMessagesResponse;
      GetPersonMentionsResponse? getPersonMentionsResponse;
      GetRepliesResponse? getRepliesResponse;

      if (event.reset) {
        emit(state.copyWith(status: InboxStatus.loading, errorMessage: ''));

        switch (event.inboxType) {
          case InboxType.replies:
            getRepliesResponse = await lemmy.run(
              GetReplies(
                auth: account!.jwt!,
                unreadOnly: !event.showAll,
                limit: limit,
                sort: event.commentSortType,
                page: 1,
              ),
            );
            break;
          case InboxType.mentions:
            getPersonMentionsResponse = await lemmy.run(
              GetPersonMentions(
                auth: account!.jwt!,
                unreadOnly: !event.showAll,
                sort: event.commentSortType,
                limit: limit,
                page: 1,
              ),
            );
            break;
          case InboxType.messages:
            privateMessagesResponse = await lemmy.run(
              GetPrivateMessages(
                auth: account!.jwt!,
                unreadOnly: !event.showAll,
                limit: limit,
                page: 1,
              ),
            );
            break;
          case InboxType.all:
            getRepliesResponse = await lemmy.run(
              GetReplies(
                auth: account!.jwt!,
                unreadOnly: !event.showAll,
                limit: limit,
                sort: event.commentSortType,
                page: 1,
              ),
            );
            getPersonMentionsResponse = await lemmy.run(
              GetPersonMentions(
                auth: account.jwt!,
                unreadOnly: !event.showAll,
                sort: event.commentSortType,
                limit: limit,
                page: 1,
              ),
            );
            privateMessagesResponse = await lemmy.run(
              GetPrivateMessages(
                auth: account.jwt!,
                unreadOnly: !event.showAll,
                limit: limit,
                page: 1,
              ),
            );
            break;
          default:
            break;
        }

        GetUnreadCountResponse getUnreadCountResponse = await lemmy.run(GetUnreadCount(auth: account!.jwt!));
        int totalUnreadCount = getUnreadCountResponse.privateMessages + getUnreadCountResponse.mentions + getUnreadCountResponse.replies;

        return emit(
          state.copyWith(
            status: InboxStatus.success,
            privateMessages: cleanDeletedMessages(privateMessagesResponse?.privateMessages ?? []),
            mentions: cleanDeletedMentions(getPersonMentionsResponse?.mentions ?? []),
            replies: getRepliesResponse?.replies.toList() ?? [], // Copy this list so that it is modifyable
            showUnreadOnly: !event.showAll,
            inboxMentionPage: 2,
            inboxReplyPage: 2,
            inboxPrivateMessagePage: 2,
            totalUnreadCount: totalUnreadCount,
            repliesUnreadCount: getUnreadCountResponse.replies,
            mentionsUnreadCount: getUnreadCountResponse.mentions,
            messagesUnreadCount: getUnreadCountResponse.privateMessages,
            hasReachedInboxReplyEnd: getRepliesResponse?.replies.isEmpty == true || (getRepliesResponse?.replies.length ?? 0) < limit,
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

          getRepliesResponse = await lemmy.run(
            GetReplies(
              auth: account!.jwt!,
              unreadOnly: state.showUnreadOnly,
              limit: limit,
              sort: event.commentSortType,
              page: state.inboxReplyPage,
            ),
          );
          break;
        case InboxType.mentions:
          if (state.hasReachedInboxMentionEnd) return;

          getPersonMentionsResponse = await lemmy.run(
            GetPersonMentions(
              auth: account!.jwt!,
              unreadOnly: state.showUnreadOnly,
              sort: event.commentSortType,
              limit: limit,
              page: state.inboxMentionPage,
            ),
          );
          break;
        case InboxType.messages:
          if (state.hasReachedInboxPrivateMessageEnd) return;
          privateMessagesResponse = await lemmy.run(
            GetPrivateMessages(
              auth: account!.jwt!,
              unreadOnly: state.showUnreadOnly,
              limit: limit,
              page: state.inboxPrivateMessagePage,
            ),
          );
          break;
        default:
          break;
      }

      List<CommentReplyView> replies = List.from(state.replies)..addAll(getRepliesResponse?.replies ?? []);
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
          hasReachedInboxReplyEnd: getRepliesResponse?.replies.isEmpty == true || (getRepliesResponse?.replies.length ?? 0) < limit,
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
    assert(!(event.commentReplyId == null && event.personMentionId == null));
    emit(state.copyWith(status: InboxStatus.refreshing, errorMessage: ''));

    int existingIndex = -1;

    CommentReplyView? existingCommentReplyView;
    PersonMentionView? existingPersonMentionView;

    if (event.commentReplyId != null) {
      existingIndex = state.replies.indexWhere((element) => element.commentReply.id == event.commentReplyId);
      existingCommentReplyView = state.replies[existingIndex];
    } else if (event.personMentionId != null) {
      existingIndex = state.mentions.indexWhere((element) => element.personMention.id == event.personMentionId);
      existingPersonMentionView = state.mentions[existingIndex];
    }

    if (existingCommentReplyView == null && existingPersonMentionView == null) return emit(state.copyWith(status: InboxStatus.failure));

    /// Convert the reply or mention to a comment
    CommentView? commentView;

    if (existingCommentReplyView != null) {
      commentView = CommentView(
        comment: existingCommentReplyView.comment,
        creator: existingCommentReplyView.creator,
        post: existingCommentReplyView.post,
        community: existingCommentReplyView.community,
        counts: existingCommentReplyView.counts,
        creatorBannedFromCommunity: existingCommentReplyView.creatorBannedFromCommunity,
        subscribed: existingCommentReplyView.subscribed,
        saved: existingCommentReplyView.saved,
        creatorBlocked: existingCommentReplyView.creatorBlocked,
        myVote: existingCommentReplyView.myVote as int?,
      );
    } else if (existingPersonMentionView != null) {
      commentView = CommentView(
        comment: existingPersonMentionView.comment,
        creator: existingPersonMentionView.creator,
        post: existingPersonMentionView.post,
        community: existingPersonMentionView.community,
        counts: existingPersonMentionView.counts,
        creatorBannedFromCommunity: existingPersonMentionView.creatorBannedFromCommunity,
        subscribed: existingPersonMentionView.subscribed,
        saved: existingPersonMentionView.saved,
        creatorBlocked: existingPersonMentionView.creatorBlocked,
        myVote: existingPersonMentionView.myVote,
      );
    }

    switch (event.action) {
      case CommentAction.read:
        try {
          // Optimistically remove the reply from the list or change the status (depending on whether we're showing all)
          if (existingCommentReplyView != null) {
            if (!state.showUnreadOnly) {
              state.replies[existingIndex] = existingCommentReplyView.copyWith(commentReply: existingCommentReplyView.commentReply.copyWith(read: event.value));
            } else if (event.value == true) {
              state.replies.remove(existingCommentReplyView);
            }
          } else if (existingPersonMentionView != null) {
            if (!state.showUnreadOnly) {
              state.mentions[existingIndex] = existingPersonMentionView.copyWith(personMention: existingPersonMentionView.personMention.copyWith(read: event.value));
            } else if (event.value == true) {
              state.mentions.remove(existingPersonMentionView);
            }
          }

          Account? account = await fetchActiveProfileAccount();
          LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

          if (account?.jwt == null) return emit(state.copyWith(status: InboxStatus.success));

          if (existingCommentReplyView != null) {
            await lemmy.run(MarkCommentReplyAsRead(
              auth: account!.jwt!,
              commentReplyId: event.commentReplyId!,
              read: event.value,
            ));
          } else if (existingPersonMentionView != null) {
            await lemmy.run(MarkPersonMentionAsRead(
              auth: account!.jwt!,
              personMentionId: event.personMentionId!,
              read: event.value,
            ));
          }

          GetUnreadCountResponse getUnreadCountResponse = await lemmy.run(GetUnreadCount(auth: account!.jwt!));
          int totalUnreadCount = getUnreadCountResponse.privateMessages + getUnreadCountResponse.mentions + getUnreadCountResponse.replies;

          return emit(state.copyWith(
            status: InboxStatus.success,
            totalUnreadCount: totalUnreadCount,
            repliesUnreadCount: getUnreadCountResponse.replies,
            mentionsUnreadCount: getUnreadCountResponse.mentions,
            messagesUnreadCount: getUnreadCountResponse.privateMessages,
            inboxReplyMarkedAsRead: event.commentReplyId,
          ));
        } catch (e) {
          return emit(state.copyWith(status: InboxStatus.failure, errorMessage: e.toString()));
        }
      case CommentAction.vote:
        try {
          CommentView updatedCommentView = optimisticallyVoteComment(commentView!, event.value);

          if (existingCommentReplyView != null) {
            state.replies[existingIndex] = existingCommentReplyView.copyWith(counts: updatedCommentView.counts, myVote: updatedCommentView.myVote);
          } else if (existingPersonMentionView != null) {
            state.mentions[existingIndex] = existingPersonMentionView.copyWith(counts: updatedCommentView.counts, myVote: updatedCommentView.myVote);
          }

          // Immediately set the status, and continue
          emit(state.copyWith(status: InboxStatus.success));
          emit(state.copyWith(status: InboxStatus.refreshing));

          await voteComment(commentView.comment.id, event.value).timeout(timeout, onTimeout: () {
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
          CommentView updatedCommentView = optimisticallySaveComment(commentView!, event.value);

          if (existingCommentReplyView != null) {
            state.replies[existingIndex] = existingCommentReplyView.copyWith(saved: updatedCommentView.saved);
          } else if (existingPersonMentionView != null) {
            state.mentions[existingIndex] = existingPersonMentionView.copyWith(saved: updatedCommentView.saved);
          }

          // Immediately set the status, and continue
          emit(state.copyWith(status: InboxStatus.success));
          emit(state.copyWith(status: InboxStatus.refreshing));

          await saveComment(commentView.comment.id, event.value).timeout(timeout, onTimeout: () {
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
          CommentView updatedCommentView = optimisticallyDeleteComment(commentView!, event.value);

          if (existingCommentReplyView != null) {
            state.replies[existingIndex] = existingCommentReplyView.copyWith(comment: updatedCommentView.comment);
          } else if (existingPersonMentionView != null) {
            state.mentions[existingIndex] = existingPersonMentionView.copyWith(comment: updatedCommentView.comment);
          }

          // Immediately set the status, and continue
          emit(state.copyWith(status: InboxStatus.success));
          emit(state.copyWith(status: InboxStatus.refreshing));

          await deleteComment(commentView.comment.id, event.value).timeout(timeout, onTimeout: () {
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

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) return emit(state.copyWith(status: InboxStatus.success));
      await lemmy.run(MarkAllAsRead(auth: account!.jwt!));

      // Update all the replies, mentions, and messages to be read locally
      List<CommentReplyView> updatedReplies = state.replies.map((commentReplyView) => commentReplyView.copyWith(commentReply: commentReplyView.commentReply.copyWith(read: true))).toList();
      List<PersonMentionView> updatedMentions = state.mentions.map((personMentionView) => personMentionView.copyWith(personMention: personMentionView.personMention.copyWith(read: true))).toList();
      List<PrivateMessageView> updatedPrivateMessages =
          state.privateMessages.map((privateMessageView) => privateMessageView.copyWith(privateMessage: privateMessageView.privateMessage.copyWith(read: true))).toList();

      return emit(state.copyWith(
        status: InboxStatus.success,
        replies: updatedReplies,
        mentions: updatedMentions,
        privateMessages: updatedPrivateMessages,
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
