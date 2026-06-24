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
    return 'De geselecteerde opmerking is niet gevonden op ‘$instance’';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'Het geselecteerde bericht is niet gevonden op ‘$instance’';
  }

  @override
  String get actionColors => 'Actie­kleuren';

  @override
  String get actionColorsRedirect => 'Wilt u kleuren aanpassen?';

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
  String get addAccountToSeeProfile => 'Log in om uw account te bekĳken.';

  @override
  String get addAnonymousInstance => 'Anonieme instantie toevoegen';

  @override
  String get addAsCommunityModerator => 'Toevoegen als gemeenschaps­moderator';

  @override
  String get addDiscussionLanguage => 'Taal toevoegen';

  @override
  String get addKeywordFilter => 'Sleutel­woord toevoegen';

  @override
  String get addOriginalPostBody => 'Originele bericht­tekst toevoegen?';

  @override
  String get addToFavorites => 'Toevoegen aan favorieten';

  @override
  String get addUserLabel => 'Gebruikers­label toevoegen';

  @override
  String get addedCommunityToSubscriptions => 'Geabonneerd op gemeenschap';

  @override
  String get addedInstanceMod => 'Instantie­moderator toegevoegd';

  @override
  String get addedModToCommunity => 'Moderator toegevoegd aan gemeenschap';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return '$username toegevoegd als gemeenschaps­moderator';
  }

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
  String get allowOpenSupportedLinks =>
      'Sta toe dat de app ondersteunde links opent.';

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
  String get applePushNotificationService => 'Apple-pushmeldings­service';

  @override
  String get applied => 'Toegepast';

  @override
  String get apply => 'Toepassen';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return 'Meldingen zijn toegestaan door het systeem: $yesOrNo';
  }

  @override
  String averageComments(Object x) {
    return '$x opmerkingen/maand';
  }

  @override
  String averageContributions(Object x) {
    return '$x bĳdragen/maand';
  }

  @override
  String averagePosts(Object x) {
    return '$x berichten/maand';
  }

  @override
  String get back => 'Terug';

  @override
  String get backButton => 'Terug­knop';

  @override
  String get backToTop => 'Terug naar boven';

  @override
  String get backgroundCheckWarning =>
      'Houd er rekening mee dat meldings­controles extra accu verbruiken';

  @override
  String get ban => 'Verbannen';

  @override
  String get banFromCommunity => 'Verbannen van gemeen­schap';

  @override
  String get bannedUser => 'Verbannen gebruiker';

  @override
  String get bannedUserFromCommunity => 'Gebruiker verbannen van gemeenschap';

  @override
  String get base => 'Basis';

  @override
  String get block => 'Blokkeren';

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
    return 'U bezoekt $instance momenteel anoniem.';
  }

  @override
  String get cancel => 'Annuleren';

  @override
  String get cannotReportOwnComment =>
      'U kunt uw eigen opmerking niet rapporteren.';

  @override
  String get cantBlockAdmin => 'U kunt een instantie­beheerder niet blokkeren.';

  @override
  String get cantBlockYourself => 'U kunt zichzelf niet blokkeren.';

  @override
  String get cardPostCardMetadataItems => 'Meta­gegevens in kaart­weergave';

  @override
  String get cardView => 'Kaart­weergave';

  @override
  String get cardViewDescription =>
      'Schakel kaart­weergave in om instellingen aan te passen';

  @override
  String get cardViewSettings => 'Kaart­weergave­instellingen';

  @override
  String get changeAccountSettingsFor => 'Account­instellingen wĳzigen voor';

  @override
  String get changeNotificationSettings => 'Meldings­instellingen wĳzigen…';

  @override
  String get changePassword => 'Wachtwoord wĳzigen';

  @override
  String get changePasswordWarning =>
      'Om uw wacht­woord te wĳzigen, wordt u door­gestuurd naar de website van uw instantie.\n\nWeet u zeker dat u wilt doorgaan?';

  @override
  String get changeSort => 'Sortering wĳzigen';

  @override
  String clearCache(Object cacheSize) {
    return 'Cache wissen ($cacheSize)';
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
  String get clearedCache => 'Cache succesvol gewist.';

  @override
  String get clearedDatabase =>
      'Lokale database gewist. Start Thunder opnieuw op om de nieuwe wĳzigingen door te voeren.';

  @override
  String get clearedUserPreferences => 'Alle gebruikers­voorkeuren gewist';

  @override
  String get close => 'Sluiten';

  @override
  String get collapse => 'Inklappen';

  @override
  String get collapseCommentPreview => 'Voorbeeld van opmerkingen inklappen';

  @override
  String get collapseInformation => 'Informatie inklappen';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Boven­liggende opmerking verbergen wanneer ingeklapt';

  @override
  String get collapsePost => 'Bericht inklappen';

  @override
  String get collapsePostPreview => 'Voorbeeld van bericht inklappen';

  @override
  String get collapseSpoiler => 'Spoiler inklappen';

  @override
  String get color => 'Kleur';

  @override
  String get colorizeCommunityName => 'Gemeenschaps­naam kleuren';

  @override
  String get colorizeInstanceName => 'Instantie­naam kleuren';

  @override
  String get colorizeUserName => 'Gebruikers­naam kleuren';

  @override
  String get colors => 'Kleuren';

  @override
  String get combineCommentScores => 'Opmerking­scores combineren';

  @override
  String get combineCommentScoresLabel => 'Opmerking­scores combineren';

  @override
  String get combineNavAndFab =>
      'Zwevende actie­knop en navigatie­knoppen combineren';

  @override
  String get combineNavAndFabDescription =>
      'Zwevende actie­knop wordt getoond tussen de navigatie­knoppen.';

  @override
  String get comfortable => 'Comfortabel';

  @override
  String get comment => 'Opmerking';

  @override
  String get commentActions => 'Opmerkings­acties';

  @override
  String get commentBehaviourSettings => 'Opmerkingen';

  @override
  String get commentFontScale => 'Lettertype­schaal van opmerkings­inhoud';

  @override
  String get commentPreview =>
      'Toon een voorbeeld van opmerkingen met de opgegeven instellingen';

  @override
  String get commentReported => 'De opmerking is gemarkeerd voor beoordeling.';

  @override
  String get commentSavedAsDraft => 'Opmerking opgeslagen als concept';

  @override
  String get commentShowUserAvatar => 'Gebruikers­avatar tonen';

  @override
  String get commentShowUserInstance => 'Gebruikers­instantie tonen';

  @override
  String get commentSortType => 'Sorteer­type voor opmerkingen';

  @override
  String get commentSwipeActions => 'Veeg­acties voor opmerkingen';

  @override
  String get commentSwipeGesturesHint =>
      'Wilt u liever knoppen gebruiken? Schakel ze in onder opmerkingen van de algemene instellingen.';

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
  String get communityNameColor => 'Kleur van gemeenschaps­naam';

  @override
  String get communityNameThickness => 'Dikte van gemeenschaps­naam';

  @override
  String get communityStyle => 'Gemeenschaps­stĳl';

  @override
  String get compact => 'Compact';

  @override
  String get compactPostCardMetadataItems =>
      'Meta­gegevens voor compacte weergave';

  @override
  String get compactView => 'Compacte weergave';

  @override
  String get compactViewDescription =>
      'Schakel compacte weergave in om instellingen aan te passen';

  @override
  String get compactViewSettings => 'Instellingen voor compacte weergave';

  @override
  String get condensed => 'Beknopt';

  @override
  String get confirm => 'Bevestigen';

  @override
  String get confirmLogOutBody => 'Weet u zeker dat u wilt uitloggen?';

  @override
  String get confirmLogOutTitle => 'Uit­loggen?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Weet u zeker dat u alle reacties, vermeldingen en berichten als gelezen wilt markeren?';

  @override
  String get confirmMarkAllAsReadTitle => 'Alles als gelezen markeren?';

  @override
  String get confirmResetCommentPreferences =>
      'Hiermee worden alle opmerkings­voorkeuren gereset. Weet u zeker dat u wilt doorgaan?';

  @override
  String get confirmResetPostPreferences =>
      'Hiermee worden alle bericht­voorkeuren gereset. Weet u zeker dat u wilt doorgaan?';

  @override
  String get confirmUnsubscription =>
      'Weet u zeker dat u zich wilt deabonneren?';

  @override
  String connectedToUnifiedPushDistributorApp(Object app) {
    return 'Verbonden met $app';
  }

  @override
  String get contentManagement => 'Inhouds­beheer';

  @override
  String get contentWarning => 'Inhouds­waarschuwing';

  @override
  String get controversial => 'Controversieel';

  @override
  String get copiedToClipboard => 'Gekopieerd naar klembord';

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
      'Fout: Kon het bericht om de opmerking te verwĳderen niet bepalen.';

  @override
  String get couldNotDeterminePostComment =>
      'Fout: Kon het bericht om de opmerking bij te plaatsen niet bepalen.';

  @override
  String get couldntCreateReport =>
      'Uw opmerkings­rapport kon op dit moment niet worden verzonden. Probeer het later opnieuw';

  @override
  String get couldntFindPost =>
      'Het opgevraagde bericht kan niet worden geladen. Het is mogelijk verwĳderd.';

  @override
  String countComments(Object count) {
    return '$count opmerkingen';
  }

  @override
  String countLocalSubscribers(Object count) {
    return '$count lokale abonnees';
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
    return '$count gebruikers/6 maanden';
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
  String get createNewCrossPost => 'Nieuw kruis­bericht maken';

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
    return 'Gekruisplaatst vanuit: $postUrl';
  }

  @override
  String get crossPostedTo => 'Gekruisplaatst naar';

  @override
  String get currentLongPress => 'Momenteel ingesteld als lang indrukken';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Huidige meldings­modus: $mode';
  }

  @override
  String get currentSinglePress => 'Momenteel ingesteld als één keer drukken';

  @override
  String get customizeSwipeActions =>
      'Veeg­acties aan­passen (druk om te wĳzigen)';

  @override
  String get dangerZone => 'Gevaren­zone';

  @override
  String get dark => 'Donker';

  @override
  String get databaseExportWarning =>
      'De data­base kan gevoelige informatie bevatten met betrekking tot uw Lemmy-account. Als u deze exporteert, deel deze dan met niemand. Wilt u doorgaan?';

  @override
  String databaseExportedSuccessfully(Object savedFilePath) {
    return 'De database is succesvol geëxporteerd naar ‘$savedFilePath’';
  }

  @override
  String get databaseImportedSuccessfully =>
      'De database is succesvol geïmporteerd!';

  @override
  String get databaseNotExportedSuccessfully =>
      'De database is niet succesvol geëxporteerd of de bewerking is geannuleerd.';

  @override
  String get databaseNotImportedSuccessfully =>
      'De database is niet succesvol geïmporteerd of de bewerking is geannuleerd.';

  @override
  String get dateFormat => 'Datum­formaat';

  @override
  String get debug => 'Fout­opsporing';

  @override
  String get debugDescription =>
      'De volgende foutopsporingsinstellingen dienen alleen te worden gebruikt voor het oplossen van problemen.';

  @override
  String get debugNotificationsDescription =>
      'Gebruik de volgende opties om problemen met meldingen op te lossen.';

  @override
  String get decline => 'Afwĳzen';

  @override
  String get defaultColor => 'Standaard';

  @override
  String get defaultCommentSortType => 'Standaard­sortering voor opmerkingen';

  @override
  String get defaultFeedSortType => 'Standaard­sortering voor feed';

  @override
  String get defaultFeedType => 'Standaardfeedtype';

  @override
  String get delete => 'Verwĳderen';

  @override
  String get deleteAccount => 'Account verwĳderen';

  @override
  String get deleteAccountDescription =>
      'Om uw account permanent te verwĳderen, wordt u doorgestuurd naar de website van uw instantie.\n\nWeet u zeker dat u wilt doorgaan?';

  @override
  String get deleteComment => 'Opmerking verwĳderen';

  @override
  String get deleteDraftConfirmation =>
      'Are you sure you want to delete this draft?';

  @override
  String get deleteImageConfirmMessage =>
      'Weet u zeker dat u deze afbeelding wilt verwĳderen?';

  @override
  String get deleteImageConfirmTitle => 'Verwĳderen?';

  @override
  String get deleteLocalDatabase => 'Lokale database verwĳderen';

  @override
  String get deleteLocalDatabaseDescription =>
      'Deze actie verwĳdert de lokale database en meldt u af bĳ al uw accounts.\n\nWeet u zeker dat u wilt doorgaan?';

  @override
  String get deleteLocalPreferences => 'Lokale voorkeuren verwĳderen';

  @override
  String get deleteLocalPreferencesDescription =>
      'Dit wist al uw gebruikers­voorkeuren en -instellingen in Thunder.\n\nWilt u doorgaan?';

  @override
  String get deletePost => 'Bericht verwĳderen';

  @override
  String get deleteUserLabelConfirmation =>
      'Weet u zeker dat u het label wilt verwĳderen?';

  @override
  String get deleted => 'Verwĳderd';

  @override
  String get deletedByCreator => 'verwĳderd door aanmaker';

  @override
  String get deletedByModerator => 'verwĳderd door moderator';

  @override
  String get deletedComment => 'Opmerking verwĳderd';

  @override
  String get deletedPost => 'Bericht verwĳderd';

  @override
  String get deselectUndeterminedWarning =>
      'Als u ‘Onbepaald’ deselecteert, zult u de meeste inhoud niet zien.';

  @override
  String detailedReason(Object reason) {
    return 'Reden: $reason';
  }

  @override
  String get dimReadPosts => 'Gelezen berichten dimmen';

  @override
  String get directMessage => 'Direct message';

  @override
  String get disable => 'Uitschakelen';

  @override
  String get disablePushNotifications => 'Push­meldingen uitschakelen';

  @override
  String get disabled => 'Uitgeschakeld';

  @override
  String get discussionLanguages => 'Discussie­talen';

  @override
  String get discussionLanguagesTooltip =>
      'Inhoud wordt gefilterd op de geselecteerde talen.';

  @override
  String get dismissRead => 'Gelezen items afwĳzen';

  @override
  String get displayName => 'Weergave­naam';

  @override
  String get displayUserScore => 'Gebruikers­scores (karma) weergeven.';

  @override
  String get dividerAppearance => 'Verdeler­weergave';

  @override
  String get doNotShowAgain => 'Niet opnieuw tonen';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Er zĳn meerdere compatibele apps gevonden; installeer er slechts één';

  @override
  String get downloadingMedia => 'Bezig met downloaden van media om te delen…';

  @override
  String get downvote => 'Downvoten';

  @override
  String get downvoteColor => 'Downvote-kleur';

  @override
  String get downvoted => 'Gedownvotet';

  @override
  String get downvotesDisabled =>
      'Downvotes zĳn uitgeschakeld op deze instantie.';

  @override
  String get drafts => 'Drafts';

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
      'De koppeling is leeg. Geef een geldige dynamische koppeling op om door te gaan.';

  @override
  String get enableCommentNavigation => 'Opmerking­navigatie inschakelen';

  @override
  String get enableExperimentalFeatures => 'Experimentele functies inschakelen';

  @override
  String get enableFeedFab => 'Zwevende knop op feeds inschakelen';

  @override
  String get enableFloatingButtonOnFeeds =>
      'Zwevende knop op feeds inschakelen';

  @override
  String get enableFloatingButtonOnPosts =>
      'Zwevende knop op berichten inschakelen';

  @override
  String get enableInboxNotifications =>
      'Meldingen inschakelen voor postvak IN';

  @override
  String get enablePostFab => 'Zwevende knop op berichten inschakelen';

  @override
  String get endOfComments => 'Einde van de opmerkingen';

  @override
  String get endSearch => 'Stoppen met zoeken';

  @override
  String errorDeletingImage(Object error) {
    return 'Er is een fout opgetreden bĳ het verwĳderen van de afbeelding: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Kon het mediabestand niet downloaden om te delen: $errorMessage';
  }

  @override
  String get errorImportingAccountSettings =>
      'Er is een fout opgetreden bĳ het importeren van de instellingen. Het bestand heeft mogelijk niet de juiste indeling.';

  @override
  String get errorInitializingClient =>
      'Fout bĳ het initialiseren van de cliënt';

  @override
  String get errorLoadingAccountSettings =>
      'Er is een fout opgetreden bĳ het laden van het instellingenbestand of de bewerking is geannuleerd.';

  @override
  String get errorMarkingReplyRead =>
      'Er is een fout opgetreden bĳ het markeren van het antwoord als gelezen.';

  @override
  String get errorMarkingReplyUnread =>
      'Er is een fout opgetreden bĳ het markeren van het antwoord als ongelezen.';

  @override
  String get errorNoActiveInstance => 'Geen actieve instantie gevonden';

  @override
  String get errorParsingJson =>
      'Er is een fout opgetreden bĳ het parseren van het geselecteerde bestand. Het is mogelijk geen geldige JSON.';

  @override
  String get errorSavingAccountSettings =>
      'Er is een fout opgetreden bĳ het opslaan van het instellingenbestand of de bewerking is geannuleerd.';

  @override
  String get exceptionProcessingUri =>
      'Er is een fout opgetreden bĳ het verwerken van de koppeling. Deze is mogelijk niet beschikbaar op uw instantie.';

  @override
  String get excessiveApiCallsWarning =>
      'Het kan even duren voordat uw feed is geladen vanwege trefwoord­filters.';

  @override
  String get expand => 'Uitvouwen';

  @override
  String get expandCommentPreview => 'Voorbeeld van opmerkingen uitvouwen';

  @override
  String get expandInformation => 'Informatie uitvouwen';

  @override
  String get expandOptions => 'Opties uitvouwen';

  @override
  String get expandPost => 'Bericht uitvouwen';

  @override
  String get expandPostPreview => 'Voorbeeld van bericht uitvouwen';

  @override
  String get expandSpoiler => 'Spoiler uitvouwen';

  @override
  String get expanded => 'Uitgevouwen';

  @override
  String get experimentalFeatures => 'Experimentele functies';

  @override
  String get experimentalFeaturesDescription =>
      'Deze functies zĳn nog in ontwikkeling en kunnen instabiel zĳn. Gebruik ze op eigen risico. U dient Thunder opnieuw te starten om de wĳzigingen door te voeren.';

  @override
  String get exploreInstance => 'Instantie verkennen';

  @override
  String get exportDatabase => 'Database exporteren';

  @override
  String get exportDatabaseSubtitle =>
      'De database bevat informatie over accounts, favorieten, anonieme abonnementen en gebruikers­labels.';

  @override
  String get exportLemmyAccountSettingsDescription =>
      'Lemmy-account­instellingen exporteren';

  @override
  String get exportSettingsSubtitle =>
      'De instellingen bevatten alle voorkeuren die u hebt geconfigureerd in Thunder.';

  @override
  String get extraLarge => 'Extra groot';

  @override
  String failedToBlock(Object errorMessage) {
    return 'Kon niet blokkeren: $errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return 'Kon niet communiceren met de Thunder-meldingenserver op $serverAddress.';
  }

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return 'Kon blokkeringen niet laden: $errorMessage';
  }

  @override
  String get failedToLoadVideo =>
      'Kon video niet laden. Koppeling openen in browser?';

  @override
  String get failedToPerformAction => 'Kon actie niet uitvoeren';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'Kon deblokkering niet ongedaan maken: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Kon melding­instellingen niet bĳwerken';

  @override
  String get favorite => 'Opslaan als favoriet';

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
  String get feedTypeAndSorts => 'Standaardfeedtype en -sortering';

  @override
  String get fetchAccountError => 'Kon account niet bepalen';

  @override
  String filteringBy(Object entity) {
    return 'Gefilterd op $entity';
  }

  @override
  String get filters => 'Filters';

  @override
  String get floatingActionButton => 'Zwevende actie­knop';

  @override
  String get floatingActionButtonInformation =>
      'Thunder heeft een volledig aanpasbare zwevende actie­knop die een aantal gebaren ondersteunt.\n- Veeg omhoog om extra acties weer te geven\n- Veeg omlaag/omhoog om de zwevende actie­knop te verbergen of weer te geven\n\nHoud één van onderstaande acties lang ingedrukt om de hoofd- en secundaire acties aan te passen.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'geeft de actie aan bĳ lang indrukken van de zwevende actie­knop.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'geeft de actie aan bĳ eenmalig drukken op de zwevende actie­knop.';

  @override
  String get fonts => 'Letter­typen';

  @override
  String get forward => 'Vooruit';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Compatibele app gevonden; start Thunder opnieuw op om te verbinden';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Veeg ergens om terug te gaan als links-naar-rechts-gebaren zĳn uitgeschakeld';

  @override
  String get fullscreen => 'Volledig scherm';

  @override
  String get fullscreenSwipeGestures => 'Veeg­gebaren in volledig scherm';

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
  String get guestModeFeedSettings => 'Feed-instellingen voor gastmodus';

  @override
  String get guestModeFeedSettingsLabel =>
      'De volgende instellingen worden alleen toegepast op gast­accounts. Ga naar ‘Account­instellingen’ om feed­instellingen voor uw account aan te passen.';

  @override
  String get havingIssuesWithNotifications => 'Hebt u problemen met meldingen?';

  @override
  String get hidCommunity => 'Heeft gemeen­schap verborgen';

  @override
  String get hidden => 'Verborgen';

  @override
  String get hide => 'Verbergen';

  @override
  String get hideBottomBarOnScroll => 'Onderste balk verbergen bĳ scrollen';

  @override
  String get hideColor => 'Kleur verbergen';

  @override
  String get hideNsfwPostsFromFeed => 'NSFW-berichten verbergen uit feed';

  @override
  String get hideNsfwPreviews => 'NSFW-voor­vertoningen vervagen';

  @override
  String get hidePassword => 'Wachtwoord verbergen';

  @override
  String get hideThumbnails => 'Miniaturen verbergen';

  @override
  String get hideTopBarOnScroll => 'Bovenbalk verbergen bĳ scrollen';

  @override
  String get hostInstance => 'Host-instantie';

  @override
  String get hot => 'Populair';

  @override
  String get image => 'Afbeelding';

  @override
  String get imageCachingMode => 'Afbeelding­cache­modus';

  @override
  String get imageCachingModeAggressive =>
      'Afbeeldingen agressief in cache opslaan (gebruikt meer geheugen)';

  @override
  String get imageCachingModeAggressiveShort => 'Agressief';

  @override
  String get imageCachingModeRelaxed =>
      'Cache voor afbeeldingen laten verlopen (gebruikt minder geheugen, maar afbeeldingen worden vaker opnieuw geladen)';

  @override
  String get imageCachingModeRelaxedShort => 'Ontspannen';

  @override
  String get imageDimensionTimeout => 'Time-out voor afbeeldings­afmetingen';

  @override
  String get imagePeekDuration => 'Image Peek Duration';

  @override
  String get imagePeekDurationDescription =>
      'Duration of long press before image peek is triggered';

  @override
  String get importDatabase => 'Database importeren';

  @override
  String get importExportDatabase => 'Thunder-database importeren/exporteren';

  @override
  String get importExportLemmyAccountSettings =>
      'Lemmy-account­instellingen importeren/exporteren';

  @override
  String get importExportLemmyAccountSettingsSubtitle =>
      'Bevat abonnementen op gemeen­schappen, blokkeer­lĳsten en account­voorkeuren';

  @override
  String get importExportSettings => 'Instellingen importeren/exporteren';

  @override
  String get importExportThunderSettings =>
      'Thunder-instellingen importeren/exporteren';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Lemmy-account­instellingen importeren';

  @override
  String get importSettings => 'Instellingen importeren';

  @override
  String inReplyTo(Object post, Object community) {
    return 'Als antwoord op $post in $community';
  }

  @override
  String get in_ => 'in';

  @override
  String get inbox => 'Postvak IN';

  @override
  String get includeCommunity => 'Gemeen­schap bĳvoegen';

  @override
  String get includeExternalLink => 'Externe link opnemen';

  @override
  String get includeImage => 'Afbeelding bĳvoegen';

  @override
  String get includePostLink => 'Bericht­link opnemen';

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
      other: 'Instanties',
      one: 'Instantie',
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
    return '$instance is al toegevoegd.';
  }

  @override
  String get instanceNameColor => 'Kleur van instantie­naam';

  @override
  String get instanceNameThickness => 'Dikte van instantie­naam';

  @override
  String get instanceOffline => 'Instance is offline';

  @override
  String get instanceOnline => 'Instance is online';

  @override
  String get instanceStatusUnknown => 'Instance status unknown';

  @override
  String get instances => 'Instanties';

  @override
  String get internetOrInstanceIssues =>
      'U bent mogelijk niet verbonden met het internet of uw instantie is momenteel niet beschikbaar.';

  @override
  String get invalidUrl => 'Ongeldige URL-indeling';

  @override
  String joined(Object x) {
    return 'Lid geworden op $x';
  }

  @override
  String get keywordFilterDescription =>
      'Filtert berichten die trefwoorden bevatten in de titel, inhoud of URL';

  @override
  String get keywordFilters => 'Trefwoord­filters';

  @override
  String get label => 'Label';

  @override
  String get language => 'Taal';

  @override
  String get languageFilters => 'Op zoek naar taal­filters?';

  @override
  String get languageNotAllowed =>
      'De gemeenschap waarin u plaatst, staat geen berichten toe in de taal die u hebt geselecteerd. Probeer een andere taal.';

  @override
  String get large => 'Groot';

  @override
  String get leftLongSwipe => 'Lange veeg naar links';

  @override
  String get leftShortSwipe => 'Korte veeg naar links';

  @override
  String get light => 'Licht';

  @override
  String link(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Koppelingen',
      one: 'Koppeling',
    );
    return '$_temp0 ';
  }

  @override
  String get linkActions => 'Link­acties';

  @override
  String get linkHandlingCustomTabs =>
      'Openen in systeembrowser ingebed in-app';

  @override
  String get linkHandlingCustomTabsShort => 'In-app ingebed';

  @override
  String get linkHandlingExternal => 'Extern openen in systeembrowser';

  @override
  String get linkHandlingExternalShort => 'Extern';

  @override
  String get linkHandlingInApp => 'Ingebouwde browser van Thunder gebruiken';

  @override
  String get linkHandlingInAppShort => 'Intern';

  @override
  String get linkPostsUseCompactView => 'Show Compact Link Posts';

  @override
  String get linksBehaviourSettings => 'Koppelingen';

  @override
  String loadMorePlural(Object count) {
    return 'Nog $count reacties laden…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Nog $count reactie laden…';
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
  String get loginAttemptCanceled => 'Aanmeld­poging geannuleerd.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Kon niet inloggen. Probeer het opnieuw. (Fout: $errorMessage)';
  }

  @override
  String get loginSucceeded => 'Ingelogd.';

  @override
  String get loginToPerformAction =>
      'U dient ingelogd te zĳn om deze taak uit te voeren.';

  @override
  String get loginToSeeInbox => 'Log in om uw postvak IN te bekijken';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Op zoek naar account­specifieke feed­instellingen?';

  @override
  String get malformedUri =>
      'De opgegeven koppeling heeft een niet-ondersteunde indeling. Zorg ervoor dat het een geldige koppeling is.';

  @override
  String get manageAccounts => 'Accounts beheren';

  @override
  String get manageMedia => 'Media beheren';

  @override
  String get markAllAsRead => 'Alles als gelezen markeren';

  @override
  String get markAsRead => 'Markeren als gelezen';

  @override
  String get markPostAsReadOnMediaView =>
      'Markeren als gelezen na bekijken van media';

  @override
  String get markPostAsReadOnScroll => 'Markeren als gelezen bĳ scrollen';

  @override
  String get markReadColor => 'Kleur van markeren als (on)gelezen';

  @override
  String get matrixUser => 'Matrix­gebruiker';

  @override
  String get me => 'Ik';

  @override
  String get media => 'Media';

  @override
  String get medium => 'Gemiddeld';

  @override
  String mention(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vermeldingen',
      one: 'Vermelding',
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
      other: 'Berichten',
      one: 'Bericht',
    );
    return '$_temp0';
  }

  @override
  String get metadataFontScale => 'Lettertype­grootte voor meta­gegevens';

  @override
  String get missingErrorMessage => 'Geen foutmelding beschikbaar';

  @override
  String get modAdd => 'Instantie­moderators toevoegen/verwĳderen';

  @override
  String get modAddCommunity =>
      'Moderators toevoegen aan/verwĳderen uit gemeen­schappen';

  @override
  String get modBan => 'Instantie­gebruikers verbannen/herstellen';

  @override
  String get modBanFromCommunity =>
      'Gebruikers verbannen uit/herstellen in gemeen­schappen';

  @override
  String get modFeaturePost => 'Berichten uitlichten/niet meer uitlichten';

  @override
  String get modLockPost => 'Berichten vergrendelen/ontgrendelen';

  @override
  String get modRemoveComment => 'Opmerkingen verwĳderen/herstellen';

  @override
  String get modRemoveCommunity => 'Gemeenschappen verwĳderen/herstellen';

  @override
  String get modRemovePost => 'Berichten verwĳderen/herstellen';

  @override
  String get modTransferCommunity => 'Gemeen­schappen overdragen';

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
  String get mustBeLoggedIn => 'U dient ingelogd te zĳn';

  @override
  String get mustBeLoggedInComment =>
      'U dient ingelogd te zĳn om een opmerking te plaatsen';

  @override
  String get mustBeLoggedInPost =>
      'U dient ingelogd te zĳn om een bericht te plaatsen';

  @override
  String get names => 'Namen';

  @override
  String get navbarDoubleTapGestures =>
      'Dubbel-tik-gebaren voor navigatie­balk';

  @override
  String get navbarSwipeGestures => 'Veeg­gebaren voor navigatie­balk';

  @override
  String get navigateDown => 'Volgende opmerking';

  @override
  String get navigateUp => 'Vorige opmerking';

  @override
  String get navigation => 'Navigatie';

  @override
  String get nestedCommentIndicatorColor =>
      'Kleur van indicator voor geneste opmerkingen';

  @override
  String get nestedCommentIndicatorStyle =>
      'Stijl van indicator voor geneste opmerkingen';

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
  String get noAccountsAdded => 'Er zĳn geen accounts toegevoegd';

  @override
  String get noAnonymousInstances =>
      'Er zĳn geen anonieme instanties toegevoegd';

  @override
  String get noCommentsFound => 'Geen opmerkingen gevonden';

  @override
  String get noCommunitiesFound => 'Geen gemeenschappen gevonden';

  @override
  String get noCommunityBlocks => 'Geen geblokkeerde gemeen­schappen';

  @override
  String get noCommunitySelected => 'No community selected';

  @override
  String get noCompatibleAppFound => 'Geen compatibele app gevonden';

  @override
  String get noDiscussionLanguages =>
      'Er wordt geen inhoud verborgen op basis van taal.';

  @override
  String get noDisplayNameSet => 'Geen weergave­naam ingesteld';

  @override
  String get noDrafts => 'You do not have any drafts yet';

  @override
  String get noEmailSet => 'Geen e-mail ingesteld';

  @override
  String get noFavoritedCommunities => 'Geen favoriete gemeenschappen';

  @override
  String get noImages =>
      'Het lĳkt erop dat u nog geen afbeeldingen hebt geüpload.';

  @override
  String get noInstanceBlocks => 'Er zĳn geen geblokkeerde instanties.';

  @override
  String get noItems => 'Geen items';

  @override
  String get noKeywordFilters => 'Geen trefwoord­filters toegevoegd';

  @override
  String get noLanguage => 'Geen taal';

  @override
  String get noMatrixUserSet => 'Geen Matrix-gebruiker ingesteld';

  @override
  String get noMentions => 'Geen vermeldingen';

  @override
  String get noMessages => 'Geen berichten';

  @override
  String get noPostsFound => 'Er zĳn geen berichten gevonden.';

  @override
  String get noProfileBioSet => 'Geen profiel­biografie ingesteld';

  @override
  String get noReferencesToImage =>
      'Er zĳn geen berichten of opmerkingen gevonden die deze afbeelding bevatten. Deze kan echter elders op het internet worden gebruikt.';

  @override
  String get noReplies => 'Geen reacties';

  @override
  String get noResultsFound => 'Geen resultaten gevonden.';

  @override
  String get noSubscriptions => 'Geen abonnementen';

  @override
  String get noUserBlocks => 'Geen geblokkeerde gebruikers.';

  @override
  String get noUserLabels => 'U hebt nog geen gebruikers­labels aangemaakt';

  @override
  String get noUsersFound => 'Geen gebruikers gevonden.';

  @override
  String get noVisibleComments =>
      'Opmerkingen zĳn mogelijk niet zichtbaar omdat de gemeenschap is geblokkeerd.';

  @override
  String get none => 'Geen';

  @override
  String get normal => 'Normaal';

  @override
  String get notAvailable => 'N/A';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance lĳkt geen geldige instantie te zĳn';
  }

  @override
  String get notValidUrl => 'Geen geldige URL';

  @override
  String get nothingToShare => 'Niets om te delen';

  @override
  String notifications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Meldingen',
      one: 'Melding',
    );
    return '$_temp0';
  }

  @override
  String get notificationsBehaviourSettings => 'Meldingen';

  @override
  String get notificationsNotAllowed =>
      'Meldingen zĳn niet toegestaan voor Thunder in de systeeminstellingen';

  @override
  String get notificationsWarningDialog =>
      'Meldingen zĳn een **experimentele functie** die mogelijk niet correct werkt op alle apparaten.\n\n - Controles vinden elke ~15 minuten plaats en verbruiken extra accu.\n\n - Schakel accu-optimalisaties uit voor een grotere kans op succesvolle meldingen.\n\n Raadpleeg de volgende pagina voor meer informatie.';

  @override
  String get nsfw => 'NSFW';

  @override
  String get nsfwWarning => 'NSFW - Druk om weer te geven';

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
      'Alleen moderators mogen berichten plaatsen in deze gemeenschap';

  @override
  String get open => 'Openen';

  @override
  String get openAccountSwitcher => 'Account­wisselaar openen';

  @override
  String get openByDefault => 'Standaard openen';

  @override
  String get openInBrowser => 'Openen in browser';

  @override
  String get openInstance => 'Instantie openen';

  @override
  String get openLinksInExternalBrowser =>
      'Koppelingen openen in externe browser';

  @override
  String get openLinksInReaderMode => 'Koppelingen openen in lees­modus';

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
    return 'Uitgevoerd door: $user';
  }

  @override
  String get permissionDenied =>
      'Thunder heeft geen toestemming gekregen om meldingen weer te geven. Schakel dit in via de systeeminstellingen.';

  @override
  String get permissionDeniedMessage =>
      'Thunder heeft enkele machtigingen nodig om deze afbeelding op te slaan die zĳn geweigerd.';

  @override
  String get piefedSupportBeta =>
      'PieFed support is currently in beta.\nNot all features are supported yet.';

  @override
  String get pinPostToCommunity => 'Bericht vastpinnen in gemeenschap';

  @override
  String get pinToCommunity => 'Vastpinnen in gemeenschap';

  @override
  String get pinned => 'Vastgepind';

  @override
  String get pinnedPostToCommunity => 'Bericht vastgepind in gemeenschap';

  @override
  String get pinnedPostsUseCompactView => 'Show Compact Pinned Posts';

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
  String get postBodySettings => 'Instellingen voor bericht­inhoud';

  @override
  String get postBodySettingsDescription =>
      'Deze instellingen hebben invloed op de weergave van de bericht­inhoud';

  @override
  String get postBodyShowCommunityInstance =>
      'Gemeenschaps­instantie weergeven';

  @override
  String get postBodyShowUserInstance => 'Gebruikers­instantie weergeven';

  @override
  String get postBodyViewType => 'Weergavetype voor bericht­inhoud';

  @override
  String get postContentFontScale => 'Letter­grootte van bericht­inhoud';

  @override
  String get postCreatedSuccessfully => 'Bericht succesvol aangemaakt!';

  @override
  String get postFlairs => 'Flairs';

  @override
  String get postFlairsUnavailable =>
      'No flair options available for this community';

  @override
  String get postLocked => 'Bericht vergrendeld. Geen reacties toegestaan.';

  @override
  String get postMetadataInstructions =>
      'U kunt de metadata-informatie aanpassen door de gewenste informatie te slepen en neer te zetten';

  @override
  String get postNSFW => 'Markeren als NSFW';

  @override
  String get postPreview =>
      'Toon een voorbeeld van het bericht met de opgegeven instellingen';

  @override
  String get postSavedAsDraft => 'Bericht opgeslagen als concept';

  @override
  String get postShowUserInstance => 'Gebruikers­instantie tonen';

  @override
  String get postSwipeActions => 'Veegacties voor berichten';

  @override
  String get postSwipeGesturesHint =>
      'Wilt u liever knoppen gebruiken? Wĳzig welke knoppen worden weergegeven op berichtkaarten in de algemene instellingen.';

  @override
  String get postTags => 'Tags';

  @override
  String get postTagsHelperText => 'Separate tags with commas';

  @override
  String get postTitle => 'Titel';

  @override
  String get postTitleFontScale => 'Letter­grootte van bericht­titel';

  @override
  String get postTogglePreview => 'Voor­vertoning omschakelen';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Kon afbeelding niet uploaden';

  @override
  String get postViewType => 'Weergavetype voor berichten';

  @override
  String get posts => 'Berichten';

  @override
  String get preview => 'Voor­vertoning';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile succesvol toegepast!';
  }

  @override
  String get profileBio => 'Profiel­biografie';

  @override
  String get profileOperationInProgress => 'Profile operation in progress';

  @override
  String get profiles => 'Profielen';

  @override
  String get public => 'Openbaar';

  @override
  String get pureBlack => 'Puur zwart';

  @override
  String get purgedComment => 'Opmerking vernietigd';

  @override
  String get purgedCommunity => 'Gemeenschap vernietigd';

  @override
  String get purgedPerson => 'Persoon vernietigd';

  @override
  String get purgedPost => 'Bericht vernietigd';

  @override
  String get purple => 'Paars';

  @override
  String get pushNotification => 'Push­meldingen';

  @override
  String get pushNotificationDescription =>
      'Indien ingeschakeld, stuurt Thunder uw JWT-token(s) naar de server om te pollen voor nieuwe meldingen.\n\n **OPMERKING:** Dit wordt pas van kracht als de app opnieuw wordt gestart.';

  @override
  String get pushNotificationServer => 'Pushmeldings­server';

  @override
  String get pushNotificationServerDescription =>
      'Configureer de pushmeldingenserver. De server moet correct geconfigureerd zĳn om pushmeldingen naar uw apparaat te verzenden.\n\n **Voer alleen een server in die u vertrouwt met uw inloggegevens.**';

  @override
  String get rateLimitErrorMessage =>
      'U hebt de snelheidslimiet voor dit verzoek bereikt. Wacht even en probeer het later opnieuw.';

  @override
  String get reachedTheBottom => 'Geen items meer om te laden';

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
  String get reducesAnimations =>
      'Vermindert de animaties die in Thunder worden gebruikt';

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
  String get removeAsCommunityModerator =>
      'Verwĳderen als gemeen­schaps­moderator';

  @override
  String get removeComment => 'Opmerking verwĳderen';

  @override
  String get removeFromFavorites => 'Verwĳderen uit favorieten';

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
  String get removeUserData => 'Gebruikersgegevens verwĳderen';

  @override
  String get removed => 'Verwĳderd';

  @override
  String get removedComment => 'Verwĳderde opmerking';

  @override
  String get removedCommunity => 'Gemeen­schap verwĳderd';

  @override
  String get removedCommunityFromSubscriptions => 'Deabonneren van gemeenschap';

  @override
  String get removedInstanceMod => 'Instantie­moderator verwĳderd';

  @override
  String get removedModFromCommunity => 'Moderator verwĳderd uit gemeenschap';

  @override
  String get removedPost => 'Bericht verwĳderd';

  @override
  String removedUserAsCommunityModerator(Object username) {
    return '$username verwĳderd als gemeen­schaps­moderator';
  }

  @override
  String get reorder => 'Opnieuw ordenen';

  @override
  String reply(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reacties',
      one: 'Reactie',
    );
    return '$_temp0';
  }

  @override
  String get replyColor => 'Reactie­kleur';

  @override
  String get replyNotSupported =>
      'Reageren vanuit deze weergave wordt momenteel nog niet ondersteund';

  @override
  String get replyToComment => 'Reply to Comment';

  @override
  String get replyToPost => 'Reageren op bericht';

  @override
  String replyingTo(Object author) {
    return 'Reageren op $author';
  }

  @override
  String report(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rapportages',
      one: 'Rapportage',
    );
    return '$_temp0 ';
  }

  @override
  String get reportComment => 'Opmerking rapporteren';

  @override
  String get reportPost => 'Bericht rapporteren';

  @override
  String get reportedComment => 'Opmerking gerapporteerd';

  @override
  String get reportedPost => 'Bericht gerapporteerd';

  @override
  String get reporter => 'Rapporteerder:';

  @override
  String get requiredField => '*vereist';

  @override
  String get reset => 'Opnieuw instellen';

  @override
  String get resetCommentPreferences => 'Opmerkings­voorkeuren resetten';

  @override
  String get resetPostPreferences => 'Bericht­voorkeuren resetten';

  @override
  String get resetPreferences => 'Voorkeuren resetten';

  @override
  String get resetPreferencesAndData => 'Voorkeuren en gegevens resetten';

  @override
  String get restore => 'Herstellen';

  @override
  String get restoreComment => 'Opmerking herstellen';

  @override
  String get restorePost => 'Bericht herstellen';

  @override
  String get restoredComment => 'Opmerking hersteld';

  @override
  String get restoredCommentFromDraft => 'Opmerking hersteld uit concept';

  @override
  String get restoredCommunity => 'Gemeenschap hersteld';

  @override
  String get restoredPost => 'Bericht hersteld';

  @override
  String get restoredPostFromDraft => 'Bericht hersteld uit concept';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get rightLongSwipe => 'Lange veeg naar rechts';

  @override
  String get rightShortSwipe => 'Korte veeg naar rechts';

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
  String get scrapeMissingLinkPreviews =>
      'Ontbrekende koppelingsvoorvertoningen ophalen';

  @override
  String get screenReaderProfile => 'Schermlezerprofiel';

  @override
  String get screenReaderProfileDescription =>
      'Optimaliseert Thunder voor schermlezers door het aantal elementen te verminderen en mogelijk conflicterende gebaren te verwĳderen.';

  @override
  String get search => 'Zoeken';

  @override
  String get searchByText => 'Zoeken op tekst';

  @override
  String get searchByUrl => 'Zoeken op URL';

  @override
  String get searchComments => 'Opmerkingen zoeken';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return 'Zoeken naar opmerkingen gefedereerd met $instance';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return 'Zoeken naar gemeenschappen gefedereerd met $instance';
  }

  @override
  String searchInstance(Object instance) {
    return '$instance doorzoeken';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return 'Zoeken naar instanties die gefedereerd zĳn met $instance';
  }

  @override
  String get searchPostSearchType => 'Selecteer zoektype voor berichten';

  @override
  String searchPostsFederatedWith(Object instance) {
    return 'Zoeken naar berichten die gefedereerd zĳn met $instance';
  }

  @override
  String get searchTerm => 'Zoek­term';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Zoeken naar gebruikers die gefedereerd zĳn met $instance';
  }

  @override
  String get selectAccountToCommentAs =>
      'Selecteer account om opmerking mee te plaatsen';

  @override
  String get selectAccountToPostAs =>
      'Selecteer account om bericht mee te plaatsen';

  @override
  String get selectAll => 'Alles selecteren';

  @override
  String get selectCommunity => 'Selecteer een gemeen­schap (vereist)';

  @override
  String get selectFeedType => 'Feed­type selecteren';

  @override
  String get selectLanguage => 'Taal selecteren';

  @override
  String get selectRecipient => 'Select recipient';

  @override
  String get selectSearchType => 'Selecteer zoektype';

  @override
  String get selectText => 'Tekst selecteren';

  @override
  String get send => 'Send';

  @override
  String get sendBackgroundTestLocalNotification =>
      'Lokale test­melding op achter­grond verzenden';

  @override
  String get sendBackgroundTestUnifiedPushNotification =>
      'UnifiedPush-test­melding op achter­grond verzenden';

  @override
  String get sendTestLocalNotification => 'Lokale test­melding verzenden';

  @override
  String get sendTestUnifiedPushNotification =>
      'UnifiedPush-test­melding verzenden';

  @override
  String get sensitiveContentWarning =>
      'Kan gevoelige inhoud bevatten. Druk om weer te geven.';

  @override
  String get sentRequestForTestNotification =>
      'Verzoek voor testmelding verzonden.';

  @override
  String serverErrorComments(Object message) {
    return 'Er is een serverfout opgetreden bĳ het ophalen van meer opmerkingen: $message';
  }

  @override
  String get setAction => 'Actie instellen';

  @override
  String get setLongPress => 'Instellen als actie voor lang indrukken';

  @override
  String get setShortPress => 'Instellen als actie voor één keer drukken';

  @override
  String get settingOverrideLabel =>
      'Deze instellingen over­schrĳven de standaard­instellingen van Thunder.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'Instellingen van het type $settingType worden nog niet ondersteund.';
  }

  @override
  String get settings => 'Instellingen';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'Instellingen zĳn succesvol opgeslagen naar \'$savedFilePath\'';
  }

  @override
  String get settingsFeedCards =>
      'Deze instellingen gelden voor de kaarten in de hoofd­feed. Acties zijn altĳd beschikbaar wanneer u daad­werkelĳk berichten opent.';

  @override
  String get settingsImportedSuccessfully =>
      'Instellingen zĳn succesvol geïmporteerd!';

  @override
  String get settingsNotExportedSuccessfully =>
      'Instellingen zĳn niet succesvol opgeslagen of de bewerking is geannuleerd.';

  @override
  String get settingsNotImportedSuccessfully =>
      'Instellingen zĳn niet succesvol geïmporteerd of de bewerking is geannuleerd.';

  @override
  String get settingsPage => 'Instellingen­pagina';

  @override
  String get settingsPageAbout => 'Over';

  @override
  String get settingsPageAccessibility => 'Toegankelĳkheid';

  @override
  String get settingsPageAccount => 'Account';

  @override
  String get settingsPageAccountBlocks => 'Blokkerings­lĳsten';

  @override
  String get settingsPageAccountLanguages => 'Discussie­talen';

  @override
  String get settingsPageAccountMedia => 'Media beheren';

  @override
  String get settingsPageAppearance => 'Uiterlĳk';

  @override
  String get settingsPageAppearanceComments => 'Opmerkingen';

  @override
  String get settingsPageAppearancePosts => 'Berichten';

  @override
  String get settingsPageAppearanceTheming => 'Thema\'s';

  @override
  String get settingsPageDebug => 'Fout­opsporing';

  @override
  String get settingsPageFilters => 'Filters';

  @override
  String get settingsPageFloatingActionButton => 'Zwevende actie­knop';

  @override
  String get settingsPageGeneral => 'Algemeen';

  @override
  String get settingsPageGestures => 'Gebaren';

  @override
  String get settingsPageUserLabels => 'Gebruikers­labels';

  @override
  String get settingsPageVideo => 'Video';

  @override
  String get share => 'Delen';

  @override
  String get shareComment => 'Opmerkings­koppeling delen';

  @override
  String get shareCommentLocal => 'Opmerkings­koppeling delen (mĳn instantie)';

  @override
  String get shareCommunity => 'Gemeenschap delen';

  @override
  String get shareCommunityLink => 'Gemeenschaps­koppeling delen';

  @override
  String get shareCommunityLinkLocal =>
      'Gemeenschaps­koppeling delen (mĳn instantie)';

  @override
  String get shareImage => 'Afbeelding delen';

  @override
  String get shareLemmyLink => 'Lemmy-koppeling delen';

  @override
  String get shareLink => 'Externe koppeling delen';

  @override
  String get shareMedia => 'Media delen';

  @override
  String get shareMediaLink => 'Media­koppeling delen';

  @override
  String get shareOriginalLink => 'Originele koppeling delen';

  @override
  String get sharePost => 'Bericht­koppeling delen';

  @override
  String get sharePostLocal => 'Bericht­koppeling delen (mĳn instantie)';

  @override
  String get shareThumbnail => 'Miniatuur delen';

  @override
  String get shareThumbnailAsImage => 'Miniatuur delen als afbeelding';

  @override
  String get shareUser => 'Gebruiker delen';

  @override
  String get shareUserLink => 'Gebruikers­koppeling delen';

  @override
  String get shareUserLinkLocal => 'Gebruikers­koppeling delen (mĳn instantie)';

  @override
  String get showAll => 'Alles tonen';

  @override
  String get showBotAccounts => 'Bot-accounts tonen';

  @override
  String get showCommentActionButtons => 'Actie­knoppen voor opmerkingen tonen';

  @override
  String get showCommunityDisplayNames =>
      'Weergave­namen van gemeenschappen tonen';

  @override
  String get showCrossPosts => 'Kruis­berichten tonen';

  @override
  String get showEdgeToEdgeImages => 'Afbeeldingen van rand tot rand tonen';

  @override
  String get showExpandedTaglines => 'Uitgebreide tag­regels weergeven';

  @override
  String get showFullDate => 'Volledige datum tonen';

  @override
  String get showFullDateDescription => 'Volledige datum tonen op berichten';

  @override
  String get showFullHeightImages => 'Afbeeldingen op volledige hoogte tonen';

  @override
  String get showHiddenPosts => 'Verborgen berichten tonen';

  @override
  String get showInAppUpdateNotifications =>
      'Meldingen ontvangen van nieuwe GitHub-releases';

  @override
  String get showLess => 'Minder tonen';

  @override
  String get showMore => 'Meer tonen';

  @override
  String get showNavigationLabels => 'Navigatie­labels tonen';

  @override
  String get showNavigationLabelsDescription =>
      'Of labels onder de onderste navigatie­knoppen moeten worden weergegeven';

  @override
  String get showNsfwContent => 'NSFW-inhoud tonen';

  @override
  String get showOwnContent => 'Eigen inhoud tonen';

  @override
  String get showPassword => 'Wacht­woord tonen';

  @override
  String get showPostAuthor => 'Bericht­auteur tonen';

  @override
  String get showPostAuthorSubtitle =>
      'Bericht­auteur wordt altĳd getoond in gemeenschaps­feeds';

  @override
  String get showPostCommunityFirst => 'Show Community and Author First';

  @override
  String get showPostCommunityIcons => 'Gemeenschaps­pictogrammen tonen';

  @override
  String get showPostSaveAction => 'Opslaan-knop tonen';

  @override
  String get showPostTextContentPreview => 'Tekst­voorvertoning tonen';

  @override
  String get showPostTitleFirst => 'Titel bovenaan tonen';

  @override
  String get showPostVoteActions => 'Stem­knoppen tonen';

  @override
  String get showReadPosts => 'Gelezen berichten tonen';

  @override
  String get showSavedContent => 'Opgeslagen inhoud tonen';

  @override
  String get showScoreCounters => 'Gebruikers­scores tonen';

  @override
  String get showScores => 'Scores van berichten en opmerkingen tonen';

  @override
  String get showTextPostIndicator => 'Tekstbericht­indicator tonen';

  @override
  String get showThumbnailPreviewOnRight => 'Miniaturen rechts tonen';

  @override
  String get showUnreadOnly => 'Enkel ongelezen items tonen';

  @override
  String get showUpdateChangelogs => 'Wĳzigings­logboek tonen bij updates';

  @override
  String get showUpdateChangelogsSubtitle =>
      'Een lĳst met wĳzigingen weergeven na een update';

  @override
  String get showUserAvatar => 'Gebruikers­avatar tonen';

  @override
  String get showUserDisplayNames => 'Weergave­namen van gebruikers tonen';

  @override
  String get showUserInstance => 'Gebruikers­instantie tonen';

  @override
  String get sidebar => 'Zĳbalk';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Dubbeltik op onderbalk om zĳbalk te openen';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Veeg over onderbalk om zĳbalk te openen';

  @override
  String get small => 'Klein';

  @override
  String get somethingWentWrong => 'Oeps, er is iets misgegaan!';

  @override
  String get sortBy => 'Sorteren op';

  @override
  String get sortByTop => 'Sorteren op beste';

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
  String get subscribeToCommunity => 'Abonneren op gemeen­schap';

  @override
  String get subscribed => 'Geabonneerd';

  @override
  String get subscriptionRequestSent => 'Abonnements­aanvraag verzonden';

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
    return 'Overgeschakeld naar $username';
  }

  @override
  String get system => 'Systeem';

  @override
  String get systemDarkMode => 'Puur zwart';

  @override
  String get systemDarkModeDescription =>
      'Puur zwart thema inschakelen voor donkere modus';

  @override
  String get tabletMode => 'Tablet­modus (2-koloms­weergave)';

  @override
  String get tapToExit => 'Ga nogmaals terug om af te sluiten';

  @override
  String get tappableAuthorCommunity => 'Tikbare auteurs en gemeen­schappen';

  @override
  String get teal => 'Blauw­groen';

  @override
  String get testBackgroundNotificationDescription =>
      'Thunder sluit zichzelf af en probeert vervolgens een melding op de achter­grond te genereren. (Dit duurt minimaal 15 minuten)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'Thunder vraagt de meldings­server een vertraagde melding te verzenden en sluit zichzelf vervolgens af. (Dit kan enkele minuten duren)';

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
    return 'Thunder is bĳgewerkt naar $version!';
  }

  @override
  String thunderNotificationServer(Object server) {
    return 'Thunder-meldingsserver: $server';
  }

  @override
  String get timeoutComments => 'Fout: time-out bĳ het ophalen van opmerkingen';

  @override
  String get timeoutErrorMessage =>
      'Er is een time-out opgetreden bĳ het wachten op een reactie.';

  @override
  String get timeoutSaveComment =>
      'Fout: time-out bĳ het opslaan van een opmerking';

  @override
  String get timeoutSavingPost => 'Fout: time-out bĳ het opslaan van bericht.';

  @override
  String get timeoutUpvoteComment =>
      'Fout: time-out bĳ het stemmen op opmerking';

  @override
  String get timeoutVotingPost => 'Fout: time-out bĳ het stemmen op bericht.';

  @override
  String get toggelRead => 'Gelezen omschakelen';

  @override
  String get top => 'Beste';

  @override
  String get topAll => 'Beste aller tĳden';

  @override
  String get topDay => 'Beste vandaag';

  @override
  String get topHour => 'Beste afgelopen uur';

  @override
  String get topMonth => 'Beste afgelopen maand';

  @override
  String get topNineMonths => 'Beste afgelopen 9 maanden';

  @override
  String get topSixHour => 'Beste afgelopen 6 uur';

  @override
  String get topSixMonths => 'Beste afgelopen 6 maanden';

  @override
  String get topThreeMonths => 'Beste afgelopen 3 maanden';

  @override
  String get topTwelveHour => 'Beste afgelopen 12 uur';

  @override
  String get topWeek => 'Beste afgelopen week';

  @override
  String get topYear => 'Beste afgelopen jaar';

  @override
  String totalComments(Object x) {
    return '$x opmerkingen';
  }

  @override
  String totalPosts(Object x) {
    return '$x berichten';
  }

  @override
  String get totp => 'TOTP (optioneel)';

  @override
  String get transferredModToCommunity => 'Gemeen­schap over­gedragen';

  @override
  String get translationsMayNotBeComplete =>
      'Houd er rekening mee dat de vertalingen mogelijk niet volledig zĳn';

  @override
  String get trendingCommunities => 'Trending gemeen­schappen';

  @override
  String get trySearchingFor => 'Probeer te zoeken op…';

  @override
  String get unableToFindCommunity => 'Kan gemeenschap niet vinden';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'Kan gemeenschap \'$communityName\' niet vinden';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Kan de geselecteerde gemeenschap niet vinden op de instantie van de geselecteerde gebruiker.';

  @override
  String get unableToFindInstance => 'Kan instantie niet vinden';

  @override
  String get unableToFindLanguage => 'Kan taal niet vinden';

  @override
  String get unableToFindPost => 'Kan bericht niet vinden';

  @override
  String get unableToFindUser => 'Kan gebruiker niet vinden';

  @override
  String unableToFindUserName(Object username) {
    return 'Kan gebruiker \'$username\' niet vinden';
  }

  @override
  String get unableToLoadImage => 'Kan afbeelding niet laden';

  @override
  String unableToLoadImageFrom(Object domain) {
    return 'Kan afbeelding niet laden van $domain';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return 'Kan $instance niet laden';
  }

  @override
  String get unableToLoadPost => 'Kan bericht niet laden';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return 'Kan berichten niet laden van $instance';
  }

  @override
  String get unableToLoadReplies => 'Kan niet meer reacties laden.';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return 'Kan niet navigeren naar $instanceHost. Het is mogelĳk geen geldige Lemmy-instantie.';
  }

  @override
  String get unableToResolveReport => 'Kan rapportage niet oplossen';

  @override
  String unableToRetrieveChangelog(Object version) {
    return 'Kan wĳzigingslogboek voor versie $version niet ophalen.';
  }

  @override
  String get unbanFromCommunity => 'Verbanning uit gemeenschap opheffen';

  @override
  String get unbannedUser => 'Verbanning van gebruiker opgeheven';

  @override
  String unbannedUserFromCommunity(Object username) {
    return 'Verbanning van $username uit gemeenschap opgeheven';
  }

  @override
  String get unblock => 'Deblokkeren';

  @override
  String get unblockCommunity => 'Blokkering van gemeen­schap opheffen';

  @override
  String get unblockCommunityInstance =>
      'Blokkering van gemeenschaps­instantie opheffen';

  @override
  String get unblockInstance => 'Blokkering van instantie opheffen';

  @override
  String get unblockUser => 'Blokkering van gebruiker opheffen';

  @override
  String get unblockUserInstance =>
      'Blokkering van gebruikers­instantie opheffen';

  @override
  String get understandEnable => 'Ik begrĳp het, inschakelen';

  @override
  String get unexpectedError => 'Onverwachte fout';

  @override
  String get unfavorite => 'Verwijderen uit favorieten';

  @override
  String get unfeaturedPost => 'Bericht niet langer uitgelicht';

  @override
  String get unhidCommunity => 'Gemeenschap niet langer verborgen';

  @override
  String get unhide => 'Verbergen herstellen';

  @override
  String unifiedPushDistributorApp(Object app, Object count) {
    return 'UnifiedPush-distributor-app: $app ($count beschikbaar)';
  }

  @override
  String get unifiedPushNotifications => 'UnifiedPush-meldingen';

  @override
  String unifiedPushServer(Object server) {
    return 'UnifiedPush-server: $server';
  }

  @override
  String get unifiedpush => 'UnifiedPush';

  @override
  String get unlockPost => 'Bericht ontgrendelen';

  @override
  String get unlockedPost => 'Bericht ontgrendeld';

  @override
  String get unpinFromCommunity => 'Losmaken uit gemeenschap';

  @override
  String get unpinPostFromCommunity => 'Bericht losmaken uit gemeenschap';

  @override
  String get unpinnedPostFromCommunity => 'Bericht losgemaakt uit gemeenschap';

  @override
  String get unreachable => 'Onbereikbaar';

  @override
  String get unresolved => 'Onopgelost';

  @override
  String get unsubscribe => 'Uitschrĳven';

  @override
  String get unsubscribeFromCommunity => 'Uitschrĳven uit gemeenschap';

  @override
  String get unsubscribePending => 'Uitschrĳven (abonnement in behandeling)';

  @override
  String get unsubscribed => 'Uitgeschreven';

  @override
  String get untitledCommentDraft => 'Untitled comment draft';

  @override
  String get untitledPostDraft => 'Untitled post draft';

  @override
  String updateReleased(Object version) {
    return 'Update uitgebracht: $version';
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
      'Dit type koppeling wordt momenteel niet ondersteund.';

  @override
  String get url => 'URL';

  @override
  String get useAdvancedShareSheet => 'Geavanceerde deel­opties gebruiken';

  @override
  String get useApplePushNotifications => 'APNs-meldingen gebruiken';

  @override
  String get useApplePushNotificationsDescription =>
      'Maakt gebruik van Apple\'s pushmeldingsdienst';

  @override
  String get useCompactView =>
      'Inschakelen voor kleine berichten, uitschakelen voor grote.';

  @override
  String get useLocalNotifications =>
      'Lokale meldingen gebruiken (experimenteel)';

  @override
  String get useLocalNotificationsDescription =>
      'Controleert periodiek op meldingen op de achtergrond';

  @override
  String get useMaterialYouTheme => 'Material You-thema gebruiken';

  @override
  String get useMaterialYouThemeDescription =>
      'Over­schrĳft het geselecteerde aangepaste thema';

  @override
  String get useProfilePictureForDrawer => 'Profiel­foto gebruiken voor zĳbalk';

  @override
  String get useProfilePictureForDrawerSubtitle =>
      'Toont de profiel­afbeelding van de gebruiker in plaats van het menu-pictogram wanneer u bent ingelogd';

  @override
  String useSuggestedTitle(Object title) {
    return 'Voorgestelde titel gebruiken: $title';
  }

  @override
  String get useUnifiedPushNotifications => 'UnifiedPush-meldingen gebruiken';

  @override
  String get useUnifiedPushNotificationsDescription =>
      'Vereist een compatibele app';

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
  String get userLabelHint => 'Dit is mĳn favoriete gebruiker';

  @override
  String get userLabels => 'Gebruikers­labels';

  @override
  String get userLabelsSettingsPageDescription =>
      'U kunt labels toevoegen, wĳzigen of verwĳderen die aan gebruikers zĳn gekoppeld.';

  @override
  String get userNameColor => 'Kleur van gebruikers­naam';

  @override
  String get userNameThickness => 'Dikte van gebruikers­naam';

  @override
  String get userNotLoggedIn => 'Gebruiker is niet ingelogd';

  @override
  String get userProfiles => 'Gebruikers­profielen';

  @override
  String get userSettingDescription =>
      'Deze instellingen worden gesynchroniseerd met uw Lemmy-account en worden per account toegepast.';

  @override
  String get userStyle => 'Gebruikers­stĳl';

  @override
  String get username => 'Gebruikers­naam';

  @override
  String get usernameFormattingRedirect =>
      'Op zoek naar gebruikersnaam­opmaak?';

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
  String get videoDefaultPlaybackSpeed => 'Standaard­afspeelsnelheid';

  @override
  String get videoLinkHandlingExternal =>
      'Video\'s afspelen met een externe app';

  @override
  String get videoPlayerInApp => 'Ingebouwde speler van Thunder gebruiken';

  @override
  String get videoPlayerMode => 'Speler­modus';

  @override
  String get viewAll => 'Alles bekĳken';

  @override
  String get viewAllComments => 'Alle opmerkingen tonen';

  @override
  String get viewCommentSource => 'Opmerkings­bron tonen';

  @override
  String get viewModlog => 'Moderator­logboek bekĳken';

  @override
  String get viewOriginal => 'Origineel bekĳken';

  @override
  String get viewPostAsDifferentAccount => 'Bericht bekĳken als ander account';

  @override
  String get viewPostSource => 'Bericht­bron bekĳken';

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
  String get visitCommunityInstance => 'Gemeenschaps­instantie bezoeken';

  @override
  String get visitInstance => 'Instantie bezoeken';

  @override
  String get visitUserInstance => 'Gebruikers­instantie bezoeken';

  @override
  String get visitUserProfile => 'Gebruikers­profiel bezoeken';

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
      other: '$x jaar oud',
    );
    return '$_temp0';
  }

  @override
  String get yes => 'Ja';

  @override
  String get youMustSelectAJsonFile => 'U moet een .json-bestand selecteren.';
}
