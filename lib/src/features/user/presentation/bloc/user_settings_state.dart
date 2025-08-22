part of 'user_settings_bloc.dart';

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
  final List<Map<String, dynamic>>? images;
  final List<ThunderPost>? imageSearchPosts;
  final List<ThunderComment>? imageSearchComments;

  UserSettingsState copyWith({
    required UserSettingsStatus status,
    List<ThunderUser>? personBlocks,
    List<ThunderCommunity>? communityBlocks,
    List<Map<String, dynamic>>? instanceBlocks,
    int? personBeingBlocked,
    int? communityBeingBlocked,
    int? instanceBeingBlocked,
    ThunderSiteResponse? siteResponse,
    String? errorMessage,
    List<Map<String, dynamic>>? images,
    List<ThunderPost>? imageSearchPosts,
    List<ThunderComment>? imageSearchComments,
  }) {
    return UserSettingsState(
      status: status,
      personBlocks: personBlocks ?? this.personBlocks,
      communityBlocks: communityBlocks ?? this.communityBlocks,
      instanceBlocks: instanceBlocks ?? this.instanceBlocks,
      personBeingBlocked: personBeingBlocked ?? this.personBeingBlocked,
      communityBeingBlocked: communityBeingBlocked ?? this.communityBeingBlocked,
      instanceBeingBlocked: instanceBeingBlocked ?? this.instanceBeingBlocked,
      siteResponse: siteResponse ?? this.siteResponse,
      errorMessage: errorMessage ?? this.errorMessage,
      images: images ?? this.images,
      imageSearchPosts: imageSearchPosts ?? this.imageSearchPosts,
      imageSearchComments: imageSearchComments ?? this.imageSearchComments,
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
        images,
      ];
}
