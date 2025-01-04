part of 'auth_bloc.dart';

/// The [AuthBloc] handles the overall state for authentication with a given instance and account.
///
/// The [AuthBloc] should be responsible for:
/// - Checking authentication status within the Thunder
/// - Logging in and out of accounts
/// - Changes to the current active instance.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// The [CheckAuth] event should be triggered whenever the app starts.
/// This is responsible for checking the authentication status of the user on app initialization.
class CheckAuth extends AuthEvent {}

/// The [LoginAttempt] event should be triggered whenever the user attempts to log in for the first time.
/// This event is responsible for login authentication and handling related errors.
class LoginAttempt extends AuthEvent {
  final String username;
  final String password;
  final String instance;
  final String totp;
  final bool showContentWarning;

  const LoginAttempt({required this.username, required this.password, required this.instance, this.totp = "", this.showContentWarning = true});
}

/// The [OAuthLoginAttemptPart1] event should be triggered whenever the user attempts to log in with OAuth.
/// This event is responsible for login authentication and handling related errors.
class OAuthLoginAttemptPart1 extends AuthEvent {
  final String instance;
  final ProviderView provider;
  final bool showContentWarning;

  const OAuthLoginAttemptPart1({required this.instance, required this.provider, this.showContentWarning = true});
}

/// The [OAuthLoginAttemptPart2] event should be triggered whenever the user attempts to log in with OAuth.
/// This event is responsible for login authentication and handling related errors.
class OAuthLoginAttemptPart2 extends AuthEvent {
  final String link;
  final bool showContentWarning;

  const OAuthLoginAttemptPart2({required this.link, this.showContentWarning = true});
}

/// Cancels a login attempt by emitting the `failure` state.
class CancelLoginAttempt extends AuthEvent {
  const CancelLoginAttempt();
}

/// Cancels a login attempt by emitting the `failure` state.
class ShowContentWarning extends AuthEvent {
  const ShowContentWarning();
}

/// TODO: Consolidate logic to have adding accounts (for both authenticated and anonymous accounts) placed here
class AddAccount extends AuthEvent {}

/// The [RemoveAccount] event should be triggered whenever the user removes a given account.
/// Currently, this event only handles removing authenticated accounts.
///
/// TODO: Consolidate logic so that anonymous accounts are also handled here.
class RemoveAccount extends AuthEvent {
  final String accountId;

  const RemoveAccount({required this.accountId});
}

/// TODO: Consolidate logic to have removing accounts (for both authenticated and anonymous accounts) placed here
class RemoveAllAccounts extends AuthEvent {
  const RemoveAllAccounts();
}

/// The [SwitchAccount] event should be triggered whenever the user switches accounts.
/// Currently, this event only handles switching between authenticated accounts.
///
/// TODO: Consolidate logic so that anonymous accounts are also handled here.
class SwitchAccount extends AuthEvent {
  final String accountId;
  final bool reload;

  const SwitchAccount({required this.accountId, this.reload = true});
}

/// The [LogOutOfAllAccounts] event should be triggered whenever we want to clear the current logged in.
///
/// This event only clears the current logged in account. It does NOT remove any accounts. To remove an account, use the [RemoveAccount] event.
class LogOutOfAllAccounts extends AuthEvent {
  const LogOutOfAllAccounts();
}

/// The [InstanceChanged] event should be triggered whenever the user changes the instance.
/// This event should handle any logic related to switching instances including fetching instance information and preferences.
class InstanceChanged extends AuthEvent {
  final String instance;

  const InstanceChanged({required this.instance});
}

/// The [LemmyAccountSettingUpdated] event should be triggered whenever the any user Lemmy account setting is updated.
/// This event should handle any logic related to refetching the updated user preferences.
class LemmyAccountSettingUpdated extends AuthEvent {}
