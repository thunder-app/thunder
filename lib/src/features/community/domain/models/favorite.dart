/// A locally favorited community for an account.
class Favorite {
  final String id;
  final int communityId;
  final String accountId;

  const Favorite({required this.id, required this.communityId, required this.accountId});

  Favorite copyWith({String? id}) => Favorite(id: id ?? this.id, communityId: communityId, accountId: accountId);
}
