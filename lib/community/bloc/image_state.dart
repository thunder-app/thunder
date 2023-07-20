part of 'image_bloc.dart';

enum ImageStatus { initial, uploading, success, deleting, failure }

class ImageState extends Equatable {
  const ImageState(
      {this.imageUrl = '',
      this.status = ImageStatus.initial,
      this.bodyImage = ''});

  final String? imageUrl;
  final String? bodyImage;
  final ImageStatus status;

  ImageState copyWith({
    String? imageUrl,
    ImageStatus? status,
    String? bodyImage,
  }) {
    return ImageState(
        imageUrl: imageUrl ?? this.imageUrl,
        status: status ?? this.status,
        bodyImage: bodyImage ?? this.bodyImage);
  }

  @override
  List<Object?> get props => [imageUrl, status, bodyImage];
}
