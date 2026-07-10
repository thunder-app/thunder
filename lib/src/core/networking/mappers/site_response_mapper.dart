import 'package:thunder/src/core/domain/models/thunder_community.dart';
import 'package:thunder/src/core/domain/models/thunder_language.dart';
import 'package:thunder/src/core/domain/models/thunder_local_user.dart';
import 'package:thunder/src/core/domain/models/thunder_my_user.dart';
import 'package:thunder/src/core/domain/models/thunder_site.dart';
import 'package:thunder/src/core/domain/models/thunder_site_response.dart';
import 'package:thunder/src/core/domain/models/thunder_tagline.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';
import 'package:thunder/src/core/networking/mappers/primitive_mappers.dart';

ThunderSiteResponse lemmySiteResponse(Map<String, dynamic> response) {
  final myUser = response['my_user'];
  final allLanguages = response['all_languages'];
  final discussionLanguages = response['discussion_languages'];
  final taglines = response['taglines'];

  return ThunderSiteResponse(
    site: ThunderSite.fromLemmySiteView(response['site_view']),
    version: response['version'],
    myUser: myUser != null ? lemmyV3MyUser(myUser) : null,
    allLanguages: allLanguages.map<ThunderLanguage>((l) => ThunderLanguage.fromLemmyLanguage(l)).toList(),
    discussionLanguages: discussionLanguages.cast<int>(),
    taglines: taglines.map<ThunderTagline>((t) => ThunderTagline.fromLemmyTagline(t)).toList(),
  );
}

ThunderSiteResponse piefedSiteResponse(Map<String, dynamic> response) {
  final site = response['site'];
  final myUser = response['my_user'];
  final allLanguages = site?['all_languages'];
  final discussionLanguages = myUser?['discussion_languages'];

  return ThunderSiteResponse(
    site: ThunderSite.fromPiefedSite(site),
    version: response['version'],
    myUser: myUser != null ? piefedMyUser(myUser) : null,
    allLanguages: allLanguages.map<ThunderLanguage>((l) => ThunderLanguage.fromPiefedLanguage(l)).toList(),
    discussionLanguages: discussionLanguages?.map<int>((language) => language['id'] as int).toList(),
  );
}

ThunderSiteResponse lemmyV4SiteAndAccountResponse({
  required Map<String, dynamic> siteResponse,
  Map<String, dynamic>? accountResponse,
}) {
  final allLanguages = siteResponse['all_languages'] ?? const [];
  final discussionLanguages = siteResponse['discussion_languages'] ?? const [];
  final taglines = siteResponse['taglines'] ?? const [];

  return ThunderSiteResponse(
    site: ThunderSite.fromLemmyV4SiteView(siteResponse['site_view']),
    version: siteResponse['version'],
    myUser: accountResponse != null ? lemmyV4MyUser(accountResponse) : null,
    allLanguages: allLanguages.map<ThunderLanguage>((l) => ThunderLanguage.fromLemmyLanguage(l)).toList(),
    discussionLanguages: discussionLanguages.cast<int>(),
    taglines: taglines.map<ThunderTagline>((t) => ThunderTagline.fromLemmyTagline(t)).toList(),
  );
}

ThunderLocalUserView piefedLocalUserView(Map<String, dynamic> localUserView) {
  const mapper = PiefedPrimitiveMapper();
  return ThunderLocalUserView(
    localUser: ThunderLocalUser.fromPiefedLocalUser(localUserView['local_user']),
    person: mapper.user(localUserView['person']),
  );
}

ThunderMyUser lemmyV3MyUser(Map<String, dynamic> myUser) {
  final follows = myUser['follows'];
  final moderates = myUser['moderates'];
  final communityBlocks = myUser['community_blocks'];
  final instanceBlocks = myUser['instance_blocks'];
  final personBlocks = myUser['person_blocks'];
  final discussionLanguages = myUser['discussion_languages'];

  const mapper = LemmyV3PrimitiveMapper();

  return ThunderMyUser(
    localUserView: localUserViewFromLemmyV3(myUser['local_user_view']),
    follows: follows.map<ThunderCommunity>((cfv) => mapper.community(cfv['community'])).toList(),
    moderates: moderates.map<ThunderCommunity>((cmv) => mapper.community(cmv['community'])).toList(),
    communityBlocks: communityBlocks.map<ThunderCommunity>((cbv) => mapper.community(cbv['community'])).toList(),
    instanceBlocks: instanceBlocks.map<ThunderInstanceBlock>((ibv) => ThunderInstanceBlock(instance: ibv['instance'])).toList(),
    personBlocks: personBlocks.map<ThunderUser>((pbv) => mapper.user(pbv['target'])).toList(),
    discussionLanguages: discussionLanguages?.cast<int>(),
  );
}

ThunderMyUser lemmyV4MyUser(Map<String, dynamic> myUser) {
  const mapper = LemmyV4PrimitiveMapper();
  final follows = myUser['follows'] ?? const [];
  final moderates = myUser['moderates'] ?? const [];
  final communityBlocks = myUser['community_blocks'] ?? const [];
  final personBlocks = myUser['person_blocks'] ?? const [];
  final discussionLanguages = myUser['discussion_languages'];

  return ThunderMyUser(
    localUserView: localUserViewFromLemmyV4(myUser['local_user_view']),
    follows: follows.map<ThunderCommunity>((cfv) => mapper.community(cfv['community'])).toList(),
    moderates: moderates.map<ThunderCommunity>((cmv) => mapper.community(cmv['community'])).toList(),
    communityBlocks: communityBlocks.map<ThunderCommunity>((cbv) => mapper.community(cbv['community'] ?? cbv)).toList(),
    instanceBlocks: const [],
    personBlocks: personBlocks.map<ThunderUser>((pbv) => mapper.user(pbv['target'] ?? pbv['person'] ?? pbv)).toList(),
    discussionLanguages: discussionLanguages?.cast<int>(),
  );
}

ThunderMyUser piefedMyUser(Map<String, dynamic> myUser) {
  final follows = myUser['follows'];
  final moderates = myUser['moderates'];
  final communityBlocks = myUser['community_blocks'];
  final discussionLanguages = myUser['discussion_languages'];
  final instanceBlocks = myUser['instance_blocks'];
  final personBlocks = myUser['person_blocks'];
  final localUserView = myUser['local_user_view'];

  const mapper = PiefedPrimitiveMapper();

  return ThunderMyUser(
    localUserView: piefedLocalUserView(localUserView),
    follows: follows.map<ThunderCommunity>((f) => mapper.community(f['community'])).toList(),
    moderates: moderates.map<ThunderCommunity>((m) => mapper.community(m['community'])).toList(),
    communityBlocks: communityBlocks.map<ThunderCommunity>((b) => mapper.community(b['community'])).toList(),
    instanceBlocks: instanceBlocks.map<ThunderInstanceBlock>((b) => ThunderInstanceBlock(instance: b['instance'])).toList(),
    personBlocks: personBlocks.map<ThunderUser>((b) => mapper.user(b['target'])).toList(),
    discussionLanguages: discussionLanguages?.map<int>((language) => language['id'] as int).toList(),
  );
}
