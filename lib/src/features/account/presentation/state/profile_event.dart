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

/// Cancels a login attempt by emitting the `failure` state.
class CancelLoginAttempt extends ProfileEvent {
  const CancelLoginAttempt();
}

/// The [FetchProfileSettings] event should be triggered whenever the any user Lemmy account setting is updated.
/// This event should handle any logic related to refetching the updated user preferences.
class FetchProfileSettings extends ProfileEvent {}

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
