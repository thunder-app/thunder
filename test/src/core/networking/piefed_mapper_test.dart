import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/core/networking/mappers/piefed_mapper.dart';
import 'package:thunder/src/core/domain/models/thunder_report.dart';

void main() {
  const mapper = PiefedPrimitiveMapper();

  group('PiefedPrimitiveMapper', () {
    test('maps post view fixture to ThunderPost', () {
      final post = mapper.postView({
        'post': {
          'id': 42,
          'title': 'Hello PieFed',
          'user_id': 7,
          'community_id': 3,
          'published': '2025-06-01T12:00:00Z',
          'ap_id': 'https://piefed.test/post/42',
          'language_id': 1,
        },
        'creator': {
          'id': 7,
          'user_name': 'alice',
          'published': '2025-01-01T00:00:00Z',
          'actor_id': 'https://piefed.test/u/alice',
          'instance_id': 1,
        },
        'community': {
          'id': 3,
          'name': 'news',
          'title': 'News',
          'published': '2025-01-01T00:00:00Z',
          'actor_id': 'https://piefed.test/c/news',
          'instance_id': 1,
        },
        'counts': {
          'comments': 2,
          'score': 10,
          'upvotes': 12,
          'downvotes': 2,
        },
        'subscribed': 'NotSubscribed',
      });

      expect(post.id, 42);
      expect(post.name, 'Hello PieFed');
      expect(post.creator?.name, 'alice');
      expect(post.community?.name, 'news');
      expect(post.counts.comments, 2);
    });

    test('maps comment view fixture to ThunderComment', () {
      final comment = mapper.commentView({
        'comment': {
          'id': 99,
          'post_id': 42,
          'user_id': 7,
          'body': 'Nice post',
          'published': '2025-06-01T13:00:00Z',
          'ap_id': 'https://piefed.test/comment/99',
          'path': '0.99',
          'language_id': 1,
        },
        'creator': {
          'id': 7,
          'user_name': 'alice',
          'published': '2025-01-01T00:00:00Z',
          'actor_id': 'https://piefed.test/u/alice',
          'instance_id': 1,
        },
        'counts': {
          'score': 3,
          'upvotes': 4,
          'downvotes': 1,
        },
      });

      expect(comment.id, 99);
      expect(comment.content, 'Nice post');
      expect(comment.creator?.name, 'alice');
      expect(comment.counts.score, 3);
    });

    test('maps post report view using PieFed field names', () {
      final report = mapper.postReportView({
        'post_report': {
          'id': 5,
          'reason': 'spam',
          'resolved': false,
        },
        'post': {
          'id': 42,
          'title': 'Reported PieFed Post',
          'user_id': 7,
          'community_id': 3,
          'published': '2025-06-01T12:00:00Z',
          'ap_id': 'https://piefed.test/post/42',
          'language_id': 1,
        },
        'post_creator': {
          'id': 7,
          'user_name': 'alice',
          'published': '2025-01-01T00:00:00Z',
          'actor_id': 'https://piefed.test/u/alice',
          'instance_id': 1,
        },
        'creator': {
          'id': 8,
          'user_name': 'reporter',
          'published': '2025-01-01T00:00:00Z',
          'actor_id': 'https://piefed.test/u/reporter',
          'instance_id': 1,
        },
        'community': {
          'id': 3,
          'name': 'news',
          'title': 'News',
          'published': '2025-01-01T00:00:00Z',
          'actor_id': 'https://piefed.test/c/news',
          'instance_id': 1,
        },
        'counts': {
          'comments': 2,
          'score': 10,
          'upvotes': 12,
          'downvotes': 2,
        },
        'subscribed': 'Subscribed',
        'saved': true,
      });

      expect(report.id, 5);
      expect(report.kind, ReportKind.post);
      expect(report.reason, 'spam');
      expect(report.creator?.name, 'reporter');
      expect(report.post?.name, 'Reported PieFed Post');
      expect(report.post?.creatorId, 7);
      expect(report.post?.creator?.name, 'alice');
      expect(report.post?.community?.name, 'news');
    });

    test('maps comment report view using PieFed field names', () {
      final report = mapper.commentReportView({
        'comment_report': {
          'id': 6,
          'reason': 'rule violation',
          'resolved': true,
        },
        'comment': {
          'id': 99,
          'post_id': 42,
          'user_id': 7,
          'body': 'Reported PieFed comment',
          'published': '2025-06-01T13:00:00Z',
          'ap_id': 'https://piefed.test/comment/99',
          'path': '0.99',
          'language_id': 1,
        },
        'comment_creator': {
          'id': 7,
          'user_name': 'alice',
          'published': '2025-01-01T00:00:00Z',
          'actor_id': 'https://piefed.test/u/alice',
          'instance_id': 1,
        },
        'creator': {
          'id': 8,
          'user_name': 'reporter',
          'published': '2025-01-01T00:00:00Z',
          'actor_id': 'https://piefed.test/u/reporter',
          'instance_id': 1,
        },
        'post': {
          'id': 42,
          'title': 'Hello PieFed',
          'user_id': 7,
          'community_id': 3,
          'published': '2025-06-01T12:00:00Z',
          'ap_id': 'https://piefed.test/post/42',
          'language_id': 1,
        },
        'community': {
          'id': 3,
          'name': 'news',
          'title': 'News',
          'published': '2025-01-01T00:00:00Z',
          'actor_id': 'https://piefed.test/c/news',
          'instance_id': 1,
        },
        'counts': {
          'score': 3,
          'upvotes': 4,
          'downvotes': 1,
        },
      });

      expect(report.id, 6);
      expect(report.kind, ReportKind.comment);
      expect(report.resolved, isTrue);
      expect(report.creator?.name, 'reporter');
      expect(report.comment?.content, 'Reported PieFed comment');
      expect(report.comment?.creatorId, 7);
      expect(report.comment?.creator?.name, 'alice');
      expect(report.post?.name, 'Hello PieFed');
    });
  });
}
