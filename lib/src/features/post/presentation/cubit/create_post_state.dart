part of 'create_post_cubit.dart';

enum CreatePostStatus {
  initial,
  loading,
  submitting,
  error,
  success,
  postImageUploadInProgress,
  postImageUploadSuccess,
  postImageUploadFailure,
  imageUploadInProgress,
  imageUploadSuccess,
  imageUploadFailure,
  unknown,
}

class CreatePostState extends Equatable {
  const CreatePostState({
    this.status = CreatePostStatus.initial,
    this.post,
    this.imageUrls,
    this.message,
  });

  /// The status of the current cubit
  final CreatePostStatus status;

  /// The result of the created or edited post
  final ThunderPost? post;

  /// The urls of the uploaded images
  final List<String>? imageUrls;

  /// The info or error message to be displayed as a snackbar
  final String? message;

  CreatePostState copyWith({
    required CreatePostStatus status,
    ThunderPost? post,
    List<String>? imageUrls,
    String? message,
  }) {
    return CreatePostState(
      status: status,
      post: post ?? this.post,
      imageUrls: imageUrls ?? this.imageUrls,
      message: message ?? this.message,
    );
  }

  @override
  List<dynamic> get props => [status, post, imageUrls, message];
}
