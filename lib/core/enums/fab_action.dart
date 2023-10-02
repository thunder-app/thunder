import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/global_context.dart';

enum FeedFabAction {
  openFab(),
  backToTop(),
  subscriptions(),
  changeSort(),
  refresh(),
  dismissRead(),
  newPost();

  IconData get icon {
    switch (this) {
      case FeedFabAction.openFab:
        return Icons.more_horiz_rounded;
      case FeedFabAction.backToTop:
        return Icons.arrow_upward;
      case FeedFabAction.subscriptions:
        return Icons.people_rounded;
      case FeedFabAction.changeSort:
        return Icons.sort_rounded;
      case FeedFabAction.refresh:
        return Icons.refresh_rounded;
      case FeedFabAction.dismissRead:
        return Icons.clear_all_rounded;
      case FeedFabAction.newPost:
        return Icons.add_rounded;
    }
  }

  String get title {
    switch (this) {
      case FeedFabAction.openFab:
        return AppLocalizations.of(GlobalContext.context)!.open;
      case FeedFabAction.backToTop:
        return AppLocalizations.of(GlobalContext.context)!.backToTop;
      case FeedFabAction.subscriptions:
        return AppLocalizations.of(GlobalContext.context)!.subscriptions;
      case FeedFabAction.changeSort:
        return AppLocalizations.of(GlobalContext.context)!.changeSort;
      case FeedFabAction.refresh:
        return AppLocalizations.of(GlobalContext.context)!.refresh;
      case FeedFabAction.dismissRead:
        return AppLocalizations.of(GlobalContext.context)!.dismissRead;
      case FeedFabAction.newPost:
        return AppLocalizations.of(GlobalContext.context)!.createPost;
    }
  }
}

enum PostFabAction {
  openFab(),
  backToTop(),
  changeSort(),
  replyToPost(),
  refresh();

  IconData getIcon({IconData? override, bool postLocked = false}) {
    if (override != null) {
      return override;
    }

    switch (this) {
      case PostFabAction.openFab:
        return Icons.more_horiz_rounded;
      case PostFabAction.backToTop:
        return Icons.arrow_upward;
      case PostFabAction.changeSort:
        return Icons.sort_rounded;
      case PostFabAction.replyToPost:
        if (postLocked) {
          return Icons.lock;
        }
        return Icons.reply_rounded;
      case PostFabAction.refresh:
        return Icons.refresh_rounded;
    }
  }

  String getTitle(BuildContext context, {bool postLocked = false}) {
    switch (this) {
      case PostFabAction.openFab:
        return AppLocalizations.of(context)!.open;
      case PostFabAction.backToTop:
        return AppLocalizations.of(context)!.backToTop;
      case PostFabAction.changeSort:
        return AppLocalizations.of(context)!.changeSort;
      case PostFabAction.replyToPost:
        if (postLocked) {
          return AppLocalizations.of(context)!.postLocked;
        }
        return AppLocalizations.of(context)!.replyToPost;
      case PostFabAction.refresh:
        return AppLocalizations.of(context)!.refresh;
    }
  }

  void execute({BuildContext? context, void Function()? override, PostViewMedia? postView, int? postId, int? selectedCommentId, String? selectedCommentPath}) {
    if (override != null) {
      override();
    }

    switch (this) {
      case PostFabAction.openFab:
        context?.read<ThunderBloc>().add(const OnFabToggle(true));
      case PostFabAction.backToTop:
        // Invoked via override
        break;
      case PostFabAction.changeSort:
        // Invoked via override
        break;
      case PostFabAction.replyToPost:
        // Invoked via override
        break;
      case PostFabAction.refresh:
        context?.read<PostBloc>().add(GetPostEvent(postView: postView, postId: postId, selectedCommentId: selectedCommentId, selectedCommentPath: selectedCommentPath));
    }
  }
}
