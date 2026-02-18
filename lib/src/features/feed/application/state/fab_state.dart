part of 'fab_state_cubit.dart';

class FabStateState extends Equatable {
  const FabStateState({
    this.isFeedFabOpen = false,
    this.isFeedFabSummoned = true,
    this.isPostFabOpen = false,
    this.isPostFabSummoned = true,
  });

  /// Whether the feed FAB is currently open
  final bool isFeedFabOpen;

  /// Whether the feed FAB is currently summoned (visible on screen)
  final bool isFeedFabSummoned;

  /// Whether the post FAB is currently open
  final bool isPostFabOpen;

  /// Whether the post FAB is currently summoned (visible on screen)
  final bool isPostFabSummoned;

  FabStateState copyWith({
    bool? isFeedFabOpen,
    bool? isFeedFabSummoned,
    bool? isPostFabOpen,
    bool? isPostFabSummoned,
  }) {
    return FabStateState(
      isFeedFabOpen: isFeedFabOpen ?? this.isFeedFabOpen,
      isFeedFabSummoned: isFeedFabSummoned ?? this.isFeedFabSummoned,
      isPostFabOpen: isPostFabOpen ?? this.isPostFabOpen,
      isPostFabSummoned: isPostFabSummoned ?? this.isPostFabSummoned,
    );
  }

  @override
  List<Object?> get props => [isFeedFabOpen, isFeedFabSummoned, isPostFabOpen, isPostFabSummoned];
}
