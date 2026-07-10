import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/core/domain/domain.dart';

part 'network_checker_state.dart';

class NetworkCheckerCubit extends Cubit<NetworkCheckerState> {
  NetworkCheckerCubit({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService,
        super(const NetworkCheckerState());

  final ConnectivityService _connectivityService;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Future<void> getConnectionType() async {
    emit(const NetworkCheckerState(status: NetworkCheckerStatus.loading));
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivityService.onConnectivityChanged.listen((List<ConnectivityResult> result) {
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
          break;
        default:
          emit(const NetworkCheckerState(
            status: NetworkCheckerStatus.error,
          ));
      }
    });
  }

  @override
  Future<void> close() async {
    await _connectivitySubscription?.cancel();
    await super.close();
  }
}
