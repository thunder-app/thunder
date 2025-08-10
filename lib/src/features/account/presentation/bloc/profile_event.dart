part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  /// Whether to force a reload of the account information
  final bool reload;

  const ProfileEvent({this.reload = true});

  @override
  List<Object> get props => [reload];
}

/// The [InitializeAuth] event should be triggered whenever the app starts.
/// This is responsible for checking the authentication status of the user on app initialization.
class InitializeAuth extends ProfileEvent {}

/// The [AddProfile] event should be triggered whenever the user attempts to log in for the first time.
/// This event is responsible for login authentication and handling related errors.
class AddProfile extends ProfileEvent {
  final String username;
  final String password;
  final String instance;
  final String totp;
  final bool showContentWarning;

  const AddProfile({required this.username, required this.password, required this.instance, this.totp = "", this.showContentWarning = true});
}

/// Cancels a login attempt by emitting the `failure` state.
class CancelLoginAttempt extends ProfileEvent {
  const CancelLoginAttempt();
}

/// TODO: Consolidate logic to have adding accounts (for both authenticated and anonymous accounts) placed here
class AddAccount extends ProfileEvent {}

/// The [RemoveProfile] event should be triggered whenever the user removes a given account.
/// Currently, this event only handles removing authenticated accounts.
///
/// TODO: Consolidate logic so that anonymous accounts are also handled here.
class RemoveProfile extends ProfileEvent {
  final String accountId;

  const RemoveProfile({required this.accountId});
}

/// TODO: Consolidate logic to have removing accounts (for both authenticated and anonymous accounts) placed here
class RemoveAllAccounts extends ProfileEvent {
  const RemoveAllAccounts();
}

/// The [SwitchProfile] event should be triggered whenever the user switches accounts.
/// Currently, this event only handles switching between authenticated accounts.
///
/// TODO: Consolidate logic so that anonymous accounts are also handled here.
class SwitchProfile extends ProfileEvent {
  final String accountId;
  @override
  final bool reload;

  const SwitchProfile({required this.accountId, this.reload = true});
}

/// The [FetchProfileSettings] event should be triggered whenever the any user Lemmy account setting is updated.
/// This event should handle any logic related to refetching the updated user preferences.
class FetchProfileSettings extends ProfileEvent {}

class ResetAccountState extends ProfileEvent {
  const ResetAccountState();
}

class FetchProfileInformation extends ProfileEvent {
  const FetchProfileInformation({super.reload});
}

/// Fetches the current profile's subscribed communities. This is only applicable for non-anonymous profiles.
class FetchProfileSubscriptions extends ProfileEvent {
  const FetchProfileSubscriptions({super.reload});
}

/// Fetches the current profile's favourited communities. This is only applicable for non-anonymous profiles.
class FetchProfileFavorites extends ProfileEvent {
  const FetchProfileFavorites({super.reload});
}
