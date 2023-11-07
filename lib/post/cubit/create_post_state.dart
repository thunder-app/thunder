part of 'create_post_cubit.dart';

enum CreatePostStatus { initial, loading, error, success, unknown }

class CreatePostState extends Equatable {
  const CreatePostState({
    this.status = CreatePostStatus.initial,
    this.message,
  });

  /// The status of the current cubit
  final CreatePostStatus status;

  /// The info or error message to be displayed as a snackbar
  final String? message;

  CreatePostState copyWith({
    required CreatePostStatus status,
    String? message,
  }) {
    return CreatePostState(
      status: status,
      message: message ?? this.message,
    );
  }

  @override
  List<dynamic> get props => [status, message];
}
