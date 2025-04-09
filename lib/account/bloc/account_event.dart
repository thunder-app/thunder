part of 'account_bloc.dart';

abstract class AccountEvent extends Equatable {
  /// Whether to force a reload of the account information
  final bool reload;

  const AccountEvent({this.reload = true});

  @override
  List<Object> get props => [];
}

class ResetAccountState extends AccountEvent {
  const ResetAccountState();
}

class RefreshAccountInformation extends AccountEvent {
  const RefreshAccountInformation({super.reload});
}

class GetAccountInformation extends AccountEvent {
  const GetAccountInformation({super.reload});
}

class GetAccountSubscriptions extends AccountEvent {
  const GetAccountSubscriptions({super.reload});
}

class GetFavoritedCommunities extends AccountEvent {
  const GetFavoritedCommunities({super.reload});
}
