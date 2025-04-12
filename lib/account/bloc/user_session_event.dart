part of 'user_session_bloc.dart';

abstract class UserSessionEvent extends Equatable {
  /// Whether to force a reload of the account information
  final bool reload;

  const UserSessionEvent({this.reload = true});

  @override
  List<Object> get props => [reload];
}

/// The [CheckAuth] event should be triggered whenever the app starts.
/// This is responsible for checking the authentication status of the user on app initialization.
class CheckAuth extends UserSessionEvent {}

/// The [LoginAttempt] event should be triggered whenever the user attempts to log in for the first time.
/// This event is responsible for login authentication and handling related errors.
class LoginAttempt extends UserSessionEvent {
  final String username;
  final String password;
  final String instance;
  final String totp;
  final bool showContentWarning;

  const LoginAttempt({required this.username, required this.password, required this.instance, this.totp = "", this.showContentWarning = true});
}

/// Cancels a login attempt by emitting the `failure` state.
class CancelLoginAttempt extends UserSessionEvent {
  const CancelLoginAttempt();
}

/// TODO: Consolidate logic to have adding accounts (for both authenticated and anonymous accounts) placed here
class AddAccount extends UserSessionEvent {}

/// The [RemoveAccount] event should be triggered whenever the user removes a given account.
/// Currently, this event only handles removing authenticated accounts.
///
/// TODO: Consolidate logic so that anonymous accounts are also handled here.
class RemoveAccount extends UserSessionEvent {
  final String accountId;

  const RemoveAccount({required this.accountId});
}

/// TODO: Consolidate logic to have removing accounts (for both authenticated and anonymous accounts) placed here
class RemoveAllAccounts extends UserSessionEvent {
  const RemoveAllAccounts();
}

/// The [SwitchAccount] event should be triggered whenever the user switches accounts.
/// Currently, this event only handles switching between authenticated accounts.
///
/// TODO: Consolidate logic so that anonymous accounts are also handled here.
class SwitchAccount extends UserSessionEvent {
  final String accountId;
  @override
  final bool reload;

  const SwitchAccount({required this.accountId, this.reload = true});
}

/// The [LogOutOfAllAccounts] event should be triggered whenever we want to clear the current logged in.
///
/// This event only clears the current logged in account. It does NOT remove any accounts. To remove an account, use the [RemoveAccount] event.
class LogOutOfAllAccounts extends UserSessionEvent {
  const LogOutOfAllAccounts();
}

/// The [InstanceChanged] event should be triggered whenever the user changes the instance.
/// This event should handle any logic related to switching instances including fetching instance information and preferences.
class InstanceChanged extends UserSessionEvent {
  final String instance;

  const InstanceChanged({required this.instance});
}

/// The [LemmyAccountSettingUpdated] event should be triggered whenever the any user Lemmy account setting is updated.
/// This event should handle any logic related to refetching the updated user preferences.
class LemmyAccountSettingUpdated extends UserSessionEvent {}

class ResetAccountState extends UserSessionEvent {
  const ResetAccountState();
}

class RefreshAccountInformation extends UserSessionEvent {
  const RefreshAccountInformation({super.reload});
}

class GetAccountInformation extends UserSessionEvent {
  const GetAccountInformation({super.reload});
}

class GetAccountSubscriptions extends UserSessionEvent {
  const GetAccountSubscriptions({super.reload});
}

class GetFavoritedCommunities extends UserSessionEvent {
  const GetFavoritedCommunities({super.reload});
}
