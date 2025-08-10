enum FeedCardDividerThickness {
  compact,
  standard,
  comfortable;

  double get value {
    switch (this) {
      case FeedCardDividerThickness.compact:
        return 2.0;
      case FeedCardDividerThickness.standard:
        return 6.0;
      case FeedCardDividerThickness.comfortable:
        return 10.0;
    }
  }
}
