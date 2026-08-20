class UnreadNotificationsCount {
  final int replies;
  final int mentions;
  final int privateMessages;

  const UnreadNotificationsCount({required this.replies, required this.mentions, required this.privateMessages});

  int get total => replies + mentions + privateMessages;
}
