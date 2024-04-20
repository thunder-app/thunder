part of 'network_checker_cubit.dart';

sealed class NetworkCheckerState extends Equatable {
  const NetworkCheckerState();

  @override
  List<Object> get props => [];
}

final class NetworkCheckerInitial extends NetworkCheckerState {}
