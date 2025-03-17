import 'package:lemmy_api_client/v3.dart';

class ThunderCommunity {
  Community? community;

  ThunderCommunity(this.community);

  String get name => (community?.title.isNotEmpty == true ? community?.title : community?.name) ?? '';

  bool get locked => community?.postingRestrictedToMods ?? false;

  String? get icon => community?.icon;
}
