// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get about => 'Über';

  @override
  String get accept => 'Annehmen';

  @override
  String get accessibility => 'Bedienungshilfen';

  @override
  String get accessibilityProfilesDescription =>
      'Profile für Bedienungshilfen ermöglichen es, mehrere Einstellungen auf einmal zu übernehmen, um den bestimmten Anforderungen eines Nutzers gerecht zu werden.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Konten',
      one: 'Konto',
      zero: 'Konto',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'Kontogeburtstag $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'Die Einstellungen deines Kontos überschreiben die folgenden Einstellungen';

  @override
  String get accountSettings => 'Kontoeinstellungen';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'Lemmy Accounteinstellungen erfolgreich nach $savedFilePath exportiert!';
  }

  @override
  String get accountSettingsImportedSuccessfully =>
      'Lemmy Accounteinstellungen erfolgreich importiert!';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return 'Der ausgewählte Kommentar wurde nicht auf \'$instance\'gefunden. Wechsle zu vorherigem Konto.';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'Der gewählte Post wurde nicht auf \'$instance\'gefunden. Wechsle zurück auf vorheriges Konto.';
  }

  @override
  String get actionColors => 'Aktionsfarben';

  @override
  String get actionColorsRedirect => 'Auf der Suche nach eigenen Farbe?';

  @override
  String get actions => 'Aktionen';

  @override
  String get active => 'Aktiv';

  @override
  String get activity => 'Activity';

  @override
  String get add => 'Hinzufügen';

  @override
  String get addAccount => 'Konto hinzufügen';

  @override
  String get addAccountToSeeProfile =>
      'Bitte zum Betrachten des Profils einloggen.';

  @override
  String get addAnonymousInstance => 'Anonyme Instanz hinzufügen';

  @override
  String get addAsCommunityModerator => 'Hinzufügen als Community Moderator';

  @override
  String get addDiscussionLanguage => 'Sprache hinzufügen';

  @override
  String get addKeywordFilter => 'Schlüsselwort hinzufügen';

  @override
  String get addOriginalPostBody => 'Add original post body?';

  @override
  String get addToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get addUserLabel => 'Benutzerlabel hinzufügen';

  @override
  String get addedCommunityToSubscriptions => 'Community abonniert';

  @override
  String get addedInstanceMod => 'Instanz Moderator hinzufügen';

  @override
  String get addedModToCommunity => 'Füge Moderator zur Community hinzu';

  @override
  String get admin => 'Administrator';

  @override
  String get advanced => 'Erweitert';

  @override
  String ago(Object time) {
    return 'vor $time';
  }

  @override
  String get all => 'Alle';

  @override
  String get allPosts => 'Alle Posts';

  @override
  String get allowOpenSupportedLinks =>
      'Erlaube Thunder, unterstütze Links zu öffnen.';

  @override
  String get alreadyPostedTo => 'Bereits gepostet auf';

  @override
  String get altText => 'Alternativtext';

  @override
  String get alternateSources => 'Alternative Quellen';

  @override
  String get always => 'Immer';

  @override
  String andXMore(Object count) {
    return 'und $count mehr';
  }

  @override
  String get animations => 'Animationen';

  @override
  String get anonymous => 'Anonym';

  @override
  String get anonymousInstances => 'Anonyme Instanzen';

  @override
  String get appLanguage => 'App-Sprache';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get applePushNotificationService =>
      'Apple Push Benachrichtigungsservice';

  @override
  String get applied => 'Übernommen';

  @override
  String get apply => 'Übernehmen';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return 'Benachrichtigungen vom System erlaubt: $yesOrNo';
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
  String get back => 'Zurück';

  @override
  String get backButton => 'Zurück-Button';

  @override
  String get backToTop => 'Zurück nach oben';

  @override
  String get backgroundCheckWarning =>
      'Beachte das Benachrichtigungsprüfungen zusätzlich Strom verbrauchen';

  @override
  String get banFromCommunity => 'Von Community geblockt';

  @override
  String get bannedUser => 'Geblockte Benutzer';

  @override
  String get bannedUserFromCommunity => 'Von Community geblockte User';

  @override
  String get base => 'Standard';

  @override
  String get block => 'Block';

  @override
  String get blockCommunity => 'Community blockieren';

  @override
  String get blockCommunityInstance => 'Blockierte Community Instanz';

  @override
  String get blockInstance => 'Instanz blockieren';

  @override
  String get blockManagement => 'Sperrmanagement';

  @override
  String get blockSettingLabel => 'Benutzer/Community/Instanz Blocks';

  @override
  String get blockUser => 'Benutzer blockieren';

  @override
  String get blockUserInstance => 'Blockiere Benutzer Instanz';

  @override
  String get blockedCommunities => 'Blockierte Communitys';

  @override
  String get blockedInstances => 'Blockierte Instanzen';

  @override
  String get blockedUsers => 'Blockierte Nutzer';

  @override
  String get blue => 'Blau';

  @override
  String get bold => 'Fett';

  @override
  String get boldCommunityName => 'Fettgedruckter Name der Community';

  @override
  String get boldInstanceName => 'Fettgedruckter Name der Instanz';

  @override
  String get boldUserName => 'Fettgedruckter Name des Benutzers';

  @override
  String get bot => 'Bot';

  @override
  String get browserMode => 'Link Behandlung';

  @override
  String browsingAnonymously(Object instance) {
    return 'Du bist anonym auf $instance.';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get cannotReportOwnComment =>
      'Du kannst nicht deinen eigenen Kommentar melden.';

  @override
  String get cantBlockAdmin =>
      'Du kannst den Administrator der Instanz blockieren.';

  @override
  String get cantBlockYourself => 'Du kannst dich nicht selbst blockieren.';

  @override
  String get cardPostCardMetadataItems => 'Metadaten Kartenansicht';

  @override
  String get cardView => 'Kartenansicht';

  @override
  String get cardViewDescription =>
      'Kartenansicht aktivieren um Einstellungen anzupassen';

  @override
  String get cardViewSettings => 'Einstellungen für Kartenansicht';

  @override
  String get changeAccountSettingsFor => 'Ändere Konto Einstellungen für';

  @override
  String get changeNotificationSettings =>
      'Ändere Benachrichtigungseinstellungen...';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get changePasswordWarning =>
      'Um die dein Passwort zu ändern, wirst du auf die Seite deiner Instanz weitergeleitet. \n\nBis du dir sicher, das du weitermachen möchtest?';

  @override
  String get changeSort => 'Sortierung ändern';

  @override
  String clearCache(Object cacheSize) {
    return 'Cache leeren ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Cache leeren';

  @override
  String get clearDatabase => 'Datenbank zurücksetzen';

  @override
  String get clearPreferences => 'Einstellungen zurücksetzen';

  @override
  String get clearSearch => 'Suchverlauf löschen';

  @override
  String get clearedCache => 'Cache erfolgreich geleert.';

  @override
  String get clearedDatabase =>
      'Lokale Datenbank zurückgesetzt. Thunder bitte neu starten.';

  @override
  String get clearedUserPreferences => 'Einstellungen zurückgesetzt';

  @override
  String get close => 'Schließen';

  @override
  String get collapse => 'Einklappen';

  @override
  String get collapseCommentPreview => 'Kommentarvorschau einklappen';

  @override
  String get collapseInformation => 'Informationen einklappen';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Verstecke übergeordneten Kommentar, wenn eingeklappt';

  @override
  String get collapsePost => 'Post einklappen';

  @override
  String get collapsePostPreview => 'Postvorschau einklappen';

  @override
  String get collapseSpoiler => 'Klappe Spoiler zusammen';

  @override
  String get color => 'Farbe';

  @override
  String get colorizeCommunityName => 'Färbe Community Namen';

  @override
  String get colorizeInstanceName => 'Färbe Instanz Namen';

  @override
  String get colorizeUserName => 'Färbe Benutzer Namen';

  @override
  String get colors => 'Farben';

  @override
  String get combineCommentScores => 'Kombiniere Kommentar Ergebnisse';

  @override
  String get combineCommentScoresLabel => 'Kommentarbewertungen kombinieren';

  @override
  String get combineNavAndFab =>
      'Kombinieren Sie FAB und Navigationsschaltflächen';

  @override
  String get combineNavAndFabDescription =>
      'Schwebender Aktionsbutton wird zwischen den Navigationsbuttons angezeigt.';

  @override
  String get comfortable => 'Komfortabel';

  @override
  String get comment => 'Kommentieren';

  @override
  String get commentBehaviourSettings => 'Kommentare';

  @override
  String get commentFontScale => 'Kommentar Inhaltsschriftgröße';

  @override
  String get commentPreview =>
      'Zeige eine Kommentarvorschau mit den gewählten Einstellungen';

  @override
  String get commentReported => 'Der Kommentar wurde gemeldet.';

  @override
  String get commentSavedAsDraft => 'Kommentar als Entwurf gespeichert';

  @override
  String get commentShowUserAvatar => 'Benutzeravatar anzeigen';

  @override
  String get commentShowUserInstance => 'Instanz des Nutzers anzeigen';

  @override
  String get commentSortType => 'Kommentarsortierung';

  @override
  String get commentSwipeActions => 'Kommentar Wisch Aktionen';

  @override
  String get commentSwipeGesturesHint =>
      'Lieber Buttons benutzen? Schalte sie im Abschnitt \"Kommentare\" in den allgemeinen Einstellungen ein.';

  @override
  String get comments => 'Kommentare';

  @override
  String get communities => 'Communitys';

  @override
  String get community => 'Community';

  @override
  String get communityActions => 'Community Aktionen';

  @override
  String communityEntry(Object community) {
    return 'Community \'$community\'';
  }

  @override
  String get communityFormat => 'Formatierung Communityname';

  @override
  String get communityNameColor => 'Namensfarbe Community';

  @override
  String get communityNameThickness => 'Community Namensschriftstärke';

  @override
  String get communityStyle => 'Community Stil';

  @override
  String get compact => 'Kompakt';

  @override
  String get compactPostCardMetadataItems => 'Kompakte Ansicht Metadaten';

  @override
  String get compactView => 'Kompaktansicht';

  @override
  String get compactViewDescription =>
      'Kompaktansicht aktivieren um Einstellungen anzupassen';

  @override
  String get compactViewSettings => 'Einstellungen für die Kompaktansicht';

  @override
  String get condensed => 'Verdichtet';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get confirmLogOutBody => 'Willst du dich wirklich ausloggen?';

  @override
  String get confirmLogOutTitle => 'Ausloggen?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Bist du sicher, dass du alle Nachrichten als gelesen markieren willst?';

  @override
  String get confirmMarkAllAsReadTitle => 'Alles als gelesen markieren?';

  @override
  String get confirmResetCommentPreferences =>
      'Dies wird alle Kommentareinstellungen zurücksetzen. Bist du sicher, dass du fortfahren möchtest?';

  @override
  String get confirmResetPostPreferences =>
      'Dies wird alle Post Einstellungen zurücksetzen. Bist du sicher, dass du fortfahren möchtest?';

  @override
  String get confirmUnsubscription =>
      'Bist du dir sicher, das du dich abmelden möchtest?';

  @override
  String connectedToUnifiedPushDistributorApp(Object app) {
    return 'Verbunden mit $app';
  }

  @override
  String get contentManagement => 'Inhaltsmanagement';

  @override
  String get contentWarning => 'Inhaltswarnung';

  @override
  String get controversial => 'Kontrovers';

  @override
  String get copiedToClipboard => 'In Zwischenablage kopiert';

  @override
  String get copy => 'Kopieren';

  @override
  String get copyComment => 'Kommentar kopieren';

  @override
  String get copySelected => 'Auswahl kopieren';

  @override
  String get copyText => 'Text kopieren';

  @override
  String get couldNotDetermineCommentDelete =>
      'Fehler: Konnte Kommentar nicht löschen (Post nicht bestimmbar).';

  @override
  String get couldNotDeterminePostComment =>
      'Fehler: Kommentar nicht gespeichert (Post nicht bestimmbar).';

  @override
  String get couldntCreateReport =>
      'Deine Meldung konnte nicht abgesendet werden. Bitte versuche es später wieder';

  @override
  String get couldntFindPost =>
      'Der angeforderte Post kann nicht geladen werden. Er wurde möglicherweise gelöscht oder entfernt.';

  @override
  String countComments(Object count) {
    return '$count Kommentare';
  }

  @override
  String countLocalSubscribers(Object count) {
    return '$count Lokale Abonnenten';
  }

  @override
  String countPosts(Object count) {
    return '$count Posts';
  }

  @override
  String countSubscribers(Object count) {
    return '$count Abonnenten';
  }

  @override
  String countUsers(Object count) {
    return '$count Benutzer';
  }

  @override
  String countUsersActiveDay(Object count) {
    return '$count Benutzer/Tag';
  }

  @override
  String countUsersActiveHalfYear(Object count) {
    return '$count Benutzer/6 Mo';
  }

  @override
  String countUsersActiveMonth(Object count) {
    return '$count Benutzer/Mo';
  }

  @override
  String countUsersActiveWeek(Object count) {
    return '$count Benutzer/Wo';
  }

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get createComment => 'Kommentar erstellen';

  @override
  String get createNewCrossPost => 'Neuen Crosspost erstellen';

  @override
  String get createPost => 'Post erstellen';

  @override
  String created(Object date) {
    return 'Erstellt $date';
  }

  @override
  String get createdToday => 'Heute erstellt';

  @override
  String get creator => 'Autor';

  @override
  String crossPostedFrom(Object postUrl) {
    return 'Mehrfach veröffentlicht von:  $postUrl';
  }

  @override
  String get crossPostedTo => 'Crossgeposted auf';

  @override
  String get currentLongPress => 'Momentan auf langes Drücken eingestellt';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Aktueller Benachrichtigungsmodus: $mode';
  }

  @override
  String get currentSinglePress => 'Momentan auf kurzes Drücken eingestellt';

  @override
  String get customizeSwipeActions =>
      'Wischgesten bearbeiten (zum Ändern antippen)';

  @override
  String get dangerZone => 'Gefahrenzone';

  @override
  String get dark => 'Dunkel';

  @override
  String get databaseExportWarning =>
      'Die Datenbank kann sensible Informationen über dein Lemmy-Konto enthalten. Wenn du sie exportierst, solltest du sie nicht an Dritte weitergeben. Möchtest du fortfahren?';

  @override
  String databaseExportedSuccessfully(Object savedFilePath) {
    return 'Die Datenbank wurde erfolgreich exportiert nach \'$savedFilePath\'';
  }

  @override
  String get databaseImportedSuccessfully =>
      'Die Datenbank wurde erfolgreich importiert!';

  @override
  String get databaseNotExportedSuccessfully =>
      'Die Datenbank wurde nicht erfolgreich exportiert oder der Vorgang wurde abgebrochen.';

  @override
  String get databaseNotImportedSuccessfully =>
      'Die Datenbank wurde nicht erfolgreich importiert, oder der Vorgang wurde abgebrochen.';

  @override
  String get dateFormat => 'Datumsformat';

  @override
  String get debug => 'Debuggen';

  @override
  String get debugDescription =>
      'Die folgenden Debug-Einstellungen sollten nur zur Problemermittlung eingesetzt werden.';

  @override
  String get debugNotificationsDescription =>
      'Verwende die folgenden Optionen, um Probleme im Zusammenhang mit Benachrichtigungen zu beheben.';

  @override
  String get decline => 'Ablehnen';

  @override
  String get defaultColor => 'Voreinstellung';

  @override
  String get defaultCommentSortType => 'Kommentar Sortierung';

  @override
  String get defaultFeedSortType => 'Feed Sortierung';

  @override
  String get defaultFeedType => 'Feed Typ';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountDescription =>
      'Um dein Konto endgültig zu löschen, wirst du zu deiner Instanzseite weitergeleitet. \n\nBist du sicher, dass du fortfahren möchtest?';

  @override
  String get deleteComment => 'Kommentar löschen';

  @override
  String get deleteImageConfirmMessage =>
      'Sind Sie sicher, dass Sie dieses Bild löschen möchten?';

  @override
  String get deleteImageConfirmTitle => 'Löschen?';

  @override
  String get deleteLocalDatabase => 'Lokale Datenbank zurücksetzen';

  @override
  String get deleteLocalDatabaseDescription =>
      'Dies wird die lokale Datenbank löschen und dich aus allen Accounts ausloggen.\n\nBist du sicher, dass du fortfahren möchtest?';

  @override
  String get deleteLocalPreferences => 'Lokale Einstellungen löschen';

  @override
  String get deleteLocalPreferencesDescription =>
      'Dies wird alle deine Benutzereinstellungen und Einstellungen in Thunder löschen.\n\nBist du sicher, dass du fortfahren möchtest?';

  @override
  String get deletePost => 'Lösche Post';

  @override
  String get deleteUserLabelConfirmation =>
      'Bist du sicher, dass du die Bezeichnung löschen möchtest?';

  @override
  String get deleted => 'Gelöscht';

  @override
  String get deletedByCreator => 'vom Ersteller entfernt';

  @override
  String get deletedByModerator => 'vom Moderator gelöscht';

  @override
  String get deselectUndeterminedWarning =>
      'Wenn du die Option Undetermined deaktivierst, wirst du viele Inhalte nicht sehen.';

  @override
  String detailedReason(Object reason) {
    return 'Grund: $reason';
  }

  @override
  String get dimReadPosts => 'Gelesene Posts werden ausgegraut';

  @override
  String get disable => 'Deaktivieren';

  @override
  String get disablePushNotifications => 'Push-Benachrichtigungen deaktivieren';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String get discussionLanguages => 'Diskussion Sprachen';

  @override
  String get discussionLanguagesTooltip =>
      'Der Inhalt wird nach den ausgewählten Sprachen gefiltert.';

  @override
  String get dismissRead => 'Gelesene verwerfen';

  @override
  String get displayName => 'Name anzeigen';

  @override
  String get displayUserScore => 'Nutzerpunktzahl anzeigen (\"Karma\").';

  @override
  String get dividerAppearance => 'Trenner Erscheinungsbild';

  @override
  String get doNotShowAgain => 'Nicht mehr anzeigen';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Mehrere kompatible Apps gefunden; bitte nur eine installieren';

  @override
  String get downloadingMedia => 'Lade Medien zum Teilen herunter…';

  @override
  String get downvote => 'Herunterwählen';

  @override
  String get downvoteColor => 'Downvote Farbe';

  @override
  String get downvoted => 'Heruntergewertet';

  @override
  String get downvotesDisabled =>
      'Herunterwählen ist auf dieser Instanz deaktiviert.';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get editComment => 'Kommentar bearbeiten';

  @override
  String get editPost => 'Post bearbeiten';

  @override
  String get email => 'E-Mail';

  @override
  String get empty => 'Leer';

  @override
  String get emptyInbox => 'Posteingang ist leer';

  @override
  String get emptyUri =>
      'Der Link ist leer. Bitte zum Fortsetzen einen gültigen, dynamischen Link eingeben.';

  @override
  String get enableCommentNavigation => 'Aktivieren der Kommentar-Navigation';

  @override
  String get enableExperimentalFeatures =>
      'Aktiviere experimentelle Funktionen';

  @override
  String get enableFeedFab => 'Schwebenden Button auf Feeds aktivieren';

  @override
  String get enableFloatingButtonOnFeeds =>
      'Schwebenden Button auf Feeds aktivieren';

  @override
  String get enableFloatingButtonOnPosts =>
      'Aktiviere schwebenden Button auf Posts';

  @override
  String get enableInboxNotifications =>
      'Posteingang-Benachrichtigungen aktivieren';

  @override
  String get enablePostFab => 'Schwebenden Button auf Posts aktivieren';

  @override
  String get endOfComments => 'Ende der Kommentare';

  @override
  String get endSearch => 'Suche beenden';

  @override
  String errorDeletingImage(Object error) {
    return 'Dort war ein Fehler beim Löschen des Bildes: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Konnte Medien nicht herunterladen: $errorMessage';
  }

  @override
  String get errorImportingAccountSettings =>
      'Beim Importieren der Einstellungen ist ein Fehler aufgetreten. Die Datei hat vieleicht nicht das richtige Format.';

  @override
  String get errorInitializingClient => 'Error initializing client';

  @override
  String get errorLoadingAccountSettings =>
      'Beim Laden der Einstellungsdatei ist ein Fehler aufgetreten oder der Vorgang wurde abgebrochen.';

  @override
  String get errorMarkingReplyRead =>
      'Es gab einen Fehler bei der Markierung der Antwort als gelesen.';

  @override
  String get errorMarkingReplyUnread =>
      'Es gab einen Fehler bei der Markierung der Antwort als ungelesen.';

  @override
  String get errorNoActiveInstance => 'No active instance found';

  @override
  String get errorParsingJson =>
      'Beim Parsen der ausgewählten Datei ist ein Fehler aufgetreten. Es handelt sich möglicherweise nicht um gültiges JSON.';

  @override
  String get errorSavingAccountSettings =>
      'Beim Speichern der Einstellungsdatei ist ein Fehler aufgetreten oder der Vorgang wurde abgebrochen.';

  @override
  String get exceptionProcessingUri =>
      'Bei der Verarbeitung des Links ist ein Fehler aufgetreten. Möglicherweise ist er auf deiner Instanz nicht verfügbar.';

  @override
  String get excessiveApiCallsWarning =>
      'Es kann sein, dass Ihr Feed aufgrund von Filtern für Suchbegriffe eine Weile zum Laden braucht.';

  @override
  String get expand => 'Erweitern';

  @override
  String get expandCommentPreview => 'Kommentarvorschau ausklappen';

  @override
  String get expandInformation => 'Informationen erweitern';

  @override
  String get expandOptions => 'Optionen erweitern';

  @override
  String get expandPost => 'Post erweitern';

  @override
  String get expandPostPreview => 'Postvorschau erweitern';

  @override
  String get expandSpoiler => 'Spoiler ausklappen';

  @override
  String get expanded => 'Ausgeklappt';

  @override
  String get experimentalFeatures => 'Experimentelle Funktionen';

  @override
  String get experimentalFeaturesDescription =>
      'Diese Funktionen befinden sich noch in der Entwicklung und können instabil sein. Die Verwendung erfolgt auf eigene Gefahr. Du musst Thunder neu starten, damit sie wirksam werden.';

  @override
  String get exploreInstance => 'Instanz erkunden';

  @override
  String get exportDatabase => 'Exportiere Datenbank';

  @override
  String get exportDatabaseSubtitle =>
      'Die Datenbank enthält Informationen über Konten, Favoriten, anonyme Abonnements und Kennzeichnungen von Benutzern.';

  @override
  String get exportLemmyAccountSettingsDescription =>
      'Lemmy-Kontoeinstellungen exportieren';

  @override
  String get exportSettingsSubtitle =>
      'Die Einstellungen enthalten alle Präferenzen, die du konfiguriert hast.';

  @override
  String get extraLarge => 'Extra Groß';

  @override
  String failedToBlock(Object errorMessage) {
    return 'Blockieren fehlgeschlagen: $errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return 'Kommunikation mit dem Thunder-Benachrichtigungsserver unter \'$serverAddress\' fehlgeschlagen';
  }

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return 'Konnte Blockierungen nicht laden: $errorMessage';
  }

  @override
  String get failedToLoadVideo =>
      'Das Video konnte nicht geladen werden. Link im Browser öffnen?';

  @override
  String get failedToPerformAction => 'Aktion konnte nicht ausgeführt werden';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'Entblocken fehlgeschlagen: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Benachrichtigungseinstellungen konnten nicht aktualisiert werden';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Favoriten';

  @override
  String get featuredPost => 'Besonderer Post';

  @override
  String get feed => 'Feed';

  @override
  String get feedBehaviourSettings => 'Feed';

  @override
  String get feedSettings => 'Feed Einstellungen';

  @override
  String get feedTypeAndSorts => 'Standard Feed-Art und -sortierung';

  @override
  String get fetchAccountError => 'Konnte Konto nicht abrufen';

  @override
  String filteringBy(Object entity) {
    return 'Filtere nach $entity';
  }

  @override
  String get filters => 'Filter';

  @override
  String get floatingActionButton => 'Schwebender Button';

  @override
  String get floatingActionButtonInformation =>
      'Thunder bietet ein vollständig anpassbares FAB- Element, das ein paar Gesten unterstützt.\n- Wische nach oben, um zusätzliche FAB-Aktionen anzuzeigen\n- Wische nach unten/oben, um den FAB ein- oder auszublenden\n\nUm die Haupt- und Nebenaktionen für den FAB anzupassen, drücke lange auf eine der Aktionen.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'bezeichnet den langen Druck des FAB.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'bezeichnet die Funktion des FAB auf einmaliges Drücken.';

  @override
  String get fonts => 'Schriftarten';

  @override
  String get forward => 'Weiterleitung';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Kompatible Anwendung gefunden; Thunder neu starten, um eine Verbindung herzustellen';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Wische irgendwohin, um zurückzugehen, wenn die Links-nach-Rechts-Gesten deaktiviert sind';

  @override
  String get fullscreenSwipeGestures => 'Wischgesten im Vollbildmodus';

  @override
  String get general => 'Allgemein';

  @override
  String get generalSettings => 'Allgemeine Einstellungen';

  @override
  String get gestures => 'Gesten';

  @override
  String get gettingStarted => 'Erste Schritte';

  @override
  String get green => 'Grün';

  @override
  String get guestModeFeedSettings => 'Einstellungen für den Gastmodus';

  @override
  String get guestModeFeedSettingsLabel =>
      'Die folgenden Einstellungen gelten nur für Gastkonten. Um die Feed-Einstellungen für dein Konto anzupassen, gehen zu Kontoeinstellungen.';

  @override
  String get havingIssuesWithNotifications =>
      'Hast du Probleme mit Benachrichtigungen?';

  @override
  String get hidCommunity => 'Verstecke Community';

  @override
  String get hidden => 'Versteckt';

  @override
  String get hide => 'Verstecke';

  @override
  String get hideColor => 'Farbe verstecken';

  @override
  String get hideNsfwPostsFromFeed => 'Verstecke NSFW Posts im Feed';

  @override
  String get hideNsfwPreviews => 'Verwische NSFW Vorschau';

  @override
  String get hidePassword => 'Passwort verbergen';

  @override
  String get hideThumbnails => 'Thumbnails ausblenden';

  @override
  String get hideTopBarOnScroll => 'Obere Leiste beim Scrollen ausblenden';

  @override
  String get hostInstance => 'Host Instanz';

  @override
  String get hot => 'Hot';

  @override
  String get image => 'Bild';

  @override
  String get imageCachingMode => 'Bildcaching-Modus';

  @override
  String get imageCachingModeAggressive =>
      'Aggressives Zwischenspeichern von Bildern (verbraucht mehr Speicher)';

  @override
  String get imageCachingModeAggressiveShort => 'Aggressiv';

  @override
  String get imageCachingModeRelaxed =>
      'Bild-Caches ablaufen lassen (verbraucht weniger Speicher, führt aber dazu, dass Bilder häufiger neu geladen werden)';

  @override
  String get imageCachingModeRelaxedShort => 'Entspannt';

  @override
  String get imageDimensionTimeout => 'Zeitüberschreitung Bild Abmessungen';

  @override
  String get importDatabase => 'Datenbank importieren';

  @override
  String get importExportDatabase =>
      'Thunder-Datenbank importieren/exportieren';

  @override
  String get importExportLemmyAccountSettings =>
      'Lemmy-Kontoeinstellungen importieren/exportieren';

  @override
  String get importExportLemmyAccountSettingsSubtitle =>
      'Beinhaltet abonnierte Communities, Sperrlisten und Kontoeinstellungen';

  @override
  String get importExportSettings => 'Import/Export Einstellungen';

  @override
  String get importExportThunderSettings =>
      'Thunder-Einstellungen importieren/exportieren';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Lemmy-Kontoeinstellungen importieren';

  @override
  String get importSettings => 'Einstellungen importieren';

  @override
  String inReplyTo(Object community, Object post) {
    return 'Als Antwort auf $post in $community';
  }

  @override
  String get in_ => 'von';

  @override
  String get inbox => 'Posteingang';

  @override
  String get includeCommunity => 'Community einbeziehen';

  @override
  String get includeExternalLink => 'Externen Link einfügen';

  @override
  String get includeImage => 'Bild einfügen';

  @override
  String get includePostLink => 'Post-Link einschließen';

  @override
  String get includeText => 'Text einfügen';

  @override
  String get includeTitle => 'Titel einfügen';

  @override
  String get information => 'Informationen';

  @override
  String instance(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Instanzen',
      one: 'Instanz',
      zero: 'Instanz',
    );
    return '$_temp0 ';
  }

  @override
  String get instanceActions => 'Instanz Aktionen';

  @override
  String instanceEntry(Object username) {
    return 'Instanz \'$username\'';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance wurde bereits hinzugefügt.';
  }

  @override
  String get instanceNameColor => 'Instanzname Farbe';

  @override
  String get instanceNameThickness => 'Instanz Name Stärke';

  @override
  String get instances => 'Instanzen';

  @override
  String get internetOrInstanceIssues =>
      'Möglicherweise bist du nicht mit dem Internet verbunden, oder deine Instanz ist derzeit nicht verfügbar.';

  @override
  String get invalidUrl => 'Invalid URL format';

  @override
  String joined(Object x) {
    return 'Joined $x';
  }

  @override
  String get keywordFilterDescription =>
      'Filtert Posts, die Schlüsselwörter im Titel, im Text oder in der URL enthalten';

  @override
  String get keywordFilters => 'Stichwort Filter';

  @override
  String get label => 'Bezeichnung';

  @override
  String get language => 'Sprache';

  @override
  String get languageFilters => 'Du suchst nach Sprachfiltern?';

  @override
  String get languageNotAllowed =>
      'Die Community, in der du den Post verfasst, erlaubt keine Posts in der von dir gewählten Sprache. Versuche eine andere Sprache.';

  @override
  String get large => 'Groß';

  @override
  String get leftLongSwipe => 'Langes Wischen nach links';

  @override
  String get leftShortSwipe => 'Kurzes Wischen nach Links';

  @override
  String get light => 'Hell';

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
  String get linkActions => 'Link Aktionen';

  @override
  String get linkHandlingCustomTabs =>
      'Öffnen im Systembrowser, eingebettet in die App';

  @override
  String get linkHandlingCustomTabsShort => 'Eingebettet in die App';

  @override
  String get linkHandlingExternal => 'Im Systembrowser extern öffnen';

  @override
  String get linkHandlingExternalShort => 'Extern';

  @override
  String get linkHandlingInApp =>
      'Verwende den integrierten Browser von Thunder';

  @override
  String get linkHandlingInAppShort => 'In-App';

  @override
  String get linksBehaviourSettings => 'Links';

  @override
  String loadMorePlural(Object count) {
    return 'Lade $count weitere Antworten…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Lade $count weitere Antworten…';
  }

  @override
  String get loading => 'Laden...';

  @override
  String get local => 'Loakl';

  @override
  String get localNotifications => 'Lokale Benachrichtigungen';

  @override
  String get localOnly => 'Nur lokal';

  @override
  String get localPosts => 'Lokale Posts';

  @override
  String get lockPost => 'Sperre Post';

  @override
  String get locked => 'Gesperrt';

  @override
  String get lockedPost => 'Gesperrter Post';

  @override
  String get logOut => 'Ausloggen';

  @override
  String get login => 'Einloggen';

  @override
  String get loginAttemptCanceled => 'Anmeldeversuch abgebrochen.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Konnte nicht eingeloggt werden. Bitte versuche es erneut. (Fehler: $errorMessage)';
  }

  @override
  String get loginSucceeded => 'Eingeloggt.';

  @override
  String get loginToPerformAction =>
      'Um diese Aktion ausführen zu können, musst du eingeloggt sein.';

  @override
  String get loginToSeeInbox => 'Anmelden, um den Posteingang zu sehen';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Suchst du nach kontospezifischen Feed-Einstellungen?';

  @override
  String get malformedUri =>
      'Der von dir angegebene Link hat ein nicht unterstütztes Format. Bitte stelle sicher, dass es sich um ein gültigen Link handelt.';

  @override
  String get manageAccounts => 'Konten verwalten';

  @override
  String get manageMedia => 'Medien verwalten';

  @override
  String get markAllAsRead => 'Alles als gelesen markieren';

  @override
  String get markAsRead => 'Als gelesen markieren';

  @override
  String get markPostAsReadOnMediaView =>
      'Nach dem Betrachten von Medien als gelesen markieren';

  @override
  String get markPostAsReadOnScroll => 'Beim Scrollen als gelesen markieren';

  @override
  String get markReadColor => 'Gelesen/Ungelesen Farbe';

  @override
  String get matrixUser => 'Matrix Benutzer';

  @override
  String get me => 'Ich';

  @override
  String get medium => 'Mittel';

  @override
  String mention(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Erwähnungen',
      one: 'Erwähnung',
      zero: 'Erwähnung',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'Menü';

  @override
  String message(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nachrichten',
      one: 'Nachricht',
      zero: 'Nachricht',
    );
    return '$_temp0';
  }

  @override
  String get metadataFontScale => 'Metadaten Schriftgröße';

  @override
  String get missingErrorMessage => 'Keine Fehlermeldung vorhanden';

  @override
  String get modAdd => 'Hinzufügen/Entfernen von Instanz-Moderatoren';

  @override
  String get modAddCommunity =>
      'Hinzufügen/Entfernen von Moderatoren zu Communities';

  @override
  String get modBan => 'Instanz-Benutzer sperren/entsperren';

  @override
  String get modBanFromCommunity =>
      'Benutzer von Communities sperren/entsperren';

  @override
  String get modFeaturePost => 'Hervorheben/Anpassen Posts';

  @override
  String get modLockPost => 'Sperre/Entsperre Posts';

  @override
  String get modRemoveComment => 'Kommentare entfernen/wiederherstellen';

  @override
  String get modRemoveCommunity => 'Communities entfernen/wiederherstellen';

  @override
  String get modRemovePost => 'Posts entfernen/wiederherstellen';

  @override
  String get modTransferCommunity => 'Communities übertragen';

  @override
  String get moderatedCommunities => 'Moderierte Communities';

  @override
  String get moderates => 'Moderates';

  @override
  String moderator(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moderatoren',
      one: 'Moderator',
      zero: 'Moderator',
    );
    return '$_temp0';
  }

  @override
  String get moderatorActions => 'Moderator Aktionen';

  @override
  String get modlog => 'Modlog';

  @override
  String get mostComments => 'Meiste Kommentare';

  @override
  String get mustBeLoggedIn => 'Du musst eingeloggt sein';

  @override
  String get mustBeLoggedInComment =>
      'Du musst eingeloggt sein, um zu kommentieren';

  @override
  String get mustBeLoggedInPost =>
      'Du musst eingeloggt sein, um einen Post zu erstellen';

  @override
  String get names => 'Namen';

  @override
  String get navbarDoubleTapGestures => 'Navbar-Doppeltippgesten';

  @override
  String get navbarSwipeGestures => 'Navbar-Wischgesten';

  @override
  String get navigateDown => 'Nächster Kommentar';

  @override
  String get navigateUp => 'Vorheriger Kommentar';

  @override
  String get navigation => 'Navigation';

  @override
  String get nestedCommentIndicatorColor =>
      'Farbe für verschachtelte Kommentare';

  @override
  String get nestedCommentIndicatorStyle =>
      'Verschachtelter Kommentar Indikatorstil';

  @override
  String get never => 'Niemals';

  @override
  String get newComments => 'Neue Kommentare';

  @override
  String get newPost => 'Neuer Post';

  @override
  String get new_ => 'Neu';

  @override
  String get no => 'Nein';

  @override
  String get noAccountsAdded => 'Es wurden keine Konten hinzugefügt';

  @override
  String get noAnonymousInstances =>
      'Es wurden keine anonymen Instanzen hinzugefügt';

  @override
  String get noCommentsFound => 'Keine Kommentare gefunden';

  @override
  String get noCommunitiesFound => 'Keine Communities gefunden';

  @override
  String get noCommunityBlocks => 'Keine gesperrten Communities';

  @override
  String get noCompatibleAppFound => 'Keine kompatible App gefunden';

  @override
  String get noDiscussionLanguages =>
      'Kein Inhalt wurde versteckt, basierend auf der Sprache';

  @override
  String get noDisplayNameSet => 'Kein Anzeigename festgelegt';

  @override
  String get noEmailSet => 'Keine E-Mail eingerichtet';

  @override
  String get noFavoritedCommunities => 'Keine bevorzugten Communities';

  @override
  String get noImages =>
      'Es sieht so aus, als hätten Sie keine Bilder hochgeladen.';

  @override
  String get noInstanceBlocks => 'Keine blockierten Instanzen.';

  @override
  String get noItems => 'Keine Einträge';

  @override
  String get noKeywordFilters => 'Keine Stichwortfilter hinzugefügt';

  @override
  String get noLanguage => 'Keine Sprache';

  @override
  String get noMatrixUserSet => 'Kein Matrix-Benutzer eingestellt';

  @override
  String get noMentions => 'Keine Erwähnungen';

  @override
  String get noMessages => 'Keine Nachrichten';

  @override
  String get noPostsFound => 'Keine Posts gefunden.';

  @override
  String get noProfileBioSet => 'Keine Profilbeschreibung eingestellt';

  @override
  String get noReferencesToImage =>
      'Es wurden keine Beiträge oder Kommentare mit diesem Bild gefunden. Es kann jedoch an anderer Stelle im Internet verwendet werden.';

  @override
  String get noReplies => 'Keine Antworten';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden.';

  @override
  String get noSubscriptions => 'Keine Abonnements';

  @override
  String get noUserBlocks => 'Keine gesperrten Benutzer.';

  @override
  String get noUserLabels =>
      'Sie haben noch keine Benutzerkennzeichnungen erstellt';

  @override
  String get noUsersFound => 'Keine Benutzer gefunden.';

  @override
  String get noVisibleComments =>
      'Comments may not be visible because the community is blocked.';

  @override
  String get none => 'Keine';

  @override
  String get normal => 'Normal';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance scheint keine gültige Lemmy-Instanz zu sein';
  }

  @override
  String get notValidUrl => 'Ungültiger URL';

  @override
  String get nothingToShare => 'Es gibt nichts zu teilen';

  @override
  String notifications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Benachrichtigungen',
      one: 'Benachrichtigung',
      zero: 'Benachrichtigung',
    );
    return '$_temp0';
  }

  @override
  String get notificationsBehaviourSettings => 'Benachrichtigungen';

  @override
  String get notificationsNotAllowed =>
      'Benachrichtigungen sind für Thunder in den Systemeinstellungen nicht erlaubt';

  @override
  String get notificationsWarningDialog =>
      'Benachrichtigungen sind eine **experimentelle Funktion**, die möglicherweise nicht auf allen Geräten korrekt funktioniert.\n\n - Die Überprüfungen erfolgen alle ~15 Minuten und verbrauchen zusätzlichen Akku.\n\n - Deaktivieren Sie die Akku-Optimierung, um eine höhere Wahrscheinlichkeit für erfolgreiche Benachrichtigungen zu erreichen.\n\n Weitere Informationen finden Sie auf der folgenden Seite.';

  @override
  String get nsfw => 'NSFW';

  @override
  String get nsfwWarning => 'NSFW - Zum Anzeigen antippen';

  @override
  String get off => 'aus';

  @override
  String get offline => 'offline';

  @override
  String get ok => 'OK';

  @override
  String get old => 'Alt';

  @override
  String get on => 'an';

  @override
  String get onWifi => 'Mit WLAN';

  @override
  String get onlyModsCanPostInCommunity =>
      'Nur Moderatoren dürfen in dieser Community Post verfassen';

  @override
  String get open => 'Offen';

  @override
  String get openAccountSwitcher => 'Kontowechsler öffnen';

  @override
  String get openByDefault => 'Standardmäßig geöffnet';

  @override
  String get openInBrowser => 'Im Browser öffnen';

  @override
  String get openInstance => 'Instanz öffnen';

  @override
  String get openLinksInExternalBrowser => 'Links in externem Browser öffnen';

  @override
  String get openLinksInReaderMode => 'Links im Lesemodus öffnen';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get orange => 'Orange';

  @override
  String get originalPoster => 'Original Ersteller';

  @override
  String get overview => 'Übersicht';

  @override
  String get password => 'Passwort';

  @override
  String get pending => 'Ausstehend';

  @override
  String performedBy(Object user) {
    return 'Performed by: $user';
  }

  @override
  String get permissionDenied =>
      'Thunder hat nicht die Berechtigung, Benachrichtigungen anzuzeigen. Bitte aktiviere dies in den Systemeinstellungen.';

  @override
  String get permissionDeniedMessage =>
      'Thunder benötigt einige Berechtigungen, um dieses Bild zu speichern, die verweigert wurden.';

  @override
  String get pinPostToCommunity => 'Post an Community anheften';

  @override
  String get pinToCommunity => 'Pin an Community';

  @override
  String get pinned => 'Angeheftet';

  @override
  String get placeholderText =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  @override
  String get post => 'Post';

  @override
  String get postActions => 'Post Aktionen';

  @override
  String get postBehaviourSettings => 'Posts';

  @override
  String get postBody => 'Post Body';

  @override
  String get postBodySettings => 'Post Body Einstellungen';

  @override
  String get postBodySettingsDescription =>
      'Diese Einstellungen wirken sich auf die Anzeige des Post Texts aus';

  @override
  String get postBodyShowCommunityInstance => 'Community-Instanz anzeigen';

  @override
  String get postBodyShowUserInstance => 'Benutzer-Instanz anzeigen';

  @override
  String get postBodyViewType => 'Post Body Ansicht Typ';

  @override
  String get postContentFontScale => 'Post-Inhalt Schriftgröße';

  @override
  String get postCreatedSuccessfully => 'Post erfolgreich erstellt!';

  @override
  String get postLocked => 'Post gesperrt. Keine Antworten erlaubt.';

  @override
  String get postMetadataInstructions =>
      'Du kannst die Metadaten durch Ziehen und Ablegen der gewünschten Informationen anpassen';

  @override
  String get postNSFW => 'Als NSFW markieren';

  @override
  String get postPreview =>
      'Eine Vorschau des Posts mit den angegebenen Einstellungen anzeigen';

  @override
  String get postSavedAsDraft => 'Post als Entwurf gespeichert';

  @override
  String get postShowUserInstance => 'Benutzer-Instanz anzeigen';

  @override
  String get postSwipeActions => 'Post-Swipe-Aktionen';

  @override
  String get postSwipeGesturesHint =>
      'Möchtest du stattdessen Buttons verwenden? Ändere in den allgemeinen Einstellungen, welche Buttons auf den Karten erscheinen.';

  @override
  String get postTitle => 'Titel';

  @override
  String get postTitleFontScale => 'Posttitel Schriftgröße';

  @override
  String get postTogglePreview => 'Umschalten der Vorschau';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Bild kann nicht hochgeladen werden';

  @override
  String get postViewType => 'Post-Ansicht Typ';

  @override
  String get posts => 'Posts';

  @override
  String get preview => 'Vorschau';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile erfolgreich angewandt!';
  }

  @override
  String get profileBio => 'Profil Beschreibung';

  @override
  String get profiles => 'Profile';

  @override
  String get public => 'Öffentlich';

  @override
  String get pureBlack => 'Reines Schwarz';

  @override
  String get purgedComment => 'Gelöschter Kommentar';

  @override
  String get purgedCommunity => 'Gelöschte Community';

  @override
  String get purgedPerson => 'Gelöschte Person';

  @override
  String get purgedPost => 'Gelöschter Post';

  @override
  String get purple => 'Lila';

  @override
  String get pushNotification => 'Push-Benachrichtigungen';

  @override
  String get pushNotificationDescription =>
      'Wenn aktiviert, sendet Thunder deine(n) JWT-Token an den Server, um neue Benachrichtigungen abzufragen. \n\n **Hinweis:** Dies wird erst beim nächsten Start der App wirksam.';

  @override
  String get pushNotificationServer => 'Server für Push-Benachrichtigungen';

  @override
  String get pushNotificationServerDescription =>
      'Konfiguriere den Push-Benachrichtigungsserver. Der Server muss richtig konfiguriert sein, um Push-Benachrichtigungen an dein Gerät zu senden.\n\n **Gib nur einen Server ein, dem du mit deinen Anmeldedaten vertraust.**';

  @override
  String get rateLimitErrorMessage =>
      'Sie haben das Ratenlimit für diese Anfrage erreicht. Bitte warten Sie und versuchen Sie es später erneut.';

  @override
  String get reachedTheBottom => 'Es sind keine weiteren Artikel zu laden';

  @override
  String get read => 'Gelesen';

  @override
  String get readAll => 'Alles gelesen';

  @override
  String get readerMode => 'Lesemodus';

  @override
  String get reason => 'Grund';

  @override
  String get red => 'Rot';

  @override
  String get reduceAnimations => 'Animationen verringern';

  @override
  String get reducesAnimations =>
      'Verringert die in Thunder verwendeten Animationen';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get refreshContent => 'Inhalt aktualisieren';

  @override
  String get removalReason => 'Entfernungsgrund';

  @override
  String get remove => 'Entfernen';

  @override
  String get removeAccount => 'Konto löschen';

  @override
  String get removeAsCommunityModerator => 'Als Community-Moderator entfernen';

  @override
  String get removeComment => 'Kommentar entfernen';

  @override
  String get removeFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get removeInstance => 'Instanz entfernen';

  @override
  String removeKeyword(Object keyword) {
    return 'Entferne \"$keyword\"?';
  }

  @override
  String get removeKeywordFilter => 'Stichwort entfernen';

  @override
  String get removePost => 'Post löschen';

  @override
  String get removed => 'Entfernt';

  @override
  String get removedComment => 'Gelöschter Kommentar';

  @override
  String get removedCommunity => 'Gelöschte Community';

  @override
  String get removedCommunityFromSubscriptions =>
      'Von der Community abgemeldet';

  @override
  String get removedInstanceMod => 'Entfernte Instanz-Mod';

  @override
  String get removedModFromCommunity => 'Mod aus der Community entfernt';

  @override
  String get removedPost => 'Entfernter Post';

  @override
  String get reorder => 'Neusortieren';

  @override
  String reply(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Antworten',
      one: 'Antwort',
      zero: 'Antwort',
    );
    return '$_temp0';
  }

  @override
  String get replyColor => 'Antwort Farbe';

  @override
  String get replyNotSupported =>
      'Das Antworten aus dieser Ansicht wird derzeit noch nicht unterstützt';

  @override
  String get replyToPost => 'Antwort auf Post';

  @override
  String replyingTo(Object author) {
    return 'Antworte auf $author';
  }

  @override
  String report(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Melden',
      one: 'Melden',
      zero: 'Melden',
    );
    return '$_temp0 ';
  }

  @override
  String get reportComment => 'Melde Kommentar';

  @override
  String get reportPost => 'Post melden';

  @override
  String get reporter => 'Melder:';

  @override
  String get requiredField => '*benötigt';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get resetCommentPreferences => 'Kommentar-Einstellungen zurücksetzen';

  @override
  String get resetPostPreferences => 'Post-Einstellungen zurücksetzen';

  @override
  String get resetPreferences => 'Einstellungen zurücksetzen';

  @override
  String get resetPreferencesAndData => 'Einstellungen und Daten zurücksetzen';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get restoreComment => 'Kommentar wiederherstellen';

  @override
  String get restorePost => 'Post wiederherstellen';

  @override
  String get restoredComment => 'Wiederhergestellter Kommentar';

  @override
  String get restoredCommentFromDraft =>
      'Wiederhergestellter Kommentar vom Entwurf';

  @override
  String get restoredCommunity => 'Wiederhergestellte Community';

  @override
  String get restoredPost => 'Wiederhergestellter Post';

  @override
  String get restoredPostFromDraft => 'Post aus Entwurf wiederhergestellt';

  @override
  String get retry => 'Wiederholen';

  @override
  String get rightLongSwipe => 'Langes Wischen nach rechts';

  @override
  String get rightShortSwipe => 'Kurzer Swipe Rechts';

  @override
  String get save => 'Speichern';

  @override
  String get saveColor => 'Farbe speichern';

  @override
  String get saveSettings => 'Einstellungen speichern';

  @override
  String get saved => 'Gespeichert';

  @override
  String get scaled => 'Skaliert';

  @override
  String get scrapeMissingLinkPreviews => 'Hole Fehlende Link-Vorschauen';

  @override
  String get screenReaderProfile => 'Screen Reader Profil';

  @override
  String get screenReaderProfileDescription =>
      'Optimiert Thunder für Screen Reader, indem es die Gesamtelemente reduziert und potenziell widersprüchliche Gesten entfernt.';

  @override
  String get search => 'Suche';

  @override
  String get searchByText => 'Suche nach Text';

  @override
  String get searchByUrl => 'Suche nach URL';

  @override
  String get searchComments => 'Kommentare suchen';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return 'Suche nach Kommentaren, die mit $instance föderiert sind';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return 'Suche nach Communities, die mit $instance föderiert sind';
  }

  @override
  String searchInstance(Object instance) {
    return 'Suche $instance';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return 'Suche nach Instanzen, die mit $instance föderiert sind';
  }

  @override
  String get searchPostSearchType => 'Post-Suchtyp wählen';

  @override
  String searchPostsFederatedWith(Object instance) {
    return 'Suche nach Posts, die mit $instance föderiert sind';
  }

  @override
  String get searchTerm => 'Suchbegriff';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Suche nach Benutzern, die mit $instance föderiert sind';
  }

  @override
  String get selectAccountToCommentAs =>
      'Wähle das Konto, unter dem du kommentieren willst';

  @override
  String get selectAccountToPostAs =>
      'Wähle das Konto, mit dem geposted werden soll';

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get selectCommunity => 'Wählen Sie eine Community (erforderlich)';

  @override
  String get selectFeedType => 'Feed-Typ auswählen';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get selectSearchType => 'Suchart auswählen';

  @override
  String get selectText => 'Text auswählen';

  @override
  String get sendBackgroundTestLocalNotification =>
      'Lokale Benachrichtigung für Hintergrundtests senden';

  @override
  String get sendBackgroundTestUnifiedPushNotification =>
      'Senden einer UnifiedPush-Benachrichtigung im Hintergrund';

  @override
  String get sendTestLocalNotification => 'Lokale Testbenachrichtigung senden';

  @override
  String get sendTestUnifiedPushNotification =>
      'Test UnifiedPush-Benachrichtigung senden';

  @override
  String get sensitiveContentWarning =>
      'Kann sensible Inhalte enthalten. Zum Anzeigen antippen.';

  @override
  String get sentRequestForTestNotification =>
      'Anfrage für Testbenachrichtigung gesendet.';

  @override
  String serverErrorComments(Object message) {
    return 'Beim Abrufen weiterer Kommentare ist ein Serverfehler aufgetreten: $message';
  }

  @override
  String get setAction => 'Aktion einstellen';

  @override
  String get setLongPress => 'Als Langdruckaktion einstellen';

  @override
  String get setShortPress => 'Als Kurzdruckaktion einstellen';

  @override
  String get settingOverrideLabel =>
      'Diese Einstellungen setzen die Standardeinstellungen von Thunder außer Kraft.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'Einstellungen vom Typ $settingType werden noch nicht unterstützt.';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'Einstellungen wurden erfolgreich in \'$savedFilePath\' gespeichert';
  }

  @override
  String get settingsFeedCards =>
      'Diese Einstellungen gelten für die Karten im Haupt-Feed, Aktionen sind immer verfügbar, wenn Beiträge geöffnet werden.';

  @override
  String get settingsImportedSuccessfully =>
      'Die Einstellungen wurden erfolgreich importiert!';

  @override
  String get settingsNotExportedSuccessfully =>
      'Die Einstellungen wurden nicht gespeichert, oder der Vorgang wurde abgebrochen.';

  @override
  String get settingsNotImportedSuccessfully =>
      'Die Einstellungen wurden nicht importiert oder der Vorgang wurde abgebrochen.';

  @override
  String get settingsPage => 'Einstellungsseite';

  @override
  String get settingsPageAbout => 'Über';

  @override
  String get settingsPageAccessibility => 'Barrierefreiheit';

  @override
  String get settingsPageAccount => 'Konto';

  @override
  String get settingsPageAccountBlocks => 'Blocklists';

  @override
  String get settingsPageAccountLanguages => 'Discussion Languages';

  @override
  String get settingsPageAccountMedia => 'Medien verwalten';

  @override
  String get settingsPageAppearance => 'Darstellung';

  @override
  String get settingsPageAppearanceComments => 'Kommentare';

  @override
  String get settingsPageAppearancePosts => 'Beiträge';

  @override
  String get settingsPageAppearanceTheming => 'Theming';

  @override
  String get settingsPageDebug => 'Debug';

  @override
  String get settingsPageFilters => 'Filter';

  @override
  String get settingsPageFloatingActionButton => 'Floating Action Button';

  @override
  String get settingsPageGeneral => 'Allgemein';

  @override
  String get settingsPageGestures => 'Gesten';

  @override
  String get settingsPageUserLabels => 'User Labels';

  @override
  String get settingsPageVideo => 'Video';

  @override
  String get share => 'Teilen';

  @override
  String get shareComment => 'Kommentar-Link teilen';

  @override
  String get shareCommentLocal => 'Kommentar-Link teilen (Meine Instanz)';

  @override
  String get shareCommunity => 'Community teilen';

  @override
  String get shareCommunityLink => 'Community-Link teilen';

  @override
  String get shareCommunityLinkLocal => 'Community-Link teilen (Meine Instanz)';

  @override
  String get shareImage => 'Bild teilen';

  @override
  String get shareLemmyLink => 'Lemmy-Link teilen';

  @override
  String get shareLink => 'Externen Link teilen';

  @override
  String get shareMedia => 'Medien teilen';

  @override
  String get shareMediaLink => 'Medien-Link teilen';

  @override
  String get shareOriginalLink => 'Original-Link teilen';

  @override
  String get sharePost => 'Post-Link teilen';

  @override
  String get sharePostLocal => 'Post-Link teilen (Meine Instanz)';

  @override
  String get shareThumbnail => 'Thumbnail teilen';

  @override
  String get shareThumbnailAsImage => 'Thumbnail als Bild teilen';

  @override
  String get shareUser => 'Benutzer teilen';

  @override
  String get shareUserLink => 'Benutzer-Link teilen';

  @override
  String get shareUserLinkLocal => 'Benutzer-Link teilen (Meine Instanz)';

  @override
  String get showAll => 'Alle anzeigen';

  @override
  String get showBotAccounts => 'Bot-Konten anzeigen';

  @override
  String get showCommentActionButtons => 'Kommentar-Buttons anzeigen';

  @override
  String get showCommunityDisplayNames => 'Namen der Community anzeigen';

  @override
  String get showCrossPosts => 'Cross Posts anzeigen';

  @override
  String get showEdgeToEdgeImages => 'Bilder von Rand zu Rand anzeigen';

  @override
  String get showExpandedTaglines => 'Erweiterte Schlagworte anzeigen';

  @override
  String get showFullDate => 'Vollständiges Datum anzeigen';

  @override
  String get showFullDateDescription => 'Volles Datum bei Posts anzeigen';

  @override
  String get showFullHeightImages => 'Bilder mit voller Höhe anzeigen';

  @override
  String get showHiddenPosts => 'Versteckte Posts anzeigen';

  @override
  String get showInAppUpdateNotifications =>
      'Über neue GitHub-Releases benachrichtigen lassen';

  @override
  String get showLess => 'Weniger anzeigen';

  @override
  String get showMore => 'Mehr anzeigen';

  @override
  String get showNavigationLabels => 'Navigationsbeschriftung anzeigen';

  @override
  String get showNavigationLabelsDescription =>
      'Legt fest, ob Beschriftungen unter den unteren Buttons angezeigt werden sollen';

  @override
  String get showNsfwContent => 'NSFW Inhalte anzeigen';

  @override
  String get showOwnContent => 'Eigene Inhalte anzeigen';

  @override
  String get showPassword => 'Passwort anzeigen';

  @override
  String get showPostAuthor => 'Autor des Posts anzeigen';

  @override
  String get showPostAuthorSubtitle =>
      'Der Autor eines Posts wird immer in den Community Feeds angezeigt';

  @override
  String get showPostCommunityIcons => 'Community-Symbole anzeigen';

  @override
  String get showPostSaveAction => 'Speichern- Button anzeigen';

  @override
  String get showPostTextContentPreview => 'Textvorschau anzeigen';

  @override
  String get showPostTitleFirst => 'Titel zuerst anzeigen';

  @override
  String get showPostVoteActions => 'Abstimmungsbuttons zeigen';

  @override
  String get showReadPosts => 'Gelesene Posts anzeigen';

  @override
  String get showSavedContent => 'Gespeicherte Inhalte anzeigen';

  @override
  String get showScoreCounters => 'Nutzerbewertungen anzeigen';

  @override
  String get showScores => 'Post/Kommentar-Bewertungen anzeigen';

  @override
  String get showTextPostIndicator => 'Text-Post-Indikator anzeigen';

  @override
  String get showThumbnailPreviewOnRight => 'Thumbnails rechts anzeigen';

  @override
  String get showUnreadOnly => 'Nur ungelesene anzeigen';

  @override
  String get showUpdateChangelogs => 'Changelogs für Updates anzeigen';

  @override
  String get showUpdateChangelogsSubtitle =>
      'Anzeige der Liste der Änderungen nach einer Aktualisierung';

  @override
  String get showUserAvatar => 'Benutzer-Avatar anzeigen';

  @override
  String get showUserDisplayNames => 'Anzeige der Benutzernamen';

  @override
  String get showUserInstance => 'Benutzer-Instanz anzeigen';

  @override
  String get sidebar => 'Seitenleiste';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Doppeltipp auf die untere Navigationsleiste zum Öffnen der Seitenleiste';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Durch Wischen über die untere Navigationsleiste wird die Seitenleiste geöffnet';

  @override
  String get small => 'Klein';

  @override
  String get somethingWentWrong => 'Ups, da ist etwas schiefgegangen!';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get sortByTop => 'Nach Top sortieren';

  @override
  String get sortOptions => 'Sortier-Optionen';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get standard => 'Standard';

  @override
  String get stats => 'Statistiken';

  @override
  String get status => 'Status';

  @override
  String get submit => 'Senden';

  @override
  String get subscribe => 'Abonnieren';

  @override
  String get subscribeToCommunity => 'Community abonnieren';

  @override
  String get subscribed => 'Abonniert';

  @override
  String get subscriptionRequestSent => 'Abonnement-Anfrage gesendet';

  @override
  String get subscriptions => 'Abonnements';

  @override
  String successfullyBannedUser(Object username) {
    return 'Gesperrt $username';
  }

  @override
  String get successfullyBlocked => 'Blockiert.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return 'Blockiert $communityName';
  }

  @override
  String successfullyBlockedUser(Object username) {
    return 'Blockiert $username';
  }

  @override
  String successfullyUnbannedUser(Object username) {
    return 'Entsperrt $username';
  }

  @override
  String get successfullyUnblocked => 'Entsperrt.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return 'Entsperrt $communityName';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return 'Entsperrt $username';
  }

  @override
  String get suchAs => 'wie z.B.';

  @override
  String get suggestedTitle => 'Vorgeschlagener Titel';

  @override
  String switchedAccount(Object username) {
    return 'Switched to $username';
  }

  @override
  String get system => 'System';

  @override
  String get systemDarkMode => 'Reines Schwarz';

  @override
  String get systemDarkModeDescription =>
      'Rein schwarzes Thema für dunklen Modus aktivieren';

  @override
  String get tabletMode => 'Tablet-Modus (2-Spalten-Ansicht)';

  @override
  String get tapToExit => 'Zum Beenden erneut auf Zurück drücken';

  @override
  String get tappableAuthorCommunity => 'Antippbare Autoren & Communitys';

  @override
  String get teal => 'Türkisblau';

  @override
  String get testBackgroundNotificationDescription =>
      'Thunder beendet sich selbst und versucht dann, im Hintergrund eine Benachrichtigung zu erstellen. (Dies dauert mindestens 15 Minuten.)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'Thunder fragt den Benachrichtigungs-Server, eine verzögerte Benachrichtigung zu senden und beendet sich dann selbst. (Das kann einige Minuten dauern.)';

  @override
  String get text => 'Text';

  @override
  String get textActions => 'Text Aktionen';

  @override
  String get theme => 'Thema';

  @override
  String get themeAccentColor => 'Akzent Farben';

  @override
  String get themePrimary => 'Primäre Farbe';

  @override
  String get themeSecondary => 'Sekundäre Farbe';

  @override
  String get themeTertiary => 'Dritte Farbe';

  @override
  String get theming => 'Thema';

  @override
  String get thickness => 'Dicke';

  @override
  String get thisAccount => 'Dieses Konto';

  @override
  String get thumbnailUrl => 'Thumbnail URL';

  @override
  String thunderHasBeenUpdated(Object version) {
    return 'Thunder auf $version aktualisiert!';
  }

  @override
  String thunderNotificationServer(Object server) {
    return 'Thunder Benachrichtigungs Server: $server';
  }

  @override
  String get timeoutComments =>
      'Fehler: Zeitüberschreitung beim Versuch, Kommentare abzurufen';

  @override
  String get timeoutErrorMessage =>
      'Es gab eine Unterbrechung beim Warten auf eine Rückmeldung.';

  @override
  String get timeoutSaveComment =>
      'Fehler: Zeitüberschreitung beim Versuch, einen Kommentar zu speichern';

  @override
  String get timeoutSavingPost =>
      'Fehler: Zeitüberschreitung beim Versuch, den Beitrag zu speichern.';

  @override
  String get timeoutUpvoteComment =>
      'Fehler: Zeitüberschreitung beim Versuch, für einen Kommentar abzustimmen';

  @override
  String get timeoutVotingPost =>
      'Fehler: Zeitüberschreitung beim Versuch, einen Beitrag zu bewerten.';

  @override
  String get toggelRead => 'Lesen umschalten';

  @override
  String get top => 'Top';

  @override
  String get topAll => 'Top aller Zeiten';

  @override
  String get topDay => 'Top Heute';

  @override
  String get topHour => 'Top in der vergangenen Stunde';

  @override
  String get topMonth => 'Top Monat';

  @override
  String get topNineMonths => 'Top der letzten 9 Monate';

  @override
  String get topSixHour => 'Top der letzten 6 Stunden';

  @override
  String get topSixMonths => 'Top der letzten 6 Monate';

  @override
  String get topThreeMonths => 'Top der letzten 3 Monate';

  @override
  String get topTwelveHour => 'Top der letzten 12 Stunden';

  @override
  String get topWeek => 'Top Woche';

  @override
  String get topYear => 'Top Jahr';

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
  String get transferredModToCommunity => 'Übertragene Community';

  @override
  String get translationsMayNotBeComplete =>
      'Bitte beachte, dass Übersetzungen möglicherweise nicht vollständig sind';

  @override
  String get trendingCommunities => 'Trending Communities';

  @override
  String get trySearchingFor => 'Versuche die Suche nach...';

  @override
  String get unableToFindCommunity => 'Community nicht gefunden';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'Community \'$communityName\' wurde nicht gefunden';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Die gewählte Community kann auf der Instanz des Benutzers nicht gefunden werden.';

  @override
  String get unableToFindInstance => 'Instanz nicht auffindbar';

  @override
  String get unableToFindLanguage => 'Sprache nicht gefunden';

  @override
  String get unableToFindPost => 'Post kann nicht gefunden werden';

  @override
  String get unableToFindUser => 'Benutzer nicht gefunden';

  @override
  String unableToFindUserName(Object username) {
    return 'Benutzer \'$username\' nicht gefunden';
  }

  @override
  String get unableToLoadImage => 'Bild konnte nicht geladen werden';

  @override
  String unableToLoadImageFrom(Object domain) {
    return 'Bild konnte nicht von $domain geladen werden';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return 'Kann $instance nicht laden';
  }

  @override
  String get unableToLoadPost => 'Unable to load post';

  @override
  String unableToLoadPostsFrominstance(Object Instance, Object instance) {
    return 'Posts von $instance konnten nicht geladen werden';
  }

  @override
  String get unableToLoadReplies => 'Kann keine weiteren Antworten laden.';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return 'Es ist nicht möglich, zu $instanceHost zu wechseln. Es handelt sich möglicherweise nicht um eine gültige Lemmy-Instanz.';
  }

  @override
  String get unableToResolveReport => 'Meldung kann nicht gelöst werden';

  @override
  String unableToRetrieveChangelog(Object version) {
    return 'Changelog für Version $version kann nicht geladen werden.';
  }

  @override
  String get unbanFromCommunity => 'Community-Sperre aufheben';

  @override
  String get unbannedUser => 'Entsperrter Benutzer';

  @override
  String get unbannedUserFromCommunity =>
      'Entsperrter Benutzer aus der Community';

  @override
  String get unblock => 'Unblock';

  @override
  String get unblockCommunity => 'Community entsperren';

  @override
  String get unblockCommunityInstance => 'Community-Instanz entsperren';

  @override
  String get unblockInstance => 'Instanz entsperren';

  @override
  String get unblockUser => 'Benutzer entsperren';

  @override
  String get unblockUserInstance => 'Benutzerinstanz entsperren';

  @override
  String get understandEnable => 'Verstehe, Aktivieren';

  @override
  String get unexpectedError => 'Unerwarteter Fehler';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get unfeaturedPost => 'Einfacher Post';

  @override
  String get unhidCommunity => 'Unversteckte Community';

  @override
  String get unhide => 'Einblenden';

  @override
  String unifiedPushDistributorApp(Object app, Object count) {
    return 'UnifiedPush Verteileranwendung: $app ($count verfügbar)';
  }

  @override
  String get unifiedPushNotifications => 'UnifiedPush Benachrichtigungen';

  @override
  String unifiedPushServer(Object server) {
    return 'UnifiedPush Server: $server';
  }

  @override
  String get unifiedpush => 'UnifiedPush';

  @override
  String get unlockPost => 'Post entsperren';

  @override
  String get unlockedPost => 'Entsperrter Post';

  @override
  String get unpinFromCommunity => 'Aus der Community lösen';

  @override
  String get unpinPostFromCommunity => 'Post aus der Community lösen';

  @override
  String get unreachable => 'Unerreichbar';

  @override
  String get unresolved => 'Ungeklärt';

  @override
  String get unsubscribe => 'Abbestellen';

  @override
  String get unsubscribeFromCommunity => 'Community abbestellen';

  @override
  String get unsubscribePending => 'Abbestellen (Abonnement ausstehend)';

  @override
  String get unsubscribed => 'Abbestellt';

  @override
  String updateReleased(Object version) {
    return 'Update veröffentlicht: $version';
  }

  @override
  String get uploadImage => 'Bild hochladen';

  @override
  String uploadedDate(Object date) {
    return 'Hochgeladen: $date';
  }

  @override
  String get upvote => 'Aufwerten';

  @override
  String get upvoteColor => 'Hochstufen Farbe';

  @override
  String get upvoted => 'Hochgestuft';

  @override
  String get uriNotSupported =>
      'Diese Art der Link wird zur Zeit nicht unterstützt.';

  @override
  String get url => 'URL';

  @override
  String get useAdvancedShareSheet => 'Erweitertes Freigabeformular verwenden';

  @override
  String get useApplePushNotifications => 'APNs Benachrichtigungen verwenden';

  @override
  String get useApplePushNotificationsDescription =>
      'Verwendet Apples Push-Benachrichtigungsdienst';

  @override
  String get useCompactView =>
      'Für kleine Posts einschalten, für große deaktivieren.';

  @override
  String get useLocalNotifications =>
      'Lokale Benachrichtigungen verwenden (experimentell)';

  @override
  String get useLocalNotificationsDescription =>
      'Prüft regelmäßig im Hintergrund auf Benachrichtigungen';

  @override
  String get useMaterialYouTheme => 'Verwende Material You Thema';

  @override
  String get useMaterialYouThemeDescription =>
      'Setzt das benutzerdefinierte Thema außer Kraft';

  @override
  String get useProfilePictureForDrawer => 'Profilbild für Drawer verwenden';

  @override
  String get useProfilePictureForDrawerSubtitle =>
      'Zeigt bei der Anmeldung das Profilbild des Benutzers, anstelle des Symboles an';

  @override
  String useSuggestedTitle(Object title) {
    return 'Vorgeschlagenen Titel verwenden: $title';
  }

  @override
  String get useUnifiedPushNotifications =>
      'UnifiedPush-Benachrichtigungen verwenden';

  @override
  String get useUnifiedPushNotificationsDescription =>
      'Benötigt eine kompatible App';

  @override
  String get user => 'Benutzer';

  @override
  String get userActions => 'Benutzer Aktionen';

  @override
  String userEntry(Object username) {
    return 'Benutzer \'$username\'';
  }

  @override
  String get userFormat => 'Benutzerformat';

  @override
  String get userLabelHint => 'Dies ist mein bevorzugter Benutzer';

  @override
  String get userLabels => 'Benutzer Bezeichnungen';

  @override
  String get userLabelsSettingsPageDescription =>
      'Du kannst mit Benutzern verknüpfte Kennzeichnungen hinzufügen, ändern oder entfernen.';

  @override
  String get userNameColor => 'Benutzername Farbe';

  @override
  String get userNameThickness => 'Nutzername Stärke';

  @override
  String get userNotLoggedIn => 'Benutzer nicht angemeldet';

  @override
  String get userProfiles => 'Benutzerprofile';

  @override
  String get userSettingDescription =>
      'Diese Einstellungen werden mit deinem Lemmy-Konto synchronisiert und gelten nur für das jeweilige Konto.';

  @override
  String get userStyle => 'Benutzer-Stil';

  @override
  String get username => 'Benutzername';

  @override
  String get usernameFormattingRedirect =>
      'Suchst du nach der Formatierung des Benutzernamens?';

  @override
  String get users => 'Benutzer';

  @override
  String versionNumber(Object version) {
    return 'Version $version';
  }

  @override
  String get video => 'Video';

  @override
  String get videoAutoFullscreen => 'Auto-Vollbild';

  @override
  String get videoAutoLoop => 'Video wiederholen';

  @override
  String get videoAutoMute => 'Videos stummschalten';

  @override
  String get videoAutoPlay => 'Video automatisch abspielen';

  @override
  String get videoDefaultPlaybackSpeed => 'Standard Wiedergabegeschwindigkeit';

  @override
  String get videoLinkHandlingExternal => 'Videos mit externer App abspielen';

  @override
  String get videoPlayerInApp => 'Integrierten Thunder Player verwenden';

  @override
  String get videoPlayerMode => 'Player Modus';

  @override
  String get viewAll => 'Alle ansehen';

  @override
  String get viewAllComments => 'Alle Kommentare anzeigen';

  @override
  String get viewCommentSource => 'Kommentarquelle anzeigen';

  @override
  String get viewModlog => 'Modlog anzeigen';

  @override
  String get viewOriginal => 'Original anzeigen';

  @override
  String get viewPostAsDifferentAccount => 'Post unter anderem Konto anzeigen';

  @override
  String get viewPostSource => 'Quelle für Post anzeigen';

  @override
  String get viewSource => 'Quelle anzeigen';

  @override
  String get viewingAll => 'Alle anzeigen';

  @override
  String visibility(Object visibility) {
    return 'Sichtbarkeit: $visibility';
  }

  @override
  String get visitCommunity => 'Community besuchen';

  @override
  String get visitCommunityInstance => 'Community-Instanz besuchen';

  @override
  String get visitInstance => 'Instanz besuchen';

  @override
  String get visitUserInstance => 'Benutzerinstanz besuchen';

  @override
  String get visitUserProfile => 'Benutzerprofil besuchen';

  @override
  String get warning => 'Warnung';

  @override
  String xDownvotes(Object x) {
    return '$x Herabstufungen';
  }

  @override
  String xScore(Object x) {
    return '$x Wertung';
  }

  @override
  String xUpvotes(Object x) {
    return '$x Hochstufungen';
  }

  @override
  String xYearsOld(num count, Object x) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$x Jahre alt',
      one: '$x Jahr alt',
      zero: '$x Jahr alt',
    );
    return '$_temp0';
  }

  @override
  String get yes => 'Ja';

  @override
  String get youMustSelectAJsonFile => 'Sie müssen eine JSON-Datei auswählen.';
}
