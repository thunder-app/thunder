enum SwipeAction {
  upvote(label: 'Upvote'),
  downvote(label: 'Downvote'),
  reply(label: 'Reply'),
  save(label: 'Save'),
  edit(label: 'Edit'),
  toggleRead(label: 'Mark As Read/Unread'),
  none(label: 'None');

  const SwipeAction({
    required this.label,
  });

  final String label;
}
