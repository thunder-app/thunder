// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get about => 'Info';

  @override
  String get accept => 'Accetta';

  @override
  String get accessibility => 'Accessibilità';

  @override
  String get accessibilityProfilesDescription =>
      'I profili di accessibilità consentono di applicare più impostazioni contemporaneamente per soddisfare un requisito di accessibilità specifico.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Account',
      one: 'Account',
      zero: 'Account',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'Compleanno Account $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'Le impostazioni del tuo account sovrascrivono le seguenti impostazioni';

  @override
  String get accountSettings => 'Impostazioni Account';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'Impostazioni dell\'account Lemmy esportate correttamente in $savedFilePath!';
  }

  @override
  String get accountSettingsImportedSuccessfully =>
      'Impostazioni dell\'account Lemmy esportate correttamente!';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return 'Commento selezionato non trovato su \'$instance\'. Ritorno all\'account precedente.';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'Post selezionato non trovato su \'$instance\'. Ritorno all\'account precedente.';
  }

  @override
  String get actionColors => 'Colori Azione';

  @override
  String get actionColorsRedirect => 'Vuoi personalizzare i colori?';

  @override
  String get actions => 'Azioni';

  @override
  String get active => 'Attivi';

  @override
  String get activity => 'Activity';

  @override
  String get add => 'Aggiungi';

  @override
  String get addAccount => 'Aggiungi Account';

  @override
  String get addAccountToSeeProfile => 'Accedi per vedere il tuo account.';

  @override
  String get addAnonymousInstance => 'Aggiungi Istanza Anonima';

  @override
  String get addAsCommunityModerator => 'Aggiungi come Community Moderator';

  @override
  String get addDiscussionLanguage => 'Aggiungi Lingua';

  @override
  String get addKeywordFilter => 'Aggiungi Keyword';

  @override
  String get addOriginalPostBody => 'Add original post body?';

  @override
  String get addToFavorites => 'Aggiungi ai preferiti';

  @override
  String get addUserLabel => 'Aggiungi Etichetta Utente';

  @override
  String get addedCommunityToSubscriptions =>
      'Comunità aggiunta alle iscrizioni';

  @override
  String get addedInstanceMod => 'Aggiunto Mod Istanza';

  @override
  String get addedModToCommunity => 'Aggiunto Mod Comunità';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return 'Added $username as community moderator';
  }

  @override
  String get admin => 'Admin';

  @override
  String get advanced => 'Avanzate';

  @override
  String ago(Object time) {
    return '$time fa';
  }

  @override
  String get all => 'Tutto';

  @override
  String get allPosts => 'Tutti i Post';

  @override
  String get allowOpenSupportedLinks =>
      'Permetti a questa app di aprire i link supportati.';

  @override
  String get alreadyPostedTo => 'Già pubblicato su';

  @override
  String get altText => 'Alt Text';

  @override
  String get alternateSources => 'Fonti Alternative';

  @override
  String get always => 'Sempre';

  @override
  String andXMore(Object count) {
    return 'e $count in più';
  }

  @override
  String get animations => 'Animazioni';

  @override
  String get anonymous => 'Anonimo';

  @override
  String get anonymousInstances => 'Istanze Anonime';

  @override
  String get appLanguage => 'Lingua App';

  @override
  String get appearance => 'Aspetto';

  @override
  String get applePushNotificationService => 'Servizio Notifiche Push Apple';

  @override
  String get applied => 'Applicato';

  @override
  String get apply => 'Applica';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return 'Notifiche permesse dal sistema: $yesOrNo';
  }

  @override
  String averageComments(Object x) {
    return '$x commenti/mese';
  }

  @override
  String averageContributions(Object x) {
    return '$x contributi/mese';
  }

  @override
  String averagePosts(Object x) {
    return '$x post/mese';
  }

  @override
  String get back => 'Indietro';

  @override
  String get backButton => 'Pulsante \'indietro\'';

  @override
  String get backToTop => 'Ritorna all\'Inizio';

  @override
  String get backgroundCheckWarning =>
      'Nota che il controllo notifiche consuma batteria aggiuntiva';

  @override
  String get ban => 'Ban';

  @override
  String get banFromCommunity => 'Banna dalla Comunità';

  @override
  String get bannedUser => 'Utente Bannato';

  @override
  String get bannedUserFromCommunity => 'Utente Bannato dalla Comunità';

  @override
  String get base => 'Base';

  @override
  String get block => 'Block';

  @override
  String get blockCommunity => 'Blocca Comunità';

  @override
  String get blockCommunityInstance => 'Blocca Istanza da Comunità';

  @override
  String get blockInstance => 'Blocca Istanza';

  @override
  String get blockManagement => 'Gestione Blocchi';

  @override
  String get blockSettingLabel => 'Blocchi Utente/Comunità/Istanza';

  @override
  String get blockUser => 'Blocca Utente';

  @override
  String get blockUserInstance => 'Blocca Istanza di Utente';

  @override
  String get blockedCommunities => 'Comunità Bloccate';

  @override
  String get blockedInstances => 'Istanze Bloccate';

  @override
  String get blockedUsers => 'Utenti Bloccati';

  @override
  String get blue => 'Blu';

  @override
  String get bold => 'Grassetto';

  @override
  String get boldCommunityName => 'Grassetto Nome Comunità';

  @override
  String get boldInstanceName => 'Grassetto Nome Istanza';

  @override
  String get boldUserName => 'Grassetto Nome Utente';

  @override
  String get bot => 'Bot';

  @override
  String get browserMode => 'Gestione link';

  @override
  String browsingAnonymously(Object instance) {
    return 'Al momento stai navigando $instance in maniera anonima.';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get cannotReportOwnComment => 'Non puoi segnalare il tuo commento.';

  @override
  String get cantBlockAdmin =>
      'Non è permesso bloccare un amministratore di un\'istanza.';

  @override
  String get cantBlockYourself => 'Non puoi bloccare te stesso.';

  @override
  String get cardPostCardMetadataItems => 'Card View Metadati';

  @override
  String get cardView => 'Card View';

  @override
  String get cardViewDescription => 'Abilita regolazioni per card view';

  @override
  String get cardViewSettings => 'Impostazioni Card View';

  @override
  String get changeAccountSettingsFor => 'Cambia impostazioni account per';

  @override
  String get changeNotificationSettings => 'Cambia impostazioni notifica...';

  @override
  String get changePassword => 'Cambia Password';

  @override
  String get changePasswordWarning =>
      'Per cambiare password, si reindirizza al sito della tua istanza.\n\nContinuare?';

  @override
  String get changeSort => 'Cambia Ordine';

  @override
  String clearCache(Object cacheSize) {
    return 'Pulizia Cache ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Pulizia Cache';

  @override
  String get clearDatabase => 'Pulizia Database';

  @override
  String get clearPreferences => 'Pulizia Preferenze';

  @override
  String get clearSearch => 'Elimina Ricerca';

  @override
  String get clearedCache => 'Cache pulite correttamente.';

  @override
  String get clearedDatabase =>
      'Database locale svuotato. Riavvia Thunder per applicare i cambiamenti.';

  @override
  String get clearedUserPreferences =>
      'Rimosse tutte le preferenze dell\'utente';

  @override
  String get close => 'Chiudi';

  @override
  String get collapse => 'Collassa';

  @override
  String get collapseCommentPreview => 'Collassa Anteprima Commento';

  @override
  String get collapseInformation => 'Collassa Informazione';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Nascondi Commento Genitore quando Ridotto';

  @override
  String get collapsePost => 'Riduci post';

  @override
  String get collapsePostPreview => 'Collassa Anteprima Post';

  @override
  String get collapseSpoiler => 'Collassa Spoiler';

  @override
  String get color => 'Colore';

  @override
  String get colorizeCommunityName => 'Colora Nome Comunità';

  @override
  String get colorizeInstanceName => 'Colora Nome Istanza';

  @override
  String get colorizeUserName => 'Colora Nome Utente';

  @override
  String get colors => 'Colori';

  @override
  String get combineCommentScores => 'Combina Punteggi Commento';

  @override
  String get combineCommentScoresLabel => 'Combina Punteggi Commento';

  @override
  String get combineNavAndFab =>
      'Il pulsante flessibile delle azioni è disponibile tra i pulsanti di navigazione.';

  @override
  String get combineNavAndFabDescription =>
      'Il Pulsante di Azione Galleggiante verrà mostrato tra i pulsanti di navigazione.';

  @override
  String get comfortable => 'Confortevole';

  @override
  String get comment => 'Commento';

  @override
  String get commentActions => 'Comment Actions';

  @override
  String get commentBehaviourSettings => 'Commenti';

  @override
  String get commentFontScale => 'Dimensione Font Contenuto Commento';

  @override
  String get commentPreview =>
      'Mostra un\'anteprima dei commenti con le impostazioni date';

  @override
  String get commentReported =>
      'Il commento è stato segnalato per un controllo.';

  @override
  String get commentSavedAsDraft => 'Commento salvato come bozza';

  @override
  String get commentShowUserAvatar => 'Mostra Avatar Utente';

  @override
  String get commentShowUserInstance => 'Mostra Istanza Utente';

  @override
  String get commentSortType => 'Tipo di Organizzazione dei Commenti';

  @override
  String get commentSwipeActions => 'Azione Swipe su Commento';

  @override
  String get commentSwipeGesturesHint =>
      'Preferisci usare i pulsanti? Abilitali nella sezione \'commenti\' delle impostazioni generali.';

  @override
  String get comments => 'Commenti';

  @override
  String get communities => 'Comunità';

  @override
  String get community => 'Comunità';

  @override
  String get communityActions => 'Azioni Comunità';

  @override
  String communityEntry(Object community) {
    return 'Comunità \'$community\'';
  }

  @override
  String get communityFormat => 'Formato Comunità';

  @override
  String get communityNameColor => 'Colore Nome Comunità';

  @override
  String get communityNameThickness => 'Spessore Nome Comunità';

  @override
  String get communityStyle => 'Stile Comunità';

  @override
  String get compact => 'Compatto';

  @override
  String get compactPostCardMetadataItems => 'Compact View Metadati';

  @override
  String get compactView => 'Compact View';

  @override
  String get compactViewDescription => 'Abilità compact view per impostare';

  @override
  String get compactViewSettings => 'Impostazioni Compact View';

  @override
  String get condensed => 'Condensato';

  @override
  String get confirm => 'Conferma';

  @override
  String get confirmLogOutBody => 'Fare il log out?';

  @override
  String get confirmLogOutTitle => 'Log Out?';

  @override
  String get confirmMarkAllAsReadBody => 'Segnare tutti i messaggi come letti?';

  @override
  String get confirmMarkAllAsReadTitle => 'Segnare tutto come letto?';

  @override
  String get confirmResetCommentPreferences =>
      'Questo resetterà tutte le preferenze dei commenti. Confermare?';

  @override
  String get confirmResetPostPreferences =>
      'Questo resetterà tutte le preferenze dei post. Confermare?';

  @override
  String get confirmUnsubscription => 'Ti vuoi disiscrivere?';

  @override
  String connectedToUnifiedPushDistributorApp(Object app) {
    return 'Connesso a $app';
  }

  @override
  String get contentManagement => 'Gestione Contenuti';

  @override
  String get contentWarning => 'Avviso Contenuti';

  @override
  String get controversial => 'Controversi';

  @override
  String get copiedToClipboard => 'Copiato in memoria';

  @override
  String get copy => 'Copia';

  @override
  String get copyComment => 'Copia Commento';

  @override
  String get copySelected => 'Copia selezione';

  @override
  String get copyText => 'Copia Testo';

  @override
  String get couldNotDetermineCommentDelete =>
      'È stato impossibile determinare il post da dove eliminare il commento.';

  @override
  String get couldNotDeterminePostComment =>
      'È stato impossibile determinare il post nel cui lasciare il commento.';

  @override
  String get couldntCreateReport =>
      'Non è stato possibile inoltrare la tua segnalazione. Riprova più tardi per favore';

  @override
  String get couldntFindPost =>
      'Impossibile caricare il post richiesto. Potrebbe essere stato cancellato o rimosso.';

  @override
  String countComments(Object count) {
    return '$count Commenti';
  }

  @override
  String countLocalSubscribers(Object count) {
    return '$count Iscritti Locali';
  }

  @override
  String countPosts(Object count) {
    return '$count Post';
  }

  @override
  String countSubscribers(Object count) {
    return '$count iscritti';
  }

  @override
  String countUsers(Object count) {
    return '$count utenti';
  }

  @override
  String countUsersActiveDay(Object count) {
    return '$count utenti/giorno';
  }

  @override
  String countUsersActiveHalfYear(Object count) {
    return '$count utenti/6 mesi';
  }

  @override
  String countUsersActiveMonth(Object count) {
    return '$count utenti/mesi';
  }

  @override
  String countUsersActiveWeek(Object count) {
    return '$count utenti/sett';
  }

  @override
  String get createAccount => 'Crea Account';

  @override
  String get createComment => 'Crea Commento';

  @override
  String get createNewCrossPost => 'Crea nuovo post incrociato';

  @override
  String get createPost => 'Crea Post';

  @override
  String created(Object date) {
    return 'Creato $date';
  }

  @override
  String get createdToday => 'Creato Oggi';

  @override
  String get creator => 'Creator';

  @override
  String crossPostedFrom(Object postUrl) {
    return 'crosspost da:  $postUrl';
  }

  @override
  String get crossPostedTo => 'Precedentemente pubblicato in';

  @override
  String get currentLongPress => 'Attualmente impostata come premuta lunga';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Modalità notifiche attuale: $mode';
  }

  @override
  String get currentSinglePress => 'Attualmente impostata come premuta breve';

  @override
  String get customizeSwipeActions =>
      'Personalizza azioni di scorrimento sullo schermo (seleziona per modificare)';

  @override
  String get dangerZone => 'Zona Pericolosa';

  @override
  String get dark => 'Scuro';

  @override
  String get databaseExportWarning =>
      'Il database può contenere informazioni sensibili sul tuo account Lemmy. Se lo esporti, non condividerlo con nessuno. Vuoi procedere?';

  @override
  String databaseExportedSuccessfully(Object savedFilePath) {
    return 'Database esportato con successo in \'$savedFilePath\'';
  }

  @override
  String get databaseImportedSuccessfully =>
      'Database importato correttamente!';

  @override
  String get databaseNotExportedSuccessfully =>
      'Il database non è stato esportato correttamente o l\'operazione è stata cancellata.';

  @override
  String get databaseNotImportedSuccessfully =>
      'Il database non è stato importato correttamente o l\'operazione è stata cancellata.';

  @override
  String get dateFormat => 'Formato Data';

  @override
  String get debug => 'Debug';

  @override
  String get debugDescription =>
      'Le seguenti impostazioni di debug devono essere utilizzate solo per la risoluzione dei problemi.';

  @override
  String get debugNotificationsDescription =>
      'Per risolvere i problemi relativi alle notifiche, utilizzare le seguenti opzioni.';

  @override
  String get decline => 'Declina';

  @override
  String get defaultColor => 'Predefinito';

  @override
  String get defaultCommentSortType => 'Tipo Ordinamento Commenti Predefinito';

  @override
  String get defaultFeedSortType => 'Tipo Ordinamento Feed Predefinito';

  @override
  String get defaultFeedType => 'Ordinamento Feed Predefinito';

  @override
  String get delete => 'Elimina';

  @override
  String get deleteAccount => 'Cancella Account';

  @override
  String get deleteAccountDescription =>
      'Per cancellare permanentemente il tuo account, si verrà reindirizzati al sito della tua istanza. \n\nContinuare?';

  @override
  String get deleteComment => 'Cancella Commento';

  @override
  String get deleteImageConfirmMessage => 'Cancellare questa immagine?';

  @override
  String get deleteImageConfirmTitle => 'Cancella?';

  @override
  String get deleteLocalDatabase => 'Cancella Database Locale';

  @override
  String get deleteLocalDatabaseDescription =>
      'Questa azione rimuoverà il database locale e disconnetterà i tuoi account.\n\nContinuare?';

  @override
  String get deleteLocalPreferences => 'Cancella Preferenze Locali';

  @override
  String get deleteLocalPreferencesDescription =>
      'Questo cancellerà le tue impostazioni e preferenze di Thunder.\n\nContinuare?';

  @override
  String get deletePost => 'Cancella Post';

  @override
  String get deleteUserLabelConfirmation => 'Cancellare l’etichetta?';

  @override
  String get deleted => 'Deleted';

  @override
  String get deletedByCreator => 'rimosso dall\'autore';

  @override
  String get deletedByModerator => 'rimosso da moderatore';

  @override
  String get deletedComment => 'Deleted comment';

  @override
  String get deletedPost => 'Deleted post';

  @override
  String get deselectUndeterminedWarning =>
      'Se deselezioni, non vedrai la maggior parte dei contenuti.';

  @override
  String detailedReason(Object reason) {
    return 'Motivo: $reason';
  }

  @override
  String get dimReadPosts => 'Sbiadisci Post Letti';

  @override
  String get disable => 'Disabilita';

  @override
  String get disablePushNotifications => 'Disabilita Notifiche Push';

  @override
  String get disabled => 'Disabilitato';

  @override
  String get discussionLanguages => 'Lingua Discussione';

  @override
  String get discussionLanguagesTooltip =>
      'Contenuto filtrato nella lingua selezionata.';

  @override
  String get dismissRead => 'Rimuovi \'letti\'';

  @override
  String get displayName => 'Mostra Nome';

  @override
  String get displayUserScore => 'Visualizza i Punteggi degli Utenti (Karma).';

  @override
  String get dividerAppearance => 'Aspetto Divisore';

  @override
  String get doNotShowAgain => 'Non Mostrare Nuovamente';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Trovate diverse app compatibili; si prega di installane solo una';

  @override
  String get downloadingMedia => 'Download in corso per la condivisione…';

  @override
  String get downvote => 'Voto in giù';

  @override
  String get downvoteColor => 'Colore Disprezzati';

  @override
  String get downvoted => 'Disprezzato';

  @override
  String get downvotesDisabled =>
      'I voti in giù sono disabilitati in questa istanza.';

  @override
  String get edit => 'Modifica';

  @override
  String get editComment => 'Modifica Commento';

  @override
  String get editPost => 'Modifica Post';

  @override
  String get email => 'Email';

  @override
  String get empty => 'Vuoto';

  @override
  String get emptyInbox => 'Svuota Inbox';

  @override
  String get emptyUri =>
      'Il link è vuoto. Per favore inserisci un link in formato valido per procedere.';

  @override
  String get enableCommentNavigation => 'Abilita Navigazione Commento';

  @override
  String get enableExperimentalFeatures => 'Abilita funzioni sperimentali';

  @override
  String get enableFeedFab => 'Abilita Pulsante Galleggiante su Feed';

  @override
  String get enableFloatingButtonOnFeeds =>
      'Abilita Pulsante Galleggiante Su Feed';

  @override
  String get enableFloatingButtonOnPosts =>
      'Abilita Pulsante Galleggiante Sui Post';

  @override
  String get enableInboxNotifications => 'Abilita Notifiche Inbox';

  @override
  String get enablePostFab => 'Abilita Pulsante Galleggiante sui Post';

  @override
  String get endOfComments => 'Fine dei commenti';

  @override
  String get endSearch => 'Fine Ricerca';

  @override
  String errorDeletingImage(Object error) {
    return 'Errore nel cancellare l\'immagine: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Non è stato possibile effettuare il download del file per la condivisione: $errorMessage';
  }

  @override
  String get errorImportingAccountSettings =>
      'Errore nell\'importare le impostazioni. Il file potrebbe essere in un formato errato.';

  @override
  String get errorInitializingClient => 'Error initializing client';

  @override
  String get errorLoadingAccountSettings =>
      'Errore nel caricare il file impostazioni o l\'operazione è stata cancellata.';

  @override
  String get errorMarkingReplyRead =>
      'Errore nel segnare la risposta come letta.';

  @override
  String get errorMarkingReplyUnread =>
      'Errore nel segnare la risposta come non letta.';

  @override
  String get errorNoActiveInstance => 'No active instance found';

  @override
  String get errorParsingJson =>
      'Errore nell\'analisi del file selezionato. Potrebbe non essere JSON valido.';

  @override
  String get errorSavingAccountSettings =>
      'Errore nel salvare il file impostazioni o l\'operazione è stata cancellata.';

  @override
  String get exceptionProcessingUri =>
      'Si è verificato un errore durante il trattamento del link. Potrebbe non essere disponibile nella tua istanza.';

  @override
  String get excessiveApiCallsWarning =>
      'Potrebbe volerci un po\' a causa dei filtri.';

  @override
  String get expand => 'Espandi';

  @override
  String get expandCommentPreview => 'Espandi Anteprima Commento';

  @override
  String get expandInformation => 'Espandi Informazione';

  @override
  String get expandOptions => 'Espandi le opzioni';

  @override
  String get expandPost => 'Espandi post';

  @override
  String get expandPostPreview => 'Espandi Anteprima Post';

  @override
  String get expandSpoiler => 'Espandi Spoiler';

  @override
  String get expanded => 'Espanso';

  @override
  String get experimentalFeatures => 'Funzioni Sperimentali';

  @override
  String get experimentalFeaturesDescription =>
      'Queste funzioni sono in fase di sviluppo, usale a tuo rischio. Dovrai riavviare Thunder per applicarle.';

  @override
  String get exploreInstance => 'Esplora Istanza';

  @override
  String get exportDatabase => 'Esporta Database';

  @override
  String get exportDatabaseSubtitle =>
      'Questo database contiene info sui tuoi account, preferiti, iscrizioni anonime, ed etichette utente.';

  @override
  String get exportLemmyAccountSettingsDescription =>
      'Esporta impostazioni account Lemmy';

  @override
  String get exportSettingsSubtitle =>
      'L\'impostazione include tutte le preferenze che hai configurato su Thunder.';

  @override
  String get extraLarge => 'Extra Largo';

  @override
  String failedToBlock(Object errorMessage) {
    return 'È stato impossibile bloccare: $errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return 'Comunicazione fallita con il server notifica di Thunder a \'$serverAddress\'';
  }

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return 'È stato impossibile caricare i blocchi: $errorMessage';
  }

  @override
  String get failedToLoadVideo =>
      'Caricamento video fallito. Aprire nel browser?';

  @override
  String get failedToPerformAction => 'Operazione fallita';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'È stato impossibile sbloccare: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Impossibile aggiornare le impostazioni di notifica';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Preferiti';

  @override
  String get featuredPost => 'Post in Evidenza';

  @override
  String get feed => 'Feed';

  @override
  String get feedBehaviourSettings => 'Feed';

  @override
  String get feedSettings => 'Impostazioni Feed';

  @override
  String get feedTypeAndSorts => 'Feed Predefinito e Ordinamento';

  @override
  String get fetchAccountError => 'Non è stato possibile stabilire l\'account';

  @override
  String filteringBy(Object entity) {
    return 'Filtrato per $entity';
  }

  @override
  String get filters => 'Filtri';

  @override
  String get floatingActionButton => 'Azione Pulsante Galleggiante';

  @override
  String get floatingActionButtonInformation =>
      'Thunder permette diverse Azioni per il Pulsante Galleggiante.\n- Swipe per rivelare diverse Azioni\n- Swipe sotto/sopra per nascondere o rivelare il Pulsante\n\nPer personalizzare le Azioni principali o secondarie, premi a lungo sulle seguenti Azioni.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'indica Azione di pressione prolungata.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'indica Azione di pressione singola.';

  @override
  String get fonts => 'Font';

  @override
  String get forward => 'Inoltrati';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Trovata app compatibile; riavvia Thunder per connettere';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Scorri ovunque per tornare indietro quando le azioni da sinistra-a-destra sono disabilitate';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get fullscreenSwipeGestures => 'Gesti Swipe a Schermo Intero';

  @override
  String get general => 'Generale';

  @override
  String get generalSettings => 'Impostazioni Generali';

  @override
  String get gestures => 'Movimenti';

  @override
  String get gettingStarted => 'Iniziare';

  @override
  String get green => 'Verde';

  @override
  String get guestModeFeedSettings => 'Impostazioni Feed Ospite';

  @override
  String get guestModeFeedSettingsLabel =>
      'Le seguenti impostazioni si applicano al solo account ospite. Per regolare il tuo feed, vai su Impostazioni Account.';

  @override
  String get havingIssuesWithNotifications => 'Problemi con le notifiche?';

  @override
  String get hidCommunity => 'Nascondi Comunità';

  @override
  String get hidden => 'Nascosto';

  @override
  String get hide => 'Nascondi';

  @override
  String get hideBottomBarOnScroll => 'Hide Bottom Bar on Scroll';

  @override
  String get hideColor => 'Colore Nascosti';

  @override
  String get hideNsfwPostsFromFeed => 'Nascondi Post NSFW dal Feed';

  @override
  String get hideNsfwPreviews => 'Sfoca Anteprime Post NSFW';

  @override
  String get hidePassword => 'Nascondi Password';

  @override
  String get hideThumbnails => 'Nascondi Miniature';

  @override
  String get hideTopBarOnScroll => 'Nascondi Barra Superiore se Scorri';

  @override
  String get hostInstance => 'Host Istanza';

  @override
  String get hot => 'Popolari';

  @override
  String get image => 'Immagine';

  @override
  String get imageCachingMode => 'Modalità Image Caching';

  @override
  String get imageCachingModeAggressive =>
      'Image caching aggressivo (utilizza più memoria)';

  @override
  String get imageCachingModeAggressiveShort => 'Aggressivo';

  @override
  String get imageCachingModeRelaxed =>
      'Fai scadere image caching (usa meno memoria ma le immagini sono ricaricate più spesso)';

  @override
  String get imageCachingModeRelaxedShort => 'Rilassato';

  @override
  String get imageDimensionTimeout => 'Timeout Dimensione Immagine';

  @override
  String get imagePeekDuration => 'Image Peek Duration';

  @override
  String get imagePeekDurationDescription =>
      'Duration of long press before image peek is triggered';

  @override
  String get importDatabase => 'Importa Database';

  @override
  String get importExportDatabase => 'Importa/Esporta Database Thunder';

  @override
  String get importExportLemmyAccountSettings =>
      'Importa/Esporta Impostazioni Account Lemmy';

  @override
  String get importExportLemmyAccountSettingsSubtitle =>
      'Include comunità iscritte, bloccate, e preferenze account';

  @override
  String get importExportSettings => 'Importa/Esporta Impostazioni';

  @override
  String get importExportThunderSettings =>
      'Importa/Esporta Impostazioni Thunder';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Importa impostazioni account Lemmy';

  @override
  String get importSettings => 'Importa Impostazioni';

  @override
  String inReplyTo(Object post, Object community) {
    return 'In risposta a $post da $community';
  }

  @override
  String get in_ => 'da';

  @override
  String get inbox => 'In arrivo';

  @override
  String get includeCommunity => 'Includi Comunità';

  @override
  String get includeExternalLink => 'Includi Link Esterni';

  @override
  String get includeImage => 'Includi Immagine';

  @override
  String get includePostLink => 'Includi Link del Post';

  @override
  String get includeText => 'Includi Testo';

  @override
  String get includeTitle => 'Includi Titolo';

  @override
  String get information => 'Informazioni';

  @override
  String instance(num count) {
    return 'Istanza';
  }

  @override
  String get instanceActions => 'Azioni Istanza';

  @override
  String instanceEntry(Object username) {
    return 'Istanza \'$username\'';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance è stata già aggiunta.';
  }

  @override
  String get instanceNameColor => 'Colore Nome Istanza';

  @override
  String get instanceNameThickness => 'Spessore Nome Istanza';

  @override
  String get instances => 'Istanze';

  @override
  String get internetOrInstanceIssues =>
      'Potresti non essere connesso all\'Internet oppure la tua istanza potrebbe non essere disponibile in questo momento.';

  @override
  String get invalidUrl => 'Invalid URL format';

  @override
  String joined(Object x) {
    return 'Iscritto il $x';
  }

  @override
  String get keywordFilterDescription =>
      'Filtra post contenenti parole-chiave nel titolo, corpo o URL';

  @override
  String get keywordFilters => 'Filtri Parole-Chiave';

  @override
  String get label => 'Etichetta';

  @override
  String get language => 'Lingua';

  @override
  String get languageFilters => 'Cerchi i filtri della lingua?';

  @override
  String get languageNotAllowed =>
      'Questa comunità non permette post nella lingua che hai selezionato. Prova un altra lingua.';

  @override
  String get large => 'Largo';

  @override
  String get leftLongSwipe => 'Swipe Sx Lungo';

  @override
  String get leftShortSwipe => 'Swipe Sx Corto';

  @override
  String get light => 'Chiaro';

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
  String get linkActions => 'Azioni per il Link';

  @override
  String get linkHandlingCustomTabs => 'Apri nel browser incorporato in-app';

  @override
  String get linkHandlingCustomTabsShort => 'Incorporato in-app';

  @override
  String get linkHandlingExternal => 'Apri nel browser esterno';

  @override
  String get linkHandlingExternalShort => 'Esterno';

  @override
  String get linkHandlingInApp => 'Usa il browser integrato di Thunder';

  @override
  String get linkHandlingInAppShort => 'In-app';

  @override
  String get linksBehaviourSettings => 'Link';

  @override
  String loadMorePlural(Object count) {
    return 'Carica altre $count risposte in più…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Carica $count risposta in più…';
  }

  @override
  String get loading => 'Caricamento...';

  @override
  String get local => 'Locale';

  @override
  String get localNotifications => 'Notifiche Locali';

  @override
  String get localOnly => 'Solo Locale';

  @override
  String get localPosts => 'Post Locali';

  @override
  String get lockPost => 'Fissa Post';

  @override
  String get locked => 'Locked';

  @override
  String get lockedPost => 'Post Fissato';

  @override
  String get logOut => 'Log Out';

  @override
  String get login => 'Accesso';

  @override
  String get loginAttemptCanceled => 'Tentativo di login cancellato.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Non è stato possibile effettuare il log in. Prova di nuovo per favore:($errorMessage)';
  }

  @override
  String get loginSucceeded => 'Log in effettuato.';

  @override
  String get loginToPerformAction =>
      'Devi aver effettuato l\'accesso per completare questa operazione.';

  @override
  String get loginToSeeInbox => 'Effettua l\'accesso per vedere il tuo Inbox';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Cerchi impostazioni del feed specifiche per l\'account?';

  @override
  String get malformedUri =>
      'Il link che hai fornito era in un formato non supportato. Per favore assicurati che il link sia valido.';

  @override
  String get manageAccounts => 'Gestisci Profili';

  @override
  String get manageMedia => 'Gestione Media';

  @override
  String get markAllAsRead => 'Segna tutto come letto';

  @override
  String get markAsRead => 'Segna come letto';

  @override
  String get markPostAsReadOnMediaView => 'Segna Come Letto Dopo Visione Media';

  @override
  String get markPostAsReadOnScroll => 'Segna Come Letto Su Scorrimento';

  @override
  String get markReadColor => 'Colore Letti/Non Letti';

  @override
  String get matrixUser => 'Utente Matrix';

  @override
  String get me => 'Io';

  @override
  String get media => 'Media';

  @override
  String get medium => 'Medio';

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
  String get metadataFontScale => 'Scala Font Metadati';

  @override
  String get missingErrorMessage => 'Nessun messaggio di errore disponibile';

  @override
  String get modAdd => 'Aggiungi/Rimuovi Moderatori Istanza';

  @override
  String get modAddCommunity => 'Aggiungi/Rimuovi Moderatori Comunità';

  @override
  String get modBan => 'Banna/Sbanna Utenti Istanza';

  @override
  String get modBanFromCommunity => 'Banna/Sbanna Utenti Comunità';

  @override
  String get modFeaturePost => 'Evidenzia/Tralascia Post';

  @override
  String get modLockPost => 'Fissa/Rilascia Post';

  @override
  String get modRemoveComment => 'Rimuovi/Ripristina Commenti';

  @override
  String get modRemoveCommunity => 'Rimuovi/Ripristina Comunità';

  @override
  String get modRemovePost => 'Rimuovi/Ripristina Post';

  @override
  String get modTransferCommunity => 'Trasferimento Comunità';

  @override
  String get moderatedCommunities => 'Comunità Moderate';

  @override
  String get moderates => 'Moderates';

  @override
  String moderator(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moderatori',
      one: 'Moderatore',
      zero: 'Moderatore',
    );
    return '$_temp0';
  }

  @override
  String get moderatorActions => 'Azioni Moderatore';

  @override
  String get modlog => 'Modlog';

  @override
  String get mostComments => 'Più Commentati';

  @override
  String get mustBeLoggedIn => 'Devi effettuare l\'accesso';

  @override
  String get mustBeLoggedInComment =>
      'Devi avere effettuato il log in per poter commentare';

  @override
  String get mustBeLoggedInPost =>
      'Devi avere effettuato il log in per poter creare un post';

  @override
  String get names => 'Nomi';

  @override
  String get navbarDoubleTapGestures => 'Gesti Doppio Tap Barra Navigazione';

  @override
  String get navbarSwipeGestures => 'Gesti Swipe Barra Navigazione';

  @override
  String get navigateDown => 'Vai al prossimo commento';

  @override
  String get navigateUp => 'Commento precedente';

  @override
  String get navigation => 'Navigazione';

  @override
  String get nestedCommentIndicatorColor =>
      'Colore Indicatore Commento Nidificato';

  @override
  String get nestedCommentIndicatorStyle =>
      'Stile Indicatore Commento Nidificato';

  @override
  String get never => 'Mai';

  @override
  String get newComments => 'Commenti Nuovi';

  @override
  String get newPost => 'Nuovo Post';

  @override
  String get new_ => 'Nuovi';

  @override
  String get no => 'No';

  @override
  String get noAccountsAdded => 'Nessun account è stato aggiunto';

  @override
  String get noAnonymousInstances => 'Non sono state aggiunte istanze anonime';

  @override
  String get noCommentsFound => 'Nessun commento trovato.';

  @override
  String get noCommunitiesFound => 'Nessuna comunità trovata';

  @override
  String get noCommunityBlocks => 'Nessuna comunità bloccata.';

  @override
  String get noCompatibleAppFound => 'Nessuna app compatibile trovata';

  @override
  String get noDiscussionLanguages =>
      'Nessun contenuto è nascosto in base alla lingua.';

  @override
  String get noDisplayNameSet => 'Nome da mostrare non impostato';

  @override
  String get noEmailSet => 'Nessuna email impostata';

  @override
  String get noFavoritedCommunities => 'Nessuna comunità preferita';

  @override
  String get noImages => 'Sembra che tu non abbia caricato nessuna immagine.';

  @override
  String get noInstanceBlocks => 'Nessun istanza bloccata.';

  @override
  String get noItems => 'Nessun elemento';

  @override
  String get noKeywordFilters => 'Nessun filtro parola-chiave aggiunto';

  @override
  String get noLanguage => 'Nessuna lingua';

  @override
  String get noMatrixUserSet => 'Nessun utente matrix impostato';

  @override
  String get noMentions => 'Nessuna menzione';

  @override
  String get noMessages => 'Nessun messaggio';

  @override
  String get noPostsFound => 'Nessun post trovato.';

  @override
  String get noProfileBioSet => 'Nessuna bio profilo impostata';

  @override
  String get noReferencesToImage =>
      'Nessun post o commento trovato contenente questa immagine. Tuttavia, potrebbe essere utilizzata altrove su internet.';

  @override
  String get noReplies => 'Nessuna risposta';

  @override
  String get noResultsFound => 'Nessun risultato trovato.';

  @override
  String get noSubscriptions => 'Nessuna Iscrizione';

  @override
  String get noUserBlocks => 'Nessun utente bloccato.';

  @override
  String get noUserLabels => 'Non hai ancora creato alcuna etichetta utente';

  @override
  String get noUsersFound => 'Nessun utente trovato';

  @override
  String get noVisibleComments =>
      'Comments may not be visible because the community is blocked.';

  @override
  String get none => 'Nessuna';

  @override
  String get normal => 'Normale';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance non sembra essere un\'istanza valida di Lemmy';
  }

  @override
  String get notValidUrl => 'URL invalido';

  @override
  String get nothingToShare => 'Non c\'è niente da condividere';

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
  String get notificationsBehaviourSettings => 'Notifiche';

  @override
  String get notificationsNotAllowed =>
      'Le notifiche per Thunder non sono consentite nelle impostazioni del sistema';

  @override
  String get notificationsWarningDialog =>
      'Le notifiche sono una **caratteristica sperimentale** che potrebbe non funzionare correttamente su tutti i dispositivi.\n\n- I controlli avverranno ogni ~15 minuti e consumeranno batteria aggiuntiva.\n\n- Disabilita l\'ottimizzazione della batteria per una maggiore stabilità delle notifiche.\n\nVedere la seguente pagina per ulteriori informazioni.';

  @override
  String get nsfw => 'NSFW';

  @override
  String get nsfwWarning => 'NSFW - Tocca per rivelare';

  @override
  String get off => 'off';

  @override
  String get offline => 'offline';

  @override
  String get ok => 'OK';

  @override
  String get old => 'Vecchi';

  @override
  String get on => 'on';

  @override
  String get onWifi => 'Su Wifi';

  @override
  String get onlyModsCanPostInCommunity =>
      'Solo i moderatori posso postare in questa comunità';

  @override
  String get open => 'Apri';

  @override
  String get openAccountSwitcher => 'Apri interruttore utenti';

  @override
  String get openByDefault => 'Apri per impostazione predefinita';

  @override
  String get openInBrowser => 'Apri nel Browser';

  @override
  String get openInstance => 'Apri Istanza';

  @override
  String get openLinksInExternalBrowser => 'Apri Link nel Browser Esterno';

  @override
  String get openLinksInReaderMode => 'Apri Link in Modalità Lettura';

  @override
  String get openSettings => 'Apri Impostazioni';

  @override
  String get orange => 'Arancione';

  @override
  String get originalPoster => 'Autore Originale';

  @override
  String get overview => 'Panoramica';

  @override
  String get password => 'Password';

  @override
  String get pending => 'In Attesa';

  @override
  String performedBy(Object user) {
    return 'Performed by: $user';
  }

  @override
  String get permissionDenied =>
      'Permesso di visualizzare notifiche non abilitato per Thunder. Si prega di attivare nelle impostazioni di sistema.';

  @override
  String get permissionDeniedMessage =>
      'Thunder richiede alcune autorizzazioni per salvare questa immagine, che sono state negate.';

  @override
  String get pinPostToCommunity => 'Fissa Post a Comunità';

  @override
  String get pinToCommunity => 'Fissa a Comunità';

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
  String get postActions => 'Azioni Post';

  @override
  String get postBehaviourSettings => 'Post';

  @override
  String get postBody => 'Pubblica Testo';

  @override
  String get postBodySettings => 'Impostazioni Corpo del Post';

  @override
  String get postBodySettingsDescription =>
      'Queste impostazioni influiscono sulla visualizzazione del corpo del post';

  @override
  String get postBodyShowCommunityInstance => 'Mostra Istanza Comunità';

  @override
  String get postBodyShowUserInstance => 'Mostra Istanza Utente';

  @override
  String get postBodyViewType => 'Tipo di Visualizzazione del Corpo del Post';

  @override
  String get postContentFontScale => 'Scala Font Contenuto Post';

  @override
  String get postCreatedSuccessfully => 'Post creato con successo!';

  @override
  String get postLocked => 'Il post è bloccato. Non è permesso rispondere.';

  @override
  String get postMetadataInstructions =>
      'Puoi personalizzare le info dei metadati trascinando e rilasciando quelle desiderate';

  @override
  String get postNSFW => 'Segna come NSFW';

  @override
  String get postPreview =>
      'Mostra anteprima del post con le impostazioni indicate';

  @override
  String get postSavedAsDraft => 'Post salvato come bozza';

  @override
  String get postShowUserInstance => 'Mostra Istanza Utente';

  @override
  String get postSwipeActions => 'Azioni Swipe Post';

  @override
  String get postSwipeGesturesHint =>
      'Preferisci usare i pulsanti? Cambia quali pulsanti compaiono nelle schermate dei post nelle impostazioni generali.';

  @override
  String get postTitle => 'Titolo';

  @override
  String get postTitleFontScale => 'Scala Font Titolo Post';

  @override
  String get postTogglePreview => 'Aziona Anteprima';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Impossibile caricare l\'immagine';

  @override
  String get postViewType => 'Tipo Vista Post';

  @override
  String get posts => 'Post';

  @override
  String get preview => 'Anteprima';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile applicato con successo!';
  }

  @override
  String get profileBio => 'Bio Profilo';

  @override
  String get profiles => 'Profili';

  @override
  String get public => 'Pubblico';

  @override
  String get pureBlack => 'Nero';

  @override
  String get purgedComment => 'Commento Purgato';

  @override
  String get purgedCommunity => 'Comunità Purgata';

  @override
  String get purgedPerson => 'Persona Purgata';

  @override
  String get purgedPost => 'Post Purgato';

  @override
  String get purple => 'Viola';

  @override
  String get pushNotification => 'Notifiche Push';

  @override
  String get pushNotificationDescription =>
      'Se abilitato, Thunder invierà token JWT al server al fine di inviare nuove notifiche.\n\n**NOTA:** Questo non avrà effetto fino al riavvio dell\'app.';

  @override
  String get pushNotificationServer => 'Server Notifiche Push';

  @override
  String get pushNotificationServerDescription =>
      'Configura il server di notifica push. Il server deve essere configurato correttamente per inviare notifiche push al dispositivo.\n\n** Inserisci solo server di cui ti fidi con le tue credenziali.**';

  @override
  String get rateLimitErrorMessage =>
      'Hai raggiunto il limite per effettuare questa richiesta. Attendere e riprovare più tardi.';

  @override
  String get reachedTheBottom => 'Mmh. Sembra che hai raggiunto la fine.';

  @override
  String get read => 'Letto';

  @override
  String get readAll => 'Leggi Tutto';

  @override
  String get readerMode => 'Modalità lettura';

  @override
  String get reason => 'Motivo';

  @override
  String get red => 'Rosso';

  @override
  String get reduceAnimations => 'Riduci Animazioni';

  @override
  String get reducesAnimations => 'Limita le animazioni usate su Thunder';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get refreshContent => 'Aggiorna Contenuti';

  @override
  String get removalReason => 'Motivo Rimozione';

  @override
  String get remove => 'Rimuovi';

  @override
  String get removeAccount => 'Elimina Account';

  @override
  String get removeAsCommunityModerator => 'Rimuovi da Moderatore Comunità';

  @override
  String get removeComment => 'Rimuovi Commento';

  @override
  String get removeFromFavorites => 'Rimuovi dai preferiti';

  @override
  String get removeInstance => 'Elimina istanza';

  @override
  String removeKeyword(Object keyword) {
    return 'Rimuovi \"$keyword\"?';
  }

  @override
  String get removeKeywordFilter => 'Rimuovi Parola-Chiave';

  @override
  String get removePost => 'Rimuovi Post';

  @override
  String get removeUserData => 'Remove user data';

  @override
  String get removed => 'Removed';

  @override
  String get removedComment => 'Commento Rimosso';

  @override
  String get removedCommunity => 'Comunità Rimossa';

  @override
  String get removedCommunityFromSubscriptions => 'Rimosso dalla comunità';

  @override
  String get removedInstanceMod => 'Moderatore Istanza Rimosso';

  @override
  String get removedModFromCommunity => 'Moderatore Rimosso da Comunità';

  @override
  String get removedPost => 'Post Rimosso';

  @override
  String removedUserAsCommunityModerator(Object username) {
    return 'Removed $username as community moderator';
  }

  @override
  String get reorder => 'Riordina';

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
  String get replyColor => 'Colore Risposta';

  @override
  String get replyNotSupported =>
      'Rispondere da questa schermata non è ancora supportato';

  @override
  String get replyToPost => 'Rispondi al Post';

  @override
  String replyingTo(Object author) {
    return 'Stai rispondendo a $author';
  }

  @override
  String report(num count) {
    return 'Segnala';
  }

  @override
  String get reportComment => 'Segnala Commento';

  @override
  String get reportPost => 'Segnala Post';

  @override
  String get reportedComment => 'Reported comment';

  @override
  String get reportedPost => 'Reported post';

  @override
  String get reporter => 'Segnalatore:';

  @override
  String get requiredField => '*necessario';

  @override
  String get reset => 'Ripristina';

  @override
  String get resetCommentPreferences => 'Ripristina preferenze commento';

  @override
  String get resetPostPreferences => 'Ripristina preferenze post';

  @override
  String get resetPreferences => 'Ripristina Preferenze';

  @override
  String get resetPreferencesAndData => 'Ripristina Preferenze e Dati';

  @override
  String get restore => 'Ripristina';

  @override
  String get restoreComment => 'Ripristina Commento';

  @override
  String get restorePost => 'Ripristina Post';

  @override
  String get restoredComment => 'Commento Ripristinato';

  @override
  String get restoredCommentFromDraft => 'Commento recuperato dalle bozze';

  @override
  String get restoredCommunity => 'Comunità Ripristinata';

  @override
  String get restoredPost => 'Post Ripristinato';

  @override
  String get restoredPostFromDraft => 'Post recuperato dalle bozze';

  @override
  String get retry => 'Riprova';

  @override
  String get rightLongSwipe => 'Swipe Dx Lungo';

  @override
  String get rightShortSwipe => 'Swipe Dx Corto';

  @override
  String get save => 'Salva';

  @override
  String get saveColor => 'Salva Colore';

  @override
  String get saveSettings => 'Salva Impostazioni';

  @override
  String get saved => 'Salvati';

  @override
  String get scaled => 'Bilanciati';

  @override
  String get scrapeMissingLinkPreviews => 'Recupera Anteprime Link Mancanti';

  @override
  String get screenReaderProfile => 'Profilo del Lettore di Schermo';

  @override
  String get screenReaderProfileDescription =>
      'Ottimizza Thunder per lettori di schermo tramite una riduzione generale degli elementi visualizzati e la rimozione di movimenti contrastanti.';

  @override
  String get search => 'Cerca';

  @override
  String get searchByText => 'Cerca per testo';

  @override
  String get searchByUrl => 'Cerca per URL';

  @override
  String get searchComments => 'Cerca Commenti';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return 'Cerca commenti associati con $instance';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return 'Cerca comunità associate con $instance';
  }

  @override
  String searchInstance(Object instance) {
    return 'Cerca $instance';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return 'Cerca per istanze federate con $instance';
  }

  @override
  String get searchPostSearchType => 'Seleziona Tipo di Ricerca di Post';

  @override
  String searchPostsFederatedWith(Object instance) {
    return 'Cerca post associati con $instance';
  }

  @override
  String get searchTerm => 'Cerca termine';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Cerca utenti associati con $instance';
  }

  @override
  String get selectAccountToCommentAs => 'Seleziona account con cui commentare';

  @override
  String get selectAccountToPostAs => 'Seleziona account con cui postare';

  @override
  String get selectAll => 'Seleziona tutto';

  @override
  String get selectCommunity => 'Seleziona una comunità';

  @override
  String get selectFeedType => 'Seleziona Tipo di Feed';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String get selectSearchType => 'Seleziona Tipo di Ricerca';

  @override
  String get selectText => 'Seleziona Testo';

  @override
  String get sendBackgroundTestLocalNotification =>
      'Invia notifica locale di test in background';

  @override
  String get sendBackgroundTestUnifiedPushNotification =>
      'Invia notifica UnifiedPush di test in background';

  @override
  String get sendTestLocalNotification => 'Invia notifica locale di test';

  @override
  String get sendTestUnifiedPushNotification =>
      'Invia notifica UnifiedPush di test';

  @override
  String get sensitiveContentWarning =>
      'Può contenere contenuti sensibili. Tocca per rivelare.';

  @override
  String get sentRequestForTestNotification =>
      'Richiesta test di notifica inviata.';

  @override
  String serverErrorComments(Object message) {
    return 'Si è verificato un errore del server durante il caricamento di ulteriori commenti: $message';
  }

  @override
  String get setAction => 'Imposta Azione';

  @override
  String get setLongPress => 'Imposta come azione a premuta lunga';

  @override
  String get setShortPress => 'Imposta come azione a premuta breve';

  @override
  String get settingOverrideLabel =>
      'Queste impostazioni sovrascrivono quelle predefinite di Thunder.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'Impostazioni per il tipo $settingType non sono ancora supportate.';
  }

  @override
  String get settings => 'Impostazioni';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'Impostazioni salvate correttamente in \'$savedFilePath\'';
  }

  @override
  String get settingsFeedCards =>
      'Queste impostazioni sono applicabili alle tessere della feed principale, ulteriori azioni sono disponibili una volta aperto il post.';

  @override
  String get settingsImportedSuccessfully =>
      'Impostazioni importate con successo!';

  @override
  String get settingsNotExportedSuccessfully =>
      'Impostazioni non salvate correttamente o l\'operazione è stata cancellata.';

  @override
  String get settingsNotImportedSuccessfully =>
      'Impostazioni non importate correttamente o l\'operazione è stata cancellata.';

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
  String get settingsPageAppearancePosts => 'Post';

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
  String get share => 'Condividi';

  @override
  String get shareComment => 'Condividi Link Commento';

  @override
  String get shareCommentLocal => 'Condividi Commento Link (Mia Istanza)';

  @override
  String get shareCommunity => 'Condividi Comunità';

  @override
  String get shareCommunityLink => 'Condividi Link Comunità';

  @override
  String get shareCommunityLinkLocal => 'Condividi Link Comunità (Mia Istanza)';

  @override
  String get shareImage => 'Condividi Immagine';

  @override
  String get shareLemmyLink => 'Condividi Link Lemmy';

  @override
  String get shareLink => 'Condividi il Link';

  @override
  String get shareMedia => 'Condividi Materiale audio/video';

  @override
  String get shareMediaLink => 'Condividi Link Media';

  @override
  String get shareOriginalLink => 'Condividi Link Originale';

  @override
  String get sharePost => 'Condividi Post';

  @override
  String get sharePostLocal => 'Condividi Link Post (Mia Istanza)';

  @override
  String get shareThumbnail => 'Condividi Miniatura';

  @override
  String get shareThumbnailAsImage => 'Condividere Miniatura Come Immagine';

  @override
  String get shareUser => 'Condividi Utente';

  @override
  String get shareUserLink => 'Condividi Link Utente';

  @override
  String get shareUserLinkLocal => 'Condividi Link Utente (Mia Istanza)';

  @override
  String get showAll => 'Mostra Tutto';

  @override
  String get showBotAccounts => 'Mostra Account Bot';

  @override
  String get showCommentActionButtons => 'Mostra Pulsanti Azione Commento';

  @override
  String get showCommunityDisplayNames => 'Mostra Nomi Comunità';

  @override
  String get showCrossPosts => 'Mostra Crosspost';

  @override
  String get showEdgeToEdgeImages => 'Mostra Immagini da-Bordo-a-Bordo';

  @override
  String get showExpandedTaglines => 'Mostra linea tag espansa';

  @override
  String get showFullDate => 'Mostra Data Completa';

  @override
  String get showFullDateDescription => 'Mostra data completa nei post';

  @override
  String get showFullHeightImages => 'Mostra Immagini ad Altezza Completa';

  @override
  String get showHiddenPosts => 'Mostra Post Nascosti';

  @override
  String get showInAppUpdateNotifications => 'Ricevi Notifiche Release GitHub';

  @override
  String get showLess => 'Mostra di meno';

  @override
  String get showMore => 'Mostra successivi';

  @override
  String get showNavigationLabels => 'Mostra Etichette Navigazione';

  @override
  String get showNavigationLabelsDescription =>
      'Visualizza etichette sotto i pulsanti di navigazione in basso';

  @override
  String get showNsfwContent => 'Mostra Contenuti NSFW';

  @override
  String get showOwnContent => 'Mostra propri contenuti';

  @override
  String get showPassword => 'Mostra Password';

  @override
  String get showPostAuthor => 'Mostra Autore Post';

  @override
  String get showPostAuthorSubtitle =>
      'L\'autore del post è sempre mostrato nei feed della comunità';

  @override
  String get showPostCommunityIcons => 'Mostra Icone Comunità';

  @override
  String get showPostSaveAction => 'Mostra Pulsante Salva';

  @override
  String get showPostTextContentPreview => 'Mostra Anteprima Testo';

  @override
  String get showPostTitleFirst => 'Mostra Prima il Titolo';

  @override
  String get showPostVoteActions => 'Mostra Pulsanti Voto';

  @override
  String get showReadPosts => 'Mostra Post Letti';

  @override
  String get showSavedContent => 'Mostra contenuti salvati';

  @override
  String get showScoreCounters => 'Visualizza Punteggi Utenti';

  @override
  String get showScores => 'Mostra Punteggi Post/Commenti';

  @override
  String get showTextPostIndicator => 'Mostra Indicatore Testo';

  @override
  String get showThumbnailPreviewOnRight => 'Mostra Miniature a Dx';

  @override
  String get showUnreadOnly => 'Mostra solo non letti';

  @override
  String get showUpdateChangelogs => 'Mostra Aggiornamenti Changelog';

  @override
  String get showUpdateChangelogsSubtitle =>
      'Visualizza elenco modifiche dopo un aggiornamento';

  @override
  String get showUserAvatar => 'Mostra Avatar Utente';

  @override
  String get showUserDisplayNames => 'Mostra Nomi Utente';

  @override
  String get showUserInstance => 'Mostra Istanza Utente';

  @override
  String get sidebar => 'Barra Laterale';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Tocca 2 volte la barra inferiore per aprire la barra laterale';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Scorri la barra inferiore per aprire la barra laterale';

  @override
  String get small => 'Piccolo';

  @override
  String get somethingWentWrong => 'Ops, qualcosa è andato storto!';

  @override
  String get sortBy => 'Ordina Per';

  @override
  String get sortByTop => 'Ordina dal Migliore';

  @override
  String get sortOptions => 'Opzioni di Visualizzazione';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get standard => 'Standard';

  @override
  String get stats => 'Statistiche';

  @override
  String get status => 'Stato';

  @override
  String get submit => 'Invia';

  @override
  String get subscribe => 'Iscriviti';

  @override
  String get subscribeToCommunity => 'Iscriviti alla Comunità';

  @override
  String get subscribed => 'Iscritto';

  @override
  String get subscriptionRequestSent => 'Richiesta di iscrizione inviata';

  @override
  String get subscriptions => 'Iscrizioni';

  @override
  String successfullyBannedUser(Object username) {
    return '$username Bannato';
  }

  @override
  String get successfullyBlocked => 'Bloccato.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return '$communityName bloccato/a';
  }

  @override
  String successfullyBlockedUser(Object username) {
    return '$username Bloccato';
  }

  @override
  String successfullyUnbannedUser(Object username) {
    return '$username Sbannato';
  }

  @override
  String get successfullyUnblocked => 'Sbloccato.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return '$communityName sbloccato/a';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return '$username Sbloccato';
  }

  @override
  String get suchAs => 'come';

  @override
  String get suggestedTitle => 'Titolo consigliato';

  @override
  String switchedAccount(Object username) {
    return 'Switched to $username';
  }

  @override
  String get system => 'Sistema';

  @override
  String get systemDarkMode => 'Modalità di Sistema Scura';

  @override
  String get systemDarkModeDescription =>
      'Abilita il tema nero in modalità sistema scura';

  @override
  String get tabletMode => 'Modalità Tablet (vista 2-colonne)';

  @override
  String get tapToExit => 'Premi \'indietro\' due volte per uscire';

  @override
  String get tappableAuthorCommunity => 'Autori & Comunità Toccabili';

  @override
  String get teal => 'Turchese';

  @override
  String get testBackgroundNotificationDescription =>
      'Thunder si chiuderà e poi tenterà di generare una notifica in background. (Ci vorranno almeno 15 minuti.)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'Thunder chiederà al server di notifica di inviare una notifica ritardata e si chiuderà. (Ci vorranno pochi minuti.)';

  @override
  String get text => 'Testo';

  @override
  String get textActions => 'Azioni Testo';

  @override
  String get theme => 'Tema';

  @override
  String get themeAccentColor => 'Colori Accento';

  @override
  String get themePrimary => 'Tema Primario';

  @override
  String get themeSecondary => 'Tema Secondario';

  @override
  String get themeTertiary => 'Tema Terziario';

  @override
  String get theming => 'Personalizzazione tema';

  @override
  String get thickness => 'Spessore';

  @override
  String get thisAccount => 'Questo Account';

  @override
  String get thumbnailUrl => 'URL Miniatura';

  @override
  String thunderHasBeenUpdated(Object version) {
    return 'Thunder aggiornata alla $version!';
  }

  @override
  String thunderNotificationServer(Object server) {
    return 'Server Notifiche Thunder: $server';
  }

  @override
  String get timeoutComments =>
      'Errore: si è verificato un time out durante il caricamento dei commenti';

  @override
  String get timeoutErrorMessage =>
      'Si è verificato un time out attendendo una risposta.';

  @override
  String get timeoutSaveComment =>
      'Errore: si è verificato un time out durante il salvataggio del commento';

  @override
  String get timeoutSavingPost =>
      'Errore: si è verificato un time out durante il salvataggio del post.';

  @override
  String get timeoutUpvoteComment =>
      'Errore: si è verificato un time out durante il voto del commento';

  @override
  String get timeoutVotingPost =>
      'Errore: si è verificato un time out durante il voto del post.';

  @override
  String get toggelRead => 'Interruttore Lettura';

  @override
  String get top => 'Migliori';

  @override
  String get topAll => 'Migliori di Sempre';

  @override
  String get topDay => 'Migliori di Oggi';

  @override
  String get topHour => 'Migliori dell\'Ultima Ora';

  @override
  String get topMonth => 'Migliori del Mese';

  @override
  String get topNineMonths => 'Migliori degli Ultimi 9 Mesi';

  @override
  String get topSixHour => 'Migliori delle Ultime 6 Ore';

  @override
  String get topSixMonths => 'Migliori degli Ultimi 6 Mesi';

  @override
  String get topThreeMonths => 'Migliori degli Ultimi 3 Mesi';

  @override
  String get topTwelveHour => 'Migliori delle Ultime 12 Ore';

  @override
  String get topWeek => 'Migliori della Settimana';

  @override
  String get topYear => 'Migliori dell\'Anno';

  @override
  String totalComments(Object x) {
    return '$x Comments';
  }

  @override
  String totalPosts(Object x) {
    return '$x Post';
  }

  @override
  String get totp => 'TOTP - Password Monouso a Tempo (facoltativo)';

  @override
  String get transferredModToCommunity => 'Comunità Trasferita';

  @override
  String get translationsMayNotBeComplete =>
      'Si prega di notare che le traduzioni potrebbero non essere complete';

  @override
  String get trendingCommunities => 'Comunità di Tendenza';

  @override
  String get trySearchingFor => 'Prova a cercare...';

  @override
  String get unableToFindCommunity => 'Impossibile trovare la comunità';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'Impossibile trovare la comunità \'$communityName\'';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Impossibile trovare la comunità selezionata sull\'istanza dell\'utente selezionato.';

  @override
  String get unableToFindInstance => 'Impossibile trovare l\'istanza';

  @override
  String get unableToFindLanguage => 'Impossibile trovare lingua';

  @override
  String get unableToFindPost => 'Impossibile trovare post';

  @override
  String get unableToFindUser => 'Impossibile trovare l\'utente';

  @override
  String unableToFindUserName(Object username) {
    return 'Impossibile trovare l\'utente \'$username\'';
  }

  @override
  String get unableToLoadImage => 'Impossibile caricare l\'immagine';

  @override
  String unableToLoadImageFrom(Object domain) {
    return 'Impossibile caricare l\'immagine da $domain';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return 'Impossibile caricare $instance';
  }

  @override
  String get unableToLoadPost => 'Unable to load post';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return 'Impossibile caricare post da $instance';
  }

  @override
  String get unableToLoadReplies => 'Impossibile caricare ulteriori commenti.';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return 'Impossibile navigare su $instanceHost. Potrebbe essere un\'istanza Lemmy non valida.';
  }

  @override
  String get unableToResolveReport => 'Impossibile risolvere segnalazione';

  @override
  String unableToRetrieveChangelog(Object version) {
    return 'Impossibile recuperare changelog per la versione $version.';
  }

  @override
  String get unbanFromCommunity => 'Sbanna dalla Comunità';

  @override
  String get unbannedUser => 'Utente Sbannato';

  @override
  String unbannedUserFromCommunity(Object username) {
    return 'Sbanna Utente dalla Comunità';
  }

  @override
  String get unblock => 'Unblock';

  @override
  String get unblockCommunity => 'Comunità Sbloccata';

  @override
  String get unblockCommunityInstance => 'Istanza Comunità Sbloccata';

  @override
  String get unblockInstance => 'Sblocca Istanza';

  @override
  String get unblockUser => 'Sblocca Utente';

  @override
  String get unblockUserInstance => 'Sblocca Istanza Utente';

  @override
  String get understandEnable => 'Capisco, Abilitare';

  @override
  String get unexpectedError => 'Errore Inaspettato';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get unfeaturedPost => 'Post Rilasciato';

  @override
  String get unhidCommunity => 'Recupera Comunità';

  @override
  String get unhide => 'Recupera';

  @override
  String unifiedPushDistributorApp(Object app, Object count) {
    return 'App Distributore UnifiedPush: $app ($count available)';
  }

  @override
  String get unifiedPushNotifications => 'Notifiche UnifiedPush';

  @override
  String unifiedPushServer(Object server) {
    return 'Server UnifiedPush: $server';
  }

  @override
  String get unifiedpush => 'UnifiedPush';

  @override
  String get unlockPost => 'Sblocca Post';

  @override
  String get unlockedPost => 'Post Sbloccato';

  @override
  String get unpinFromCommunity => 'Rilascia da Comunità';

  @override
  String get unpinPostFromCommunity => 'Rilascia Post da Comunità';

  @override
  String get unpinnedPostFromCommunity => 'Unpinned post from community';

  @override
  String get unreachable => 'Irraggiungibile';

  @override
  String get unresolved => 'Irrisolto';

  @override
  String get unsubscribe => 'Cancella iscrizione';

  @override
  String get unsubscribeFromCommunity => 'Disiscriviti dalla Comunità';

  @override
  String get unsubscribePending =>
      'Cancellare iscrizione (iscrizione in corso)';

  @override
  String get unsubscribed => 'Iscrizione cancellata';

  @override
  String updateReleased(Object version) {
    return 'Aggiornamento pubblicato: $version';
  }

  @override
  String get uploadImage => 'Carica l\'immagine';

  @override
  String uploadedDate(Object date) {
    return 'Caricato: $date';
  }

  @override
  String get upvote => 'Voto in su';

  @override
  String get upvoteColor => 'Colore Apprezzati';

  @override
  String get upvoted => 'Apprezzato';

  @override
  String get uriNotSupported =>
      'Al momento questo tipo di link non è supportato.';

  @override
  String get url => 'URL';

  @override
  String get useAdvancedShareSheet => 'Usa Foglio Condivisione Avanzato';

  @override
  String get useApplePushNotifications => 'Usa Notifiche APN';

  @override
  String get useApplePushNotificationsDescription =>
      'Usa servizio di notifica Push Apple';

  @override
  String get useCompactView =>
      'Abilita per post piccoli, disabilita per post grandi.';

  @override
  String get useLocalNotifications => 'Usa Notifiche Locali (Sperimentale)';

  @override
  String get useLocalNotificationsDescription =>
      'Controllo periodico delle notifiche in background';

  @override
  String get useMaterialYouTheme => 'Usa Tema Material You';

  @override
  String get useMaterialYouThemeDescription =>
      'Sovrascrive il tema personalizzato selezionato';

  @override
  String get useProfilePictureForDrawer => 'Usa Immagine Profilo per il Drawer';

  @override
  String get useProfilePictureForDrawerSubtitle =>
      'Se l\'accesso è effettuato, mostra l\'immagine del profilo utente al posto dell\'icona del drawer';

  @override
  String useSuggestedTitle(Object title) {
    return 'Usa il titolo suggerito: $title';
  }

  @override
  String get useUnifiedPushNotifications => 'Usa Notifiche UnifiedPush';

  @override
  String get useUnifiedPushNotificationsDescription =>
      'Richiede un\'app compatibile';

  @override
  String get user => 'Utente';

  @override
  String get userActions => 'Azioni Utente';

  @override
  String userEntry(Object username) {
    return 'Utente \'$username\'';
  }

  @override
  String get userFormat => 'Formato Utente';

  @override
  String get userLabelHint => 'Questo è il mio utente preferito';

  @override
  String get userLabels => 'Etichette Utente';

  @override
  String get userLabelsSettingsPageDescription =>
      'Puoi aggiungere, modificare o rimuovere le etichette associate agli utenti.';

  @override
  String get userNameColor => 'Colore Nome Utente';

  @override
  String get userNameThickness => 'Spessore Nome Utente';

  @override
  String get userNotLoggedIn => 'L\'utente non ha effettuato il log in';

  @override
  String get userProfiles => 'Profili dell\'Utente';

  @override
  String get userSettingDescription =>
      'Queste impostazioni si sincronizzano con il tuo account Lemmy e vengono applicate solo per ogni account.';

  @override
  String get userStyle => 'Stile Utente';

  @override
  String get username => 'Nome utente';

  @override
  String get usernameFormattingRedirect =>
      'Cerchi la formattazione del nome utente?';

  @override
  String get users => 'Utenti';

  @override
  String versionNumber(Object version) {
    return 'Versione $version';
  }

  @override
  String get video => 'Video';

  @override
  String get videoAutoFullscreen => 'Schermo Intero Automatico';

  @override
  String get videoAutoLoop => 'Loop Video';

  @override
  String get videoAutoMute => 'Muta Video';

  @override
  String get videoAutoPlay => 'Autoplay Video';

  @override
  String get videoDefaultPlaybackSpeed => 'Velocità Riproduzione Predefinita';

  @override
  String get videoLinkHandlingExternal => 'Riprodurre video con app esterna';

  @override
  String get videoPlayerInApp => 'Utilizza player Thunder integrato';

  @override
  String get videoPlayerMode => 'Modalità Player';

  @override
  String get viewAll => 'Vedi tutto';

  @override
  String get viewAllComments => 'Vedi tutti i commenti.';

  @override
  String get viewCommentSource => 'Vedi Fonte Commento';

  @override
  String get viewModlog => 'Visualizza Modlog';

  @override
  String get viewOriginal => 'Visualizza Originale';

  @override
  String get viewPostAsDifferentAccount =>
      'Visualizza post con account diverso';

  @override
  String get viewPostSource => 'Visualizza fonte post';

  @override
  String get viewSource => 'Visualizza fonte';

  @override
  String get viewingAll => 'Visualizza tutto';

  @override
  String visibility(Object visibility) {
    return 'Visibilità: $visibility';
  }

  @override
  String get visitCommunity => 'Visita Comunità';

  @override
  String get visitCommunityInstance => 'Visita Comunità Istanza';

  @override
  String get visitInstance => 'Visita Istanza';

  @override
  String get visitUserInstance => 'Visita Istanza Utente';

  @override
  String get visitUserProfile => 'Visita Profilo dell\'Utente';

  @override
  String get warning => 'Avvertimento';

  @override
  String xDownvotes(Object x) {
    return '$x voti in giù';
  }

  @override
  String xScore(Object x) {
    return '$x punti';
  }

  @override
  String xUpvotes(Object x) {
    return '$x voti in su';
  }

  @override
  String xYearsOld(num count, Object x) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$x anni',
      one: '$x anno',
      zero: '$x anno',
    );
    return '$_temp0';
  }

  @override
  String get yes => 'Sì';

  @override
  String get youMustSelectAJsonFile => 'File .json necessario.';
}
