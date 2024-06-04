import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:thunder/thunder/enums/deep_link_enums.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'deep_links_state.dart';

/// A Cubit for handling deep links and determining their types.
class DeepLinksCubit extends Cubit<DeepLinksState> {
  DeepLinksCubit() : super(const DeepLinksState());
  StreamSubscription? _uniLinksStreamSubscription;

  /// Analyzes a given link to determine its type and updates the state accordingly.
  ///
  /// [link] is the URL to be analyzed.
  Future<void> getLinkType(String link) async {
    try {
      if (link.startsWith('thunder://')) {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.thunder,
        ));
      } else if (link.contains("/u/")) {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.user,
        ));
      } else if (link.contains("/post/")) {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.post,
        ));
      } else if (link.contains("/comment/")) {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.comment,
        ));
      } else if (link.contains("/c/")) {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.community,
        ));
      } else if (link.contains("/modlog")) {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.modlog,
        ));
      } else if (Uri.tryParse(link)?.pathSegments.isEmpty == true) {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.success,
          link: link,
          linkType: LinkType.instance,
        ));
      } else {
        emit(state.copyWith(
          deepLinkStatus: DeepLinkStatus.unknown,
          link: link,
          error: AppLocalizations.of(GlobalContext.context)!.uriNotSupported,
        ));
      }
    } catch (e) {
      emit(
        state.copyWith(
          deepLinkStatus: DeepLinkStatus.error,
          error: e.toString(),
          link: link,
        ),
      );
    }
  }

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.

  Future<void> handleIncomingLinks() async {
    emit(state.copyWith(
      deepLinkStatus: DeepLinkStatus.loading,
    ));
    _uniLinksStreamSubscription = uriLinkStream.listen((Uri? uri) {
      emit(state.copyWith(
        deepLinkStatus: DeepLinkStatus.loading,
      ));
      getLinkType(uri.toString());
    }, onError: (Object err) {
      if (err is FormatException) {
        emit(
          state.copyWith(
            deepLinkStatus: DeepLinkStatus.error,
            error: AppLocalizations.of(GlobalContext.context)!.malformedUri,
          ),
        );
      } else {
        state.copyWith(
          deepLinkStatus: DeepLinkStatus.error,
          error: err.toString(),
        );
      }
    });
  }

  /// Handle the initial Uri - the one the app was started with
  Future<void> handleInitialURI() async {
    try {
      emit(state.copyWith(
        deepLinkStatus: DeepLinkStatus.loading,
      ));
      final uri = await getInitialUri();
      if (uri == null) {
        state.copyWith(
          deepLinkStatus: DeepLinkStatus.empty,
          error: AppLocalizations.of(GlobalContext.context)!.emptyUri,
        );
      } else {
        getLinkType(uri.toString());
      }
    } catch (e) {
      state.copyWith(
        deepLinkStatus: DeepLinkStatus.error,
        error: e.toString(),
      );
    }
  }

  void dispose() {
    _uniLinksStreamSubscription?.cancel();
  }
}
