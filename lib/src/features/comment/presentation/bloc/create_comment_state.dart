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
    this.comment,
    this.imageUrls,
    this.message,
  });

  /// The status of the current cubit
  final CreateCommentStatus status;

  /// The result of the created or edited comment
  final ThunderComment? comment;

  /// The urls of the uploaded images
  final List<String>? imageUrls;

  /// The info or error message to be displayed as a snackbar
  final String? message;

  CreateCommentState copyWith({
    required CreateCommentStatus status,
    ThunderComment? comment,
    List<String>? imageUrls,
    String? message,
  }) {
    return CreateCommentState(
      status: status,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      message: message ?? this.message,
    );
  }

  @override
  List<dynamic> get props => [status, comment, imageUrls, message];
}
