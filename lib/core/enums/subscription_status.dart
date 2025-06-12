import 'package:lemmy_api_client/v3.dart' as lemmy;

enum SubscriptionStatus {
  subscribed,
  notSubscribed,
  pending,
}

extension SubscriptionStatusMapping on SubscriptionStatus {
  /// Converts a local SubscriptionStatus to lemmy API SubscribedType
  lemmy.SubscribedType toLemmyType() {
    switch (this) {
      case SubscriptionStatus.subscribed:
        return lemmy.SubscribedType.subscribed;
      case SubscriptionStatus.notSubscribed:
        return lemmy.SubscribedType.notSubscribed;
      case SubscriptionStatus.pending:
        return lemmy.SubscribedType.pending;
    }
  }

  /// Converts a lemmy API SubscribedType to local SubscriptionStatus
  static SubscriptionStatus fromLemmyType(lemmy.SubscribedType? lemmyType) {
    switch (lemmyType) {
      case lemmy.SubscribedType.subscribed:
        return SubscriptionStatus.subscribed;
      case lemmy.SubscribedType.pending:
        return SubscriptionStatus.pending;
      case lemmy.SubscribedType.notSubscribed:
      case null:
        return SubscriptionStatus.notSubscribed;
    }
  }
}
