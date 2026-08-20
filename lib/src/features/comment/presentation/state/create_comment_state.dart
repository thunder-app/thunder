part of 'create_comment_cubit.dart';

const _createCommentStateUnset = Object();

enum CreateCommentStatus { initial, loading, submitting, error, success, imageUploadInProgress, imageUploadSuccess, imageUploadFailure, unknown }

class CreateCommentState extends Equatable {
  const CreateCommentState({this.status = CreateCommentStatus.initial, this.comment, this.imageUrls, this.message, this.errorReason});

  /// The status of the current cubit
  final CreateCommentStatus status;

  /// The result of the created or edited comment
  final ThunderComment? comment;

  /// The urls of the uploaded images
  final List<String>? imageUrls;

  /// The info or error message to be displayed as a snackbar
  final String? message;

  /// Typed error details for deterministic failure handling.
  final AppErrorReason? errorReason;

  CreateCommentState copyWith({
    required CreateCommentStatus status,
    Object? comment = _createCommentStateUnset,
    Object? imageUrls = _createCommentStateUnset,
    Object? message = _createCommentStateUnset,
    Object? errorReason = _createCommentStateUnset,
  }) {
    return CreateCommentState(
      status: status,
      comment: identical(comment, _createCommentStateUnset) ? this.comment : comment as ThunderComment?,
      imageUrls: identical(imageUrls, _createCommentStateUnset) ? this.imageUrls : imageUrls as List<String>?,
      message: identical(message, _createCommentStateUnset) ? this.message : message as String?,
      errorReason: identical(errorReason, _createCommentStateUnset) ? this.errorReason : errorReason as AppErrorReason?,
    );
  }

  @override
  List<Object?> get props => [status, comment, imageUrls, message, errorReason];
}
