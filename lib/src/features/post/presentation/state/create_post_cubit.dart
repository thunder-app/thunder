import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/drafts/drafts.dart';
import 'package:thunder/src/features/post/data/repositories/post_repository.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

part 'create_post_state.dart';

/// Cubit for the create / edit post page (fields, drafts, uploads, submit).
class CreatePostCubit extends Cubit<CreatePostState> {
  /// The current account.
  Account account;

  /// The repository for posts.
  late PostRepository repository;

  /// Repositories for the create post cubit.
  final PostRepository Function(Account) _postRepository;
  final AccountRepository Function(Account) _accountRepository;
  final CommunityRepository Function(Account) _communityRepository;
  final SearchRepository Function(Account) _searchRepository;
  final DraftRepository _draftRepository;
  final LocalizationService _localizationService;
  final String _initialAccountId;

  CreatePostCubit({
    required this.account,
    required PostRepository Function(Account) postRepository,
    required AccountRepository Function(Account) accountRepository,
    required CommunityRepository Function(Account) communityRepository,
    required SearchRepository Function(Account) searchRepository,
    required DraftRepository draftRepository,
    required LocalizationService localizationService,
  })  : _postRepository = postRepository,
        _accountRepository = accountRepository,
        _communityRepository = communityRepository,
        _searchRepository = searchRepository,
        _draftRepository = draftRepository,
        _localizationService = localizationService,
        _initialAccountId = account.id,
        super(const CreatePostState()) {
    repository = _postRepository(account);
  }

  Timer? _draftDebounceTimer;
  Timer? _crossPostsDebounceTimer;

  ThunderPost? _editingPost;
  late CreatePostState _initialState;
  int _piefedMetadataRequestId = 0;
  int _crossPostsRequestId = 0;
  bool _saveDraft = true;

  /// Loads initial route arguments, optionally restores a draft, and refreshes metadata.
  Future<void> initialize({
    required int? communityId,
    ThunderCommunity? community,
    ThunderPost? post,
    bool prePopulated = false,
    String? title,
    String? text,
    String? url,
    String? customThumbnail,
    String? altText,
    bool isCrossPost = false,
  }) async {
    _editingPost = post;
    _saveDraft = true;

    final resolvedCommunity = community ?? post?.community;
    final resolvedCommunityId = communityId ?? resolvedCommunity?.id ?? post?.communityId;
    final shouldSeedBodyFromPrepopulatedText = prePopulated && !(url != null && text?.isNotEmpty == true && isCrossPost);

    final initialState = _validateState(
      state.copyWith(
        status: CreatePostStatus.initial,
        post: null,
        imageUrls: null,
        message: null,
        errorReason: null,
        title: post?.name ?? (prePopulated ? title ?? '' : ''),
        body: post?.body ?? (shouldSeedBodyFromPrepopulatedText ? text ?? '' : ''),
        url: post?.url ?? (prePopulated ? url ?? '' : ''),
        customThumbnail: post?.thumbnailUrl ?? (prePopulated ? customThumbnail ?? '' : ''),
        altText: post?.altText ?? (prePopulated ? altText ?? '' : ''),
        tags: post != null ? encodePiefedTags(post.tags) : '',
        communityId: resolvedCommunityId,
        community: resolvedCommunity,
        languageId: post?.languageId,
        isNsfw: post?.nsfw ?? false,
        userChanged: account.id != _initialAccountId,
        isPiefedComposer: account.platform == ThreadiversePlatform.piefed,
        piefedMetadataStatus: _initialPiefedStatusFor(post),
        availablePiefedFlairs: post?.flairs ?? const <ThunderFlair>[],
        selectedPiefedFlairIds: normalizePiefedFlairIds(post?.flairs.map((flair) => flair.id)),
        crossPostsStatus: CreatePostCrossPostsStatus.initial,
        crossPosts: const <ThunderPost>[],
        restoredDraftAvailable: false,
      ),
    );

    _initialState = initialState;
    emit(initialState);

    if (!prePopulated) {
      await _restoreExistingDraft();
    }

    await _refreshPiefedMetadata();
    _scheduleCrossPostsLookup(state.url, immediate: state.url.isNotEmpty);
  }

  Future<void> clearMessage() async {
    emit(state.copyWith(
      status: CreatePostStatus.initial,
      message: null,
      errorReason: null,
    ));
  }

