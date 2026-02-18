part of 'user_settings_bloc.dart';

const _userSettingsUnset = Object();

enum UserSettingsStatus {
  initial,
  updating,
  success,
  blocking,
  successBlock,
  failure,
  revert,
  failedRevert,
  notLoggedIn,
  listingMedia,
  failedListingMedia,
  succeededListingMedia,
  deletingMedia,
  searchingMedia,
  succeededSearchingMedia,
}

class UserSettingsState extends Equatable {
  const UserSettingsState({
    this.status = UserSettingsStatus.initial,
    this.personBlocks = const [],
    this.communityBlocks = const [],
    this.instanceBlocks = const [],
    this.personBeingBlocked = 0,
    this.communityBeingBlocked = 0,
    this.instanceBeingBlocked = 0,
    this.siteResponse,
    this.errorMessage = '',
    this.errorReason,
    this.images,
    this.imageSearchPosts,
    this.imageSearchComments,
  });

  final UserSettingsStatus status;

  final List<ThunderUser> personBlocks;
  final List<ThunderCommunity> communityBlocks;
  final List<Map<String, dynamic>> instanceBlocks;

  final int personBeingBlocked;
  final int communityBeingBlocked;
  final int instanceBeingBlocked;

  final ThunderSiteResponse? siteResponse;

  final String? errorMessage;
  final AppErrorReason? errorReason;
  final List<Map<String, dynamic>>? images;
  final List<ThunderPost>? imageSearchPosts;
  final List<ThunderComment>? imageSearchComments;

  UserSettingsState copyWith({
    UserSettingsStatus? status,
    List<ThunderUser>? personBlocks,
    List<ThunderCommunity>? communityBlocks,
    List<Map<String, dynamic>>? instanceBlocks,
    int? personBeingBlocked,
    int? communityBeingBlocked,
    int? instanceBeingBlocked,
    Object? siteResponse = _userSettingsUnset,
    Object? errorMessage = _userSettingsUnset,
    Object? errorReason = _userSettingsUnset,
    Object? images = _userSettingsUnset,
    Object? imageSearchPosts = _userSettingsUnset,
    Object? imageSearchComments = _userSettingsUnset,
  }) {
    return UserSettingsState(
      status: status ?? this.status,
      personBlocks: personBlocks ?? this.personBlocks,
      communityBlocks: communityBlocks ?? this.communityBlocks,
      instanceBlocks: instanceBlocks ?? this.instanceBlocks,
      personBeingBlocked: personBeingBlocked ?? this.personBeingBlocked,
      communityBeingBlocked: communityBeingBlocked ?? this.communityBeingBlocked,
      instanceBeingBlocked: instanceBeingBlocked ?? this.instanceBeingBlocked,
      siteResponse: identical(siteResponse, _userSettingsUnset) ? this.siteResponse : siteResponse as ThunderSiteResponse?,
      errorMessage: identical(errorMessage, _userSettingsUnset) ? this.errorMessage : errorMessage as String?,
      errorReason: identical(errorReason, _userSettingsUnset) ? this.errorReason : errorReason as AppErrorReason?,
      images: identical(images, _userSettingsUnset) ? this.images : images as List<Map<String, dynamic>>?,
      imageSearchPosts: identical(imageSearchPosts, _userSettingsUnset) ? this.imageSearchPosts : imageSearchPosts as List<ThunderPost>?,
      imageSearchComments: identical(imageSearchComments, _userSettingsUnset) ? this.imageSearchComments : imageSearchComments as List<ThunderComment>?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        personBlocks,
        communityBlocks,
        instanceBlocks,
        personBeingBlocked,
        communityBeingBlocked,
        instanceBeingBlocked,
        siteResponse,
        errorMessage,
        errorReason,
        images,
        imageSearchPosts,
        imageSearchComments,
      ];
}
