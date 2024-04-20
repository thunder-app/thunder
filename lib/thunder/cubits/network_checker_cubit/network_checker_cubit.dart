import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'network_checker_state.dart';

class NetworkCheckerCubit extends Cubit<NetworkCheckerState> {
  NetworkCheckerCubit() : super(NetworkCheckerInitial());
}
