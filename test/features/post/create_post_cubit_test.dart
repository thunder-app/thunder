import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/foundation/contracts/localization_service.dart';
import 'package:thunder/src/foundation/errors/app_error_reason.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/post/post.dart';

class _MockPostRepository extends Mock implements PostRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockThunderPost extends Mock implements ThunderPost {}

class _MockLocalizationService extends Mock implements LocalizationService {}

class _MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  group('CreatePostCubit', () {
    late _MockPostRepository postRepository;
    late _MockAccountRepository accountRepository;
    late _MockLocalizationService localizationService;
    late _MockAppLocalizations l10n;

    setUp(() {
      postRepository = _MockPostRepository();
      accountRepository = _MockAccountRepository();
      localizationService = _MockLocalizationService();
      l10n = _MockAppLocalizations();
      when(() => localizationService.l10n).thenReturn(l10n);
      when(() => l10n.userNotLoggedIn).thenReturn('User not logged in');
    });

    blocTest<CreatePostCubit, CreatePostState>(
      'emits not-logged-in typed error for anonymous image upload',
      build: () => CreatePostCubit(
        account: const Account(
          id: 'anon',
          index: 0,
          instance: 'lemmy.world',
          anonymous: true,
        ),
        postRepositoryFactory: (_) => postRepository,
        accountRepositoryFactory: (_) => accountRepository,
        localizationService: localizationService,
      ),
      act: (cubit) => cubit.uploadImages(const ['a.png']),
      expect: () => [
        isA<CreatePostState>()
            .having((state) => state.status, 'status',
                CreatePostStatus.imageUploadFailure)
            .having((state) => state.errorReason?.category, 'error category',
                AppErrorCategory.notLoggedIn),
      ],
    );

    blocTest<CreatePostCubit, CreatePostState>(
      'emits typed actionFailed error when create fails',
      build: () {
        when(() => postRepository.create(
              communityId: 1,
              name: 'Title',
              body: null,
              url: null,
              customThumbnail: null,
              altText: null,
              nsfw: null,
              postIdBeingEdited: null,
              languageId: null,
            )).thenThrow(Exception('failed'));

        return CreatePostCubit(
          account: const Account(id: '1', index: 0, instance: 'lemmy.world'),
          postRepositoryFactory: (_) => postRepository,
          accountRepositoryFactory: (_) => accountRepository,
          localizationService: localizationService,
        );
      },
      act: (cubit) => cubit.createOrEditPost(communityId: 1, name: 'Title'),
      expect: () => [
        isA<CreatePostState>().having(
            (state) => state.status, 'status', CreatePostStatus.submitting),
        isA<CreatePostState>()
            .having((state) => state.status, 'status', CreatePostStatus.error)
            .having((state) => state.errorReason?.category, 'error category',
                AppErrorCategory.actionFailed),
      ],
    );

    blocTest<CreatePostCubit, CreatePostState>(
      'emits success when create succeeds',
      build: () {
        final post = _MockThunderPost();
        when(() => post.id).thenReturn(101);

        when(() => postRepository.create(
              communityId: 1,
              name: 'Title',
              body: null,
              url: null,
              customThumbnail: null,
              altText: null,
              nsfw: null,
              postIdBeingEdited: null,
              languageId: null,
            )).thenAnswer((_) async => post);

        return CreatePostCubit(
          account: const Account(id: '1', index: 0, instance: 'lemmy.world'),
          postRepositoryFactory: (_) => postRepository,
          accountRepositoryFactory: (_) => accountRepository,
          localizationService: localizationService,
        );
      },
      act: (cubit) => cubit.createOrEditPost(communityId: 1, name: 'Title'),
      expect: () => [
        isA<CreatePostState>().having(
            (state) => state.status, 'status', CreatePostStatus.submitting),
        isA<CreatePostState>()
            .having((state) => state.status, 'status', CreatePostStatus.success)
            .having((state) => state.errorReason, 'errorReason', isNull),
      ],
    );
  });
}
