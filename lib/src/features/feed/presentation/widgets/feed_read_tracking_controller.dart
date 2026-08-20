import 'dart:async';

import 'package:thunder/src/features/post/post.dart';

/// Tracks feed-row visibility and batches unread post ids for read-on-scroll.
class FeedReadTrackingController {
  /// The index of the last tapped post.
  int lastTappedIndex = -1;

  /// The index of the last processed post for read status.
  int lastProcessedIndex = -1;

  /// Whether the user is currently scrolling down.
  bool isScrollingDown = false;

  final Set<int> _queuedPostIds = <int>{};
  final Set<int> _processedPostIds = <int>{};
  Timer? _debounceTimer;

  /// Releases the pending read debounce timer.
  void dispose() {
    _debounceTimer?.cancel();
  }

  /// Records which row was most recently pressed.
  void updateLastTappedIndex(int index) {
    lastTappedIndex = index;
  }

  /// Updates the current scroll direction from a vertical drag distance.
  void updateScrollDirection(double verticalDragDistance) {
    isScrollingDown = verticalDragDistance < 0;
  }

  /// Queues unread ids between the hidden row and the previous processed row.
  void queueReadBatch({required int index, required List<ThunderPost> posts, required void Function(List<int> postIds) onBatchReady}) {
    if (!isScrollingDown || index > lastTappedIndex || index < 0 || index >= posts.length) {
      return;
    }

    final endIndex = lastProcessedIndex > 0 ? lastProcessedIndex : 0;
    if (index < endIndex) return;

    for (int i = index; i >= endIndex; i--) {
      final post = posts[i];
      if (_processedPostIds.contains(post.id) || _queuedPostIds.contains(post.id)) {
        continue;
      }

      if (post.context.read == false) {
        _queuedPostIds.add(post.id);
      }
      _processedPostIds.add(post.id);
    }

    if (index > lastProcessedIndex) {
      lastProcessedIndex = index;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_queuedPostIds.isEmpty) return;

      final postIds = List<int>.unmodifiable(_queuedPostIds);
      _processedPostIds.addAll(postIds);
      _queuedPostIds.clear();
      onBatchReady(postIds);
    });
  }
}
