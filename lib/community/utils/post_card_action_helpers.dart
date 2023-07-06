import 'dart:io';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/pages/community_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/pages/user_page.dart';

enum PostCardAction { visitProfile, visitCommunity, sharePost, shareMedia, shareLink }

class ExtendedPostCardActions {
  const ExtendedPostCardActions({required this.postCardAction, required this.icon, required this.label});

  final PostCardAction postCardAction;
  final IconData icon;
  final String label;
}

const postCardActionItems = [
  ExtendedPostCardActions(
    postCardAction: PostCardAction.visitCommunity,
    icon: Icons.home_work_rounded,
    label: 'Visit Community',
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.visitProfile,
    icon: Icons.person_search_rounded,
    label: 'Visit User Profile',
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.sharePost,
    icon: Icons.share_rounded,
    label: 'Share Post',
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.shareMedia,
    icon: Icons.image_rounded,
    label: 'Share Media',
  ),
  ExtendedPostCardActions(
    postCardAction: PostCardAction.shareLink,
    icon: Icons.link_rounded,
    label: 'Share Link',
  )
];

void showPostActionBottomModalSheet(BuildContext context, PostViewMedia postViewMedia) {
  final theme = Theme.of(context);

  showModalBottomSheet<void>(
    showDragHandle: true,
    context: context,
    builder: (BuildContext bottomSheetContext) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Actions',
                  style: theme.textTheme.titleLarge!.copyWith(),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: postCardActionItems.length,
              itemBuilder: (BuildContext itemBuilderContext, int index) {
                if (postCardActionItems[index].postCardAction == PostCardAction.shareLink && (postViewMedia.media.isEmpty || (postViewMedia.media.first.mediaType != MediaType.link && postViewMedia.media.first.mediaType != MediaType.image))) {
                  return Container();
                }

                if (postCardActionItems[index].postCardAction == PostCardAction.shareMedia && (postViewMedia.media.isEmpty || postViewMedia.media.first.mediaUrl == null)) {
                  return Container();
                }

                return ListTile(
                  title: Text(
                    postCardActionItems[index].label,
                    style: theme.textTheme.bodyMedium,
                  ),
                  leading: Icon(postCardActionItems[index].icon),
                  onTap: () async {
                    Navigator.of(context).pop();

                    PostCardAction postCardAction = postCardActionItems[index].postCardAction;

                    switch (postCardAction) {
                      case PostCardAction.visitCommunity:
                        onTapCommunityName(context, postViewMedia.postView.community.id);
                        break;
                      case PostCardAction.visitProfile:
                        AccountBloc accountBloc = context.read<AccountBloc>();
                        AuthBloc authBloc = context.read<AuthBloc>();
                        ThunderBloc thunderBloc = context.read<ThunderBloc>();

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: accountBloc),
                                BlocProvider.value(value: authBloc),
                                BlocProvider.value(value: thunderBloc),
                              ],
                              child: UserPage(userId: postViewMedia.postView.post.creatorId),
                            ),
                          ),
                        );
                        break;
                      case PostCardAction.sharePost:
                        Share.share(postViewMedia.postView.post.apId);
                        break;
                      case PostCardAction.shareMedia:
                        if (postViewMedia.media.first.mediaUrl != null) {
                          // Figure out where we're going to store the media temporarily
                          final filename = basename(postViewMedia.media.first.mediaUrl!);
                          final tempDirectoryPath = (await getTemporaryDirectory()).path;
                          final temporaryMediaPath = '$tempDirectoryPath/$filename';

                          // Download the media
                          final media = await http.get(Uri.parse(postViewMedia.media.first.mediaUrl!));
                          await File(temporaryMediaPath).writeAsBytes(media.bodyBytes);
                          
                          // Share
                          await Share.shareXFiles([XFile(temporaryMediaPath)]);
                          
                          // Delete the temp file
                          await File(temporaryMediaPath).delete();
                        }
                        break;
                      case PostCardAction.shareLink:
                        if (postViewMedia.media.first.originalUrl != null) Share.share(postViewMedia.media.first.originalUrl!);
                        break;
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      );
    },
  );
}

void onTapCommunityName(BuildContext context, int communityId) {
  AccountBloc accountBloc = context.read<AccountBloc>();
  AuthBloc authBloc = context.read<AuthBloc>();
  ThunderBloc thunderBloc = context.read<ThunderBloc>();

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: accountBloc),
          BlocProvider.value(value: authBloc),
          BlocProvider.value(value: thunderBloc),
        ],
        child: CommunityPage(communityId: communityId),
      ),
    ),
  );
}