  Future<void> switchAccount(Account newAccount) async {
    account = newAccount;
    repository = _postRepository(account);

    debugPrint('Account switched to ${account.username}@${account.instance}');
    emit(_validateState(state.copyWith(
      status: CreatePostStatus.initial,
      message: null,
      errorReason: null,
      isPiefedComposer: account.platform == ThreadiversePlatform.piefed,
      userChanged: account.id != _initialAccountId,
      piefedMetadataStatus: _piefedResetStatus,
      availablePiefedFlairs: const <ThunderFlair>[],
      selectedPiefedFlairIds: const <int>[],
    )));

    _scheduleDraftPersistence();
    await _refreshPiefedMetadata();
  }

  void updateTitle(String value) {
    if (value == state.title) return;

    emit(_validateState(state.copyWith(title: value)));
    _scheduleDraftPersistence();
  }

  void updateBody(String value) {
    if (value == state.body) return;

    emit(state.copyWith(body: value));
    _scheduleDraftPersistence();
  }

  void updateUrl(String value) {
    if (value == state.url) return;

    emit(_validateState(state.copyWith(
      url: value,
      crossPosts: value.isEmpty ? const <ThunderPost>[] : state.crossPosts,
      crossPostsStatus: value.isEmpty ? CreatePostCrossPostsStatus.initial : CreatePostCrossPostsStatus.loading,
    )));

    _scheduleCrossPostsLookup(value);
    _scheduleDraftPersistence();
  }

  void updateCustomThumbnail(String value) {
    if (value == state.customThumbnail) return;

    emit(_validateState(state.copyWith(customThumbnail: value)));
    _scheduleDraftPersistence();
  }

  void updateAltText(String value) {
    if (value == state.altText) return;

    emit(state.copyWith(altText: value));
    _scheduleDraftPersistence();
  }

  void updateTags(String value) {
    if (value == state.tags) return;

    emit(state.copyWith(tags: value));
    _scheduleDraftPersistence();
  }

  Future<void> updateCommunity(ThunderCommunity? community) async {
    final nextCommunityId = community?.id;
    final hasContextChanged = state.communityId != nextCommunityId || state.community != community;

    if (!hasContextChanged) return;

    emit(_validateState(state.copyWith(
      communityId: nextCommunityId,
      community: community,
      piefedMetadataStatus: _piefedResetStatus,
      availablePiefedFlairs: const <ThunderFlair>[],
      selectedPiefedFlairIds: const <int>[],
    )));

    _scheduleDraftPersistence();
    await _refreshPiefedMetadata();
  }

  void updateLanguage(int? languageId) {
    if (languageId == state.languageId) return;

    emit(state.copyWith(languageId: languageId));
    _scheduleDraftPersistence();
  }

  void updateNsfw(bool value) {
    if (value == state.isNsfw) return;

    emit(state.copyWith(isNsfw: value));
    _scheduleDraftPersistence();
  }

  void updateFlairs(List<int> flairIds) {
    final normalized = normalizePiefedFlairIds(flairIds);
    if (listEquals(normalized, state.selectedPiefedFlairIds)) return;

    emit(state.copyWith(selectedPiefedFlairIds: normalized));
    _scheduleDraftPersistence();
  }

  /// Persists the current composer fields when the app goes to background.
  Future<DraftPersistenceResult> handleAppLifecyclePause() {
    return persistDraftNow();
  }

  /// Writes the active post draft immediately (cancels debounced save).
  Future<DraftPersistenceResult> persistDraftNow() async {
    _draftDebounceTimer?.cancel();

    final draft = _buildDraft();
    return persistDraft(
      repository: _draftRepository,
      context: _draftContext,
      draft: draft,
      save: _saveDraft,
      differsFromEdit: postDraftDiffersFromEdit(draft, _editingPost),
      hasContent: draft.isPostNotEmpty,
    );
  }

  Future<void> clearActiveDraft() async {
    await _draftRepository.clearActiveDraftByIdentity(_draftContext.draftType, _draftContext.existingId, _draftContext.replyId);
  }

  Future<void> discardRestoredDraft() async {
    await _draftRepository.deleteDraft(_draftContext.draftType, _draftContext.existingId, _draftContext.replyId);

    final resetState = _validateState(
      _initialState.copyWith(
        status: CreatePostStatus.initial,
        restoredDraftAvailable: false,
      ),
    );

    emit(resetState);
    await _refreshPiefedMetadata();
    _scheduleCrossPostsLookup(resetState.url, immediate: resetState.url.isNotEmpty);
  }

