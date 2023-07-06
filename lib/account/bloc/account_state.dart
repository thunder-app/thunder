part of 'account_bloc.dart';

enum AccountStatus { initial, loading, refreshing, success, empty, failure }

class AccountState extends Equatable {
  const AccountState({
    this.status = AccountStatus.initial,
    this.subsciptions = const [],
    this.personView,
    this.errorMessage,
  });

  final AccountStatus status;
  final String? errorMessage;

  /// The user's subscriptions if logged in
  final List<CommunityView> subsciptions;

  /// The user's information
  final PersonViewSafe? personView;

  AccountState copyWith({
    AccountStatus? status,
    List<CommunityView>? subsciptions,
    PersonViewSafe? personView,
    String? errorMessage,
  }) {
    return AccountState(
      status: status ?? this.status,
      subsciptions: subsciptions ?? this.subsciptions,
      personView: personView ?? this.personView,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, subsciptions, errorMessage];
}
