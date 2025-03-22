part of 'community_bloc.dart';

enum CommunityStatus { initial, fetching, success, failure }

final class CommunityState extends Equatable {
  const CommunityState({
    this.status = CommunityStatus.initial,
    this.community,
    this.message,
  });

  /// The status of the community state
  final CommunityStatus status;

  /// The community
  final ThunderCommunity? community;

  /// The message to display on failure
  final String? message;

  CommunityState copyWith({
    CommunityStatus? status,
    ThunderCommunity? community,
    String? message,
  }) {
    return CommunityState(
      status: status ?? this.status,
      community: community ?? this.community,
      message: message,
    );
  }

  @override
  String toString() {
    return '''CommunityState { status: $status, community: $community, message: $message }''';
  }

  @override
  List<dynamic> get props => [status, community, message];
}
