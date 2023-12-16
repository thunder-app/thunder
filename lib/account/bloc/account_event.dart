part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class GetAccountInformation extends AccountEvent {}

class GetFavoritedCommunities extends AccountEvent {}
