import 'package:thunder/src/core/config/global_context.dart';

enum FeedCardDividerThickness {
  compact,
  standard,
  comfortable,
  large;

  double get value {
    switch (this) {
      case FeedCardDividerThickness.compact:
        return 2.0;
      case FeedCardDividerThickness.standard:
        return 6.0;
      case FeedCardDividerThickness.comfortable:
        return 10.0;
      case FeedCardDividerThickness.large:
        return 16.0;
    }
  }

  String get label {
    final l10n = GlobalContext.l10n;

    switch (this) {
      case FeedCardDividerThickness.compact:
        return l10n.compact;
      case FeedCardDividerThickness.standard:
        return l10n.standard;
      case FeedCardDividerThickness.comfortable:
        return l10n.comfortable;
      case FeedCardDividerThickness.large:
        return l10n.large;
    }
  }
}
