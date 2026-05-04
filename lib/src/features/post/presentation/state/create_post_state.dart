part of 'create_post_cubit.dart';

const _createPostStateUnset = Object();

enum CreatePostStatus {
  initial,
  loading,
  submitting,
  error,
  success,
  postImageUploadInProgress,
  postImageUploadSuccess,
  postImageUploadFailure,
  imageUploadInProgress,
  imageUploadSuccess,
  imageUploadFailure,
  unknown,
}

enum CreatePostPiefedMetadataStatus {
  initial,
  unsupported,
  empty,
  loading,
  loaded,
  error,
}

enum CreatePostCrossPostsStatus {
  initial,
  loading,
  loaded,
  error,
}

class CreatePostState extends Equatable {
  const CreatePostState({
    this.status = CreatePostStatus.initial,
    this.post,
    this.imageUrls,
    this.message,
    this.errorReason,
    this.title = '',
    this.body = '',
    this.url = '',
    this.customThumbnail = '',
    this.altText = '',
    this.tags = '',
    this.suggestedLinkTitle,
    this.urlError,
    this.customThumbnailError,
    this.communityId,
    this.community,
    this.languageId,
    this.isNsfw = false,
    this.userChanged = false,
    this.isPiefedComposer = false,
    this.piefedMetadataStatus = CreatePostPiefedMetadataStatus.initial,
    this.availablePiefedFlairs = const <ThunderFlair>[],
    this.selectedPiefedFlairIds = const <int>[],
    this.crossPostsStatus = CreatePostCrossPostsStatus.initial,
    this.crossPosts = const <ThunderPost>[],
    this.restoredDraftNoticeId = 0,
    this.restoredDraftAvailable = false,
  });

  /// The current status of the create post page.
  final CreatePostStatus status;

  /// The post being created or edited.
  final ThunderPost? post;

  /// The urls of the uploaded images.
  final List<String>? imageUrls;

  /// The info or error message to be displayed as a snackbar.
  final String? message;

  /// Contains details about the error that occurred.
  final AppErrorReason? errorReason;

  /// The title of the post.
  final String title;

  /// The body of the post.
  final String body;

  /// The url of the post.
  final String url;

  /// The custom thumbnail of the post.
  final String customThumbnail;

  /// The alternate text of the post.
  final String altText;

  /// The tags of the post.
  final String tags;

  /// A suggested title derived from the current post URL.
  final String? suggestedLinkTitle;

  /// The error reason for the url field.
  final String? urlError;

  /// The error reason for the custom thumbnail field.
  final String? customThumbnailError;

  /// The id of the community the post is being created in.
  final int? communityId;

  /// The community the post is being created in.
  final ThunderCommunity? community;

  /// The id of the language the post is being created in.
  final int? languageId;

  /// Whether the post is NSFW.
  final bool isNsfw;

  /// Whether the user has been switched.
  final bool userChanged;

  /// Whether to show the PieFed specific input fields.
  final bool isPiefedComposer;

  /// The status of the PieFed metadata.
  final CreatePostPiefedMetadataStatus piefedMetadataStatus;

  /// The available PieFed flairs.
  final List<ThunderFlair> availablePiefedFlairs;

  /// The ids of the selected PieFed flairs.
  final List<int> selectedPiefedFlairIds;

  /// The status of the cross posts.
  final CreatePostCrossPostsStatus crossPostsStatus;

  /// The cross posts.
  final List<ThunderPost> crossPosts;

  /// The id of the restored draft notice.
  final int restoredDraftNoticeId;

  /// Whether the restored draft is available.
  final bool restoredDraftAvailable;

  /// Whether the post can be submitted.
  bool get canSubmit => title.trim().isNotEmpty && communityId != null && urlError == null && customThumbnailError == null;

  /// Whether there are selectable PieFed flairs.
  bool get hasSelectablePiefedFlairs => availablePiefedFlairs.isNotEmpty;

  /// The selected PieFed flairs.
  List<ThunderFlair> get selectedPiefedFlairs => availablePiefedFlairs.where((flair) => selectedPiefedFlairIds.contains(flair.id)).toList();

