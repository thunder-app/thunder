part of 'create_comment_cubit.dart';

enum CreateCommentStatus {
  initial,
  loading,
  submitting,
  error,
  success,
  imageUploadInProgress,
  imageUploadSuccess,
  imageUploadFailure,
  unknown,
}

class CreateCommentState extends Equatable {
  const CreateCommentState({
    this.status = CreateCommentStatus.initial,
    this.commentView,
    this.imageUrl,
    this.message,
  });

  /// The status of the current cubit
  final CreateCommentStatus status;

  /// The result of the created or edited comment
  final CommentView? commentView;

  /// The url of the uploaded image
  final String? imageUrl;

  /// The info or error message to be displayed as a snackbar
  final String? message;

  CreateCommentState copyWith({
    required CreateCommentStatus status,
    CommentView? commentView,
    String? imageUrl,
    String? message,
  }) {
    return CreateCommentState(
      status: status,
      commentView: commentView ?? this.commentView,
      imageUrl: imageUrl ?? this.imageUrl,
      message: message ?? this.message,
    );
  }

  @override
  List<dynamic> get props => [status, commentView, imageUrl, message];
}
