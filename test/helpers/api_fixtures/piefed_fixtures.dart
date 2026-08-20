/// Minimal PieFed API JSON fixtures guided by [spec/piefed_1_6.json].
library;

Map<String, dynamic> piefedUser({int id = 7, String name = 'alice'}) => {
      'id': id,
      'user_name': name,
      'published': '2025-01-01T00:00:00Z',
      'actor_id': 'https://piefed.test/u/$name',
      'instance_id': 1,
    };

Map<String, dynamic> piefedCommunity({int id = 3, String name = 'news'}) => {
      'id': id,
      'name': name,
      'title': 'News',
      'published': '2025-01-01T00:00:00Z',
      'actor_id': 'https://piefed.test/c/$name',
      'instance_id': 1,
    };

Map<String, dynamic> piefedPost({int id = 42, String title = 'Hello PieFed'}) => {
      'id': id,
      'title': title,
      'user_id': 7,
      'community_id': 3,
      'published': '2025-06-01T12:00:00Z',
      'ap_id': 'https://piefed.test/post/$id',
      'language_id': 1,
    };

Map<String, dynamic> piefedPostView({int id = 42, String title = 'Hello PieFed', bool hidden = false}) => {
      'post': piefedPost(id: id, title: title),
      'creator': piefedUser(),
      'community': piefedCommunity(),
      'counts': {'comments': 2, 'score': 10, 'upvotes': 12, 'downvotes': 2},
      'subscribed': 'NotSubscribed',
      'hidden': hidden,
    };

Map<String, dynamic> piefedCommentView({int id = 99}) => {
      'comment': {
        'id': id,
        'post_id': 42,
        'user_id': 7,
        'body': 'Nice post',
        'published': '2025-06-01T13:00:00Z',
        'ap_id': 'https://piefed.test/comment/$id',
        'path': '0.$id',
        'language_id': 1,
      },
      'creator': piefedUser(),
      'counts': {'score': 3, 'upvotes': 4, 'downvotes': 1},
    };

Map<String, dynamic> piefedSiteResponse({String version = '1.6.0'}) => {
      'version': version,
      'site': {
        'name': 'PieFed Test',
        'actor_id': 'https://piefed.test',
        'icon': 'https://piefed.test/icon.png',
        'user_count': 50,
        'enable_downvotes': true,
        'all_languages': [],
      },
    };

Map<String, dynamic> piefedPostListResponse({String? nextCursor}) => {
      'posts': [piefedPostView()],
      'next_cursor': ?nextCursor,
    };

Map<String, dynamic> piefedPostReportView({int reportId = 5, bool resolved = false}) => {
      'post_report': {'id': reportId, 'reason': 'spam', 'resolved': resolved},
      'post': piefedPost(),
      'post_creator': piefedUser(),
      'creator': piefedUser(id: 8, name: 'reporter'),
      'community': piefedCommunity(),
      'counts': {'comments': 0, 'score': 0, 'upvotes': 0, 'downvotes': 0},
      'subscribed': 'NotSubscribed',
    };

Map<String, dynamic> piefedCommentReportView({int reportId = 6, bool resolved = true}) => {
      'comment_report': {'id': reportId, 'reason': 'rule violation', 'resolved': resolved},
      'comment': piefedCommentView()['comment'],
      'comment_creator': piefedUser(),
      'creator': piefedUser(id: 8, name: 'reporter'),
      'post': piefedPost(),
      'community': piefedCommunity(),
      'counts': {'score': 0, 'upvotes': 0, 'downvotes': 0},
    };

Map<String, dynamic> piefedRemovedPostModlogEvent() => {
      'mod_remove_post': {
        'when_': '2025-06-01T14:00:00Z',
        'reason': 'spam',
        'removed': true,
      },
      'moderator': piefedUser(id: 2, name: 'mod'),
      'post': piefedPost(),
      'community': piefedCommunity(),
    };

Map<String, dynamic> piefedModlogResponse({bool includeEvents = true}) => {
      'removed_posts': includeEvents ? [piefedRemovedPostModlogEvent()] : [],
      'locked_posts': [],
    };

Map<String, dynamic> piefedPrivateMessageView({
  int id = 1,
  int creatorId = 7,
  int recipientId = 42,
}) =>
    {
      'private_message': {
        'id': id,
        'creator_id': creatorId,
        'recipient_id': recipientId,
        'content': 'Hello',
        'deleted': false,
        'read': false,
        'published': '2025-06-01T12:00:00Z',
      },
      'creator': piefedUser(id: creatorId),
      'recipient': piefedUser(id: recipientId, name: 'bob'),
      'conversation_id': 99,
    };
