import 'package:equatable/equatable.dart';

/// A federated instance entry returned from the federated instances API.
class FederatedInstanceEntry extends Equatable {
  /// The instance ID.
  final int id;

  /// The instance domain.
  final String domain;

  /// The software running on the instance, when available.
  final String? software;

  /// The software version, when available.
  final String? version;

  /// The last successful federation publish time, when available.
  final DateTime? lastSuccessfulPublishedTime;

  const FederatedInstanceEntry({
    required this.id,
    required this.domain,
    this.software,
    this.version,
    this.lastSuccessfulPublishedTime,
  });

  factory FederatedInstanceEntry.fromJson(Map<String, dynamic> json) {
    DateTime? lastSuccessfulPublishedTime;
    final federationState = json['federation_state'];
    if (federationState is Map<String, dynamic>) {
      final publishedTime = federationState['last_successful_published_time'];
      if (publishedTime is String) {
        lastSuccessfulPublishedTime = DateTime.tryParse(publishedTime);
      }
    }

    return FederatedInstanceEntry(
      id: json['id'] as int,
      domain: json['domain'] as String,
      software: json['software'] as String?,
      version: json['version'] as String?,
      lastSuccessfulPublishedTime: lastSuccessfulPublishedTime,
    );
  }

  @override
  List<Object?> get props => [id, domain, software, version, lastSuccessfulPublishedTime];
}

/// Represents federated instances returned from the API.
class FederatedInstances extends Equatable {
  /// Instances linked to the current instance.
  final List<FederatedInstanceEntry> linked;

  const FederatedInstances({
    this.linked = const [],
  });

  factory FederatedInstances.fromJson(Map<String, dynamic> json) {
    final federatedInstances = json['federated_instances'];
    if (federatedInstances is! Map<String, dynamic>) {
      return const FederatedInstances();
    }

    final linked = federatedInstances['linked'];
    if (linked is! List) {
      return const FederatedInstances();
    }

    return FederatedInstances(
      linked: linked.whereType<Map<String, dynamic>>().map(FederatedInstanceEntry.fromJson).toList(),
    );
  }

  @override
  List<Object?> get props => [linked];
}
