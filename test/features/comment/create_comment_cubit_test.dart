import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/foundation/contracts/localization_service.dart';
import 'package:thunder/src/foundation/errors/app_error_reason.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';

class _MockCommentRepository extends Mock implements CommentRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

class _MockThunderComment extends Mock implements ThunderComment {}

class _MockLocalizationService extends Mock implements LocalizationService {}

class _MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  group('CreateCommentCubit', () {
    late _MockCommentRepository commentRepository;
    late _MockAccountRepository accountRepository;
    late _MockLocalizationService localizationService;
    late _MockAppLocalizations l10n;

    setUp(() {
      commentRepository = _MockCommentRepository();
      accountRepository = _MockAccountRepository();
      localizationService = _MockLocalizationService();
      l10n = _MockAppLocalizations();
      when(() => localizationService.l10n).thenReturn(l10n);
      when(() => l10n.userNotLoggedIn).thenReturn('User not logged in');
    });

    blocTest<CreateCommentCubit, CreateCommentState>(
      'emits not-logged-in typed error for anonymous image upload',
      build: () => CreateCommentCubit(
        account: const Account(
          id: 'anon',
          index: 0,
          instance: 'lemmy.world',
          anonymous: true,
        ),
        commentRepositoryFactory: (_) => commentRepository,
        accountRepositoryFactory: (_) => accountRepository,
        localizationService: localizationService,
      ),
      act: (cubit) => cubit.uploadImages(const ['a.png']),
      expect: () => [
        isA<CreateCommentState>()
            .having((state) => state.status, 'status',
                CreateCommentStatus.imageUploadFailure)
            .having((state) => state.errorReason?.category, 'error category',
                AppErrorCategory.notLoggedIn),
      ],
    );

    blocTest<CreateCommentCubit, CreateCommentState>(
      'emits typed actionFailed error when comment create fails',
      build: () {
        when(() => commentRepository.create(
              postId: 12,
              content: 'Hello',
              parentId: null,
              languageId: null,
            )).thenThrow(Exception('failed'));

        return CreateCommentCubit(
          account: const Account(id: '1', index: 0, instance: 'lemmy.world'),
          commentRepositoryFactory: (_) => commentRepository,
          accountRepositoryFactory: (_) => accountRepository,
          localizationService: localizationService,
        );
      },
      act: (cubit) => cubit.createOrEditComment(postId: 12, content: 'Hello'),
      expect: () => [
        isA<CreateCommentState>().having(
            (state) => state.status, 'status', CreateCommentStatus.submitting),
        isA<CreateCommentState>()
            .having((state) => state.status, 'status', CreateCommentStatus.error)
            .having((state) => state.errorReason?.category, 'error category',
                AppErrorCategory.actionFailed),
      ],
    );

    blocTest<CreateCommentCubit, CreateCommentState>(
      'emits success when comment create succeeds',
      build: () {
        final comment = _MockThunderComment();
        when(() => comment.id).thenReturn(88);

        when(() => commentRepository.create(
              postId: 12,
              content: 'Hello',
              parentId: null,
              languageId: null,
            )).thenAnswer((_) async => comment);

        return CreateCommentCubit(
          account: const Account(id: '1', index: 0, instance: 'lemmy.world'),
          commentRepositoryFactory: (_) => commentRepository,
          accountRepositoryFactory: (_) => accountRepository,
          localizationService: localizationService,
        );
      },
      act: (cubit) => cubit.createOrEditComment(postId: 12, content: 'Hello'),
      expect: () => [
        isA<CreateCommentState>().having(
            (state) => state.status, 'status', CreateCommentStatus.submitting),
        isA<CreateCommentState>()
            .having((state) => state.status, 'status', CreateCommentStatus.success)
            .having((state) => state.errorReason, 'errorReason', isNull),
      ],
    );
  });
}
