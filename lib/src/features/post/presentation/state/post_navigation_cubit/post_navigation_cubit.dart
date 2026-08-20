import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'post_navigation_state.dart';

enum NavigateCommentDirection { up, down }

abstract class PostNavigationEvent extends Equatable {
  const PostNavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigateCommentEvent extends PostNavigationEvent {
  final NavigateCommentDirection direction;
  final int targetIndex;

  const NavigateCommentEvent({required this.targetIndex, required this.direction});

  @override
  List<Object> get props => [direction, targetIndex];
}

class StartCommentSearchEvent extends PostNavigationEvent {
  final Map<int, int> commentSearchResults;

  const StartCommentSearchEvent({required this.commentSearchResults});

  @override
  List<Object> get props => [commentSearchResults];
}

class ContinueCommentSearchEvent extends PostNavigationEvent {
  const ContinueCommentSearchEvent();
}

class EndCommentSearchEvent extends PostNavigationEvent {
  const EndCommentSearchEvent();
}

class UpdateScrollPositionEvent extends PostNavigationEvent {
  final double scrollPosition;

  const UpdateScrollPositionEvent({required this.scrollPosition});

  @override
  List<Object> get props => [scrollPosition];
}

class SetHighlightedCommentIdEvent extends PostNavigationEvent {
  final int? highlightedCommentId;

  const SetHighlightedCommentIdEvent({required this.highlightedCommentId});

  @override
  List<Object> get props => [highlightedCommentId ?? -1];
}

class PostNavigationCubit extends Cubit<PostNavigationState> {
  PostNavigationCubit() : super(const PostNavigationState());

  void navigateComment(NavigateCommentDirection direction, int targetIndex) {
    if (direction == NavigateCommentDirection.up) {
      emit(state.copyWith(navigateCommentIndex: max(0, targetIndex)));
    } else {
      emit(state.copyWith(navigateCommentIndex: targetIndex));
    }
  }

  void startCommentSearch(Map<int, int> commentSearchResults) {
    if (commentSearchResults.isEmpty) return;

    int firstMatchIndex = commentSearchResults.keys.first;
    int firstMatchCommentId = commentSearchResults[firstMatchIndex]!;

    emit(state.copyWith(commentSearchResults: commentSearchResults, highlightedCommentId: firstMatchCommentId, navigateCommentIndex: firstMatchIndex));
  }

  void continueCommentSearch() {
    if (state.commentSearchResults?.isEmpty ?? true) return;

    final commentSearchResults = state.commentSearchResults!;
    final commentSearchResultIndexes = commentSearchResults.keys.toList();

    // Find the current match position in our sorted list
    int currentMatchPosition = -1;
    int currentCommentId = state.highlightedCommentId ?? commentSearchResults.values.first;

    for (int i = 0; i < commentSearchResultIndexes.length; i++) {
      if (commentSearchResults[commentSearchResultIndexes[i]] == currentCommentId) {
        currentMatchPosition = i;
        break;
      }
    }

    // Move to the next match, wrapping around to the beginning if at the end
    int nextMatchPosition = (currentMatchPosition + 1) % commentSearchResultIndexes.length;
    int nextFlattenedIndex = commentSearchResultIndexes[nextMatchPosition];
    int nextCommentId = commentSearchResults[nextFlattenedIndex]!;

    emit(state.copyWith(highlightedCommentId: nextCommentId, navigateCommentIndex: nextFlattenedIndex));
  }

  void endCommentSearch() {
    emit(state.copyWith(highlightedCommentId: null, commentSearchResults: null));
  }

  void updateScrollPosition(double scrollPosition) {
    emit(state.copyWith(scrollPosition: scrollPosition, didScrollPositionChange: true));
  }

  void setHighlightedCommentId(int? highlightedCommentId) {
    emit(state.copyWith(highlightedCommentId: highlightedCommentId));
  }

  void clearScrollPositionChange() {
    emit(state.copyWith(didScrollPositionChange: false));
  }
}
