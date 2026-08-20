import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/user/domain/utils/user_media_utils.dart';
import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/core/networking/networking.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/services/localization_service.dart';

const _userMediaUnset = Object();

enum UserMediaStatus { initial, loading, loadSuccess, loadFailure, deleting, searching, searchSuccess, notLoggedIn }

class UserMediaState extends Equatable {
  const UserMediaState({this.status = UserMediaStatus.initial, this.errorMessage = '', this.errorReason, this.images, this.imageSearchPosts, this.imageSearchComments});

  final UserMediaStatus status;
  final String? errorMessage;
  final AppErrorReason? errorReason;
  final List<AccountMediaItem>? images;
  final List<ThunderPost>? imageSearchPosts;
  final List<ThunderComment>? imageSearchComments;

  UserMediaState copyWith({
    UserMediaStatus? status,
    Object? errorMessage = _userMediaUnset,
    Object? errorReason = _userMediaUnset,
    Object? images = _userMediaUnset,
    Object? imageSearchPosts = _userMediaUnset,
    Object? imageSearchComments = _userMediaUnset,
  }) {
    return UserMediaState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _userMediaUnset) ? this.errorMessage : errorMessage as String?,
      errorReason: identical(errorReason, _userMediaUnset) ? this.errorReason : errorReason as AppErrorReason?,
      images: identical(images, _userMediaUnset) ? this.images : images as List<AccountMediaItem>?,
      imageSearchPosts: identical(imageSearchPosts, _userMediaUnset) ? this.imageSearchPosts : imageSearchPosts as List<ThunderPost>?,
      imageSearchComments: identical(imageSearchComments, _userMediaUnset) ? this.imageSearchComments : imageSearchComments as List<ThunderComment>?,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, errorReason, images, imageSearchPosts, imageSearchComments];
}

class UserMediaCubit extends Cubit<UserMediaState> {
  UserMediaCubit({required this.account, required this.accountRepository, required this.searchRepository, required LocalizationService localizationService})
    : _localizationService = localizationService,
      super(const UserMediaState());

  final Account account;
  final AccountRepository accountRepository;
  final SearchRepository searchRepository;
  final LocalizationService _localizationService;

  Future<void> loadMedia() async {
    emit(state.copyWith(status: UserMediaStatus.loading, errorMessage: '', errorReason: null));

    try {
      int page = 1;
      final images = <AccountMediaItem>[];

      while (true) {
        final response = await accountRepository.media(page: page);
        if (response.items.isEmpty) break;

        images.addAll(response.items);
        page++;
      }

      emit(state.copyWith(status: UserMediaStatus.loadSuccess, images: images, errorMessage: '', errorReason: null));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(
        state.copyWith(
          status: UserMediaStatus.loadFailure,
          errorMessage: message,
          errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
        ),
      );
    }
  }

  Future<void> deleteMedia({String? deleteToken, required String id}) async {
    emit(state.copyWith(status: UserMediaStatus.deleting, errorMessage: '', errorReason: null));

    try {
      final images = removeImageByAlias(images: state.images ?? const [], alias: id);
      final l10n = _localizationService.l10n;

      if (account.anonymous) {
        return emit(
          state.copyWith(
            status: UserMediaStatus.notLoggedIn,
            errorMessage: l10n.userNotLoggedIn,
            errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
          ),
        );
      }

      await accountRepository.deleteImage(file: id, token: deleteToken);
      emit(state.copyWith(status: UserMediaStatus.loadSuccess, images: images, errorMessage: '', errorReason: null));
    } catch (e) {
      final message = _localizationService.l10n.errorDeletingImage(getExceptionErrorMessage(e));
      emit(
        state.copyWith(
          status: UserMediaStatus.loadFailure,
          errorMessage: message,
          errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
        ),
      );
    }
  }

  Future<void> findMediaUsages({required String id}) async {
    emit(state.copyWith(status: UserMediaStatus.searching, errorMessage: '', errorReason: null, imageSearchPosts: null, imageSearchComments: null));

    try {
      final url = buildInstanceUrl(account.instance, '/pictrs/image/$id');

      final postsResponse = await searchRepository.search(query: url, type: MetaSearchType.posts);
      final postsByUrlResponse = await searchRepository.search(query: url, type: MetaSearchType.url);
      final response = await searchRepository.search(query: url, type: MetaSearchType.comments);

      final posts = mergeUniquePosts(primary: postsResponse.posts, secondary: postsByUrlResponse.posts);

      emit(state.copyWith(status: UserMediaStatus.searchSuccess, imageSearchPosts: await parsePosts(posts), imageSearchComments: response.comments, errorMessage: '', errorReason: null));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(
        state.copyWith(
          status: UserMediaStatus.loadFailure,
          errorMessage: message,
          errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
        ),
      );
    }
  }
}
