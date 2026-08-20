part of 'instance_page_bloc.dart';

enum InstancePageStatus { none, loading, success, failure, done }

const _instancePageUnset = Object();

class InstanceTypeState<T> extends Equatable {
  /// The status of the instance type
  final InstancePageStatus status;

  /// The error message if the instance type failed to load
  final String? message;

  /// Typed error reason for failure states.
  final AppErrorReason? errorReason;

  /// The current page of the instance type
  final int page;

  /// The list of items for the instance type
  final List<T> items;

  const InstanceTypeState({this.status = InstancePageStatus.none, this.message, this.errorReason, this.page = 1, this.items = const []});

  InstanceTypeState<T> copyWith({InstancePageStatus? status, Object? message = _instancePageUnset, Object? errorReason = _instancePageUnset, int? page, List<T>? items}) {
    return InstanceTypeState<T>(
      status: status ?? this.status,
      message: identical(message, _instancePageUnset) ? this.message : message as String?,
      errorReason: identical(errorReason, _instancePageUnset) ? this.errorReason : errorReason as AppErrorReason?,
      page: page ?? this.page,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [status, message, errorReason, page, items];
}

class InstancePageState extends Equatable {
  /// The status of the instance page
  final InstancePageStatus status;

  /// The error message if the instance page failed to load
  final String? message;

  /// Typed error reason for top-level page failures.
  final AppErrorReason? errorReason;

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
    this.errorReason,
    this.communities = const InstanceTypeState(),
    this.posts = const InstanceTypeState(),
    this.users = const InstanceTypeState(),
    this.comments = const InstanceTypeState(),
  });

  InstancePageState copyWith({
    InstancePageStatus? status,
    Object? message = _instancePageUnset,
    Object? errorReason = _instancePageUnset,
    InstanceTypeState<ThunderCommunity>? communities,
    InstanceTypeState<ThunderPost>? posts,
    InstanceTypeState<ThunderUser>? users,
    InstanceTypeState<ThunderComment>? comments,
  }) {
    return InstancePageState(
      status: status ?? this.status,
      message: identical(message, _instancePageUnset) ? this.message : message as String?,
      errorReason: identical(errorReason, _instancePageUnset) ? this.errorReason : errorReason as AppErrorReason?,
      communities: communities ?? this.communities,
      posts: posts ?? this.posts,
      users: users ?? this.users,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [status, message, errorReason, communities, posts, users, comments];
}
