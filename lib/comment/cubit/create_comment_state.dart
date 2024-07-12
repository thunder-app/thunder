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
    this.imageUrls,
    this.message,
  });

  /// The status of the current cubit
  final CreateCommentStatus status;

  /// The result of the created or edited comment
  final CommentView? commentView;

  /// The urls of the uploaded images
  final List<String>? imageUrls;

  /// The info or error message to be displayed as a snackbar
  final String? message;

  CreateCommentState copyWith({
    required CreateCommentStatus status,
    CommentView? commentView,
    List<String>? imageUrls,
    String? message,
  }) {
    return CreateCommentState(
      status: status,
      commentView: commentView ?? this.commentView,
      imageUrls: imageUrls ?? this.imageUrls,
      message: message ?? this.message,
    );
  }

  @override
  List<dynamic> get props => [status, commentView, imageUrls, message];
}
