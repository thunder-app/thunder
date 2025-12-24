// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get accept => 'Accept';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get accessibilityProfilesDescription =>
      'Accessibility profiles allows applying several settings at once to accommodate a particular accessibility requirement.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Accounts',
      one: 'Account',
      zero: 'Account',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'Account Birthday $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'Your account settings override the following settings';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'Lemmy account settings exported successfully to $savedFilePath!';
  }

  @override
  String get accountSettingsImportedSuccessfully =>
      'Lemmy account settings imported successfully!';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return 'The selected comment was not found on \'$instance\'';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'The selected post was not found on \'$instance\'';
  }

  @override
  String get actionColors => 'Action Colors';

  @override
  String get actionColorsRedirect => 'Looking to customize colors?';

  @override
  String get actions => 'Actions';

  @override
  String get active => 'Active';

  @override
  String get activity => 'Activity';

  @override
  String get add => 'Add';

  @override
  String get addAccount => 'Add Account';

  @override
  String get addAccountToSeeProfile => 'Log in to see your account.';

  @override
  String get addAnonymousInstance => 'Add Anonymous Instance';

  @override
  String get addAsCommunityModerator => 'Add as Community Moderator';

  @override
  String get addDiscussionLanguage => 'Add Language';

  @override
  String get addKeywordFilter => 'Add Keyword';

  @override
  String get addOriginalPostBody => 'Add original post body?';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get addUserLabel => 'Add User Label';

  @override
  String get addedCommunityToSubscriptions => 'Subscribed to community';

  @override
  String get addedInstanceMod => 'Added Instance Mod';

  @override
  String get addedModToCommunity => 'Added Mod to Community';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return 'Added $username as community moderator';
  }

  @override
  String get admin => 'Admin';

  @override
  String get advanced => 'Advanced';

  @override
  String ago(Object time) {
    return '$time ago';
  }

  @override
  String get all => 'All';

  @override
  String get allPosts => 'All Posts';

  @override
  String get allowOpenSupportedLinks => 'Allow app to open supported links.';

  @override
  String get alreadyPostedTo => 'Already posted to';

  @override
  String get altText => 'Alt Text';

  @override
  String get alternateSources => 'Alternate Sources';

  @override
  String get always => 'Always';

  @override
  String andXMore(Object count) {
    return 'and $count more';
  }

  @override
  String get animations => 'Animations';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get anonymousInstances => 'Anonymous Instances';

  @override
  String get appLanguage => 'App Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get applePushNotificationService => 'Apple Push Notification Service';

  @override
  String get applied => 'Applied';

  @override
  String get apply => 'Apply';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return 'Notifications are allowed by system: $yesOrNo';
  }

  @override
  String averageComments(Object x) {
    return '$x comments/month';
  }

  @override
  String averageContributions(Object x) {
    return '$x contributions/month';
  }

  @override
  String averagePosts(Object x) {
    return '$x posts/month';
  }

  @override
  String get back => 'Back';

  @override
  String get backButton => 'Back button';

  @override
  String get backToTop => 'Back To Top';

  @override
  String get backgroundCheckWarning =>
      'Note that notification checks will consume additional battery';

  @override
  String get ban => 'Ban';

  @override
  String get banFromCommunity => 'Ban from Community';

  @override
  String get bannedUser => 'Banned User';

  @override
  String get bannedUserFromCommunity => 'Banned User from Community';

  @override
  String get base => 'Base';

  @override
  String get block => 'Block';

  @override
  String get blockCommunity => 'Block Community';

  @override
  String get blockCommunityInstance => 'Block Community Instance';

  @override
  String get blockInstance => 'Block Instance';

  @override
  String get blockManagement => 'Block Management';

  @override
  String get blockSettingLabel => 'User/Community/Instance Blocks';

  @override
  String get blockUser => 'Block User';

  @override
  String get blockUserInstance => 'Block User Instance';

  @override
  String get blockedCommunities => 'Blocked Communities';

  @override
  String get blockedInstances => 'Blocked Instances';

  @override
  String get blockedUsers => 'Blocked Users';

  @override
  String get blue => 'Blue';

  @override
  String get bold => 'Bold';

  @override
  String get boldCommunityName => 'Bold Community Name';

  @override
  String get boldInstanceName => 'Bold Instance Name';

  @override
  String get boldUserName => 'Bold User Name';

  @override
  String get bot => 'Bot';

  @override
  String get browserMode => 'Link handling';

  @override
  String browsingAnonymously(Object instance) {
    return 'You are currently browsing $instance anonymously.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get cannotReportOwnComment =>
      'You may not submit a report for your own comment.';

  @override
  String get cantBlockAdmin => 'You may not block an instance administrator.';

  @override
  String get cantBlockYourself => 'You may not block yourself.';

  @override
  String get cardPostCardMetadataItems => 'Card View Metadata';

  @override
  String get cardView => 'Card View';

  @override
  String get cardViewDescription => 'Enable card view to adjust settings';

  @override
  String get cardViewSettings => 'Card View Settings';

  @override
  String get changeAccountSettingsFor => 'Change account settings for';

  @override
  String get changeNotificationSettings => 'Change notification settings...';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordWarning =>
      'To change your password, you will be redirected to your instance site. \n\nAre you sure you want to continue?';

  @override
  String get changeSort => 'Change Sort';

  @override
  String clearCache(Object cacheSize) {
    return 'Clear Cache ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Clear Cache';

  @override
  String get clearDatabase => 'Clear Database';

  @override
  String get clearPreferences => 'Clear Preferences';

  @override
  String get clearSearch => 'Clear Search';

  @override
  String get clearedCache => 'Cleared cache successfully.';

  @override
  String get clearedDatabase =>
      'Local database cleared. Restart Thunder for new changes to take effect.';

  @override
  String get clearedUserPreferences => 'Cleared all user preferences';

  @override
  String get close => 'Close';

  @override
  String get collapse => 'Collapse';

  @override
  String get collapseCommentPreview => 'Collapse Comment Preview';

  @override
  String get collapseInformation => 'Collapse Information';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Hide Parent Comment when Collapsed';

  @override
  String get collapsePost => 'Collapse post';

  @override
  String get collapsePostPreview => 'Collapse Post Preview';

  @override
  String get collapseSpoiler => 'Collapse Spoiler';

  @override
  String get color => 'Color';

  @override
  String get colorizeCommunityName => 'Colorize Community Name';

  @override
  String get colorizeInstanceName => 'Colorize Instance Name';

  @override
  String get colorizeUserName => 'Colorize User Name';

  @override
  String get colors => 'Colors';

  @override
  String get combineCommentScores => 'Combine Comment Scores';

  @override
  String get combineCommentScoresLabel => 'Combine Comment Scores';

  @override
  String get combineNavAndFab => 'Combine FAB and Navigation Buttons';

  @override
  String get combineNavAndFabDescription =>
      'Floating Action Button will be shown between navigation buttons.';

  @override
  String get comfortable => 'Comfortable';

  @override
  String get comment => 'Comment';

  @override
  String get commentActions => 'Comment Actions';

  @override
  String get commentBehaviourSettings => 'Comments';

  @override
  String get commentFontScale => 'Comment Content Font Scale';

  @override
  String get commentPreview =>
      'Show a preview of the comments with the given settings';

  @override
  String get commentReported => 'The comment has been marked for review.';

  @override
  String get commentSavedAsDraft => 'Comment saved as draft';

  @override
  String get commentShowUserAvatar => 'Show User Avatar';

  @override
  String get commentShowUserInstance => 'Show User Instance';

  @override
  String get commentSortType => 'Comment Sort Type';

  @override
  String get commentSwipeActions => 'Comment Swipe Actions';

  @override
  String get commentSwipeGesturesHint =>
      'Looking to use buttons instead? Enable them in the comments section in general settings.';

  @override
  String get comments => 'Comments';

  @override
  String get communities => 'Communities';

  @override
  String get community => 'Community';

  @override
  String get communityActions => 'Community Actions';

  @override
  String communityEntry(Object community) {
    return 'Community \'$community\'';
  }

  @override
  String get communityFormat => 'Community Format';

  @override
  String get communityNameColor => 'Community Name Color';

  @override
  String get communityNameThickness => 'Community Name Thickness';

  @override
  String get communityStyle => 'Community Style';

  @override
  String get compact => 'Compact';

  @override
  String get compactPostCardMetadataItems => 'Compact View Metadata';

  @override
  String get compactView => 'Compact View';

  @override
  String get compactViewDescription => 'Enable compact view to adjust settings';

  @override
  String get compactViewSettings => 'Compact View Settings';

  @override
  String get condensed => 'Condensed';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmLogOutBody => 'Are you sure you want to log out?';

  @override
  String get confirmLogOutTitle => 'Log Out?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Are you sure you want to mark all replies, mentions, and messages as read?';

  @override
  String get confirmMarkAllAsReadTitle => 'Mark all as read?';

  @override
  String get confirmResetCommentPreferences =>
      'This will reset all comment preferences. Are you sure you want to proceed?';

  @override
  String get confirmResetPostPreferences =>
      'This will reset all post preferences. Are you sure you want to proceed?';

  @override
  String get confirmUnsubscription => 'Are you sure you want to unsubscribe?';

  @override
  String connectedToUnifiedPushDistributorApp(Object app) {
    return 'Conected to $app';
  }

  @override
  String get contentManagement => 'Content Management';

  @override
  String get contentWarning => 'Content Warning';

  @override
  String get controversial => 'Controversial';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get copyComment => 'Copy Comment';

  @override
  String get copySelected => 'Copy selected';

  @override
  String get copyText => 'Copy Text';

  @override
  String get couldNotDetermineCommentDelete =>
      'Error: Could not determine post to delete the comment.';

  @override
  String get couldNotDeterminePostComment =>
      'Error: Could not determine post to comment to.';

  @override
  String get couldntCreateReport =>
      'Your comment report could not be submitted at this time. Please try again later';

  @override
  String get couldntFindPost =>
      'Unable to load the requested post. It may have been deleted or removed.';

  @override
  String countComments(Object count) {
    return '$count Comments';
  }

  @override
  String countLocalSubscribers(Object count) {
    return '$count Local Subscribers';
  }

  @override
  String countPosts(Object count) {
    return '$count Posts';
  }

  @override
  String countSubscribers(Object count) {
    return '$count Subscribers';
  }

  @override
  String countUsers(Object count) {
    return '$count users';
  }

  @override
  String countUsersActiveDay(Object count) {
    return '$count users/day';
  }

  @override
  String countUsersActiveHalfYear(Object count) {
    return '$count users/6 mo';
  }

  @override
  String countUsersActiveMonth(Object count) {
    return '$count users/mo';
  }

  @override
  String countUsersActiveWeek(Object count) {
    return '$count users/wk';
  }

  @override
  String get createAccount => 'Create Account';

  @override
  String get createComment => 'Create Comment';

  @override
  String get createNewCrossPost => 'Create new cross-post';

  @override
  String get createPost => 'Create Post';

  @override
  String created(Object date) {
    return 'Created $date';
  }

  @override
  String get createdToday => 'Created Today';

  @override
  String get creator => 'Creator';

  @override
  String crossPostedFrom(Object postUrl) {
    return 'cross-posted from: $postUrl';
  }

  @override
  String get crossPostedTo => 'Cross-posted to';

  @override
  String get currentLongPress => 'Currently set as long press';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Current notifications mode: $mode';
  }

  @override
  String get currentSinglePress => 'Currently set as single press';

  @override
  String get customizeSwipeActions => 'Customize swipe actions (tap to change)';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get dark => 'Dark';

  @override
  String get databaseExportWarning =>
      'The database may contain sensitive information related to your Lemmy account. If you export it, you should not share it with anyone. Do you want to proceed?';

  @override
  String databaseExportedSuccessfully(Object savedFilePath) {
    return 'The database was successfully exported to \'$savedFilePath\'';
  }

  @override
  String get databaseImportedSuccessfully =>
      'The database was imported successfully!';

  @override
  String get databaseNotExportedSuccessfully =>
      'The database was not exported successfully or the operation was canceled.';

  @override
  String get databaseNotImportedSuccessfully =>
      'The database was not imported successfully, or the operation was canceled.';

  @override
  String get dateFormat => 'Date Format';

  @override
  String get debug => 'Debug';

  @override
  String get debugDescription =>
      'The following debug settings should only be used for troubleshooting purposes.';

  @override
  String get debugNotificationsDescription =>
      'Use the following options to troubleshoot issues related to notifications.';

  @override
  String get decline => 'Decline';

  @override
  String get defaultColor => 'Default';

  @override
  String get defaultCommentSortType => 'Default Comment Sort Type';

  @override
  String get defaultFeedSortType => 'Default Feed Sort Type';

  @override
  String get defaultFeedType => 'Default Feed Type';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountDescription =>
      'To permanently delete your account, you will be redirected to your instance site. \n\nAre you sure you want to continue?';

  @override
  String get deleteComment => 'Delete Comment';

  @override
  String get deleteImageConfirmMessage =>
      'Are you sure you want to delete this image?';

  @override
  String get deleteImageConfirmTitle => 'Delete?';

  @override
  String get deleteLocalDatabase => 'Delete Local Database';

  @override
  String get deleteLocalDatabaseDescription =>
      'This action will remove the local database and will log you out of all your accounts.\n\nAre you sure you want to continue?';

  @override
  String get deleteLocalPreferences => 'Delete Local Preferences';

  @override
  String get deleteLocalPreferencesDescription =>
      'This will clear all your user preferences and settings in Thunder.\n\nDo you want to continue?';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get deleteUserLabelConfirmation =>
      'Are you sure you want to delete the label?';

  @override
  String get deleted => 'Deleted';

  @override
  String get deletedByCreator => 'deleted by creator';

  @override
  String get deletedByModerator => 'deleted by moderator';

  @override
  String get deletedComment => 'Deleted comment';

  @override
  String get deletedPost => 'Deleted post';

  @override
  String get deselectUndeterminedWarning =>
      'If you deselect Undetermined, you will not see most content.';

  @override
  String detailedReason(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get dimReadPosts => 'Dim Read Posts';

  @override
  String get disable => 'Disable';

  @override
  String get disablePushNotifications => 'Disable Push Notifications';

  @override
  String get disabled => 'Disabled';

  @override
  String get discussionLanguages => 'Discussion Languages';

  @override
  String get discussionLanguagesTooltip =>
      'Content is filtered to the selected languages.';

  @override
  String get dismissRead => 'Dismiss Read';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayUserScore => 'Display User Scores (Karma).';

  @override
  String get dividerAppearance => 'Divider Appearance';

  @override
  String get doNotShowAgain => 'Do Not Show Again';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Found multiple compatible apps; please install only one';

  @override
  String get downloadingMedia => 'Downloading media to share…';

  @override
  String get downvote => 'Downvote';

  @override
  String get downvoteColor => 'Downvote Color';

  @override
  String get downvoted => 'Downvoted';

  @override
  String get downvotesDisabled => 'Downvotes are turned off on this instance.';

  @override
  String get edit => 'Edit';

  @override
  String get editComment => 'Edit Comment';

  @override
  String get editPost => 'Edit Post';

  @override
  String get email => 'Email';

  @override
  String get empty => 'Empty';

  @override
  String get emptyInbox => 'Empty Inbox';

  @override
  String get emptyUri =>
      'The link is empty. Please provide a valid dynamic link to proceed.';

  @override
  String get enableCommentNavigation => 'Enable Comment Navigation';

  @override
  String get enableExperimentalFeatures => 'Enable experimental features';

  @override
  String get enableFeedFab => 'Enable Floating Button on Feeds';

  @override
  String get enableFloatingButtonOnFeeds => 'Enable Floating Button On Feeds';

  @override
  String get enableFloatingButtonOnPosts => 'Enable Floating Button On Posts';

  @override
  String get enableInboxNotifications => 'Enable Inbox Notifications';

  @override
  String get enablePostFab => 'Enable Floating Button on Posts';

  @override
  String get endOfComments => 'End of comments';

  @override
  String get endSearch => 'End Search';

  @override
  String errorDeletingImage(Object error) {
    return 'There was an error deleting the image: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Could not download the media file to share: $errorMessage';
  }

  @override
  String get errorImportingAccountSettings =>
      'There was an error importing the settings. The file might not be in the right format.';

  @override
  String get errorInitializingClient => 'Error initializing client';

  @override
  String get errorLoadingAccountSettings =>
      'There was an error loading the settings file or the operation was canceled.';

  @override
  String get errorMarkingReplyRead =>
      'There was an error marking the reply as read.';

  @override
  String get errorMarkingReplyUnread =>
      'There was an error marking the reply as unread.';

  @override
  String get errorNoActiveInstance => 'No active instance found';

  @override
  String get errorParsingJson =>
      'There was an error parsing the selected file. It may not be valid JSON.';

  @override
  String get errorSavingAccountSettings =>
      'There was an error saving the settings file or the operation was canceled.';

  @override
  String get exceptionProcessingUri =>
      'An error occurred while processing the link. It may not be available on your instance.';

  @override
  String get excessiveApiCallsWarning =>
      'Your feed may be taking a while to load due to keyword filters.';

  @override
  String get expand => 'Expand';

  @override
  String get expandCommentPreview => 'Expand Comment Preview';

  @override
  String get expandInformation => 'Expand Information';

  @override
  String get expandOptions => 'Expand options';

  @override
  String get expandPost => 'Expand post';

  @override
  String get expandPostPreview => 'Expand Post Preview';

  @override
  String get expandSpoiler => 'Expand Spoiler';

  @override
  String get expanded => 'Expanded';

  @override
  String get experimentalFeatures => 'Experimental Features';

  @override
  String get experimentalFeaturesDescription =>
      'These features are still in development and may be unstable. Use them at your own risk. You must restart Thunder to take effect.';

  @override
  String get exploreInstance => 'Explore instance';

  @override
  String get exportDatabase => 'Export Database';

  @override
  String get exportDatabaseSubtitle =>
      'The database contains info about accounts, favorites, anonymous subscriptions, and user labels.';

  @override
  String get exportLemmyAccountSettingsDescription =>
      'Export Lemmy account settings';

  @override
  String get exportSettingsSubtitle =>
      'The settings includes all of the preferences that you have configured in Thunder.';

  @override
  String get extraLarge => 'Extra Large';

  @override
  String failedToBlock(Object errorMessage) {
    return 'Failed to block: $errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return 'Failed to communicate with Thunder notification server at $serverAddress.';
  }

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return 'Could not load blocks: $errorMessage';
  }

  @override
  String get failedToLoadVideo => 'Failed to load video. Open link in browser?';

  @override
  String get failedToPerformAction => 'Failed to perform action';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'Could not unblock: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Failed to update notification settings';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Favorites';

  @override
  String get featuredPost => 'Featured Post';

  @override
  String get feed => 'Feed';

  @override
  String get feedBehaviourSettings => 'Feed';

  @override
  String get feedSettings => 'Feed Settings';

  @override
  String get feedTypeAndSorts => 'Default Feed Type and Sorting';

  @override
  String get fetchAccountError => 'Could not determine account';

  @override
  String filteringBy(Object entity) {
    return 'Filtering by $entity';
  }

  @override
  String get filters => 'Filters';

  @override
  String get floatingActionButton => 'Floating Action Button';

  @override
  String get floatingActionButtonInformation =>
      'Thunder has a fully customizable FAB experience that supports a few gestures.\n- Swipe up to reveal additional FAB actions\n- Swipe down/up to hide or reveal the FAB\n\nTo customize the main and secondary actions for the FAB, long press on one of the actions below.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'denotes the FAB\'s long-press action.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'denotes the FAB\'s single-press action.';

  @override
  String get fonts => 'Fonts';

  @override
  String get forward => 'Forward';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Found compatible app; restart Thunder to connect';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Swipe anywhere to go back when left-to-right gestures are disabled';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get fullscreenSwipeGestures => 'Fullscreen Swipe Gestures';

  @override
  String get general => 'General';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get gestures => 'Gestures';

  @override
  String get gettingStarted => 'Getting Started';

  @override
  String get green => 'Green';

  @override
  String get guestModeFeedSettings => 'Guest Mode Feed Settings';

  @override
  String get guestModeFeedSettingsLabel =>
      'The following settings are only applied to guest accounts. To adjust feed settings for your account, go to Account Settings.';

  @override
  String get havingIssuesWithNotifications =>
      'Having issues with notifications?';

  @override
  String get hidCommunity => 'Hid Community';

  @override
  String get hidden => 'Hidden';

  @override
  String get hide => 'Hide';

  @override
  String get hideBottomBarOnScroll => 'Hide Bottom Bar on Scroll';

  @override
  String get hideColor => 'Hide Color';

  @override
  String get hideNsfwPostsFromFeed => 'Hide NSFW Posts from Feed';

  @override
  String get hideNsfwPreviews => 'Blur NSFW Previews';

  @override
  String get hidePassword => 'Hide Password';

  @override
  String get hideThumbnails => 'Hide Thumbnails';

  @override
  String get hideTopBarOnScroll => 'Hide Top Bar on Scroll';

  @override
  String get hostInstance => 'Host Instance';

  @override
  String get hot => 'Hot';

  @override
  String get image => 'Image';

  @override
  String get imageCachingMode => 'Image Caching Mode';

  @override
  String get imageCachingModeAggressive =>
      'Aggressively cache images (uses more memory)';

  @override
  String get imageCachingModeAggressiveShort => 'Aggressive';

  @override
  String get imageCachingModeRelaxed =>
      'Let image caches expire (uses less memory but causes images to reload more often)';

  @override
  String get imageCachingModeRelaxedShort => 'Relaxed';

  @override
  String get imageDimensionTimeout => 'Image Dimension Timeout';

  @override
  String get imagePeekDuration => 'Image Peek Duration';

  @override
  String get imagePeekDurationDescription =>
      'Duration of long press before image peek is triggered';

  @override
  String get importDatabase => 'Import Database';

  @override
  String get importExportDatabase => 'Import/Export Thunder Database';

  @override
  String get importExportLemmyAccountSettings =>
      'Import/Export Lemmy Account Settings';

  @override
  String get importExportLemmyAccountSettingsSubtitle =>
      'Includes subscribed communities, blocklists, and account preferences';

  @override
  String get importExportSettings => 'Import/Export Settings';

  @override
  String get importExportThunderSettings => 'Import/Export Thunder Settings';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Import Lemmy account settings';

  @override
  String get importSettings => 'Import Settings';

  @override
  String inReplyTo(Object post, Object community) {
    return 'In reply to $post in $community';
  }

  @override
  String get in_ => 'in';

  @override
  String get inbox => 'Inbox';

  @override
  String get includeCommunity => 'Include Community';

  @override
  String get includeExternalLink => 'Include External Link';

  @override
  String get includeImage => 'Include Image';

  @override
  String get includePostLink => 'Include Post Link';

  @override
  String get includeText => 'Include Text';

  @override
  String get includeTitle => 'Include Title';

  @override
  String get information => 'Information';

  @override
  String instance(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Instances',
      one: 'Instance',
      zero: 'Instance',
    );
    return '$_temp0 ';
  }

  @override
  String get instanceActions => 'Instance Actions';

  @override
  String instanceEntry(Object username) {
    return 'Instance \'$username\'';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance has already been added.';
  }

  @override
  String get instanceNameColor => 'Instance Name Color';

  @override
  String get instanceNameThickness => 'Instance Name Thickness';

  @override
  String get instances => 'Instances';

  @override
  String get internetOrInstanceIssues =>
      'You may not be connected to the Internet, or your instance may be currently unavailable.';

  @override
  String get invalidUrl => 'Invalid URL format';

  @override
  String joined(Object x) {
    return 'Joined $x';
  }

  @override
  String get keywordFilterDescription =>
      'Filters posts containing any keywords in the title, body, or URL';

  @override
  String get keywordFilters => 'Keyword Filters';

  @override
  String get label => 'Label';

  @override
  String get language => 'Language';

  @override
  String get languageFilters => 'Looking for language filters?';

  @override
  String get languageNotAllowed =>
      'The community you are posting to does not allow posts in the language that you have selected. Try another language.';

  @override
  String get large => 'Large';

  @override
  String get leftLongSwipe => 'Left Long Swipe';

  @override
  String get leftShortSwipe => 'Left Short Swipe';

  @override
  String get light => 'Light';

  @override
  String link(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Links',
      one: 'Link',
      zero: 'Link',
    );
    return '$_temp0 ';
  }

  @override
  String get linkActions => 'Link Actions';

  @override
  String get linkHandlingCustomTabs => 'Open in system browser embedded in-app';

  @override
  String get linkHandlingCustomTabsShort => 'In-app embedded';

  @override
  String get linkHandlingExternal => 'Open in system browser externally';

  @override
  String get linkHandlingExternalShort => 'External';

  @override
  String get linkHandlingInApp => 'Use Thunder\'s built-in browser';

  @override
  String get linkHandlingInAppShort => 'In-app';

  @override
  String get linksBehaviourSettings => 'Links';

  @override
  String loadMorePlural(Object count) {
    return 'Load $count more replies…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Load $count more reply…';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get local => 'Local';

  @override
  String get localNotifications => 'Local Notifications';

  @override
  String get localOnly => 'Local Only';

  @override
  String get localPosts => 'Local Posts';

  @override
  String get lockPost => 'Lock Post';

  @override
  String get locked => 'Locked';

  @override
  String get lockedPost => 'Locked Post';

  @override
  String get logOut => 'Log out';

  @override
  String get login => 'Log in';

  @override
  String get loginAttemptCanceled => 'Login attempt canceled.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Could not log in. Please try again. (Error: $errorMessage)';
  }

  @override
  String get loginSucceeded => 'Logged in.';

  @override
  String get loginToPerformAction =>
      'You need to be logged in to carry out this task.';

  @override
  String get loginToSeeInbox => 'Log in to see your inbox';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Looking for account-specific feed settings?';

  @override
  String get malformedUri =>
      'The link you provided is in an unsupported format. Please make sure it\'s a valid link.';

  @override
  String get manageAccounts => 'Manage Accounts';

  @override
  String get manageMedia => 'Manage Media';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get markPostAsReadOnMediaView => 'Mark Read After Viewing Media';

  @override
  String get markPostAsReadOnScroll => 'Mark Read On Scroll';

  @override
  String get markReadColor => 'Mark Read/Unread Color';

  @override
  String get matrixUser => 'Matrix User';

  @override
  String get me => 'Me';

  @override
  String get media => 'Media';

  @override
  String get medium => 'Medium';

  @override
  String mention(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mentions',
      one: 'Mention',
      zero: 'Mention',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'Menu';

  @override
  String message(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Messages',
      one: 'Message',
      zero: 'Message',
    );
    return '$_temp0';
  }

  @override
  String get metadataFontScale => 'Metadata Font Scale';

  @override
  String get missingErrorMessage => 'No error message available';

  @override
  String get modAdd => 'Add/Remove Instance Moderators';

  @override
  String get modAddCommunity => 'Add/Remove Moderators to Communities';

  @override
  String get modBan => 'Ban/Unban Instance Users';

  @override
  String get modBanFromCommunity => 'Ban/Unban Users from Communities';

  @override
  String get modFeaturePost => 'Feature/Unfeature Posts';

  @override
  String get modLockPost => 'Lock/Unlock Posts';

  @override
  String get modRemoveComment => 'Remove/Restore Comments';

  @override
  String get modRemoveCommunity => 'Remove/Restore Communities';

  @override
  String get modRemovePost => 'Remove/Restore Posts';

  @override
  String get modTransferCommunity => 'Transferring Communities';

  @override
  String get moderatedCommunities => 'Moderated Communities';

  @override
  String get moderates => 'Moderates';

  @override
  String moderator(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moderators',
      one: 'Moderator',
      zero: 'Moderator',
    );
    return '$_temp0';
  }

  @override
  String get moderatorActions => 'Moderator Actions';

  @override
  String get modlog => 'Modlog';

  @override
  String get mostComments => 'Most Comments';

  @override
  String get mustBeLoggedIn => 'You need to be logged in';

  @override
  String get mustBeLoggedInComment => 'You need to be logged in to comment';

  @override
  String get mustBeLoggedInPost => 'You need to be logged in to create a post';

  @override
  String get names => 'Names';

  @override
  String get navbarDoubleTapGestures => 'Navbar Double Tap Gestures';

  @override
  String get navbarSwipeGestures => 'Navbar Swipe Gestures';

  @override
  String get navigateDown => 'Next comment';

  @override
  String get navigateUp => 'Previous comment';

  @override
  String get navigation => 'Navigation';

  @override
  String get nestedCommentIndicatorColor => 'Nested Comment Indicator Color';

  @override
  String get nestedCommentIndicatorStyle => 'Nested Comment Indicator Style';

  @override
  String get never => 'Never';

  @override
  String get newComments => 'New Comments';

  @override
  String get newPost => 'New Post';

  @override
  String get new_ => 'New';

  @override
  String get no => 'No';

  @override
  String get noAccountsAdded => 'No accounts have been added';

  @override
  String get noAnonymousInstances => 'No anonymous instances have been added';

  @override
  String get noCommentsFound => 'No comments found';

  @override
  String get noCommunitiesFound => 'No communities found';

  @override
  String get noCommunityBlocks => 'No blocked communities';

  @override
  String get noCompatibleAppFound => 'No compatible app found';

  @override
  String get noDiscussionLanguages => 'No content is hidden based on language.';

  @override
  String get noDisplayNameSet => 'No display name set';

  @override
  String get noEmailSet => 'No email set';

  @override
  String get noFavoritedCommunities => 'No favorited communities';

  @override
  String get noImages => 'It looks like you have not uploaded any images.';

  @override
  String get noInstanceBlocks => 'No blocked instances.';

  @override
  String get noItems => 'No items';

  @override
  String get noKeywordFilters => 'No keyword filters added';

  @override
  String get noLanguage => 'No language';

  @override
  String get noMatrixUserSet => 'No matrix user set';

  @override
  String get noMentions => 'No mentions';

  @override
  String get noMessages => 'No messages';

  @override
  String get noPostsFound => 'No posts found.';

  @override
  String get noProfileBioSet => 'No profile bio set';

  @override
  String get noReferencesToImage =>
      'No posts or comments were found containing this image. However, it may be used elsewhere on the internet.';

  @override
  String get noReplies => 'No replies';

  @override
  String get noResultsFound => 'No results found.';

  @override
  String get noSubscriptions => 'No Subscriptions';

  @override
  String get noUserBlocks => 'No blocked users.';

  @override
  String get noUserLabels => 'You have not created any user labels yet';

  @override
  String get noUsersFound => 'No users found.';

  @override
  String get noVisibleComments =>
      'Comments may not be visible because the community is blocked.';

  @override
  String get none => 'None';

  @override
  String get normal => 'Normal';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance does not appear to be a valid instance';
  }

  @override
  String get notValidUrl => 'Not a valid URL';

  @override
  String get nothingToShare => 'Nothing to share';

  @override
  String notifications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notifications',
      one: 'Notifications',
      zero: 'Notification',
    );
    return '$_temp0';
  }

  @override
  String get notificationsBehaviourSettings => 'Notifications';

  @override
  String get notificationsNotAllowed =>
      'Notifications are not allowed for Thunder in system settings';

  @override
  String get notificationsWarningDialog =>
      'Notifications are an **experimental feature** which may not function correctly on all devices.\n\n - Checks will occur every ~15 minutes and will consume additional battery.\n\n - Disable battery optimizations for a higher likelihood of successful notifications.\n\n See the following page for more information.';

  @override
  String get nsfw => 'NSFW';

  @override
  String get nsfwWarning => 'NSFW - Tap to reveal';

  @override
  String get off => 'off';

  @override
  String get offline => 'offline';

  @override
  String get ok => 'OK';

  @override
  String get old => 'Old';

  @override
  String get on => 'on';

  @override
  String get onWifi => 'On Wifi';

  @override
  String get onlyModsCanPostInCommunity =>
      'Only moderators may post in this community';

  @override
  String get open => 'Open';

  @override
  String get openAccountSwitcher => 'Open account switcher';

  @override
  String get openByDefault => 'Open by default';

  @override
  String get openInBrowser => 'Open in Browser';

  @override
  String get openInstance => 'Open Instance';

  @override
  String get openLinksInExternalBrowser => 'Open Links in External Browser';

  @override
  String get openLinksInReaderMode => 'Open Links in Reader Mode';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get orange => 'Orange';

  @override
  String get originalPoster => 'Original Poster';

  @override
  String get overview => 'Overview';

  @override
  String get password => 'Password';

  @override
  String get pending => 'Pending';

  @override
  String performedBy(Object user) {
    return 'Performed by: $user';
  }

  @override
  String get permissionDenied =>
      'Thunder has not been granted permission to display notifications. Please enable in system settings.';

  @override
  String get permissionDeniedMessage =>
      'Thunder requires some permissions in order to save this image which have been denied.';

  @override
  String get pinPostToCommunity => 'Pin Post to Community';

  @override
  String get pinToCommunity => 'Pin to Community';

  @override
  String get pinned => 'Pinned';

  @override
  String get pinnedPostToCommunity => 'Pinned post to community';

  @override
  String get placeholderText =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  @override
  String get post => 'Post';

  @override
  String get postActions => 'Post Actions';

  @override
  String get postBehaviourSettings => 'Posts';

  @override
  String get postBody => 'Post Body';

  @override
  String get postBodySettings => 'Post Body Settings';

  @override
  String get postBodySettingsDescription =>
      'These settings affect the display of the post body';

  @override
  String get postBodyShowCommunityInstance => 'Show Community Instance';

  @override
  String get postBodyShowUserInstance => 'Show User Instance';

  @override
  String get postBodyViewType => 'Post Body View Type';

  @override
  String get postContentFontScale => 'Post Content Font Scale';

  @override
  String get postCreatedSuccessfully => 'Post created successfully!';

  @override
  String get postLocked => 'Post locked. No replies allowed.';

  @override
  String get postMetadataInstructions =>
      'You can customize the metadata information by dragging and dropping the desired information';

  @override
  String get postNSFW => 'Mark as NSFW';

  @override
  String get postPreview =>
      'Show a preview of the post with the given settings';

  @override
  String get postSavedAsDraft => 'Post saved as draft';

  @override
  String get postShowUserInstance => 'Show User Instance';

  @override
  String get postSwipeActions => 'Post Swipe Actions';

  @override
  String get postSwipeGesturesHint =>
      'Looking to use buttons instead? Change what buttons appear on post cards in general settings.';

  @override
  String get postTitle => 'Title';

  @override
  String get postTitleFontScale => 'Post Title Font Scale';

  @override
  String get postTogglePreview => 'Toggle Preview';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Could not upload image';

  @override
  String get postViewType => 'Post View Type';

  @override
  String get posts => 'Posts';

  @override
  String get preview => 'Preview';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile applied successfully!';
  }

  @override
  String get profileBio => 'Profile Bio';

  @override
  String get profiles => 'Profiles';

  @override
  String get public => 'Public';

  @override
  String get pureBlack => 'Pure Black';

  @override
  String get purgedComment => 'Purged Comment';

  @override
  String get purgedCommunity => 'Purged Community';

  @override
  String get purgedPerson => 'Purged Person';

  @override
  String get purgedPost => 'Purged Post';

  @override
  String get purple => 'Purple';

  @override
  String get pushNotification => 'Push Notifications';

  @override
  String get pushNotificationDescription =>
      'If enabled, Thunder will send your JWT token(s) to the server in order to poll for new notifications. \n\n **NOTE:** This will not take effect until the next time the app is launched.';

  @override
  String get pushNotificationServer => 'Push Notification Server';

  @override
  String get pushNotificationServerDescription =>
      'Configure the push notification server. The server must be properly configured to send push notifications to your device.\n\n **Only enter a server that you trust with your credentials.**';

  @override
  String get rateLimitErrorMessage =>
      'You have hit the rate limit for this request. Please wait and try again later.';

  @override
  String get reachedTheBottom => 'No more items to load';

  @override
  String get read => 'Read';

  @override
  String get readAll => 'Read All';

  @override
  String get readerMode => 'Reader mode';

  @override
  String get reason => 'Reason';

  @override
  String get red => 'Red';

  @override
  String get reduceAnimations => 'Reduce Animations';

  @override
  String get reducesAnimations => 'Reduces the animations used within Thunder';

  @override
  String get refresh => 'Refresh';

  @override
  String get refreshContent => 'Refresh Content';

  @override
  String get removalReason => 'Removal Reason';

  @override
  String get remove => 'Remove';

  @override
  String get removeAccount => 'Remove Account';

  @override
  String get removeAsCommunityModerator => 'Remove as Community Moderator';

  @override
  String get removeComment => 'Remove Comment';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get removeInstance => 'Remove instance';

  @override
  String removeKeyword(Object keyword) {
    return 'Remove \"$keyword\"?';
  }

  @override
  String get removeKeywordFilter => 'Remove Keyword';

  @override
  String get removePost => 'Remove Post';

  @override
  String get removeUserData => 'Remove user data';

  @override
  String get removed => 'Removed';

  @override
  String get removedComment => 'Removed Comment';

  @override
  String get removedCommunity => 'Removed Community';

  @override
  String get removedCommunityFromSubscriptions => 'Unsubscribed from community';

  @override
  String get removedInstanceMod => 'Removed Instance Mod';

  @override
  String get removedModFromCommunity => 'Removed Mod from Community';

  @override
  String get removedPost => 'Removed Post';

  @override
  String removedUserAsCommunityModerator(Object username) {
    return 'Removed $username as community moderator';
  }

  @override
  String get reorder => 'Reorder';

  @override
  String reply(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Replies',
      one: 'Reply',
      zero: 'Reply',
    );
    return '$_temp0';
  }

  @override
  String get replyColor => 'Reply Color';

  @override
  String get replyNotSupported =>
      'Replying from this view is currently not supported yet';

  @override
  String get replyToPost => 'Reply to Post';

  @override
  String replyingTo(Object author) {
    return 'Replying to $author';
  }

  @override
  String report(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reports',
      one: 'Report',
      zero: 'Report',
    );
    return '$_temp0 ';
  }

  @override
  String get reportComment => 'Report Comment';

  @override
  String get reportPost => 'Report Post';

  @override
  String get reportedComment => 'Reported comment';

  @override
  String get reportedPost => 'Reported post';

  @override
  String get reporter => 'Reporter:';

  @override
  String get requiredField => '*required';

  @override
  String get reset => 'Reset';

  @override
  String get resetCommentPreferences => 'Reset comment preferences';

  @override
  String get resetPostPreferences => 'Reset post preferences';

  @override
  String get resetPreferences => 'Reset Preferences';

  @override
  String get resetPreferencesAndData => 'Reset Preferences and Data';

  @override
  String get restore => 'Restore';

  @override
  String get restoreComment => 'Restore Comment';

  @override
  String get restorePost => 'Restore Post';

  @override
  String get restoredComment => 'Restored comment';

  @override
  String get restoredCommentFromDraft => 'Restored comment from draft';

  @override
  String get restoredCommunity => 'Restored Community';

  @override
  String get restoredPost => 'Restored Post';

  @override
  String get restoredPostFromDraft => 'Restored post from draft';

  @override
  String get retry => 'Retry';

  @override
  String get rightLongSwipe => 'Right Long Swipe';

  @override
  String get rightShortSwipe => 'Right Short Swipe';

  @override
  String get save => 'Save';

  @override
  String get saveColor => 'Save Color';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get saved => 'Saved';

  @override
  String get scaled => 'Scaled';

  @override
  String get scrapeMissingLinkPreviews => 'Scrape Missing Link Previews';

  @override
  String get screenReaderProfile => 'Screen Reader Profile';

  @override
  String get screenReaderProfileDescription =>
      'Optimizes Thunder for screen readers by reducing overall elements and removing potentially conflicting gestures.';

  @override
  String get search => 'Search';

  @override
  String get searchByText => 'Search by text';

  @override
  String get searchByUrl => 'Search by URL';

  @override
  String get searchComments => 'Search Comments';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return 'Search for comments federated with $instance';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return 'Search for communities federated with $instance';
  }

  @override
  String searchInstance(Object instance) {
    return 'Search $instance';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return 'Search for instances federated with $instance';
  }

  @override
  String get searchPostSearchType => 'Select Post Search Type';

  @override
  String searchPostsFederatedWith(Object instance) {
    return 'Search for posts federated with $instance';
  }

  @override
  String get searchTerm => 'Search term';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Search for users federated with $instance';
  }

  @override
  String get selectAccountToCommentAs => 'Select account to comment as';

  @override
  String get selectAccountToPostAs => 'Select account to post as';

  @override
  String get selectAll => 'Select all';

  @override
  String get selectCommunity => 'Select a community (required)';

  @override
  String get selectFeedType => 'Select Feed Type';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectSearchType => 'Select Search Type';

  @override
  String get selectText => 'Select Text';

  @override
  String get sendBackgroundTestLocalNotification =>
      'Send background test local notification';

  @override
  String get sendBackgroundTestUnifiedPushNotification =>
      'Send background test UnifiedPush notification';

  @override
  String get sendTestLocalNotification => 'Send test local notification';

  @override
  String get sendTestUnifiedPushNotification =>
      'Send test UnifiedPush notification';

  @override
  String get sensitiveContentWarning =>
      'May contain sensitive content. Tap to reveal.';

  @override
  String get sentRequestForTestNotification =>
      'Sent request for test notification.';

  @override
  String serverErrorComments(Object message) {
    return 'A server error was encountered when fetching more comments: $message';
  }

  @override
  String get setAction => 'Set Action';

  @override
  String get setLongPress => 'Set as long-press action';

  @override
  String get setShortPress => 'Set as short-press action';

  @override
  String get settingOverrideLabel =>
      'These settings override Thunder\'s default settings.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'Settings of type $settingType are not yet supported.';
  }

  @override
  String get settings => 'Settings';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'Settings were successfully saved to \'$savedFilePath\'';
  }

  @override
  String get settingsFeedCards =>
      'These settings apply to the cards in the main feed, actions are always available when actually opening posts.';

  @override
  String get settingsImportedSuccessfully =>
      'Settings were imported successfully!';

  @override
  String get settingsNotExportedSuccessfully =>
      'Settings were not saved successfully, or the operation was canceled.';

  @override
  String get settingsNotImportedSuccessfully =>
      'Settings were not imported successfully or the operation was canceled.';

  @override
  String get settingsPage => 'Settings Page';

  @override
  String get settingsPageAbout => 'About';

  @override
  String get settingsPageAccessibility => 'Accessibility';

  @override
  String get settingsPageAccount => 'Account';

  @override
  String get settingsPageAccountBlocks => 'Blocklists';

  @override
  String get settingsPageAccountLanguages => 'Discussion Languages';

  @override
  String get settingsPageAccountMedia => 'Manage Media';

  @override
  String get settingsPageAppearance => 'Appearance';

  @override
  String get settingsPageAppearanceComments => 'Comments';

  @override
  String get settingsPageAppearancePosts => 'Posts';

  @override
  String get settingsPageAppearanceTheming => 'Theming';

  @override
  String get settingsPageDebug => 'Debug';

  @override
  String get settingsPageFilters => 'Filters';

  @override
  String get settingsPageFloatingActionButton => 'Floating Action Button';

  @override
  String get settingsPageGeneral => 'General';

  @override
  String get settingsPageGestures => 'Gestures';

  @override
  String get settingsPageUserLabels => 'User Labels';

  @override
  String get settingsPageVideo => 'Video';

  @override
  String get share => 'Share';

  @override
  String get shareComment => 'Share Comment Link';

  @override
  String get shareCommentLocal => 'Share Comment Link (My Instance)';

  @override
  String get shareCommunity => 'Share Community';

  @override
  String get shareCommunityLink => 'Share Community Link';

  @override
  String get shareCommunityLinkLocal => 'Share Community Link (My Instance)';

  @override
  String get shareImage => 'Share Image';

  @override
  String get shareLemmyLink => 'Share Lemmy Link';

  @override
  String get shareLink => 'Share External Link';

  @override
  String get shareMedia => 'Share Media';

  @override
  String get shareMediaLink => 'Share Media Link';

  @override
  String get shareOriginalLink => 'Share Original Link';

  @override
  String get sharePost => 'Share Post Link';

  @override
  String get sharePostLocal => 'Share Post Link (My Instance)';

  @override
  String get shareThumbnail => 'Share Thumbnail';

  @override
  String get shareThumbnailAsImage => 'Share Thumbnail As Image';

  @override
  String get shareUser => 'Share User';

  @override
  String get shareUserLink => 'Share User Link';

  @override
  String get shareUserLinkLocal => 'Share User Link (My Instance)';

  @override
  String get showAll => 'Show all';

  @override
  String get showBotAccounts => 'Show Bot Accounts';

  @override
  String get showCommentActionButtons => 'Show Comment Action Buttons';

  @override
  String get showCommunityDisplayNames => 'Show Community Display Names';

  @override
  String get showCrossPosts => 'Show Cross Posts';

  @override
  String get showEdgeToEdgeImages => 'Show Edge to Edge Images';

  @override
  String get showExpandedTaglines => 'Show expanded taglines';

  @override
  String get showFullDate => 'Show Full Date';

  @override
  String get showFullDateDescription => 'Show full date on posts';

  @override
  String get showFullHeightImages => 'Show Full Height Images';

  @override
  String get showHiddenPosts => 'Show Hidden Posts';

  @override
  String get showInAppUpdateNotifications =>
      'Get Notified of new GitHub Releases';

  @override
  String get showLess => 'Show less';

  @override
  String get showMore => 'Show more';

  @override
  String get showNavigationLabels => 'Show Navigation Labels';

  @override
  String get showNavigationLabelsDescription =>
      'Whether to display labels beneath the bottom navigation buttons';

  @override
  String get showNsfwContent => 'Show NSFW Content';

  @override
  String get showOwnContent => 'Show own content';

  @override
  String get showPassword => 'Show Password';

  @override
  String get showPostAuthor => 'Show Post Author';

  @override
  String get showPostAuthorSubtitle =>
      'Post author is always shown in community feeds';

  @override
  String get showPostCommunityIcons => 'Show Community Icons';

  @override
  String get showPostSaveAction => 'Show Save Button';

  @override
  String get showPostTextContentPreview => 'Show Text Preview';

  @override
  String get showPostTitleFirst => 'Show Title First';

  @override
  String get showPostVoteActions => 'Show Vote Buttons';

  @override
  String get showReadPosts => 'Show Read Posts';

  @override
  String get showSavedContent => 'Show saved content';

  @override
  String get showScoreCounters => 'Display User Scores';

  @override
  String get showScores => 'Show Post/Comment Scores';

  @override
  String get showTextPostIndicator => 'Show Text Post Indicator';

  @override
  String get showThumbnailPreviewOnRight => 'Show Thumbnails on the Right';

  @override
  String get showUnreadOnly => 'Show unread only';

  @override
  String get showUpdateChangelogs => 'Show Update Changelogs';

  @override
  String get showUpdateChangelogsSubtitle =>
      'Display a list of changes after an update';

  @override
  String get showUserAvatar => 'Show User Avatar';

  @override
  String get showUserDisplayNames => 'Show User Display Names';

  @override
  String get showUserInstance => 'Show User Instance';

  @override
  String get sidebar => 'Sidebar';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Double-tap bottom nav to open sidebar';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Swipe bottom nav to open sidebar';

  @override
  String get small => 'Small';

  @override
  String get somethingWentWrong => 'Oops, something went wrong!';

  @override
  String get sortBy => 'Sort By';

  @override
  String get sortByTop => 'Sort by Top';

  @override
  String get sortOptions => 'Sort Options';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get standard => 'Standard';

  @override
  String get stats => 'Stats';

  @override
  String get status => 'Status';

  @override
  String get submit => 'Submit';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get subscribeToCommunity => 'Subscribe to Community';

  @override
  String get subscribed => 'Subscribed';

  @override
  String get subscriptionRequestSent => 'Subscription request sent';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String successfullyBannedUser(Object username) {
    return 'Banned $username';
  }

  @override
  String get successfullyBlocked => 'Blocked.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return 'Blocked $communityName';
  }

  @override
  String successfullyBlockedUser(Object username) {
    return 'Blocked $username';
  }

  @override
  String successfullyUnbannedUser(Object username) {
    return 'Unbanned $username';
  }

  @override
  String get successfullyUnblocked => 'Unblocked.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return 'Unblocked $communityName';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return 'Unblocked $username';
  }

  @override
  String get suchAs => 'such as';

  @override
  String get suggestedTitle => 'Suggested title';

  @override
  String switchedAccount(Object username) {
    return 'Switched to $username';
  }

  @override
  String get system => 'System';

  @override
  String get systemDarkMode => 'Pure Black';

  @override
  String get systemDarkModeDescription =>
      'Enable pure black theme for dark mode';

  @override
  String get tabletMode => 'Tablet Mode (2-column view)';

  @override
  String get tapToExit => 'Press back again to exit';

  @override
  String get tappableAuthorCommunity => 'Tappable Authors & Communities';

  @override
  String get teal => 'Teal';

  @override
  String get testBackgroundNotificationDescription =>
      'Thunder will close itself and then attempt to generate a notification in the background. (It will take at least 15 minutes.)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'Thunder will ask the notification server to send a delayed notification and then close itself. (It may take a few minutes.)';

  @override
  String get text => 'Text';

  @override
  String get textActions => 'Text Actions';

  @override
  String get theme => 'Theme';

  @override
  String get themeAccentColor => 'Accent Colors';

  @override
  String get themePrimary => 'Theme Primary';

  @override
  String get themeSecondary => 'Theme Secondary';

  @override
  String get themeTertiary => 'Theme Tertiary';

  @override
  String get theming => 'Theming';

  @override
  String get thickness => 'Thickness';

  @override
  String get thisAccount => 'This Account';

  @override
  String get thumbnailUrl => 'Thumbnail URL';

  @override
  String thunderHasBeenUpdated(Object version) {
    return 'Thunder updated to $version!';
  }

  @override
  String thunderNotificationServer(Object server) {
    return 'Thunder Notification Server: $server';
  }

  @override
  String get timeoutComments =>
      'Error: Timeout when attempting to fetch comments';

  @override
  String get timeoutErrorMessage =>
      'There was a timeout waiting for a response.';

  @override
  String get timeoutSaveComment =>
      'Error: Timeout when attempting to save a comment';

  @override
  String get timeoutSavingPost =>
      'Error: Timeout when attempting to save post.';

  @override
  String get timeoutUpvoteComment =>
      'Error: Timeout when attempting to vote on comment';

  @override
  String get timeoutVotingPost =>
      'Error: Timeout when attempting to vote post.';

  @override
  String get toggelRead => 'Toggle Read';

  @override
  String get top => 'Top';

  @override
  String get topAll => 'Top of all time';

  @override
  String get topDay => 'Top Today';

  @override
  String get topHour => 'Top in Past Hour';

  @override
  String get topMonth => 'Top Month';

  @override
  String get topNineMonths => 'Top in Past 9 Months';

  @override
  String get topSixHour => 'Top in Past 6 Hours';

  @override
  String get topSixMonths => 'Top in Past 6 Months';

  @override
  String get topThreeMonths => 'Top in Past 3 Months';

  @override
  String get topTwelveHour => 'Top in Past 12 Hours';

  @override
  String get topWeek => 'Top Week';

  @override
  String get topYear => 'Top Year';

  @override
  String totalComments(Object x) {
    return '$x Comments';
  }

  @override
  String totalPosts(Object x) {
    return '$x Posts';
  }

  @override
  String get totp => 'TOTP (optional)';

  @override
  String get transferredModToCommunity => 'Transferred Community';

  @override
  String get translationsMayNotBeComplete =>
      'Please note that the translations may not be complete';

  @override
  String get trendingCommunities => 'Trending Communities';

  @override
  String get trySearchingFor => 'Try searching for...';

  @override
  String get unableToFindCommunity => 'Unable to find community';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'Unable to find community \'$communityName\'';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Unable to find the selected community on the selected user\'s instance.';

  @override
  String get unableToFindInstance => 'Unable to find instance';

  @override
  String get unableToFindLanguage => 'Unable to find language';

  @override
  String get unableToFindPost => 'Unable to find post';

  @override
  String get unableToFindUser => 'Unable to find user';

  @override
  String unableToFindUserName(Object username) {
    return 'Unable to find user \'$username\'';
  }

  @override
  String get unableToLoadImage => 'Unable to load image';

  @override
  String unableToLoadImageFrom(Object domain) {
    return 'Unable to load image from $domain';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return 'Unable to load $instance';
  }

  @override
  String get unableToLoadPost => 'Unable to load post';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return 'Unable to load posts from $instance';
  }

  @override
  String get unableToLoadReplies => 'Unable to load more replies.';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return 'Unable to navigate to $instanceHost. It may not be a valid Lemmy instance.';
  }

  @override
  String get unableToResolveReport => 'Unable to resolve report';

  @override
  String unableToRetrieveChangelog(Object version) {
    return 'Unable to retrieve changelog for version $version.';
  }

  @override
  String get unbanFromCommunity => 'Unban from Community';

  @override
  String get unbannedUser => 'Unbanned User';

  @override
  String unbannedUserFromCommunity(Object username) {
    return 'Unbanned $username from Community';
  }

  @override
  String get unblock => 'Unblock';

  @override
  String get unblockCommunity => 'Unblock Community';

  @override
  String get unblockCommunityInstance => 'Unblock Community Instance';

  @override
  String get unblockInstance => 'Unblock Instance';

  @override
  String get unblockUser => 'Unblock User';

  @override
  String get unblockUserInstance => 'Unblock User Instance';

  @override
  String get understandEnable => 'I Understand, Enable';

  @override
  String get unexpectedError => 'Unexpected Error';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get unfeaturedPost => 'Unfeatured Post';

  @override
  String get unhidCommunity => 'Unhid Community';

  @override
  String get unhide => 'Unhide';

  @override
  String unifiedPushDistributorApp(Object app, Object count) {
    return 'UnifiedPush Distributor app: $app ($count available)';
  }

  @override
  String get unifiedPushNotifications => 'UnifiedPush Notifications';

  @override
  String unifiedPushServer(Object server) {
    return 'UnifiedPush Server: $server';
  }

  @override
  String get unifiedpush => 'UnifiedPush';

  @override
  String get unlockPost => 'Unlock Post';

  @override
  String get unlockedPost => 'Unlocked Post';

  @override
  String get unpinFromCommunity => 'Unpin from Community';

  @override
  String get unpinPostFromCommunity => 'Unpin Post from Community';

  @override
  String get unpinnedPostFromCommunity => 'Unpinned post from community';

  @override
  String get unreachable => 'Unreachable';

  @override
  String get unresolved => 'Unresolved';

  @override
  String get unsubscribe => 'Unsubscribe';

  @override
  String get unsubscribeFromCommunity => 'Unsubscribe from Community';

  @override
  String get unsubscribePending => 'Unsubscribe (subscription pending)';

  @override
  String get unsubscribed => 'Unsubscribed';

  @override
  String updateReleased(Object version) {
    return 'Update released: $version';
  }

  @override
  String get uploadImage => 'Upload image';

  @override
  String uploadedDate(Object date) {
    return 'Uploaded: $date';
  }

  @override
  String get upvote => 'Upvote';

  @override
  String get upvoteColor => 'Upvote Color';

  @override
  String get upvoted => 'Upvoted';

  @override
  String get uriNotSupported =>
      'This type of link is not supported at the moment.';

  @override
  String get url => 'URL';

  @override
  String get useAdvancedShareSheet => 'Use Advanced Share Sheet';

  @override
  String get useApplePushNotifications => 'Use APNs Notifications';

  @override
  String get useApplePushNotificationsDescription =>
      'Uses Apple\'s Push Notification service';

  @override
  String get useCompactView => 'Enable for small posts, disable for big.';

  @override
  String get useLocalNotifications => 'Use Local Notifications (Experimental)';

  @override
  String get useLocalNotificationsDescription =>
      'Periodically checks for notifications in the background';

  @override
  String get useMaterialYouTheme => 'Use Material You Theme';

  @override
  String get useMaterialYouThemeDescription =>
      'Overrides the selected custom theme';

  @override
  String get useProfilePictureForDrawer => 'Use Profile Picture for Drawer';

  @override
  String get useProfilePictureForDrawerSubtitle =>
      'When logged in, shows the user\'s profile picture in place of the drawer icon';

  @override
  String useSuggestedTitle(Object title) {
    return 'Use suggested title: $title';
  }

  @override
  String get useUnifiedPushNotifications => 'Use UnifiedPush Notifications';

  @override
  String get useUnifiedPushNotificationsDescription =>
      'Requires a compatible app';

  @override
  String get user => 'User';

  @override
  String get userActions => 'User Actions';

  @override
  String userEntry(Object username) {
    return 'User \'$username\'';
  }

  @override
  String get userFormat => 'User Format';

  @override
  String get userLabelHint => 'This is my favorite user';

  @override
  String get userLabels => 'User Labels';

  @override
  String get userLabelsSettingsPageDescription =>
      'You can add, modify, or remove labels associated with users.';

  @override
  String get userNameColor => 'User Name Color';

  @override
  String get userNameThickness => 'User Name Thickness';

  @override
  String get userNotLoggedIn => 'User not logged in';

  @override
  String get userProfiles => 'User Profiles';

  @override
  String get userSettingDescription =>
      'These settings sync with your Lemmy account and are only applied on a per-account basis.';

  @override
  String get userStyle => 'User Style';

  @override
  String get username => 'Username';

  @override
  String get usernameFormattingRedirect => 'Looking for username formatting?';

  @override
  String get users => 'Users';

  @override
  String versionNumber(Object version) {
    return 'Version $version';
  }

  @override
  String get video => 'Video';

  @override
  String get videoAutoFullscreen => 'Auto Fullscreen';

  @override
  String get videoAutoLoop => 'Loop Video';

  @override
  String get videoAutoMute => 'Mute Videos';

  @override
  String get videoAutoPlay => 'Video Autoplay';

  @override
  String get videoDefaultPlaybackSpeed => 'Default Playback Speed';

  @override
  String get videoLinkHandlingExternal => 'Play video with an external app';

  @override
  String get videoPlayerInApp => 'Use Thunder built-in player';

  @override
  String get videoPlayerMode => 'Player Mode';

  @override
  String get viewAll => 'View all';

  @override
  String get viewAllComments => 'View all comments';

  @override
  String get viewCommentSource => 'View Comment Source';

  @override
  String get viewModlog => 'View Modlog';

  @override
  String get viewOriginal => 'View original';

  @override
  String get viewPostAsDifferentAccount => 'View post as different account';

  @override
  String get viewPostSource => 'View post source';

  @override
  String get viewSource => 'View source';

  @override
  String get viewingAll => 'Viewing all';

  @override
  String visibility(Object visibility) {
    return 'Visibility: $visibility';
  }

  @override
  String get visitCommunity => 'Visit Community';

  @override
  String get visitCommunityInstance => 'Visit Community Instance';

  @override
  String get visitInstance => 'Visit Instance';

  @override
  String get visitUserInstance => 'Visit User Instance';

  @override
  String get visitUserProfile => 'Visit User Profile';

  @override
  String get warning => 'Warning';

  @override
  String xDownvotes(Object x) {
    return '$x downvotes';
  }

  @override
  String xScore(Object x) {
    return '$x score';
  }

  @override
  String xUpvotes(Object x) {
    return '$x upvotes';
  }

  @override
  String xYearsOld(num count, Object x) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$x years old',
      one: '$x year old',
      zero: '$x year old',
    );
    return '$_temp0';
  }

  @override
  String get yes => 'Yes';

  @override
  String get youMustSelectAJsonFile => 'You must select a .json file.';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get about => '关于';

  @override
  String get accept => '接受';

  @override
  String get accessibility => '无障碍';

  @override
  String get accessibilityProfilesDescription =>
      '无障碍个人档案允许一次性应用多个设置来容纳特殊的无障碍要求。';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '账户',
      one: '账户',
      zero: '账户',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return '账户生日 $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning => '您的账号设置覆盖以下设置';

  @override
  String get accountSettings => '账户设置';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'Lemmy 账号设置已成功导出到 $savedFilePath！';
  }

  @override
  String get accountSettingsImportedSuccessfully => 'Lemmy 账号设置已成功导入！';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return '选择的评论并没有在 \'$instance\' 上找到';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return '选择的帖子并没有在 \'$instance\' 上找到';
  }

  @override
  String get actionColors => '动作颜色';

  @override
  String get actionColorsRedirect => '在找自定义颜色？';

  @override
  String get actions => '动作';

  @override
  String get active => '活跃';

  @override
  String get activity => '活动';

  @override
  String get add => '新增';

  @override
  String get addAccount => '添加账户';

  @override
  String get addAccountToSeeProfile => '登录以查看您的账户。';

  @override
  String get addAnonymousInstance => '添加匿名实例';

  @override
  String get addAsCommunityModerator => '添加为社区管理员';

  @override
  String get addDiscussionLanguage => '增加语言';

  @override
  String get addKeywordFilter => '添加关键字';

  @override
  String get addOriginalPostBody => '添加原帖正文？';

  @override
  String get addToFavorites => '增加到收藏';

  @override
  String get addUserLabel => '添加用户标签';

  @override
  String get addedCommunityToSubscriptions => '订阅至社区';

  @override
  String get addedInstanceMod => '增加实例管理';

  @override
  String get addedModToCommunity => '增加社区管理';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return '已将 $username 添加为社区版主';
  }

  @override
  String get admin => '管理员';

  @override
  String get advanced => '高级';

  @override
  String ago(Object time) {
    return '$time 之前';
  }

  @override
  String get all => '全部';

  @override
  String get allPosts => '全部帖子';

  @override
  String get allowOpenSupportedLinks => '允许应用打开支持的链接。';

  @override
  String get alreadyPostedTo => '已经发到';

  @override
  String get altText => '替代文本';

  @override
  String get alternateSources => '替代来源';

  @override
  String get always => '总是';

  @override
  String andXMore(Object count) {
    return '外加 $count 个';
  }

  @override
  String get animations => '动画';

  @override
  String get anonymous => '匿名';

  @override
  String get anonymousInstances => '匿名实例';

  @override
  String get appLanguage => '应用语言';

  @override
  String get appearance => '外观';

  @override
  String get applePushNotificationService => 'Apple 推送通知服务';

  @override
  String get applied => '已应用';

  @override
  String get apply => '应用';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return '系统是否允许通知：$yesOrNo';
  }

  @override
  String averageComments(Object x) {
    return '$x 条评论/月';
  }

  @override
  String averageContributions(Object x) {
    return '$x 条贡献/月';
  }

  @override
  String averagePosts(Object x) {
    return '$x 篇帖文/月';
  }

  @override
  String get back => '后退';

  @override
  String get backButton => '返回按钮';

  @override
  String get backToTop => '回到顶部';

  @override
  String get backgroundCheckWarning => '请注意，通知检查会消耗更多电量';

  @override
  String get ban => '封禁';

  @override
  String get banFromCommunity => '从社区中禁用';

  @override
  String get bannedUser => '已封禁用户';

  @override
  String get bannedUserFromCommunity => '从社区中封禁用户';

  @override
  String get base => '基本大小';

  @override
  String get block => '屏蔽';

  @override
  String get blockCommunity => '屏蔽该社区';

  @override
  String get blockCommunityInstance => '屏蔽社区实例';

  @override
  String get blockInstance => '屏蔽该实例';

  @override
  String get blockManagement => '屏蔽管理';

  @override
  String get blockSettingLabel => '用户/社区/实例屏蔽';

  @override
  String get blockUser => '屏蔽该用户';

  @override
  String get blockUserInstance => '屏蔽用户实例';

  @override
  String get blockedCommunities => '已屏蔽社区';

  @override
  String get blockedInstances => '已屏蔽实例';

  @override
  String get blockedUsers => '已屏蔽用户';

  @override
  String get blue => '蓝色';

  @override
  String get bold => '粗体';

  @override
  String get boldCommunityName => '显示粗体社区名字';

  @override
  String get boldInstanceName => '显示粗体实例名字';

  @override
  String get boldUserName => '显示粗体用户名字';

  @override
  String get bot => '机器人';

  @override
  String get browserMode => '接管链接';

  @override
  String browsingAnonymously(Object instance) {
    return '您当前正在匿名地浏览 $instance。';
  }

  @override
  String get cancel => '取消';

  @override
  String get cannotReportOwnComment => '你不能举报自己的评论。';

  @override
  String get cantBlockAdmin => '你可能不会屏蔽一个实例的管理员。';

  @override
  String get cantBlockYourself => '你不能屏蔽你自己。';

  @override
  String get cardPostCardMetadataItems => '卡片显示元数据';

  @override
  String get cardView => '卡片样式';

  @override
  String get cardViewDescription => '启用卡片视图以调整设置';

  @override
  String get cardViewSettings => '卡片视图设置';

  @override
  String get changeAccountSettingsFor => '更改这个人的账户设置：';

  @override
  String get changeNotificationSettings => '更改通知设置…';

  @override
  String get changePassword => '更改密码';

  @override
  String get changePasswordWarning => '要更改您的密码，您将被重定向到您的实例网站。您确定要继续吗？';

  @override
  String get changeSort => '更改排序';

  @override
  String clearCache(Object cacheSize) {
    return '清除($cacheSize)缓存';
  }

  @override
  String get clearCacheLabel => '清除缓存';

  @override
  String get clearDatabase => '清除数据库';

  @override
  String get clearPreferences => '清除首选项';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get clearedCache => '成功清除缓存。';

  @override
  String get clearedDatabase => '已清除本地数据库。重启Thunder以生效。';

  @override
  String get clearedUserPreferences => '清除所有用户偏好';

  @override
  String get close => '关闭';

  @override
  String get collapse => '折叠';

  @override
  String get collapseCommentPreview => '折叠评论预览';

  @override
  String get collapseInformation => '折叠信息';

  @override
  String get collapseParentCommentBodyOnGesture => '折叠时隐藏父评论';

  @override
  String get collapsePost => '折叠帖子';

  @override
  String get collapsePostPreview => '折叠帖子预览';

  @override
  String get collapseSpoiler => '折叠剧透';

  @override
  String get color => '颜色';

  @override
  String get colorizeCommunityName => '社区名上色';

  @override
  String get colorizeInstanceName => '实例名上色';

  @override
  String get colorizeUserName => '用户名上色';

  @override
  String get colors => '颜色';

  @override
  String get combineCommentScores => '合并评论分数';

  @override
  String get combineCommentScoresLabel => '合并评论分数';

  @override
  String get combineNavAndFab => '合并 FAB 与导航按钮';

  @override
  String get combineNavAndFabDescription => '浮动动作按钮（FAB）将会在导航按钮中间展示。';

  @override
  String get comfortable => '舒适';

  @override
  String get comment => '评论';

  @override
  String get commentActions => '评论操作';

  @override
  String get commentBehaviourSettings => '评论';

  @override
  String get commentFontScale => '评论内容的字体大小';

  @override
  String get commentPreview => '按照所提供的设置显示评论的预览';

  @override
  String get commentReported => '该评论已被标记为等待审阅。';

  @override
  String get commentSavedAsDraft => '已保存评论为草稿';

  @override
  String get commentShowUserAvatar => '显示用户头像';

  @override
  String get commentShowUserInstance => '显示用户实例';

  @override
  String get commentSortType => '评论排序方式';

  @override
  String get commentSwipeActions => '评论扫除动作';

  @override
  String get commentSwipeGesturesHint => '想直接使用按钮？在通用设置中的评论板块启用他们。';

  @override
  String get comments => '评论';

  @override
  String get communities => '社区';

  @override
  String get community => '社区';

  @override
  String get communityActions => '社区动作';

  @override
  String communityEntry(Object community) {
    return '社区 \'$community\'';
  }

  @override
  String get communityFormat => '社区格式';

  @override
  String get communityNameColor => '社区名颜色';

  @override
  String get communityNameThickness => '社区名粗细';

  @override
  String get communityStyle => '社区样式';

  @override
  String get compact => '紧凑';

  @override
  String get compactPostCardMetadataItems => '紧凑元数据视图';

  @override
  String get compactView => '紧凑视图';

  @override
  String get compactViewDescription => '启用紧凑视图调整设置';

  @override
  String get compactViewSettings => '紧凑视图设置';

  @override
  String get condensed => '紧缩';

  @override
  String get confirm => '确认';

  @override
  String get confirmLogOutBody => '您确认要登出吗？';

  @override
  String get confirmLogOutTitle => '登出？';

  @override
  String get confirmMarkAllAsReadBody => '你确认要将所有回复、提及与消息标记为已读吗？';

  @override
  String get confirmMarkAllAsReadTitle => '标记所有消息已读？';

  @override
  String get confirmResetCommentPreferences => '这会重置您所有评论首选项。您确认您要进行吗？';

  @override
  String get confirmResetPostPreferences => '这会重置您所有的帖子首选项。您确认您想要进行吗？';

  @override
  String get confirmUnsubscription => '您确认您想要取消订阅吗？';

  @override
  String connectedToUnifiedPushDistributorApp(Object app) {
    return '已连接至 $app';
  }

  @override
  String get contentManagement => '内容管理';

  @override
  String get contentWarning => '内容警告';

  @override
  String get controversial => '争议';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get copy => '复制';

  @override
  String get copyComment => '复制评论';

  @override
  String get copySelected => '复制选择的文本';

  @override
  String get copyText => '复制文本';

  @override
  String get couldNotDetermineCommentDelete => '错误：不能确定哪个帖子的评论是要删除的。';

  @override
  String get couldNotDeterminePostComment => '错误：不能确定哪个帖子的评论是要发送的。';

  @override
  String get couldntCreateReport => '您的评论举报不能在这时候发送。请稍后重试';

  @override
  String get couldntFindPost => '无法加载请求的帖子。它可能已经删除了。';

  @override
  String countComments(Object count) {
    return '$count 条评论';
  }

  @override
  String countLocalSubscribers(Object count) {
    return '$count 本地订阅者';
  }

  @override
  String countPosts(Object count) {
    return '$count 帖子';
  }

  @override
  String countSubscribers(Object count) {
    return '$count 位订阅者';
  }

  @override
  String countUsers(Object count) {
    return '$count 位用户';
  }

  @override
  String countUsersActiveDay(Object count) {
    return '$count 用户/天';
  }

  @override
  String countUsersActiveHalfYear(Object count) {
    return '$count 用户/半年';
  }

  @override
  String countUsersActiveMonth(Object count) {
    return '$count 用户/月';
  }

  @override
  String countUsersActiveWeek(Object count) {
    return '$count 用户/周';
  }

  @override
  String get createAccount => '创建用户';

  @override
  String get createComment => '创建评论';

  @override
  String get createNewCrossPost => '创建新的跨社区帖子';

  @override
  String get createPost => '创建帖子';

  @override
  String created(Object date) {
    return '创建于 $date';
  }

  @override
  String get createdToday => '今日已经创建';

  @override
  String get creator => '创建者';

  @override
  String crossPostedFrom(Object postUrl) {
    return '自 $postUrl 跨社区发帖';
  }

  @override
  String get crossPostedTo => '跨社区发帖至';

  @override
  String get currentLongPress => '当前设为长按';

  @override
  String currentNotificationsMode(Object mode) {
    return '当前通知模式：$mode';
  }

  @override
  String get currentSinglePress => '当前设为单击';

  @override
  String get customizeSwipeActions => '自定义扫除动作（点击以修改）';

  @override
  String get dangerZone => '危险区';

  @override
  String get dark => '暗黑';

  @override
  String get databaseExportWarning =>
      '数据库可能包含与您的 Lemmy 账号相关的敏感信息。如果您导出它，您不应与任何人分享。您想继续吗？';

  @override
  String databaseExportedSuccessfully(Object savedFilePath) {
    return '数据库已成功导出到 \'$savedFilePath\'';
  }

  @override
  String get databaseImportedSuccessfully => '数据库已成功导入！';

  @override
  String get databaseNotExportedSuccessfully => '数据库未成功导出或操作已取消。';

  @override
  String get databaseNotImportedSuccessfully => '数据库未成功导入，或操作已取消。';

  @override
  String get dateFormat => '日期格式';

  @override
  String get debug => '调试';

  @override
  String get debugDescription => '以下调试设置应仅用于除错用途。';

  @override
  String get debugNotificationsDescription => '使用以下选项以除错跟通知有关的问题。';

  @override
  String get decline => '拒绝';

  @override
  String get defaultColor => '默认';

  @override
  String get defaultCommentSortType => '默认评论排序方式';

  @override
  String get defaultFeedSortType => '默认推送排序方式';

  @override
  String get defaultFeedType => '默认推送方式';

  @override
  String get delete => '删除';

  @override
  String get deleteAccount => '删除账号';

  @override
  String get deleteAccountDescription =>
      '要永久删除您的账号，您将要重定向至您的实例网站。\n\n您确定您要继续吗？';

  @override
  String get deleteComment => '删除评论';

  @override
  String get deleteImageConfirmMessage => '您确定要删除此图像吗？';

  @override
  String get deleteImageConfirmTitle => '删除？';

  @override
  String get deleteLocalDatabase => '删除本地数据库';

  @override
  String get deleteLocalDatabaseDescription =>
      '这个动作会删除本地数据库，并且登出您的每一个账号\n\n您确信您要继续吗？';

  @override
  String get deleteLocalPreferences => '删除本地首选项';

  @override
  String get deleteLocalPreferencesDescription =>
      '这个动作会删除您全部的首选项和设置。\n\n您确信您要继续吗？';

  @override
  String get deletePost => '删除帖子';

  @override
  String get deleteUserLabelConfirmation => '您确定要删除标签吗？';

  @override
  String get deleted => '已删除';

  @override
  String get deletedByCreator => '被发帖者删除';

  @override
  String get deletedByModerator => '被管理删除';

  @override
  String get deletedComment => '评论已删除';

  @override
  String get deletedPost => '帖文已删除';

  @override
  String get deselectUndeterminedWarning => '如果你取消选择「未确定」，您不会看见大多数内容。';

  @override
  String detailedReason(Object reason) {
    return '原因：$reason';
  }

  @override
  String get dimReadPosts => '淡化已读帖子';

  @override
  String get disable => '禁用';

  @override
  String get disablePushNotifications => '禁用推送通知';

  @override
  String get disabled => '已禁用';

  @override
  String get discussionLanguages => '讨论语言';

  @override
  String get discussionLanguagesTooltip => '内容已过滤为所选语言。';

  @override
  String get dismissRead => '忽略已读';

  @override
  String get displayName => '显示名称';

  @override
  String get displayUserScore => '显示用户评分（Karma）。';

  @override
  String get dividerAppearance => '分隔符外观';

  @override
  String get doNotShowAgain => '不再显示';

  @override
  String get doNotSupportMultipleUnifiedPushApps => '发现多个兼容应用；请仅安装一个';

  @override
  String get downloadingMedia => '正在下载媒体以分享…';

  @override
  String get downvote => '点踩';

  @override
  String get downvoteColor => '点踩颜色';

  @override
  String get downvoted => '已点踩';

  @override
  String get downvotesDisabled => '此实例已关闭点踩。';

  @override
  String get edit => '编辑';

  @override
  String get editComment => '编辑评论';

  @override
  String get editPost => '编辑帖子';

  @override
  String get email => '电子邮件';

  @override
  String get empty => '空';

  @override
  String get emptyInbox => '清空收件箱';

  @override
  String get emptyUri => '链接为空。请提供有效的动态链接以继续。';

  @override
  String get enableCommentNavigation => '启用评论导航';

  @override
  String get enableExperimentalFeatures => '启用实验性功能';

  @override
  String get enableFeedFab => '在信息流中启用动态按钮';

  @override
  String get enableFloatingButtonOnFeeds => '在信息流中启用动态按钮';

  @override
  String get enableFloatingButtonOnPosts => '启用动态按钮在帖子中';

  @override
  String get enableInboxNotifications => '启用收件箱通知';

  @override
  String get enablePostFab => '启用动态按钮在帖子中';

  @override
  String get endOfComments => '评论结束';

  @override
  String get endSearch => '结束搜索';

  @override
  String errorDeletingImage(Object error) {
    return '删除图像时发生错误：$error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return '无法下载媒体文件以分享：$errorMessage';
  }

  @override
  String get errorImportingAccountSettings => '导入设置时出错。文件可能格式不正确。';

  @override
  String get errorInitializingClient => '初始化客户端时出错';

  @override
  String get errorLoadingAccountSettings => '加载设置文件时出错或操作已被取消。';

  @override
  String get errorMarkingReplyRead => '标记回复为已读时出错。';

  @override
  String get errorMarkingReplyUnread => '标记回复为未读时出错。';

  @override
  String get errorNoActiveInstance => '未找到活动实例';

  @override
  String get errorParsingJson => '解析所选文件时出错。它可能不是有效的 JSON。';

  @override
  String get errorSavingAccountSettings => '保存设置文件时出错或操作已被取消。';

  @override
  String get exceptionProcessingUri => '处理链接时发生错误。它可能在您的实例上不可用。';

  @override
  String get excessiveApiCallsWarning => '由于关键字过滤器，您的信息流可能需要一些时间才能加载。';

  @override
  String get expand => '展开';

  @override
  String get expandCommentPreview => '展开评论预览';

  @override
  String get expandInformation => '展开信息';

  @override
  String get expandOptions => '展开选项';

  @override
  String get expandPost => '展开帖子';

  @override
  String get expandPostPreview => '展开帖子预览';

  @override
  String get expandSpoiler => '展开剧透';

  @override
  String get expanded => '已展开';

  @override
  String get experimentalFeatures => '实验性功能';

  @override
  String get experimentalFeaturesDescription =>
      '这些功能仍在开发中，可能不稳定。使用风险自负。您必须重启 Thunder 才能生效。';

  @override
  String get exploreInstance => '探索实例';

  @override
  String get exportDatabase => '导出数据库';

  @override
  String get exportDatabaseSubtitle => '数据库包含有关账号、收藏、匿名订阅和用户标签的信息。';

  @override
  String get exportLemmyAccountSettingsDescription => '导出 Lemmy 账号设置';

  @override
  String get exportSettingsSubtitle => '设置包括您在 Thunder 中配置的所有偏好。';

  @override
  String get extraLarge => '特大号';

  @override
  String failedToBlock(Object errorMessage) {
    return '屏蔽失败：$errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return '无法与位于 $serverAddress 的 Thunder 通知服务器通信。';
  }

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return '无法加载屏蔽：$errorMessage';
  }

  @override
  String get failedToLoadVideo => '加载视频失败。要在浏览器中打开链接吗？';

  @override
  String get failedToPerformAction => '执行操作失败';

  @override
  String failedToUnblock(Object errorMessage) {
    return '无法取消屏蔽：$errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings => '更新通知设置失败';

  @override
  String get favorite => '收藏';

  @override
  String get favorites => '收藏';

  @override
  String get featuredPost => '精选帖子';

  @override
  String get feed => '信息流';

  @override
  String get feedBehaviourSettings => '信息流';

  @override
  String get feedSettings => '信息流设置';

  @override
  String get feedTypeAndSorts => '默认信息流类型和排序';

  @override
  String get fetchAccountError => '无法确定账号';

  @override
  String filteringBy(Object entity) {
    return '按 $entity 过滤';
  }

  @override
  String get filters => '过滤器';

  @override
  String get floatingActionButton => '浮动操作按钮';

  @override
  String get floatingActionButtonInformation =>
      'Thunder 提供完全可自定义的 FAB 体验，支持一些手势。- 向上滑动以显示额外的 FAB 操作 - 向下/上滑动以隐藏或显示 FAB 要自定义 FAB 的主要和次要操作，请长按以下其中一个操作。';

  @override
  String get floatingActionButtonLongPressDescription => '表示 FAB 的长按操作。';

  @override
  String get floatingActionButtonSinglePressDescription => '表示 FAB 的单击操作。';

  @override
  String get fonts => '字体';

  @override
  String get forward => '前进';

  @override
  String get foundUnifiedPushDistribtorApp => '找到兼容的应用程序；重启 Thunder 以连接';

  @override
  String get fullScreenNavigationSwipeDescription => '在禁用左右滑动手势时，随处滑动以返回';

  @override
  String get fullscreen => '全屏';

  @override
  String get fullscreenSwipeGestures => '全屏滑动手势';

  @override
  String get general => '常规';

  @override
  String get generalSettings => '常规设置';

  @override
  String get gestures => '手势';

  @override
  String get gettingStarted => '开始使用';

  @override
  String get green => '绿色';

  @override
  String get guestModeFeedSettings => '访客模式信息流设置';

  @override
  String get guestModeFeedSettingsLabel => '以下设置仅适用于访客账号。要调整您账号的信息流设置，请前往账号设置。';

  @override
  String get havingIssuesWithNotifications => '遇到通知问题了吗？';

  @override
  String get hidCommunity => '隐藏社区';

  @override
  String get hidden => '已隐藏';

  @override
  String get hide => '隐藏';

  @override
  String get hideBottomBarOnScroll => '滚动时隐藏底部栏';

  @override
  String get hideColor => '隐藏颜色';

  @override
  String get hideNsfwPostsFromFeed => '从信息流中隐藏 NSFW 帖子';

  @override
  String get hideNsfwPreviews => '模糊 NSFW 预览';

  @override
  String get hidePassword => '隐藏密码';

  @override
  String get hideThumbnails => '隐藏缩略图';

  @override
  String get hideTopBarOnScroll => '滚动时隐藏顶部栏';

  @override
  String get hostInstance => '主机实例';

  @override
  String get hot => '热门';

  @override
  String get image => '图像';

  @override
  String get imageCachingMode => '图像缓存模式';

  @override
  String get imageCachingModeAggressive => '积极缓存图像（使用更多内存）';

  @override
  String get imageCachingModeAggressiveShort => '激进';

  @override
  String get imageCachingModeRelaxed => '让图像缓存过期（使用更少内存，但导致图像更频繁地重新加载）';

  @override
  String get imageCachingModeRelaxedShort => '放松';

  @override
  String get imageDimensionTimeout => '图像尺寸超时';

  @override
  String get importDatabase => '导入数据库';

  @override
  String get importExportDatabase => '导入/导出 Thunder 数据库';

  @override
  String get importExportLemmyAccountSettings => '导入/导出 Lemmy 账号设置';

  @override
  String get importExportLemmyAccountSettingsSubtitle => '包括订阅的社区、屏蔽列表和账号偏好设置';

  @override
  String get importExportSettings => '导入/导出设置';

  @override
  String get importExportThunderSettings => '导入/导出 Thunder 设置';

  @override
  String get importLemmyAccountSettingsDescription => '导入 Lemmy 账号设置';

  @override
  String get importSettings => '导入设置';

  @override
  String inReplyTo(Object post, Object community) {
    return '回复 $post 在 $community 中';
  }

  @override
  String get in_ => '在';

  @override
  String get inbox => '收件箱';

  @override
  String get includeCommunity => '包括社区';

  @override
  String get includeExternalLink => '包括外部链接';

  @override
  String get includeImage => '包括图像';

  @override
  String get includePostLink => '包括帖子链接';

  @override
  String get includeText => '包括文本';

  @override
  String get includeTitle => '包括标题';

  @override
  String get information => '信息';

  @override
  String instance(num count) {
    return '实例 ';
  }

  @override
  String get instanceActions => '实例操作';

  @override
  String instanceEntry(Object username) {
    return '实例 \'$username\'';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance 已经被添加。';
  }

  @override
  String get instanceNameColor => '实例名称颜色';

  @override
  String get instanceNameThickness => '实例名称厚度';

  @override
  String get instances => '实例';

  @override
  String get internetOrInstanceIssues => '您可能未连接到互联网，或者您的实例当前可能不可用。';

  @override
  String get invalidUrl => 'URL 格式无效';

  @override
  String joined(Object x) {
    return '于 $x 加入';
  }

  @override
  String get keywordFilterDescription => '过滤标题、正文或 URL 中包含的任何关键字的帖子';

  @override
  String get keywordFilters => '关键字过滤器';

  @override
  String get label => '标签';

  @override
  String get language => '语言';

  @override
  String get languageFilters => '寻找语言过滤器吗？';

  @override
  String get languageNotAllowed => '您发布的社区不允许使用您选择的语言发布帖子。请尝试其他语言。';

  @override
  String get large => '大';

  @override
  String get leftLongSwipe => '左长滑动';

  @override
  String get leftShortSwipe => '左短滑动';

  @override
  String get light => '亮';

  @override
  String link(num count) {
    return '链接 ';
  }

  @override
  String get linkActions => '链接操作';

  @override
  String get linkHandlingCustomTabs => '在系统浏览器中打开，嵌入在应用内';

  @override
  String get linkHandlingCustomTabsShort => '应用内嵌入';

  @override
  String get linkHandlingExternal => '在系统浏览器中外部打开';

  @override
  String get linkHandlingExternalShort => '外部';

  @override
  String get linkHandlingInApp => '使用 Thunder 的内置浏览器';

  @override
  String get linkHandlingInAppShort => '应用内';

  @override
  String get linksBehaviourSettings => '链接';

  @override
  String loadMorePlural(Object count) {
    return '加载 $count 条更多回复…';
  }

  @override
  String loadMoreSingular(Object count) {
    return '加载 $count 条更多回复…';
  }

  @override
  String get loading => '加载中...';

  @override
  String get local => '本地';

  @override
  String get localNotifications => '本地通知';

  @override
  String get localOnly => '仅本地';

  @override
  String get localPosts => '本地帖子';

  @override
  String get lockPost => '锁定帖子';

  @override
  String get locked => '已锁定';

  @override
  String get lockedPost => '已锁定帖子';

  @override
  String get logOut => '登出';

  @override
  String get login => '登录';

  @override
  String get loginAttemptCanceled => '登录尝试已取消。';

  @override
  String loginFailed(Object errorMessage) {
    return '无法登录。请再试一次。（错误：$errorMessage）';
  }

  @override
  String get loginSucceeded => '已登录。';

  @override
  String get loginToPerformAction => '您需要登录才能执行此任务。';

  @override
  String get loginToSeeInbox => '登录以查看您的收件箱';

  @override
  String get lookingForAccountSpecificFeedSettings => '寻找账号特定的信息流设置吗？';

  @override
  String get malformedUri => '您提供的链接格式不受支持。请确保它是有效的链接。';

  @override
  String get manageAccounts => '管理账号';

  @override
  String get manageMedia => '管理媒体';

  @override
  String get markAllAsRead => '全部标记为已读';

  @override
  String get markAsRead => '标记为已读';

  @override
  String get markPostAsReadOnMediaView => '查看媒体后标记为已读';

  @override
  String get markPostAsReadOnScroll => '滚动时标记为已读';

  @override
  String get markReadColor => '标记已读/未读颜色';

  @override
  String get matrixUser => 'Matrix 用户';

  @override
  String get me => '我';

  @override
  String get medium => '中等';

  @override
  String mention(num count) {
    return '提及';
  }

  @override
  String get menu => '菜单';

  @override
  String message(num count) {
    return '消息';
  }

  @override
  String get metadataFontScale => '元数据字体比例';

  @override
  String get missingErrorMessage => '没有可用的错误消息';

  @override
  String get modAdd => '添加/移除实例管理员';

  @override
  String get modAddCommunity => '添加/移除社区管理员';

  @override
  String get modBan => '禁止/解禁实例用户';

  @override
  String get modBanFromCommunity => '禁止/解禁社区用户';

  @override
  String get modFeaturePost => '推荐/取消推荐帖子';

  @override
  String get modLockPost => '锁定/解锁帖子';

  @override
  String get modRemoveComment => '移除/恢复评论';

  @override
  String get modRemoveCommunity => '移除/恢复社区';

  @override
  String get modRemovePost => '移除/恢复帖子';

  @override
  String get modTransferCommunity => '转移社区';

  @override
  String get moderatedCommunities => '管理的社区';

  @override
  String get moderates => '管理的社区';

  @override
  String moderator(num count) {
    return '管理员';
  }

  @override
  String get moderatorActions => '管理员操作';

  @override
  String get modlog => '管理日志';

  @override
  String get mostComments => '最多评论';

  @override
  String get mustBeLoggedIn => '您需要登录';

  @override
  String get mustBeLoggedInComment => '您需要登录才能评论';

  @override
  String get mustBeLoggedInPost => '您需要登录才能创建帖子';

  @override
  String get names => '名称';

  @override
  String get navbarDoubleTapGestures => '导航栏双击手势';

  @override
  String get navbarSwipeGestures => '导航栏滑动手势';

  @override
  String get navigateDown => '下一条评论';

  @override
  String get navigateUp => '上一条评论';

  @override
  String get navigation => '导航';

  @override
  String get nestedCommentIndicatorColor => '嵌套评论指示器颜色';

  @override
  String get nestedCommentIndicatorStyle => '嵌套评论指示器样式';

  @override
  String get never => '从不';

  @override
  String get newComments => '新评论';

  @override
  String get newPost => '新帖子';

  @override
  String get new_ => '新';

  @override
  String get no => '否';

  @override
  String get noAccountsAdded => '没有添加任何账号';

  @override
  String get noAnonymousInstances => '没有添加任何匿名实例';

  @override
  String get noCommentsFound => '未找到评论';

  @override
  String get noCommunitiesFound => '未找到社区';

  @override
  String get noCommunityBlocks => '没有被屏蔽的社区';

  @override
  String get noCompatibleAppFound => '未找到兼容的应用';

  @override
  String get noDiscussionLanguages => '没有根据语言隐藏内容。';

  @override
  String get noDisplayNameSet => '未设置显示名称';

  @override
  String get noEmailSet => '未设置电子邮件';

  @override
  String get noFavoritedCommunities => '没有收藏的社区';

  @override
  String get noImages => '看起来您还没有上传任何图片。';

  @override
  String get noInstanceBlocks => '没有被屏蔽的实例。';

  @override
  String get noItems => '没有项目';

  @override
  String get noKeywordFilters => '没有添加关键词过滤器';

  @override
  String get noLanguage => '没有语言';

  @override
  String get noMatrixUserSet => '未设置 Matrix 用户';

  @override
  String get noMentions => '没有提及';

  @override
  String get noMessages => '没有消息';

  @override
  String get noPostsFound => '未找到帖子。';

  @override
  String get noProfileBioSet => '未设置个人资料简介';

  @override
  String get noReferencesToImage => '未找到包含此图像的帖子或评论。然而，它可能在互联网上的其他地方被使用。';

  @override
  String get noReplies => '没有回复';

  @override
  String get noResultsFound => '未找到结果。';

  @override
  String get noSubscriptions => '没有订阅';

  @override
  String get noUserBlocks => '没有被屏蔽的用户。';

  @override
  String get noUserLabels => '您还没有创建任何用户标签';

  @override
  String get noUsersFound => '未找到用户。';

  @override
  String get noVisibleComments => '评论可能不可见，因为该社区已被屏蔽。';

  @override
  String get none => '无';

  @override
  String get normal => '正常';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance 似乎不是有效的实例';
  }

  @override
  String get notValidUrl => '不是有效的 URL';

  @override
  String get nothingToShare => '没有内容可分享';

  @override
  String notifications(num count) {
    return '通知';
  }

  @override
  String get notificationsBehaviourSettings => '通知';

  @override
  String get notificationsNotAllowed => '系统设置中不允许通知 Thunder';

  @override
  String get notificationsWarningDialog =>
      '通知是一个 **实验性功能**，可能在所有设备上无法正常工作。- 检查将每 ~15 分钟进行一次，并会消耗额外的电池。- 禁用电池优化以提高成功通知的可能性。请参阅以下页面以获取更多信息。';

  @override
  String get nsfw => 'NSFW';

  @override
  String get nsfwWarning => 'NSFW - 点击以显示';

  @override
  String get off => '关闭';

  @override
  String get offline => '离线';

  @override
  String get ok => '好的';

  @override
  String get old => '旧';

  @override
  String get on => '开启';

  @override
  String get onWifi => '在 Wifi 上';

  @override
  String get onlyModsCanPostInCommunity => '只有管理员可以在此社区发帖';

  @override
  String get open => '打开';

  @override
  String get openAccountSwitcher => '打开账号切换器';

  @override
  String get openByDefault => '默认打开';

  @override
  String get openInBrowser => '在浏览器中打开';

  @override
  String get openInstance => '打开实例';

  @override
  String get openLinksInExternalBrowser => '在外部浏览器中打开链接';

  @override
  String get openLinksInReaderMode => '在阅读模式中打开链接';

  @override
  String get openSettings => '打开设置';

  @override
  String get orange => '橙色';

  @override
  String get originalPoster => '原始发布者';

  @override
  String get overview => '概述';

  @override
  String get password => '密码';

  @override
  String get pending => '待处理';

  @override
  String performedBy(Object user) {
    return '执行者：$user';
  }

  @override
  String get permissionDenied => 'Thunder 未获得显示通知的权限。请在系统设置中启用。';

  @override
  String get permissionDeniedMessage => 'Thunder 需要一些权限才能保存此图像，但这些权限已被拒绝。';

  @override
  String get pinPostToCommunity => '将帖子固定到社区';

  @override
  String get pinToCommunity => '固定到社区';

  @override
  String get pinned => '已置顶';

  @override
  String get pinnedPostToCommunity => '已将帖文置顶至社区';

  @override
  String get placeholderText =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  @override
  String get post => '帖子';

  @override
  String get postActions => '帖子操作';

  @override
  String get postBehaviourSettings => '帖子';

  @override
  String get postBody => '帖子内容';

  @override
  String get postBodySettings => '帖子内容设置';

  @override
  String get postBodySettingsDescription => '这些设置影响帖子内容的显示';

  @override
  String get postBodyShowCommunityInstance => '显示社区实例';

  @override
  String get postBodyShowUserInstance => '显示用户实例';

  @override
  String get postBodyViewType => '帖子内容视图类型';

  @override
  String get postContentFontScale => '帖子内容字体缩放';

  @override
  String get postCreatedSuccessfully => '帖子创建成功！';

  @override
  String get postLocked => '帖子已锁定。禁止回复。';

  @override
  String get postMetadataInstructions => '您可以通过拖放所需信息来自定义元数据';

  @override
  String get postNSFW => '标记为 NSFW';

  @override
  String get postPreview => '显示具有给定设置的帖子预览';

  @override
  String get postSavedAsDraft => '帖子已保存为草稿';

  @override
  String get postShowUserInstance => '显示用户实例';

  @override
  String get postSwipeActions => '帖子滑动操作';

  @override
  String get postSwipeGesturesHint => '想使用按钮吗？在常规设置中更改帖子卡片上显示的按钮。';

  @override
  String get postTitle => '标题';

  @override
  String get postTitleFontScale => '帖子标题字体缩放';

  @override
  String get postTogglePreview => '切换预览';

  @override
  String get postURL => '网址';

  @override
  String get postUploadImageError => '无法上传图像';

  @override
  String get postViewType => '帖子视图类型';

  @override
  String get posts => '帖子';

  @override
  String get preview => '预览';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile 应用成功！';
  }

  @override
  String get profileBio => '个人资料简介';

  @override
  String get profiles => '个人资料';

  @override
  String get public => '公开';

  @override
  String get pureBlack => '纯黑色';

  @override
  String get purgedComment => '已清除评论';

  @override
  String get purgedCommunity => '已清除社区';

  @override
  String get purgedPerson => '已清除人员';

  @override
  String get purgedPost => '已清除帖子';

  @override
  String get purple => '紫色';

  @override
  String get pushNotification => '推送通知';

  @override
  String get pushNotificationDescription =>
      '如果启用，Thunder 将向服务器发送您的 JWT 令牌，以轮询新通知。**注意：** 这将在下次启动应用程序时生效。';

  @override
  String get pushNotificationServer => '推送通知服务器';

  @override
  String get pushNotificationServerDescription =>
      '配置推送通知服务器。服务器必须正确配置以向您的设备发送推送通知。**仅输入您信任其凭据的服务器。**';

  @override
  String get rateLimitErrorMessage => '您已达到此请求的速率限制。请稍等并稍后再试。';

  @override
  String get reachedTheBottom => '没有更多项目可加载';

  @override
  String get read => '已读';

  @override
  String get readAll => '全部已读';

  @override
  String get readerMode => '阅读模式';

  @override
  String get reason => '原因';

  @override
  String get red => '红色';

  @override
  String get reduceAnimations => '减少动画';

  @override
  String get reducesAnimations => '减少 Thunder 中使用的动画';

  @override
  String get refresh => '刷新';

  @override
  String get refreshContent => '刷新内容';

  @override
  String get removalReason => '删除原因';

  @override
  String get remove => '删除';

  @override
  String get removeAccount => '删除账号';

  @override
  String get removeAsCommunityModerator => '移除社区管理员';

  @override
  String get removeComment => '删除评论';

  @override
  String get removeFromFavorites => '从收藏夹中移除';

  @override
  String get removeInstance => '移除实例';

  @override
  String removeKeyword(Object keyword) {
    return '移除“$keyword”?';
  }

  @override
  String get removeKeywordFilter => '移除关键词';

  @override
  String get removePost => '删除帖子';

  @override
  String get removeUserData => '移除用户数据';

  @override
  String get removed => '已移除';

  @override
  String get removedComment => '已删除评论';

  @override
  String get removedCommunity => '已删除社区';

  @override
  String get removedCommunityFromSubscriptions => '已取消订阅社区';

  @override
  String get removedInstanceMod => '已移除实例管理员';

  @override
  String get removedModFromCommunity => '已从社区移除管理员';

  @override
  String get removedPost => '已删除帖子';

  @override
  String removedUserAsCommunityModerator(Object username) {
    return '已将 $username 移除社区版主身份';
  }

  @override
  String get reorder => '重新排序';

  @override
  String reply(num count) {
    return '回复';
  }

  @override
  String get replyColor => '回复颜色';

  @override
  String get replyNotSupported => '当前不支持从此视图回复';

  @override
  String get replyToPost => '回复帖子';

  @override
  String replyingTo(Object author) {
    return '回复 $author';
  }

  @override
  String report(num count) {
    return '举报 ';
  }

  @override
  String get reportComment => '举报评论';

  @override
  String get reportPost => '举报帖子';

  @override
  String get reportedComment => '评论已举报';

  @override
  String get reportedPost => '帖文已举报';

  @override
  String get reporter => '举报人：';

  @override
  String get requiredField => '*必填';

  @override
  String get reset => '重置';

  @override
  String get resetCommentPreferences => '重置评论偏好设置';

  @override
  String get resetPostPreferences => '重置帖子偏好设置';

  @override
  String get resetPreferences => '重置偏好设置';

  @override
  String get resetPreferencesAndData => '重置偏好设置和数据';

  @override
  String get restore => '恢复';

  @override
  String get restoreComment => '恢复评论';

  @override
  String get restorePost => '恢复帖子';

  @override
  String get restoredComment => '已恢复评论';

  @override
  String get restoredCommentFromDraft => '从草稿中恢复的评论';

  @override
  String get restoredCommunity => '已恢复社区';

  @override
  String get restoredPost => '已恢复帖子';

  @override
  String get restoredPostFromDraft => '从草稿中恢复的帖子';

  @override
  String get retry => '重试';

  @override
  String get rightLongSwipe => '右长滑动';

  @override
  String get rightShortSwipe => '右短滑动';

  @override
  String get save => '保存';

  @override
  String get saveColor => '保存颜色';

  @override
  String get saveSettings => '保存设置';

  @override
  String get saved => '已保存';

  @override
  String get scaled => '缩放';

  @override
  String get scrapeMissingLinkPreviews => '抓取缺失的链接预览';

  @override
  String get screenReaderProfile => '屏幕阅读器配置文件';

  @override
  String get screenReaderProfileDescription =>
      '通过减少整体元素和移除可能冲突的手势来优化 Thunder 以适应屏幕阅读器。';

  @override
  String get search => '搜索';

  @override
  String get searchByText => '按文本搜索';

  @override
  String get searchByUrl => '按 URL 搜索';

  @override
  String get searchComments => '搜索评论';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return '搜索与 $instance 联邦的评论';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return '搜索与 $instance 联邦的社区';
  }

  @override
  String searchInstance(Object instance) {
    return '搜索 $instance';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return '搜索与 $instance 联邦的实例';
  }

  @override
  String get searchPostSearchType => '选择帖子搜索类型';

  @override
  String searchPostsFederatedWith(Object instance) {
    return '搜索与 $instance 联邦的帖子';
  }

  @override
  String get searchTerm => '搜索词';

  @override
  String searchUsersFederatedWith(Object instance) {
    return '搜索与 $instance 联邦的用户';
  }

  @override
  String get selectAccountToCommentAs => '选择作为其他用户评论的账号';

  @override
  String get selectAccountToPostAs => '选择作为其他用户发布的账号';

  @override
  String get selectAll => '全选';

  @override
  String get selectCommunity => '选择社区（必填）';

  @override
  String get selectFeedType => '选择信息流类型';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get selectSearchType => '选择搜索类型';

  @override
  String get selectText => '选择文本';

  @override
  String get sendBackgroundTestLocalNotification => '发送后台测试本地通知';

  @override
  String get sendBackgroundTestUnifiedPushNotification =>
      '发送后台测试 UnifiedPush 通知';

  @override
  String get sendTestLocalNotification => '发送测试本地通知';

  @override
  String get sendTestUnifiedPushNotification => '发送测试 UnifiedPush 通知';

  @override
  String get sensitiveContentWarning => '可能包含敏感内容。点击以显示。';

  @override
  String get sentRequestForTestNotification => '已发送测试通知请求。';

  @override
  String serverErrorComments(Object message) {
    return '获取更多评论时遇到服务器错误：$message';
  }

  @override
  String get setAction => '设置操作';

  @override
  String get setLongPress => '设置为长按操作';

  @override
  String get setShortPress => '设置为短按操作';

  @override
  String get settingOverrideLabel => '这些设置会覆盖 Thunder 的默认设置。';

  @override
  String settingTypeNotSupported(Object settingType) {
    return '类型为$settingType的设置尚不支持。';
  }

  @override
  String get settings => '设置';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return '设置已成功保存到\'$savedFilePath\'';
  }

  @override
  String get settingsFeedCards => '这些设置适用于主信息流中的卡片，实际打开帖子时操作始终可用。';

  @override
  String get settingsImportedSuccessfully => '设置已成功导入！';

  @override
  String get settingsNotExportedSuccessfully => '设置未成功保存，或操作已被取消。';

  @override
  String get settingsNotImportedSuccessfully => '设置未成功导入或操作已被取消。';

  @override
  String get settingsPage => '设置页面';

  @override
  String get settingsPageAbout => '关于';

  @override
  String get settingsPageAccessibility => '无障碍';

  @override
  String get settingsPageAccount => '账号';

  @override
  String get settingsPageAccountBlocks => '屏蔽列表';

  @override
  String get settingsPageAccountLanguages => '讨论语言';

  @override
  String get settingsPageAccountMedia => '管理媒体';

  @override
  String get settingsPageAppearance => '外观';

  @override
  String get settingsPageAppearanceComments => '评论';

  @override
  String get settingsPageAppearancePosts => '帖文';

  @override
  String get settingsPageAppearanceTheming => '主题';

  @override
  String get settingsPageDebug => '调试';

  @override
  String get settingsPageFilters => '过滤器';

  @override
  String get settingsPageFloatingActionButton => '悬浮操作按钮';

  @override
  String get settingsPageGeneral => '通用';

  @override
  String get settingsPageGestures => '手势';

  @override
  String get settingsPageUserLabels => '用户标签';

  @override
  String get settingsPageVideo => '视频';

  @override
  String get share => '分享';

  @override
  String get shareComment => '分享评论链接';

  @override
  String get shareCommentLocal => '分享评论链接（我的实例）';

  @override
  String get shareCommunity => '分享社区';

  @override
  String get shareCommunityLink => '分享社区链接';

  @override
  String get shareCommunityLinkLocal => '分享社区链接（我的实例）';

  @override
  String get shareImage => '分享图片';

  @override
  String get shareLemmyLink => '分享 Lemmy 链接';

  @override
  String get shareLink => '分享外部链接';

  @override
  String get shareMedia => '分享媒体';

  @override
  String get shareMediaLink => '分享媒体链接';

  @override
  String get shareOriginalLink => '分享原始链接';

  @override
  String get sharePost => '分享帖子链接';

  @override
  String get sharePostLocal => '分享帖子链接（我的实例）';

  @override
  String get shareThumbnail => '分享缩略图';

  @override
  String get shareThumbnailAsImage => '分享缩略图作为图片';

  @override
  String get shareUser => '分享用户';

  @override
  String get shareUserLink => '分享用户链接';

  @override
  String get shareUserLinkLocal => '分享用户链接（我的实例）';

  @override
  String get showAll => '显示全部';

  @override
  String get showBotAccounts => '显示机器人账号';

  @override
  String get showCommentActionButtons => '显示评论操作按钮';

  @override
  String get showCommunityDisplayNames => '显示社区显示名称';

  @override
  String get showCrossPosts => '显示交叉帖子';

  @override
  String get showEdgeToEdgeImages => '显示边缘到边缘的图片';

  @override
  String get showExpandedTaglines => '显示扩展标签行';

  @override
  String get showFullDate => '显示完整日期';

  @override
  String get showFullDateDescription => '在帖子上显示完整日期';

  @override
  String get showFullHeightImages => '显示完整高度的图片';

  @override
  String get showHiddenPosts => '显示隐藏帖子';

  @override
  String get showInAppUpdateNotifications => '获取新 GitHub 发布的通知';

  @override
  String get showLess => '显示更少';

  @override
  String get showMore => '显示更多';

  @override
  String get showNavigationLabels => '显示导航标签';

  @override
  String get showNavigationLabelsDescription => '是否在底部导航按钮下方显示标签';

  @override
  String get showNsfwContent => '显示 NSFW 内容';

  @override
  String get showOwnContent => '显示自己的内容';

  @override
  String get showPassword => '显示密码';

  @override
  String get showPostAuthor => '显示帖子作者';

  @override
  String get showPostAuthorSubtitle => '帖子作者在社区信息流中始终显示';

  @override
  String get showPostCommunityIcons => '显示社区图标';

  @override
  String get showPostSaveAction => '显示保存按钮';

  @override
  String get showPostTextContentPreview => '显示文本预览';

  @override
  String get showPostTitleFirst => '优先显示标题';

  @override
  String get showPostVoteActions => '显示投票按钮';

  @override
  String get showReadPosts => '显示已读帖子';

  @override
  String get showSavedContent => '显示已保存的内容';

  @override
  String get showScoreCounters => '显示用户评分';

  @override
  String get showScores => '显示帖子/评论评分';

  @override
  String get showTextPostIndicator => '显示文本帖子指示器';

  @override
  String get showThumbnailPreviewOnRight => '在右侧显示缩略图';

  @override
  String get showUnreadOnly => '仅显示未读';

  @override
  String get showUpdateChangelogs => '显示更新日志';

  @override
  String get showUpdateChangelogsSubtitle => '在更新后显示更改列表';

  @override
  String get showUserAvatar => '显示用户头像';

  @override
  String get showUserDisplayNames => '显示用户显示名称';

  @override
  String get showUserInstance => '显示用户实例';

  @override
  String get sidebar => '侧边栏';

  @override
  String get sidebarBottomNavDoubleTapDescription => '双击底部导航以打开侧边栏';

  @override
  String get sidebarBottomNavSwipeDescription => '滑动底部导航以打开侧边栏';

  @override
  String get small => '小';

  @override
  String get somethingWentWrong => '哎呀，出了点问题！';

  @override
  String get sortBy => '排序方式';

  @override
  String get sortByTop => '按最佳排序';

  @override
  String get sortOptions => '排序选项';

  @override
  String get spoiler => '剧透';

  @override
  String get standard => '标准';

  @override
  String get stats => '统计';

  @override
  String get status => '状态';

  @override
  String get submit => '提交';

  @override
  String get subscribe => '订阅';

  @override
  String get subscribeToCommunity => '订阅社区';

  @override
  String get subscribed => '已订阅';

  @override
  String get subscriptionRequestSent => '订阅请求已发送';

  @override
  String get subscriptions => '订阅';

  @override
  String successfullyBannedUser(Object username) {
    return '已禁止 $username';
  }

  @override
  String get successfullyBlocked => '已屏蔽。';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return '已屏蔽 $communityName';
  }

  @override
  String successfullyBlockedUser(Object username) {
    return '已屏蔽 $username';
  }

  @override
  String successfullyUnbannedUser(Object username) {
    return '已解禁 $username';
  }

  @override
  String get successfullyUnblocked => '已解封。';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return '已解封 $communityName';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return '已解封 $username';
  }

  @override
  String get suchAs => '例如';

  @override
  String get suggestedTitle => '建议标题';

  @override
  String switchedAccount(Object username) {
    return '已切换到 $username';
  }

  @override
  String get system => '系统';

  @override
  String get systemDarkMode => '纯黑模式';

  @override
  String get systemDarkModeDescription => '在暗黑模式下启用纯黑主题';

  @override
  String get tabletMode => '平板模式（2 列视图）';

  @override
  String get tapToExit => '再次按返回键以退出';

  @override
  String get tappableAuthorCommunity => '可点击的作者和社区';

  @override
  String get teal => '青色';

  @override
  String get testBackgroundNotificationDescription =>
      'Thunder 将自行关闭，然后尝试在后台生成通知。（这将至少需要 15 分钟。）';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'Thunder 将请求通知服务器发送延迟通知，然后自行关闭。（这可能需要几分钟。）';

  @override
  String get text => '文本';

  @override
  String get textActions => '文本操作';

  @override
  String get theme => '主题';

  @override
  String get themeAccentColor => '强调颜色';

  @override
  String get themePrimary => '主题主色';

  @override
  String get themeSecondary => '主题次色';

  @override
  String get themeTertiary => '主题第三色';

  @override
  String get theming => '主题设置';

  @override
  String get thickness => '厚度';

  @override
  String get thisAccount => '此账号';

  @override
  String get thumbnailUrl => '缩略图 URL';

  @override
  String thunderHasBeenUpdated(Object version) {
    return 'Thunder 更新到 $version！';
  }

  @override
  String thunderNotificationServer(Object server) {
    return 'Thunder 通知服务器：$server';
  }

  @override
  String get timeoutComments => '错误：尝试获取评论时超时';

  @override
  String get timeoutErrorMessage => '等待响应时超时。';

  @override
  String get timeoutSaveComment => '错误：尝试保存评论时超时';

  @override
  String get timeoutSavingPost => '错误：尝试保存帖子时超时。';

  @override
  String get timeoutUpvoteComment => '错误：尝试对评论投票时超时';

  @override
  String get timeoutVotingPost => '错误：尝试对帖子投票时超时。';

  @override
  String get toggelRead => '切换已读';

  @override
  String get top => '最佳';

  @override
  String get topAll => '历史最佳';

  @override
  String get topDay => '今日最佳';

  @override
  String get topHour => '过去一小时最佳';

  @override
  String get topMonth => '本月最佳';

  @override
  String get topNineMonths => '过去 9 个月最佳';

  @override
  String get topSixHour => '过去 6 小时最佳';

  @override
  String get topSixMonths => '过去 6 个月最佳';

  @override
  String get topThreeMonths => '过去 3 个月最佳';

  @override
  String get topTwelveHour => '过去 12 小时最佳';

  @override
  String get topWeek => '本周最佳';

  @override
  String get topYear => '本年最佳';

  @override
  String totalComments(Object x) {
    return '$x 条评论';
  }

  @override
  String totalPosts(Object x) {
    return '$x 篇帖文';
  }

  @override
  String get totp => 'TOTP（可选）';

  @override
  String get transferredModToCommunity => '转移的社区';

  @override
  String get translationsMayNotBeComplete => '请注意，翻译可能不完整';

  @override
  String get trendingCommunities => '热门社区';

  @override
  String get trySearchingFor => '尝试搜索...';

  @override
  String get unableToFindCommunity => '无法找到社区';

  @override
  String unableToFindCommunityName(Object communityName) {
    return '无法找到社区 \'$communityName\'';
  }

  @override
  String get unableToFindCommunityOnInstance => '无法在所选用户的实例中找到所选社区。';

  @override
  String get unableToFindInstance => '无法找到实例';

  @override
  String get unableToFindLanguage => '无法找到语言';

  @override
  String get unableToFindPost => '无法找到帖子';

  @override
  String get unableToFindUser => '无法找到用户';

  @override
  String unableToFindUserName(Object username) {
    return '无法找到用户 \'$username\'';
  }

  @override
  String get unableToLoadImage => '无法加载图像';

  @override
  String unableToLoadImageFrom(Object domain) {
    return '无法从 $domain 加载图像';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return '无法加载 $instance';
  }

  @override
  String get unableToLoadPost => '无法加载帖文';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return '无法从 $instance 加载帖子';
  }

  @override
  String get unableToLoadReplies => '无法加载更多回复。';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return '无法导航到 $instanceHost。这可能不是有效的 Lemmy 实例。';
  }

  @override
  String get unableToResolveReport => '无法解析报告';

  @override
  String unableToRetrieveChangelog(Object version) {
    return '无法检索版本 $version 的变更日志。';
  }

  @override
  String get unbanFromCommunity => '从社区解除禁令';

  @override
  String get unbannedUser => '已解除用户禁令';

  @override
  String unbannedUserFromCommunity(Object username) {
    return '已解除 $username 在社区中的禁令';
  }

  @override
  String get unblock => '取消屏蔽';

  @override
  String get unblockCommunity => '解除社区禁令';

  @override
  String get unblockCommunityInstance => '解除社区实例禁令';

  @override
  String get unblockInstance => '解除实例禁令';

  @override
  String get unblockUser => '解除用户禁令';

  @override
  String get unblockUserInstance => '解除用户实例禁令';

  @override
  String get understandEnable => '我明白，启用';

  @override
  String get unexpectedError => '意外错误';

  @override
  String get unfavorite => '取消收藏';

  @override
  String get unfeaturedPost => '已取消特色帖子';

  @override
  String get unhidCommunity => '已取消隐藏社区';

  @override
  String get unhide => '取消隐藏';

  @override
  String unifiedPushDistributorApp(Object app, Object count) {
    return 'UnifiedPush 分发应用程序：$app ($count 可用)';
  }

  @override
  String get unifiedPushNotifications => 'UnifiedPush 通知';

  @override
  String unifiedPushServer(Object server) {
    return 'UnifiedPush 服务器：$server';
  }

  @override
  String get unifiedpush => 'UnifiedPush';

  @override
  String get unlockPost => '解锁帖子';

  @override
  String get unlockedPost => '已解锁帖子';

  @override
  String get unpinFromCommunity => '从社区取消固定';

  @override
  String get unpinPostFromCommunity => '从社区取消固定帖子';

  @override
  String get unpinnedPostFromCommunity => '已将帖文从社区取消置顶';

  @override
  String get unreachable => '无法访问';

  @override
  String get unresolved => '未解决';

  @override
  String get unsubscribe => '取消订阅';

  @override
  String get unsubscribeFromCommunity => '取消订阅社区';

  @override
  String get unsubscribePending => '取消订阅（订阅待处理）';

  @override
  String get unsubscribed => '已取消订阅';

  @override
  String updateReleased(Object version) {
    return '已发布更新：$version';
  }

  @override
  String get uploadImage => '上传图片';

  @override
  String uploadedDate(Object date) {
    return '已上传：$date';
  }

  @override
  String get upvote => '点赞';

  @override
  String get upvoteColor => '点赞颜色';

  @override
  String get upvoted => '已点赞';

  @override
  String get uriNotSupported => '此类型的链接目前不受支持。';

  @override
  String get url => '网址';

  @override
  String get useAdvancedShareSheet => '使用高级分享面板';

  @override
  String get useApplePushNotifications => '使用 APNs 通知';

  @override
  String get useApplePushNotificationsDescription => '使用苹果推送通知服务';

  @override
  String get useCompactView => '小帖子启用，大帖子禁用。';

  @override
  String get useLocalNotifications => '使用本地通知（实验性）';

  @override
  String get useLocalNotificationsDescription => '定期在后台检查通知';

  @override
  String get useMaterialYouTheme => '使用 Material You 主题';

  @override
  String get useMaterialYouThemeDescription => '覆盖所选的自定义主题';

  @override
  String get useProfilePictureForDrawer => '使用个人资料图片作为抽屉图标';

  @override
  String get useProfilePictureForDrawerSubtitle => '登录后，显示用户的个人资料图片以替代抽屉图标';

  @override
  String useSuggestedTitle(Object title) {
    return '使用建议标题：$title';
  }

  @override
  String get useUnifiedPushNotifications => '使用 UnifiedPush 通知';

  @override
  String get useUnifiedPushNotificationsDescription => '需要兼容的应用程序';

  @override
  String get user => '用户';

  @override
  String get userActions => '用户操作';

  @override
  String userEntry(Object username) {
    return '用户 \'$username\'';
  }

  @override
  String get userFormat => '用户格式';

  @override
  String get userLabelHint => '这是我最喜欢的用户';

  @override
  String get userLabels => '用户标签';

  @override
  String get userLabelsSettingsPageDescription => '您可以添加、修改或删除与用户相关的标签。';

  @override
  String get userNameColor => '用户名颜色';

  @override
  String get userNameThickness => '用户名粗细';

  @override
  String get userNotLoggedIn => '用户未登录';

  @override
  String get userProfiles => '用户资料';

  @override
  String get userSettingDescription => '这些设置与您的 Lemmy 账号同步，仅在每个账号基础上应用。';

  @override
  String get userStyle => '用户样式';

  @override
  String get username => '用户名';

  @override
  String get usernameFormattingRedirect => '寻找用户名格式化？';

  @override
  String get users => '用户';

  @override
  String versionNumber(Object version) {
    return '版本 $version';
  }

  @override
  String get video => '视频';

  @override
  String get videoAutoFullscreen => '自动全屏';

  @override
  String get videoAutoLoop => '循环视频';

  @override
  String get videoAutoMute => '静音视频';

  @override
  String get videoAutoPlay => '视频自动播放';

  @override
  String get videoDefaultPlaybackSpeed => '默认播放速度';

  @override
  String get videoLinkHandlingExternal => '使用外部应用播放视频';

  @override
  String get videoPlayerInApp => '使用 Thunder 内置播放器';

  @override
  String get videoPlayerMode => '播放器模式';

  @override
  String get viewAll => '查看全部';

  @override
  String get viewAllComments => '查看所有评论';

  @override
  String get viewCommentSource => '查看评论来源';

  @override
  String get viewModlog => '查看 Modlog';

  @override
  String get viewOriginal => '查看原文';

  @override
  String get viewPostAsDifferentAccount => '以不同账号查看帖子';

  @override
  String get viewPostSource => '查看帖子来源';

  @override
  String get viewSource => '查看源代码';

  @override
  String get viewingAll => '查看全部';

  @override
  String visibility(Object visibility) {
    return '可见性：$visibility';
  }

  @override
  String get visitCommunity => '访问社区';

  @override
  String get visitCommunityInstance => '访问社区实例';

  @override
  String get visitInstance => '访问实例';

  @override
  String get visitUserInstance => '访问用户实例';

  @override
  String get visitUserProfile => '访问用户资料';

  @override
  String get warning => '警告';

  @override
  String xDownvotes(Object x) {
    return '$x 个点踩';
  }

  @override
  String xScore(Object x) {
    return '$x 分';
  }

  @override
  String xUpvotes(Object x) {
    return '$x 个点赞';
  }

  @override
  String xYearsOld(num count, Object x) {
    return '$x 岁';
  }

  @override
  String get yes => '是';

  @override
  String get youMustSelectAJsonFile => '您必须选择一个 .json 文件。';
}
