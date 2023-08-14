import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/pictrs.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
part 'image_state.dart';
part 'image_event.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  ImageBloc() : super(const ImageState()) {
    on<ImageUploadEvent>(
      _uploadImageToServer,
      transformer: throttleDroppable(throttleDuration),
    );
  }
  Future<void> _uploadImageToServer(ImageUploadEvent event, Emitter<ImageState> emit) async {
    PictrsApi pictrs = PictrsApi(event.instance);
    emit(state.copyWith(status: ImageStatus.uploading));
    try {
      PictrsUpload result = await pictrs.upload(filePath: event.imageFile, auth: event.jwt);
      String url = "https://${event.instance}/pictrs/image/${result.files[0].file}";
      if (event.postImage) {
        emit(state.copyWith(
          status: ImageStatus.successPostImage,
          imageUrl: url,
        ));
      } else {
        emit(state.copyWith(status: ImageStatus.success, imageUrl: url));
      }
    } catch (e) {
      emit(state.copyWith(status: ImageStatus.failure));
    }
  }
}
