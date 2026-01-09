part of 'instance_page_bloc.dart';

enum InstancePageStatus { none, loading, success, failure, done }

class InstanceTypeState<T> extends Equatable {
  /// The status of the instance type
  final InstancePageStatus status;

  /// The error message if the instance type failed to load
  final String? message;

  /// The current page of the instance type
  final int page;

  /// The list of items for the instance type
  final List<T> items;

  const InstanceTypeState({
    this.status = InstancePageStatus.none,
    this.message,
    this.page = 1,
    this.items = const [],
  });

  InstanceTypeState<T> copyWith({
    InstancePageStatus? status,
    String? message,
    int? page,
    List<T>? items,
  }) {
    return InstanceTypeState<T>(
      status: status ?? this.status,
      message: message ?? this.message,
      page: page ?? this.page,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [status, message, page, items];
}

class InstancePageState extends Equatable {
  /// The status of the instance page
  final InstancePageStatus status;

  /// The error message if the instance page failed to load
  final String? message;

  /// The communities for the instance page
  final InstanceTypeState<ThunderCommunity> communities;

  /// The posts for the instance page
  final InstanceTypeState<ThunderPost> posts;

  /// The users for the instance page
  final InstanceTypeState<ThunderUser> users;

  /// The comments for the instance page
  final InstanceTypeState<ThunderComment> comments;

  const InstancePageState({
    this.status = InstancePageStatus.success,
    this.message,
    this.communities = const InstanceTypeState(),
    this.posts = const InstanceTypeState(),
    this.users = const InstanceTypeState(),
    this.comments = const InstanceTypeState(),
  });

  InstancePageState copyWith({
    InstancePageStatus? status,
    String? message,
    InstanceTypeState<ThunderCommunity>? communities,
    InstanceTypeState<ThunderPost>? posts,
    InstanceTypeState<ThunderUser>? users,
    InstanceTypeState<ThunderComment>? comments,
  }) {
    return InstancePageState(
      status: status ?? this.status,
      message: message ?? this.message,
      communities: communities ?? this.communities,
      posts: posts ?? this.posts,
      users: users ?? this.users,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<dynamic> get props => [status, message, communities, posts, users, comments];
}
