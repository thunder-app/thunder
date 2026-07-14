// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get about => 'O aplikácii';

  @override
  String get accept => 'Accept';

  @override
  String get accessibility => 'Prístupnosť';

  @override
  String get accessibilityProfilesDescription =>
      'Umožňujú aplikovať viacero nastavení prístupnosti naraz.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Účty',
      one: 'Účet',
      zero: 'Účet',
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
  String get accountSettings => 'Nastavenia účtu';

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
  String get actions => 'Akcie';

  @override
  String get active => 'Aktívny';

  @override
  String get activity => 'Activity';

  @override
  String get add => 'Pridať';

  @override
  String get addAccount => 'Pridať účet';

  @override
  String get addAccountToSeeProfile =>
      'Prihláste sa, aby ste videli svoj účet.';

  @override
  String get addAnonymousInstance => 'Pridať anonymnú inštanciu';

  @override
  String get addAsCommunityModerator => 'Add as Community Moderator';

  @override
  String get addDiscussionLanguage => 'Add Language';

  @override
  String get addKeywordFilter => 'Pridať kľúčové slovo';

  @override
  String get addOriginalPostBody => 'Add original post body?';

  @override
  String get addToFavorites => 'Pridať do obľúbených';

  @override
  String get addUserLabel => 'Add User Label';

  @override
  String get addedCommunityToSubscriptions => 'Odoberané komunity';

  @override
  String get addedInstanceMod => 'Moderátor inštancie pridaný';

  @override
  String get addedModToCommunity => 'Pridaný moderátor do komunity';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return 'Added $username as community moderator';
  }

  @override
  String get admin => 'Administrátor';

  @override
  String get advanced => 'Pokročilé';

  @override
  String ago(Object time) {
    return '$time ago';
  }

  @override
  String get all => 'Všetko';

  @override
  String get allPosts => 'Všetky príspevky';

  @override
  String get allowOpenSupportedLinks =>
      'Povoliť aplikácii otvárať podporované odkazy.';

  @override
  String get alreadyPostedTo => 'Už pridané do';

  @override
  String get altText => 'Alt Text';

  @override
  String get alternateSources => 'Alternate Sources';

  @override
  String get always => 'Always';

  @override
  String andXMore(Object count) {
    return 'a $count ďalšie';
  }

  @override
  String get animations => 'Animácie';

  @override
  String get anonymous => 'Anonymný';

  @override
  String get anonymousInstances => 'Anonymous Instances';

  @override
  String get appLanguage => 'Jazyk aplikácie';

  @override
  String get appearance => 'Vzhľad';

  @override
  String get applePushNotificationService => 'Apple Push Notification Service';

  @override
  String get applied => 'Aplikované';

  @override
  String get apply => 'Použiť';

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
  String get back => 'Späť';

  @override
  String get backButton => 'Tlačidlo späť';

  @override
  String get backToTop => 'Späť na začiatok';

  @override
  String get backgroundCheckWarning =>
      'Uvedomte si, že kontroly upozornení budú spotrebúvať viac energie';

  @override
  String get ban => 'Ban';

  @override
  String get banFromCommunity => 'Ban from Community';

  @override
  String get bannedUser => 'Zablokovaný používateľ';

  @override
  String get bannedUserFromCommunity => 'Zablokovaný používateľ z komunity';

  @override
  String get base => 'Normálny';

  @override
  String get block => 'Block';

  @override
  String get blockCommunity => 'Zablokovať komunitu';

  @override
  String get blockCommunityInstance => 'Block Community Instance';

  @override
  String get blockInstance => 'Zablokovať inštanciu';

  @override
  String get blockManagement => 'Block Management';

  @override
  String get blockSettingLabel => 'User/Community/Instance Blocks';

  @override
  String get blockUser => 'Zablokovať používateľa';

  @override
  String get blockUserInstance => 'Block User Instance';

  @override
  String get blockedCommunities => 'Zablokované komunity';

  @override
  String get blockedInstances => 'Zablokované inštancie';

  @override
  String get blockedUsers => 'Zablokovaní používatelia';

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
  String get browserMode => 'Spracovanie odkazov';

  @override
  String browsingAnonymously(Object instance) {
    return 'Momentálne prezeráte $instance anonymne.';
  }

  @override
  String get cancel => 'Zrušiť';

  @override
  String get cannotReportOwnComment => 'Nemôžete nahlásiť vlastný komentár.';

  @override
  String get cantBlockAdmin => 'Nemôžete zablokovať správcu inštancie.';

  @override
  String get cantBlockYourself => 'Nemôžete zablokovať sami seba.';

  @override
  String get cardPostCardMetadataItems => 'Metadáta v karte';

  @override
  String get cardView => 'Kartové zobrazenie';

  @override
  String get cardViewDescription =>
      'Povoľte kartové zobrazenie pre zmenu nastavení';

  @override
  String get cardViewSettings => 'Nastavenia kartového zobrazenia';

  @override
  String get changeAccountSettingsFor => 'Zmena nastavení účtu pre';

  @override
  String get changeNotificationSettings => 'Change notification settings...';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordWarning =>
      'To change your password, you will be redirected to your instance site. \n\nAre you sure you want to continue?';

  @override
  String get changeSort => 'Zmeniť zoradenie';

  @override
  String clearCache(Object cacheSize) {
    return 'Vyčistiť vyrovnávaciu pamäť ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Clear Cache';

  @override
  String get clearDatabase => 'Vyčistiť databázu';

  @override
  String get clearPreferences => 'Vymazať nastavenia';

  @override
  String get clearSearch => 'Vyčistiť vyhľadávanie';

  @override
  String get clearedCache => 'Vyčistenie vyrovnávacej pamäte bolo úspešné.';

  @override
  String get clearedDatabase =>
      'Lokálna databáza vyčistená. Aby sa zmeny prejavili, reštartujte Thunder.';

  @override
  String get clearedUserPreferences =>
      'Vymazali sa všetky používateľské preferencie';

  @override
  String get close => 'Zavrieť';

  @override
  String get collapse => 'Collapse';

  @override
  String get collapseCommentPreview => 'Zbaliť náhľad komentára';

  @override
  String get collapseInformation => 'Zbaliť informácie';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Skryť nadradený komentár pri zbalení';

  @override
  String get collapsePost => 'Zbaliť príspevok';

  @override
  String get collapsePostPreview => 'Zbaliť náhľad príspevku';

  @override
  String get collapseSpoiler => 'Zbaliť spoiler';

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
  String get combineCommentScores => 'Kombinovať hodnotenie komentárov';

  @override
  String get combineCommentScoresLabel => 'Kombinovať hodnotenie komentárov';

  @override
  String get combineNavAndFab => 'Skombinovať PAT s navigačnými tlačidlami';

  @override
  String get combineNavAndFabDescription =>
      'Plávajúce akčné tlačidlo bude zobrazené medzi navigačnými tlačidlami.';

  @override
  String get comfortable => 'Comfortable';

  @override
  String get comment => 'Komentár';

  @override
  String get commentActions => 'Comment Actions';

  @override
  String get commentBehaviourSettings => 'Komentáre';

  @override
  String get commentFontScale => 'Mierka písma obsahu komentára';

  @override
  String get commentPreview =>
      'Zobraziť náhľad komentárov s danými nastaveniami';

  @override
  String get commentReported => 'Komentár bol označený na preverenie.';

  @override
  String get commentSavedAsDraft => 'Komentár uložený ako návrh';

  @override
  String get commentShowUserAvatar => 'Show User Avatar';

  @override
  String get commentShowUserInstance => 'Zobraziť používateľskú inštanciu';

  @override
  String get commentSortType => 'Typ zoradenia komentárov';

  @override
  String get commentSwipeActions => 'Akcie potiahnutím komentára';

  @override
  String get commentSwipeGesturesHint =>
      'Chcete radšej používať tlačidlá? Zapnete ich vo všeobecných nastaveniach v sekcii komentárov.';

  @override
  String get comments => 'Komentáre';

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
  String get communityFormat => 'Formát komunity';

  @override
  String get communityNameColor => 'Community Name Color';

  @override
  String get communityNameThickness => 'Community Name Thickness';

  @override
  String get communityStyle => 'Community Style';

  @override
  String get compact => 'Compact';

  @override
  String get compactPostCardMetadataItems => 'Metadáta v kompaktnom zobrazení';

  @override
  String get compactView => 'Kompaktné zobrazenie';

  @override
  String get compactViewDescription =>
      'Zapnite kompaktné zobrazenie pre zmenu nastavení';

  @override
  String get compactViewSettings => 'Nastavenia kompaktného zobrazenia';

  @override
  String get condensed => 'Zhustené';

  @override
  String get confirm => 'Potvrdiť';

  @override
  String get confirmLogOutBody => 'Naozaj sa chcete odhlásiť?';

  @override
  String get confirmLogOutTitle => 'Odhlásiť?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Naozaj chcete označiť všetky správy ako prečítané?';

  @override
  String get confirmMarkAllAsReadTitle => 'Označiť všetky ako prečítané?';

  @override
  String get confirmResetCommentPreferences =>
      'Toto vynuluje všetky predvoľby komentárov. Naozaj chcete pokračovať?';

  @override
  String get confirmResetPostPreferences =>
      'Toto vynuluje všetky predvoľby príspevkov. Naozaj chcete pokračovať?';

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
  String get controversial => 'Kontroverzné';

  @override
  String get copiedToClipboard => 'Skopírované do schránky';

  @override
  String get copy => 'Kopírovať';

  @override
  String get copyComment => 'Copy Comment';

  @override
  String get copySelected => 'Copy selected';

  @override
  String get copyText => 'Kopírovať text';

  @override
  String get couldNotDetermineCommentDelete =>
      'Chyba: Nemožno určiť príspevok na vymazanie komentára.';

  @override
  String get couldNotDeterminePostComment =>
      'Chyba: Nepodarilo sa určiť príspevok, ku ktorému sa má komentár pridať.';

  @override
  String get couldntCreateReport =>
      'Nepodarilo sa nahlásiť komentár. Prosím, skúste to neskôr';

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
    return '$count odberateľov';
  }

  @override
  String countUsers(Object count) {
    return '$count používateľov';
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
  String get createAccount => 'Vytvoriť účet';

  @override
  String get createComment => 'Vytvoriť komentár';

  @override
  String get createNewCrossPost => 'Vytvoriť nový cross-príspevok';

  @override
  String get createPost => 'Vytvoriť príspevok';

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
    return 'cross-príspevok z:  $postUrl';
  }

  @override
  String get crossPostedTo => 'Cross-postnuté do';

  @override
  String get currentLongPress => 'Aktuálne nastavené ako podržanie';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Current notifications mode: $mode';
  }

  @override
  String get currentSinglePress => 'Aktuálne nastavené krátke stlačenie';

  @override
  String get customizeSwipeActions =>
      'Prispôsobiť akcie potiahnutia (ťuknutím na položku sa zmení)';

  @override
  String get dangerZone => 'Nebezpečná zóna';

  @override
  String get dark => 'Tmavá';

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
  String get dateFormat => 'Dátum Formát';

  @override
  String get debug => 'Debug';

  @override
  String get debugDescription =>
      'Nasledujúce nastavenia ladenia by sa mali používať len na účely riešenia problémov.';

  @override
  String get debugNotificationsDescription =>
      'Use the following options to troubleshoot issues related to notifications.';

  @override
  String get decline => 'Decline';

  @override
  String get defaultColor => 'Default';

  @override
  String get defaultCommentSortType => 'Predvolený typ triedenia komentárov';

  @override
  String get defaultFeedSortType => 'Predvolený typ zoradenia feedov';

  @override
  String get defaultFeedType => 'Predvolený Typ Feedu';

  @override
  String get delete => 'Odstrániť';

  @override
  String get deleteAccount => 'Vymazať účet';

  @override
  String get deleteAccountDescription =>
      'Ak chcete natrvalo vymazať svoje konto, budete presmerovaní na stránku svojej inštancie. \n\nNaozaj chcete pokračovať?';

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
  String get deleteLocalDatabase => 'Odstrániť lokálnu databázu';

  @override
  String get deleteLocalDatabaseDescription =>
      'Táto akcia odstráni lokálnu databázu a odhlási vás zo všetkých vašich účtov.\n\nNaozaj chcete pokračovať?';

  @override
  String get deleteLocalPreferences => 'Odstrániť miestne predvoľby';

  @override
  String get deleteLocalPreferencesDescription =>
      'Táto akcia odstráni všetky užívateľské predvoľby a nastavenia vo Thunder.\n\nChcete pokračovať?';

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
    return 'Dôvod: $reason';
  }

  @override
  String get dimReadPosts => 'Stmaviť prečítané príspevky';

  @override
  String get directMessage => 'Direct message';

  @override
  String get disable => 'Zakázať';

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
  String get dismissRead => 'Uvoľniť čítanie';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayUserScore => 'Zobraziť skóre používateľov (Karmu).';

  @override
  String get dividerAppearance => 'Divider Appearance';

  @override
  String get doNotShowAgain => 'Do Not Show Again';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Found multiple compatible apps; please install only one';

  @override
  String get downloadingMedia => 'Sťahujem média na zdieľanie…';

  @override
  String get downvote => 'Zníženie počtu hlasov';

  @override
  String get downvoteColor => 'Downvote Color';

  @override
  String get downvoted => 'Downvoted';

  @override
  String get downvotesDisabled => 'Downvotes sú v tejto inštancii vypnuté.';

  @override
  String get drafts => 'Drafts';

  @override
  String get edit => 'Upraviť';

  @override
  String get editComment => 'Upraviť komentár';

  @override
  String get editPost => 'Upraviť príspevok';

  @override
  String get email => 'Email';

  @override
  String get empty => 'Prázdne';

  @override
  String get emptyInbox => 'Prázdna schránka';

  @override
  String get emptyUri =>
      'Odkaz je prázdny. Ak chcete pokračovať, uveďte platný dynamický odkaz.';

  @override
  String get enableCommentNavigation => 'Povoliť navigáciu komentárov';

  @override
  String get enableExperimentalFeatures => 'Enable experimental features';

  @override
  String get enableFeedFab => 'Zapnúť plávajúce tlačidlo na feedoch';

  @override
  String get enableFloatingButtonOnFeeds =>
      'Zapnúť plávajúce tlačidlo na feedoch';

  @override
  String get enableFloatingButtonOnPosts =>
      'Zapnúť plávajúce tlačidlo na príspevkoch';

  @override
  String get enableInboxNotifications =>
      'Povoliť oznámenia v schránke (experimentálne)';

  @override
  String get enablePostFab => 'Zapnúť plávajúce tlačidlo na príspevkoch';

  @override
  String get endOfComments => 'End of comments';

  @override
  String get endSearch => 'Ukončiť vyhľadávanie';

  @override
  String errorDeletingImage(Object error) {
    return 'There was an error deleting the image: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Nepodarilo sa stiahnuť mediálny súbor na zdieľanie: $errorMessage';
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
      'Pri spracovaní odkazu došlo k chybe. Je možné, že vo vašej inštancii nie je k dispozícii.';

  @override
  String get excessiveApiCallsWarning =>
      'Your feed may be taking a while to load due to keyword filters.';

  @override
  String get expand => 'Expand';

  @override
  String get expandCommentPreview => 'Rozšíriť náhľad komentára';

  @override
  String get expandInformation => 'Rozšíriť informácie';

  @override
  String get expandOptions => 'Rozšíriť možnosti';

  @override
  String get expandPost => 'Rozbaliť príspevok';

  @override
  String get expandPostPreview => 'Rozbaliť náhľad príspevku';

  @override
  String get expandSpoiler => 'Rozbaliť spoiler';

  @override
  String get expanded => 'Rozbalený';

  @override
  String get experimentalFeatures => 'Experimental Features';

  @override
  String get experimentalFeaturesDescription =>
      'These features are still in development and may be unstable. Use them at your own risk. You must restart Thunder to take effect.';

  @override
  String get exploreInstance => 'Preskúmať inštanciu';

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
    return 'Nepodarilo sa zablokovať: $errorMessage';
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
    return 'Nepodarilo sa načítať bloky: $errorMessage';
  }

  @override
  String get failedToLoadVideo => 'Failed to load video. Open link in browser?';

  @override
  String get failedToPerformAction => 'Failed to perform action';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'Odblokovanie zlyhalo: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Failed to update notification settings';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Obľúbené';

  @override
  String get featuredPost => 'Pripnutý príspevok';

  @override
  String get feed => 'Feed';

  @override
  String get feedBehaviourSettings => 'Feed';

  @override
  String get feedSettings => 'Feed Settings';

  @override
  String get feedTypeAndSorts => 'Predvolený typ feedu a zoradenie';

  @override
  String get fetchAccountError => 'Nepodarilo sa určiť účet';

  @override
  String filteringBy(Object entity) {
    return 'Filtrovanie podľa $entity';
  }

  @override
  String get filters => 'Filtre';

  @override
  String get floatingActionButton => 'Plávajúce akčné tlačidlo (PAT)';

  @override
  String get floatingActionButtonInformation =>
      'Thunder má plne prispôsobiteľné prostredie PAT, ktoré podporuje niekoľko gest.\n- Potiahnutím nahor zobrazíte ďalšie akcie PAT\n- Potiahnutím nadol/nahor skryjete alebo odkryjete PAT\n\nAk chcete prispôsobiť hlavné a vedľajšie akcie pre PAT, podržte jednu z nižšie uvedených akcií.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'označuje akciu podržaním PAT.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'označuje akciu stlačením PAT.';

  @override
  String get fonts => 'Písma';

  @override
  String get forward => 'Vpred';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Found compatible app; restart Thunder to connect';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Potiahnite prstom kdekoľvek, aby ste sa vrátili späť, keď sú gestá zľava doprava vypnuté';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get fullscreenSwipeGestures => 'Gestá posunutia obrazovky';

  @override
  String get general => 'Všeobecné';

  @override
  String get generalSettings => 'Všeobecné nastavenia';

  @override
  String get gestures => 'Gestá';

  @override
  String get gettingStarted => 'Začíname';

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
  String get hidCommunity => 'Skrytá komunita';

  @override
  String get hidden => 'Hidden';

  @override
  String get hide => 'Hide';

  @override
  String get hideBottomBarOnScroll => 'Hide Bottom Bar on Scroll';

  @override
  String get hideColor => 'Hide Color';

  @override
  String get hideNsfwPostsFromFeed => 'Skryť príspevky NSFW z feedu';

  @override
  String get hideNsfwPreviews => 'Rozmazať NSFW náhľady';

  @override
  String get hidePassword => 'Skryť heslo';

  @override
  String get hideThumbnails => 'Hide Thumbnails';

  @override
  String get hideTopBarOnScroll => 'Skryť hornú lištu pri posúvaní';

  @override
  String get hostInstance => 'Host Instance';

  @override
  String get hot => 'Horúce';

  @override
  String get image => 'Image';

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
  String get importExportSettings => 'Import/Export nastavení';

  @override
  String get importExportThunderSettings => 'Import/Export Thunder Settings';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Import Lemmy account settings';

  @override
  String get importSettings => 'Importovať nastavenia';

  @override
  String inReplyTo(Object post, Object community) {
    return 'V odpovedi na $post v $community';
  }

  @override
  String get in_ => 'in';

  @override
  String get inbox => 'Schránka';

  @override
  String get includeCommunity => 'Zahrnúť komunitu';

  @override
  String get includeExternalLink => 'Zahrnúť externé prepojenie';

  @override
  String get includeImage => 'Zahrnúť obrázok';

  @override
  String get includePostLink => 'Zahrnúť odkaz na príspevok';

  @override
  String get includeText => 'Zahrnúť text';

  @override
  String get includeTitle => 'Zahrnúť nadpis';

  @override
  String get information => 'Informácie';

  @override
  String instance(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inštancií',
      one: 'Inštancia',
      zero: 'Inštancií',
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
    return '$instance už bola pridaná.';
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
      'Možno nie ste pripojený k internetu alebo vaša inštancia je momentálne nedostupná.';

  @override
  String get invalidUrl => 'Invalid URL format';

  @override
  String joined(Object x) {
    return 'Joined $x';
  }

  @override
  String get keywordFilterDescription =>
      'Filtruje príspevky obsahujúce akékoľvek kľúčové slová v názve alebo tele';

  @override
  String get keywordFilters => 'Filtre kľúčových slov';

  @override
  String get label => 'Label';

  @override
  String get language => 'Jazyk';

  @override
  String get languageFilters => 'Looking for language filters?';

  @override
  String get languageNotAllowed =>
      'Komunita, do ktorej prispievate, nepovoľuje príspevky v jazyku, ktorý ste vybrali. Skúste iný jazyk.';

  @override
  String get large => 'Veľký';

  @override
  String get leftLongSwipe => 'Dlhé potiahnutie vľavo';

  @override
  String get leftShortSwipe => 'Krátke potiahnutie vľavo';

  @override
  String get light => 'Svetlá';

  @override
  String link(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odkazy',
      one: 'Odkaz',
      zero: 'Odkaz',
    );
    return '$_temp0 ';
  }

  @override
  String get linkActions => 'Akcie odkazov';

  @override
  String get linkHandlingCustomTabs =>
      'Otvoriť v systémovom prehliadači vloženom v aplikácii';

  @override
  String get linkHandlingCustomTabsShort => 'Vložené v aplikácii';

  @override
  String get linkHandlingExternal => 'Otvoriť v systémovom prehliadači externe';

  @override
  String get linkHandlingExternalShort => 'Externý';

  @override
  String get linkHandlingInApp => 'Použiť vstavaný prehliadač Thunder';

  @override
  String get linkHandlingInAppShort => 'V aplikácii';

  @override
  String get linkPostsUseCompactView => 'Show Compact Link Posts';

  @override
  String get linksBehaviourSettings => 'Links';

  @override
  String loadMorePlural(Object count) {
    return 'Načítať $count ďalších odpovedí…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Načítať $count odpoveď…';
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
  String get localPosts => 'Miestne príspevky';

  @override
  String get lockPost => 'Lock Post';

  @override
  String get locked => 'Locked';

  @override
  String get lockedPost => 'Zamknutý príspevok';

  @override
  String get logOut => 'Odhlásiť sa';

  @override
  String get login => 'Prihlásiť sa';

  @override
  String get loginAttemptCanceled => 'Login attempt canceled.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Prihlásenie zlyhalo. Skúste to prosím znova: ($errorMessage)';
  }

  @override
  String get loginSucceeded => 'Prihlásený.';

  @override
  String get loginToPerformAction =>
      'Na vykonanie tejto akcie musíte byť prihlásení.';

  @override
  String get loginToSeeInbox =>
      'Prihláste sa, aby ste videli svoju doručenú poštu';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Looking for account-specific feed settings?';

  @override
  String get malformedUri =>
      'Odkaz, ktorý ste uviedli, je v nepodporovanom formáte. Uistite sa, že ide o platný odkaz.';

  @override
  String get manageAccounts => 'Spravovať účty';

  @override
  String get manageMedia => 'Manage Media';

  @override
  String get markAllAsRead => 'Označiť všetko ako prečítané';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get markPostAsReadOnMediaView =>
      'Označiť ako prečítané po zobrazení médií';

  @override
  String get markPostAsReadOnScroll => 'Označiť ako prečítané skrolovaním';

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
      other: 'Označenia',
      one: 'Označenie',
      zero: 'Označenie',
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
      other: 'Správy',
      one: 'Správa',
      zero: 'Správa',
    );
    return '$_temp0';
  }

  @override
  String get metadataFontScale => 'Veľkosť fontu metadát';

  @override
  String get missingErrorMessage => 'Nie je k dispozícii žiadna chybová správa';

  @override
  String get modAdd => 'Pridať/Odstrániť moderátorov inštancie';

  @override
  String get modAddCommunity => 'Pridať/Odstrániť moderátorov komunít';

  @override
  String get modBan => 'Zablokovať/Odblokovať moderátorov inštancie';

  @override
  String get modBanFromCommunity =>
      'Zablokovať/Odblokovať používateľov z komunít';

  @override
  String get modFeaturePost => 'Pripnúť/Odopnúť príspevky';

  @override
  String get modLockPost => 'Zamknúť/Odomknúť príspevky';

  @override
  String get modRemoveComment => 'Odstrániť/Obnoviť komentáre';

  @override
  String get modRemoveCommunity => 'Odstrániť/Obnoviť komunity';

  @override
  String get modRemovePost => 'Odstrániť/Obnoviť príspevky';

  @override
  String get modTransferCommunity => 'Presúvané komunity';

  @override
  String get moderatedCommunities => 'Moderované komunity';

  @override
  String get moderates => 'Moderates';

  @override
  String moderator(num count) {
    return 'Moderátor';
  }

  @override
  String get moderatorActions => 'Moderátorské akcie';

  @override
  String get modlog => 'Moderátorské záznamy';

  @override
  String get mostComments => 'Najviac komentárov';

  @override
  String get mustBeLoggedIn => 'You need to be logged in';

  @override
  String get mustBeLoggedInComment =>
      'Musíte byť prihlásený, aby ste mohli komentovať';

  @override
  String get mustBeLoggedInPost =>
      'Musíte byť prihlásený, aby ste mohli vytvoriť príspevok';

  @override
  String get names => 'Names';

  @override
  String get navbarDoubleTapGestures => 'Dvojklikové gestá navigačného panelu';

  @override
  String get navbarSwipeGestures => 'Gestá potiahnutia navigačného panelu';

  @override
  String get navigateDown => 'Ďalší komentár';

  @override
  String get navigateUp => 'Predchádzajúci komentár';

  @override
  String get navigation => 'Navigácia';

  @override
  String get nestedCommentIndicatorColor =>
      'Farba indikátora vnoreného komentára';

  @override
  String get nestedCommentIndicatorStyle =>
      'Štýl indikátora vnoreného komentára';

  @override
  String get networkErrorMessage =>
      'Unable to reach the server. Check your connection and try again.';

  @override
  String get never => 'Never';

  @override
  String get newComments => 'Nové komentáre';

  @override
  String get newPost => 'Nový príspevok';

  @override
  String get new_ => 'Nový';

  @override
  String get no => 'No';

  @override
  String get noAccountsAdded => 'No accounts have been added';

  @override
  String get noAnonymousInstances => 'No anonymous instances have been added';

  @override
  String get noCommentsFound => 'Nenašli sa žiadne komentáre.';

  @override
  String get noCommunitiesFound => 'Nenašli sa žiadne komunity.';

  @override
  String get noCommunityBlocks => 'Žiadne zablokované komunity.';

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
  String get noFavoritedCommunities => 'Žiadne obľúbené komunity';

  @override
  String get noImages => 'It looks like you have not uploaded any images.';

  @override
  String get noInstanceBlocks => 'Žiadne blokované inštancie.';

  @override
  String get noItems => 'Žiadne položky';

  @override
  String get noKeywordFilters => 'Žiadne pridané filtre kľúčových slov';

  @override
  String get noLanguage => 'Žiadny jazyk';

  @override
  String get noMatrixUserSet => 'No matrix user set';

  @override
  String get noMentions => 'No mentions';

  @override
  String get noMessages => 'No messages';

  @override
  String get noPostsFound => 'Nenašli sa žiadne príspevky.';

  @override
  String get noProfileBioSet => 'No profile bio set';

  @override
  String get noReferencesToImage =>
      'No posts or comments were found containing this image. However, it may be used elsewhere on the internet.';

  @override
  String get noReplies => 'No replies';

  @override
  String get noResultsFound => 'Nenašli sa žiadne výsledky.';

  @override
  String get noSubscriptions => 'Žiadne odbery';

  @override
  String get noUserBlocks => 'Žiadni blokovaní používatelia.';

  @override
  String get noUserLabels => 'You have not created any user labels yet';

  @override
  String get noUsersFound => 'Nenašli sa žiadni používatelia.';

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
    return 'Vyzerá to, že $instance nie je platná Lemmy inštancia';
  }

  @override
  String get notValidUrl => 'Not valid URL';

  @override
  String get nothingToShare => 'Nič na zdieľanie';

  @override
  String notifications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Upozornenia',
      one: 'Upozornenie',
      zero: 'Upozornení',
    );
    return '$_temp0';
  }

  @override
  String get notificationsBehaviourSettings => 'Notifications';

  @override
  String get notificationsNotAllowed =>
      'Oznámenia pre Thunder nie sú povolené v nastaveniach systému';

  @override
  String get notificationsWarningDialog =>
      'Notifikácie sú experimentálna funkcionality, ktorá nemusí fungovať správne na všetkých zariadeniach.\n\n- Kontroly budú prebiehať každých ~15 minút a budú spotrebovávať viac energie.\n\n- Vypnite optimalizáciu batérie pre zvýšenie šance úspešných oznámení.\n\nViac informácií nájdete na nasledujúcej stránke.';

  @override
  String get nsfw => 'NSFW';

  @override
  String get nsfwWarning => 'NSFW - Tap to reveal';

  @override
  String get off => 'vypnuté';

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
      'V tejto komunite môžu písať len moderátori';

  @override
  String get open => 'Open';

  @override
  String get openAccountSwitcher => 'Otvorený prepínač účtov';

  @override
  String get openByDefault => 'Open by default';

  @override
  String get openInBrowser => 'Otvoriť v prehliadači';

  @override
  String get openInstance => 'Otvoriť inštanciu';

  @override
  String get openLinksInExternalBrowser =>
      'Otvoriť odkazy v externom prehliadači';

  @override
  String get openLinksInReaderMode => 'Otvoriť odkazy v režime čítačky';

  @override
  String get openSettings => 'Otvoriť nastavenia';

  @override
  String get orange => 'Orange';

  @override
  String get originalPoster => 'Original Poster';

  @override
  String get overview => 'Prehľad';

  @override
  String get password => 'Heslo';

  @override
  String get pending => 'Prebieha';

  @override
  String performedBy(Object user) {
    return 'Performed by: $user';
  }

  @override
  String get permissionDenied => 'Prístup zamietnutý';

  @override
  String get permissionDeniedMessage =>
      'Thunder vyžaduje niektoré povolenia na uloženie tohto obrázka, ktoré boli zamietnuté.';

  @override
  String get piefedSupportBeta =>
      'PieFed support is currently in beta.\nNot all features are supported yet.';

  @override
  String get pinPostToCommunity => 'Pin Post to Community';

  @override
  String get pinToCommunity => 'Pripnúť do komunity';

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
  String get postBehaviourSettings => 'Posts';

  @override
  String get postBody => 'Obsah príspevku';

  @override
  String get postBodySettings => 'Nastavenie obsahu príspevku';

  @override
  String get postBodySettingsDescription =>
      'Tieto nastavenia ovplyvňujú zobrazenie tela príspevku';

  @override
  String get postBodyShowCommunityInstance => 'Show Community Instance';

  @override
  String get postBodyShowUserInstance => 'Show User Instance';

  @override
  String get postBodyViewType => 'Typ zobrazenia tela príspevku';

  @override
  String get postContentFontScale => 'Mierka písma obsahu príspevku';

  @override
  String get postCreatedSuccessfully => 'Príspevok úspešne vytvorený!';

  @override
  String get postFlairs => 'Flairs';

  @override
  String get postFlairsUnavailable =>
      'No flair options available for this community';

  @override
  String get postLocked => 'Post locked. Nie sú povolené žiadne odpovede.';

  @override
  String get postMetadataInstructions =>
      'Informácie o metadátach môžete prispôsobiť pretiahnutím požadovaných informácií';

  @override
  String get postNSFW => 'Označiť ako NSFW';

  @override
  String get postPreview => 'Zobraziť náhľad príspevku s danými nastaveniami';

  @override
  String get postSavedAsDraft => 'Príspevok uložený ako koncept';

  @override
  String get postShowUserInstance => 'Show User Instance';

  @override
  String get postSwipeActions => 'Akcie potiahnutia príspevku';

  @override
  String get postSwipeGesturesHint =>
      'Chcete namiesto toho použiť tlačidlá? Vo všeobecných nastaveniach zmeňte, aké tlačidlá sa zobrazujú na kartách príspevkov.';

  @override
  String get postTags => 'Tags';

  @override
  String get postTagsHelperText => 'Separate tags with commas';

  @override
  String get postTitle => 'Nadpis';

  @override
  String get postTitleBold => 'Bold post titles';

  @override
  String get postTitleFontScale => 'Mierka písma nadpisu';

  @override
  String get postTitleFontWeight => 'Post Title Weight';

  @override
  String get postTitleFontWeightBold => 'Bold';

  @override
  String get postTitleFontWeightExtraBold => 'Extra bold';

  @override
  String get postTitleFontWeightNormal => 'Normal';

  @override
  String get postTogglePreview => 'Ukázať náhľad';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Nebolo možné nahrať obrázok';

  @override
  String get postViewType => 'Post View Type';

  @override
  String get posts => 'Príspevky';

  @override
  String get preview => 'Náhľad';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile úspešne použitý!';
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
  String get pureBlack => 'Čisto čierna';

  @override
  String get purgedComment => 'Prečistený komentár';

  @override
  String get purgedCommunity => 'Prečistená komunita';

  @override
  String get purgedPerson => 'Prečistená osoba';

  @override
  String get purgedPost => 'Prečistený príspevok';

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
  String get reachedTheBottom => 'Hmmm. Zdá sa, že ste dosiahli koniec.';

  @override
  String get read => 'Read';

  @override
  String get readAll => 'Čítaj všetko';

  @override
  String get readerMode => 'Reader mode';

  @override
  String get reason => 'Dôvod';

  @override
  String get red => 'Red';

  @override
  String get reduceAnimations => 'Obmedziť animácie';

  @override
  String get reducesAnimations => 'Redukuje animácie použité v rámci Thunder';

  @override
  String get refresh => 'Obnoviť';

  @override
  String get refreshContent => 'Obnoviť obsah';

  @override
  String get removalReason => 'Dôvod odstránenia';

  @override
  String get remove => 'Odobrať';

  @override
  String get removeAccount => 'Odstrániť Účet';

  @override
  String get removeAsCommunityModerator => 'Remove as Community Moderator';

  @override
  String get removeComment => 'Remove Comment';

  @override
  String get removeFromFavorites => 'Odstrániť z obľúbených';

  @override
  String get removeInstance => 'Odstrániť inštanciu';

  @override
  String removeKeyword(Object keyword) {
    return 'Odstrániť \"$keyword\"?';
  }

  @override
  String get removeKeywordFilter => 'Odstrániť kľúčové slovo';

  @override
  String get removePost => 'Odstrániť príspevok';

  @override
  String get removeUserData => 'Remove user data';

  @override
  String get removed => 'Removed';

  @override
  String get removedComment => 'Odstránený komentár';

  @override
  String get removedCommunity => 'Odstránená komunita';

  @override
  String get removedCommunityFromSubscriptions => 'Odber komunity zrušený';

  @override
  String get removedInstanceMod => 'Odstránený moderátor inštancie';

  @override
  String get removedModFromCommunity => 'Odstránený moderátor z komunity';

  @override
  String get removedPost => 'Vymazaný príspevok';

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
      other: 'Odpovede',
      one: 'Odpoveď',
      zero: 'Odpovedí',
    );
    return '$_temp0';
  }

  @override
  String get replyColor => 'Reply Color';

  @override
  String get replyNotSupported =>
      'Odpovedanie z tohto zobrazenia v súčasnosti ešte nie je podporované';

  @override
  String get replyToComment => 'Reply to Comment';

  @override
  String get replyToPost => 'Odpovedať na príspevok';

  @override
  String replyingTo(Object author) {
    return 'Odpovedať $author';
  }

  @override
  String report(num count) {
    return 'Nahlásiť';
  }

  @override
  String get reportComment => 'Nahlásiť komentár';

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
  String get reset => 'Resetovať';

  @override
  String get resetCommentPreferences => 'Resetovať preferencie komentárov';

  @override
  String get resetPostPreferences => 'Resetovať preferencie príspevkov';

  @override
  String get resetPreferences => 'Resetovať predvoľby';

  @override
  String get resetPreferencesAndData => 'Resetovať predvoľby a údaje';

  @override
  String get restore => 'Obnoviť';

  @override
  String get restoreComment => 'Restore Comment';

  @override
  String get restorePost => 'Obnoviť príspevok';

  @override
  String get restoredComment => 'Obnovený komentár';

  @override
  String get restoredCommentFromDraft => 'Obnovený komentár z návrhu';

  @override
  String get restoredCommunity => 'Obnovené komunity';

  @override
  String get restoredPost => 'Obnovený príspevok';

  @override
  String get restoredPostFromDraft => 'Obnovený príspevok z návrhu';

  @override
  String get retry => 'Skúsiť znova';

  @override
  String get rightLongSwipe => 'Dlhé potiahnutie doprava';

  @override
  String get rightShortSwipe => 'Krátke potiahnutie doprava';

  @override
  String get save => 'Uložiť';

  @override
  String get saveColor => 'Save Color';

  @override
  String get saveSettings => 'Uložiť nastavenia';

  @override
  String get saved => 'Uložené';

  @override
  String get scaled => 'Škálované';

  @override
  String get scrapeMissingLinkPreviews => 'Načítať chýbajúce náhľady linkov';

  @override
  String get screenReaderProfile => 'Profil čítačky obrazovky';

  @override
  String get screenReaderProfileDescription =>
      'Optimalizuje hromozvod pre čítačky obrazovky znížením celkového počtu prvkov a odstránením potenciálne konfliktných gest.';

  @override
  String get search => 'Hľadať';

  @override
  String get searchByText => 'Vyhľadávanie podľa textu';

  @override
  String get searchByUrl => 'Vyhľadávanie podľa adresy URL';

  @override
  String get searchComments => 'Vyhľadávanie v komentároch';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return 'Vyhľadať komentáre združené s $instance';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return 'Vyhľadať komunity združené s $instance';
  }

  @override
  String searchInstance(Object instance) {
    return 'Hľadať $instance';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return 'Vyhľadať prípady kŕmené $instance';
  }

  @override
  String get searchPostSearchType => 'Vyberte typ vyhľadávania príspevkov';

  @override
  String searchPostsFederatedWith(Object instance) {
    return 'Vyhľadať príspevky združené s $instance';
  }

  @override
  String get searchTerm => 'Vyhľadávací termín';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Hľadať používateľov združených s $instance';
  }

  @override
  String get selectAccountToCommentAs => 'Select account to comment as';

  @override
  String get selectAccountToPostAs => 'Vybrať účet pre zverejnenie príspevku';

  @override
  String get selectAll => 'Select all';

  @override
  String get selectCommunity => 'Vyberte komunitu';

  @override
  String get selectFeedType => 'Zvoliť druh feedu';

  @override
  String get selectLanguage => 'Vybrať jazyk';

  @override
  String get selectRecipient => 'Select recipient';

  @override
  String get selectSearchType => 'Vybrať typ vyhľadávania';

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
      'Môže obsahovať citlivý obsah. Kliknite pre zobrazenie.';

  @override
  String get sentRequestForTestNotification =>
      'Sent request for test notification.';

  @override
  String serverErrorComments(Object message) {
    return 'Pri načítaní ďalších komentárov došlo k chybe servera: $message';
  }

  @override
  String get setAction => 'Set Action';

  @override
  String get setLongPress => 'Nastaviť ako akciu podržania';

  @override
  String get setShortPress => 'Nastaviť ako akciu stlačenia';

  @override
  String get settingOverrideLabel =>
      'These settings override Thunder\'s default settings.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'Nastavenia typu $settingType zatiaľ nie sú podporované.';
  }

  @override
  String get settings => 'Nastavenia';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'Settings were successfully saved to \'$savedFilePath\'';
  }

  @override
  String get settingsFeedCards =>
      'Tieto nastavenia sa vzťahujú na karty v hlavnom feede. Akcie sú vždy k dispozícii po otvorení príspevkov.';

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
  String get share => 'Zdieľať';

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
  String get shareLink => 'Zdieľať link';

  @override
  String get shareMedia => 'Zdieľať médiá';

  @override
  String get shareMediaLink => 'Share Media Link';

  @override
  String get shareOriginalLink => 'Share Original Link';

  @override
  String get sharePost => 'Zdieľať príspevok';

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
  String get showAll => 'Zobraziť všetky';

  @override
  String get showBotAccounts => 'Zobraziť botové účty';

  @override
  String get showCommentActionButtons => 'Zobraziť tlačidlá akcií komentárov';

  @override
  String get showCommunityDisplayNames => 'Show Community Display Names';

  @override
  String get showCrossPosts => 'Zobraziť cross-príspevky';

  @override
  String get showEdgeToEdgeImages => 'Zobraziť obrázky z okraja na okraj';

  @override
  String get showExpandedTaglines => 'Show expanded taglines';

  @override
  String get showFullDate => 'Zobraziť celý dátum';

  @override
  String get showFullDateDescription => 'Zobraziť celý dátum na príspevky';

  @override
  String get showFullHeightImages => 'Zobraziť obrázky na celú výšku';

  @override
  String get showHiddenPosts => 'Show Hidden Posts';

  @override
  String get showInAppUpdateNotifications =>
      'Dostať upozornenie na nové vydania GitHub';

  @override
  String get showLess => 'Zobraziť menej';

  @override
  String get showMore => 'Zobraziť viac';

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
  String get showPassword => 'Zobraziť heslo';

  @override
  String get showPostAuthor => 'Zobraziť autora príspevku';

  @override
  String get showPostAuthorSubtitle =>
      'Post author is always shown in community feeds';

  @override
  String get showPostCommunityFirst => 'Show Community and Author First';

  @override
  String get showPostCommunityIcons => 'Zobraziť ikony komunity';

  @override
  String get showPostSaveAction => 'Zobraziť tlačidlo uložiť';

  @override
  String get showPostTextContentPreview => 'Zobraziť náhľad textu';

  @override
  String get showPostTitleFirst => 'Zobraziť nadpis ako prvý';

  @override
  String get showPostVoteActions => 'Zobraziť tlačidlá hlasovania';

  @override
  String get showReadPosts => 'Zobraziť prečítané príspevky';

  @override
  String get showSavedContent => 'Show saved content';

  @override
  String get showScoreCounters => 'Zobraziť skóre používateľov';

  @override
  String get showScores => 'Zobraziť skóre príspevkov/komentárov';

  @override
  String get showTextPostIndicator => 'Zobraziť indikátor textového príspevku';

  @override
  String get showThumbnailPreviewOnRight => 'Zobraziť miniatúry vpravo';

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
  String get showUserDisplayNames => 'Zobraziť názvy používateľov';

  @override
  String get showUserInstance => 'Zobraziť inštanciu používateľa';

  @override
  String get sidebar => 'Bočný panel';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Dvojitým poklepaním na spodnú navigáciu otvoríte bočný panel';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Potiahnutím prstom po spodnej navigácii otvoríte bočný panel';

  @override
  String get small => 'Malé';

  @override
  String get somethingWentWrong => 'Hups, niečo sa pokazilo!';

  @override
  String get sortBy => 'Zoradiť podľa';

  @override
  String get sortByTop => 'Zoradiť od najlepšieho';

  @override
  String get sortOptions => 'Možnosti zoradenia';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get standard => 'Standard';

  @override
  String get stats => 'Stats';

  @override
  String get status => 'Status';

  @override
  String get submit => 'Odoslať';

  @override
  String get subscribe => 'Predplatiť';

  @override
  String get subscribeToCommunity => 'Prihlásiť sa ku komunite';

  @override
  String get subscribed => 'Odoberané';

  @override
  String get subscriptionRequestSent => 'Subscription request sent';

  @override
  String get subscriptions => 'Odbery';

  @override
  String successfullyBannedUser(Object username) {
    return 'Banned $username';
  }

  @override
  String get successfullyBlocked => 'Zablokované.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return 'Zablokované $communityName';
  }

  @override
  String successfullyBlockedUser(Object username) {
    return '$username zablokovaný';
  }

  @override
  String successfullyUnbannedUser(Object username) {
    return 'Unbanned $username';
  }

  @override
  String get successfullyUnblocked => 'Odblokované.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return 'Odblokované $communityName';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return '$username odblokovaný';
  }

  @override
  String get suchAs => 'such as';

  @override
  String get suggestedTitle => 'Navrhovaný názov';

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
  String get tabletMode => 'Režim tabletu (zobrazenie v 2 stĺpcoch)';

  @override
  String get tapToExit => 'Stlačte znova späť pre ukončenie';

  @override
  String get tappableAuthorCommunity =>
      'Autori a komunity, na ktoré možno ťukať';

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
  String get themeAccentColor => 'Farby zvýraznenia';

  @override
  String get themePrimary => 'Theme Primary';

  @override
  String get themeSecondary => 'Theme Secondary';

  @override
  String get themeTertiary => 'Theme Tertiary';

  @override
  String get theming => 'Témy';

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
      'Error: Timeout pri pokuse o načítanie komentárov';

  @override
  String get timeoutErrorMessage =>
      'Pri čakaní na odpoveď nastal časový limit.';

  @override
  String get timeoutSaveComment =>
      'Chyba: Timeout pri pokuse o uloženie komentára';

  @override
  String get timeoutSavingPost =>
      'Chyba: Timeout pri pokuse o uloženie príspevku.';

  @override
  String get timeoutUpvoteComment =>
      'Chyba: Timeout pri pokuse o hlasovanie komentára';

  @override
  String get timeoutVotingPost =>
      'Chyba: Timeout pri pokuse o hlasovanie príspevku.';

  @override
  String get toggelRead => 'Prepnúť čítanie';

  @override
  String get top => 'Top';

  @override
  String get topAll => 'Top všetkých čias';

  @override
  String get topDay => 'Top dnes';

  @override
  String get topHour => 'Top za hodinu';

  @override
  String get topMonth => 'Top mesiac';

  @override
  String get topNineMonths => 'Top 9 mesiacov';

  @override
  String get topSixHour => 'Top 6 hodín';

  @override
  String get topSixMonths => 'Top 6 mesiacov';

  @override
  String get topThreeMonths => 'Top 3 mesiace';

  @override
  String get topTwelveHour => 'Top 12 hodín';

  @override
  String get topWeek => 'Top týždeň';

  @override
  String get topYear => 'Top rok';

  @override
  String totalComments(Object x) {
    return '$x Comments';
  }

  @override
  String totalPosts(Object x) {
    return '$x Posts';
  }

  @override
  String get totp => 'TOTP (voliteľné)';

  @override
  String get transferredModToCommunity => 'Komunita presunutá';

  @override
  String get translationsMayNotBeComplete =>
      'Upozorňujeme, že preklady nemusia byť úplné';

  @override
  String get trendingCommunities => 'Rastúce komunity';

  @override
  String get trySearchingFor => 'Skúste hľadať...';

  @override
  String get unableToFindCommunity => 'Nie je možné nájsť komunitu';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'Nie je možné nájsť komunitu \'$communityName\'';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Nie je možné nájsť vybranú komunitu v inštancii vybraného používateľa.';

  @override
  String get unableToFindInstance => 'Inštanciu sa nepodarilo nájsť';

  @override
  String get unableToFindLanguage => 'Jazyk sa nepodarilo nájsť';

  @override
  String get unableToFindPost => 'Nemožno nájsť príspevok';

  @override
  String get unableToFindUser => 'Používateľ sa nenašiel';

  @override
  String unableToFindUserName(Object username) {
    return 'Unable to find user \'$username\'';
  }

  @override
  String get unableToLoadImage => 'Nie je možné načítať obrázok';

  @override
  String unableToLoadImageFrom(Object domain) {
    return 'Obrázok z $domain sa nepodarilo načítať';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return 'Inštanciu $instance sa nepodarilo načítať';
  }

  @override
  String get unableToLoadPost => 'Unable to load post';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return 'Nie je možné načítať príspevky z $instance)';
  }

  @override
  String get unableToLoadReplies => 'Nie je možné načítať ďalšie odpovede.';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return 'Unable to navigate to $instanceHost. Možno to nie je platná inštancia Lemmy.';
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
  String get unbannedUser => 'Odblokovaný používateľ';

  @override
  String unbannedUserFromCommunity(Object username) {
    return 'Odblokovaný používateľ z komunity';
  }

  @override
  String get unblock => 'Unblock';

  @override
  String get unblockCommunity => 'Unblock Community';

  @override
  String get unblockCommunityInstance => 'Unblock Community Instance';

  @override
  String get unblockInstance => 'Odblokuj inštanciu';

  @override
  String get unblockUser => 'Unblock User';

  @override
  String get unblockUserInstance => 'Unblock User Instance';

  @override
  String get understandEnable => 'Rozumiem, povoliť';

  @override
  String get unexpectedError => 'Neočakávaná chyba';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get unfeaturedPost => 'Odopnutý príspevok';

  @override
  String get unhidCommunity => 'Odokrytá komunita';

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
  String get unlockPost => 'Odomknúť príspevok';

  @override
  String get unlockedPost => 'Odomknutý príspevok';

  @override
  String get unpinFromCommunity => 'Odopnúť z komunity';

  @override
  String get unpinPostFromCommunity => 'Unpin Post from Community';

  @override
  String get unpinnedPostFromCommunity => 'Unpinned post from community';

  @override
  String get unreachable => 'Nepochybné';

  @override
  String get unresolved => 'Unresolved';

  @override
  String get unsubscribe => 'Zrušiť odber';

  @override
  String get unsubscribeFromCommunity => 'Zrušiť odber z komunity';

  @override
  String get unsubscribePending => 'Zrušiť odber (čaká sa na odber)';

  @override
  String get unsubscribed => 'Odber zrušený';

  @override
  String get untitledCommentDraft => 'Untitled comment draft';

  @override
  String get untitledPostDraft => 'Untitled post draft';

  @override
  String updateReleased(Object version) {
    return 'Aktualizácia vydaná: $version';
  }

  @override
  String get uploadImage => 'Nahrať obrázok';

  @override
  String uploadedDate(Object date) {
    return 'Uploaded: $date';
  }

  @override
  String get upvote => 'Súhlasím';

  @override
  String get upvoteColor => 'Upvote Color';

  @override
  String get upvoted => 'Upvoted';

  @override
  String get uriNotSupported =>
      'Tento typ odkazu nie je momentálne podporovaný.';

  @override
  String get url => 'URL';

  @override
  String get useAdvancedShareSheet => 'Použiť rozšírený zdieľací panel';

  @override
  String get useApplePushNotifications => 'Use APNs Notifications';

  @override
  String get useApplePushNotificationsDescription =>
      'Uses Apple\'s Push Notification service';

  @override
  String get useCompactView => 'Zapnúť pre krátke príspevky, vypnúť pre dlhé.';

  @override
  String get useLocalNotifications => 'Use Local Notifications (Experimental)';

  @override
  String get useLocalNotificationsDescription =>
      'Periodically checks for notifications in the background';

  @override
  String get useMaterialYouTheme => 'Použiť tému Material You';

  @override
  String get useMaterialYouThemeDescription => 'Prepíše vybranú vlastnú tému';

  @override
  String get useProfilePictureForDrawer => 'Use Profile Picture for Drawer';

  @override
  String get useProfilePictureForDrawerSubtitle =>
      'When logged in, shows the user\'s profile picture in place of the drawer icon';

  @override
  String useSuggestedTitle(Object title) {
    return 'Použiť navrhovaný názov: $title';
  }

  @override
  String get useUnifiedPushNotifications => 'Use UnifiedPush Notifications';

  @override
  String get useUnifiedPushNotificationsDescription =>
      'Requires a compatible app';

  @override
  String get user => 'Používateľ';

  @override
  String get userActions => 'User Actions';

  @override
  String userEntry(Object username) {
    return 'User \'$username\'';
  }

  @override
  String get userFormat => 'Formát používateľa';

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
  String get userNotLoggedIn => 'Používateľ nie je prihlásený';

  @override
  String get userProfiles => 'Profily používateľov';

  @override
  String get userSettingDescription =>
      'Tieto nastavenia sa synchronizujú s vaším účtom Lemmy a uplatňujú sa len na základe jednotlivých účtov.';

  @override
  String get userStyle => 'User Style';

  @override
  String get username => 'Používateľské meno';

  @override
  String get usernameFormattingRedirect => 'Looking for username formatting?';

  @override
  String get users => 'Používatelia';

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
  String get viewAll => 'Zobraziť všetko';

  @override
  String get viewAllComments => 'Zobraziť všetky komentáre';

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
  String get visitCommunity => 'Navštíviť komunitu';

  @override
  String get visitCommunityInstance => 'Visit Community Instance';

  @override
  String get visitInstance => 'Navštíviť inštanciu';

  @override
  String get visitUserInstance => 'Visit User Instance';

  @override
  String get visitUserProfile => 'Navštíviť profil používateľa';

  @override
  String get warning => 'Varovanie';

  @override
  String xDownvotes(Object x) {
    return '$x nesúhlasov';
  }

  @override
  String xScore(Object x) {
    return '$x skóre';
  }

  @override
  String xUpvotes(Object x) {
    return '$x súhlasov';
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
