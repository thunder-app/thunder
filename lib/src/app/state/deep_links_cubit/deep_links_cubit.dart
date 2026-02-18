import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/app/shell/routing/deep_link_enums.dart';

part 'deep_links_state.dart';

/// A Cubit for handling deep links and determining their types.
class DeepLinksCubit extends Cubit<DeepLinksState> {
  DeepLinksCubit({
    required DeepLinkService deepLinkService,
    required LocalizationService localizationService,
  })  : _deepLinkService = deepLinkService,
        _localizationService = localizationService,
        super(const DeepLinksState());
  StreamSubscription<Uri?>? _appLinksStreamSubscription;

  final DeepLinkService _deepLinkService;
  final LocalizationService _localizationService;

  /// Analyzes a given link to determine its type and updates the state accordingly.
  ///
  /// [link] is the URL to be analyzed.
  Future<void> getLinkType(String link) async {
    try {
      // First, check to see if this is an internal Thunder link
      List<String> internalLinks = ['thunder://setting-'];

      if (internalLinks.where((internalLink) => link.startsWith(internalLink)).isNotEmpty) {
        return emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.thunder,
          error: null,
          errorReason: null,
        ));
      }

      if (link.contains("/u/")) {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.user,
          error: null,
          errorReason: null,
        ));
      } else if (link.contains("/post/")) {
        LinkType linkType = LinkType.post;

        // See if this is actually a comment link
        Uri? uri = Uri.tryParse(link);
        if (uri != null && uri.pathSegments.length >= 3 && int.tryParse(uri.pathSegments[2]) != null) {
          linkType = LinkType.comment;
        }

        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: linkType,
          error: null,
          errorReason: null,
        ));
      } else if (link.contains("/comment/")) {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.comment,
          error: null,
          errorReason: null,
        ));
      } else if (link.contains("/c/")) {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.community,
          error: null,
          errorReason: null,
        ));
      } else if (link.contains("/modlog")) {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.modlog,
          error: null,
          errorReason: null,
        ));
      } else if (Uri.tryParse(link)?.pathSegments.isEmpty == true) {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.instance,
          error: null,
          errorReason: null,
        ));
      } else {
        final message = _localizationService.l10n.uriNotSupported;
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.unknown,
          link: link,
          error: message,
          errorReason: AppErrorReason.validation(message: message),
        ));
      }
    } catch (e) {
      final message = e.toString();
      emit(
        state.copyWith(
          deepLinkStatus: DeepLinkStatus.error,
          error: message,
          errorReason: AppErrorReason.unexpected(message: message),
          link: link,
        ),
      );
    }
  }

  /// Handles deep link navigation.
  Future<void> initialize() async {
    emit(state.copyWith(
      deepLinkStatus: DeepLinkStatus.loading,
      error: null,
      errorReason: null,
    ));

    _appLinksStreamSubscription = _deepLinkService.uriLinkStream.listen((Uri? uri) {
      emit(state.copyWith(
        deepLinkStatus: DeepLinkStatus.loading,
        error: null,
        errorReason: null,
      ));
      getLinkType(uri.toString());
    }, onError: (Object err) {
      if (err is FormatException) {
        final message = _localizationService.l10n.malformedUri;
        emit(
          state.copyWith(
            deepLinkStatus: DeepLinkStatus.error,
            error: message,
            errorReason: AppErrorReason.validation(message: message),
          ),
        );
      } else {
        final message = err.toString();
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.error,
          error: message,
          errorReason: AppErrorReason.unexpected(message: message),
        ));
      }
    });
  }

  @override
  Future<void> close() async {
    _appLinksStreamSubscription?.cancel();
    await super.close();
  }
}
