part of 'profile_bloc.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  failure,
  failureCheckingInstance,
  contentWarning,
}

class ProfileState extends Equatable {
  final ProfileStatus status;

  final bool isLoggedIn;

  final Account? account;

  final bool downvotesEnabled;

  final GetSiteResponse? getSiteResponse;

  final String? contentWarning;

  /// The current active user's information
  final ThunderUser? user;

  /// The user's subscriptions if logged in
  final List<ThunderCommunity> subscriptions;

  /// The user's favorites if logged in
  final List<ThunderCommunity> favorites;

  /// The user's moderated communities
  final List<ThunderCommunity> moderates;

  /// Whether changes to the account state should force a reload in certain parts of the app
  final bool reload;

  /// The error message if the account failed to load
  final String? error;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.isLoggedIn = false,
    this.account,
    this.downvotesEnabled = true,
    this.getSiteResponse,
    this.contentWarning,
    this.subscriptions = const [],
    this.favorites = const [],
    this.moderates = const [],
    this.user,
    this.error,
    this.reload = true,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    bool? isLoggedIn,
    ValueGetter<Account>? account,
    bool? downvotesEnabled,
    ValueGetter<GetSiteResponse>? getSiteResponse,
    ValueGetter<String>? contentWarning,
    ValueGetter<ThunderUser>? user,
    List<ThunderCommunity>? subscriptions,
    List<ThunderCommunity>? favorites,
    List<ThunderCommunity>? moderates,
    bool? reload,
    ValueGetter<String>? error,
  }) {
    return ProfileState(
      status: status ?? this.status,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      account: account != null ? account() : this.account,
      downvotesEnabled: downvotesEnabled ?? this.downvotesEnabled,
      getSiteResponse: getSiteResponse != null ? getSiteResponse() : this.getSiteResponse,
      contentWarning: contentWarning != null ? contentWarning() : this.contentWarning,
      user: user != null ? user() : this.user,
      subscriptions: subscriptions ?? this.subscriptions,
      favorites: favorites ?? this.favorites,
      moderates: moderates ?? this.moderates,
      reload: reload ?? this.reload,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isLoggedIn,
        account,
        downvotesEnabled,
        getSiteResponse,
        reload,
        status,
        user,
        subscriptions,
        favorites,
        moderates,
        reload,
        error,
      ];
}
