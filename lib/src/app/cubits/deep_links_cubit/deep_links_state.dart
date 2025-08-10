part of 'deep_links_cubit.dart';

enum DeepLinkStatus { empty, loading, error, success, unknown }

class DeepLinksState extends Equatable {
  const DeepLinksState({
    this.deepLinkStatus = DeepLinkStatus.empty,
    this.linkType = LinkType.unknown,
    this.link,
    this.error,
  });
  final String? error;
  final LinkType linkType;
  final String? link;
  final DeepLinkStatus deepLinkStatus;

  DeepLinksState copyWith({
    required DeepLinkStatus? deepLinkStatus,
    String? error,
    String? link,
    LinkType? linkType,
  }) {
    return DeepLinksState(
      deepLinkStatus: deepLinkStatus ?? this.deepLinkStatus,
      error: error ?? this.error,
      linkType: linkType ?? this.linkType,
      link: link ?? this.link,
    );
  }

  @override
  List<dynamic> get props => [
        error,
        linkType,
        link,
        deepLinkStatus,
      ];
}
