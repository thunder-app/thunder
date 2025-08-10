part of 'network_checker_cubit.dart';

class NetworkCheckerState extends Equatable {
  const NetworkCheckerState({
    this.internetConnectionType,
    this.status = NetworkCheckerStatus.initial,
  });
  final InternetConnectionType? internetConnectionType;
  final NetworkCheckerStatus status;
  @override
  List<dynamic> get props => [internetConnectionType, status];
}

enum NetworkCheckerStatus { initial, loading, success, error }
