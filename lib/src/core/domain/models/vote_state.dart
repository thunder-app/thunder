enum VoteState {
  /// The signed-in account has not voted, or the vote state is unknown.
  none,

  /// The signed-in account upvoted the item.
  up,

  /// The signed-in account downvoted the item.
  down;

  /// Score value used when an API expects `1`, `0`, or `-1`.
  int get score => switch (this) {
    VoteState.up => 1,
    VoteState.down => -1,
    VoteState.none => 0,
  };

  /// Creates a vote state from a score-style value.
  static VoteState fromScore(int? score) {
    return switch (score) {
      1 => VoteState.up,
      -1 => VoteState.down,
      _ => VoteState.none,
    };
  }

  /// Creates a vote state from an upvote/downvote flag.
  static VoteState fromIsUpvote(bool? isUpvote) {
    return switch (isUpvote) {
      true => VoteState.up,
      false => VoteState.down,
      null => VoteState.none,
    };
  }
}
