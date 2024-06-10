part of 'user_settings_bloc.dart';

abstract class UserSettingsEvent extends Equatable {
  const UserSettingsEvent();

  @override
  List<Object> get props => [];
}

class ResetUserSettingsEvent extends UserSettingsEvent {
  const ResetUserSettingsEvent();
}

class GetUserSettingsEvent extends UserSettingsEvent {
  const GetUserSettingsEvent();
}

class UpdateUserSettingsEvent extends UserSettingsEvent {
  /// The display name associated with the user
  final String? displayName;

  /// The profile bio associated with the user
  final String? bio;

  /// The email associated with the user
  final String? email;

  /// The matrix user id associated with the user
  final String? matrixUserId;

  /// The default listing type for the feed
  final ListingType? defaultListingType;

  /// The default sort type for the feed
  final SortType? defaultSortType;

  /// Whether or not NSFW content should be shown
  final bool? showNsfw;

  /// Whether or not read posts should be shown
  final bool? showReadPosts;

  /// Whether or not post/comment scores should be shown
  final bool? showScores;

  /// Whether the current user is a bot
  final bool? botAccount;

  /// Whether or not bot accounts should be shown
  final bool? showBotAccounts;

  /// The languages associated with the user
  final List<int>? discussionLanguages;

  const UpdateUserSettingsEvent({
    this.displayName,
    this.bio,
    this.email,
    this.matrixUserId,
    this.defaultListingType,
    this.defaultSortType,
    this.showNsfw,
    this.showReadPosts,
    this.showScores,
    this.botAccount,
    this.showBotAccounts,
    this.discussionLanguages,
  });
}

class GetUserBlocksEvent extends UserSettingsEvent {
  const GetUserBlocksEvent();
}

class UnblockInstanceEvent extends UserSettingsEvent {
  final int instanceId;
  final bool unblock;

  const UnblockInstanceEvent({required this.instanceId, this.unblock = true});
}

class UnblockCommunityEvent extends UserSettingsEvent {
  final int communityId;
  final bool unblock;

  const UnblockCommunityEvent({required this.communityId, this.unblock = true});
}

class UnblockPersonEvent extends UserSettingsEvent {
  final int personId;
  final bool unblock;

  const UnblockPersonEvent({required this.personId, this.unblock = true});
}
