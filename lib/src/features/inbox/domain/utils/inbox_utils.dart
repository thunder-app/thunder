import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/inbox/inbox.dart';

List<ThunderPrivateMessage> cleanDeletedMessages(
  List<ThunderPrivateMessage> messages,
) {
  return messages.map(cleanDeletedPrivateMessage).toList();
}

List<ThunderComment> cleanDeletedMentions(List<ThunderComment> mentions) {
  return mentions.map(cleanDeletedMention).toList();
}

ThunderPrivateMessage cleanDeletedPrivateMessage(
  ThunderPrivateMessage message,
) {
  if (message.deleted) {
    return message.copyWith(content: '_deleted by creator_');
  }
  return message;
}

ThunderComment cleanDeletedMention(ThunderComment mention) {
  if (mention.status.removed) {
    return mention.copyWith(content: '_deleted by moderator_');
  }
  if (mention.status.deleted) {
    return mention.copyWith(content: '_deleted by creator_');
  }
  return mention;
}

({int mentionPage, int replyPage, int messagePage}) resetPagesForType(InboxType? type) {
  final mentionsFetched = type == InboxType.mentions || type == InboxType.all;
  final repliesFetched = type == InboxType.replies || type == InboxType.all;
  final messagesFetched = type == InboxType.messages || type == InboxType.all;

  return (
    mentionPage: mentionsFetched ? 2 : 1,
    replyPage: repliesFetched ? 2 : 1,
    messagePage: messagesFetched ? 2 : 1,
  );
}

({int mentionPage, int replyPage, int messagePage}) incrementFetchedPage({
  required InboxType? type,
  required int currentMentionPage,
  required int currentReplyPage,
  required int currentMessagePage,
}) {
  return (
    mentionPage: type == InboxType.mentions ? currentMentionPage + 1 : currentMentionPage,
    replyPage: type == InboxType.replies ? currentReplyPage + 1 : currentReplyPage,
    messagePage: type == InboxType.messages ? currentMessagePage + 1 : currentMessagePage,
  );
}
