import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'thunder_event.dart';
part 'thunder_state.dart';

class ThunderBloc extends Bloc<ThunderEvent, ThunderState> {
  ThunderBloc() : super(const ThunderState());
}
