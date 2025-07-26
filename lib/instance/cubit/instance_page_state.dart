part of 'instance_page_cubit.dart';

enum InstancePageStatus { none, loading, success, failure, done }

class InstancePageState extends Equatable {
  final InstancePageStatus status;
  final String? errorMessage;
  final int? page;
  final String resolutionInstance;

  final List<ThunderCommunity>? communities;
  final List<ThunderPost>? posts;
  final List<ThunderUser>? users;
  final List<ThunderComment>? comments;

  const InstancePageState({
    this.status = InstancePageStatus.none,
    this.errorMessage,
    this.communities,
    this.posts,
    this.users,
    this.comments,
    this.page,
    required this.resolutionInstance,
  });

  InstancePageState copyWith({
    required InstancePageStatus status,
    String? errorMessage,
    List<ThunderCommunity>? communities,
    List<ThunderPost>? posts,
    List<ThunderUser>? users,
    List<ThunderComment>? comments,
    int? page,
  }) {
    return InstancePageState(
      status: status,
      errorMessage: errorMessage,
      communities: communities,
      posts: posts,
      users: users,
      comments: comments,
      page: page,
      resolutionInstance: resolutionInstance,
    );
  }

  @override
  List<dynamic> get props => [status, errorMessage, communities, posts, users, comments, page, resolutionInstance];
}
