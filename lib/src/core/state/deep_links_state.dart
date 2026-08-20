part of 'deep_links_cubit.dart';

enum DeepLinkStatus { empty, loading, error, success, unknown }

const _deepLinksUnset = Object();

class DeepLinksState extends Equatable {
  const DeepLinksState({this.deepLinkStatus = DeepLinkStatus.empty, this.linkType = LinkType.unknown, this.link, this.error, this.errorReason});
  final String? error;
  final AppErrorReason? errorReason;
  final LinkType linkType;
  final String? link;
  final DeepLinkStatus deepLinkStatus;

  DeepLinksState copyWith({DeepLinkStatus? deepLinkStatus, Object? error = _deepLinksUnset, Object? errorReason = _deepLinksUnset, Object? link = _deepLinksUnset, LinkType? linkType}) {
    return DeepLinksState(
      deepLinkStatus: deepLinkStatus ?? this.deepLinkStatus,
      error: identical(error, _deepLinksUnset) ? this.error : error as String?,
      errorReason: identical(errorReason, _deepLinksUnset) ? this.errorReason : errorReason as AppErrorReason?,
      linkType: linkType ?? this.linkType,
      link: identical(link, _deepLinksUnset) ? this.link : link as String?,
    );
  }

  @override
  List<Object?> get props => [error, errorReason, linkType, link, deepLinkStatus];
}
