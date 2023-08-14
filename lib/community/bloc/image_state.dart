part of 'image_bloc.dart';

enum ImageStatus { initial, uploading, success, successPostImage, failure }

class ImageState extends Equatable {
  const ImageState({
    this.imageUrl = '',
    this.status = ImageStatus.initial,
  });

  final String imageUrl;
  final ImageStatus status;

  ImageState copyWith({
    String? imageUrl,
    ImageStatus? status,
  }) {
    return ImageState(
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        imageUrl,
        status,
      ];
}
