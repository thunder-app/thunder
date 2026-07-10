/// A community stored for anonymous local subscriptions.
class LocalCommunity {
  final int id;
  final String name;
  final String title;
  final String actorId;
  final String? icon;

  const LocalCommunity({required this.id, required this.name, required this.title, required this.actorId, this.icon});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "title": title,
      "actorId": actorId,
      "icon": icon,
    };
  }
}
