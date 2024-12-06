import 'dart:async';
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/thunder/enums/deep_link_enums.dart';
import 'package:thunder/utils/global_context.dart';

part 'deep_links_state.dart';

/// A Cubit for handling deep links and determining their types.
class DeepLinksCubit extends Cubit<DeepLinksState> {
  DeepLinksCubit() : super(const DeepLinksState());
  StreamSubscription? _appLinksStreamSubscription;

  AppLinks appLinks = AppLinks();

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
        ));
      }

      if (link.contains("/u/")) {
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

  /// Handles deep link navigation.
  Future<void> initialize() async {
    emit(state.copyWith(deepLinkStatus: DeepLinkStatus.loading));

    _appLinksStreamSubscription = appLinks.uriLinkStream.listen((Uri? uri) {
      emit(state.copyWith(deepLinkStatus: DeepLinkStatus.loading));
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

  void dispose() {
    _appLinksStreamSubscription?.cancel();
  }
}
