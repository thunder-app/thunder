enum SwipeAction {
  upvote(friendlyName: 'Upvote'),
  downvote(friendlyName: 'Downvote'),
  reply(friendlyName: 'Reply'),
  save(friendlyName: 'Save'),
  edit(friendlyName: 'Edit'),
  toggleRead(friendlyName: 'Mark As Read/Unread'),
  none(friendlyName: 'None');

  const SwipeAction({
    required this.friendlyName,
  });

  final String friendlyName;
}
