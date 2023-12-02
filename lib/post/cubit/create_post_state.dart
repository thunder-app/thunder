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
    this.postViewMedia,
    this.imageUrl,
    this.message,
  });

  /// The status of the current cubit
  final CreatePostStatus status;

  /// The result of the created or edited post
  final PostViewMedia? postViewMedia;

  /// The url of the uploaded image
  final String? imageUrl;

  /// The info or error message to be displayed as a snackbar
  final String? message;

  CreatePostState copyWith({
    required CreatePostStatus status,
    PostViewMedia? postViewMedia,
    String? imageUrl,
    String? message,
  }) {
    return CreatePostState(
      status: status,
      postViewMedia: postViewMedia ?? this.postViewMedia,
      imageUrl: imageUrl ?? this.imageUrl,
      message: message ?? this.message,
    );
  }

  @override
  List<dynamic> get props => [status, postViewMedia, imageUrl, message];
}
