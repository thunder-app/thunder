// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get about => 'Over';

  @override
  String get accept => 'Accepteren';

  @override
  String get accessibility => 'Toegankelĳkheid';

  @override
  String get accessibilityProfilesDescription =>
      'Met toegankelĳkheids­profielen kunt u meerdere instellingen tegelĳk toepassen om aan een specifieke toegankelĳkheids­vereiste te voldoen.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Accounts',
      one: 'Account',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'Account­verjaardag $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'Uw account­instellingen hebben voorrang op de volgende instellingen';

  @override
  String get accountSettings => 'Account­instellingen';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'Lemmy-account­instellingen zijn succesvol geëxporteerd naar $savedFilePath!';
  }

  @override
  String get accountSettingsImportedSuccessfully =>
      'Lemmy-account­instellingen succesvol geïmporteerd!';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return 'De geselecteerde opmerking is niet gevonden op ‘$instance’. Terug­schakelen naar het vorige account.';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'The selected post was not found on \'$instance\'. Switching back to previous account.';
  }

  @override
  String get actionColors => 'Actie­kleuren';

  @override
  String get actionColorsRedirect => 'Looking to customize colors?';

  @override
  String get actions => 'Acties';

  @override
  String get active => 'Actief';

  @override
  String get activity => 'Activiteit';

  @override
  String get add => 'Toe­voegen';

  @override
  String get addAccount => 'Account toevoegen';

  @override
  String get addAccountToSeeProfile => 'Log in to see your account.';

  @override
  String get addAnonymousInstance => 'Anonieme instantie toevoegen';

  @override
  String get addAsCommunityModerator => 'Add as Community Moderator';

  @override
  String get addDiscussionLanguage => 'Taal toevoegen';

  @override
  String get addKeywordFilter => 'Sleutel­woord toevoegen';

  @override
  String get addOriginalPostBody => 'Add original post body?';

  @override
  String get addToFavorites => 'Toevoegen aan favorieten';

  @override
  String get addUserLabel => 'Gebruikers­label toevoegen';

  @override
  String get addedCommunityToSubscriptions => 'Geabonneerd op gemeenschap';

  @override
  String get addedInstanceMod => 'Instantie­moderator toegevoegd';

  @override
  String get addedModToCommunity => 'Added Mod to Community';

  @override
  String get admin => 'Administrator';

  @override
  String get advanced => 'Geavanceerd';

  @override
  String ago(Object time) {
    return '$time geleden';
  }

  @override
  String get all => 'Alles';

  @override
  String get allPosts => 'Alle berichten';

  @override
  String get allowOpenSupportedLinks => 'Allow app to open supported links.';

  @override
  String get alreadyPostedTo => 'Al geplaatst in';

  @override
  String get altText => 'Alternatieve tekst';

  @override
  String get alternateSources => 'Alternatieve bronnen';

  @override
  String get always => 'Altĳd';

  @override
  String andXMore(Object count) {
    return 'en nog $count';
  }

  @override
  String get animations => 'Animaties';

  @override
  String get anonymous => 'Anoniem';

  @override
  String get anonymousInstances => 'Anonieme instanties';

  @override
  String get appLanguage => 'App-taal';

  @override
  String get appearance => 'Weergave';

  @override
  String get applePushNotificationService => 'Apple Push Notification Service';

  @override
  String get applied => 'Toegepast';

  @override
  String get apply => 'Toepassen';

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
  String get back => 'Terug';

  @override
  String get backButton => 'Terug­knop';

  @override
  String get backToTop => 'Terug naar boven';

  @override
  String get backgroundCheckWarning =>
      'Note that notification checks will consume additional battery';

  @override
  String get banFromCommunity => 'Verbannen van gemeen­schap';

  @override
  String get bannedUser => 'Verbannen gebruiker';

  @override
  String get bannedUserFromCommunity => 'Banned User from Community';

  @override
  String get base => 'Basis';

  @override
  String get block => 'Block';

  @override
  String get blockCommunity => 'Gemeenschap blokkeren';

  @override
  String get blockCommunityInstance => 'Gemeenschaps­instantie blokkeren';

  @override
  String get blockInstance => 'Instantie blokkeren';

  @override
  String get blockManagement => 'Blokkade­beheer';

  @override
  String get blockSettingLabel => 'Gebruiker-/gemeenschap-/instantie­blokkades';

  @override
  String get blockUser => 'Gebruiker blokkeren';

  @override
  String get blockUserInstance => 'Gebruikers­instantie blokkeren';

  @override
  String get blockedCommunities => 'Geblokkeerde gemeenschappen';

  @override
  String get blockedInstances => 'Geblokkeerde instanties';

  @override
  String get blockedUsers => 'Geblokkeerde gebruikers';

  @override
  String get blue => 'Blauw';

  @override
  String get bold => 'Vetgedrukt';

  @override
  String get boldCommunityName => 'Vet­gedrukte gemeenschaps­naam';

  @override
  String get boldInstanceName => 'Vet­gedrukte instantie­naam';

  @override
  String get boldUserName => 'Vet­gedrukte gebruikers­naam';

  @override
  String get bot => 'Bot';

  @override
  String get browserMode => 'Koppelings­verwerking';

  @override
  String browsingAnonymously(Object instance) {
    return 'You are currently browsing $instance anonymously.';
  }

  @override
  String get cancel => 'Annuleren';

  @override
  String get cannotReportOwnComment =>
      'You may not submit a report for your own comment.';

  @override
  String get cantBlockAdmin => 'You may not block an instance administrator.';

  @override
  String get cantBlockYourself => 'You may not block yourself.';

  @override
  String get cardPostCardMetadataItems => 'Meta­gegevens in kaart­weergave';

  @override
  String get cardView => 'Kaart­weergave';

  @override
  String get cardViewDescription => 'Enable card view to adjust settings';

  @override
  String get cardViewSettings => 'Card View Settings';

  @override
  String get changeAccountSettingsFor => 'Change account settings for';

  @override
  String get changeNotificationSettings => 'Change notification settings...';

  @override
  String get changePassword => 'Wachtwoord wĳzigen';

  @override
  String get changePasswordWarning =>
      'To change your password, you will be redirected to your instance site. \n\nAre you sure you want to continue?';

  @override
  String get changeSort => 'Sortering wĳzigen';

  @override
  String clearCache(Object cacheSize) {
    return 'Clear Cache ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Cache wissen';

  @override
  String get clearDatabase => 'Database wissen';

  @override
  String get clearPreferences => 'Voorkeuren wissen';

  @override
  String get clearSearch => 'Zoek­opdrachten wissen';

  @override
  String get clearedCache => 'Cleared cache successfully.';

  @override
  String get clearedDatabase =>
      'Local database cleared. Restart Thunder for new changes to take effect.';

  @override
  String get clearedUserPreferences => 'Cleared all user preferences';

  @override
  String get close => 'Sluiten';

  @override
  String get collapse => 'Inklappen';

  @override
  String get collapseCommentPreview => 'Collapse Comment Preview';

  @override
  String get collapseInformation => 'Informatie samen­vouwen';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Hide Parent Comment when Collapsed';

  @override
  String get collapsePost => 'Bericht samen­vouwen';

  @override
  String get collapsePostPreview => 'Collapse Post Preview';

  @override
  String get collapseSpoiler => 'Spoiler samen­vouwen';

  @override
  String get color => 'Kleur';

  @override
  String get colorizeCommunityName => 'Colorize Community Name';

  @override
  String get colorizeInstanceName => 'Colorize Instance Name';

  @override
  String get colorizeUserName => 'Colorize User Name';

  @override
  String get colors => 'Kleuren';

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
  String get comfortable => 'Comfortabel';

  @override
  String get comment => 'Opmerking';

  @override
  String get commentBehaviourSettings => 'Opmerkingen';

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
  String get comments => 'Opmerkingen';

  @override
  String get communities => 'Gemeen­schappen';

  @override
  String get community => 'Gemeen­schap';

  @override
  String get communityActions => 'Gemeenschaps­acties';

  @override
  String communityEntry(Object community) {
    return 'Gemeenschap ‘$community’';
  }

  @override
  String get communityFormat => 'Gemeenschaps­formaat';

  @override
  String get communityNameColor => 'Community Name Color';

  @override
  String get communityNameThickness => 'Community Name Thickness';

  @override
  String get communityStyle => 'Gemeenschaps­stĳl';

  @override
  String get compact => 'Compact';

  @override
  String get compactPostCardMetadataItems => 'Compact View Metadata';

  @override
  String get compactView => 'Compacte weergave';

  @override
  String get compactViewDescription => 'Enable compact view to adjust settings';

  @override
  String get compactViewSettings => 'Compact View Settings';

  @override
  String get condensed => 'Beknopt';

  @override
  String get confirm => 'Bevestigen';

  @override
  String get confirmLogOutBody => 'Are you sure you want to log out?';

  @override
  String get confirmLogOutTitle => 'Uit­loggen?';

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
  String get contentManagement => 'Inhouds­beheer';

  @override
  String get contentWarning => 'Inhouds­waarschuwing';

  @override
  String get controversial => 'Controversieel';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copy => 'Kopiëren';

  @override
  String get copyComment => 'Opmerking kopiëren';

  @override
  String get copySelected => 'Geselecteerde tekst kopiëren';

  @override
  String get copyText => 'Tekst kopiëren';

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
    return '$count opmerkingen';
  }

  @override
  String countLocalSubscribers(Object count) {
    return '$count Local Subscribers';
  }

  @override
  String countPosts(Object count) {
    return '$count berichten';
  }

  @override
  String countSubscribers(Object count) {
    return '$count abonnees';
  }

  @override
  String countUsers(Object count) {
    return '$count gebruikers';
  }

  @override
  String countUsersActiveDay(Object count) {
    return '$count gebruikers/dag';
  }

  @override
  String countUsersActiveHalfYear(Object count) {
    return '$count users/6 mo';
  }

  @override
  String countUsersActiveMonth(Object count) {
    return '$count gebruikers/maand';
  }

  @override
  String countUsersActiveWeek(Object count) {
    return '$count gebruikers/week';
  }

  @override
  String get createAccount => 'Account aan­maken';

  @override
  String get createComment => 'Opmerking plaatsen';

  @override
  String get createNewCrossPost => 'Create new cross-post';

  @override
  String get createPost => 'Bericht plaatsen';

  @override
  String created(Object date) {
    return 'Geplaatst op $date';
  }

  @override
  String get createdToday => 'Vandaag geplaatst';

  @override
  String get creator => 'Maker';

  @override
  String crossPostedFrom(Object postUrl) {
    return 'cross-posted from:  $postUrl';
  }

  @override
  String get crossPostedTo => 'Gekruisplaatst naar';

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
  String get dangerZone => 'Gevaren­zone';

  @override
  String get dark => 'Donker';

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
  String get dateFormat => 'Datum­formaat';

  @override
  String get debug => 'Fout­opsporing';

  @override
  String get debugDescription =>
      'The following debug settings should only be used for troubleshooting purposes.';

  @override
  String get debugNotificationsDescription =>
      'Use the following options to troubleshoot issues related to notifications.';

  @override
  String get decline => 'Afwĳzen';

  @override
  String get defaultColor => 'Standaard';

  @override
  String get defaultCommentSortType => 'Default Comment Sort Type';

  @override
  String get defaultFeedSortType => 'Default Feed Sort Type';

  @override
  String get defaultFeedType => 'Default Feed Type';

  @override
  String get delete => 'Verwĳderen';

  @override
  String get deleteAccount => 'Account verwĳderen';

  @override
  String get deleteAccountDescription =>
      'To permanently delete your account, you will be redirected to your instance site. \n\nAre you sure you want to continue?';

  @override
  String get deleteComment => 'Opmerking verwĳderen';

  @override
  String get deleteImageConfirmMessage =>
      'Are you sure you want to delete this image?';

  @override
  String get deleteImageConfirmTitle => 'Verwĳderen?';

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
  String get deletePost => 'Bericht verwĳderen';

  @override
  String get deleteUserLabelConfirmation =>
      'Are you sure you want to delete the label?';

  @override
  String get deleted => 'Verwĳderd';

  @override
  String get deletedByCreator => 'deleted by creator';

  @override
  String get deletedByModerator => 'deleted by moderator';

  @override
  String get deselectUndeterminedWarning =>
      'If you deselect Undetermined, you will not see most content.';

  @override
  String detailedReason(Object reason) {
    return 'Reden: $reason';
  }

  @override
  String get dimReadPosts => 'Dim Read Posts';

  @override
  String get disable => 'Uitschakelen';

  @override
  String get disablePushNotifications => 'Disable Push Notifications';

  @override
  String get disabled => 'Uitgeschakeld';

  @override
  String get discussionLanguages => 'Discussie­talen';

  @override
  String get discussionLanguagesTooltip =>
      'Content is filtered to the selected languages.';

  @override
  String get dismissRead => 'Gelezen items afwĳzen';

  @override
  String get displayName => 'Weergave­naam';

  @override
  String get displayUserScore => 'Display User Scores (Karma).';

  @override
  String get dividerAppearance => 'Verdeler­weergave';

  @override
  String get doNotShowAgain => 'Do Not Show Again';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Found multiple compatible apps; please install only one';

  @override
  String get downloadingMedia => 'Downloading media to share…';

  @override
  String get downvote => 'Downvoten';

  @override
  String get downvoteColor => 'Downvote-kleur';

  @override
  String get downvoted => 'Gedownvotet';

  @override
  String get downvotesDisabled => 'Downvotes are turned off on this instance.';

  @override
  String get edit => 'Bewerken';

  @override
  String get editComment => 'Opmerking bewerken';

  @override
  String get editPost => 'Bericht bewerken';

  @override
  String get email => 'E-mail';

  @override
  String get empty => 'Leeg';

  @override
  String get emptyInbox => 'Postvak IN legen';

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
  String get endSearch => 'Stoppen met zoeken';

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
  String get expand => 'Uitvouwen';

  @override
  String get expandCommentPreview => 'Expand Comment Preview';

  @override
  String get expandInformation => 'Informatie uitvouwen';

  @override
  String get expandOptions => 'Opties uitvouwen';

  @override
  String get expandPost => 'Bericht uitvouwen';

  @override
  String get expandPostPreview => 'Expand Post Preview';

  @override
  String get expandSpoiler => 'Spoiler uitvouwen';

  @override
  String get expanded => 'Uitgevouwen';

  @override
  String get experimentalFeatures => 'Experimentele functies';

  @override
  String get experimentalFeaturesDescription =>
      'These features are still in development and may be unstable. Use them at your own risk. You must restart Thunder to take effect.';

  @override
  String get exploreInstance => 'Instantie verkennen';

  @override
  String get exportDatabase => 'Database exporteren';

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
  String get extraLarge => 'Extra groot';

  @override
  String failedToBlock(Object errorMessage) {
    return 'Failed to block: $errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return 'Failed to communicate with Thunder notification server at \'$serverAddress\'';
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
  String get favorites => 'Favorieten';

  @override
  String get featuredPost => 'Uitgelicht bericht';

  @override
  String get feed => 'Feed';

  @override
  String get feedBehaviourSettings => 'Feed';

  @override
  String get feedSettings => 'Feed-instellingen';

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
  String get fonts => 'Letter­typen';

  @override
  String get forward => 'Vooruit';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Found compatible app; restart Thunder to connect';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Swipe anywhere to go back when left-to-right gestures are disabled';

  @override
  String get fullscreenSwipeGestures => 'Fullscreen Swipe Gestures';

  @override
  String get general => 'Algemeen';

  @override
  String get generalSettings => 'Algemene instellingen';

  @override
  String get gestures => 'Gebaren';

  @override
  String get gettingStarted => 'Aan de slag';

  @override
  String get green => 'Groen';

  @override
  String get guestModeFeedSettings => 'Guest Mode Feed Settings';

  @override
  String get guestModeFeedSettingsLabel =>
      'The following settings are only applied to guest accounts. To adjust feed settings for your account, go to Account Settings.';

  @override
  String get havingIssuesWithNotifications =>
      'Having issues with notifications?';

  @override
  String get hidCommunity => 'Heeft gemeen­schap verborgen';

  @override
  String get hidden => 'Verborgen';

  @override
  String get hide => 'Verbergen';

  @override
  String get hideColor => 'Kleur verbergen';

  @override
  String get hideNsfwPostsFromFeed => 'Hide NSFW Posts from Feed';

  @override
  String get hideNsfwPreviews => 'Blur NSFW Previews';

  @override
  String get hidePassword => 'Wachtwoord verbergen';

  @override
  String get hideThumbnails => 'Miniaturen verbergen';

  @override
  String get hideTopBarOnScroll => 'Hide Top Bar on Scroll';

  @override
  String get hostInstance => 'Host-instantie';

  @override
  String get hot => 'Populair';

  @override
  String get image => 'Afbeelding';

  @override
  String get imageCachingMode => 'Image Caching Mode';

  @override
  String get imageCachingModeAggressive =>
      'Aggressively cache images (uses more memory)';

  @override
  String get imageCachingModeAggressiveShort => 'Agressief';

  @override
  String get imageCachingModeRelaxed =>
      'Let image caches expire (uses less memory but causes images to reload more often)';

  @override
  String get imageCachingModeRelaxedShort => 'Ontspannen';

  @override
  String get imageDimensionTimeout => 'Image Dimension Timeout';

  @override
  String get importDatabase => 'Database importeren';

  @override
  String get importExportDatabase => 'Import/Export Thunder Database';

  @override
  String get importExportLemmyAccountSettings =>
      'Import/Export Lemmy Account Settings';

  @override
  String get importExportLemmyAccountSettingsSubtitle =>
      'Includes subscribed communities, blocklists, and account preferences';

  @override
  String get importExportSettings => 'Instellingen importeren/exporteren';

  @override
  String get importExportThunderSettings => 'Import/Export Thunder Settings';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Import Lemmy account settings';

  @override
  String get importSettings => 'Instellingen importeren';

  @override
  String inReplyTo(Object community, Object post) {
    return 'In reply to $post in $community';
  }

  @override
  String get in_ => 'in';

  @override
  String get inbox => 'Postvak IN';

  @override
  String get includeCommunity => 'Gemeen­schap bĳvoegen';

  @override
  String get includeExternalLink => 'Include External Link';

  @override
  String get includeImage => 'Afbeelding bĳvoegen';

  @override
  String get includePostLink => 'Include Post Link';

  @override
  String get includeText => 'Tekst bĳvoegen';

  @override
  String get includeTitle => 'Titel bĳvoegen';

  @override
  String get information => 'Informatie';

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
  String get instanceActions => 'Instantie­acties';

  @override
  String instanceEntry(Object username) {
    return 'Instantie ‘$username’';
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
  String get instances => 'Instanties';

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
  String get keywordFilters => 'Trefwoord­filters';

  @override
  String get label => 'Label';

  @override
  String get language => 'Taal';

  @override
  String get languageFilters => 'Looking for language filters?';

  @override
  String get languageNotAllowed =>
      'The community you are posting to does not allow posts in the language that you have selected. Try another language.';

  @override
  String get large => 'Groot';

  @override
  String get leftLongSwipe => 'Left Long Swipe';

  @override
  String get leftShortSwipe => 'Left Short Swipe';

  @override
  String get light => 'Licht';

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
  String get linkActions => 'Link­acties';

  @override
  String get linkHandlingCustomTabs => 'Open in system browser embedded in-app';

  @override
  String get linkHandlingCustomTabsShort => 'In-app ingebed';

  @override
  String get linkHandlingExternal => 'Open in system browser externally';

  @override
  String get linkHandlingExternalShort => 'Extern';

  @override
  String get linkHandlingInApp => 'Use Thunder\'s built-in browser';

  @override
  String get linkHandlingInAppShort => 'Intern';

  @override
  String get linksBehaviourSettings => 'Koppelingen';

  @override
  String loadMorePlural(Object count) {
    return 'Load $count more replies…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Load $count more reply…';
  }

  @override
  String get loading => 'Aan het laden…';

  @override
  String get local => 'Lokaal';

  @override
  String get localNotifications => 'Lokale meldingen';

  @override
  String get localOnly => 'Enkel lokaal';

  @override
  String get localPosts => 'Lokale berichten';

  @override
  String get lockPost => 'Bericht vergrendelen';

  @override
  String get locked => 'Vergrendeld';

  @override
  String get lockedPost => 'Vergrendeld bericht';

  @override
  String get logOut => 'Uitloggen';

  @override
  String get login => 'Inloggen';

  @override
  String get loginAttemptCanceled => 'Login attempt canceled.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Could not log in. Please try again. (Error: $errorMessage)';
  }

  @override
  String get loginSucceeded => 'Ingelogd.';

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
  String get manageAccounts => 'Accounts beheren';

  @override
  String get manageMedia => 'Media beheren';

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
  String get matrixUser => 'Matrix­gebruiker';

  @override
  String get me => 'Ik';

  @override
  String get medium => 'Gemiddeld';

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
  String get moderatedCommunities => 'Gemodereerde gemeen­schappen';

  @override
  String get moderates => 'Moderator van';

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
  String get moderatorActions => 'Moderator­acties';

  @override
  String get modlog => 'Moderator­logboek';

  @override
  String get mostComments => 'Meeste opmerkingen';

  @override
  String get mustBeLoggedIn => 'You need to be logged in';

  @override
  String get mustBeLoggedInComment => 'You need to be logged in to comment';

  @override
  String get mustBeLoggedInPost => 'You need to be logged in to create a post';

  @override
  String get names => 'Namen';

  @override
  String get navbarDoubleTapGestures => 'Navbar Double Tap Gestures';

  @override
  String get navbarSwipeGestures => 'Navbar Swipe Gestures';

  @override
  String get navigateDown => 'Volgende opmerking';

  @override
  String get navigateUp => 'Vorige opmerking';

  @override
  String get navigation => 'Navigatie';

  @override
  String get nestedCommentIndicatorColor => 'Nested Comment Indicator Color';

  @override
  String get nestedCommentIndicatorStyle => 'Nested Comment Indicator Style';

  @override
  String get never => 'Nooit';

  @override
  String get newComments => 'Nieuwe opmerkingen';

  @override
  String get newPost => 'Nieuw bericht';

  @override
  String get new_ => 'Nieuw';

  @override
  String get no => 'Nee';

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
  String get noItems => 'Geen items';

  @override
  String get noKeywordFilters => 'No keyword filters added';

  @override
  String get noLanguage => 'Geen taal';

  @override
  String get noMatrixUserSet => 'No matrix user set';

  @override
  String get noMentions => 'Geen vermeldingen';

  @override
  String get noMessages => 'Geen berichten';

  @override
  String get noPostsFound => 'No posts found.';

  @override
  String get noProfileBioSet => 'No profile bio set';

  @override
  String get noReferencesToImage =>
      'No posts or comments were found containing this image. However, it may be used elsewhere on the internet.';

  @override
  String get noReplies => 'Geen reacties';

  @override
  String get noResultsFound => 'No results found.';

  @override
  String get noSubscriptions => 'Geen abonnementen';

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
  String get none => 'Geen';

  @override
  String get normal => 'Normaal';

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
  String get notificationsBehaviourSettings => 'Meldingen';

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
  String get off => 'uit';

  @override
  String get offline => 'offline';

  @override
  String get ok => 'Oké';

  @override
  String get old => 'Oud';

  @override
  String get on => 'aan';

  @override
  String get onWifi => 'Op wifi';

  @override
  String get onlyModsCanPostInCommunity =>
      'Only moderators may post in this community';

  @override
  String get open => 'Openen';

  @override
  String get openAccountSwitcher => 'Open account switcher';

  @override
  String get openByDefault => 'Open by default';

  @override
  String get openInBrowser => 'Open in Browser';

  @override
  String get openInstance => 'Instantie openen';

  @override
  String get openLinksInExternalBrowser => 'Open Links in External Browser';

  @override
  String get openLinksInReaderMode => 'Open Links in Reader Mode';

  @override
  String get openSettings => 'Instellingen openen';

  @override
  String get orange => 'Oranje';

  @override
  String get originalPoster => 'Originele plaatser';

  @override
  String get overview => 'Overzicht';

  @override
  String get password => 'Wacht­woord';

  @override
  String get pending => 'In behandeling';

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
  String get placeholderText =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  @override
  String get post => 'Bericht';

  @override
  String get postActions => 'Bericht­acties';

  @override
  String get postBehaviourSettings => 'Berichten';

  @override
  String get postBody => 'Bericht­inhoud';

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
  String get postTitle => 'Titel';

  @override
  String get postTitleFontScale => 'Post Title Font Scale';

  @override
  String get postTogglePreview => 'Voor­vertoning omschakelen';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Could not upload image';

  @override
  String get postViewType => 'Post View Type';

  @override
  String get posts => 'Berichten';

  @override
  String get preview => 'Voor­vertoning';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile applied successfully!';
  }

  @override
  String get profileBio => 'Profiel­biografie';

  @override
  String get profiles => 'Profielen';

  @override
  String get public => 'Openbaar';

  @override
  String get pureBlack => 'Puur zwart';

  @override
  String get purgedComment => 'Purged Comment';

  @override
  String get purgedCommunity => 'Purged Community';

  @override
  String get purgedPerson => 'Purged Person';

  @override
  String get purgedPost => 'Purged Post';

  @override
  String get purple => 'Paars';

  @override
  String get pushNotification => 'Push­meldingen';

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
  String get read => 'Gelezen';

  @override
  String get readAll => 'Alles lezen';

  @override
  String get readerMode => 'Lezer­modus';

  @override
  String get reason => 'Reden';

  @override
  String get red => 'Rood';

  @override
  String get reduceAnimations => 'Animaties verminderen';

  @override
  String get reducesAnimations => 'Reduces the animations used within Thunder';

  @override
  String get refresh => 'Vernieuwen';

  @override
  String get refreshContent => 'Inhoud verversen';

  @override
  String get removalReason => 'Reden voor verwĳdering';

  @override
  String get remove => 'Verwĳderen';

  @override
  String get removeAccount => 'Account verwĳderen';

  @override
  String get removeAsCommunityModerator => 'Remove as Community Moderator';

  @override
  String get removeComment => 'Opmerking verwĳderen';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get removeInstance => 'Instantie verwĳderen';

  @override
  String removeKeyword(Object keyword) {
    return '‘$keyword’ verwĳderen?';
  }

  @override
  String get removeKeywordFilter => 'Tref­woord verwĳderen';

  @override
  String get removePost => 'Bericht verwĳderen';

  @override
  String get removed => 'Verwĳderd';

  @override
  String get removedComment => 'Verwĳderde opmerking';

  @override
  String get removedCommunity => 'Gemeen­schap verwĳderd';

  @override
  String get removedCommunityFromSubscriptions => 'Unsubscribed from community';

  @override
  String get removedInstanceMod => 'Removed Instance Mod';

  @override
  String get removedModFromCommunity => 'Removed Mod from Community';

  @override
  String get removedPost => 'Bericht verwĳderd';

  @override
  String get reorder => 'Opnieuw ordenen';

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
  String get replyColor => 'Reactie­kleur';

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
  String get reportComment => 'Opmerking rapporteren';

  @override
  String get reportPost => 'Bericht rapporteren';

  @override
  String get reporter => 'Rapporteerder:';

  @override
  String get requiredField => '*vereist';

  @override
  String get reset => 'Opnieuw instellen';

  @override
  String get resetCommentPreferences => 'Reset comment preferences';

  @override
  String get resetPostPreferences => 'Reset post preferences';

  @override
  String get resetPreferences => 'Voorkeuren resetten';

  @override
  String get resetPreferencesAndData => 'Reset Preferences and Data';

  @override
  String get restore => 'Herstellen';

  @override
  String get restoreComment => 'Opmerking herstellen';

  @override
  String get restorePost => 'Bericht herstellen';

  @override
  String get restoredComment => 'Opmerking hersteld';

  @override
  String get restoredCommentFromDraft => 'Restored comment from draft';

  @override
  String get restoredCommunity => 'Gemeenschap hersteld';

  @override
  String get restoredPost => 'Bericht hersteld';

  @override
  String get restoredPostFromDraft => 'Restored post from draft';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get rightLongSwipe => 'Right Long Swipe';

  @override
  String get rightShortSwipe => 'Right Short Swipe';

  @override
  String get save => 'Opslaan';

  @override
  String get saveColor => 'Opslaan-kleur';

  @override
  String get saveSettings => 'Instellingen opslaan';

  @override
  String get saved => 'Opgeslagen';

  @override
  String get scaled => 'Geschaald';

  @override
  String get scrapeMissingLinkPreviews => 'Scrape Missing Link Previews';

  @override
  String get screenReaderProfile => 'Screen Reader Profile';

  @override
  String get screenReaderProfileDescription =>
      'Optimizes Thunder for screen readers by reducing overall elements and removing potentially conflicting gestures.';

  @override
  String get search => 'Zoeken';

  @override
  String get searchByText => 'Search by text';

  @override
  String get searchByUrl => 'Search by URL';

  @override
  String get searchComments => 'Opmerkingen zoeken';

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
    return '$instance doorzoeken';
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
  String get searchTerm => 'Zoek­term';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Search for users federated with $instance';
  }

  @override
  String get selectAccountToCommentAs => 'Select account to comment as';

  @override
  String get selectAccountToPostAs => 'Select account to post as';

  @override
  String get selectAll => 'Alles selecteren';

  @override
  String get selectCommunity => 'Select a community (required)';

  @override
  String get selectFeedType => 'Select Feed Type';

  @override
  String get selectLanguage => 'Taal selecteren';

  @override
  String get selectSearchType => 'Select Search Type';

  @override
  String get selectText => 'Tekst selecteren';

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
  String get setAction => 'Actie instellen';

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
  String get settings => 'Instellingen';

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
  String get settingsPageAbout => 'Over';

  @override
  String get settingsPageAccessibility => 'Toegankelĳkheid';

  @override
  String get settingsPageAccount => 'Account';

  @override
  String get settingsPageAccountBlocks => 'Blokkerings­lĳsten';

  @override
  String get settingsPageAccountLanguages => 'Discussion Languages';

  @override
  String get settingsPageAccountMedia => 'Manage Media';

  @override
  String get settingsPageAppearance => 'Uiterlĳk';

  @override
  String get settingsPageAppearanceComments => 'Opmerkingen';

  @override
  String get settingsPageAppearancePosts => 'Berichten';

  @override
  String get settingsPageAppearanceTheming => 'Theming';

  @override
  String get settingsPageDebug => 'Fout­opsporing';

  @override
  String get settingsPageFilters => 'Filters';

  @override
  String get settingsPageFloatingActionButton => 'Floating Action Button';

  @override
  String get settingsPageGeneral => 'Algemeen';

  @override
  String get settingsPageGestures => 'Gebaren';

  @override
  String get settingsPageUserLabels => 'User Labels';

  @override
  String get settingsPageVideo => 'Video';

  @override
  String get share => 'Delen';

  @override
  String get shareComment => 'Share Comment Link';

  @override
  String get shareCommentLocal => 'Share Comment Link (My Instance)';

  @override
  String get shareCommunity => 'Gemeenschap delen';

  @override
  String get shareCommunityLink => 'Share Community Link';

  @override
  String get shareCommunityLinkLocal => 'Share Community Link (My Instance)';

  @override
  String get shareImage => 'Afbeelding delen';

  @override
  String get shareLemmyLink => 'Share Lemmy Link';

  @override
  String get shareLink => 'Share External Link';

  @override
  String get shareMedia => 'Media delen';

  @override
  String get shareMediaLink => 'Share Media Link';

  @override
  String get shareOriginalLink => 'Share Original Link';

  @override
  String get sharePost => 'Share Post Link';

  @override
  String get sharePostLocal => 'Share Post Link (My Instance)';

  @override
  String get shareThumbnail => 'Miniatuur delen';

  @override
  String get shareThumbnailAsImage => 'Share Thumbnail As Image';

  @override
  String get shareUser => 'Gebruiker delen';

  @override
  String get shareUserLink => 'Share User Link';

  @override
  String get shareUserLinkLocal => 'Share User Link (My Instance)';

  @override
  String get showAll => 'Alles tonen';

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
  String get showLess => 'Minder tonen';

  @override
  String get showMore => 'Meer tonen';

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
  String get showPassword => 'Wacht­woord tonen';

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
  String get sidebar => 'Zĳbalk';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Double-tap bottom nav to open sidebar';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Swipe bottom nav to open sidebar';

  @override
  String get small => 'Klein';

  @override
  String get somethingWentWrong => 'Oops, something went wrong!';

  @override
  String get sortBy => 'Sorteren op';

  @override
  String get sortByTop => 'Sort by Top';

  @override
  String get sortOptions => 'Sorteer­instellingen';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get standard => 'Standaard';

  @override
  String get stats => 'Statistieken';

  @override
  String get status => 'Status';

  @override
  String get submit => 'Indienen';

  @override
  String get subscribe => 'Abonneren';

  @override
  String get subscribeToCommunity => 'Subscribe to Community';

  @override
  String get subscribed => 'Geabonneerd';

  @override
  String get subscriptionRequestSent => 'Subscription request sent';

  @override
  String get subscriptions => 'Abonnementen';

  @override
  String successfullyBannedUser(Object username) {
    return '$username verbannen';
  }

  @override
  String get successfullyBlocked => 'Geblokkeerd.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return '$communityName geblokkeerd';
  }

  @override
  String successfullyBlockedUser(Object username) {
    return '$username geblokkeerd';
  }

  @override
  String successfullyUnbannedUser(Object username) {
    return 'Verbanning van $username opgeheven';
  }

  @override
  String get successfullyUnblocked => 'Gedeblokkeerd.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return 'Blokkering van $communityName opgeheven';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return 'Blokkering van $username opgeheven';
  }

  @override
  String get suchAs => 'zoals';

  @override
  String get suggestedTitle => 'Voor­gestelde titel';

  @override
  String switchedAccount(Object username) {
    return 'Switched to $username';
  }

  @override
  String get system => 'Systeem';

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
  String get teal => 'Blauw­groen';

  @override
  String get testBackgroundNotificationDescription =>
      'Thunder will close itself and then attempt to generate a notification in the background. (It will take at least 15 minutes.)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'Thunder will ask the notification server to send a delayed notification and then close itself. (It may take a few minutes.)';

  @override
  String get text => 'Tekst';

  @override
  String get textActions => 'Tekst­acties';

  @override
  String get theme => 'Thema';

  @override
  String get themeAccentColor => 'Accent­kleuren';

  @override
  String get themePrimary => 'Thema (primair)';

  @override
  String get themeSecondary => 'Thema (secundair)';

  @override
  String get themeTertiary => 'Thema (tertiair)';

  @override
  String get theming => 'Thematiek';

  @override
  String get thickness => 'Dikte';

  @override
  String get thisAccount => 'Dit account';

  @override
  String get thumbnailUrl => 'Miniatuur-URL';

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
  String get toggelRead => 'Gelezen omschakelen';

  @override
  String get top => 'Beste';

  @override
  String get topAll => 'Top of all time';

  @override
  String get topDay => 'Beste vandaag';

  @override
  String get topHour => 'Top in Past Hour';

  @override
  String get topMonth => 'Beste afgelopen maand';

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
  String get topWeek => 'Beste afgelopen week';

  @override
  String get topYear => 'Beste afgelopen jaar';

  @override
  String totalComments(Object x) {
    return '$x Comments';
  }

  @override
  String totalPosts(Object x) {
    return '$x Posts';
  }

  @override
  String get totp => 'TOTP (optioneel)';

  @override
  String get transferredModToCommunity => 'Gemeen­schap over­gedragen';

  @override
  String get translationsMayNotBeComplete =>
      'Please note that the translations may not be complete';

  @override
  String get trendingCommunities => 'Trending gemeen­schappen';

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
  String get unbannedUser => 'Verbanning van gebruiker opgeheven';

  @override
  String get unbannedUserFromCommunity => 'Unbanned User from Community';

  @override
  String get unblock => 'Unblock';

  @override
  String get unblockCommunity => 'Blokkering van gemeen­schap opheffen';

  @override
  String get unblockCommunityInstance => 'Unblock Community Instance';

  @override
  String get unblockInstance => 'Blokkering van instantie opheffen';

  @override
  String get unblockUser => 'Blokkering van gebruiker opheffen';

  @override
  String get unblockUserInstance => 'Unblock User Instance';

  @override
  String get understandEnable => 'I Understand, Enable';

  @override
  String get unexpectedError => 'Onverwachte fout';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get unfeaturedPost => 'Unfeatured Post';

  @override
  String get unhidCommunity => 'Unhid Community';

  @override
  String get unhide => 'Verbergen herstellen';

  @override
  String unifiedPushDistributorApp(Object app, Object count) {
    return 'UnifiedPush Distributor app: $app ($count available)';
  }

  @override
  String get unifiedPushNotifications => 'UnifiedPush-meldingen';

  @override
  String unifiedPushServer(Object server) {
    return 'UnifiedPush Server: $server';
  }

  @override
  String get unifiedpush => 'UnifiedPush';

  @override
  String get unlockPost => 'Bericht ontgrendelen';

  @override
  String get unlockedPost => 'Bericht ontgrendeld';

  @override
  String get unpinFromCommunity => 'Unpin from Community';

  @override
  String get unpinPostFromCommunity => 'Unpin Post from Community';

  @override
  String get unreachable => 'Onbereikbaar';

  @override
  String get unresolved => 'Onopgelost';

  @override
  String get unsubscribe => 'Uitschrĳven';

  @override
  String get unsubscribeFromCommunity => 'Unsubscribe from Community';

  @override
  String get unsubscribePending => 'Unsubscribe (subscription pending)';

  @override
  String get unsubscribed => 'Uitgeschreven';

  @override
  String updateReleased(Object version) {
    return 'Update released: $version';
  }

  @override
  String get uploadImage => 'Afbeelding uploaden';

  @override
  String uploadedDate(Object date) {
    return 'Geüploaded op: $date';
  }

  @override
  String get upvote => 'Upvoten';

  @override
  String get upvoteColor => 'Upvote-kleur';

  @override
  String get upvoted => 'Geüpvotet';

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
  String get user => 'Gebruiker';

  @override
  String get userActions => 'Gebruikers­acties';

  @override
  String userEntry(Object username) {
    return 'Gebruiker ‘$username’';
  }

  @override
  String get userFormat => 'Gebruikers­formaat';

  @override
  String get userLabelHint => 'This is my favorite user';

  @override
  String get userLabels => 'Gebruikers­labels';

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
  String get userProfiles => 'Gebruikers­profielen';

  @override
  String get userSettingDescription =>
      'These settings sync with your Lemmy account and are only applied on a per-account basis.';

  @override
  String get userStyle => 'Gebruikers­stĳl';

  @override
  String get username => 'Gebruikers­naam';

  @override
  String get usernameFormattingRedirect => 'Looking for username formatting?';

  @override
  String get users => 'Gebruikers';

  @override
  String versionNumber(Object version) {
    return 'Versie $version';
  }

  @override
  String get video => 'Video';

  @override
  String get videoAutoFullscreen => 'Automatisch volledig scherm';

  @override
  String get videoAutoLoop => 'Video\'s herhalen';

  @override
  String get videoAutoMute => 'Video\'s dempen';

  @override
  String get videoAutoPlay => 'Video\'s automatisch afspelen';

  @override
  String get videoDefaultPlaybackSpeed => 'Default Playback Speed';

  @override
  String get videoLinkHandlingExternal => 'Play video with an external app';

  @override
  String get videoPlayerInApp => 'Use Thunder built-in player';

  @override
  String get videoPlayerMode => 'Speler­modus';

  @override
  String get viewAll => 'Alles bekĳken';

  @override
  String get viewAllComments => 'View all comments';

  @override
  String get viewCommentSource => 'View Comment Source';

  @override
  String get viewModlog => 'Moderator­logboek bekĳken';

  @override
  String get viewOriginal => 'Origineel bekĳken';

  @override
  String get viewPostAsDifferentAccount => 'View post as different account';

  @override
  String get viewPostSource => 'View post source';

  @override
  String get viewSource => 'Bron bekĳken';

  @override
  String get viewingAll => 'Alles aan het bekĳken';

  @override
  String visibility(Object visibility) {
    return 'Zichtbaarheid: $visibility';
  }

  @override
  String get visitCommunity => 'Gemeenschap bezoeken';

  @override
  String get visitCommunityInstance => 'Visit Community Instance';

  @override
  String get visitInstance => 'Instantie bezoeken';

  @override
  String get visitUserInstance => 'Visit User Instance';

  @override
  String get visitUserProfile => 'Visit User Profile';

  @override
  String get warning => 'Waarschuwing';

  @override
  String xDownvotes(Object x) {
    return '$x downvotes';
  }

  @override
  String xScore(Object x) {
    return 'Score: $x';
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
  String get yes => 'Ja';

  @override
  String get youMustSelectAJsonFile => 'You must select a .json file.';
}
