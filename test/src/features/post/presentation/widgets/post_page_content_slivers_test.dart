import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/post/presentation/widgets/post_comments_sliver.dart';
import 'package:thunder/src/features/post/presentation/widgets/post_page_content_slivers.dart';

import '../../../../../helpers/repository_test_fixtures.dart';

void main() {
  group('postContentPhaseForStatus', () {
    test('treats pagination states as the same content phase', () {
      expect(postContentPhaseForStatus(PostPageStatus.refreshing), PostContentPhase.content);
      expect(postContentPhaseForStatus(PostPageStatus.success), PostContentPhase.content);
      expect(postContentPhaseForStatus(PostPageStatus.empty), PostContentPhase.content);
      expect(postContentPhaseForStatus(PostPageStatus.searchInProgress), PostContentPhase.content);
    });

    test('keeps loading and failure branches distinct', () {
      expect(postContentPhaseForStatus(PostPageStatus.initial), PostContentPhase.loading);
      expect(postContentPhaseForStatus(PostPageStatus.loading), PostContentPhase.loading);
      expect(postContentPhaseForStatus(PostPageStatus.failure), PostContentPhase.failure);
    });
  });

  group('postPageContentChanged', () {
    final post = testPost();

    test('does not rebuild the post body for pagination status changes', () {
      final previous = PostState(status: PostPageStatus.success, post: post);
      final refreshing = previous.copyWith(status: PostPageStatus.refreshing);
      final success = refreshing.copyWith(status: PostPageStatus.success);

      expect(postPageContentChanged(previous, refreshing), isFalse);
      expect(postPageContentChanged(refreshing, success), isFalse);
    });

    test('rebuilds content when the post changes', () {
      final previous = PostState(status: PostPageStatus.success, post: post);
      final current = previous.copyWith(post: testPost(name: 'Updated'));

      expect(postPageContentChanged(previous, current), isTrue);
    });

    test('rebuilds when entering or updating the failure branch', () {
      final previous = PostState(status: PostPageStatus.success, post: post);
      final failure = previous.copyWith(status: PostPageStatus.failure, errorMessage: 'first');
      final updatedFailure = failure.copyWith(errorMessage: 'second');

      expect(postPageContentChanged(previous, failure), isTrue);
      expect(postPageContentChanged(failure, updatedFailure), isTrue);
    });
  });

  group('postCommentsChanged', () {
    const previous = PostState(status: PostPageStatus.success);

    test('rebuilds for appended comments', () {
      final current = previous.copyWith(comments: [CommentNode(comment: testComment())]);

      expect(postCommentsChanged(previous, current), isTrue);
    });

    test('rebuilds for collapsed comment changes', () {
      final current = previous.copyWith(collapsedComments: {200});

      expect(postCommentsChanged(previous, current), isTrue);
    });

    test('ignores moderation-only progress state', () {
      final current = previous.copyWith(moddingCommentId: 200);

      expect(postCommentsChanged(previous, current), isFalse);
    });
  });
}
