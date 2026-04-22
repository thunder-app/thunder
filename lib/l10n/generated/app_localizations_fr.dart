// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get about => 'À propos';

  @override
  String get accept => 'Accepter';

  @override
  String get accessibility => 'Accessibilité';

  @override
  String get accessibilityProfilesDescription =>
      'Les profils d\'accessibilité permettent d\'appliquer plusieurs paramètres à la fois pour répondre à une exigence d\'accessibilité particulière.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Comptes',
      one: 'Compte',
      zero: 'Comptes',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'Compte crée le $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'Vos paramètres de compte outrepassent les réglages suivants';

  @override
  String get accountSettings => 'Paramètres de compte';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'Les paramètres du compte Lemmy ont été exportés vers $savedFilePath !';
  }

  @override
  String get accountSettingsImportedSuccessfully =>
      'Les paramètres du compte Lemmy ont été importés !';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return 'Le commentaire sélectionné n\'a pas été trouvé sur \'$instance\'. Retour au compte précédent.';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'La publication sélectionnée n\'a pas été trouvé sur \'$instance\'. Retour au compte précédent.';
  }

  @override
  String get actionColors => 'Couleurs d\'action';

  @override
  String get actionColorsRedirect =>
      'Vous cherchez à personnaliser les couleurs ?';

  @override
  String get actions => 'Actions';

  @override
  String get active => 'Active';

  @override
  String get activity => 'Activité';

  @override
  String get add => 'Ajouter';

  @override
  String get addAccount => 'Ajouter compte';

  @override
  String get addAccountToSeeProfile => 'Connectez-vous pour voir votre compte.';

  @override
  String get addAnonymousInstance => 'Ajouter une instance anonyme';

  @override
  String get addAsCommunityModerator =>
      'Ajouter comme modérateur de la communauté';

  @override
  String get addDiscussionLanguage => 'Ajouter la langue';

  @override
  String get addKeywordFilter => 'Ajouter un mot-clef';

  @override
  String get addOriginalPostBody =>
      'Ajouter le texte accompagnant la publication d\'origine ?';

  @override
  String get addToFavorites => 'Ajouter au favoris';

  @override
  String get addUserLabel => 'Ajouter l\'étiquette d\'utilisateur';

  @override
  String get addedCommunityToSubscriptions => 'Abonné à la communauté';

  @override
  String get addedInstanceMod => 'Ajouter Instance Mod';

  @override
  String get addedModToCommunity => 'Mod ajouté à la communauté';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return '$username ajouté comme modérateur de la communauté';
  }

  @override
  String get admin => 'Admin';

  @override
  String get advanced => 'Avancé';

  @override
  String ago(Object time) {
    return 'Il y a $time';
  }

  @override
  String get all => 'Tout';

  @override
  String get allPosts => 'Tous les messages';

  @override
  String get allowOpenSupportedLinks =>
      'Autoriser l\'application à ouvrir les liens compatibles.';

  @override
  String get alreadyPostedTo => 'Déjà posté dans';

  @override
  String get altText => 'Texte alt';

  @override
  String get alternateSources => 'Sources alternatives';

  @override
  String get always => 'Toujours';

  @override
  String andXMore(Object count) {
    return 'et $count plus';
  }

  @override
  String get animations => 'Animations';

  @override
  String get anonymous => 'Anonyme';

  @override
  String get anonymousInstances => 'Instances anonymes';

  @override
  String get appLanguage => 'Langue de l\'application';

  @override
  String get appearance => 'Apparence';

  @override
  String get applePushNotificationService =>
      'Service de notification push d\'Apple';

  @override
  String get applied => 'Appliqué';

  @override
  String get apply => 'Appliquer';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return 'Les notifications sont autorisées par le système : $yesOrNo';
  }

  @override
  String averageComments(Object x) {
    return '$x commentaires/mois';
  }

  @override
  String averageContributions(Object x) {
    return '$x participations/mois';
  }

  @override
  String averagePosts(Object x) {
    return '$x publications/mois';
  }

  @override
  String get back => 'Retour';

  @override
  String get backButton => 'Bouton retour';

  @override
  String get backToTop => 'Retour en haut';

  @override
  String get backgroundCheckWarning =>
      'Notez que les vérifications de notification consomment plus de batterie';

  @override
  String get ban => 'Bannir';

  @override
  String get banFromCommunity => 'Bannir de la communauté';

  @override
  String get bannedUser => 'Utilisateur banni';

  @override
  String get bannedUserFromCommunity => 'Utilisateur banni de la communauté';

  @override
  String get base => 'Base';

  @override
  String get block => 'Bloquer';

  @override
  String get blockCommunity => 'Bloquer la communauté';

  @override
  String get blockCommunityInstance => 'Bloquer l\'instance de la communauté';

  @override
  String get blockInstance => 'Bloquer l\'instance';

  @override
  String get blockManagement => 'Gestion de blocage';

  @override
  String get blockSettingLabel =>
      'Utilisateurs / Communautés / Instances bloqué(e)s';

  @override
  String get blockUser => 'Bloquer l\'utilisateur';

  @override
  String get blockUserInstance => 'Bloquer l\'instance de l\'utilisateur';

  @override
  String get blockedCommunities => 'Communautés bloquées';

  @override
  String get blockedInstances => 'Instances bloquées';

  @override
  String get blockedUsers => 'Utilisateurs bloqués';

  @override
  String get blue => 'Bleu';

  @override
  String get bold => 'Gras';

  @override
  String get boldCommunityName => 'Nom de la communauté en gras';

  @override
  String get boldInstanceName => 'Nom de l\'instance en gras';

  @override
  String get boldUserName => 'Nom de l\'utilisateur en gras';

  @override
  String get bot => 'Robot';

  @override
  String get browserMode => 'Ouverture des liens';

  @override
  String browsingAnonymously(Object instance) {
    return 'Vous parcourez $instance anonymement.';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get cannotReportOwnComment =>
      'Vous ne pouvez pas signaler votre propre message.';

  @override
  String get cantBlockAdmin =>
      'Vous ne pouvez pas bloquer un administrateur d\'instance.';

  @override
  String get cantBlockYourself => 'Vous ne pouvez pas vous bloquer vous-même.';

  @override
  String get cardPostCardMetadataItems =>
      'Métadonnées dans l\'affichage en Fiches';

  @override
  String get cardView => 'Affichage en fiches';

  @override
  String get cardViewDescription =>
      'Activez l\'affichage en fiches pour ajuster les paramètres';

  @override
  String get cardViewSettings => 'Configuration de l\'affichage en fiches';

  @override
  String get changeAccountSettingsFor =>
      'Modifier les paramètres de compte pour';

  @override
  String get changeNotificationSettings =>
      'Modifier les paramètres de notification…';

  @override
  String get changePassword => 'Changer de mot de passe';

  @override
  String get changePasswordWarning =>
      'Pour changer votre mot de passe, vous allez être redirigé vers le site de votre instance. \n\nÊtes-vous sûr de vouloir continuer ?';

  @override
  String get changeSort => 'Changer l\'ordre';

  @override
  String clearCache(Object cacheSize) {
    return 'Vider le cache ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Vider le cache';

  @override
  String get clearDatabase => 'Effacer la base de données';

  @override
  String get clearPreferences => 'Effacer les préférences';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get clearedCache => 'Le cache a été vidé.';

  @override
  String get clearedDatabase =>
      'La base de données locale a été effacée. Redémarrer Thunder pour que les nouvelles modifications soient prises en compte.';

  @override
  String get clearedUserPreferences =>
      'Effacer toutes les préférences utilisateur';

  @override
  String get close => 'Fermer';

  @override
  String get collapse => 'Minimiser';

  @override
  String get collapseCommentPreview => 'Réduire l\'aperçu des commentaires';

  @override
  String get collapseInformation => 'Réduire l\'information';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Masquer les commentaires parents lorsqu\'ils sont réduit';

  @override
  String get collapsePost => 'Réduire la publication';

  @override
  String get collapsePostPreview => 'Réduire l\'aperçu de publication';

  @override
  String get collapseSpoiler => 'Minimiser la révélation';

  @override
  String get color => 'Couleur';

  @override
  String get colorizeCommunityName => 'Coloriser le nom de la communauté';

  @override
  String get colorizeInstanceName => 'Coloriser le nom de l\'instance';

  @override
  String get colorizeUserName => 'Coloriser le nom de l\'utilisateur';

  @override
  String get colors => 'Couleurs';

  @override
  String get combineCommentScores => 'Combiner les scores de commentaire';

  @override
  String get combineCommentScoresLabel => 'Combiner les scores de commentaires';

  @override
  String get combineNavAndFab =>
      'Combiner le bouton d\'action flottant et les boutons de navigation';

  @override
  String get combineNavAndFabDescription =>
      'Le bouton d\'action flottant s\'affiche entre les boutons de navigation.';

  @override
  String get comfortable => 'Large';

  @override
  String get comment => 'Commentaire';

  @override
  String get commentActions => 'Actions des commentaires';

  @override
  String get commentBehaviourSettings => 'Commentaires';

  @override
  String get commentFontScale => 'Taille de police des commentaires';

  @override
  String get commentPreview =>
      'Montrer un aperçu des commentaires avec la configuration';

  @override
  String get commentReported => 'Le commentaire a été signalé pour examen.';

  @override
  String get commentSavedAsDraft => 'Commentaire sauvegarder comme brouillon';

  @override
  String get commentShowUserAvatar =>
      'Afficher la photo d\'avatar de l\'utilisateur';

  @override
  String get commentShowUserInstance =>
      'Afficher l\'instance de l\'utilisateur';

  @override
  String get commentSortType => 'Type d\'ordre des commentaires';

  @override
  String get commentSwipeActions => 'Actions du balayage de commentaire';

  @override
  String get commentSwipeGesturesHint =>
      'Vous souhaitez utiliser les boutons ? Activez-les dans la section des commentaires des paramètres généraux.';

  @override
  String get comments => 'Commentaires';

  @override
  String get communities => 'Communautés';

  @override
  String get community => 'Communauté';

  @override
  String get communityActions => 'Actions de communauté';

  @override
  String communityEntry(Object community) {
    return 'Communauté \'$community\'';
  }

  @override
  String get communityFormat => 'Format de la communauté';

  @override
  String get communityNameColor => 'Couleur du nom de la communauté';

  @override
  String get communityNameThickness => 'Densité du nom de la communauté';

  @override
  String get communityStyle => 'Style de la communauté';

  @override
  String get compact => 'Compact';

  @override
  String get compactPostCardMetadataItems =>
      'Métadonnées de l\'affichage en liste';

  @override
  String get compactView => 'Affichage en liste';

  @override
  String get compactViewDescription =>
      'Activez l\'affichage en liste pour modifier les paramètres';

  @override
  String get compactViewSettings => 'Paramètres de l\'affichage en liste';

  @override
  String get condensed => 'Condensé';

  @override
  String get confirm => 'Confirmer';

  @override
  String get confirmLogOutBody => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get confirmLogOutTitle => 'Déconnecter ?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Êtes-vous sûr de vouloir marquer toutes les réponses, toutes les mentions, et tous les messages comme lu ?';

  @override
  String get confirmMarkAllAsReadTitle => 'Tout marquer comme lu ?';

  @override
  String get confirmResetCommentPreferences =>
      'Ceci va réinitialiser toutes les préférences des commentaires. Voulez-vous continuer ?';

  @override
  String get confirmResetPostPreferences =>
      'Cette opération réinitialisera toutes les préférences de publication. Voulez-vous continuer ?';

  @override
  String get confirmUnsubscription =>
      'Êtes-vous sûr de vouloir vous désabonner ?';

  @override
  String connectedToUnifiedPushDistributorApp(Object app) {
    return 'Connecté à $app';
  }

  @override
  String get contentManagement => 'Gestion du contenu';

  @override
  String get contentWarning => 'Avertissements sur le contenu';

  @override
  String get controversial => 'Controversé';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get copy => 'Copier';

  @override
  String get copyComment => 'Copier le commentaire';

  @override
  String get copySelected => 'Copier la sélection';

  @override
  String get copyText => 'Copier le texte';

  @override
  String get couldNotDetermineCommentDelete =>
      'Erreur : Impossible de déterminer la publication à supprimer.';

  @override
  String get couldNotDeterminePostComment =>
      'Erreur : Impossible de déterminer la publication à commenter.';

  @override
  String get couldntCreateReport =>
      'Votre signalement de commentaire n\'a pas pu être transmis pour le moment. Veuillez réessayer plus tard';

  @override
  String get couldntFindPost =>
      'Impossible de charger la publication. Elle a peut-être été supprimée ou retirée.';

  @override
  String countComments(Object count) {
    return '$count Commentaires';
  }

  @override
  String countLocalSubscribers(Object count) {
    return '$count Abonnés locaux';
  }

  @override
  String countPosts(Object count) {
    return '$count Publications';
  }

  @override
  String countSubscribers(Object count) {
    return '$count Abonnés';
  }

  @override
  String countUsers(Object count) {
    return '$count utilisateurs';
  }

  @override
  String countUsersActiveDay(Object count) {
    return '$count utilisateurs/jour';
  }

  @override
  String countUsersActiveHalfYear(Object count) {
    return '$count utilisateurs/6 mois';
  }

  @override
  String countUsersActiveMonth(Object count) {
    return '$count utilisateurs/mois';
  }

  @override
  String countUsersActiveWeek(Object count) {
    return '$count utilisateurs/semaine';
  }

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createComment => 'Créer un commentaire';

  @override
  String get createNewCrossPost => 'Créer une nouvelle publication croisée';

  @override
  String get createPost => 'Créer publication';

  @override
  String created(Object date) {
    return 'Créé(e) le $date';
  }

  @override
  String get createdToday => 'Créé(e) aujourd\'hui';

  @override
  String get creator => 'Créateur';

  @override
  String crossPostedFrom(Object postUrl) {
    return 'Publication croisé depuis: $postUrl';
  }

  @override
  String get crossPostedTo => 'Publication croisée sur';

  @override
  String get currentLongPress => 'Actuellement défini comme appui long';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Mode de notification actuel : $mode';
  }

  @override
  String get currentSinglePress => 'Actuellement défini comme appui simple';

  @override
  String get customizeSwipeActions =>
      'Personnalisation des actions de balayage (touchez pour modifier)';

  @override
  String get dangerZone => 'Actions sensibles';

  @override
  String get dark => 'Sombre';

  @override
  String get databaseExportWarning =>
      'La base de données peut contenir des informations sensibles en relation avec votre compte Lemmy. Si vous l\'exportez, vous ne devriez pas la partager avec quiconque. Voulez-vous continuer ?';

  @override
  String databaseExportedSuccessfully(Object savedFilePath) {
    return 'La base de données a été exportée avec succès vers \'$savedFilePath\'';
  }

  @override
  String get databaseImportedSuccessfully =>
      'La base de données a été importée avec succès !';

  @override
  String get databaseNotExportedSuccessfully =>
      'La base de données n\'a pas été exportée avec succès ou l\'opération a été annulée.';

  @override
  String get databaseNotImportedSuccessfully =>
      'La base de données n\'a pas été importée avec succès, ou l\'opération a été annulée.';

  @override
  String get dateFormat => 'Format de date';

  @override
  String get debug => 'Déboguer';

  @override
  String get debugDescription =>
      'Les paramètres de débogage suivants ne doivent être utilisés qu\'à des fins de dépannage.';

  @override
  String get debugNotificationsDescription =>
      'Utiliser les options suivantes afin de résoudre les problèmes liés aux notifications.';

  @override
  String get decline => 'Refuser';

  @override
  String get defaultColor => 'Par défaut';

  @override
  String get defaultCommentSortType =>
      'Type de classement de commentaire par défaut';

  @override
  String get defaultFeedSortType => 'Type de classement de fil par défaut';

  @override
  String get defaultFeedType => 'Type de fil par défaut';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteAccount => 'Effacer le compte';

  @override
  String get deleteAccountDescription =>
      'Pour supprimer définitivement votre compte, vous serez redirigé vers votre site d\'instance. \n\nÊtes-vous sûr de vouloir continuer ?';

  @override
  String get deleteComment => 'Supprimer le commentaire';

  @override
  String get deleteDraftConfirmation =>
      'Are you sure you want to delete this draft?';

  @override
  String get deleteImageConfirmMessage =>
      'Êtes-vous sûr de vouloir supprimer cette image ?';

  @override
  String get deleteImageConfirmTitle => 'Supprimer ?';

  @override
  String get deleteLocalDatabase => 'Supprimer la base de donnée locale';

  @override
  String get deleteLocalDatabaseDescription =>
      'Cette action va supprimer la base de donnée locale et vous déconnecter de tous vos comptes\n\nVoulez-vous continuer ?';

  @override
  String get deleteLocalPreferences => 'Supprimer les préférences locales';

  @override
  String get deleteLocalPreferencesDescription =>
      'Cette opération effacera toutes vos préférences d\'utilisateur et tous les paramètres de Thunder.\n\nVoulez-vous continuer ?';

  @override
  String get deletePost => 'Supprimer le poste';

  @override
  String get deleteUserLabelConfirmation =>
      'Êtes-vous sûr de vouloir supprimer cette étiquette ?';

  @override
  String get deleted => 'Supprimé(e)';

  @override
  String get deletedByCreator => 'Supprimé par le créateur';

  @override
  String get deletedByModerator => 'Supprimé par le modérateur';

  @override
  String get deletedComment => 'Commentaire supprimé';

  @override
  String get deletedPost => 'Poste supprimé';

  @override
  String get deselectUndeterminedWarning =>
      'If you deselect Undetermined, you will not see most content.';

  @override
  String detailedReason(Object reason) {
    return 'Raison : $reason';
  }

  @override
  String get dimReadPosts => 'Griser les publications lues.';

  @override
  String get disable => 'Désactiver';

  @override
  String get disablePushNotifications => 'Désactiver les notifications';

  @override
  String get disabled => 'Désactivé(e)';

  @override
  String get discussionLanguages => 'Langues de discussion';

  @override
  String get discussionLanguagesTooltip =>
      'Le contenu est filtré à la langue sélectionnée.';

  @override
  String get dismissRead => 'Rejeter la lecture';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayUserScore => 'Afficher les scores utilisateur (karma).';

  @override
  String get dividerAppearance => 'Divider Appearance';

  @override
  String get doNotShowAgain => 'Do Not Show Again';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Found multiple compatible apps; please install only one';

  @override
  String get downloadingMedia =>
      'Téléchargement de fichier multimédia à partager…';

  @override
  String get downvote => 'Vote négatif';

  @override
  String get downvoteColor => 'Downvote Color';

  @override
  String get downvoted => 'Downvoted';

  @override
  String get downvotesDisabled =>
      'Les votes négatifs sont désactivés sur cette instance.';

  @override
  String get drafts => 'Drafts';

  @override
  String get edit => 'Éditer';

  @override
  String get editComment => 'Éditer commentaire';

  @override
  String get editPost => 'Éditer la publication';

  @override
  String get email => 'Email';

  @override
  String get empty => 'Vide';

  @override
  String get emptyInbox => 'Boite de réception vide';

  @override
  String get emptyUri =>
      'Le lien est vide. Veuillez fournir un lien dynamique valide pour continuer.';

  @override
  String get enableCommentNavigation =>
      'Activer la navigation dans les commentaires';

  @override
  String get enableExperimentalFeatures => 'Enable experimental features';

  @override
  String get enableFeedFab => 'Activer le bouton flottant sur les fils';

  @override
  String get enableFloatingButtonOnFeeds =>
      'Activer bouton flottant sur les fils';

  @override
  String get enableFloatingButtonOnPosts =>
      'Activer bouton flottant sur les publications';

  @override
  String get enableInboxNotifications => 'Enable Inbox Notifications';

  @override
  String get enablePostFab =>
      'Activer le bouton flottant dans les publications';

  @override
  String get endOfComments => 'End of comments';

  @override
  String get endSearch => 'Terminer la recherche';

  @override
  String errorDeletingImage(Object error) {
    return 'There was an error deleting the image: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Impossible de télécharger le fichier multimédia à partager : $errorMessage';
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
      'Une erreur s\'est produite lors du traitement du lien. Il se peut qu\'il ne soit pas disponible sur votre instance.';

  @override
  String get excessiveApiCallsWarning =>
      'Your feed may be taking a while to load due to keyword filters.';

  @override
  String get expand => 'Expand';

  @override
  String get expandCommentPreview => 'Développer l\'aperçu des commentaires';

  @override
  String get expandInformation => 'Maximiser l\'information';

  @override
  String get expandOptions => 'Développer les options';

  @override
  String get expandPost => 'Développer la publication';

  @override
  String get expandPostPreview => 'Développer l\'aperçu de publication';

  @override
  String get expandSpoiler => 'Maximiser la révélation';

  @override
  String get expanded => 'Développer';

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
    return 'Échec du blocage : $errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return 'Failed to communicate with Thunder notification server at $serverAddress.';
  }

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return 'Impossible de charger les blocs : $errorMessage';
  }

  @override
  String get failedToLoadVideo => 'Failed to load video. Open link in browser?';

  @override
  String get failedToPerformAction => 'Failed to perform action';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'Impossible de débloquer : $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Failed to update notification settings';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Favoris';

  @override
  String get featuredPost => 'Featured Post';

  @override
  String get feed => 'Fil';

  @override
  String get feedBehaviourSettings => 'Fil';

  @override
  String get feedSettings => 'Feed Settings';

  @override
  String get feedTypeAndSorts => 'Type de fil et tri par défaut';

  @override
  String get fetchAccountError => 'Impossible de déterminer le compte';

  @override
  String filteringBy(Object entity) {
    return 'Filtrer par $entity';
  }

  @override
  String get filters => 'Filtres';

  @override
  String get floatingActionButton => 'Bouton d\'action flottant';

  @override
  String get floatingActionButtonInformation =>
      'Thunder dispose d\'une expérience FAB entièrement personnalisable qui prend en charge quelques gestes.\n- Glissez vers le haut pour révéler des actions FAB supplémentaires\n- Balayez vers le bas ou vers le haut pour cacher ou révéler le FAB.\n\nPour personnaliser les actions principales et secondaires du FAB, appuyez longuement sur l\'une des actions ci-dessous.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'Indique l\'action d\'appui long de la FAB.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'Indique l\'action d\'appui simple de la FAB.';

  @override
  String get fonts => 'Fonts';

  @override
  String get forward => 'Forward';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Found compatible app; restart Thunder to connect';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Balayer n\'importe où pour revenir en arrière lorsque les gestes de gauche à droite sont désactivés';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get fullscreenSwipeGestures => 'Geste de balayage en plein écran';

  @override
  String get general => 'Général';

  @override
  String get generalSettings => 'Paramètres généraux';

  @override
  String get gestures => 'Gestes';

  @override
  String get gettingStarted => 'Pour commencer';

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
  String get hideNsfwPostsFromFeed => 'Masquer les publications NSFW du fil';

  @override
  String get hideNsfwPreviews => 'Masquer les aperçus NSFW';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get hideThumbnails => 'Hide Thumbnails';

  @override
  String get hideTopBarOnScroll =>
      'Masquer la barre du haut pendant le défilement';

  @override
  String get hostInstance => 'Host Instance';

  @override
  String get hot => 'Tendances';

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
  String get importExportSettings => 'Paramètres d\'import/export';

  @override
  String get importExportThunderSettings => 'Import/Export Thunder Settings';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Import Lemmy account settings';

  @override
  String get importSettings => 'Paramètres d\'import';

  @override
  String inReplyTo(Object post, Object community) {
    return 'En réponse à $post dans $community';
  }

  @override
  String get in_ => 'in';

  @override
  String get inbox => 'Boite de réception';

  @override
  String get includeCommunity => 'Inclure la communauté';

  @override
  String get includeExternalLink => 'Inclure lien externe';

  @override
  String get includeImage => 'Inclure image';

  @override
  String get includePostLink => 'Inclure un lien vers la publication';

  @override
  String get includeText => 'Inclure texte';

  @override
  String get includeTitle => 'Inclure le titre';

  @override
  String get information => 'Information';

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
    return '$instance a déjà été ajouté.';
  }

  @override
  String get instanceNameColor => 'Instance Name Color';

  @override
  String get instanceNameThickness => 'Instance Name Thickness';

  @override
  String get instances => 'Instances';

  @override
  String get internetOrInstanceIssues =>
      'Il se peut que vous ne soyez pas connecté à internet ou que votre instance soit actuellement indisponible.';

  @override
  String get invalidUrl => 'Invalid URL format';

  @override
  String joined(Object x) {
    return 'Joined $x';
  }

  @override
  String get keywordFilterDescription =>
      'Filtre les publications contenant des mots-clés dans le titre ou le corps du message';

  @override
  String get keywordFilters => 'Filtres de mots-clés';

  @override
  String get label => 'Label';

  @override
  String get language => 'Langue';

  @override
  String get languageFilters => 'Looking for language filters?';

  @override
  String get languageNotAllowed =>
      'La communauté dans laquelle vous publiez ne permet pas la publication de messages dans la langue que vous avez sélectionnée. Essayez une autre langue.';

  @override
  String get large => 'Large';

  @override
  String get leftLongSwipe => 'Balayage long à gauche';

  @override
  String get leftShortSwipe => 'Balayage court à gauche';

  @override
  String get light => 'Light';

  @override
  String link(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lien',
      one: 'Lien',
      zero: 'Lien',
    );
    return '$_temp0 ';
  }

  @override
  String get linkActions => 'Actions de lien';

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
  String get linksBehaviourSettings => 'Liens';

  @override
  String loadMorePlural(Object count) {
    return 'Charger $count réponses supplémentaires…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Charger $count réponse supplémentaire…';
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
  String get localPosts => 'Publications locales';

  @override
  String get lockPost => 'Lock Post';

  @override
  String get locked => 'Locked';

  @override
  String get lockedPost => 'Locked Post';

  @override
  String get logOut => 'Déconnexion';

  @override
  String get login => 'Connexion';

  @override
  String get loginAttemptCanceled => 'Login attempt canceled.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Impossible de se connecter. Veuillez réessayer :($errorMessage)';
  }

  @override
  String get loginSucceeded => 'Connecté.';

  @override
  String get loginToPerformAction =>
      'Vous devez être connecté pour accomplir cette tâche.';

  @override
  String get loginToSeeInbox =>
      'Connectez-vous pour voir votre boîte de réception';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Looking for account-specific feed settings?';

  @override
  String get malformedUri =>
      'Le lien que vous avez fourni est dans un format non supporté. Veuillez vous assurer qu\'il s\'agit d\'un lien valide.';

  @override
  String get manageAccounts => 'Gérer les comptes';

  @override
  String get manageMedia => 'Manage Media';

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get markPostAsReadOnMediaView =>
      'Marquer comme lu après lecture du contenu';

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
  String get metadataFontScale => 'Taille de police de métadonnée';

  @override
  String get missingErrorMessage => 'Aucun message d\'erreur disponible';

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
  String get mostComments => 'Les plus commentés';

  @override
  String get mustBeLoggedIn => 'You need to be logged in';

  @override
  String get mustBeLoggedInComment => 'Vous devez être connecté pour commenter';

  @override
  String get mustBeLoggedInPost =>
      'Vous devez être connecté pour créer une publication';

  @override
  String get names => 'Names';

  @override
  String get navbarDoubleTapGestures =>
      'Gestes de double appui sur la barre de navigation';

  @override
  String get navbarSwipeGestures => 'Balayer la barre de navigation';

  @override
  String get navigateDown => 'Commentaire suivant';

  @override
  String get navigateUp => 'Commentaire précédent';

  @override
  String get navigation => 'Navigation';

  @override
  String get nestedCommentIndicatorColor =>
      'Couleur de l\'indicateur de commentaire imbriqué';

  @override
  String get nestedCommentIndicatorStyle =>
      'Style de l\'indicateur de commentaire imbriqué';

  @override
  String get never => 'Never';

  @override
  String get newComments => 'Nouveaux commentaires';

  @override
  String get newPost => 'Nouvelle publication';

  @override
  String get new_ => 'Nouveau';

  @override
  String get no => 'No';

  @override
  String get noAccountsAdded => 'No accounts have been added';

  @override
  String get noAnonymousInstances => 'No anonymous instances have been added';

  @override
  String get noCommentsFound => 'Aucun commentaire trouvé';

  @override
  String get noCommunitiesFound => 'Aucune communauté trouvée';

  @override
  String get noCommunityBlocks => 'Aucune communautés bloquées';

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
  String get noFavoritedCommunities => 'Pas de communautés préférées';

  @override
  String get noImages => 'It looks like you have not uploaded any images.';

  @override
  String get noInstanceBlocks => 'Pas d\'instances bloquées.';

  @override
  String get noItems => 'No items';

  @override
  String get noKeywordFilters => 'Aucun filtre par mot-clé ajouté';

  @override
  String get noLanguage => 'Pas de langue';

  @override
  String get noMatrixUserSet => 'No matrix user set';

  @override
  String get noMentions => 'No mentions';

  @override
  String get noMessages => 'No messages';

  @override
  String get noPostsFound => 'Aucune publication trouvée';

  @override
  String get noProfileBioSet => 'No profile bio set';

  @override
  String get noReferencesToImage =>
      'No posts or comments were found containing this image. However, it may be used elsewhere on the internet.';

  @override
  String get noReplies => 'No replies';

  @override
  String get noResultsFound => 'Aucun résultat trouvé.';

  @override
  String get noSubscriptions => 'Pas d\'abonnements';

  @override
  String get noUserBlocks => 'Pas d\'utilisateurs bloqués.';

  @override
  String get noUserLabels => 'You have not created any user labels yet';

  @override
  String get noUsersFound => 'Aucun utilisateur trouvé';

  @override
  String get noVisibleComments =>
      'Comments may not be visible because the community is blocked.';

  @override
  String get none => 'None';

  @override
  String get normal => 'Normal';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance ne semble pas être une instance de Lemmy valide';
  }

  @override
  String get notValidUrl => 'URL invalide';

  @override
  String get nothingToShare => 'Rien à partager';

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
  String get off => 'éteint';

  @override
  String get offline => 'offline';

  @override
  String get ok => 'OK';

  @override
  String get old => 'Ancien';

  @override
  String get on => 'allumé';

  @override
  String get onWifi => 'On Wifi';

  @override
  String get onlyModsCanPostInCommunity =>
      'Seuls les modérateurs peuvent publier dans cette communauté';

  @override
  String get open => 'Ouvrir';

  @override
  String get openAccountSwitcher => 'Ouvrir le sélecteur de compte';

  @override
  String get openByDefault => 'Ouvrir par défaut';

  @override
  String get openInBrowser => 'Ouvrir dans le navigateur';

  @override
  String get openInstance => 'Ouvrir l\'instance';

  @override
  String get openLinksInExternalBrowser =>
      'Ouvrir les liens dans un navigateur externe';

  @override
  String get openLinksInReaderMode => 'Ouvrir les liens en mode lecture';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get orange => 'Orange';

  @override
  String get originalPoster => 'Original Poster';

  @override
  String get overview => 'Vue d\'ensemble';

  @override
  String get password => 'Mot de passe';

  @override
  String get pending => 'En attente';

  @override
  String performedBy(Object user) {
    return 'Performed by: $user';
  }

  @override
  String get permissionDenied => 'Permission refusé';

  @override
  String get permissionDeniedMessage =>
      'Thunder a besoin de certaines permissions pour enregistrer cette image, qui lui ont été refusées.';

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
  String get postBehaviourSettings => 'Publications';

  @override
  String get postBody => 'Corps de publication';

  @override
  String get postBodySettings => 'Paramètres de corps de publication';

  @override
  String get postBodySettingsDescription =>
      'Ces paramètres affectent l\'affichage du corps de publication';

  @override
  String get postBodyShowCommunityInstance => 'Show Community Instance';

  @override
  String get postBodyShowUserInstance => 'Show User Instance';

  @override
  String get postBodyViewType => 'Type de vue du corps de publication';

  @override
  String get postContentFontScale =>
      'Taille de police du contenu de publication';

  @override
  String get postCreatedSuccessfully => 'Post created successfully!';

  @override
  String get postFlairs => 'Flairs';

  @override
  String get postFlairsUnavailable =>
      'No flair options available for this community';

  @override
  String get postLocked => 'Publication verrouillée. Impossible de répondre.';

  @override
  String get postMetadataInstructions =>
      'You can customize the metadata information by dragging and dropping the desired information';

  @override
  String get postNSFW => 'Marquer comme NSFW';

  @override
  String get postPreview =>
      'Affiche un aperçu de la publication avec les paramètres données';

  @override
  String get postSavedAsDraft => 'Publication enregistrée comme brouillon';

  @override
  String get postShowUserInstance => 'Show User Instance';

  @override
  String get postSwipeActions => 'Actions du balayage des publications';

  @override
  String get postSwipeGesturesHint =>
      'Vous souhaitez utiliser des boutons à la place ? Modifiez les boutons qui apparaissent dans les publications dans les paramètres généraux.';

  @override
  String get postTags => 'Tags';

  @override
  String get postTagsHelperText => 'Separate tags with commas';

  @override
  String get postTitle => 'Titre';

  @override
  String get postTitleFontScale => 'Taille de police du titre des publications';

  @override
  String get postTogglePreview => 'Aperçu des modifications';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Impossible d\'envoyer l\'image';

  @override
  String get postViewType => 'Type de vue des publications';

  @override
  String get posts => 'Publications';

  @override
  String get preview => 'Prévisualisation';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile appliqué avec succès !';
  }

  @override
  String get profileBio => 'Profile Bio';

  @override
  String get profiles => 'Profils';

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
  String get reachedTheBottom => 'Hum. Il semble que vous ayez touché le fond.';

  @override
  String get read => 'Read';

  @override
  String get readAll => 'Tout lire';

  @override
  String get readerMode => 'Reader mode';

  @override
  String get reason => 'Reason';

  @override
  String get red => 'Red';

  @override
  String get reduceAnimations => 'Réduire les animations';

  @override
  String get reducesAnimations =>
      'Réduire les animations utilisées dans Thunder';

  @override
  String get refresh => 'Rafraîchir';

  @override
  String get refreshContent => 'Rafraîchir le contenu';

  @override
  String get removalReason => 'Removal Reason';

  @override
  String get remove => 'Supprimer';

  @override
  String get removeAccount => 'Supprimer compte';

  @override
  String get removeAsCommunityModerator => 'Remove as Community Moderator';

  @override
  String get removeComment => 'Remove Comment';

  @override
  String get removeFromFavorites => 'Supprimer des favoris';

  @override
  String get removeInstance => 'Supprimer l\'instance';

  @override
  String removeKeyword(Object keyword) {
    return 'Supprimer \"$keyword\" ?';
  }

  @override
  String get removeKeywordFilter => 'Supprimer le mot-clé';

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
  String get removedCommunityFromSubscriptions => 'Désabonné de la communauté';

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
      other: 'Réponses',
      one: 'Réponse',
      zero: 'Réponse',
    );
    return '$_temp0';
  }

  @override
  String get replyColor => 'Reply Color';

  @override
  String get replyNotSupported =>
      'Répondre depuis cette page n\'est actuellement pas supporté';

  @override
  String get replyToComment => 'Reply to Comment';

  @override
  String get replyToPost => 'Répondre à la publication';

  @override
  String replyingTo(Object author) {
    return 'Répondre à $author';
  }

  @override
  String report(num count) {
    return 'Signaler';
  }

  @override
  String get reportComment => 'Signaler le commentaire';

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
  String get reset => 'Réinitialiser';

  @override
  String get resetCommentPreferences =>
      'Réinitialiser les préférences de commentaires';

  @override
  String get resetPostPreferences =>
      'Réinitialiser les préférences de publication';

  @override
  String get resetPreferences => 'Réinitialiser les préférences';

  @override
  String get resetPreferencesAndData =>
      'Réinitialiser les préférences et données';

  @override
  String get restore => 'Restaurer';

  @override
  String get restoreComment => 'Restore Comment';

  @override
  String get restorePost => 'Restore Post';

  @override
  String get restoredComment => 'Restored comment';

  @override
  String get restoredCommentFromDraft =>
      'Commentaire restauré depuis les brouillons';

  @override
  String get restoredCommunity => 'Restored Community';

  @override
  String get restoredPost => 'Restored Post';

  @override
  String get restoredPostFromDraft =>
      'Publication restauré depuis les brouillons';

  @override
  String get retry => 'Réessayer';

  @override
  String get rightLongSwipe => 'Balayage long à droite';

  @override
  String get rightShortSwipe => 'Balayage court à droite';

  @override
  String get save => 'Enregistrer';

  @override
  String get saveColor => 'Save Color';

  @override
  String get saveSettings => 'Enregistrer les paramètres';

  @override
  String get saved => 'Enregistrer';

  @override
  String get scaled => 'Échelle';

  @override
  String get scrapeMissingLinkPreviews =>
      'Récupérer les aperçus de liens manquants';

  @override
  String get screenReaderProfile => 'Profil du lecteur d\'écran';

  @override
  String get screenReaderProfileDescription =>
      'Optimise Thunder pour les lecteurs d\'écran en réduisant les éléments globaux et en supprimant les gestes potentiellement conflictuels.';

  @override
  String get search => 'Rechercher';

  @override
  String get searchByText => 'Rechercher par texte';

  @override
  String get searchByUrl => 'Rechercher par URL';

  @override
  String get searchComments => 'Rechercher commentaires';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return 'Rechercher les commentaires fédérés avec $instance';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return 'Rechercher des communautés fédérées avec $instance';
  }

  @override
  String searchInstance(Object instance) {
    return 'Rechercher $instance';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return 'Search for instances federated with $instance';
  }

  @override
  String get searchPostSearchType => 'Sélectionner le type de recherche';

  @override
  String searchPostsFederatedWith(Object instance) {
    return 'Rechercher de publications fédérées avec $instance';
  }

  @override
  String get searchTerm => 'Rechercher les termes';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Rechercher les utilisateurs fédérés avec $instance';
  }

  @override
  String get selectAccountToCommentAs => 'Select account to comment as';

  @override
  String get selectAccountToPostAs => 'Select account to post as';

  @override
  String get selectAll => 'Select all';

  @override
  String get selectCommunity => 'Sélectionnez une communauté (obligatoire)';

  @override
  String get selectFeedType => 'Sélectionnez le type de fil';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get selectSearchType => 'Sélectionner le type de recherche';

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
    return 'Une erreur de serveur a été rencontrée lors de l\'obtention de plus de commentaires : $message';
  }

  @override
  String get setAction => 'Définir une action';

  @override
  String get setLongPress => 'Définir comme action d\'appui long';

  @override
  String get setShortPress => 'Définir comme action d\'appui court';

  @override
  String get settingOverrideLabel =>
      'These settings override Thunder\'s default settings.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'Les paramètres de type $settingType ne sont pas encore pris en charge.';
  }

  @override
  String get settings => 'Paramètres';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'Settings were successfully saved to \'$savedFilePath\'';
  }

  @override
  String get settingsFeedCards =>
      'Ces paramètres s\'appliquent aux cartes du fil principal, les actions étant toujours disponibles lors de l\'ouverture des publications.';

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
  String get share => 'Partager';

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
  String get shareLink => 'Partager le lien';

  @override
  String get shareMedia => 'Partager un fichier multimédia';

  @override
  String get shareMediaLink => 'Share Media Link';

  @override
  String get shareOriginalLink => 'Share Original Link';

  @override
  String get sharePost => 'Partager la publication';

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
  String get showAll => 'Tout afficher';

  @override
  String get showBotAccounts => 'Afficher les comptes de bots';

  @override
  String get showCommentActionButtons =>
      'Afficher les boutons d\'action des commentaires';

  @override
  String get showCommunityDisplayNames => 'Show Community Display Names';

  @override
  String get showCrossPosts => 'Montrer les publications croisées';

  @override
  String get showEdgeToEdgeImages => 'Afficher les images bord à bord';

  @override
  String get showExpandedTaglines => 'Show expanded taglines';

  @override
  String get showFullDate => 'Show Full Date';

  @override
  String get showFullDateDescription => 'Show full date on posts';

  @override
  String get showFullHeightImages => 'Afficher les images en pleine hauteur';

  @override
  String get showHiddenPosts => 'Show Hidden Posts';

  @override
  String get showInAppUpdateNotifications =>
      'Être notifié des nouvelles versions sur GitHub';

  @override
  String get showLess => 'Voir moins';

  @override
  String get showMore => 'Voir plus';

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
  String get showPassword => 'Afficher mot de passe';

  @override
  String get showPostAuthor => 'Afficher l\'auteur de la publication';

  @override
  String get showPostAuthorSubtitle =>
      'Post author is always shown in community feeds';

  @override
  String get showPostCommunityFirst => 'Show Community and Author First';

  @override
  String get showPostCommunityIcons => 'Afficher les icônes de communauté';

  @override
  String get showPostSaveAction => 'Afficher le bouton sauvegarder';

  @override
  String get showPostTextContentPreview => 'Afficher l\'aperçu de texte';

  @override
  String get showPostTitleFirst => 'Afficher le titre en premier';

  @override
  String get showPostVoteActions => 'Afficher les boutons de vote';

  @override
  String get showReadPosts => 'Afficher les publications lues';

  @override
  String get showSavedContent => 'Show saved content';

  @override
  String get showScoreCounters => 'Afficher les notes des utilisateurs';

  @override
  String get showScores => 'Afficher les scores de publication/commentaire';

  @override
  String get showTextPostIndicator => 'Show Text Post Indicator';

  @override
  String get showThumbnailPreviewOnRight => 'Afficher les vignettes à droite';

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
  String get showUserDisplayNames =>
      'Afficher les noms d\'affichage des utilisateurs';

  @override
  String get showUserInstance => 'Afficher l\'instance de l\'utilisateur';

  @override
  String get sidebar => 'Barre latérale';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Double-clic sur la barre de navigation inférieure pour ouvrir la barre latérale';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Balayer la barre de navigation inférieure pour ouvrir la barre latérale';

  @override
  String get small => 'Small';

  @override
  String get somethingWentWrong => 'Oups, quelque chose a mal tourné !';

  @override
  String get sortBy => 'Trier par';

  @override
  String get sortByTop => 'Trier par Top';

  @override
  String get sortOptions => 'Options de tri';

  @override
  String get spoiler => 'Révélation';

  @override
  String get standard => 'Standard';

  @override
  String get stats => 'Stats';

  @override
  String get status => 'Status';

  @override
  String get submit => 'Soumettre';

  @override
  String get subscribe => 'S\'abonner';

  @override
  String get subscribeToCommunity => 'S\'abonner à la communauté';

  @override
  String get subscribed => 'Abonné';

  @override
  String get subscriptionRequestSent => 'Subscription request sent';

  @override
  String get subscriptions => 'Abonnements';

  @override
  String successfullyBannedUser(Object username) {
    return 'Banned $username';
  }

  @override
  String get successfullyBlocked => 'Bloqué.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return 'Bloqué $communityName';
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
  String get successfullyUnblocked => 'Débloqué.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return 'Débloqué $communityName';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return 'Unblocked $username';
  }

  @override
  String get suchAs => 'such as';

  @override
  String get suggestedTitle => 'Titre suggéré';

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
  String get tabletMode => 'Mode tablette (affichage sur deux colonnes)';

  @override
  String get tapToExit => 'Retour deux fois pour quitter';

  @override
  String get tappableAuthorCommunity => 'Auteurs et communautés cliquable';

  @override
  String get teal => 'Teal';

  @override
  String get testBackgroundNotificationDescription =>
      'Thunder will close itself and then attempt to generate a notification in the background. (It will take at least 15 minutes.)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'Thunder will ask the notification server to send a delayed notification and then close itself. (It may take a few minutes.)';

  @override
  String get text => 'Texte';

  @override
  String get textActions => 'Text Actions';

  @override
  String get theme => 'Thème';

  @override
  String get themeAccentColor => 'Couleurs d\'accentuation';

  @override
  String get themePrimary => 'Theme Primary';

  @override
  String get themeSecondary => 'Theme Secondary';

  @override
  String get themeTertiary => 'Theme Tertiary';

  @override
  String get theming => 'Thème';

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
      'Erreur : Délai d\'attente dépassé lors de la tentative de récupération des commentaires';

  @override
  String get timeoutErrorMessage =>
      'Il y a eu un délai d\'attente dépassé pour une réponse.';

  @override
  String get timeoutSaveComment =>
      'Erreur : Délai dépassé lors de la tentative d\'enregistrement d\'un commentaire';

  @override
  String get timeoutSavingPost =>
      'Erreur : Délai dépassé lors de la tentative d\'enregistrement de la publication.';

  @override
  String get timeoutUpvoteComment =>
      'Erreur : Délai dépassé lors de la tentative de vote sur un commentaire';

  @override
  String get timeoutVotingPost =>
      'Erreur : Délai dépassé lors de la tentative de vote de la publication.';

  @override
  String get toggelRead => 'Basculer vers la lecture';

  @override
  String get top => 'Top';

  @override
  String get topAll => 'Top depuis le début';

  @override
  String get topDay => 'Top aujourd\'hui';

  @override
  String get topHour => 'Top dernière heure';

  @override
  String get topMonth => 'Top mois';

  @override
  String get topNineMonths => 'Top 9 derniers mois';

  @override
  String get topSixHour => 'Top 6 dernières heures';

  @override
  String get topSixMonths => 'Top 6 derniers mois';

  @override
  String get topThreeMonths => 'Top 3 derniers mois';

  @override
  String get topTwelveHour => 'Top 12 dernières heures';

  @override
  String get topWeek => 'Top semaine';

  @override
  String get topYear => 'Top année';

  @override
  String totalComments(Object x) {
    return '$x Comments';
  }

  @override
  String totalPosts(Object x) {
    return '$x Posts';
  }

  @override
  String get totp => 'TOTP (optionnel)';

  @override
  String get transferredModToCommunity => 'Transferred Community';

  @override
  String get translationsMayNotBeComplete =>
      'Veuillez noter que les traductions peuvent ne pas être complètes';

  @override
  String get trendingCommunities => 'Communautés en tendance';

  @override
  String get trySearchingFor => 'Essayer de chercher...';

  @override
  String get unableToFindCommunity => 'Impossible de trouver la communauté';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'Impossible de trouver la communauté \'$communityName\'';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Unable to find the selected community on the selected user\'s instance.';

  @override
  String get unableToFindInstance => 'Impossible de trouver l’instance';

  @override
  String get unableToFindLanguage => 'Impossible de trouver la langue';

  @override
  String get unableToFindPost => 'Unable to find post';

  @override
  String get unableToFindUser => 'Impossible de trouver l\'utilisateur';

  @override
  String unableToFindUserName(Object username) {
    return 'Unable to find user \'$username\'';
  }

  @override
  String get unableToLoadImage => 'Impossible de charger l\'image';

  @override
  String unableToLoadImageFrom(Object domain) {
    return 'Impossible de charger l\'image de $domain';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return 'Impossible de charger $instance';
  }

  @override
  String get unableToLoadPost => 'Unable to load post';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return 'Impossible de charger les publications de $instance';
  }

  @override
  String get unableToLoadReplies => 'Impossible de charger plus de réponses.';

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
  String get unblockInstance => 'Débloquer l\'instance';

  @override
  String get unblockUser => 'Unblock User';

  @override
  String get unblockUserInstance => 'Unblock User Instance';

  @override
  String get understandEnable => 'I Understand, Enable';

  @override
  String get unexpectedError => 'Erreur inattendue';

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
  String get unsubscribe => 'Se désabonner';

  @override
  String get unsubscribeFromCommunity => 'Se désabonner de la communauté';

  @override
  String get unsubscribePending => 'Se désabonner (abonnement en attente)';

  @override
  String get unsubscribed => 'Désabonné';

  @override
  String get untitledCommentDraft => 'Untitled comment draft';

  @override
  String get untitledPostDraft => 'Untitled post draft';

  @override
  String updateReleased(Object version) {
    return 'Mise à jour publiée : $version';
  }

  @override
  String get uploadImage => 'Envoyer une image';

  @override
  String uploadedDate(Object date) {
    return 'Uploaded: $date';
  }

  @override
  String get upvote => 'Vote positif';

  @override
  String get upvoteColor => 'Upvote Color';

  @override
  String get upvoted => 'Upvoted';

  @override
  String get uriNotSupported =>
      'Ce type de lien n\'est pas pris en charge pour le moment.';

  @override
  String get url => 'URL';

  @override
  String get useAdvancedShareSheet =>
      'Utiliser le formulaire de partage avancé';

  @override
  String get useApplePushNotifications => 'Use APNs Notifications';

  @override
  String get useApplePushNotificationsDescription =>
      'Uses Apple\'s Push Notification service';

  @override
  String get useCompactView =>
      'Activer pour les petites publications, désactiver pour les grandes.';

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
    return 'Utiliser le titre suggéré : $title';
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
  String get userFormat => 'Format d\'utilisateur';

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
  String get userNotLoggedIn => 'Utilisateur non connecté';

  @override
  String get userProfiles => 'Profils utilisateur';

  @override
  String get userSettingDescription =>
      'Ces paramètres sont synchronisés avec votre compte Lemmy et ne sont appliqués que par compte.';

  @override
  String get userStyle => 'User Style';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get usernameFormattingRedirect => 'Looking for username formatting?';

  @override
  String get users => 'Utilisateur';

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
  String get viewAllComments => 'Voir tous les commentaires';

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
  String get visitCommunity => 'Visiter la communauté';

  @override
  String get visitCommunityInstance => 'Visit Community Instance';

  @override
  String get visitInstance => 'Voir l\'instance';

  @override
  String get visitUserInstance => 'Visit User Instance';

  @override
  String get visitUserProfile => 'Voir le profil utilisateur';

  @override
  String get warning => 'Warning';

  @override
  String xDownvotes(Object x) {
    return '$x votes négatifs';
  }

  @override
  String xScore(Object x) {
    return '$x score';
  }

  @override
  String xUpvotes(Object x) {
    return '$x votes positifs';
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