  Future<void> uploadImages(List<String> imageFiles, {bool isPostImage = false}) async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) {
      emit(state.copyWith(
        status: isPostImage ? CreatePostStatus.postImageUploadFailure : CreatePostStatus.imageUploadFailure,
        message: l10n.userNotLoggedIn,
        errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
      ));
      return;
    }

    List<String> urls = [];

    emit(state.copyWith(
      status: isPostImage ? CreatePostStatus.postImageUploadInProgress : CreatePostStatus.imageUploadInProgress,
      message: null,
      errorReason: null,
    ));

    try {
      final accountRepository = _accountRepository(account);

      for (String imageFile in imageFiles) {
        final url = await accountRepository.uploadImage(imageFile);
        urls.add(url);

        // Add a delay between each upload to avoid possible rate limiting
        await Future.wait(urls.map((url) => Future.delayed(const Duration(milliseconds: 500))));
      }

      final successStatus = isPostImage ? CreatePostStatus.postImageUploadSuccess : CreatePostStatus.imageUploadSuccess;
      final nextState = _validateState(state.copyWith(
        status: successStatus,
        imageUrls: urls,
        message: null,
        errorReason: null,
        url: isPostImage && urls.isNotEmpty ? urls.first : state.url,
      ));

      emit(nextState);

      if (isPostImage && urls.isNotEmpty) {
        _scheduleCrossPostsLookup(urls.first, immediate: true);
        _scheduleDraftPersistence();
      }
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: isPostImage ? CreatePostStatus.postImageUploadFailure : CreatePostStatus.imageUploadFailure,
        message: message,
        errorReason: AppErrorReason.actionFailed(message: message),
      ));
    }
  }

  /// Creates a new post or edits an existing one. On success, emits the [ThunderPost] and returns its id.
  Future<int?> submitPost() async {
    _saveDraft = false;

    try {
      emit(state.copyWith(
        status: CreatePostStatus.submitting,
        message: null,
        errorReason: null,
      ));

      final post = await repository.create(
        communityId: state.communityId!,
        name: state.title,
        body: state.body,
        url: state.url,
        customThumbnail: state.customThumbnail,
        altText: state.altText,
        tags: _submissionTags(),
        flairIds: _submissionFlairIds(),
        nsfw: state.isNsfw,
        postIdBeingEdited: _editingPost?.id,
        languageId: state.languageId,
      );

      emit(state.copyWith(
        status: CreatePostStatus.success,
        post: post,
        message: null,
        errorReason: null,
      ));

      return post.id;
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: CreatePostStatus.error,
        message: message,
        errorReason: AppErrorReason.actionFailed(message: message),
      ));
    }

    return null;
  }

  @override
  Future<void> close() async {
    _draftDebounceTimer?.cancel();
    _crossPostsDebounceTimer?.cancel();
    await super.close();
  }

  CreatePostState _validateState(CreatePostState source) {
    final l10n = _localizationService.l10n;

    return source.copyWith(
      urlError: _validateOptionalUrl(source.url, l10n.notValidUrl),
      customThumbnailError: _validateOptionalUrl(source.customThumbnail, l10n.notValidUrl),
    );
  }

  String? _validateOptionalUrl(String value, String invalidMessage) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmedValue);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return invalidMessage;
    }

    return null;
  }

  Future<void> _restoreExistingDraft() async {
    final draft = await restoreDraft(
      repository: _draftRepository,
      context: _draftContext,
    );

    if (draft == null) {
      return;
    }

    final restoredState = _validateState(
      state.copyWith(
        title: draft.title ?? '',
        url: draft.url ?? '',
        customThumbnail: draft.customThumbnail ?? '',
        altText: draft.altText ?? '',
        body: draft.body ?? '',
        isNsfw: draft.nsfw,
        languageId: draft.languageId,
        restoredDraftAvailable: draft.isPostNotEmpty && postDraftDiffersFromEdit(draft, _editingPost),
        restoredDraftNoticeId: draft.isPostNotEmpty && postDraftDiffersFromEdit(draft, _editingPost) ? state.restoredDraftNoticeId + 1 : state.restoredDraftNoticeId,
      ),
    );

    emit(restoredState);
  }

  DraftContext get _draftContext => resolvePostDraftContext(
        editingPostId: _editingPost?.id,
        communityId: state.communityId,
      );

  Draft _buildDraft() => buildPostDraft(
        context: _draftContext,
        title: state.title,
        url: state.url,
        customThumbnail: state.customThumbnail,
        altText: state.altText,
        nsfw: state.isNsfw,
        languageId: state.languageId,
        body: state.body,
      );

  void _scheduleDraftPersistence() {
    _draftDebounceTimer?.cancel();
    _draftDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      unawaited(persistDraftNow());
    });
  }

  void _scheduleCrossPostsLookup(String url, {bool immediate = false}) {
    _crossPostsDebounceTimer?.cancel();

    if (url.isEmpty) {
      emit(state.copyWith(
        crossPosts: const <ThunderPost>[],
        crossPostsStatus: CreatePostCrossPostsStatus.initial,
      ));
      return;
    }

    if (immediate) {
      unawaited(_refreshCrossPosts(url));
      return;
    }

    _crossPostsDebounceTimer = Timer(const Duration(milliseconds: 1000), () {
      unawaited(_refreshCrossPosts(url));
    });
  }

  Future<void> _refreshCrossPosts(String url) async {
    final requestId = ++_crossPostsRequestId;

    emit(state.copyWith(
      crossPostsStatus: CreatePostCrossPostsStatus.loading,
      crossPosts: const <ThunderPost>[],
    ));

    try {
      final SearchResults response = await _searchRepository(account).search(
        query: url,
        type: MetaSearchType.url,
        sort: SearchSortType.topAll,
        listingType: FeedListType.all,
        limit: 20,
      );

      if (requestId != _crossPostsRequestId || state.url != url) {
        return;
      }

      emit(state.copyWith(
        crossPostsStatus: CreatePostCrossPostsStatus.loaded,
        crossPosts: response.posts,
      ));
    } catch (_) {
      if (requestId != _crossPostsRequestId || state.url != url) {
        return;
      }

      emit(state.copyWith(
        crossPostsStatus: CreatePostCrossPostsStatus.error,
        crossPosts: const <ThunderPost>[],
      ));
    }
  }

  Future<void> _refreshPiefedMetadata() async {
    if (account.platform != ThreadiversePlatform.piefed || state.communityId == null) {
      emit(state.copyWith(
        piefedMetadataStatus: _piefedResetStatus,
        availablePiefedFlairs: const <ThunderFlair>[],
        selectedPiefedFlairIds: const <int>[],
      ));
      return;
    }

    final requestId = ++_piefedMetadataRequestId;

    emit(state.copyWith(piefedMetadataStatus: CreatePostPiefedMetadataStatus.loading));

    try {
      final CommunityDetails details = await _communityRepository(account).getCommunity(id: state.communityId);

      if (requestId != _piefedMetadataRequestId || state.communityId != details.community.id) {
        return;
      }

      emit(_validateState(state.copyWith(
        community: details.community,
        availablePiefedFlairs: details.flairs,
        selectedPiefedFlairIds: retainValidPiefedFlairSelection(
          selectedFlairIds: state.selectedPiefedFlairIds,
          availableFlairIds: details.flairs.map((flair) => flair.id),
          clearWhenUnavailable: true,
        ),
        piefedMetadataStatus: details.flairs.isEmpty ? CreatePostPiefedMetadataStatus.empty : CreatePostPiefedMetadataStatus.loaded,
      )));
    } catch (_) {
      if (requestId != _piefedMetadataRequestId) {
        return;
      }

      emit(state.copyWith(
        piefedMetadataStatus: CreatePostPiefedMetadataStatus.error,
        availablePiefedFlairs: const <ThunderFlair>[],
      ));
    }
  }

  CreatePostPiefedMetadataStatus get _piefedResetStatus => account.platform == ThreadiversePlatform.piefed ? CreatePostPiefedMetadataStatus.empty : CreatePostPiefedMetadataStatus.unsupported;

  CreatePostPiefedMetadataStatus _initialPiefedStatusFor(ThunderPost? post) {
    if (account.platform != ThreadiversePlatform.piefed) {
      return CreatePostPiefedMetadataStatus.unsupported;
    }

    if (post == null) {
      return CreatePostPiefedMetadataStatus.empty;
    }

    return post.flairs.isEmpty ? CreatePostPiefedMetadataStatus.empty : CreatePostPiefedMetadataStatus.loaded;
  }

  List<String>? _submissionTags() {
    if (!state.isPiefedComposer) {
      return null;
    }

    return resolveSubmittedPiefedTags(
      state.tags,
      originalTags: _editingPost?.tags,
    );
  }

  List<int>? _submissionFlairIds() {
    if (!state.isPiefedComposer) {
      return null;
    }

    return resolveSubmittedPiefedFlairIds(
      state.selectedPiefedFlairIds,
      originalFlairIds: _editingPost?.flairs.map((flair) => flair.id),
    );
  }
}
