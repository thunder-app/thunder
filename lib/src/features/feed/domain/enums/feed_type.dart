/// The type of feed content shown on a feed page.
enum FeedType {
  /// A feed scoped to a single community.
  community,

  /// A feed scoped to a single user.
  user,

  /// A general listing feed, such as subscribed, local, or all.
  general,

  /// The current account's own posts and comments.
  account,
}
