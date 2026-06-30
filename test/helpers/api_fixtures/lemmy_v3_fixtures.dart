/// Minimal Lemmy v3 API JSON fixtures guided by [spec/lemmy_0_19_11.json].
library;

Map<String, dynamic> lemmyV3User({int id = 7, String name = 'alice'}) => {
      'id': id,
      'name': name,
      'published': '2025-01-01T00:00:00Z',
      'actor_id': 'https://lemmy.test/u/$name',
      'instance_id': 1,
    };

Map<String, dynamic> lemmyV3Community({int id = 3, String name = 'news'}) => {
      'id': id,
      'name': name,
      'title': 'News',
      'published': '2025-01-01T00:00:00Z',
      'actor_id': 'https://lemmy.test/c/$name',
      'instance_id': 1,
    };

Map<String, dynamic> lemmyV3Post({int id = 42, String name = 'Hello Lemmy'}) => {
      'id': id,
      'name': name,
      'creator_id': 7,
      'community_id': 3,
      'published': '2025-06-01T12:00:00Z',
      'ap_id': 'https://lemmy.test/post/$id',
      'language_id': 1,
    };

Map<String, dynamic> lemmyV3PostView({int id = 42, String name = 'Hello Lemmy', bool hidden = false}) => {
      'post': lemmyV3Post(id: id, name: name),
      'creator': lemmyV3User(),
      'community': lemmyV3Community(),
      'counts': {'comments': 2, 'score': 10, 'upvotes': 12, 'downvotes': 2},
      'subscribed': 'NotSubscribed',
      'hidden': hidden,
    };

Map<String, dynamic> lemmyV3CommentView({int id = 99}) => {
      'comment': {
        'id': id,
        'post_id': 42,
        'creator_id': 7,
        'content': 'Nice post',
        'published': '2025-06-01T13:00:00Z',
        'ap_id': 'https://lemmy.test/comment/$id',
        'path': '0.$id',
        'language_id': 1,
      },
      'creator': lemmyV3User(),
      'counts': {'score': 3, 'upvotes': 4, 'downvotes': 1},
    };

Map<String, dynamic> lemmyV3SiteResponse({String version = '0.19.11'}) => {
      'version': version,
      'site_view': {
        'site': {
          'name': 'Test Site',
          'actor_id': 'https://lemmy.test',
          'icon': 'https://lemmy.test/icon.png',
        },
        'local_site': {'enable_downvotes': true},
        'counts': {'users': 100},
      },
      'all_languages': [],
      'discussion_languages': [],
      'taglines': [],
    };

Map<String, dynamic> lemmyV3PostListResponse({List<Map<String, dynamic>>? posts}) => {
      'posts': posts ?? [lemmyV3PostView()],
    };

Map<String, dynamic> lemmyV3PostReportView({int reportId = 5, bool resolved = false}) => {
      'post_report': {'id': reportId, 'reason': 'spam', 'resolved': resolved},
      'post': lemmyV3Post(),
      'post_creator': lemmyV3User(),
      'creator': lemmyV3User(id: 8, name: 'reporter'),
      'community': lemmyV3Community(),
      'counts': {'comments': 0, 'score': 0, 'upvotes': 0, 'downvotes': 0},
      'subscribed': 'NotSubscribed',
    };

Map<String, dynamic> lemmyV3CommentReportView({int reportId = 6, bool resolved = false}) => {
      'comment_report': {'id': reportId, 'reason': 'rule violation', 'resolved': resolved},
      'comment': lemmyV3CommentView()['comment'],
      'comment_creator': lemmyV3User(),
      'creator': lemmyV3User(id: 8, name: 'reporter'),
      'post': lemmyV3Post(),
      'community': lemmyV3Community(),
      'counts': {'score': 0, 'upvotes': 0, 'downvotes': 0},
    };

Map<String, dynamic> lemmyV3RemovedPostModlogEvent() => {
      'mod_remove_post': {
        'when_': '2025-06-01T14:00:00Z',
        'reason': 'spam',
        'removed': true,
      },
      'moderator': lemmyV3User(id: 2, name: 'mod'),
      'post': lemmyV3Post(),
      'community': lemmyV3Community(),
    };

Map<String, dynamic> lemmyV3PrivateMessageView({
  int id = 1,
  int creatorId = 7,
  int recipientId = 42,
  String content = 'Hello',
}) =>
    {
      'private_message': {
        'id': id,
        'creator_id': creatorId,
        'recipient_id': recipientId,
        'content': content,
        'deleted': false,
        'read': false,
        'published': '2025-06-01T12:00:00Z',
      },
      'creator': lemmyV3User(id: creatorId),
      'recipient': lemmyV3User(id: recipientId, name: 'bob'),
    };
