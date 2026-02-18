part of 'create_post_cubit.dart';

const _createPostStateUnset = Object();

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
    this.errorReason,
  });

  /// The status of the current cubit
  final CreatePostStatus status;

  /// The result of the created or edited post
  final ThunderPost? post;

  /// The urls of the uploaded images
  final List<String>? imageUrls;

  /// The info or error message to be displayed as a snackbar
  final String? message;

  /// Typed error details used for deterministic tests and failure handling.
  final AppErrorReason? errorReason;

  CreatePostState copyWith({
    required CreatePostStatus status,
    Object? post = _createPostStateUnset,
    Object? imageUrls = _createPostStateUnset,
    Object? message = _createPostStateUnset,
    Object? errorReason = _createPostStateUnset,
  }) {
    return CreatePostState(
      status: status,
      post: identical(post, _createPostStateUnset) ? this.post : post as ThunderPost?,
      imageUrls: identical(imageUrls, _createPostStateUnset) ? this.imageUrls : imageUrls as List<String>?,
      message: identical(message, _createPostStateUnset) ? this.message : message as String?,
      errorReason: identical(errorReason, _createPostStateUnset) ? this.errorReason : errorReason as AppErrorReason?,
    );
  }

  @override
  List<Object?> get props => [status, post, imageUrls, message, errorReason];
}
