// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get about => 'Informacje';

  @override
  String get accept => 'Akceptuj';

  @override
  String get accessibility => 'Dostępność';

  @override
  String get accessibilityProfilesDescription =>
      'Accessibility Profiles allow you to apply several settings at once with the goal of accommodating a particular accessibility requirement.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Konta',
      one: 'Konto',
      zero: 'Kont',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'Urodziny konta $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'Preferencje twojego konta napiszą obecne ustawienia';

  @override
  String get accountSettings => 'Ustawienia konta';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'Ustawienia konta Lemmy zostały pomyślnie wyeksportowane do $savedFilePath!';
  }

  @override
  String get accountSettingsImportedSuccessfully =>
      'Ustawienia konta Lemmy zostały pomyślnie zaimportowane!';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return 'The selected comment was not found on \'$instance\'';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'Wybrany wpis nie został znaleziony na \'$instance\'. Powrót do poprzedniego konta.';
  }

  @override
  String get actionColors => 'Kolory akcji';

  @override
  String get actionColorsRedirect => 'Chcesz dostosować kolory?';

  @override
  String get actions => 'Akcje';

  @override
  String get active => 'Aktywne';

  @override
  String get activity => 'Aktywność';

  @override
  String get add => 'Dodaj';

  @override
  String get addAccount => 'Dodaj Konto';

  @override
  String get addAccountToSeeProfile => 'Zaloguj się by zobaczyć swoje konto.';

  @override
  String get addAnonymousInstance => 'Dodaj Anonimową Instancję';

  @override
  String get addAsCommunityModerator => 'Dodaj jako Moderator Społeczności';

  @override
  String get addDiscussionLanguage => 'Dodaj język';

  @override
  String get addKeywordFilter => 'Dodaj Słowo Klucz';

  @override
  String get addOriginalPostBody => 'Add original post body?';

  @override
  String get addToFavorites => 'Dodaj do ulubionych';

  @override
  String get addUserLabel => 'Dodaj nazwę użytkownika';

  @override
  String get addedCommunityToSubscriptions => 'Zasubskrybowano społeczność';

  @override
  String get addedInstanceMod => 'Added Instance Mod';

  @override
  String get addedModToCommunity => 'Dodano moderatora do społeczności';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return 'Added $username as community moderator';
  }

  @override
  String get admin => 'Administrator';

  @override
  String get advanced => 'Zaawansowane';

  @override
  String ago(Object time) {
    return '$time temu';
  }

  @override
  String get all => 'Wszystkie';

  @override
  String get allPosts => 'Wszystkie wpisy';

  @override
  String get allowOpenSupportedLinks =>
      'Pozwól aplikacji otwierać wspierane linki.';

  @override
  String get alreadyPostedTo => 'Już utworzono wpis do';

  @override
  String get altText => 'Alternatywny tekst';

  @override
  String get alternateSources => 'Alternatywne źródła';

  @override
  String get always => 'Zawsze';

  @override
  String andXMore(Object count) {
    return 'dodaj $count więcej';
  }

  @override
  String get animations => 'Animacje';

  @override
  String get anonymous => 'Anonimowy';

  @override
  String get anonymousInstances => 'Instancja anonimowa';

  @override
  String get appLanguage => 'Język Aplikacji';

  @override
  String get appearance => 'Wygląd';

  @override
  String get applePushNotificationService => 'Usługa powiadomień Apple';

  @override
  String get applied => 'Zaaplikowane';

  @override
  String get apply => 'Zaaplikuj';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return 'Powiadomienia są zezwolone przez system: $yesOrNo';
  }

  @override
  String averageComments(Object x) {
    return '$x komentarze/miesiąc';
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
  String get back => 'Powrót';

  @override
  String get backButton => 'Przycisk Powrotu';

  @override
  String get backToTop => 'Powrót Do Góry';

  @override
  String get backgroundCheckWarning =>
      'Pamiętaj, że informowanie o powiadomieniach zużywa więcej baterii';

  @override
  String get ban => 'Ban';

  @override
  String get banFromCommunity => 'Ban od społeczności';

  @override
  String get bannedUser => 'Zbanowany użytkownik';

  @override
  String get bannedUserFromCommunity => 'Banned User from Community';

  @override
  String get base => 'Podstawowy';

  @override
  String get block => 'Block';

  @override
  String get blockCommunity => 'Zablokuj Społeczność';

  @override
  String get blockCommunityInstance => 'Block Community Instance';

  @override
  String get blockInstance => 'Zablokuj instancję';

  @override
  String get blockManagement => 'Block Management';

  @override
  String get blockSettingLabel => 'User/Community/Instance Blocks';

  @override
  String get blockUser => 'Zablokuj Użytkownika';

  @override
  String get blockUserInstance => 'Block User Instance';

  @override
  String get blockedCommunities => 'Zablokowane Społeczności';

  @override
  String get blockedInstances => 'Zablokowane instancje';

  @override
  String get blockedUsers => 'Zablokowani Użytkownicy';

  @override
  String get blue => 'Niebieski';

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
    return 'Obecnie przeglądasz $instance anonimowo.';
  }

  @override
  String get cancel => 'Anuluj';

  @override
  String get cannotReportOwnComment =>
      'Nie możesz zgłosić własnego komentarza.';

  @override
  String get cantBlockAdmin =>
      'Nie możesz zablokować administratora instancji.';

  @override
  String get cantBlockYourself => 'Nie możesz zablokować samego siebie.';

  @override
  String get cardPostCardMetadataItems => 'Card View Metadata';

  @override
  String get cardView => 'Widok Kart';

  @override
  String get cardViewDescription => 'Włącz widok kart by dostosować ustawienia';

  @override
  String get cardViewSettings => 'Ustawienia Widoku Kart';

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
  String get changeSort => 'Zmiana Sortowania';

  @override
  String clearCache(Object cacheSize) {
    return 'Wyczyść Pamięć Cache ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Clear Cache';

  @override
  String get clearDatabase => 'Wyczyść Bazę Danych';

  @override
  String get clearPreferences => 'Wyczyść Preferencje';

  @override
  String get clearSearch => 'Wyczyść Wyszukiwanie';

  @override
  String get clearedCache => 'Pamięć cache została wyczyszczona.';

  @override
  String get clearedDatabase =>
      'Lokalna baza danych wyczyszczona. Uruchom ponownie Thunder, aby nowe zmiany zaczęły obowiązywać.';

  @override
  String get clearedUserPreferences =>
      'Wyczyszczono wszystkie preferencje użytkownika';

  @override
  String get close => 'Zamknij';

  @override
  String get collapse => 'Collapse';

  @override
  String get collapseCommentPreview => 'Zwiń Podgląd Komentarza';

  @override
  String get collapseInformation => 'Zwiń Informacje';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Ukryj Górny Komentarz gdy Zwinięty';

  @override
  String get collapsePost => 'Zwiń wpis';

  @override
  String get collapsePostPreview => 'Zwiń Podgląd Wpisu';

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
  String get combineCommentScores => 'Połącz Oceny Komentarza';

  @override
  String get combineCommentScoresLabel => 'Połącz Oceny Komentarza';

  @override
  String get combineNavAndFab => 'Połącz FAB i Przyciski Nawigacji';

  @override
  String get combineNavAndFabDescription =>
      'Lewitujący Przycisk Akcji będzie pokazany pomiędzy przyciskami nawigacji.';

  @override
  String get comfortable => 'Comfortable';

  @override
  String get comment => 'Komentarz';

  @override
  String get commentActions => 'Comment Actions';

  @override
  String get commentBehaviourSettings => 'Komentarze';

  @override
  String get commentFontScale => 'Skala Czcionki Treści Komentarza';

  @override
  String get commentPreview =>
      'Pokaż podgląd komentarzy z następującymi ustawieniami';

  @override
  String get commentReported =>
      'Komentarz został oznaczony jako do sprawdzenia.';

  @override
  String get commentSavedAsDraft => 'Komentarz zapisany jako wersja robocza';

  @override
  String get commentShowUserAvatar => 'Show User Avatar';

  @override
  String get commentShowUserInstance => 'Pokaż Instancję Użytkownika';

  @override
  String get commentSortType => 'Typ Sortowania Komentarzy';

  @override
  String get commentSwipeActions => 'Akcje Gestów na Komentarzach';

  @override
  String get commentSwipeGesturesHint =>
      'Wolisz używać przycisków? Włącz je w sekcji komentarzy w ustawieniach generalnych.';

  @override
  String get comments => 'Komentarze';

  @override
  String get communities => 'Społeczności';

  @override
  String get community => 'Społeczność';

  @override
  String get communityActions => 'Community Actions';

  @override
  String communityEntry(Object community) {
    return 'Community \'$community\'';
  }

  @override
  String get communityFormat => 'Format Społeczności';

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
  String get compactView => 'Widok Kompaktowy';

  @override
  String get compactViewDescription =>
      'Włącz widok kompaktowy aby dostosować ustawienia';

  @override
  String get compactViewSettings => 'Ustawienia Widoku Kompaktowego';

  @override
  String get condensed => 'Zkondensowany';

  @override
  String get confirm => 'Potwierdź';

  @override
  String get confirmLogOutBody => 'Jesteś pewien, że chcesz się wylogować?';

  @override
  String get confirmLogOutTitle => 'Wylogować?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Jesteś pewien, że chcesz oznaczyć wszystkie wiadomości jako przeczytane?';

  @override
  String get confirmMarkAllAsReadTitle =>
      'Oznaczyć Wszystkie Jako Przeczytane?';

  @override
  String get confirmResetCommentPreferences =>
      'To zresetuje wszystkie preferencje komentarzy. Jesteś pewien, że chcesz kontynuować?';

  @override
  String get confirmResetPostPreferences =>
      'To zresetuje wszystkie preferencje wpisów. Jesteś pewien, że chcesz kontynuować?';

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
  String get controversial => 'Kontrowersyjne';

  @override
  String get copiedToClipboard => 'Skopiowano do schowka';

  @override
  String get copy => 'Kopiuj';

  @override
  String get copyComment => 'Copy Comment';

  @override
  String get copySelected => 'Copy selected';

  @override
  String get copyText => 'Kopiuj Tekst';

  @override
  String get couldNotDetermineCommentDelete =>
      'Błąd: Nie udało się ustalić wpisu do usunięcia komentarza.';

  @override
  String get couldNotDeterminePostComment =>
      'Błąd: Nie udało się ustalić wpisu do dodania komentarza.';

  @override
  String get couldntCreateReport =>
      'Twoje zgłoszenie komentarza nie mogło obecnie zostać przekazane. Proszę spróbować później';

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
    return '$count subskrybujących';
  }

  @override
  String countUsers(Object count) {
    return '$count użytkowników';
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
  String get createAccount => 'Stwórz Konto';

  @override
  String get createComment => 'Napisz komentarz';

  @override
  String get createNewCrossPost => 'Create new cross-post';

  @override
  String get createPost => 'Napisz Post';

  @override
  String created(Object date) {
    return 'Created $date';
  }

  @override
  String get createdToday => 'Created Today';

  @override
  String get creator => 'Twórca';

  @override
  String crossPostedFrom(Object postUrl) {
    return 'cross-posted from: $postUrl';
  }

  @override
  String get crossPostedTo => 'Cross-posted to';

  @override
  String get currentLongPress => 'Obecnie ustawione jako przytrzymanie';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Current notifications mode: $mode';
  }

  @override
  String get currentSinglePress =>
      'Obecnie ustawione jako pojedyncze naciśnięcie';

  @override
  String get customizeSwipeActions =>
      'Dostosuj działania przesuwania (dotknij, aby zmienić)';

  @override
  String get dangerZone => 'Strefa Niebezpieczeństwa';

  @override
  String get dark => 'Ciemny';

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
  String get debug => 'Debugowanie';

  @override
  String get debugDescription =>
      'Następujące ustawienia debugowania powinny być używane wyłącznie w celu naprawy błędów.';

  @override
  String get debugNotificationsDescription =>
      'Use the following options to troubleshoot issues related to notifications.';

  @override
  String get decline => 'Decline';

  @override
  String get defaultColor => 'Default';

  @override
  String get defaultCommentSortType => 'Domyślny Typ Sortowania Komentarzy';

  @override
  String get defaultFeedSortType => 'Default Feed Sort Type';

  @override
  String get defaultFeedType => 'Default Feed Type';

  @override
  String get delete => 'Usuń';

  @override
  String get deleteAccount => 'Usuń Konto';

  @override
  String get deleteAccountDescription =>
      'Aby permanentnie usunąć swoje konto, zostaniesz przekierowany do strony swojej instancji. \n\nJesteś pewien, że chcesz kontynuować?';

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
  String get deleteLocalDatabase => 'Usuń Lokalną Bazę Danych';

  @override
  String get deleteLocalDatabaseDescription =>
      'Ta akcja usunie lokalną bazę danych i wyloguje cię ze wszystkich twoich kont.\n\nJesteś pewien, że chcesz kontynuować?';

  @override
  String get deleteLocalPreferences => 'Usuń Lokalne Preferencje';

  @override
  String get deleteLocalPreferencesDescription =>
      'To wyczyści wszystkie twoje preferencje i ustawienia użytkownika w Thunder.\n\nCzy chesz kontynuować?';

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
  String get dimReadPosts => 'Przyciemnij Przeczytane Wpisy';

  @override
  String get directMessage => 'Direct message';

  @override
  String get disable => 'Wyłącz';

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
  String get dismissRead => 'Odrzuć Przeczytane';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayUserScore => 'Wyłącz Punkty Użytkowników (Karma).';

  @override
  String get dividerAppearance => 'Divider Appearance';

  @override
  String get doNotShowAgain => 'Do Not Show Again';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Found multiple compatible apps; please install only one';

  @override
  String get downloadingMedia => 'Pobieranie multimediów do udostępnienia…';

  @override
  String get downvote => 'Downvote';

  @override
  String get downvoteColor => 'Downvote Color';

  @override
  String get downvoted => 'Downvoted';

  @override
  String get downvotesDisabled => 'Głosy w dół są wyłączone w tej instancji.';

  @override
  String get drafts => 'Drafts';

  @override
  String get edit => 'Edytuj';

  @override
  String get editComment => 'Edytuj komentarz';

  @override
  String get editPost => 'Edytuj Wpis';

  @override
  String get email => 'Email';

  @override
  String get empty => 'Puste';

  @override
  String get emptyInbox => 'Pusta Skrzynka';

  @override
  String get emptyUri =>
      'Link jest pusty. Proszę załączyć właściwy dynamiczny link aby kontynuować.';

  @override
  String get enableCommentNavigation => 'Włącz Nawigację Komentarzy';

  @override
  String get enableExperimentalFeatures => 'Enable experimental features';

  @override
  String get enableFeedFab => 'Enable Floating Button on Feeds';

  @override
  String get enableFloatingButtonOnFeeds => 'Enable Floating Button On Feeds';

  @override
  String get enableFloatingButtonOnPosts =>
      'Włącz Lewitujący Przycisk Na Wpisach';

  @override
  String get enableInboxNotifications =>
      'Włącz Powiadomienia o Skrzynce (Eksperymentalne)';

  @override
  String get enablePostFab => 'Włącz Lewitujący Przycisk na Wpisach';

  @override
  String get endOfComments => 'End of comments';

  @override
  String get endSearch => 'Koniec Wyszukiwania';

  @override
  String errorDeletingImage(Object error) {
    return 'There was an error deleting the image: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Nie udało się pobrać pliku multimedialnego do udostępnienia: $errorMessage';
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
      'Wystąpił błąd podczas przetwarzania linku. Link może być niedostępny na twojej instancji.';

  @override
  String get excessiveApiCallsWarning =>
      'Your feed may be taking a while to load due to keyword filters.';

  @override
  String get expand => 'Expand';

  @override
  String get expandCommentPreview => 'Rozwiń Podgląd Komentarza';

  @override
  String get expandInformation => 'Rozwiń Informacje';

  @override
  String get expandOptions => 'Rozwiń opcje';

  @override
  String get expandPost => 'Rozwiń wpis';

  @override
  String get expandPostPreview => 'Rozwiń Podgląd Wpisu';

  @override
  String get expandSpoiler => 'Expand Spoiler';

  @override
  String get expanded => 'Rozwinięte';

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
  String get extraLarge => 'Ekstra Wielkie';

  @override
  String failedToBlock(Object errorMessage) {
    return 'Zablokowanie nie powiodło się: $errorMessage';
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
    return 'Nie udało się wczytać listy blokowanych: $errorMessage';
  }

  @override
  String get failedToLoadVideo => 'Failed to load video. Open link in browser?';

  @override
  String get failedToPerformAction => 'Failed to perform action';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'Odblokowanie nie powiodło się: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Failed to update notification settings';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Ulubione';

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
  String get fetchAccountError => 'Nie można określić konta';

  @override
  String filteringBy(Object entity) {
    return 'Filtrowanie przez $entity';
  }

  @override
  String get filters => 'Filtry';

  @override
  String get floatingActionButton => 'Lewitujący Przycisk Akcji';

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
  String get fonts => 'Czcionki';

  @override
  String get forward => 'Forward';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Found compatible app; restart Thunder to connect';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Przesuń gdziekolwiek by wrócić gdy gesty \"od lewej do prawej\" są wyłączone';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get fullscreenSwipeGestures =>
      'Gesty Przesunięć W Trybie Pełnoekranowym';

  @override
  String get general => 'Ogólne';

  @override
  String get generalSettings => 'Ustawienia Generalne';

  @override
  String get gestures => 'Gesty';

  @override
  String get gettingStarted => 'Pierwsze Kroki';

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
  String get hideNsfwPreviews => 'Ukryj Podgląd Dla Treści NSFW';

  @override
  String get hidePassword => 'Ukryj Hasło';

  @override
  String get hideThumbnails => 'Hide Thumbnails';

  @override
  String get hideTopBarOnScroll => 'Ukryj Górny Pasek Po Przesunięciu Ekranu';

  @override
  String get hostInstance => 'Host Instance';

  @override
  String get hot => 'Na Czasie';

  @override
  String get image => 'Obraz';

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
  String get importExportSettings => 'Import/Eksport Ustawień';

  @override
  String get importExportThunderSettings => 'Import/Export Thunder Settings';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Import Lemmy account settings';

  @override
  String get importSettings => 'Import Ustawień';

  @override
  String inReplyTo(Object post, Object community) {
    return 'W odpowiedzi na $post w $community';
  }

  @override
  String get in_ => 'in';

  @override
  String get inbox => 'Skrzynka';

  @override
  String get includeCommunity => 'Załącz Społeczność';

  @override
  String get includeExternalLink => 'Załącz Zewnętrzny Link';

  @override
  String get includeImage => 'Załącz Obraz';

  @override
  String get includePostLink => 'Załącz Link Do Postu';

  @override
  String get includeText => 'Załącz Tekst';

  @override
  String get includeTitle => 'Załącz Tytuł';

  @override
  String get information => 'Informacje';

  @override
  String instance(num count) {
    return 'Instancja';
  }

  @override
  String get instanceActions => 'Instance Actions';

  @override
  String instanceEntry(Object username) {
    return 'Instance \'$username\'';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance zostało już dodane.';
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
      'You may not be connected to the internet, or your instance may be currently unavailable.';

  @override
  String get invalidUrl => 'Invalid URL format';

  @override
  String joined(Object x) {
    return 'Joined $x';
  }

  @override
  String get keywordFilterDescription =>
      'Filtruje wpisy zawierające jakiekolwiek słowa klucze w tytule lub treści wpisu';

  @override
  String get keywordFilters => 'Filtry Słów Kluczy';

  @override
  String get label => 'Label';

  @override
  String get language => 'Język';

  @override
  String get languageFilters => 'Looking for language filters?';

  @override
  String get languageNotAllowed =>
      'Społeczność w której tworzysz wpis nie pozwala na wpisy w wybranym języku. Wybierz inny język.';

  @override
  String get large => 'Duże';

  @override
  String get leftLongSwipe => 'Lewe Długie Przesunięcie';

  @override
  String get leftShortSwipe => 'Lewe Krótkie Przesunięcie';

  @override
  String get light => 'Jasny';

  @override
  String link(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Linki',
      one: 'Link',
      zero: 'Linków',
    );
    return '$_temp0 ';
  }

  @override
  String get linkActions => 'Akcje Linków';

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
  String get linkPostsUseCompactView => 'Show Compact Link Posts';

  @override
  String get linksBehaviourSettings => 'Linki';

  @override
  String loadMorePlural(Object count) {
    return 'Wczytaj $count odpowiedzi więcej…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Wczytaj $count odpowiedź więcej…';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get local => 'Lokalne';

  @override
  String get localNotifications => 'Local Notifications';

  @override
  String get localOnly => 'Local Only';

  @override
  String get localPosts => 'Lokalne Wpisy';

  @override
  String get lockPost => 'Lock Post';

  @override
  String get locked => 'Locked';

  @override
  String get lockedPost => 'Locked Post';

  @override
  String get logOut => 'Wyloguj';

  @override
  String get login => 'Zaloguj się';

  @override
  String get loginAttemptCanceled => 'Login attempt canceled.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Logowanie nie powiodło się, spróbuj ponownie ($errorMessage)';
  }

  @override
  String get loginSucceeded => 'Zalogowano.';

  @override
  String get loginToPerformAction =>
      'Musisz być zalogowany aby wykonać tę czynność.';

  @override
  String get loginToSeeInbox => 'Zaloguj się aby zobaczyć swoją skrzynkę';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Looking for account-specific feed settings?';

  @override
  String get malformedUri =>
      'Format załączonego linku nie jest wspierany. Upewnij się, że to działający link.';

  @override
  String get manageAccounts => 'Zarządzaj Kontami';

  @override
  String get manageMedia => 'Manage Media';

  @override
  String get markAllAsRead => 'Oznacz Wszystkie Jako Przeczytane';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get markPostAsReadOnMediaView =>
      'Oznacz Jako Przeczytane Po Wyświetleniu Treści Multimedialnej';

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
  String get medium => 'Średnie';

  @override
  String mention(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wzmianki',
      one: 'Wzmianka',
      zero: 'Wzmianek',
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
      other: 'Wiadomości',
      one: 'Wiadomość',
      zero: 'Wiadomości',
    );
    return '$_temp0';
  }

  @override
  String get metadataFontScale => 'Metadane Sklaowania Czcionek';

  @override
  String get missingErrorMessage => 'Brak komunikatu o błędzie';

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
  String get moderatedCommunities => 'Moderowane Społeczności';

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
  String get mostComments => 'Najwięcej Komentarzy';

  @override
  String get mustBeLoggedIn => 'You need to be logged in';

  @override
  String get mustBeLoggedInComment =>
      'Musisz być zalogowany, aby napisać komentarz';

  @override
  String get mustBeLoggedInPost => 'Musisz być zalogowany, aby utworzyć post';

  @override
  String get names => 'Names';

  @override
  String get navbarDoubleTapGestures => 'Navbar Double Tap Gestures';

  @override
  String get navbarSwipeGestures => 'Navbar Swipe Gestures';

  @override
  String get navigateDown => 'Przejdź do następnego komentarza';

  @override
  String get navigateUp => 'Poprzedni komentarz';

  @override
  String get navigation => 'Nawigacja';

  @override
  String get nestedCommentIndicatorColor => 'Nested Comment Indicator Color';

  @override
  String get nestedCommentIndicatorStyle => 'Nested Comment Indicator Style';

  @override
  String get never => 'Never';

  @override
  String get newComments => 'Nowy Komentarz';

  @override
  String get newPost => 'Nowy Wpis';

  @override
  String get new_ => 'Nowy';

  @override
  String get no => 'No';

  @override
  String get noAccountsAdded => 'No accounts have been added';

  @override
  String get noAnonymousInstances => 'No anonymous instances have been added';

  @override
  String get noCommentsFound => 'Nie znaleziono komentarzy.';

  @override
  String get noCommunitiesFound => 'Nie znaleziono społeczności.';

  @override
  String get noCommunityBlocks =>
      'It looks like you have not blocked any communities.';

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
  String get noFavoritedCommunities => 'Brak ulubionych społeczności';

  @override
  String get noImages => 'It looks like you have not uploaded any images.';

  @override
  String get noInstanceBlocks => 'Brak zablokowanych instancji.';

  @override
  String get noItems => 'No items';

  @override
  String get noKeywordFilters => 'Nie dodano filtra słów kluczy';

  @override
  String get noLanguage => 'Brak języka';

  @override
  String get noMatrixUserSet => 'No matrix user set';

  @override
  String get noMentions => 'No mentions';

  @override
  String get noMessages => 'No messages';

  @override
  String get noPostsFound => 'Nie znaleziono wpisów';

  @override
  String get noProfileBioSet => 'No profile bio set';

  @override
  String get noReferencesToImage =>
      'No posts or comments were found containing this image. However, it may be used elsewhere on the internet.';

  @override
  String get noReplies => 'No replies';

  @override
  String get noResultsFound => 'Brak wyników wyszukiwania.';

  @override
  String get noSubscriptions => 'Brak Subskrybcji';

  @override
  String get noUserBlocks => 'It looks like you have not blocked anybody.';

  @override
  String get noUserLabels => 'You have not created any user labels yet';

  @override
  String get noUsersFound => 'Nie znaleziono użytkowników.';

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
    return '$instance wydaje się nie być odpowiednią instancją Lemmy';
  }

  @override
  String get notValidUrl => 'Nieodpowiedni URL';

  @override
  String get nothingToShare => 'Brak rzeczy do udostępnienia';

  @override
  String notifications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Powiadomienia',
      one: 'Powiadomienie',
      zero: 'Powiadomień',
    );
    return '$_temp0';
  }

  @override
  String get notificationsBehaviourSettings => 'Powiadomienia';

  @override
  String get notificationsNotAllowed =>
      'Powiadomienia nie są dozwolone dla Thunder w ustawieniach systemowych';

  @override
  String get notificationsWarningDialog =>
      'Notifications are an **experimental feature** which may not function correctly on all devices.\n\n - Checks will occur every ~15 minutes and will consume additional battery.\n\n - Disable battery optimizations for a higher likelihood of successful notifications.\n\n See the following page for more information.';

  @override
  String get nsfw => 'NSFW';

  @override
  String get nsfwWarning => 'NSFW - Tap to reveal';

  @override
  String get off => 'wyłącz';

  @override
  String get offline => 'offline';

  @override
  String get ok => 'OK';

  @override
  String get old => 'Stare';

  @override
  String get on => 'włącz';

  @override
  String get onWifi => 'On Wifi';

  @override
  String get onlyModsCanPostInCommunity =>
      'Tylko moderatorzy mogą tworzyć wpisy w tej społeczności';

  @override
  String get open => 'Otwórz';

  @override
  String get openAccountSwitcher => 'Otwórz zmieniacz kont';

  @override
  String get openByDefault => 'Otwórz domyślnie';

  @override
  String get openInBrowser => 'Otwór w Przeglądarce';

  @override
  String get openInstance => 'Otwórz instancję';

  @override
  String get openLinksInExternalBrowser =>
      'Otwór Linki w Zewnętrznej Przeglądarce';

  @override
  String get openLinksInReaderMode => 'Otwór Linki w Trybie Czytnika';

  @override
  String get openSettings => 'Otwórz Ustawienia';

  @override
  String get orange => 'Orange';

  @override
  String get originalPoster => 'Original Poster';

  @override
  String get overview => 'Przegląd';

  @override
  String get password => 'Hasło';

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
  String get piefedSupportBeta =>
      'PieFed support is currently in beta.\nNot all features are supported yet.';

  @override
  String get pinPostToCommunity => 'Pin Post to Community';

  @override
  String get pinToCommunity => 'Pin to Community';

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
  String get postBehaviourSettings => 'Wpis';

  @override
  String get postBody => 'Treść Wpisu';

  @override
  String get postBodySettings => 'Ustawienia Treści Wpisu';

  @override
  String get postBodySettingsDescription =>
      'Te ustawienia mają wpływ na wyświetlanie treści wpisu';

  @override
  String get postBodyShowCommunityInstance => 'Show Community Instance';

  @override
  String get postBodyShowUserInstance => 'Show User Instance';

  @override
  String get postBodyViewType => 'Typ Widoku Treści Wpisu';

  @override
  String get postContentFontScale => 'Skala Czcionki Treści Wpisu';

  @override
  String get postCreatedSuccessfully => 'Utworzono wpis!';

  @override
  String get postFlairs => 'Flairs';

  @override
  String get postFlairsUnavailable =>
      'No flair options available for this community';

  @override
  String get postLocked => 'Wpis zablokowany. Nie można odpowiedzieć.';

  @override
  String get postMetadataInstructions =>
      'You can customize the metadata information by dragging and dropping the desired information';

  @override
  String get postNSFW => 'Zaznacz jako NSFW';

  @override
  String get postPreview => 'Pokaż podgląd wpisu z wybranymi ustawieniami';

  @override
  String get postSavedAsDraft => 'Wpis zapisany jako wersja robocza';

  @override
  String get postShowUserInstance => 'Show User Instance';

  @override
  String get postSwipeActions => 'Post Swipe Actions';

  @override
  String get postSwipeGesturesHint =>
      'Wolisz używać przycisków? Zmień jakie przyciski będą widoczne na karcie wpisu w ustawieniach generalnych.';

  @override
  String get postTags => 'Tags';

  @override
  String get postTagsHelperText => 'Separate tags with commas';

  @override
  String get postTitle => 'Tytuł';

  @override
  String get postTitleFontScale => 'Skala Czcionki Tytułu Wpisu';

  @override
  String get postTogglePreview => 'Przełącz Podgląd';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Wystąpił błąd podczas przesyłania obrazu';

  @override
  String get postViewType => 'Typ Widoku Wpisu';

  @override
  String get posts => 'Posts';

  @override
  String get preview => 'Podgląd';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile zaaplikowano z powodzeniem!';
  }

  @override
  String get profileBio => 'Profile Bio';

  @override
  String get profileOperationInProgress => 'Profile operation in progress';

  @override
  String get profiles => 'Profile';

  @override
  String get public => 'Public';

  @override
  String get pureBlack => 'Całkiem Czarny';

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
  String get reachedTheBottom => 'Hmmm. Wygląda na to, że dotarłeś na sam dół.';

  @override
  String get read => 'Read';

  @override
  String get readAll => 'Przeczytaj Wszystkie';

  @override
  String get readerMode => 'Reader mode';

  @override
  String get reason => 'Reason';

  @override
  String get red => 'Red';

  @override
  String get reduceAnimations => 'Zredukuj Animacje';

  @override
  String get reducesAnimations => 'Zredukuj ilość animacji używanych w Thunder';

  @override
  String get refresh => 'Odśwież';

  @override
  String get refreshContent => 'Odśwież Zawartość';

  @override
  String get removalReason => 'Removal Reason';

  @override
  String get remove => 'Usuń';

  @override
  String get removeAccount => 'Usuń Konto';

  @override
  String get removeAsCommunityModerator => 'Remove as Community Moderator';

  @override
  String get removeComment => 'Remove Comment';

  @override
  String get removeFromFavorites => 'Usuń z ulubionych';

  @override
  String get removeInstance => 'Usuń Instancję';

  @override
  String removeKeyword(Object keyword) {
    return 'Usunąć \"$keyword\"?';
  }

  @override
  String get removeKeywordFilter => 'Usuń Słowa Klucze';

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
  String get removedCommunityFromSubscriptions =>
      'Usunięto społeczność z subskrypcji';

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
      other: 'Odpowiedzi',
      one: 'Odpowiedź',
      zero: 'Odpowiedzi',
    );
    return '$_temp0';
  }

  @override
  String get replyColor => 'Reply Color';

  @override
  String get replyNotSupported =>
      'Odpowiadanie z poziomu tego widoku nie jest jeszcze obsługiwane';

  @override
  String get replyToComment => 'Reply to Comment';

  @override
  String get replyToPost => 'Odpowiedz na Post';

  @override
  String replyingTo(Object author) {
    return 'Odpowiedź do $author';
  }

  @override
  String report(num count) {
    return 'Zgłoś';
  }

  @override
  String get reportComment => 'Zgłoś Komentarz';

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
  String get reset => 'Zresetuj';

  @override
  String get resetCommentPreferences => 'Zresetuj preferncje komentarzy';

  @override
  String get resetPostPreferences => 'Zresetuj preferncje wpisów';

  @override
  String get resetPreferences => 'Zresetuj Preferencje';

  @override
  String get resetPreferencesAndData => 'Zresetuj Preferencje i Dane';

  @override
  String get restore => 'Przywróć';

  @override
  String get restoreComment => 'Restore Comment';

  @override
  String get restorePost => 'Restore Post';

  @override
  String get restoredComment => 'Restored comment';

  @override
  String get restoredCommentFromDraft => 'Przywróć komentarz z wersji roboczej';

  @override
  String get restoredCommunity => 'Restored Community';

  @override
  String get restoredPost => 'Restored Post';

  @override
  String get restoredPostFromDraft => 'Przywrócono wpis z wersji roboczej';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get rightLongSwipe => 'Prawe Długie Przesunięcie';

  @override
  String get rightShortSwipe => 'Prawe Krótkie Przesunięcie';

  @override
  String get save => 'Zapisz';

  @override
  String get saveColor => 'Save Color';

  @override
  String get saveSettings => 'Zapisz ustawienia';

  @override
  String get saved => 'Zapisano';

  @override
  String get scaled => 'Skalowane';

  @override
  String get scrapeMissingLinkPreviews => 'Scrape Missing Link Previews';

  @override
  String get screenReaderProfile => 'Profil Czytnika Ekranowego';

  @override
  String get screenReaderProfileDescription =>
      'Optimizes Thunder for Screen Readers by reducing overall elements and removing potentially conflicting gestures.';

  @override
  String get search => 'Wyszukaj';

  @override
  String get searchByText => 'Wyszukaj po tekście';

  @override
  String get searchByUrl => 'Wyszukaj po URL';

  @override
  String get searchComments => 'Wyszukaj Komentarzy';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return 'Wyszukaj komentarzy w federacji z $instance';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return 'Wyszukaj społeczności w federacji z $instance';
  }

  @override
  String searchInstance(Object instance) {
    return 'Szukaj $instance';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return 'Search for instances federated with $instance';
  }

  @override
  String get searchPostSearchType => 'Wybierz Typ Szukania Wpisu';

  @override
  String searchPostsFederatedWith(Object instance) {
    return 'Wyszukaj wpisów w federacji z $instance';
  }

  @override
  String get searchTerm => 'Wyszukaj określenia';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Wyszukaj użytkowników w federacji z $instance';
  }

  @override
  String get selectAccountToCommentAs => 'Select account to comment as';

  @override
  String get selectAccountToPostAs => 'Select account to post as';

  @override
  String get selectAll => 'Select all';

  @override
  String get selectCommunity => 'Wybierz społeczność';

  @override
  String get selectFeedType => 'Select Feed Type';

  @override
  String get selectLanguage => 'Wybierz język';

  @override
  String get selectRecipient => 'Select recipient';

  @override
  String get selectSearchType => 'Wybierz Typ Wyszukiwania';

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
    return 'Napotkano na błąd serwera podczas pobierania większej ilości komentarzy: $message';
  }

  @override
  String get setAction => 'Ustaw Akcję';

  @override
  String get setLongPress => 'Ustaw jako akcja przytrzymania';

  @override
  String get setShortPress => 'Ustaw jako akcja naciśnięcia';

  @override
  String get settingOverrideLabel =>
      'These settings override Thunder\'s default settings.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'Ustawienia typu $settingType nie są jeszcze wspierane.';
  }

  @override
  String get settings => 'Ustawienia';

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
  String get share => 'Udostępnij';

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
  String get shareLink => 'Udostępnij Link';

  @override
  String get shareMedia => 'Udostępnij Media';

  @override
  String get shareMediaLink => 'Share Media Link';

  @override
  String get shareOriginalLink => 'Share Original Link';

  @override
  String get sharePost => 'Udostępnij Wpis';

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
  String get showAll => 'Pokaż Wszystkie';

  @override
  String get showBotAccounts => 'Pokaż Konta Botów';

  @override
  String get showCommentActionButtons => 'Pokaż Przyciski Akcji Komentarzy';

  @override
  String get showCommunityDisplayNames => 'Show Community Display Names';

  @override
  String get showCrossPosts => 'Show Cross Posts';

  @override
  String get showEdgeToEdgeImages => 'Pokaż Obrazy od Krawędzi do Krawędzi';

  @override
  String get showExpandedTaglines => 'Show expanded taglines';

  @override
  String get showFullDate => 'Show Full Date';

  @override
  String get showFullDateDescription => 'Show full date on posts';

  @override
  String get showFullHeightImages => 'Pokaż Pełnowymiarowe Obrazy';

  @override
  String get showHiddenPosts => 'Show Hidden Posts';

  @override
  String get showInAppUpdateNotifications =>
      'Zostań Powiadomiony o nowej wersji na GitHub\'ie';

  @override
  String get showLess => 'Pokaż mniej';

  @override
  String get showMore => 'Pokaż więcej';

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
  String get showPassword => 'Pokaż Hasło';

  @override
  String get showPostAuthor => 'Pokaż Autora Wpisu';

  @override
  String get showPostAuthorSubtitle =>
      'Post author is always shown in community feeds';

  @override
  String get showPostCommunityFirst => 'Show Community and Author First';

  @override
  String get showPostCommunityIcons => 'Pokaż Ikonki Społeczności';

  @override
  String get showPostSaveAction => 'Pokaż Przycisk Zapisu';

  @override
  String get showPostTextContentPreview => 'Pokaż Podgląd Tekstu';

  @override
  String get showPostTitleFirst => 'Najpierw Pokaż Tytuł';

  @override
  String get showPostVoteActions => 'Pokaż Przyciski Do Głosowania';

  @override
  String get showReadPosts => 'Pokaż Przeczytane Wpisy';

  @override
  String get showSavedContent => 'Show saved content';

  @override
  String get showScoreCounters => 'Pokaż Punkty Użytkowników';

  @override
  String get showScores => 'Pokaż Punkty Wpisów/Komentarzy';

  @override
  String get showTextPostIndicator => 'Show Text Post Indicator';

  @override
  String get showThumbnailPreviewOnRight =>
      'Pokaż Miniaturki po Prawej stronie';

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
  String get showUserDisplayNames => 'Pokaż Wyświetlane Nazwy Użytkownika';

  @override
  String get showUserInstance => 'Pokaż Interfejs Użytkownika';

  @override
  String get sidebar => 'Pasek boczny';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Dwukrotnie naciśnij dolny pasek nawigacji by otworzyć menu boczne';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Przeciągnij dolny pasek nawigacji by otworzyć menu boczne';

  @override
  String get small => 'Mały';

  @override
  String get somethingWentWrong => 'Ups, coś poszło nie tak!';

  @override
  String get sortBy => 'Sortuj Według';

  @override
  String get sortByTop => 'Sortuj po Najlepszych';

  @override
  String get sortOptions => 'Opcje Sortowania';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get standard => 'Standard';

  @override
  String get stats => 'Stats';

  @override
  String get status => 'Status';

  @override
  String get submit => 'Wstaw';

  @override
  String get subscribe => 'Subskrybuj';

  @override
  String get subscribeToCommunity => 'Zasubskrybuj Społeczność';

  @override
  String get subscribed => 'Subskrybowany';

  @override
  String get subscriptionRequestSent => 'Subscription request sent';

  @override
  String get subscriptions => 'Subskrybcje';

  @override
  String successfullyBannedUser(Object username) {
    return 'Banned $username';
  }

  @override
  String get successfullyBlocked => 'Zablokowano.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return 'Pomyślnie zablokowano $communityName';
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
  String get successfullyUnblocked => 'Odblokowano.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return 'Odblokowano $communityName';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return 'Unblocked $username';
  }

  @override
  String get suchAs => 'such as';

  @override
  String get suggestedTitle => 'Sugerowany tytuł';

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
  String get tabletMode => 'Tryb Tabletu (Widok 2-kolumnowy)';

  @override
  String get tapToExit => 'Kliknij \'wstecz\' podwójnie aby wyjść';

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
  String get text => 'Tekst';

  @override
  String get textActions => 'Text Actions';

  @override
  String get theme => 'Motyw';

  @override
  String get themeAccentColor => 'Akcenty Kolorystyczne';

  @override
  String get themePrimary => 'Theme Primary';

  @override
  String get themeSecondary => 'Theme Secondary';

  @override
  String get themeTertiary => 'Theme Tertiary';

  @override
  String get theming => 'Motyw';

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
      'Błąd: Przekroczono limit czasu oczekiwania podczas próby pobierania komentarzy';

  @override
  String get timeoutErrorMessage =>
      'Przekroczono limit czasu oczekiwania na odpowiedź.';

  @override
  String get timeoutSaveComment =>
      'Błąd: Przekroczono limit czasu oczekiwania podczas próby zapisania komentarza';

  @override
  String get timeoutSavingPost =>
      'Błąd: Przekroczono limit czasu oczekiwania podczas próby zapisania wpisu.';

  @override
  String get timeoutUpvoteComment =>
      'Błąd: Przekroczono limit czasu oczekiwania podczas próby oceny komentarza';

  @override
  String get timeoutVotingPost =>
      'Błąd: Przekroczono limit czasu oczekiwania podczas próby oceny wpisu.';

  @override
  String get toggelRead => 'Przełącz Odczytanie';

  @override
  String get top => 'Najlepsze';

  @override
  String get topAll => 'Najlepsze wszechczasów';

  @override
  String get topDay => 'Najlepsze Dziś';

  @override
  String get topHour => 'Najlepsze z Ostaniej Godziny';

  @override
  String get topMonth => 'Najlepsze Miesiąca';

  @override
  String get topNineMonths => 'Najlepsze w Ostatnich 9 Miesiącach';

  @override
  String get topSixHour => 'Najlepsze Ostatnich 6 Godzin';

  @override
  String get topSixMonths => 'Najlepsze w Ostatnich 6 Miesiącach';

  @override
  String get topThreeMonths => 'Najlepsze w Ostatnich 3 Miesiącach';

  @override
  String get topTwelveHour => 'Najlepsze Ostatnich 12 Godzin';

  @override
  String get topWeek => 'Najlepsze Tygodnia';

  @override
  String get topYear => 'Najlepsze Roku';

  @override
  String totalComments(Object x) {
    return '$x Comments';
  }

  @override
  String totalPosts(Object x) {
    return '$x Posts';
  }

  @override
  String get totp => 'TOTP (opcjonalne)';

  @override
  String get transferredModToCommunity => 'Transferred Community';

  @override
  String get translationsMayNotBeComplete =>
      'Pamiętaj, że tłumaczenia mogą być niekompletne';

  @override
  String get trendingCommunities => 'Społeczności Na Czasie';

  @override
  String get trySearchingFor => 'Spróbuj wyszukać...';

  @override
  String get unableToFindCommunity => 'Nie udało się odnaleźć społeczności';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'Nie można odnaleźć społeczności \'$communityName\'';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Unable to find the selected community on the selected user\'s instance.';

  @override
  String get unableToFindInstance => 'Nie można odnaleźć instancji';

  @override
  String get unableToFindLanguage => 'Nie można odnaleźć języka';

  @override
  String get unableToFindPost => 'Unable to find post';

  @override
  String get unableToFindUser => 'Nie udało się odnaleźć użytkownika';

  @override
  String unableToFindUserName(Object username) {
    return 'Unable to find user \'$username\'';
  }

  @override
  String get unableToLoadImage => 'Nie można załadować obrazu';

  @override
  String unableToLoadImageFrom(Object domain) {
    return 'Nie można załadować obrazu z $domain';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return 'Nie udało się załadować $instance';
  }

  @override
  String get unableToLoadPost => 'Unable to load post';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return 'Nie udało się załadować wpisów z $instance';
  }

  @override
  String get unableToLoadReplies =>
      'Nie udało się załadować więcej odpowiedzi.';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return 'Nie można przejść do $instanceHost. Możliwe, że nie jest on właściwą instancją Lemmy.';
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
  String get unblockInstance => 'Odblokuj Instancję';

  @override
  String get unblockUser => 'Unblock User';

  @override
  String get unblockUserInstance => 'Unblock User Instance';

  @override
  String get understandEnable => 'Rozumiem, Włącz';

  @override
  String get unexpectedError => 'Wystąpił niespodziewany błąd';

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
  String get unsubscribe => 'Odsubskrybuj';

  @override
  String get unsubscribeFromCommunity => 'Odsubskrybuj Społeczność';

  @override
  String get unsubscribePending => 'Odsubskrybuj (subskrypcja w toku)';

  @override
  String get unsubscribed => 'Odsubskrybowano';

  @override
  String get untitledCommentDraft => 'Untitled comment draft';

  @override
  String get untitledPostDraft => 'Untitled post draft';

  @override
  String updateReleased(Object version) {
    return 'Aktualizacja dostępna: $version';
  }

  @override
  String get uploadImage => 'Prześlij obraz';

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
  String get uriNotSupported => 'Ten typ linku nie jest obecnie wspierany.';

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
  String get useCompactView => 'Włącz dla małych wpisów, wyłącz dla wielkich.';

  @override
  String get useLocalNotifications => 'Use Local Notifications (Experimental)';

  @override
  String get useLocalNotificationsDescription =>
      'Periodically checks for notifications in the background';

  @override
  String get useMaterialYouTheme => 'Użyj Motywu Material You';

  @override
  String get useMaterialYouThemeDescription => 'Nadpisuje wybrany motyw';

  @override
  String get useProfilePictureForDrawer => 'Use Profile Picture for Drawer';

  @override
  String get useProfilePictureForDrawerSubtitle =>
      'When logged in, shows the user\'s profile picture in place of the drawer icon';

  @override
  String useSuggestedTitle(Object title) {
    return 'Użyj sugerowanego tytułu: $title';
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
  String get userNotLoggedIn => 'Użytkownik niezalogowany';

  @override
  String get userProfiles => 'Profile Użytkowników';

  @override
  String get userSettingDescription =>
      'These settings sync with your Lemmy account and are only applied on a per-account basis.';

  @override
  String get userStyle => 'User Style';

  @override
  String get username => 'Nazwa';

  @override
  String get usernameFormattingRedirect => 'Looking for username formatting?';

  @override
  String get users => 'Użytkownicy';

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
  String get viewAllComments => 'Wyświetl wszystkie komentarze';

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
  String get visitCommunity => 'Odwiedź Społeczność';

  @override
  String get visitCommunityInstance => 'Visit Community Instance';

  @override
  String get visitInstance => 'Odwiedź Instancję';

  @override
  String get visitUserInstance => 'Visit User Instance';

  @override
  String get visitUserProfile => 'Odwiedź Profil Użytkownika';

  @override
  String get warning => 'Ostrzeżenie';

  @override
  String xDownvotes(Object x) {
    return '$x downvotes';
  }

  @override
  String xScore(Object x) {
    return '$x punkty';
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
