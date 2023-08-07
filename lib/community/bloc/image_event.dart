part of 'image_bloc.dart';

class ImageEvent extends Equatable {
  const ImageEvent();

  @override
  List<Object> get props => [];
}

class ImageUploadEvent extends ImageEvent {
  final String imageFile;
  final String instance;
  final String jwt;
  final bool postImage;

  const ImageUploadEvent({required this.imageFile, required this.instance, required this.jwt, this.postImage = false});
}
