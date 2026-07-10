import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/domain/enums/threadiverse_platform.dart';

/// A supported instance identified through NodeInfo discovery.
class InstanceDiscoveryResult extends Equatable {
  const InstanceDiscoveryResult({
    required this.host,
    required this.platform,
    this.version,
  });

  /// Canonical lowercase host without a scheme or trailing path.
  final String host;

  /// Threadiverse platform reported by the instance.
  final ThreadiversePlatform platform;

  /// Platform version reported by NodeInfo, when available.
  final String? version;

  @override
  List<Object?> get props => [host, platform, version];
}
