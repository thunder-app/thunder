part of 'community_bloc.dart';

enum CommunityStatus { initial, fetching, success, failure }

final class CommunityState extends Equatable {
  const CommunityState({
    this.status = CommunityStatus.initial,
    this.communityView,
    this.message,
  });

  /// The status of the community state
  final CommunityStatus status;

  /// The community view
  final CommunityView? communityView;

  /// The message to display on failure
  final String? message;

  CommunityState copyWith({
    CommunityStatus? status,
    CommunityView? communityView,
    String? message,
  }) {
    return CommunityState(
      status: status ?? this.status,
      communityView: communityView ?? this.communityView,
      message: message,
    );
  }

  @override
  String toString() {
    return '''CommunityState { status: $status, message: $message }''';
  }

  @override
  List<dynamic> get props => [status, communityView, message];
}
