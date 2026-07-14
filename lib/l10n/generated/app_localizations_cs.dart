// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get about => 'O aplikaci';

  @override
  String get accept => 'Accept';

  @override
  String get accessibility => 'Přístupnost';

  @override
  String get accessibilityProfilesDescription =>
      'Profily přístupnosti umožňují aplikaci několika nastavení najednou pro dosažení určitého požadavku přístupnosti.';

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
  String get accountSettings => 'Nastavení Účtu';

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
  String get actions => 'Akce';

  @override
  String get active => 'Aktivní';

  @override
  String get activity => 'Activity';

  @override
  String get add => 'Přidat';

  @override
  String get addAccount => 'Přidat Účet';

  @override
  String get addAccountToSeeProfile =>
      'Přihlaste se pro zobrazení vašeho účtu.';

  @override
  String get addAnonymousInstance => 'Přidat Anonymní Instanci';

  @override
  String get addAsCommunityModerator => 'Add as Community Moderator';

  @override
  String get addDiscussionLanguage => 'Add Language';

  @override
  String get addKeywordFilter => 'Přidejte Klíčové Slovo';

  @override
  String get addOriginalPostBody => 'Add original post body?';

  @override
  String get addToFavorites => 'Přidat do oblíbených';

  @override
  String get addUserLabel => 'Add User Label';

  @override
  String get addedCommunityToSubscriptions => 'Přihlášený ke komunitě';

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
  String get advanced => 'Pokročilé';

  @override
  String ago(Object time) {
    return '$time ago';
  }

  @override
  String get all => 'Vše';

  @override
  String get allPosts => 'Všechny Příspěvky';

  @override
  String get allowOpenSupportedLinks =>
      'Dovolte aplikaci otevírat podporované odkazy.';

  @override
  String get alreadyPostedTo => 'Už přidáno na';

  @override
  String get altText => 'Alt Text';

  @override
  String get alternateSources => 'Alternate Sources';

  @override
  String get always => 'Always';

  @override
  String andXMore(Object count) {
    return 'a $count více';
  }

  @override
  String get animations => 'Animace';

  @override
  String get anonymous => 'Anonymní';

  @override
  String get anonymousInstances => 'Anonymous Instances';

  @override
  String get appLanguage => 'Jazyk Aplikace';

  @override
  String get appearance => 'Vzhled';

  @override
  String get applePushNotificationService => 'Apple Push Notification Service';

  @override
  String get applied => 'Aplikováno';

  @override
  String get apply => 'Použít';

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
  String get back => 'Zpět';

  @override
  String get backButton => 'Tlačítko zpět';

  @override
  String get backToTop => 'Zpět Nahoru';

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
  String get base => 'Normální';

  @override
  String get block => 'Block';

  @override
  String get blockCommunity => 'Zablokovat Komunitu';

  @override
  String get blockCommunityInstance => 'Block Community Instance';

  @override
  String get blockInstance => 'Zablokovat Instanci';

  @override
  String get blockManagement => 'Block Management';

  @override
  String get blockSettingLabel => 'User/Community/Instance Blocks';

  @override
  String get blockUser => 'Zablokovat Uživatele';

  @override
  String get blockUserInstance => 'Block User Instance';

  @override
  String get blockedCommunities => 'Zablokované Komunity';

  @override
  String get blockedInstances => 'Zablokované Instance';

  @override
  String get blockedUsers => 'Zablokovaní Uživatelé';

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
    return 'Právě anonymně procházíte $instance.';
  }

  @override
  String get cancel => 'Zrušit';

  @override
  String get cannotReportOwnComment =>
      'Není možné nahlásit svůj vlastní komentář.';

  @override
  String get cantBlockAdmin => 'Není možné zablokovat administrátora instance.';

  @override
  String get cantBlockYourself => 'Není možné se sám zablokovat.';

  @override
  String get cardPostCardMetadataItems => 'Card View Metadata';

  @override
  String get cardView => 'Zobrazení Karet';

  @override
  String get cardViewDescription =>
      'Abyste upravili nastavení, povolte zobrazení karet';

  @override
  String get cardViewSettings => 'Nastavení Zobrazení Karet';

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
  String get changeSort => 'Změňte Řazení';

  @override
  String clearCache(Object cacheSize) {
    return 'Vymazat Mezipaměť $cacheSize';
  }

  @override
  String get clearCacheLabel => 'Clear Cache';

  @override
  String get clearDatabase => 'Promazat Databázi';

  @override
  String get clearPreferences => 'Vymazat Preference';

  @override
  String get clearSearch => 'Vymazat Hledání';

  @override
  String get clearedCache => 'Mezipaměť úspěšně promazána.';

  @override
  String get clearedDatabase =>
      'Lokální databáze promazána. Restartujte Thunder pro aplikování těchto změn.';

  @override
  String get clearedUserPreferences =>
      'Všechna uživatelská nastavení byla vymazána';

  @override
  String get close => 'Zavřít';

  @override
  String get collapse => 'Collapse';

  @override
  String get collapseCommentPreview => 'Schovat Ukázku Komentářů';

  @override
  String get collapseInformation => 'Schovat Informace';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Při Složení Schovat Nadřazený Komentář';

  @override
  String get collapsePost => 'Složit příspěvek';

  @override
  String get collapsePostPreview => 'Složit Ukázku Příspěvku';

  @override
  String get collapseSpoiler => 'Složit Spoiler';

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
  String get combineCommentScores => 'Sloučit Skóre Komentářů';

  @override
  String get combineCommentScoresLabel => 'Sloučit Skóre Komentářů';

  @override
  String get combineNavAndFab => 'Sloučit PAT a Navigační Tlačítka';

  @override
  String get combineNavAndFabDescription =>
      'Plovoucí Akční Tlačítko se bude nacházet mezi navigačními tlačítky.';

  @override
  String get comfortable => 'Comfortable';

  @override
  String get comment => 'Komentovat';

  @override
  String get commentActions => 'Comment Actions';

  @override
  String get commentBehaviourSettings => 'Komentáře';

  @override
  String get commentFontScale => 'Velikost Fontu Komentářů';

  @override
  String get commentPreview => 'Ukázat nastavení komentářů s daným nastavením';

  @override
  String get commentReported => 'Tento komentář byl označen pro kontrolu.';

  @override
  String get commentSavedAsDraft => 'Komentář uložen do konceptu';

  @override
  String get commentShowUserAvatar => 'Show User Avatar';

  @override
  String get commentShowUserInstance => 'Zobrazit Uživatelskou Instanci';

  @override
  String get commentSortType => 'Comment Sort Type';

  @override
  String get commentSwipeActions => 'Comment Swipe Actions';

  @override
  String get commentSwipeGesturesHint =>
      'Chcete využívat tlačítka? Povolte je v sekci komentářů v základním nastavení.';

  @override
  String get comments => 'Komentáře';

  @override
  String get communities => 'Komunity';

  @override
  String get community => 'Komunita';

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
  String get compactView => 'Kompaktní Zobrazení';

  @override
  String get compactViewDescription =>
      'Pro úpravu nastavení, povolte kompaktní zobrazení';

  @override
  String get compactViewSettings => 'Nastavení Kompaktního Zobrazení';

  @override
  String get condensed => 'Condensed';

  @override
  String get confirm => 'Potvrdit';

  @override
  String get confirmLogOutBody => 'Jste si jistí, že se chcete ohlásit?';

  @override
  String get confirmLogOutTitle => 'Odhlásit Se?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Jste si jistí, že chcete označit všechny zprávy jako přečtené?';

  @override
  String get confirmMarkAllAsReadTitle => 'Označit Vše Jako Přečtené?';

  @override
  String get confirmResetCommentPreferences =>
      'Toto resetuje všechna nastavení komentářů. Opravdu chcete pokračovat?';

  @override
  String get confirmResetPostPreferences =>
      'Toto resetuje všechna nastavení příspěvků. Opravdu chcete pokračovat?';

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
  String get controversial => 'Kontroverzní';

  @override
  String get copiedToClipboard => 'Zkopírováno do schránky';

  @override
  String get copy => 'Kopírovat';

  @override
  String get copyComment => 'Copy Comment';

  @override
  String get copySelected => 'Copy selected';

  @override
  String get copyText => 'Kopírovat Text';

  @override
  String get couldNotDetermineCommentDelete =>
      'Error: Could not determine post to delete the comment.';

  @override
  String get couldNotDeterminePostComment =>
      'Error: Could not determine post to comment to.';

  @override
  String get couldntCreateReport =>
      'Vaše nahlášení komentáře proběhlo neúspěšně. Zkuste to prosím pozdějí';

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
    return '$count sledujících';
  }

  @override
  String countUsers(Object count) {
    return '$count uživatelů';
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
  String get createAccount => 'Vytvořit Účet';

  @override
  String get createComment => 'Napsat Komentář';

  @override
  String get createNewCrossPost => 'Vytvořit nový cross-příspěvek';

  @override
  String get createPost => 'Vytvořit Příspěvek';

  @override
  String created(Object date) {
    return 'Created $date';
  }

  @override
  String get createdToday => 'Created Today';

  @override
  String get creator => 'Autor';

  @override
  String crossPostedFrom(Object postUrl) {
    return 'cross-příspěvek z:  $postUrl';
  }

  @override
  String get crossPostedTo => 'Cross-přidáno na';

  @override
  String get currentLongPress => 'Nyní nastaveno na dlouhé podržení';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Current notifications mode: $mode';
  }

  @override
  String get currentSinglePress => 'Nyní nastaveno na jedno klepnutí';

  @override
  String get customizeSwipeActions =>
      'Přizpůsobit swipe akce (klepněte pro změnu)';

  @override
  String get dangerZone => 'Zóna Smrti';

  @override
  String get dark => 'Tmavé';

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
      'Následující debug nastavení by mělo být využito jen pro řešení problémů.';

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
  String get defaultFeedType => 'Výchozí Typ Feedu';

  @override
  String get delete => 'Vymazat';

  @override
  String get deleteAccount => 'Vymazat Účet';

  @override
  String get deleteAccountDescription =>
      'Pro permanentní odstranění účtu budete přesměrováni na stránku Vaší instance. \n\nOpravdu chcete pokračovat?';

  @override
  String get deleteComment => 'Delete Comment';

  @override
  String get deleteDraftConfirmation =>
      'Are you sure you want to delete this draft?';

  @override
  String get deleteImageConfirmMessage =>
      'Are you sure you want to delete this image?';

  @override
  String get deleteImageConfirmTitle => 'Delete?';

  @override
  String get deleteLocalDatabase => 'Vymazat Místní Databázi';

  @override
  String get deleteLocalDatabaseDescription =>
      'Tato akce odstraní místní databázi a odhlásí Vás ze Všech Vašich účtů. \n\nOpravdu chcete pokračovat?';

  @override
  String get deleteLocalPreferences => 'Vymazat Místní Nastavení';

  @override
  String get deleteLocalPreferencesDescription =>
      'Toto vymaže veškerá uživatelská přizpůsobení a nastavení v aplikaci Thunder. \n\nOpravdu chcete pokračovat?';

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
  String get dimReadPosts => 'Ztmavit Přečtené Příspěvky';

  @override
  String get directMessage => 'Direct message';

  @override
  String get disable => 'Zrušit';

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
  String get displayUserScore => 'Zobrazit Uživatelské Skóre (Karmu).';

  @override
  String get dividerAppearance => 'Divider Appearance';

  @override
  String get doNotShowAgain => 'Do Not Show Again';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Found multiple compatible apps; please install only one';

  @override
  String get downloadingMedia => 'Stahuji média pro sdílení…';

  @override
  String get downvote => 'Nesouhlas';

  @override
  String get downvoteColor => 'Downvote Color';

  @override
  String get downvoted => 'Downvoted';

  @override
  String get downvotesDisabled => 'Nesouhlasy jsou na této instanci vypnuty.';

  @override
  String get drafts => 'Drafts';

  @override
  String get edit => 'Upravit';

  @override
  String get editComment => 'Upravit komentář';

  @override
  String get editPost => 'Upravit Příspěvek';

  @override
  String get email => 'Email';

  @override
  String get empty => 'Prázdné';

  @override
  String get emptyInbox => 'Žádné Příchozí Zprávy';

  @override
  String get emptyUri =>
      'Tento odkaz je neplatný. Pro pokračování poskytněte platný dynamický odkaz.';

  @override
  String get enableCommentNavigation => 'Povolit Navigaci v Komentářích';

  @override
  String get enableExperimentalFeatures => 'Enable experimental features';

  @override
  String get enableFeedFab => 'Povolit Plovoucí Tlačítko na Feedech';

  @override
  String get enableFloatingButtonOnFeeds =>
      'Povolit Plovoucí Tlačítko Na Feedech';

  @override
  String get enableFloatingButtonOnPosts =>
      'Povolit Plovoucí Tlačítko Na Příspěvcích';

  @override
  String get enableInboxNotifications =>
      'Zapnout Oznámení Doručených Zpráv (Experimentální)';

  @override
  String get enablePostFab => 'Povolit Plovoucí Tlačítko na Příspěvcích';

  @override
  String get endOfComments => 'End of comments';

  @override
  String get endSearch => 'Ukončit Hledání';

  @override
  String errorDeletingImage(Object error) {
    return 'There was an error deleting the image: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Nebylo možné stáhnout mediální soubor ke sdílení:$errorMessage';
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
      'Při zpracování odkazu nastala chyba. Je možné, že toto na vaší instanci není dostupné.';

  @override
  String get excessiveApiCallsWarning =>
      'Your feed may be taking a while to load due to keyword filters.';

  @override
  String get expand => 'Expand';

  @override
  String get expandCommentPreview => 'Rozšířit Ukázku Komentářů';

  @override
  String get expandInformation => 'Rozšířit Informaci';

  @override
  String get expandOptions => 'Rozšířit možnosti';

  @override
  String get expandPost => 'Rozšířit příspěvek';

  @override
  String get expandPostPreview => 'Rozšířit Ukázku Příspěvku';

  @override
  String get expandSpoiler => 'Rozšířit Spoiler';

  @override
  String get expanded => 'Rozšířeno';

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
  String get extraLarge => 'Extra Velké';

  @override
  String failedToBlock(Object errorMessage) {
    return 'Nebylo možné zablokovat:$errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return 'Failed to communicate with Thunder notification server at $serverAddress.';
  }

  @override
  String get failedToCreateDefaultProfile => 'Failed to create default profile';

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return 'Nebylo možné načíst blokované:$errorMessage';
  }

  @override
  String get failedToLoadVideo => 'Failed to load video. Open link in browser?';

  @override
  String get failedToPerformAction => 'Failed to perform action';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'Nebylo možné odblokovat:$errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Failed to update notification settings';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Oblíbené';

  @override
  String get featuredPost => 'Featured Post';

  @override
  String get feed => 'Feed';

  @override
  String get feedBehaviourSettings => 'Feed';

  @override
  String get feedSettings => 'Feed Settings';

  @override
  String get feedTypeAndSorts => 'Původní Typy Feedu a Řazení';

  @override
  String get fetchAccountError => 'Could not determine account';

  @override
  String filteringBy(Object entity) {
    return 'Filtrováno $entity';
  }

  @override
  String get filters => 'Filtry';

  @override
  String get floatingActionButton => 'Plovoucí Akční Tlačítko';

  @override
  String get floatingActionButtonInformation =>
      'Thunder má plně nastavitelné PAT, které podporuje pár gest.\n- Swipněte nahoru pro zobrazení dalších PAT možností\n- Swipněte nahoru/dolů pro schování či zobrazení PAT\n\nPro přizpůsobení hlavní a sekundární akce PAT, dlouze podržte na jedné níže uvedené možnosti.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'denotes the FAB\'s long-press action.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'denotes the FAB\'s single-press action.';

  @override
  String get fonts => 'Fonty';

  @override
  String get forward => 'Vpřed';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Found compatible app; restart Thunder to connect';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Swipněte kdekoliv pro návrat zpět, pokud jsou gesta z leva do prava vypnutá';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get fullscreenSwipeGestures => 'Celoobrazovková Swipovací Gesta';

  @override
  String get general => 'Obecné';

  @override
  String get generalSettings => 'Obecné Nastavení';

  @override
  String get gestures => 'Gesta';

  @override
  String get gettingStarted => 'Začínáme';

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
  String get hideNsfwPostsFromFeed => 'Schovat NSFW Příspěvky z Feedu';

  @override
  String get hideNsfwPreviews => 'Schovat NSFW Náhledy';

  @override
  String get hidePassword => 'Schovat Heslo';

  @override
  String get hideThumbnails => 'Hide Thumbnails';

  @override
  String get hideTopBarOnScroll => 'Při Posunu Schovat Horní Lištu';

  @override
  String get hostInstance => 'Host Instance';

  @override
  String get hot => 'Žhavé';

  @override
  String get image => 'Obrázek';

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
  String get importExportSettings => 'Importovat/Exportovat Nastavení';

  @override
  String get importExportThunderSettings => 'Import/Export Thunder Settings';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Import Lemmy account settings';

  @override
  String get importSettings => 'Importovat Nastavení';

  @override
  String inReplyTo(Object post, Object community) {
    return 'V odpovědi na $post v $community';
  }

  @override
  String get in_ => 'in';

  @override
  String get inbox => 'Doručené zprávy';

  @override
  String get includeCommunity => 'Zahrnout Komunitu';

  @override
  String get includeExternalLink => 'Zahrnout Externí Odkaz';

  @override
  String get includeImage => 'Zahrnout Obrázek';

  @override
  String get includePostLink => 'Zahrnout Odkaz na Příspěvek';

  @override
  String get includeText => 'Zahrnout Text';

  @override
  String get includeTitle => 'Zahrnout Nadpis';

  @override
  String get information => 'Informace';

  @override
  String instance(num count) {
    return 'Instance';
  }

  @override
  String get instanceActions => 'Instance Actions';

  @override
  String instanceEntry(Object username) {
    return 'Instance \'$username\'';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance již byla přidána.';
  }

  @override
  String get instanceNameColor => 'Instance Name Color';

  @override
  String get instanceNameThickness => 'Instance Name Thickness';

  @override
  String get instanceOffline => 'Instance is offline';

  @override
  String get instanceOnline => 'Instance is online';

  @override
  String get instanceStatusUnknown => 'Instance status unknown';

  @override
  String get instances => 'Instances';

  @override
  String get internetOrInstanceIssues =>
      'Buď nejste připojení k internetu, nebo je v tuto chvíli Vaše instance nedostupná.';

  @override
  String get invalidUrl => 'Invalid URL format';

  @override
  String joined(Object x) {
    return 'Joined $x';
  }

  @override
  String get keywordFilterDescription =>
      'Filtruje příspěvky obsahující klíčová slova v nadpise či obsahu';

  @override
  String get keywordFilters => 'Filtry Klíčových Slov';

  @override
  String get label => 'Label';

  @override
  String get language => 'Jazyk';

  @override
  String get languageFilters => 'Looking for language filters?';

  @override
  String get languageNotAllowed =>
      'Komunita, do které se snažíte nahrát svůj příspěvek, nepovoluje příspěvky ve vybraném jazyku. Zkuste jiný jazyk.';

  @override
  String get large => 'Velký';

  @override
  String get leftLongSwipe => 'Dlouhý Levý Swipe';

  @override
  String get leftShortSwipe => 'Krátký Levý Swipe';

  @override
  String get light => 'Světlý';

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
  String get linkHandlingCustomTabs =>
      'Otevřít v systémovém webovém prohlížeči v aplikaci';

  @override
  String get linkHandlingCustomTabsShort => 'In-app embedded';

  @override
  String get linkHandlingExternal =>
      'Externě otevřít systémový webový prohlížeč';

  @override
  String get linkHandlingExternalShort => 'Externí';

  @override
  String get linkHandlingInApp => 'Použít webový prohlížeč v aplikaci Thunder';

  @override
  String get linkHandlingInAppShort => 'V aplikaci';

  @override
  String get linkPostsUseCompactView => 'Show Compact Link Posts';

  @override
  String get linksBehaviourSettings => 'Odkazy';

  @override
  String loadMorePlural(Object count) {
    return 'Načíst $count dalších odpovědí…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Načíst $count další odpovědi…';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get local => 'Místní';

  @override
  String get localNotifications => 'Local Notifications';

  @override
  String get localOnly => 'Local Only';

  @override
  String get localPosts => 'Místní Příspěvky';

  @override
  String get lockPost => 'Zamknout Příspěvek';

  @override
  String get locked => 'Locked';

  @override
  String get lockedPost => 'Locked Post';

  @override
  String get logOut => 'Odhlásit se';

  @override
  String get login => 'Přihlásit se';

  @override
  String get loginAttemptCanceled => 'Login attempt canceled.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Nebylo možné se přihlásit- Zkuste to prosím znovu:($errorMessage)';
  }

  @override
  String get loginSucceeded => 'Přihlášený.';

  @override
  String get loginToPerformAction =>
      'Pro provedení tohoto úkolu se musíte přihlásit.';

  @override
  String get loginToSeeInbox => 'Pro zobrazení přijaté pošty se přihlaste';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Looking for account-specific feed settings?';

  @override
  String get malformedUri =>
      'Daný odkaz je v nepodporovaném formátu. Zkontrolujte si, jestli je platný.';

  @override
  String get manageAccounts => 'Spravovat Účty';

  @override
  String get manageMedia => 'Manage Media';

  @override
  String get markAllAsRead => 'Označit Vše Jako Přečtené';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get markPostAsReadOnMediaView => 'Po Zobrazení Označit Jako Přečtené';

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
  String get medium => 'Střední';

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
  String get missingErrorMessage => 'Žádná chybná zpráva není dostupná';

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
  String get moderatedCommunities => 'Moderované Komunity';

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
  String get moderatorActions => 'Moderátorská Nabídka';

  @override
  String get modlog => 'Modlog';

  @override
  String get mostComments => 'Další Komentáře';

  @override
  String get mustBeLoggedIn => 'You need to be logged in';

  @override
  String get mustBeLoggedInComment => 'Pro komentování se musíte přihlásit';

  @override
  String get mustBeLoggedInPost =>
      'Pro vytvoření příspěvku se musíte přihlásit';

  @override
  String get names => 'Names';

  @override
  String get navbarDoubleTapGestures => 'Dvojklik Gesta na Navigačním Panelu';

  @override
  String get navbarSwipeGestures => 'Swipe Gesta na Navigačním Panelu';

  @override
  String get navigateDown => 'Další Komentář';

  @override
  String get navigateUp => 'Předešlý Komentář';

  @override
  String get navigation => 'Navigace';

  @override
  String get nestedCommentIndicatorColor =>
      'Barva Indikátoru Podřazeného Komentáře';

  @override
  String get nestedCommentIndicatorStyle =>
      'Styl Indikátoru Podřazeného Komentáře';

  @override
  String get networkErrorMessage =>
      'Unable to reach the server. Check your connection and try again.';

  @override
  String get never => 'Never';

  @override
  String get newComments => 'Nové Komentáře';

  @override
  String get newPost => 'Nový Příspěvek';

  @override
  String get new_ => 'Nový';

  @override
  String get no => 'No';

  @override
  String get noAccountsAdded => 'No accounts have been added';

  @override
  String get noAnonymousInstances => 'No anonymous instances have been added';

  @override
  String get noCommentsFound => 'Komentáře nenalezeny.';

  @override
  String get noCommunitiesFound => 'Komunity nenalezeny.';

  @override
  String get noCommunityBlocks => 'Žádné blokované komunity.';

  @override
  String get noCommunitySelected => 'No community selected';

  @override
  String get noCompatibleAppFound => 'No compatible app found';

  @override
  String get noDiscussionLanguages => 'No content is hidden based on language.';

  @override
  String get noDisplayNameSet => 'No display name set';

  @override
  String get noDrafts => 'You do not have any drafts yet';

  @override
  String get noEmailSet => 'No email set';

  @override
  String get noFavoritedCommunities => 'Žádné oblíbené komunity';

  @override
  String get noImages => 'It looks like you have not uploaded any images.';

  @override
  String get noInstanceBlocks => 'Žádné blokované instance.';

  @override
  String get noItems => 'Nic';

  @override
  String get noKeywordFilters => 'Nepřidány žádné filtry klíčových slov';

  @override
  String get noLanguage => 'Žádný jazyk';

  @override
  String get noMatrixUserSet => 'No matrix user set';

  @override
  String get noMentions => 'No mentions';

  @override
  String get noMessages => 'No messages';

  @override
  String get noPostsFound => 'Příspěvky nenalezeny.';

  @override
  String get noProfileBioSet => 'No profile bio set';

  @override
  String get noReferencesToImage =>
      'No posts or comments were found containing this image. However, it may be used elsewhere on the internet.';

  @override
  String get noReplies => 'No replies';

  @override
  String get noResultsFound => 'Nenalezeny žádné výsledky.';

  @override
  String get noSubscriptions => 'Žádné Odběry';

  @override
  String get noUserBlocks => 'Žádní blokování uživatelé.';

  @override
  String get noUserLabels => 'You have not created any user labels yet';

  @override
  String get noUsersFound => 'Žádní uživatelé nenalezeni.';

  @override
  String get noVisibleComments =>
      'Comments may not be visible because the community is blocked.';

  @override
  String get none => 'None';

  @override
  String get normal => 'Normal';

  @override
  String get notAvailable => 'N/A';

  @override
  String notValidLemmyInstance(Object instance) {
    return 'Vypadá to, že $instance není platnou Lemmy instancí';
  }

  @override
  String get notValidUrl => 'Neplatná URL';

  @override
  String get nothingToShare => 'Nic zajímavého';

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
  String get notificationsBehaviourSettings => 'Oznámení';

  @override
  String get notificationsNotAllowed =>
      'Oznámení pro Thunder nejsou v systémovém nastavení povolena';

  @override
  String get notificationsWarningDialog =>
      'Oznámení jsou experimentální funkcí, která nemusí na všech zařízeních fungovat správně.\n\n· Kontrola proběhne každých ~15 minut a spotřebuje další baterii.\n\n· Pro lepší funkci oznámení, vypněte v nastavení optimalizaci baterie.\n\nPro další informace se podívejte na následující stránku.';

  @override
  String get nsfw => 'NSFW';

  @override
  String get nsfwWarning => 'NSFW - Tap to reveal';

  @override
  String get off => 'vypnuto';

  @override
  String get offline => 'offline';

  @override
  String get ok => 'OK';

  @override
  String get old => 'Staré';

  @override
  String get on => 'zapnuté';

  @override
  String get onWifi => 'On Wifi';

  @override
  String get onlyModsCanPostInCommunity =>
      'V této komunitě mohou přispívat jen moderátoři';

  @override
  String get open => 'Otevřeno';

  @override
  String get openAccountSwitcher => 'Open account switcher';

  @override
  String get openByDefault => 'Otevřít výchozím';

  @override
  String get openInBrowser => 'Otevřít v Prohlížeči';

  @override
  String get openInstance => 'Otevřít Instanci';

  @override
  String get openLinksInExternalBrowser =>
      'Otevírat Odkazy v Externích Prohlížečích';

  @override
  String get openLinksInReaderMode => 'Otevírat Odkazy v Módu Čtení';

  @override
  String get openSettings => 'Otevřít Nastavení';

  @override
  String get orange => 'Orange';

  @override
  String get originalPoster => 'Original Poster';

  @override
  String get overview => 'Přehled';

  @override
  String get password => 'Heslo';

  @override
  String get pending => 'Dosud Nevyřízený';

  @override
  String performedBy(Object user) {
    return 'Performed by: $user';
  }

  @override
  String get permissionDenied => 'Povolení Zamítnuto';

  @override
  String get permissionDeniedMessage =>
      'Thunder k uložení tohoto obrázku potřebuje některá povolení, která byla zamítnuta.';

  @override
  String get piefedSupportBeta =>
      'PieFed support is currently in beta.\nNot all features are supported yet.';

  @override
  String get pinPostToCommunity => 'Pin Post to Community';

  @override
  String get pinToCommunity => 'Připnout ke Komunitě';

  @override
  String get pinned => 'Pinned';

  @override
  String get pinnedPostToCommunity => 'Pinned post to community';

  @override
  String get pinnedPostsUseCompactView => 'Show Compact Pinned Posts';

  @override
  String get placeholderText =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  @override
  String get post => 'Post';

  @override
  String get postActions => 'Post Actions';

  @override
  String get postBehaviourSettings => 'Příspěvky';

  @override
  String get postBody => 'Obsah Příspěvku';

  @override
  String get postBodySettings => 'Nastavení Obsahu Příspěvku';

  @override
  String get postBodySettingsDescription =>
      'Toto nastavení ovlivňuje nadpis obsahu u příspěvku';

  @override
  String get postBodyShowCommunityInstance => 'Show Community Instance';

  @override
  String get postBodyShowUserInstance => 'Show User Instance';

  @override
  String get postBodyViewType => 'Typ Zobrazení Obsahu Příspěvku';

  @override
  String get postContentFontScale => 'Post Content Font Scale';

  @override
  String get postCreatedSuccessfully => 'Příspěvek úspěšně vytvořen!';

  @override
  String get postFlairs => 'Flairs';

  @override
  String get postFlairsUnavailable =>
      'No flair options available for this community';

  @override
  String get postLocked => 'Příspěvek zamčen. Odpovědi nejsou povoleny.';

  @override
  String get postMetadataInstructions =>
      'You can customize the metadata information by dragging and dropping the desired information';

  @override
  String get postNSFW => 'Označit jako NSFW';

  @override
  String get postPreview => 'Zobrazit ukázku příspěvku s vybraným nastavením';

  @override
  String get postSavedAsDraft => 'Příspěvek uložen jako koncept';

  @override
  String get postShowUserInstance => 'Show User Instance';

  @override
  String get postSwipeActions => 'Možnosti Swipování u Příspěvku';

  @override
  String get postSwipeGesturesHint =>
      'Chcete spíš používat tlačítka? Změňte, jaká tlačítka se zobrazují na příspěvkových kartách v základním nastavení.';

  @override
  String get postTags => 'Tags';

  @override
  String get postTagsHelperText => 'Separate tags with commas';

  @override
  String get postTitle => 'Nadpis';

  @override
  String get postTitleBold => 'Bold post titles';

  @override
  String get postTitleFontScale => 'Velikost Fontu u Nadpisu Příspěvku';

  @override
  String get postTitleFontWeight => 'Post Title Weight';

  @override
  String get postTitleFontWeightBold => 'Bold';

  @override
  String get postTitleFontWeightExtraBold => 'Extra bold';

  @override
  String get postTitleFontWeightNormal => 'Normal';

  @override
  String get postTogglePreview => 'Ukázat Náhled';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Nebylo možné nahrát obrázek';

  @override
  String get postViewType => 'Typ Zobrazení Příspěvku';

  @override
  String get posts => 'Příspěvky';

  @override
  String get preview => 'Náhled';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile úspěšně použit!';
  }

  @override
  String get profileBio => 'Profile Bio';

  @override
  String get profileOperationInProgress => 'Profile operation in progress';

  @override
  String get profiles => 'Profily';

  @override
  String get public => 'Public';

  @override
  String get pureBlack => 'Čistá Černá';

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
  String get reachedTheBottom => 'Hmmm. Vypadá to, že tu nic dalšího není.';

  @override
  String get read => 'Read';

  @override
  String get readAll => 'Přečíst Vše';

  @override
  String get readerMode => 'Reader mode';

  @override
  String get reason => 'Důvod';

  @override
  String get red => 'Red';

  @override
  String get reduceAnimations => 'Omezit Animace';

  @override
  String get reducesAnimations => 'Omezuje používání animací v Thunder';

  @override
  String get refresh => 'Obnovit';

  @override
  String get refreshContent => 'Obnovit Obsah';

  @override
  String get removalReason => 'Důvod Pro Odstranění';

  @override
  String get remove => 'Odstranit';

  @override
  String get removeAccount => 'Odstranit Účet';

  @override
  String get removeAsCommunityModerator => 'Remove as Community Moderator';

  @override
  String get removeComment => 'Remove Comment';

  @override
  String get removeFromFavorites => 'Odstranit z oblíbených';

  @override
  String get removeInstance => 'Odstranit instanci';

  @override
  String removeKeyword(Object keyword) {
    return 'Odstranit \"$keyword\"?';
  }

  @override
  String get removeKeywordFilter => 'Odstranit Klíčové Slovo';

  @override
  String get removePost => 'Odstranit Příspěvek';

  @override
  String get removeUserData => 'Remove user data';

  @override
  String get removed => 'Removed';

  @override
  String get removedComment => 'Removed Comment';

  @override
  String get removedCommunity => 'Removed Community';

  @override
  String get removedCommunityFromSubscriptions => 'Odešli jste z komunity';

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
      'Odpovídat z tohoto zobrazení v tuto chvíli ještě není podporované';

  @override
  String get replyToComment => 'Reply to Comment';

  @override
  String get replyToPost => 'Odpovědět na Příspěvek';

  @override
  String replyingTo(Object author) {
    return 'Odpovědět $author';
  }

  @override
  String report(num count) {
    return 'Nahlásit';
  }

  @override
  String get reportComment => 'Nahlásit Komentář';

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
  String get reset => 'Resetovat';

  @override
  String get resetCommentPreferences => 'Resetovat nastavení komentářů';

  @override
  String get resetPostPreferences => 'Resetovat nastavení příspěvků';

  @override
  String get resetPreferences => 'Resetovat Nastavení';

  @override
  String get resetPreferencesAndData => 'Resetovat Data a Nastavení';

  @override
  String get restore => 'Obnovit';

  @override
  String get restoreComment => 'Restore Comment';

  @override
  String get restorePost => 'Obnovit Příspěvek';

  @override
  String get restoredComment => 'Restored comment';

  @override
  String get restoredCommentFromDraft => 'Obnovit komentář z konceptu';

  @override
  String get restoredCommunity => 'Restored Community';

  @override
  String get restoredPost => 'Restored Post';

  @override
  String get restoredPostFromDraft => 'Příspěvek obnoven z konceptu';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String get rightLongSwipe => 'Dlouhý Pravý Swipe';

  @override
  String get rightShortSwipe => 'Krátký Pravý Swipe';

  @override
  String get save => 'Uložit';

  @override
  String get saveColor => 'Save Color';

  @override
  String get saveSettings => 'Uložit Nastavení';

  @override
  String get saved => 'Uloženo';

  @override
  String get scaled => 'Velikost změněna';

  @override
  String get scrapeMissingLinkPreviews => 'Scrape Missing Link Previews';

  @override
  String get screenReaderProfile => 'Profil Čtecího Zařízení';

  @override
  String get screenReaderProfileDescription =>
      'Optimalizuje Thunder pro čtecí zařízení snížením počtu celkových prvků a odstraněním potenciálně protichůdných gest.';

  @override
  String get search => 'Hledat';

  @override
  String get searchByText => 'Hledat pomocí textu';

  @override
  String get searchByUrl => 'Hledat pomocí URL';

  @override
  String get searchComments => 'Hledat Komentáře';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return 'Hledat komentáře spojené s $instance';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return 'Hledat komunity spojené s $instance';
  }

  @override
  String searchInstance(Object instance) {
    return 'Hledat $instance';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return 'Search for instances federated with $instance';
  }

  @override
  String get searchPostSearchType => 'Select Post Search Type';

  @override
  String searchPostsFederatedWith(Object instance) {
    return 'Hledat příspěvky spojené s $instance';
  }

  @override
  String get searchTerm => 'Hledat termín';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Hledat uživatelé spojené s $instance';
  }

  @override
  String get selectAccountToCommentAs => 'Select account to comment as';

  @override
  String get selectAccountToPostAs => 'Select account to post as';

  @override
  String get selectAll => 'Select all';

  @override
  String get selectCommunity => 'Vybrat komunitu';

  @override
  String get selectFeedType => 'Vybrat Typ Feedu';

  @override
  String get selectLanguage => 'Vybrat Jazyk';

  @override
  String get selectRecipient => 'Select recipient';

  @override
  String get selectSearchType => 'Vybrat Typ Vyhledávání';

  @override
  String get selectText => 'Select Text';

  @override
  String get send => 'Send';

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
    return 'Při vyhledávání více komentářů jsme narazili na systémovou chybu: $message';
  }

  @override
  String get setAction => 'Nastavit Akci';

  @override
  String get setLongPress => 'Nastavit akci na dlouhé podržení';

  @override
  String get setShortPress => 'Nastavit akci na krátké podržení';

  @override
  String get settingOverrideLabel =>
      'These settings override Thunder\'s default settings.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'Typ nastavení $settingType ještě není podporován.';
  }

  @override
  String get settings => 'Nastavení';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'Settings were successfully saved to \'$savedFilePath\'';
  }

  @override
  String get settingsFeedCards =>
      'Toto nastavení ovlivňuje karty na hlavním feedu. Akce jsou vždy dostupné po otevření daného příspěvku.';

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
  String get share => 'Sdílet';

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
  String get shareLink => 'Sdílet Odkaz';

  @override
  String get shareMedia => 'Sdílet Médium';

  @override
  String get shareMediaLink => 'Share Media Link';

  @override
  String get shareOriginalLink => 'Share Original Link';

  @override
  String get sharePost => 'Sdílet Příspěvek';

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
  String get showAll => 'Zobrazit Vše';

  @override
  String get showBotAccounts => 'Zobrazit Bot Účty';

  @override
  String get showCommentActionButtons => 'Zobrazit u Komentáře Tlačítka Akcí';

  @override
  String get showCommunityDisplayNames => 'Show Community Display Names';

  @override
  String get showCrossPosts => 'Zobrazit Cross Příspěvek';

  @override
  String get showEdgeToEdgeImages => 'Zobrazit Celoplošné Obrázky';

  @override
  String get showExpandedTaglines => 'Show expanded taglines';

  @override
  String get showFullDate => 'Show Full Date';

  @override
  String get showFullDateDescription => 'Show full date on posts';

  @override
  String get showFullHeightImages => 'Zobrazit Obrázky v Plné Velikosti';

  @override
  String get showHiddenPosts => 'Show Hidden Posts';

  @override
  String get showInAppUpdateNotifications =>
      'Buďte upozorněni, když na GitHubu vyjdou nové verze';

  @override
  String get showLess => 'Zobrazit méně';

  @override
  String get showMore => 'Zobrazit více';

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
  String get showPassword => 'Zobrazit heslo';

  @override
  String get showPostAuthor => 'Zobrazit Autora Příspěvku';

  @override
  String get showPostAuthorSubtitle =>
      'Post author is always shown in community feeds';

  @override
  String get showPostCommunityFirst => 'Show Community and Author First';

  @override
  String get showPostCommunityIcons => 'Zobrazit Komunitní Ikony';

  @override
  String get showPostSaveAction => 'Zobrazit Tlačítko Ukládání';

  @override
  String get showPostTextContentPreview => 'Zobrazit Náhled Textu';

  @override
  String get showPostTitleFirst => 'Zobrazovat Nadpis První';

  @override
  String get showPostVoteActions => 'Zobrazit Volící Tlačítka';

  @override
  String get showReadPosts => 'Zobrazit Přečtené Příspěvky';

  @override
  String get showSavedContent => 'Show saved content';

  @override
  String get showScoreCounters => 'Zobrazit Uživatelská Skóre';

  @override
  String get showScores => 'Zobrazit Příspěvková/Komentářová Skóre';

  @override
  String get showTextPostIndicator => 'Show Text Post Indicator';

  @override
  String get showThumbnailPreviewOnRight => 'Zobrazovat Náhledy Napravo';

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
  String get showUserInstance => 'Zobrazit Uživatelskou Instanci';

  @override
  String get sidebar => 'Boční Panel';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Dvoj-klikem na spodní navigaci otevřete boční panel';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Pro otevření bočního panelu swipněte na spodní navigaci';

  @override
  String get small => 'Malé';

  @override
  String get somethingWentWrong => 'Jejda, něco se nám pokazilo!';

  @override
  String get sortBy => 'Seřadit Podle';

  @override
  String get sortByTop => 'Seřadit od Nejlepšího';

  @override
  String get sortOptions => 'Nabídky Seřazení';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get standard => 'Standard';

  @override
  String get stats => 'Stats';

  @override
  String get status => 'Status';

  @override
  String get submit => 'Odeslat';

  @override
  String get subscribe => 'Odebírat';

  @override
  String get subscribeToCommunity => 'Odebírat Komunitu';

  @override
  String get subscribed => 'Odebíráno';

  @override
  String get subscriptionRequestSent => 'Subscription request sent';

  @override
  String get subscriptions => 'Odběry';

  @override
  String successfullyBannedUser(Object username) {
    return 'Banned $username';
  }

  @override
  String get successfullyBlocked => 'Zablokováno.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return 'Zablokováno $communityName';
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
  String get successfullyUnblocked => 'Odblokováno.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return 'Odblokováno $communityName';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return 'Unblocked $username';
  }

  @override
  String get suchAs => 'such as';

  @override
  String get suggestedTitle => 'Navrhovaný název';

  @override
  String switchedAccount(Object username) {
    return 'Switched to $username';
  }

  @override
  String get system => 'Systém';

  @override
  String get systemDarkMode => 'Pure Black';

  @override
  String get systemDarkModeDescription =>
      'Enable pure black theme for dark mode';

  @override
  String get tabletMode => 'Režim Tabletu (zobrazení 2 sloupců)';

  @override
  String get tapToExit => 'Pro odchod znovu zmáčkněte zpět';

  @override
  String get tappableAuthorCommunity => 'Proklikatelní Autoři & Komunity';

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
  String get theme => 'Téma';

  @override
  String get themeAccentColor => 'Barvy Zvýraznění';

  @override
  String get themePrimary => 'Theme Primary';

  @override
  String get themeSecondary => 'Theme Secondary';

  @override
  String get themeTertiary => 'Theme Tertiary';

  @override
  String get theming => 'Témata';

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
      'Chyba: Při pokusu uložit komentář vypršel časový limit';

  @override
  String get timeoutSavingPost =>
      'Chyba: Při pokusu uložit příspěvek vypršel časový limit.';

  @override
  String get timeoutUpvoteComment =>
      'Chyba: Při pokusu hodnocení komentáře vypršel časový limit';

  @override
  String get timeoutVotingPost =>
      'Chyba: Při pokusu hodnocení příspěvku vypršel časový limit.';

  @override
  String get toggelRead => 'Toggle Read';

  @override
  String get top => 'Nejlepší';

  @override
  String get topAll => 'Nejlepší od počátku věků';

  @override
  String get topDay => 'Nejlepší Dnes';

  @override
  String get topHour => 'Nejlepší za Poslední Hodinu';

  @override
  String get topMonth => 'Nejlepší za Tento Měsíc';

  @override
  String get topNineMonths => 'Nejlepší za Posledních 9 Měsíců';

  @override
  String get topSixHour => 'Nejlepší za Posledních 6 Hodin';

  @override
  String get topSixMonths => 'Nejlepší za Posledních 6 Měsíců';

  @override
  String get topThreeMonths => 'Nejlepší za Poslední 3 Měsíce';

  @override
  String get topTwelveHour => 'Nejlepší za Posledních 12 Hodin';

  @override
  String get topWeek => 'Nejlepší za Týden';

  @override
  String get topYear => 'Nejlepší za Rok';

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
      'Berte na vědomí, že překlady nemusí být dokončeny';

  @override
  String get trendingCommunities => 'Populární Komunity';

  @override
  String get trySearchingFor => 'Zkuste hledat…';

  @override
  String get unableToFindCommunity => 'Nebylo možné najít komunitu';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'Nebylo možné najít komunitu \'$communityName\'';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Unable to find the selected community on the selected user\'s instance.';

  @override
  String get unableToFindInstance => 'Nebylo možné najít instanci';

  @override
  String get unableToFindLanguage => 'Nebylo možné dohledat jazyk';

  @override
  String get unableToFindPost => 'Unable to find post';

  @override
  String get unableToFindUser => 'Nebylo možné najít uživatele';

  @override
  String unableToFindUserName(Object username) {
    return 'Unable to find user \'$username\'';
  }

  @override
  String get unableToLoadImage => 'Obrázek nebylo možné načíst';

  @override
  String unableToLoadImageFrom(Object domain) {
    return 'Nebylo možné načíst obrázek z $domain';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return 'Nebylo možné načíst $instance';
  }

  @override
  String get unableToLoadPost => 'Unable to load post';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return 'Nebylo možné načíst příspěvky z $instance';
  }

  @override
  String get unableToLoadReplies => 'Nebylo možné načíst další odpovědi.';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return 'Nebylo možné se spojit s $instanceHost. Je možné, že to není platná Lemmy instance.';
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
  String get unblockInstance => 'Odblokovat Instanci';

  @override
  String get unblockUser => 'Unblock User';

  @override
  String get unblockUserInstance => 'Unblock User Instance';

  @override
  String get understandEnable => 'Chápu, I Tak Pokračovat';

  @override
  String get unexpectedError => 'Neočekávaná Chyba';

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
  String get unlockPost => 'Odblokovat Příspěvek';

  @override
  String get unlockedPost => 'Unlocked Post';

  @override
  String get unpinFromCommunity => 'Odepnout z Komunity';

  @override
  String get unpinPostFromCommunity => 'Unpin Post from Community';

  @override
  String get unpinnedPostFromCommunity => 'Unpinned post from community';

  @override
  String get unreachable => 'Unreachable';

  @override
  String get unresolved => 'Unresolved';

  @override
  String get unsubscribe => 'Zrušit Odběr';

  @override
  String get unsubscribeFromCommunity => 'Zrušit Odběr u Komunity';

  @override
  String get unsubscribePending => 'Unsubscribe (subscription pending)';

  @override
  String get unsubscribed => 'Odběr Zrušen';

  @override
  String get untitledCommentDraft => 'Untitled comment draft';

  @override
  String get untitledPostDraft => 'Untitled post draft';

  @override
  String updateReleased(Object version) {
    return 'Aktualizace vydána: $version';
  }

  @override
  String get uploadImage => 'Nahrát obrázek';

  @override
  String uploadedDate(Object date) {
    return 'Uploaded: $date';
  }

  @override
  String get upvote => 'Souhlas';

  @override
  String get upvoteColor => 'Upvote Color';

  @override
  String get upvoted => 'Upvoted';

  @override
  String get uriNotSupported =>
      'V tuto chvíli tento typ odkazu není podporován.';

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
  String get useCompactView => 'Povolit pro malé příspěvky, zakázat pro velké.';

  @override
  String get useLocalNotifications => 'Use Local Notifications (Experimental)';

  @override
  String get useLocalNotificationsDescription =>
      'Periodically checks for notifications in the background';

  @override
  String get useMaterialYouTheme => 'Použít Téma Material You';

  @override
  String get useMaterialYouThemeDescription => 'Přepsat vybrané upravené téma';

  @override
  String get useProfilePictureForDrawer => 'Use Profile Picture for Drawer';

  @override
  String get useProfilePictureForDrawerSubtitle =>
      'When logged in, shows the user\'s profile picture in place of the drawer icon';

  @override
  String useSuggestedTitle(Object title) {
    return 'Použít navrhovaný název: $title';
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
  String get userFormat => 'Uživatelský Formát';

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
  String get userNotLoggedIn => 'Uživatel není přihlášen';

  @override
  String get userProfiles => 'Uživatelské Profily';

  @override
  String get userSettingDescription =>
      'Tato nastavení se synchronizují s Vašim Lemmy účtem a jsou použity jen u daného účtu.';

  @override
  String get userStyle => 'User Style';

  @override
  String get username => 'Uživatelské Jméno';

  @override
  String get usernameFormattingRedirect => 'Looking for username formatting?';

  @override
  String get users => 'Uživatelé';

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
  String get viewAllComments => 'Zobrazit všechny komentáře';

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
  String get visitCommunity => 'Navštívit Komunitu';

  @override
  String get visitCommunityInstance => 'Visit Community Instance';

  @override
  String get visitInstance => 'Navštívit Instanci';

  @override
  String get visitUserInstance => 'Visit User Instance';

  @override
  String get visitUserProfile => 'Navštívit Uživatelský Profil';

  @override
  String get warning => 'Varování';

  @override
  String xDownvotes(Object x) {
    return '$x nesouhlasů';
  }

  @override
  String xScore(Object x) {
    return '$x skóre';
  }

  @override
  String xUpvotes(Object x) {
    return '$x souhlasů';
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
