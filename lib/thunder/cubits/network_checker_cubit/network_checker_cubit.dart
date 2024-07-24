import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:thunder/core/enums/internet_connection_type.dart';

part 'network_checker_state.dart';

class NetworkCheckerCubit extends Cubit<NetworkCheckerState> {
  NetworkCheckerCubit() : super(const NetworkCheckerState());

  Future<void> getConnectionType() async {
    emit(const NetworkCheckerState(status: NetworkCheckerStatus.loading));
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      // Received changes in available connectivity types!
      switch (result) {
        case [ConnectivityResult.wifi]:
          emit(const NetworkCheckerState(
            status: NetworkCheckerStatus.success,
            internetConnectionType: InternetConnectionType.wifi,
          ));
          break;
        case [ConnectivityResult.mobile]:
          emit(const NetworkCheckerState(
            status: NetworkCheckerStatus.success,
            internetConnectionType: InternetConnectionType.mobile,
          ));
          break;
        case [ConnectivityResult.other]:
          emit(const NetworkCheckerState(
            status: NetworkCheckerStatus.success,
            internetConnectionType: InternetConnectionType.unknown,
          ));
        default:
      }
    });
  }
}
