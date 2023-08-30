import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

Future<int?> fetchTotalCommunitySubscriberCount(CommunityView community) async {
  try {
    return (await LemmyClient.runWithInstance(community.community.instanceHost, GetCommunity(id: community.community.id))).communityView.counts.subscribers;
  } catch (e) {
    // This is a very non-serious error, so we'll just return null.
    return null;
  }
}
