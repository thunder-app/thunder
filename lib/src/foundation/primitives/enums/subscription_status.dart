import 'package:thunder/src/foundation/primitives/enums/threadiverse_platform.dart';

enum SubscriptionStatus {
  subscribed('Subscribed'),
  notSubscribed('NotSubscribed'),
  pending('Pending');

  /// The name of the subscription status.
  final String name;

  /// The platform this subscription status is used on. If null, it is used on all platforms.
  final ThreadiversePlatform? platform;

  // ignore: unused_element_parameter
  const SubscriptionStatus(this.name, {this.platform});
}
