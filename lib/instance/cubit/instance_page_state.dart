part of 'instance_page_cubit.dart';

enum InstancePageStatus { none, loading, success, failure, done }

class InstancePageState extends Equatable {
  final InstancePageStatus status;
  final String? errorMessage;
  final int? page;
  final String resolutionInstance;

  final List<CommunityView>? communities;
  final List<PostViewMedia>? posts;
  final List<PersonView>? users;
  final List<CommentView>? comments;

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
    List<CommunityView>? communities,
    List<PostViewMedia>? posts,
    List<PersonView>? users,
    List<CommentView>? comments,
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
  List<dynamic> get props => [
        status,
        errorMessage,
        communities,
        posts,
        users,
        comments,
        page,
        resolutionInstance,
      ];
}
