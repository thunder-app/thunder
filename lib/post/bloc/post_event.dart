part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class GetPostEvent extends PostEvent {
  final int id;

  const GetPostEvent({required this.id});
}

class GetPostCommentsEvent extends PostEvent {
  final int? postId;
  final bool reset;

  const GetPostCommentsEvent({this.postId, this.reset = false});
}
