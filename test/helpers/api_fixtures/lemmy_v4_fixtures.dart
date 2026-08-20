/// Minimal Lemmy v4 API JSON fixtures guided by [spec/lemmy_1_0_0.json].
library;

Map<String, dynamic> lemmyV4User({int id = 7, String name = 'alice'}) => {
      'id': id,
      'name': name,
      'published_at': '2025-01-01T00:00:00Z',
      'ap_id': 'https://lemmy.test/u/$name',
      'instance_id': 1,
    };

Map<String, dynamic> lemmyV4Community({int id = 3, String name = 'news'}) => {
      'id': id,
      'name': name,
      'title': 'News',
      'published_at': '2025-01-01T00:00:00Z',
      'ap_id': 'https://lemmy.test/c/$name',
      'instance_id': 1,
    };

Map<String, dynamic> lemmyV4Post({int id = 42, String name = 'Hello Lemmy 1.0'}) => {
      'id': id,
      'name': name,
      'creator_id': 7,
      'community_id': 3,
      'published_at': '2025-06-01T12:00:00Z',
      'comments': 2,
      'score': 10,
      'upvotes': 12,
      'downvotes': 2,
      'ap_id': 'https://lemmy.test/post/$id',
      'language_id': 1,
    };

Map<String, dynamic> lemmyV4PostView({int id = 42, String name = 'Hello Lemmy 1.0'}) => {
      'post': lemmyV4Post(id: id, name: name),
      'creator': lemmyV4User(),
      'community': lemmyV4Community(),
      'post_actions': {'read_at': '2025-06-01T12:00:00Z', 'vote_is_upvote': true},
      'community_actions': {'follow_state': 'accepted'},
    };

Map<String, dynamic> lemmyV4CommentView({int id = 99}) => {
      'comment': {
        'id': id,
        'post_id': 42,
        'creator_id': 7,
        'content': 'Nice post',
        'published_at': '2025-06-01T13:00:00Z',
        'score': 3,
        'upvotes': 4,
        'downvotes': 1,
        'ap_id': 'https://lemmy.test/comment/$id',
        'path': '0.$id',
        'language_id': 1,
      },
      'creator': lemmyV4User(),
      'comment_actions': {'saved': false, 'vote': 1},
    };

Map<String, dynamic> lemmyV4SiteResponse({String version = '1.0.0'}) => {
      'version': version,
      'site_view': {
        'site': {'name': 'Test Site', 'ap_id': 'https://lemmy.test'},
        'local_site': {'enable_downvotes': true},
        'instance': {'domain': 'lemmy.test', 'users': 100},
      },
      'all_languages': [],
      'discussion_languages': [],
      'taglines': [],
    };

Map<String, dynamic> lemmyV4PagedPosts({String? nextPage}) => {
      'items': [lemmyV4PostView()],
      'next_page': ?nextPage,
    };

Map<String, dynamic> lemmyV4PagedComments({String? nextPage}) => {
      'items': [lemmyV4CommentView()],
      'next_page': ?nextPage,
    };

Map<String, dynamic> lemmyV4ModlogItem() => {
      'modlog': {
        'type_': 'ModRemovePost',
        'when_': '2025-06-01T14:00:00Z',
        'reason': 'spam',
        'removed': true,
      },
      'moderator': lemmyV4User(id: 2, name: 'mod'),
      'target_post': lemmyV4Post(),
      'target_community': lemmyV4Community(),
    };

Map<String, dynamic> lemmyV4PagedModlog() => {
      'items': [lemmyV4ModlogItem()],
      'next_page': 'cursor-2',
    };

Map<String, dynamic> lemmyV4PostReportView({int reportId = 5, bool resolved = false}) => {
      'type_': 'post',
      'post_report': {'id': reportId, 'reason': 'spam', 'resolved': resolved},
      'post': lemmyV4Post(),
      'post_creator': lemmyV4User(),
      'creator': lemmyV4User(id: 8, name: 'reporter'),
      'community': lemmyV4Community(),
      'post_actions': {},
      'community_actions': {'follow_state': 'not_followed'},
    };

Map<String, dynamic> lemmyV4PagedReports() => {
      'items': [lemmyV4PostReportView()],
      'next_page': 'report-cursor',
    };

Map<String, dynamic> lemmyV4PrivateMessageNotification({
  int id = 1,
  int creatorId = 7,
  int recipientId = 42,
}) =>
    {
      'id': id,
      'published_at': '2025-06-01T12:00:00Z',
      'read_at': null,
      'notification': {
        'id': id,
        'kind': 'private_message',
        'read': false,
        'published_at': '2025-06-01T12:00:00Z',
      },
      'data': {
        'private_message': {
          'id': id,
          'creator_id': creatorId,
          'recipient_id': recipientId,
          'content': 'Hello',
          'deleted': false,
          'published_at': '2025-06-01T12:00:00Z',
        },
        'creator': lemmyV4User(id: creatorId),
        'recipient': lemmyV4User(id: recipientId, name: 'bob'),
      },
    };

Map<String, dynamic> lemmyV4PrivateMessageView({
  int id = 1,
  int creatorId = 7,
  int recipientId = 42,
}) =>
    {
      'private_message_view': {
        'private_message': {
          'id': id,
          'creator_id': creatorId,
          'recipient_id': recipientId,
          'content': 'Hello',
          'deleted': false,
          'published_at': '2025-06-01T12:00:00Z',
        },
        'creator': lemmyV4User(id: creatorId),
        'recipient': lemmyV4User(id: recipientId, name: 'bob'),
      },
    };
