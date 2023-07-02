part of 'account_bloc.dart';

enum AccountStatus { initial, loading, refreshing, success, empty, failure }

class AccountState extends Equatable {
  const AccountState({
    this.status = AccountStatus.initial,
    this.subsciptions = const [],
    this.errorMessage,
  });

  final AccountStatus status;
  final String? errorMessage;

  /// The user's subscriptions if logged in
  final List<CommunityView> subsciptions;

  AccountState copyWith({
    AccountStatus? status,
    List<CommunityView>? subsciptions,
    String? errorMessage,
  }) {
    return AccountState(
      status: status ?? this.status,
      subsciptions: subsciptions ?? this.subsciptions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, subsciptions, errorMessage];
}