  CreatePostState copyWith({
    Object? status = _createPostStateUnset,
    Object? post = _createPostStateUnset,
    Object? imageUrls = _createPostStateUnset,
    Object? message = _createPostStateUnset,
    Object? errorReason = _createPostStateUnset,
    Object? title = _createPostStateUnset,
    Object? body = _createPostStateUnset,
    Object? url = _createPostStateUnset,
    Object? customThumbnail = _createPostStateUnset,
    Object? altText = _createPostStateUnset,
    Object? tags = _createPostStateUnset,
    Object? suggestedLinkTitle = _createPostStateUnset,
    Object? urlError = _createPostStateUnset,
    Object? customThumbnailError = _createPostStateUnset,
    Object? communityId = _createPostStateUnset,
    Object? community = _createPostStateUnset,
    Object? languageId = _createPostStateUnset,
    Object? isNsfw = _createPostStateUnset,
    Object? userChanged = _createPostStateUnset,
    Object? isPiefedComposer = _createPostStateUnset,
    Object? piefedMetadataStatus = _createPostStateUnset,
    Object? availablePiefedFlairs = _createPostStateUnset,
    Object? selectedPiefedFlairIds = _createPostStateUnset,
    Object? crossPostsStatus = _createPostStateUnset,
    Object? crossPosts = _createPostStateUnset,
    Object? restoredDraftNoticeId = _createPostStateUnset,
    Object? restoredDraftAvailable = _createPostStateUnset,
  }) {
    return CreatePostState(
      status: identical(status, _createPostStateUnset) ? this.status : status as CreatePostStatus,
      post: identical(post, _createPostStateUnset) ? this.post : post as ThunderPost?,
      imageUrls: identical(imageUrls, _createPostStateUnset) ? this.imageUrls : imageUrls as List<String>?,
      message: identical(message, _createPostStateUnset) ? this.message : message as String?,
      errorReason: identical(errorReason, _createPostStateUnset) ? this.errorReason : errorReason as AppErrorReason?,
      title: identical(title, _createPostStateUnset) ? this.title : title as String,
      body: identical(body, _createPostStateUnset) ? this.body : body as String,
      url: identical(url, _createPostStateUnset) ? this.url : url as String,
      customThumbnail: identical(customThumbnail, _createPostStateUnset) ? this.customThumbnail : customThumbnail as String,
      altText: identical(altText, _createPostStateUnset) ? this.altText : altText as String,
      tags: identical(tags, _createPostStateUnset) ? this.tags : tags as String,
      suggestedLinkTitle: identical(suggestedLinkTitle, _createPostStateUnset) ? this.suggestedLinkTitle : suggestedLinkTitle as String?,
      urlError: identical(urlError, _createPostStateUnset) ? this.urlError : urlError as String?,
      customThumbnailError: identical(customThumbnailError, _createPostStateUnset) ? this.customThumbnailError : customThumbnailError as String?,
      communityId: identical(communityId, _createPostStateUnset) ? this.communityId : communityId as int?,
      community: identical(community, _createPostStateUnset) ? this.community : community as ThunderCommunity?,
      languageId: identical(languageId, _createPostStateUnset) ? this.languageId : languageId as int?,
      isNsfw: identical(isNsfw, _createPostStateUnset) ? this.isNsfw : isNsfw as bool,
      userChanged: identical(userChanged, _createPostStateUnset) ? this.userChanged : userChanged as bool,
      isPiefedComposer: identical(isPiefedComposer, _createPostStateUnset) ? this.isPiefedComposer : isPiefedComposer as bool,
      piefedMetadataStatus: identical(piefedMetadataStatus, _createPostStateUnset) ? this.piefedMetadataStatus : piefedMetadataStatus as CreatePostPiefedMetadataStatus,
      availablePiefedFlairs: identical(availablePiefedFlairs, _createPostStateUnset) ? this.availablePiefedFlairs : availablePiefedFlairs as List<ThunderFlair>,
      selectedPiefedFlairIds: identical(selectedPiefedFlairIds, _createPostStateUnset) ? this.selectedPiefedFlairIds : selectedPiefedFlairIds as List<int>,
      crossPostsStatus: identical(crossPostsStatus, _createPostStateUnset) ? this.crossPostsStatus : crossPostsStatus as CreatePostCrossPostsStatus,
      crossPosts: identical(crossPosts, _createPostStateUnset) ? this.crossPosts : crossPosts as List<ThunderPost>,
      restoredDraftNoticeId: identical(restoredDraftNoticeId, _createPostStateUnset) ? this.restoredDraftNoticeId : restoredDraftNoticeId as int,
      restoredDraftAvailable: identical(restoredDraftAvailable, _createPostStateUnset) ? this.restoredDraftAvailable : restoredDraftAvailable as bool,
    );
  }

  @override
  List<Object?> get props => [
        status,
        post,
        imageUrls,
        message,
        errorReason,
        title,
        body,
        url,
        customThumbnail,
        altText,
        tags,
        suggestedLinkTitle,
        urlError,
        customThumbnailError,
        communityId,
        community,
        languageId,
        isNsfw,
        userChanged,
        isPiefedComposer,
        piefedMetadataStatus,
        availablePiefedFlairs,
        selectedPiefedFlairIds,
        crossPostsStatus,
        crossPosts,
        restoredDraftNoticeId,
        restoredDraftAvailable,
      ];
}
