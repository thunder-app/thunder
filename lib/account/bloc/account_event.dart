part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class RefreshAccountInformation extends AccountEvent {}

class GetAccountInformation extends AccountEvent {}

class GetAccountSubscriptions extends AccountEvent {}

class GetFavoritedCommunities extends AccountEvent {}
