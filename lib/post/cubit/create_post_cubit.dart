import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit() : super(const CreatePostState(status: CreatePostStatus.initial));
}
