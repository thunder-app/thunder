import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityService {
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

class DefaultConnectivityService implements ConnectivityService {
  DefaultConnectivityService({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;
}
