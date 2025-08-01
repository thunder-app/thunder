// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get about => 'Tietoja';

  @override
  String get accept => 'Accept';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get accessibilityProfilesDescription =>
      'Accessibility profiles allows applying several settings at once to accommodate a particular accessibility requirement.';

  @override
  String account(num count) {
    return 'Tili';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'Account Birthday $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'Your account settings override the following settings';

  @override
  String get accountSettings => 'Tiliasetukset';

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
  String get actions => 'Toiminnot';

  @override
  String get active => 'Aktiiviset';

  @override
  String get activity => 'Activity';

  @override
  String get add => 'Lisää';

  @override
  String get addAccount => 'Lisää Tili';

  @override
  String get addAccountToSeeProfile => 'Lisää tili nähdäksesi profiilisi.';

  @override
  String get addAnonymousInstance => 'Lisää Anonyymi Instanssi';

  @override
  String get addAsCommunityModerator => 'Add as Community Moderator';

  @override
  String get addDiscussionLanguage => 'Add Language';

  @override
  String get addKeywordFilter => 'Lisää avainsana';

  @override
  String get addOriginalPostBody => 'Add original post body?';

  @override
  String get addToFavorites => 'Lisää suosikkeihin';

  @override
  String get addUserLabel => 'Add User Label';

  @override
  String get addedCommunityToSubscriptions => 'Yhteisö lisätty tilauksiin';

  @override
  String get addedInstanceMod => 'Added Instance Mod';

  @override
  String get addedModToCommunity => 'Added Mod to Community';

  @override
  String get admin => 'Admin';

  @override
  String get advanced => 'Lisäasetukset';

  @override
  String ago(Object time) {
    return '$time ago';
  }

  @override
  String get all => 'Kaikki';

  @override
  String get allPosts => 'Kaikki Postaukset';

  @override
  String get allowOpenSupportedLinks =>
      'Salli sovelluksen avata tuettuja linkkejä.';

  @override
  String get alreadyPostedTo => 'Postattu jo yhteisöön';

  @override
  String get altText => 'Alt Text';

  @override
  String get alternateSources => 'Alternate Sources';

  @override
  String get always => 'Always';

  @override
  String andXMore(Object count) {
    return 'ja $count lisää';
  }

  @override
  String get animations => 'Animaatiot';

  @override
  String get anonymous => 'Anonyymi';

  @override
  String get anonymousInstances => 'Anonymous Instances';

  @override
  String get appLanguage => 'Sovelluksen kieli';

  @override
  String get appearance => 'Ulkoasu';

  @override
  String get applePushNotificationService => 'Apple Push Notification Service';

  @override
  String get applied => 'Käytössä';

  @override
  String get apply => 'Käytä';

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
  String get back => 'Takaisin';

  @override
  String get backButton => 'Takaisin-painike';

  @override
  String get backToTop => 'Takaisin Ylös';

  @override
  String get backgroundCheckWarning =>
      'Note that notification checks will consume additional battery';

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
  String get blockCommunity => 'Estä Yhteisö';

  @override
  String get blockCommunityInstance => 'Block Community Instance';

  @override
  String get blockInstance => 'Estä Instanssi';

  @override
  String get blockManagement => 'Block Management';

  @override
  String get blockSettingLabel => 'User/Community/Instance Blocks';

  @override
  String get blockUser => 'Estä Käyttäjä';

  @override
  String get blockUserInstance => 'Block User Instance';

  @override
  String get blockedCommunities => 'Estetyt Yhteisöt';

  @override
  String get blockedInstances => 'Estetyt Instanssit';

  @override
  String get blockedUsers => 'Estetyt Käyttäjät';

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
    return 'Selaat instanssia, $instance, anonyymisti.';
  }

  @override
  String get cancel => 'Peru';

  @override
  String get cannotReportOwnComment => 'Et voi ilmiantaa omaa kommenttiasi.';

  @override
  String get cantBlockAdmin => 'Et voi estää instanssin ylläpitäjää.';

  @override
  String get cantBlockYourself => 'Et voi estää itseäsi.';

  @override
  String get cardPostCardMetadataItems => 'Card View Metadata';

  @override
  String get cardView => 'Korttinäkymä';

  @override
  String get cardViewDescription =>
      'Ota korttinäkymä käyttöön säätääksesi asetuksia';

  @override
  String get cardViewSettings => 'Korttinäkymän asetukset';

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
  String get changeSort => 'Vaihda Lajittelu';

  @override
  String clearCache(Object cacheSize) {
    return 'Clear Cache ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Clear Cache';

  @override
  String get clearDatabase => 'Tyhjennä tietokanta';

  @override
  String get clearPreferences => 'Clear Preferences';

  @override
  String get clearSearch => 'Tyhjennä Hakukenttä';

  @override
  String get clearedCache => 'Cleared cache successfully.';

  @override
  String get clearedDatabase =>
      'Paikallinen tietokanta tyhjennetty. Uudelleenkäynnistä Thunder nähdäksesi muutokset.';

  @override
  String get clearedUserPreferences => 'Cleared all user preferences';

  @override
  String get close => 'Sulje';

  @override
  String get collapse => 'Collapse';

  @override
  String get collapseCommentPreview => 'Lyyhistä kommentin esikatselu';

  @override
  String get collapseInformation => 'Collapse Information';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Hide Parent Comment when Collapsed';

  @override
  String get collapsePost => 'Lyyhistä postaus';

  @override
  String get collapsePostPreview => 'Lyyhistä postauksen esikatselu';

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
  String get combineCommentScoresLabel => 'Yhdistä kommenttipisteet';

  @override
  String get combineNavAndFab =>
      'Kelluva toimintopainike näytetään navigointipainikkeiden välissä.';

  @override
  String get combineNavAndFabDescription =>
      'Floating Action Button will be shown between navigation buttons.';

  @override
  String get comfortable => 'Comfortable';

  @override
  String get comment => 'Kommentti';

  @override
  String get commentBehaviourSettings => 'Kommentit';

  @override
  String get commentFontScale => 'Comment Content Font Scale';

  @override
  String get commentPreview =>
      'Näytä kommenttien esikatselu määritetyillä asetuksilla';

  @override
  String get commentReported => 'Kommentti merkitty tarkistusta varten.';

  @override
  String get commentSavedAsDraft => 'Kommentin luonnos tallennettu';

  @override
  String get commentShowUserAvatar => 'Show User Avatar';

  @override
  String get commentShowUserInstance => 'Näytä käyttäjän instanssi';

  @override
  String get commentSortType => 'Kommenttien lajittelun tyyppi';

  @override
  String get commentSwipeActions => 'Comment Swipe Actions';

  @override
  String get commentSwipeGesturesHint =>
      'Haluatko käyttää mielummin painikkeita? Ota ne käyttöön yleisten asetusten kommenttiosiossa.';

  @override
  String get comments => 'Kommentit';

  @override
  String get communities => 'Yhteisöt';

  @override
  String get community => 'Yhteisö';

  @override
  String get communityActions => 'Community Actions';

  @override
  String communityEntry(Object community) {
    return 'Community \'$community\'';
  }

  @override
  String get communityFormat => 'Yhteisön formaatti';

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
  String get compactView => 'Kompakti näkymä';

  @override
  String get compactViewDescription =>
      'Ota kompakti näkymä käyttöön säätääksesi asetuksia';

  @override
  String get compactViewSettings => 'Kompaktin näkymän asetukset';

  @override
  String get condensed => 'Condensed';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmLogOutBody => 'Oletko varma, että haluat kirjautua ulos?';

  @override
  String get confirmLogOutTitle => 'Kirjaudu ulos?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Oletko varma, että haluat merkitä kaikki viestit luetuiksi?';

  @override
  String get confirmMarkAllAsReadTitle => 'Merkitse kaikki luetuiksi?';

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
  String get copiedToClipboard => 'Kopioitu leikepöydälle';

  @override
  String get copy => 'Kopioi';

  @override
  String get copyComment => 'Copy Comment';

  @override
  String get copySelected => 'Copy selected';

  @override
  String get copyText => 'Kopioi teksti';

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
    return '$count tilaajaa';
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
  String get createAccount => 'Luo Tili';

  @override
  String get createComment => 'Luo kommentti';

  @override
  String get createNewCrossPost => 'Luo uusi ristiinjulkaisu';

  @override
  String get createPost => 'Luo Postaus';

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
    return 'cross-posted from:  $postUrl';
  }

  @override
  String get crossPostedTo => 'Ristiinjulkaistu yhteisöön';

  @override
  String get currentLongPress => 'Currently set as long press';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Current notifications mode: $mode';
  }

  @override
  String get currentSinglePress => 'Currently set as single press';

  @override
  String get customizeSwipeActions =>
      'Mukauta pyyhkäisytoimintoja (napauta muuttaaksesi)';

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
  String get debug => 'Virheenjäljitys';

  @override
  String get debugDescription =>
      'Seuraavia vianmääritysasetuksia tulisi käyttää ainoastaan vianetsintätarkoituksiin.';

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
  String get delete => 'Poista';

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
  String get deselectUndeterminedWarning =>
      'If you deselect Undetermined, you will not see most content.';

  @override
  String detailedReason(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get dimReadPosts => 'Luetut postaukset näkyvät tummennettuina';

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
  String get dismissRead => 'Hylkää Luetut';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayUserScore => 'Näytä käyttäjäpisteet (Karma).';

  @override
  String get dividerAppearance => 'Divider Appearance';

  @override
  String get doNotShowAgain => 'Do Not Show Again';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Found multiple compatible apps; please install only one';

  @override
  String get downloadingMedia => 'Ladataan mediaa jaettavaksi…';

  @override
  String get downvote => 'Downvote';

  @override
  String get downvoteColor => 'Downvote Color';

  @override
  String get downvoted => 'Downvoted';

  @override
  String get downvotesDisabled => 'Downvotes are turned off on this instance.';

  @override
  String get edit => 'Muokkaa';

  @override
  String get editComment => 'Muokkaa kommenttia';

  @override
  String get editPost => 'Muokkaa postausta';

  @override
  String get email => 'Email';

  @override
  String get empty => 'Tyhjä';

  @override
  String get emptyInbox => 'Tyhjä postilaatikko';

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
  String get endSearch => 'Lopeta haku';

  @override
  String errorDeletingImage(Object error) {
    return 'There was an error deleting the image: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Mediatiedostoa ei voitu ladata jaettavaksi: $errorMessage';
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
      'Linkin käsittelyssä tapahtui virhe. Se ei ehkä ole saatavilla instanssillasi.';

  @override
  String get excessiveApiCallsWarning =>
      'Your feed may be taking a while to load due to keyword filters.';

  @override
  String get expand => 'Expand';

  @override
  String get expandCommentPreview => 'Laajenna kommentin esikatselu';

  @override
  String get expandInformation => 'Expand Information';

  @override
  String get expandOptions => 'Laajenna asetukset';

  @override
  String get expandPost => 'Laajenna postaus';

  @override
  String get expandPostPreview => 'Laajenna postauksen esikatselu';

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
    return 'Estäminen epäonnistui: $errorMessage';
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
    return 'Eston poisto epäonnistui: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Failed to update notification settings';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Suosikit';

  @override
  String get featuredPost => 'Featured Post';

  @override
  String get feed => 'Julkaisut';

  @override
  String get feedBehaviourSettings => 'Syöte';

  @override
  String get feedSettings => 'Feed Settings';

  @override
  String get feedTypeAndSorts => 'Default Feed Type and Sorting';

  @override
  String get fetchAccountError => 'Tiliä ei voitu määritellä';

  @override
  String filteringBy(Object entity) {
    return 'Filtering by $entity';
  }

  @override
  String get filters => 'Suodattimet';

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
  String get fullscreenSwipeGestures => 'Fullscreen Swipe Gestures';

  @override
  String get general => 'Yleiset';

  @override
  String get generalSettings => 'Yleiset asetukset';

  @override
  String get gestures => 'Eleet';

  @override
  String get gettingStarted => 'Aloitus';

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
  String get hideColor => 'Hide Color';

  @override
  String get hideNsfwPostsFromFeed => 'Hide NSFW Posts from Feed';

  @override
  String get hideNsfwPreviews => 'Blur NSFW Previews';

  @override
  String get hidePassword => 'Piilota Salasana';

  @override
  String get hideThumbnails => 'Hide Thumbnails';

  @override
  String get hideTopBarOnScroll => 'Hide Top Bar on Scroll';

  @override
  String get hostInstance => 'Host Instance';

  @override
  String get hot => 'Kuumat';

  @override
  String get image => 'Kuva';

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
  String get importExportSettings => 'Tuo/vie asetukset';

  @override
  String get importExportThunderSettings => 'Import/Export Thunder Settings';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Import Lemmy account settings';

  @override
  String get importSettings => 'Tuo asetukset';

  @override
  String inReplyTo(Object community, Object post) {
    return 'In reply to $post in $community';
  }

  @override
  String get in_ => 'in';

  @override
  String get inbox => 'Postilaatikko';

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
    return 'Instanssi';
  }

  @override
  String get instanceActions => 'Instance Actions';

  @override
  String instanceEntry(Object username) {
    return 'Instance \'$username\'';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance on jo lisätty.';
  }

  @override
  String get instanceNameColor => 'Instance Name Color';

  @override
  String get instanceNameThickness => 'Instance Name Thickness';

  @override
  String get instances => 'Instances';

  @override
  String get internetOrInstanceIssues =>
      'Internet yhteys puuttuu, tai valitsemasi instanssi ei ole nyt saatavilla.';

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
  String get language => 'Kieli';

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
  String get linksBehaviourSettings => 'Linkit';

  @override
  String loadMorePlural(Object count) {
    return 'Lataa $count vastausta lisää…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Lataa $count vastausta lisää…';
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
  String get localPosts => 'Paikalliset Postaukset';

  @override
  String get lockPost => 'Lock Post';

  @override
  String get locked => 'Locked';

  @override
  String get lockedPost => 'Locked Post';

  @override
  String get logOut => 'Kirjaudu Ulos';

  @override
  String get login => 'Kirjaudu';

  @override
  String get loginAttemptCanceled => 'Login attempt canceled.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Kirjautuminen epäonnistui. Ole hyvä ja yritä uudelleen: ($errorMessage)';
  }

  @override
  String get loginSucceeded => 'Logged in.';

  @override
  String get loginToPerformAction =>
      'Sinun on kirjauduttava sisään suorittaaksesi tämän toiminnon.';

  @override
  String get loginToSeeInbox => 'Kirjaudu nähdäksesi postilaatikkosi';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Looking for account-specific feed settings?';

  @override
  String get malformedUri =>
      'The link you provided is in an unsupported format. Please make sure it\'s a valid link.';

  @override
  String get manageAccounts => 'Hallitse Tilejä';

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
  String get missingErrorMessage => 'Ei vikailmoitusta';

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
  String get mostComments => 'Eniten Kommentteja';

  @override
  String get mustBeLoggedIn => 'You need to be logged in';

  @override
  String get mustBeLoggedInComment =>
      'Sinun tulee olla kirjautunut kommentoidaksesi';

  @override
  String get mustBeLoggedInPost =>
      'Sinun tulee olla kirjautunut luodaksesi postauksen';

  @override
  String get names => 'Names';

  @override
  String get navbarDoubleTapGestures => 'Navbar Double Tap Gestures';

  @override
  String get navbarSwipeGestures => 'Navbar Swipe Gestures';

  @override
  String get navigateDown => 'Next comment';

  @override
  String get navigateUp => 'Edellinen kommentti';

  @override
  String get navigation => 'Navigaatio';

  @override
  String get nestedCommentIndicatorColor => 'Nested Comment Indicator Color';

  @override
  String get nestedCommentIndicatorStyle => 'Nested Comment Indicator Style';

  @override
  String get never => 'Never';

  @override
  String get newComments => 'Uusimmat Kommentit';

  @override
  String get newPost => 'New Post';

  @override
  String get new_ => 'Uusimmat';

  @override
  String get no => 'No';

  @override
  String get noAccountsAdded => 'No accounts have been added';

  @override
  String get noAnonymousInstances => 'No anonymous instances have been added';

  @override
  String get noCommentsFound => 'No comments found';

  @override
  String get noCommunitiesFound => 'Ei löytynyt yhteisöjä';

  @override
  String get noCommunityBlocks => 'Ei estettyjä yhteisöjä.';

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
  String get noInstanceBlocks => 'Ei estettyjä instansseja.';

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
  String get noUserBlocks => 'Ei estettyjä käyttäjiä.';

  @override
  String get noUserLabels => 'You have not created any user labels yet';

  @override
  String get noUsersFound => 'Ei löytynyt käyttäjiä';

  @override
  String get noVisibleComments =>
      'Comments may not be visible because the community is blocked.';

  @override
  String get none => 'None';

  @override
  String get normal => 'Normal';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance ei ole kelvollinen Lemmy instanssi';
  }

  @override
  String get notValidUrl => 'Ei kelvollinen URL';

  @override
  String get nothingToShare => 'Ei mitään jaettavaa';

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
  String get notificationsBehaviourSettings => 'Ilmoitukset';

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
  String get old => 'Vanhat';

  @override
  String get on => 'on';

  @override
  String get onWifi => 'On Wifi';

  @override
  String get onlyModsCanPostInCommunity =>
      'Ainoastaan moderaatorit voivat luoda postauksia tähän yhteisöön';

  @override
  String get open => 'Avaa';

  @override
  String get openAccountSwitcher => 'Open account switcher';

  @override
  String get openByDefault => 'Open by default';

  @override
  String get openInBrowser => 'Avaa selaimessa';

  @override
  String get openInstance => 'Avaa Instanssi';

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
  String get overview => 'Yhteenveto';

  @override
  String get password => 'Salasana';

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
  String get placeholderText =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  @override
  String get post => 'Post';

  @override
  String get postActions => 'Post Actions';

  @override
  String get postBehaviourSettings => 'Postaukset';

  @override
  String get postBody => 'Postauksen Teksti';

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
  String get postLocked => 'Postaus lukittu. Vastauksia ei sallita.';

  @override
  String get postMetadataInstructions =>
      'You can customize the metadata information by dragging and dropping the desired information';

  @override
  String get postNSFW => 'Merkitse NSFW';

  @override
  String get postPreview =>
      'Show a preview of the post with the given settings';

  @override
  String get postSavedAsDraft => 'Postauksen luonnos tallennettu';

  @override
  String get postShowUserInstance => 'Show User Instance';

  @override
  String get postSwipeActions => 'Post Swipe Actions';

  @override
  String get postSwipeGesturesHint =>
      'Looking to use buttons instead? Change what buttons appear on post cards in general settings.';

  @override
  String get postTitle => 'Otsikko';

  @override
  String get postTitleFontScale => 'Post Title Font Scale';

  @override
  String get postTogglePreview => 'Kytke Esikatselu';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Kuvan lataus epäonnistui';

  @override
  String get postViewType => 'Post View Type';

  @override
  String get posts => 'Postaukset';

  @override
  String get preview => 'Preview';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile applied successfully!';
  }

  @override
  String get profileBio => 'Profile Bio';

  @override
  String get profiles => 'Tilit';

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
  String get reducesAnimations =>
      'Vähentää Thunderissa käytettyjä animaatioita';

  @override
  String get refresh => 'Virkistä';

  @override
  String get refreshContent => 'Virkistä Sisältö';

  @override
  String get removalReason => 'Removal Reason';

  @override
  String get remove => 'Poista';

  @override
  String get removeAccount => 'Poista Tili';

  @override
  String get removeAsCommunityModerator => 'Remove as Community Moderator';

  @override
  String get removeComment => 'Remove Comment';

  @override
  String get removeFromFavorites => 'Poista suosikeista';

  @override
  String get removeInstance => 'Poista instanssi';

  @override
  String removeKeyword(Object keyword) {
    return 'Remove \"$keyword\"?';
  }

  @override
  String get removeKeywordFilter => 'Remove Keyword';

  @override
  String get removePost => 'Remove Post';

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
  String get replyToPost => 'Luo Kommentti';

  @override
  String replyingTo(Object author) {
    return 'Vastataan käyttäjälle $author';
  }

  @override
  String report(num count) {
    return 'Ilmianna';
  }

  @override
  String get reportComment => 'Ilmianna kommentti';

  @override
  String get reportPost => 'Report Post';

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
  String get restore => 'Palauta';

  @override
  String get restoreComment => 'Restore Comment';

  @override
  String get restorePost => 'Restore Post';

  @override
  String get restoredComment => 'Restored Comment';

  @override
  String get restoredCommentFromDraft => 'Kommentti palautettu luonnoksesta';

  @override
  String get restoredCommunity => 'Restored Community';

  @override
  String get restoredPost => 'Restored Post';

  @override
  String get restoredPostFromDraft => 'Postaus palautettu luonnoksesta';

  @override
  String get retry => 'Retry';

  @override
  String get rightLongSwipe => 'Right Long Swipe';

  @override
  String get rightShortSwipe => 'Right Short Swipe';

  @override
  String get save => 'Tallenna';

  @override
  String get saveColor => 'Save Color';

  @override
  String get saveSettings => 'Tallenna asetukset';

  @override
  String get saved => 'Tallennettu';

  @override
  String get scaled => 'Skaalattu';

  @override
  String get scrapeMissingLinkPreviews => 'Scrape Missing Link Previews';

  @override
  String get screenReaderProfile => 'Screen Reader Profile';

  @override
  String get screenReaderProfileDescription =>
      'Optimizes Thunder for screen readers by reducing overall elements and removing potentially conflicting gestures.';

  @override
  String get search => 'Haku';

  @override
  String get searchByText => 'Hae tekstillä';

  @override
  String get searchByUrl => 'Hae URL-osoitteella';

  @override
  String get searchComments => 'Hae kommentteja';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return 'Search for comments federated with $instance';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return 'Hae yhteisöjä jotka ovat federoituja $instance kanssa';
  }

  @override
  String searchInstance(Object instance) {
    return 'Hae $instance';
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
  String get searchTerm => 'Hakusana';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Hae käyttäjiä jotka ovat federoituja $instance kanssa';
  }

  @override
  String get selectAccountToCommentAs => 'Select account to comment as';

  @override
  String get selectAccountToPostAs => 'Select account to post as';

  @override
  String get selectAll => 'Select all';

  @override
  String get selectCommunity => 'Valitse yhteisö';

  @override
  String get selectFeedType => 'Valitse Julkaisulaji';

  @override
  String get selectLanguage => 'Valitse kieli';

  @override
  String get selectSearchType => 'Valitse Hakulaji';

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
    return 'Tapahtui palvelinvirhe haettaessa lisää kommentteja: $message';
  }

  @override
  String get setAction => 'Set Action';

  @override
  String get setLongPress => 'Aseta pitkän kosketuksen toiminnoksi';

  @override
  String get setShortPress => 'Aseta lyhyen kosketuksen toiminnoksi';

  @override
  String get settingOverrideLabel =>
      'These settings override Thunder\'s default settings.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'Settings of type $settingType are not yet supported.';
  }

  @override
  String get settings => 'Asetukset';

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
  String get share => 'Jaa';

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
  String get shareLink => 'Jaa linkki';

  @override
  String get shareMedia => 'Jaa media';

  @override
  String get shareMediaLink => 'Share Media Link';

  @override
  String get shareOriginalLink => 'Share Original Link';

  @override
  String get sharePost => 'Jaa postaus';

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
  String get showAll => 'Näytä kaikki';

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
  String get showLess => 'Näytä vähemmän';

  @override
  String get showMore => 'Näytä lisää';

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
  String get showPassword => 'Näytä Salasana';

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
  String get showReadPosts => 'Näytä luetut postaukset';

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
  String get sidebar => 'Sivupalkki';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Kaksoisnapauta alanavigointia avataksesi sivupalkin';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Avaa sivupalkki pyyhkäisemällä alanavigointia';

  @override
  String get small => 'Small';

  @override
  String get somethingWentWrong => 'Oi ei, jokin meni pieleen!';

  @override
  String get sortBy => 'Lajittelu';

  @override
  String get sortByTop => 'Sort by Top';

  @override
  String get sortOptions => 'Lajitteluasetukset';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get standard => 'Standard';

  @override
  String get stats => 'Stats';

  @override
  String get status => 'Status';

  @override
  String get submit => 'Lähetä';

  @override
  String get subscribe => 'Tilaa';

  @override
  String get subscribeToCommunity => 'Subscribe to Community';

  @override
  String get subscribed => 'Tilattu';

  @override
  String get subscriptionRequestSent => 'Subscription request sent';

  @override
  String get subscriptions => 'Tilaukset';

  @override
  String successfullyBannedUser(Object username) {
    return 'Banned $username';
  }

  @override
  String get successfullyBlocked => 'Estetty.';

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
  String get suggestedTitle => 'Otsikkoehdotus';

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
  String get tapToExit => 'Paina takaisin kahdesti poistuaksesi';

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
  String get text => 'Teksti';

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
  String get timeoutErrorMessage => 'Latauksen aikana tapahtui aikakatkaisu.';

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
  String get top => 'Parhaat';

  @override
  String get topAll => 'Kaikkien Aikojen Ylimmät';

  @override
  String get topDay => 'Päivän Ylimmät';

  @override
  String get topHour => 'Tunnin Ylimmät';

  @override
  String get topMonth => 'Kuun Ylimmät';

  @override
  String get topNineMonths => 'Parhaat 9:n kuukauden ajalta';

  @override
  String get topSixHour => 'Kuuden Tunnin Ylimmät';

  @override
  String get topSixMonths => 'Parhaat 6:n kuukauden ajalta';

  @override
  String get topThreeMonths => 'Parhaat 3:n kuukauden ajalta';

  @override
  String get topTwelveHour => 'Kahdentoista Tunnin Ylimmät';

  @override
  String get topWeek => 'Viikon Ylimmät';

  @override
  String get topYear => 'Vuoden Ylimmät';

  @override
  String totalComments(Object x) {
    return '$x Comments';
  }

  @override
  String totalPosts(Object x) {
    return '$x Posts';
  }

  @override
  String get totp => 'TOTP (valinnainen)';

  @override
  String get transferredModToCommunity => 'Transferred Community';

  @override
  String get translationsMayNotBeComplete =>
      'Please note that the translations may not be complete';

  @override
  String get trendingCommunities => 'Kasvavat Yhteisöt';

  @override
  String get trySearchingFor => 'Try searching for...';

  @override
  String get unableToFindCommunity => 'Yhteisöä ei löytynyt';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'Unable to find community \'$communityName\'';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Unable to find the selected community on the selected user\'s instance.';

  @override
  String get unableToFindInstance => 'Instanssia ei löytynyt';

  @override
  String get unableToFindLanguage => 'Unable to find language';

  @override
  String get unableToFindPost => 'Unable to find post';

  @override
  String get unableToFindUser => 'Käyttäjää ei löytynyt';

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
    return '$instance lataus epäonnistui';
  }

  @override
  String get unableToLoadPost => 'Unable to load post';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return 'Postauksien lataaminen epäonnistui $instance';
  }

  @override
  String get unableToLoadReplies => 'Lisää vastauksia ei voitu ladata.';

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
  String get unbannedUserFromCommunity => 'Unbanned User from Community';

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
  String get unexpectedError => 'Odottamaton virhe';

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
  String get unreachable => 'Unreachable';

  @override
  String get unresolved => 'Unresolved';

  @override
  String get unsubscribe => 'Peru Tilaus';

  @override
  String get unsubscribeFromCommunity => 'Unsubscribe from Community';

  @override
  String get unsubscribePending => 'Peru Tilaus (tilaus vireillä)';

  @override
  String get unsubscribed => 'Tilaus Peruttu';

  @override
  String updateReleased(Object version) {
    return 'Päivitys on saatavilla: $version';
  }

  @override
  String get uploadImage => 'Lataa kuva';

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
      'Tämän tyyppistä linkkiä ei tueta tällä hetkellä.';

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
  String get useCompactView =>
      'Ota käyttöön pienille postauksille, poista käytöstä suuremmista.';

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
    return 'Käytä ehdotettua otsikkoa: $title';
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
  String get username => 'Käyttäjänimi';

  @override
  String get usernameFormattingRedirect => 'Looking for username formatting?';

  @override
  String get users => 'Käyttäjät';

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
