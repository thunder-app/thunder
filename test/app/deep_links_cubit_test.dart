import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/app/state/deep_links_cubit/deep_links_cubit.dart';
import 'package:thunder/src/app/shell/routing/deep_link_enums.dart';
import 'package:thunder/src/foundation/contracts/deep_link_service.dart';
import 'package:thunder/src/foundation/contracts/localization_service.dart';
import 'package:thunder/src/foundation/errors/app_error_reason.dart';

class _FakeDeepLinkService implements DeepLinkService {
  _FakeDeepLinkService(this._stream);

  final Stream<Uri?> _stream;

  @override
  Stream<Uri?> get uriLinkStream => _stream;
}

class _MockLocalizationService extends Mock implements LocalizationService {}

class _MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  group('DeepLinksCubit', () {
    late _MockLocalizationService localizationService;
    late _MockAppLocalizations l10n;

    setUp(() {
      localizationService = _MockLocalizationService();
      l10n = _MockAppLocalizations();
      when(() => localizationService.l10n).thenReturn(l10n);
      when(() => l10n.uriNotSupported).thenReturn('URI not supported');
    });

    blocTest<DeepLinksCubit, DeepLinksState>(
      'emits success for user links',
      build: () => DeepLinksCubit(
        deepLinkService: _FakeDeepLinkService(const Stream<Uri?>.empty()),
        localizationService: localizationService,
      ),
      act: (cubit) => cubit.getLinkType('https://lemmy.world/u/tester'),
      expect: () => [
        isA<DeepLinksState>()
            .having((state) => state.deepLinkStatus, 'status',
                DeepLinkStatus.success)
            .having((state) => state.linkType, 'type', LinkType.user)
            .having(
                (state) => state.link, 'link', 'https://lemmy.world/u/tester'),
      ],
    );

    blocTest<DeepLinksCubit, DeepLinksState>(
      'emits typed validation error for unsupported links',
      build: () => DeepLinksCubit(
        deepLinkService: _FakeDeepLinkService(const Stream<Uri?>.empty()),
        localizationService: localizationService,
      ),
      act: (cubit) => cubit.getLinkType('https://lemmy.world/random/path'),
      expect: () => [
        isA<DeepLinksState>()
            .having((state) => state.deepLinkStatus, 'status',
                DeepLinkStatus.unknown)
            .having((state) => state.errorReason?.category, 'error category',
                AppErrorCategory.validation),
      ],
    );
  });
}
