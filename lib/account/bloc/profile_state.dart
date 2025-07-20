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

  final Account account;

  final bool downvotesEnabled;

  final ThunderSiteResponse? siteResponse;

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
    required this.account,
    this.downvotesEnabled = true,
    this.siteResponse,
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
    ValueGetter<ThunderSiteResponse>? siteResponse,
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
      siteResponse: siteResponse != null ? siteResponse() : this.siteResponse,
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
        siteResponse,
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
