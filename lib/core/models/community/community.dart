import 'package:lemmy_api_client/v3.dart';

class Community {
  final int id;

  final String name;

  final String title;

  final String? description;

  final bool removed;

  final DateTime published;

  final DateTime? updated;

  final bool deleted;

  final bool nsfw;

  final String actorId;

  final bool local;

  final String? icon;

  final String? banner;

  final bool hidden;

  final bool postingRestrictedToMods;

  final int instanceId;

  final CommunityVisibility? visibility;

  const Community({
    required this.id, // v0.18.0
    required this.name, // v0.18.0
    required this.title, // v0.18.0
    this.description, // v0.18.0
    required this.removed, // v0.18.0
    required this.published, // v0.18.0
    this.updated, // v0.18.0
    required this.deleted, // v0.18.0
    required this.nsfw, // v0.18.0
    required this.actorId, // v0.18.0
    required this.local, // v0.18.0
    this.icon, // v0.18.0
    this.banner, // v0.18.0
    required this.hidden, // v0.18.0
    required this.postingRestrictedToMods, // v0.18.0
    required this.instanceId, // v0.18.0
    this.visibility, // v0.19.4 (required)
  });
}
