// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get about => 'Acerca do Thunder';

  @override
  String get accept => 'Aceitar';

  @override
  String get accessibility => 'Acessibilidade';

  @override
  String get accessibilityProfilesDescription =>
      'Os perfis de acessibilidade permitem aplicar várias definições de uma só vez para satisfazer um determinado requisito de acessibilidade.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Contas',
      one: 'Conta',
      zero: 'Contas',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'Aniversário da conta $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'As definições da sua conta substituem as seguintes definições';

  @override
  String get accountSettings => 'Definições da conta';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'As definições da conta Lemmy foram exportadas com sucesso para $savedFilePath!';
  }

  @override
  String get accountSettingsImportedSuccessfully =>
      'As definições da conta Lemmy foram importadas com sucesso!';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return 'O comentário selecionado não foi encontrado em \'$instance\'. A voltar para a conta anterior...';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'A publicação selecionada não foi encontrada em \'$instance\'. A voltar para a conta anterior...';
  }

  @override
  String get actionColors => 'Cores das ações';

  @override
  String get actionColorsRedirect => 'Quer personalizar as cores?';

  @override
  String get actions => 'Ações';

  @override
  String get active => 'Ativo';

  @override
  String get activity => 'Activity';

  @override
  String get add => 'Adicionar';

  @override
  String get addAccount => 'Adicionar conta';

  @override
  String get addAccountToSeeProfile => 'Faça login para ver a sua conta.';

  @override
  String get addAnonymousInstance => 'Adicionar uma instância anónima';

  @override
  String get addAsCommunityModerator =>
      'Adicionar como moderador da comunidade';

  @override
  String get addDiscussionLanguage => 'Adicionar idioma';

  @override
  String get addKeywordFilter => 'Adicionar palavra-chave';

  @override
  String get addOriginalPostBody => 'Add original post body?';

  @override
  String get addToFavorites => 'Adicionar aos favoritos';

  @override
  String get addUserLabel => 'Adicionar Etiqueta de Utilizador';

  @override
  String get addedCommunityToSubscriptions => 'Subscrito à comunidade';

  @override
  String get addedInstanceMod => 'Moderador da instância adicionado';

  @override
  String get addedModToCommunity => 'Moderador adicionado à comunidade';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return 'Added $username as community moderator';
  }

  @override
  String get admin => 'Admin';

  @override
  String get advanced => 'Avançado';

  @override
  String ago(Object time) {
    return 'Há $time';
  }

  @override
  String get all => 'Tudo';

  @override
  String get allPosts => 'Todas as publicações';

  @override
  String get allowOpenSupportedLinks =>
      'Permitir que a aplicação abra ligações suportadas.';

  @override
  String get alreadyPostedTo => 'Já publicado em';

  @override
  String get altText => 'Texto alternativo';

  @override
  String get alternateSources => 'Fontes alternativas';

  @override
  String get always => 'Sempre';

  @override
  String andXMore(Object count) {
    return 'e mais $count';
  }

  @override
  String get animations => 'Animações';

  @override
  String get anonymous => 'Anónimo';

  @override
  String get anonymousInstances => 'Instâncias anónimas';

  @override
  String get appLanguage => 'Idioma da aplicação';

  @override
  String get appearance => 'Aparência';

  @override
  String get applePushNotificationService =>
      'Serviço de Notificações Push da Apple';

  @override
  String get applied => 'Aplicado';

  @override
  String get apply => 'Aplicar';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return 'As notificações são permitidas pelo sistema: $yesOrNo';
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
  String get back => 'Voltar';

  @override
  String get backButton => 'Botão de voltar';

  @override
  String get backToTop => 'Voltar ao topo';

  @override
  String get backgroundCheckWarning =>
      'Tenha em conta que as verificações de notificação irão consumir mais bateria';

  @override
  String get ban => 'Ban';

  @override
  String get banFromCommunity => 'Banir da comunidade';

  @override
  String get bannedUser => 'Utilizador banido';

  @override
  String get bannedUserFromCommunity => 'Utilizador banido da comunidade';

  @override
  String get base => 'Base';

  @override
  String get block => 'Block';

  @override
  String get blockCommunity => 'Bloquear comunidade';

  @override
  String get blockCommunityInstance => 'Bloquear instância da comunidade';

  @override
  String get blockInstance => 'Bloquear instância';

  @override
  String get blockManagement => 'Gestão de bloqueios';

  @override
  String get blockSettingLabel =>
      'Bloqueios de Utilizador/Comunidade/Instância';

  @override
  String get blockUser => 'Bloquear utilizador';

  @override
  String get blockUserInstance => 'Bloquear a instância do utilizador';

  @override
  String get blockedCommunities => 'Comunidades bloqueadas';

  @override
  String get blockedInstances => 'Instâncias bloqueadas';

  @override
  String get blockedUsers => 'Utilizadores bloqueados';

  @override
  String get blue => 'Azul';

  @override
  String get bold => 'Negrito';

  @override
  String get boldCommunityName => 'Nome da comunidade a negrito';

  @override
  String get boldInstanceName => 'Nome da instância a negrito';

  @override
  String get boldUserName => 'Nome do utilizador a negrito';

  @override
  String get bot => 'Bot';

  @override
  String get browserMode => 'Gestão de links';

  @override
  String browsingAnonymously(Object instance) {
    return 'Está a navegar $instance anonimamente.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get cannotReportOwnComment =>
      'Não pode denunciar o seu próprio comentário.';

  @override
  String get cantBlockAdmin =>
      'Não pode bloquear um administrador da instância.';

  @override
  String get cantBlockYourself => 'Não se pode bloquear a si próprio.';

  @override
  String get cardPostCardMetadataItems => 'Metadados da Vista em Cartão';

  @override
  String get cardView => 'Vista em Cartão';

  @override
  String get cardViewDescription =>
      'Ative a vista em cartões para ajustar as definições';

  @override
  String get cardViewSettings => 'Definições da vista em cartões';

  @override
  String get changeAccountSettingsFor => 'Alterar as definições da conta para';

  @override
  String get changeNotificationSettings =>
      'Alterar as definições de notificação...';

  @override
  String get changePassword => 'Mudar palavra-passe';

  @override
  String get changePasswordWarning =>
      'Para alterar a sua palavra-passe, será redirecionado para o sítio da sua instância.  \n\nTem a certeza de que pretende continuar?';

  @override
  String get changeSort => 'Mudar ordem';

  @override
  String clearCache(Object cacheSize) {
    return 'Limpar a cache ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Limpar a cache';

  @override
  String get clearDatabase => 'Apagar dados';

  @override
  String get clearPreferences => 'Apagar preferências';

  @override
  String get clearSearch => 'Limpar Pesquisa';

  @override
  String get clearedCache => 'Cache limpa com sucesso.';

  @override
  String get clearedDatabase =>
      'Base de dados local limpa. Reinicie o Thunder para que as novas alterações tenham efeito.';

  @override
  String get clearedUserPreferences =>
      'As preferências de utilizador foram apagadas';

  @override
  String get close => 'Fechar';

  @override
  String get collapse => 'Colapsar';

  @override
  String get collapseCommentPreview =>
      'Colapsar a pré-visualização dos comentários';

  @override
  String get collapseInformation => 'Colapsar Informação';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Ocultar o comentário pai quando colapsado';

  @override
  String get collapsePost => 'Colapsar publicação';

  @override
  String get collapsePostPreview => 'Collapse Post Preview';

  @override
  String get collapseSpoiler => 'Collapse Spoiler';

  @override
  String get color => 'Cor';

  @override
  String get colorizeCommunityName => 'Colorir Nome da Comunidade';

  @override
  String get colorizeInstanceName => 'Colorir Nome da Instância';

  @override
  String get colorizeUserName => 'Colorir Nome de Utilizador';

  @override
  String get colors => 'Cores';

  @override
  String get combineCommentScores => 'Combine Comment Scores';

  @override
  String get combineCommentScoresLabel => 'Combine Comment Scores';

  @override
  String get combineNavAndFab => 'Combinar FAB e Botões de Navegação';

  @override
  String get combineNavAndFabDescription =>
      'Floating Action Button will be shown between navigation buttons.';

  @override
  String get comfortable => 'Confortável';

  @override
  String get comment => 'Comment';

  @override
  String get commentActions => 'Comment Actions';

  @override
  String get commentBehaviourSettings => 'Comentários';

  @override
  String get commentFontScale => 'Comment Content Font Scale';

  @override
  String get commentPreview =>
      'Mostrar prévia dos comentários com as configurações aplicadas';

  @override
  String get commentReported => 'O comentário foi marcado para revisão.';

  @override
  String get commentSavedAsDraft => 'Comentário gravado como rascunho';

  @override
  String get commentShowUserAvatar => 'Mostrar Avatar do Utilizador';

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
  String get comments => 'Comentários';

  @override
  String get communities => 'Comunidades';

  @override
  String get community => 'Comunidade';

  @override
  String get communityActions => 'Ações da Comunidade';

  @override
  String communityEntry(Object community) {
    return 'Comunidade \'$community\'';
  }

  @override
  String get communityFormat => 'Formato da Comunidade';

  @override
  String get communityNameColor => 'Community Name Color';

  @override
  String get communityNameThickness => 'Community Name Thickness';

  @override
  String get communityStyle => 'Estilo da Comunidade';

  @override
  String get compact => 'Compactar';

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
  String get importDatabase => 'Importar base de dados';

  @override
  String get importExportDatabase => 'Importar/exportar base de dados';

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
  String get linkHandlingExternalShort => 'Externo';

  @override
  String get linkHandlingInApp => 'Use Thunder\'s built-in browser';

  @override
  String get linkHandlingInAppShort => 'In-app';

  @override
  String get linkPostsUseCompactView => 'Show Compact Link Posts';

  @override
  String get linksBehaviourSettings => 'Ligações';

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
  String get off => 'desligado';

  @override
  String get offline => 'offline';

  @override
  String get ok => 'OK';

  @override
  String get old => 'Velho';

  @override
  String get on => 'ligado';

  @override
  String get onWifi => 'On Wifi';

  @override
  String get onlyModsCanPostInCommunity =>
      'Only moderators may post in this community';

  @override
  String get open => 'Abrir';

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
  String get postFlairs => 'Flairs';

  @override
  String get postFlairsUnavailable =>
      'No flair options available for this community';

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
  String get postTags => 'Tags';

  @override
  String get postTagsHelperText => 'Separate tags with commas';

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
  String get showPostCommunityFirst => 'Show Community and Author First';

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
  String get status => 'Estado';

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

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get about => 'Sobre';

  @override
  String get accept => 'Aceitar';

  @override
  String get accessibility => 'Acessibilidade';

  @override
  String get accessibilityProfilesDescription =>
      'Perfis de acessibilidade permitem aplicar múltiplas configurações de uma vez para acomodar um requisito específico de acessibilidade.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Contas',
      one: 'Conta',
      zero: 'Contas',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'Aniversário da conta $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'Suas configurações de conta sobrescrevem as configurações a seguir';

  @override
  String get accountSettings => 'Configurações da conta';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'As configurações da conta Lemmy foram exportadas com sucesso para $savedFilePath!';
  }

  @override
  String get accountSettingsImportedSuccessfully =>
      'Configurações da conta Lemmy importadas com sucesso!';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return 'O comentário selecionado não foi encontrado em \'$instance\'';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'A postagem selecionada não foi encontrada em \'$instance\'';
  }

  @override
  String get actionColors => 'Cores de ações';

  @override
  String get actionColorsRedirect => 'Querendo customizar cores?';

  @override
  String get actions => 'Ações';

  @override
  String get active => 'Ativo';

  @override
  String get activity => 'Atividade';

  @override
  String get add => 'Adicionar';

  @override
  String get addAccount => 'Adicionar conta';

  @override
  String get addAccountToSeeProfile => 'Faça login para ver sua conta.';

  @override
  String get addAnonymousInstance => 'Adicionar instância anônima';

  @override
  String get addAsCommunityModerator =>
      'Adicionar como moderador de comunidade';

  @override
  String get addDiscussionLanguage => 'Adicionar idioma';

  @override
  String get addKeywordFilter => 'Adicionar palavra-chave';

  @override
  String get addOriginalPostBody => 'Adicionar o corpo da postagem original?';

  @override
  String get addToFavorites => 'Adicionar aos favoritos';

  @override
  String get addUserLabel => 'Adicionar rótulo de usuário';

  @override
  String get addedCommunityToSubscriptions => 'Inscrito na comunidade';

  @override
  String get addedInstanceMod => 'Adicionou mod de instância';

  @override
  String get addedModToCommunity => 'Moderador adicionado à comunidade';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return 'Adicionou $username como moderador de comunidade';
  }

  @override
  String get admin => 'Admin';

  @override
  String get advanced => 'Avançado';

  @override
  String ago(Object time) {
    return 'há $time';
  }

  @override
  String get all => 'Todos';

  @override
  String get allPosts => 'Todas as postagens';

  @override
  String get allowOpenSupportedLinks =>
      'Permitir que o aplicativo abra links suportados.';

  @override
  String get alreadyPostedTo => 'Já postado em';

  @override
  String get altText => 'Texto alt';

  @override
  String get alternateSources => 'Fontes alternativas';

  @override
  String get always => 'Sempre';

  @override
  String andXMore(Object count) {
    return 'e $count mais';
  }

  @override
  String get animations => 'Animações';

  @override
  String get anonymous => 'Anônimo';

  @override
  String get anonymousInstances => 'Instâncias anônimas';

  @override
  String get appLanguage => 'Idioma do aplicativo';

  @override
  String get appearance => 'Aparência';

  @override
  String get applePushNotificationService =>
      'Serviço de notificações push da Apple';

  @override
  String get applied => 'Aplicado';

  @override
  String get apply => 'Aplicar';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return 'As notificações são permitidas pelo sistema: $yesOrNo';
  }

  @override
  String averageComments(Object x) {
    return '$x comentários/mês';
  }

  @override
  String averageContributions(Object x) {
    return '$x contribuições/mês';
  }

  @override
  String averagePosts(Object x) {
    return '$x postagens/mês';
  }

  @override
  String get back => 'Voltar';

  @override
  String get backButton => 'Botão de voltar';

  @override
  String get backToTop => 'Voltar ao topo';

  @override
  String get backgroundCheckWarning =>
      'Observe que as verificações de notificações consumirão bateria adicional';

  @override
  String get ban => 'Banir';

  @override
  String get banFromCommunity => 'Banir da comunidade';

  @override
  String get bannedUser => 'Usuário banido';

  @override
  String get bannedUserFromCommunity => 'Baniu usuário da comunidade';

  @override
  String get base => 'Base';

  @override
  String get block => 'Bloquear';

  @override
  String get blockCommunity => 'Bloquear comunidade';

  @override
  String get blockCommunityInstance => 'Bloquear instância da comunidade';

  @override
  String get blockInstance => 'Bloquear instância';

  @override
  String get blockManagement => 'Gerenciamento de bloqueios';

  @override
  String get blockSettingLabel =>
      'Bloqueios de usuários/comunidades/instâncias';

  @override
  String get blockUser => 'Bloquear usuário';

  @override
  String get blockUserInstance => 'Bloquear instância do usuário';

  @override
  String get blockedCommunities => 'Comunidades bloqueadas';

  @override
  String get blockedInstances => 'Instâncias bloqueadas';

  @override
  String get blockedUsers => 'Usuários bloqueados';

  @override
  String get blue => 'Azul';

  @override
  String get bold => 'Negrito';

  @override
  String get boldCommunityName => 'Nome da comunidade em negrito';

  @override
  String get boldInstanceName => 'Nome da instância em negrito';

  @override
  String get boldUserName => 'Nome do usuário em negrito';

  @override
  String get bot => 'Robô';

  @override
  String get browserMode => 'Tratamento de links';

  @override
  String browsingAnonymously(Object instance) {
    return 'Você está navegando $instance anonimamente.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get cannotReportOwnComment =>
      'Você não pode denunciar seu próprio comentário.';

  @override
  String get cantBlockAdmin =>
      'Você não pode bloquear um administrador da instância.';

  @override
  String get cantBlockYourself => 'Você não pode bloquear a si mesmo.';

  @override
  String get cardPostCardMetadataItems => 'Metadados da visualização em cartão';

  @override
  String get cardView => 'Visualização em cartão';

  @override
  String get cardViewDescription =>
      'Ative a visualização em cartão para ajustar as configurações';

  @override
  String get cardViewSettings => 'Configurações da visualização em cartão';

  @override
  String get changeAccountSettingsFor => 'Mudar configurações de conta para';

  @override
  String get changeNotificationSettings =>
      'Mudar configurações de notificação.';

  @override
  String get changePassword => 'Mudar senha';

  @override
  String get changePasswordWarning =>
      'Para mudar sua senha, você será redirecionado(a) ao site da sua instância.\n\nTem certeza que deseja continuar?';

  @override
  String get changeSort => 'Alterar ordenação';

  @override
  String clearCache(Object cacheSize) {
    return 'Limpar cache ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Limpar cache';

  @override
  String get clearDatabase => 'Limpar banco de dados';

  @override
  String get clearPreferences => 'Limpar preferências';

  @override
  String get clearSearch => 'Limpar pesquisa';

  @override
  String get clearedCache => 'Cache limpado com sucesso.';

  @override
  String get clearedDatabase =>
      'O banco de dados local foi limpo. Reinicie o Thunder para que as mudanças sejam aplicadas.';

  @override
  String get clearedUserPreferences =>
      'As preferências de usuários foram limpas';

  @override
  String get close => 'Fechar';

  @override
  String get collapse => 'Colapsar';

  @override
  String get collapseCommentPreview =>
      'Recolher pré-visualização do comentário';

  @override
  String get collapseInformation => 'Recolher informação';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Ocultar comentário pai quando recolhido';

  @override
  String get collapsePost => 'Recolher postagem';

  @override
  String get collapsePostPreview => 'Recolher pré-visualização da postagem';

  @override
  String get collapseSpoiler => 'Recolher spoiler';

  @override
  String get color => 'Cor';

  @override
  String get colorizeCommunityName => 'Colorir nome da comunidade';

  @override
  String get colorizeInstanceName => 'Colorir nome da instância';

  @override
  String get colorizeUserName => 'Colorir nome de usuário';

  @override
  String get colors => 'Cores';

  @override
  String get combineCommentScores => 'Combinar pontuações dos comentários';

  @override
  String get combineCommentScoresLabel => 'Combinar pontuações dos comentários';

  @override
  String get combineNavAndFab => 'Combinar FAB e botões de navegação';

  @override
  String get combineNavAndFabDescription =>
      'O botão de ação flutuante (FAB) será exibido entre os botões de navegação.';

  @override
  String get comfortable => 'Confortável';

  @override
  String get comment => 'Comentário';

  @override
  String get commentActions => 'Ações de comentário';

  @override
  String get commentBehaviourSettings => 'Comentários';

  @override
  String get commentFontScale => 'Escala da fonte do conteúdo do comentário';

  @override
  String get commentPreview =>
      'Mostrar pré-visualização dos comentários com as configurações aplicadas';

  @override
  String get commentReported => 'O comentário foi marcado para revisão.';

  @override
  String get commentSavedAsDraft => 'Comentário salvo como rascunho';

  @override
  String get commentShowUserAvatar => 'Mostrar avatar do usuário';

  @override
  String get commentShowUserInstance => 'Exibir instância do usuário';

  @override
  String get commentSortType => 'Tipo de ordenação dos comentários';

  @override
  String get commentSwipeActions => 'Ações de deslizar no comentário';

  @override
  String get commentSwipeGesturesHint =>
      'Quer usar botões? Ative-os na seção de comentários nas configurações gerais.';

  @override
  String get comments => 'Comentários';

  @override
  String get communities => 'Comunidades';

  @override
  String get community => 'Comunidade';

  @override
  String get communityActions => 'Ações da comunidade';

  @override
  String communityEntry(Object community) {
    return 'Comunidade \'$community\'';
  }

  @override
  String get communityFormat => 'Formato da comunidade';

  @override
  String get communityNameColor => 'Cor do nome da comunidade';

  @override
  String get communityNameThickness => 'Espessura do nome da comunidade';

  @override
  String get communityStyle => 'Estilo da comunidade';

  @override
  String get compact => 'Compacto';

  @override
  String get compactPostCardMetadataItems =>
      'Visualização compacta dos metadados';

  @override
  String get compactView => 'Visualização compacta';

  @override
  String get compactViewDescription =>
      'Ativar a visualização compacta para ajustar as configurações';

  @override
  String get compactViewSettings => 'Configurações da visualização compacta';

  @override
  String get condensed => 'Condensado';

  @override
  String get confirm => 'Confirmar';

  @override
  String get confirmLogOutBody => 'Tem certeza de que deseja sair?';

  @override
  String get confirmLogOutTitle => 'Sair?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Tem certeza de que deseja marcar todas as respostas, menções e mensagens como lidas?';

  @override
  String get confirmMarkAllAsReadTitle => 'Marcar todas como lidas?';

  @override
  String get confirmResetCommentPreferences =>
      'Isso redefinirá todas as preferências de comentários. Tem certeza de que deseja continuar?';

  @override
  String get confirmResetPostPreferences =>
      'Isso redefinirá todas as preferências de postagem. Tem certeza de que deseja continuar?';

  @override
  String get confirmUnsubscription =>
      'Tem certeza de que deseja cancelar a inscrição?';

  @override
  String connectedToUnifiedPushDistributorApp(Object app) {
    return 'Conectado a $app';
  }

  @override
  String get contentManagement => 'Gerenciamento de conteúdo';

  @override
  String get contentWarning => 'Aviso de conteúdo';

  @override
  String get controversial => 'Controverso';

  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';

  @override
  String get copy => 'Copiar';

  @override
  String get copyComment => 'Copiar comentário';

  @override
  String get copySelected => 'Copiar selecionado';

  @override
  String get copyText => 'Copiar texto';

  @override
  String get couldNotDetermineCommentDelete =>
      'Erro: Não foi possível determinar a postagem para excluir o comentário.';

  @override
  String get couldNotDeterminePostComment =>
      'Erro: Não foi possível determinar a postagem a comentar.';

  @override
  String get couldntCreateReport =>
      'Seu relatório de comentário não pôde ser enviado neste momento. Por favor, tente novamente mais tarde';

  @override
  String get couldntFindPost =>
      'Não foi possível carregar a postagem solicitada. Ela pode ter sido excluída ou removida.';

  @override
  String countComments(Object count) {
    return '$count comentários';
  }

  @override
  String countLocalSubscribers(Object count) {
    return '$count assinantes locais';
  }

  @override
  String countPosts(Object count) {
    return '$count postagens';
  }

  @override
  String countSubscribers(Object count) {
    return '$count assinantes';
  }

  @override
  String countUsers(Object count) {
    return '$count usuários';
  }

  @override
  String countUsersActiveDay(Object count) {
    return '$count usuários/dia';
  }

  @override
  String countUsersActiveHalfYear(Object count) {
    return '$count usuários/6 meses';
  }

  @override
  String countUsersActiveMonth(Object count) {
    return '$count usuários/mês';
  }

  @override
  String countUsersActiveWeek(Object count) {
    return '$count usuários/sem';
  }

  @override
  String get createAccount => 'Criar conta';

  @override
  String get createComment => 'Criar comentário';

  @override
  String get createNewCrossPost => 'Criar nova postagem cruzada';

  @override
  String get createPost => 'Criar postagem';

  @override
  String created(Object date) {
    return 'Criado em $date';
  }

  @override
  String get createdToday => 'Criado hoje';

  @override
  String get creator => 'Criador';

  @override
  String crossPostedFrom(Object postUrl) {
    return 'postagem cruzada de: $postUrl';
  }

  @override
  String get crossPostedTo => 'Postagem cruzada criada em';

  @override
  String get currentLongPress => 'Atualmente definido como toque longo';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Modo de notificações atual: $mode';
  }

  @override
  String get currentSinglePress => 'Atualmente definido como toque único';

  @override
  String get customizeSwipeActions =>
      'Personalizar ações de deslizar (toque para alterar)';

  @override
  String get dangerZone => 'Zona de perigo';

  @override
  String get dark => 'Escuro';

  @override
  String get databaseExportWarning =>
      'O banco de dados pode conter informações confidenciais relacionadas à sua conta Lemmy. Se você exportá-lo, não deve compartilhá-lo com ninguém. Deseja continuar?';

  @override
  String databaseExportedSuccessfully(Object savedFilePath) {
    return 'O banco de dados foi exportado com sucesso para \'$savedFilePath\'';
  }

  @override
  String get databaseImportedSuccessfully =>
      'O banco de dados foi importado com sucesso!';

  @override
  String get databaseNotExportedSuccessfully =>
      'O banco de dados não foi exportado com sucesso ou a operação foi cancelada.';

  @override
  String get databaseNotImportedSuccessfully =>
      'O banco de dados não foi importado com sucesso ou a operação foi cancelada.';

  @override
  String get dateFormat => 'Formato de data';

  @override
  String get debug => 'Depuração';

  @override
  String get debugDescription =>
      'As seguintes configurações de depuração devem ser utilizadas apenas para fins de resolução de problemas.';

  @override
  String get debugNotificationsDescription =>
      'Use as seguintes opções para solucionar problemas relacionados a notificações.';

  @override
  String get decline => 'Recusar';

  @override
  String get defaultColor => 'Padrão';

  @override
  String get defaultCommentSortType =>
      'Tipo de ordenação padrão dos comentários';

  @override
  String get defaultFeedSortType => 'Tipo de ordenação padrão do feed';

  @override
  String get defaultFeedType => 'Tipo padrão do feed';

  @override
  String get delete => 'Excluir';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get deleteAccountDescription =>
      'Para excluir permanentemente sua conta, você será redirecionado para o site da sua instância.\n\nTem certeza de que deseja continuar?';

  @override
  String get deleteComment => 'Excluir comentário';

  @override
  String get deleteImageConfirmMessage =>
      'Tem certeza de que deseja excluir esta imagem?';

  @override
  String get deleteImageConfirmTitle => 'Excluir?';

  @override
  String get deleteLocalDatabase => 'Excluir banco de dados local';

  @override
  String get deleteLocalDatabaseDescription =>
      'Esta ação removerá o banco de dados local e você será desconectado de todas as suas contas.\n\nTem certeza de que deseja continuar?';

  @override
  String get deleteLocalPreferences => 'Excluir preferências locais';

  @override
  String get deleteLocalPreferencesDescription =>
      'Isso limpará todas as suas preferências e configurações de usuário no Thunder.\n\nDeseja continuar?';

  @override
  String get deletePost => 'Excluir postagem';

  @override
  String get deleteUserLabelConfirmation =>
      'Tem certeza de que deseja excluir o rótulo?';

  @override
  String get deleted => 'Excluído';

  @override
  String get deletedByCreator => 'excluído pelo criador';

  @override
  String get deletedByModerator => 'excluído por um moderador';

  @override
  String get deletedComment => 'Excluiu comentário';

  @override
  String get deletedPost => 'Excluiu postagem';

  @override
  String get deselectUndeterminedWarning =>
      'Se você desmarcar Indeterminado, não verá a maior parte do conteúdo.';

  @override
  String detailedReason(Object reason) {
    return 'Motivo: $reason';
  }

  @override
  String get dimReadPosts => 'Escurecer postagens lidas';

  @override
  String get disable => 'Desativar';

  @override
  String get disablePushNotifications => 'Desativar notificações push';

  @override
  String get disabled => 'Desativado';

  @override
  String get discussionLanguages => 'Idiomas de discussão';

  @override
  String get discussionLanguagesTooltip =>
      'O conteúdo é filtrado para os idiomas selecionados.';

  @override
  String get dismissRead => 'Descartar lidas';

  @override
  String get displayName => 'Nome de exibição';

  @override
  String get displayUserScore => 'Exibir pontuações dos usuários (karma).';

  @override
  String get dividerAppearance => 'Aparência do divisor';

  @override
  String get doNotShowAgain => 'Não mostrar novamente';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Encontrados vários aplicativos compatíveis; instale apenas um';

  @override
  String get downloadingMedia => 'Baixando mídia para compartilhar…';

  @override
  String get downvote => 'Dar voto negativo';

  @override
  String get downvoteColor => 'Cor de votos negativos';

  @override
  String get downvoted => 'Voto negativo';

  @override
  String get downvotesDisabled =>
      'Votos negativos estão desativos nesta instância.';

  @override
  String get edit => 'Editar';

  @override
  String get editComment => 'Editar comentário';

  @override
  String get editPost => 'Editar postagem';

  @override
  String get email => 'E-mail';

  @override
  String get empty => 'Vazio';

  @override
  String get emptyInbox => 'Caixa de entrada vazia';

  @override
  String get emptyUri =>
      'O link está vazio. Forneça um link dinâmico válido para continuar.';

  @override
  String get enableCommentNavigation => 'Ativar navegação nos comentários';

  @override
  String get enableExperimentalFeatures => 'Ativar recursos experimentais';

  @override
  String get enableFeedFab => 'Ativar botão flutuante nos feeds';

  @override
  String get enableFloatingButtonOnFeeds => 'Ativar botão flutuante nos feeds';

  @override
  String get enableFloatingButtonOnPosts =>
      'Ativar botão flutuante nas postagens';

  @override
  String get enableInboxNotifications =>
      'Ativar notificações da caixa de entrada';

  @override
  String get enablePostFab => 'Ativar botão flutuante nas postagens';

  @override
  String get endOfComments => 'Fim dos comentários';

  @override
  String get endSearch => 'Encerrar pesquisa';

  @override
  String errorDeletingImage(Object error) {
    return 'Ocorreu um erro ao excluir a imagem: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Não foi possível baixar o arquivo de mídia para compartilhar: $errorMessage';
  }

  @override
  String get errorImportingAccountSettings =>
      'Ocorreu um erro ao importar as configurações. O arquivo pode não estar no formato correto.';

  @override
  String get errorInitializingClient => 'Erro ao inicializar o cliente';

  @override
  String get errorLoadingAccountSettings =>
      'Ocorreu um erro ao carregar o arquivo de configurações ou a operação foi cancelada.';

  @override
  String get errorMarkingReplyRead =>
      'Ocorreu um erro ao marcar a resposta como lida.';

  @override
  String get errorMarkingReplyUnread =>
      'Ocorreu um erro ao marcar a resposta como não lida.';

  @override
  String get errorNoActiveInstance => 'Nenhuma instância ativa encontrada';

  @override
  String get errorParsingJson =>
      'Ocorreu um erro ao analisar o arquivo selecionado. Pode não ser um JSON válido.';

  @override
  String get errorSavingAccountSettings =>
      'Ocorreu um erro ao salvar o arquivo de configurações ou a operação foi cancelada.';

  @override
  String get exceptionProcessingUri =>
      'Ocorreu um erro ao processar o link. Ele pode não estar disponível na sua instância.';

  @override
  String get excessiveApiCallsWarning =>
      'Seu feed pode estar demorando para carregar devido aos filtros de palavras-chave.';

  @override
  String get expand => 'Expandir';

  @override
  String get expandCommentPreview => 'Expandir pré-visualização do comentário';

  @override
  String get expandInformation => 'Expandir informação';

  @override
  String get expandOptions => 'Expandir opções';

  @override
  String get expandPost => 'Expandir postagem';

  @override
  String get expandPostPreview => 'Expandir pré-visualização da postagem';

  @override
  String get expandSpoiler => 'Expandir spoiler';

  @override
  String get expanded => 'Expandido';

  @override
  String get experimentalFeatures => 'Recursos experimentais';

  @override
  String get experimentalFeaturesDescription =>
      'Estes recursos ainda estão em desenvolvimento e podem ser instáveis. Use-os por sua própria conta e risco. É necessário reiniciar o Thunder para que as alterações tenham efeito.';

  @override
  String get exploreInstance => 'Explorar instância';

  @override
  String get exportDatabase => 'Exportar banco de dados';

  @override
  String get exportDatabaseSubtitle =>
      'O banco de dados contém informações sobre contas, favoritos, inscrições anônimas e rótulos de usuários.';

  @override
  String get exportLemmyAccountSettingsDescription =>
      'Exportar configurações de contas Lemmy';

  @override
  String get exportSettingsSubtitle =>
      'As configurações incluem todas as preferências que você configurou no Thunder.';

  @override
  String get extraLarge => 'Extra grande';

  @override
  String failedToBlock(Object errorMessage) {
    return 'Falha ao bloquear: $errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return 'Falha ao comunicar com o servidor de notificações do Thunder em $serverAddress.';
  }

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return 'Não foi possível carregar bloqueios: $errorMessage';
  }

  @override
  String get failedToLoadVideo =>
      'Falha ao carregar o vídeo. Abrir link no navegador?';

  @override
  String get failedToPerformAction => 'Falha ao executar a ação';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'Não foi possível desbloquear: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Falha ao atualizar as configurações de notificação';

  @override
  String get favorite => 'Favoritar';

  @override
  String get favorites => 'Favoritos';

  @override
  String get featuredPost => 'Postagem em destaque';

  @override
  String get feed => 'Feed';

  @override
  String get feedBehaviourSettings => 'Feed';

  @override
  String get feedSettings => 'Configurações de feed';

  @override
  String get feedTypeAndSorts => 'Tipo e ordenação padrão de feed';

  @override
  String get fetchAccountError => 'Não foi possível determinar a conta';

  @override
  String filteringBy(Object entity) {
    return 'Filtrando por $entity';
  }

  @override
  String get filters => 'Filtros';

  @override
  String get floatingActionButton => 'Botão de ação flutuante';

  @override
  String get floatingActionButtonInformation =>
      'O Thunder possui uma experiência FAB totalmente personalizável que suporta alguns gestos.\n- Deslize para cima para revelar ações FAB adicionais\n- Deslize para baixo/cima para ocultar ou revelar o FAB\n\nPara personalizar as ações principais e secundárias do FAB, pressione longamente uma das ações abaixo.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'denota a ação de pressionar longamente o FAB.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'denota a ação de pressionar uma única vez o FAB.';

  @override
  String get fonts => 'Fontes';

  @override
  String get forward => 'Avançar';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Aplicativo compatível encontrado; reinicie o Thunder para conectar';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Deslize em qualquer lugar para voltar quando os gestos da esquerda para a direita estiverem desativados';

  @override
  String get fullscreen => 'Tela cheia';

  @override
  String get fullscreenSwipeGestures => 'Gestos de deslizar em tela cheia';

  @override
  String get general => 'Geral';

  @override
  String get generalSettings => 'Configurações gerais';

  @override
  String get gestures => 'Gestos';

  @override
  String get gettingStarted => 'Como começar';

  @override
  String get green => 'Verde';

  @override
  String get guestModeFeedSettings => 'Configurações do feed do modo convidado';

  @override
  String get guestModeFeedSettingsLabel =>
      'As configurações a seguir são aplicadas apenas a contas de convidados. Para ajustar as configurações de feed da sua conta, acesse Configurações da Conta.';

  @override
  String get havingIssuesWithNotifications =>
      'Está tendo problemas com notificações?';

  @override
  String get hidCommunity => 'Comunidade oculta';

  @override
  String get hidden => 'Oculto';

  @override
  String get hide => 'Ocultar';

  @override
  String get hideBottomBarOnScroll => 'Ocultar barra inferior ao rolar';

  @override
  String get hideColor => 'Ocultar cor';

  @override
  String get hideNsfwPostsFromFeed => 'Ocultar postagens NSFW do feed';

  @override
  String get hideNsfwPreviews => 'Desfocar pré-visualizações NSFW';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get hideThumbnails => 'Ocultar miniaturas';

  @override
  String get hideTopBarOnScroll => 'Ocultar barra superior ao rolar';

  @override
  String get hostInstance => 'Instância de hospedagem';

  @override
  String get hot => 'Em alta';

  @override
  String get image => 'Imagem';

  @override
  String get imageCachingMode => 'Modo de cache de imagens';

  @override
  String get imageCachingModeAggressive =>
      'Armazene imagens em cache de forma agressiva (usa mais memória)';

  @override
  String get imageCachingModeAggressiveShort => 'Agressivo';

  @override
  String get imageCachingModeRelaxed =>
      'Deixar os caches de imagens expirarem (usa menos memória, mas faz com que as imagens sejam recarregadas com mais frequência)';

  @override
  String get imageCachingModeRelaxedShort => 'Relaxado';

  @override
  String get imageDimensionTimeout => 'Tempo limite de dimensão da imagem';

  @override
  String get imagePeekDuration => 'Duração da pré-visualização da imagem';

  @override
  String get imagePeekDurationDescription =>
      'Duração do toque longo antes que a pré-visualização da imagem seja acionada';

  @override
  String get importDatabase => 'Importar banco de dados';

  @override
  String get importExportDatabase =>
      'Importar/exportar o banco de dados do Thunder';

  @override
  String get importExportLemmyAccountSettings =>
      'Importar/exportar as configurações das contas Lemmy';

  @override
  String get importExportLemmyAccountSettingsSubtitle =>
      'Inclui comunidades inscritas, listas de bloqueio e preferências da conta';

  @override
  String get importExportSettings => 'Importar/exportar configurações';

  @override
  String get importExportThunderSettings =>
      'Importar/exportar configurações do Thunder';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Importar configurações da conta Lemmy';

  @override
  String get importSettings => 'Importar configurações';

  @override
  String inReplyTo(Object post, Object community) {
    return 'Em resposta a $post em $community';
  }

  @override
  String get in_ => 'em';

  @override
  String get inbox => 'Entrada';

  @override
  String get includeCommunity => 'Incluir comunidade';

  @override
  String get includeExternalLink => 'Incluir link externo';

  @override
  String get includeImage => 'Incluir imagem';

  @override
  String get includePostLink => 'Incluir link da postagem';

  @override
  String get includeText => 'Incluir texto';

  @override
  String get includeTitle => 'Incluir título';

  @override
  String get information => 'Informação';

  @override
  String instance(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Instâncias',
      one: 'Instância',
      zero: 'Instâncias',
    );
    return '$_temp0 ';
  }

  @override
  String get instanceActions => 'Ações da instância';

  @override
  String instanceEntry(Object username) {
    return 'Instância \'$username\'';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance já foi adicionado.';
  }

  @override
  String get instanceNameColor => 'Cor do nome da instância';

  @override
  String get instanceNameThickness => 'Espessura do noma da instância';

  @override
  String get instances => 'Instâncias';

  @override
  String get internetOrInstanceIssues =>
      'Você pode não estar conectado à Internet ou sua instância pode estar indisponível no momento.';

  @override
  String get invalidUrl => 'Formato de URL inválido';

  @override
  String joined(Object x) {
    return 'Se cadastrou em $x';
  }

  @override
  String get keywordFilterDescription =>
      'Filtra postagens que contenham quaisquer palavras-chave no título, corpo ou URL';

  @override
  String get keywordFilters => 'Filtros de palavras-chave';

  @override
  String get label => 'Rótulo';

  @override
  String get language => 'Idioma';

  @override
  String get languageFilters => 'Procurando filtros de idioma?';

  @override
  String get languageNotAllowed =>
      'A comunidade em que você está postando não permite postagens no idioma que você selecionou. Tente outro idioma.';

  @override
  String get large => 'Grande';

  @override
  String get leftLongSwipe => 'Deslize longo para a esquerda';

  @override
  String get leftShortSwipe => 'Deslize curto para a esquerda';

  @override
  String get light => 'Claro';

  @override
  String link(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Links',
      one: 'Link',
      zero: 'Links',
    );
    return '$_temp0 ';
  }

  @override
  String get linkActions => 'Ações de link';

  @override
  String get linkHandlingCustomTabs =>
      'Abrir no navegador do sistema incorporado no aplicativo';

  @override
  String get linkHandlingCustomTabsShort => 'incorporado no aplicativo';

  @override
  String get linkHandlingExternal =>
      'Abrir no navegador do sistema externamente';

  @override
  String get linkHandlingExternalShort => 'Externamente';

  @override
  String get linkHandlingInApp => 'Use o navegador integrado do Thunder';

  @override
  String get linkHandlingInAppShort => 'No aplicativo';

  @override
  String get linkPostsUseCompactView => 'Mostrar postagens de link compactas';

  @override
  String get linksBehaviourSettings => 'Links';

  @override
  String loadMorePlural(Object count) {
    return 'Carregar mais $count respostas…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Carregar mais $count resposta…';
  }

  @override
  String get loading => 'Carregando…';

  @override
  String get local => 'Local';

  @override
  String get localNotifications => 'Notificações locais';

  @override
  String get localOnly => 'Somente local';

  @override
  String get localPosts => 'Postagens locais';

  @override
  String get lockPost => 'Trancar postagem';

  @override
  String get locked => 'Trancado';

  @override
  String get lockedPost => 'Postagem trancada';

  @override
  String get logOut => 'Sair';

  @override
  String get login => 'Entrar';

  @override
  String get loginAttemptCanceled => 'Tentativa de login cancelada.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Não foi possível fazer login. Tente novamente. (Erro: $errorMessage)';
  }

  @override
  String get loginSucceeded => 'Logado.';

  @override
  String get loginToPerformAction =>
      'Você precisa estar logado para realizar esta tarefa.';

  @override
  String get loginToSeeInbox => 'Faça login para ver sua caixa de entrada';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Procurando configurações de feed específicas para sua conta?';

  @override
  String get malformedUri =>
      'O link que você forneceu está em um formato não compatível. Certifique-se de que seja um link válido.';

  @override
  String get manageAccounts => 'Gerenciar contas';

  @override
  String get manageMedia => 'Gerenciar mídia';

  @override
  String get markAllAsRead => 'Marcar tudo como lido';

  @override
  String get markAsRead => 'Marcar como lido';

  @override
  String get markPostAsReadOnMediaView =>
      'Marcar como lido após visualizar a mídia';

  @override
  String get markPostAsReadOnScroll => 'Marcar como lido ao rolar';

  @override
  String get markReadColor => 'Cor da marcação lido/não lido';

  @override
  String get matrixUser => 'Usuário Matrix';

  @override
  String get me => 'Eu';

  @override
  String get media => 'Mídia';

  @override
  String get medium => 'Médio';

  @override
  String mention(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Menções',
      one: 'Menção',
      zero: 'Menções',
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
      other: 'Mensagens',
      one: 'Mensagem',
      zero: 'Mensagens',
    );
    return '$_temp0';
  }

  @override
  String get metadataFontScale => 'Escala da fonte de metadados';

  @override
  String get missingErrorMessage => 'Nenhuma mensagem de erro disponível';

  @override
  String get modAdd => 'Adicionar/remover moderadores da instância';

  @override
  String get modAddCommunity => 'Adicionar/remover moderados de comunidades';

  @override
  String get modBan => 'Banir/desbanir usuários da instância';

  @override
  String get modBanFromCommunity => 'Banir/desbanir usuários das comunidades';

  @override
  String get modFeaturePost => 'Marcar postagens em destaque/não em destaque';

  @override
  String get modLockPost => 'Trancar/destrancar postagens';

  @override
  String get modRemoveComment => 'Remover/restaurar comentários';

  @override
  String get modRemoveCommunity => 'Remover/restaurar comunidades';

  @override
  String get modRemovePost => 'Remover/restaurar postagens';

  @override
  String get modTransferCommunity => 'Transferência de comunidades';

  @override
  String get moderatedCommunities => 'Comunidades moderadas';

  @override
  String get moderates => 'Moderando';

  @override
  String moderator(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moderadores',
      one: 'Moderador',
      zero: 'Moderadores',
    );
    return '$_temp0';
  }

  @override
  String get moderatorActions => 'Ações de moderador';

  @override
  String get modlog => 'Registro da moderação';

  @override
  String get mostComments => 'Mais comentários';

  @override
  String get mustBeLoggedIn => 'Você precisa estar logado';

  @override
  String get mustBeLoggedInComment => 'Você precisa estar logado para comentar';

  @override
  String get mustBeLoggedInPost =>
      'Você precisa estar logado para criar uma postagem';

  @override
  String get names => 'Nomes';

  @override
  String get navbarDoubleTapGestures =>
      'Gestos de toque duplo na barra de navegação';

  @override
  String get navbarSwipeGestures => 'Gestos de deslizar na barra de navegação';

  @override
  String get navigateDown => 'Próximo comentário';

  @override
  String get navigateUp => 'Comentário anterior';

  @override
  String get navigation => 'Navegação';

  @override
  String get nestedCommentIndicatorColor =>
      'Cor do indicador de comentário aninhado';

  @override
  String get nestedCommentIndicatorStyle =>
      'Estilo do indicador de comentário aninhado';

  @override
  String get never => 'Nunca';

  @override
  String get newComments => 'Novos comentários';

  @override
  String get newPost => 'Nova postagem';

  @override
  String get new_ => 'Novo';

  @override
  String get no => 'Não';

  @override
  String get noAccountsAdded => 'Nenhuma conta foi adicionada';

  @override
  String get noAnonymousInstances => 'Nenhuma instância anônima foi adicionada';

  @override
  String get noCommentsFound => 'Nenhum comentário encontrado';

  @override
  String get noCommunitiesFound => 'Nenhuma comunidade encontrada';

  @override
  String get noCommunityBlocks => 'Nenhuma comunidade bloqueada';

  @override
  String get noCompatibleAppFound => 'Nenhum aplicativo compatível encontrado';

  @override
  String get noDiscussionLanguages =>
      'Nenhum conteúdo é ocultado com base no idioma.';

  @override
  String get noDisplayNameSet => 'Nenhum nome de exibição definido';

  @override
  String get noEmailSet => 'Nenhum e-mail definido';

  @override
  String get noFavoritedCommunities => 'Nenhuma comunidade favoritada';

  @override
  String get noImages => 'Parece que você não carregou nenhuma imagem.';

  @override
  String get noInstanceBlocks => 'Nenhuma instância bloqueada.';

  @override
  String get noItems => 'Sem itens';

  @override
  String get noKeywordFilters => 'Nenhum filtro de palavra-chave adicionado';

  @override
  String get noLanguage => 'Nenhum idioma';

  @override
  String get noMatrixUserSet => 'Nenhum usuário matrix definido';

  @override
  String get noMentions => 'Nenhuma menção';

  @override
  String get noMessages => 'Nenhuma mensagem';

  @override
  String get noPostsFound => 'Nenhuma postagem encontrada.';

  @override
  String get noProfileBioSet => 'Nenhuma biografia definida no perfil';

  @override
  String get noReferencesToImage =>
      'Não foram encontradas postagens ou comentários contendo esta imagem. No entanto, ela pode ser usada em outros locais na internet.';

  @override
  String get noReplies => 'Nenhuma resposta';

  @override
  String get noResultsFound => 'Nenhum resultado encontrado.';

  @override
  String get noSubscriptions => 'Sem inscrições';

  @override
  String get noUserBlocks => 'Nenhum usuário bloqueado.';

  @override
  String get noUserLabels => 'Você ainda não criou nenhum rótulo de usuário';

  @override
  String get noUsersFound => 'Nenhum usuário encontrado.';

  @override
  String get noVisibleComments =>
      'Os comentários podem não estar visíveis porque a comunidade está bloqueada.';

  @override
  String get none => 'Nenhum';

  @override
  String get normal => 'Normal';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance não parece ser uma instância válida';
  }

  @override
  String get notValidUrl => 'URL inválido';

  @override
  String get nothingToShare => 'Nada a compartilhar';

  @override
  String notifications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notificações',
      one: 'Notificação',
      zero: 'Notificações',
    );
    return '$_temp0';
  }

  @override
  String get notificationsBehaviourSettings => 'Notificações';

  @override
  String get notificationsNotAllowed =>
      'As notificações não são permitidas para o Thunder nas configurações do sistema';

  @override
  String get notificationsWarningDialog =>
      'As notificações são um **recurso experimental** que pode não funcionar corretamente em todos os dispositivos.\n\n- As verificações ocorrerão a cada 15 minutos e consumirão bateria adicional.\n\n- Desative as otimizações da bateria para aumentar a probabilidade de sucesso das notificações.\n\nConsulte a página a seguir para obter mais informações.';

  @override
  String get nsfw => 'NSFW';

  @override
  String get nsfwWarning => 'NSFW - Toque para revelar';

  @override
  String get off => 'desligado';

  @override
  String get offline => 'off-line';

  @override
  String get ok => 'OK';

  @override
  String get old => 'Antigo';

  @override
  String get on => 'ligado';

  @override
  String get onWifi => 'No Wifi';

  @override
  String get onlyModsCanPostInCommunity =>
      'Apenas moderadores podem publicar nesta comunidade';

  @override
  String get open => 'Abrir';

  @override
  String get openAccountSwitcher => 'Abrir alternador de conta';

  @override
  String get openByDefault => 'Abrir por padrão';

  @override
  String get openInBrowser => 'Abrir no navegador';

  @override
  String get openInstance => 'Abrir instância';

  @override
  String get openLinksInExternalBrowser => 'Abrir links no navegador externo';

  @override
  String get openLinksInReaderMode => 'Abrir links no modo leitor';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get orange => 'Laranja';

  @override
  String get originalPoster => 'Postador original';

  @override
  String get overview => 'Visão geral';

  @override
  String get password => 'Senha';

  @override
  String get pending => 'Pendente';

  @override
  String performedBy(Object user) {
    return 'Executado por: $user';
  }

  @override
  String get permissionDenied =>
      'O Thunder não recebeu permissão para exibir notificações. Ative essa opção nas configurações do sistema.';

  @override
  String get permissionDeniedMessage =>
      'O Thunder requer algumas permissões para salvar esta imagem, que foram negadas.';

  @override
  String get pinPostToCommunity => 'Fixar postagem na comunidade';

  @override
  String get pinToCommunity => 'Fixar na comunidade';

  @override
  String get pinned => 'Fixado';

  @override
  String get pinnedPostToCommunity => 'Postagem fixada na comunidade';

  @override
  String get pinnedPostsUseCompactView => 'Mostrar postagens fixadas compactas';

  @override
  String get placeholderText =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  @override
  String get post => 'Postagem';

  @override
  String get postActions => 'Ações de postagem';

  @override
  String get postBehaviourSettings => 'Postagens';

  @override
  String get postBody => 'Corpo de postagem';

  @override
  String get postBodySettings => 'Configurações do corpo de postagem';

  @override
  String get postBodySettingsDescription =>
      'Estas configurações afetam a exibição do corpo da postagem';

  @override
  String get postBodyShowCommunityInstance => 'Exibir instância da comunidade';

  @override
  String get postBodyShowUserInstance => 'Exibir instância do usuário';

  @override
  String get postBodyViewType => 'Tipo da visualização do corpo da postagem';

  @override
  String get postContentFontScale => 'Escala da fonte de conteúdo de postagens';

  @override
  String get postCreatedSuccessfully => 'Postagem criada com sucesso!';

  @override
  String get postLocked => 'Postagem trancada. Não são permitidas respostas.';

  @override
  String get postMetadataInstructions =>
      'Você pode personalizar as informações de metadados arrastando e soltando as informações desejadas';

  @override
  String get postNSFW => 'Marcar como NSFW';

  @override
  String get postPreview =>
      'Mostrar uma pré-visualização da postagem com as configurações definidas';

  @override
  String get postSavedAsDraft => 'Postagem salva como rascunho';

  @override
  String get postShowUserInstance => 'Exibir instância do usuário';

  @override
  String get postSwipeActions => 'Ações de deslizar na postagem';

  @override
  String get postSwipeGesturesHint =>
      'Prefere usar botões? Altere os botões que aparecem nos cartões de postagem nas configurações gerais.';

  @override
  String get postTitle => 'Título';

  @override
  String get postTitleFontScale => 'Escala da fonte de título de postagens';

  @override
  String get postTogglePreview => 'Alternar pré-visualização';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Não foi possível fazer upload da imagem';

  @override
  String get postViewType => 'Tipo da visualização de postagens';

  @override
  String get posts => 'Postagens';

  @override
  String get preview => 'Pré-visualização';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile aplicado com sucesso!';
  }

  @override
  String get profileBio => 'Biografia no perfil';

  @override
  String get profiles => 'Perfis';

  @override
  String get public => 'Público';

  @override
  String get pureBlack => 'Preto puro';

  @override
  String get purgedComment => 'Comentário eliminado';

  @override
  String get purgedCommunity => 'Comunidade eliminada';

  @override
  String get purgedPerson => 'Pessoa eliminada';

  @override
  String get purgedPost => 'Postagem eliminada';

  @override
  String get purple => 'Roxo';

  @override
  String get pushNotification => 'Notificações push';

  @override
  String get pushNotificationDescription =>
      'Se ativado, o Thunder enviará seu(s) token(s) JWT ao servidor para verificar se há novas notificações. \n\n **OBSERVAÇÃO:** Isso só entrará em vigor na próxima vez que o aplicativo for iniciado.';

  @override
  String get pushNotificationServer => 'Servidor de notificações push';

  @override
  String get pushNotificationServerDescription =>
      'Configure o servidor de notificações push. O servidor deve estar devidamente configurado para enviar notificações push para o seu dispositivo.\n\n **Insira apenas um servidor em que você confia com suas credenciais.**';

  @override
  String get rateLimitErrorMessage =>
      'Você atingiu o limite de taxa para esta solicitação. Aguarde e tente novamente mais tarde.';

  @override
  String get reachedTheBottom => 'Não há mais itens para carregar';

  @override
  String get read => 'Lido';

  @override
  String get readAll => 'Ler tudo';

  @override
  String get readerMode => 'Modo leitor';

  @override
  String get reason => 'Motivo';

  @override
  String get red => 'Vermelho';

  @override
  String get reduceAnimations => 'Reduzir animações';

  @override
  String get reducesAnimations => 'Reduze as animações usadas no Thunder';

  @override
  String get refresh => 'Atualizar';

  @override
  String get refreshContent => 'Atualizar conteúdo';

  @override
  String get removalReason => 'Motivo da remoção';

  @override
  String get remove => 'Remover';

  @override
  String get removeAccount => 'Remover conta';

  @override
  String get removeAsCommunityModerator =>
      'Remover como moderador de comunidade';

  @override
  String get removeComment => 'Remover comentário';

  @override
  String get removeFromFavorites => 'Remover dos favoritos';

  @override
  String get removeInstance => 'Remover instância';

  @override
  String removeKeyword(Object keyword) {
    return 'Remover \"$keyword\"?';
  }

  @override
  String get removeKeywordFilter => 'Remover palavra-chave';

  @override
  String get removePost => 'Remover postagem';

  @override
  String get removeUserData => 'Remover dados do usuário';

  @override
  String get removed => 'Removido';

  @override
  String get removedComment => 'Comentário removido';

  @override
  String get removedCommunity => 'Comunidade removida';

  @override
  String get removedCommunityFromSubscriptions =>
      'Cancelou a inscrição da comunidade';

  @override
  String get removedInstanceMod => 'Moderador da instância removido';

  @override
  String get removedModFromCommunity => 'Moderador removido da comunidade';

  @override
  String get removedPost => 'Postagem removida';

  @override
  String removedUserAsCommunityModerator(Object username) {
    return '$username removido(a) como moderador da comunidade';
  }

  @override
  String get reorder => 'Reordenar';

  @override
  String reply(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Respostas',
      one: 'Resposta',
      zero: 'Respostas',
    );
    return '$_temp0';
  }

  @override
  String get replyColor => 'Cor de resposta';

  @override
  String get replyNotSupported =>
      'Atualmente, ainda não é possível responder a partir desta visualização';

  @override
  String get replyToPost => 'Responder à postagem';

  @override
  String replyingTo(Object author) {
    return 'Respondendo a $author';
  }

  @override
  String report(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Relatórios',
      one: 'Relatório',
      zero: 'Relatórios',
    );
    return '$_temp0 ';
  }

  @override
  String get reportComment => 'Denunciar comentário';

  @override
  String get reportPost => 'Denunciar postagem';

  @override
  String get reportedComment => 'Comentário denunciado';

  @override
  String get reportedPost => 'Postagem denunciada';

  @override
  String get reporter => 'Relator:';

  @override
  String get requiredField => '*obrigatório';

  @override
  String get reset => 'Redefinir';

  @override
  String get resetCommentPreferences =>
      'Reiniciar as preferências de comentários';

  @override
  String get resetPostPreferences => 'Reiniciar as preferências de postagens';

  @override
  String get resetPreferences => 'Reiniciar preferências';

  @override
  String get resetPreferencesAndData => 'Reiniciar preferências e dados';

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreComment => 'Restaurar comentário';

  @override
  String get restorePost => 'Restaurar postagem';

  @override
  String get restoredComment => 'Comentário restaurado';

  @override
  String get restoredCommentFromDraft => 'Comentário restaurado do rascunho';

  @override
  String get restoredCommunity => 'Comunidade restaurada';

  @override
  String get restoredPost => 'Postagem restaurada';

  @override
  String get restoredPostFromDraft => 'Postagem restaurada do rascunho';

  @override
  String get retry => 'Retentar';

  @override
  String get rightLongSwipe => 'Deslize longo para a direita';

  @override
  String get rightShortSwipe => 'Deslize curto para a direita';

  @override
  String get save => 'Salvar';

  @override
  String get saveColor => 'Salvar cor';

  @override
  String get saveSettings => 'Salvar configurações';

  @override
  String get saved => 'Salvo';

  @override
  String get scaled => 'Escalonado';

  @override
  String get scrapeMissingLinkPreviews =>
      'Obter pré-visualizações de links ausentes';

  @override
  String get screenReaderProfile => 'Perfil do leitor de tela';

  @override
  String get screenReaderProfileDescription =>
      'Otimiza o Thunder para leitores de tela, reduzindo os elementos gerais e removendo gestos potencialmente conflitantes.';

  @override
  String get search => 'Pesquisa';

  @override
  String get searchByText => 'Pesquisar por texto';

  @override
  String get searchByUrl => 'Pesquisar por URL';

  @override
  String get searchComments => 'Pesquisar comentários';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return 'Pesquisar comentários federados com $instance';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return 'Pesquisar comunidades federadas com $instance';
  }

  @override
  String searchInstance(Object instance) {
    return 'Pesquisar $instance';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return 'Pesquisar instâncias federadas com $instance';
  }

  @override
  String get searchPostSearchType => 'Selecionar tipo de pesquisa de postagens';

  @override
  String searchPostsFederatedWith(Object instance) {
    return 'Pesquisar postagens federadas com $instance';
  }

  @override
  String get searchTerm => 'Pesquisar termo';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Pesquisar usuários federados com $instance';
  }

  @override
  String get selectAccountToCommentAs =>
      'Selecione a conta com a qual deseja comentar';

  @override
  String get selectAccountToPostAs =>
      'Selecione a conta com a qual deseja fazer a postagem';

  @override
  String get selectAll => 'Selecionar tudo';

  @override
  String get selectCommunity => 'Selecione uma comunidade (obrigatório)';

  @override
  String get selectFeedType => 'Selecionar tipo de feed';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get selectSearchType => 'Selecionar tipo de pesquisa';

  @override
  String get selectText => 'Selecionar texto';

  @override
  String get sendBackgroundTestLocalNotification =>
      'Enviar notificação local de teste em segundo plano';

  @override
  String get sendBackgroundTestUnifiedPushNotification =>
      'Enviar teste em segundo plano de notificação UnifiedPush';

  @override
  String get sendTestLocalNotification => 'Enviar notificação local de teste';

  @override
  String get sendTestUnifiedPushNotification =>
      'Enviar teste de notificação UnifiedPush';

  @override
  String get sensitiveContentWarning =>
      'Pode conter conteúdo sensível. Toque para revelar.';

  @override
  String get sentRequestForTestNotification =>
      'Enviada solicitação de notificação de teste.';

  @override
  String serverErrorComments(Object message) {
    return 'Ocorreu um erro no servidor ao buscar mais comentários: $message';
  }

  @override
  String get setAction => 'Definir ação';

  @override
  String get setLongPress => 'Definir como ação de toque longo';

  @override
  String get setShortPress => 'Definir como ação de toque curto';

  @override
  String get settingOverrideLabel =>
      'Estas configurações substituem as configurações padrão do Thunder.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'As configurações do tipo $settingType ainda não são suportadas.';
  }

  @override
  String get settings => 'Configurações';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'As configurações foram salvas com sucesso em \'$savedFilePath\'';
  }

  @override
  String get settingsFeedCards =>
      'Estas configurações se aplicam aos cartões no feed principal, as ações estão sempre disponíveis ao abrir as postagens.';

  @override
  String get settingsImportedSuccessfully =>
      'As configurações foram importadas com sucesso!';

  @override
  String get settingsNotExportedSuccessfully =>
      'As configurações não foram salvas com sucesso ou a operação foi cancelada.';

  @override
  String get settingsNotImportedSuccessfully =>
      'As configurações não foram importadas com sucesso ou a operação foi cancelada.';

  @override
  String get settingsPage => 'Página das configurações';

  @override
  String get settingsPageAbout => 'Sobre';

  @override
  String get settingsPageAccessibility => 'Acessibilidade';

  @override
  String get settingsPageAccount => 'Conta';

  @override
  String get settingsPageAccountBlocks => 'Listas de bloqueios';

  @override
  String get settingsPageAccountLanguages => 'Idiomas de discussão';

  @override
  String get settingsPageAccountMedia => 'Gerenciar mídia';

  @override
  String get settingsPageAppearance => 'Aparência';

  @override
  String get settingsPageAppearanceComments => 'Comentários';

  @override
  String get settingsPageAppearancePosts => 'Postagens';

  @override
  String get settingsPageAppearanceTheming => 'Temas';

  @override
  String get settingsPageDebug => 'Depuração';

  @override
  String get settingsPageFilters => 'Filtros';

  @override
  String get settingsPageFloatingActionButton => 'Botão de ação flutuante';

  @override
  String get settingsPageGeneral => 'Geral';

  @override
  String get settingsPageGestures => 'Gestos';

  @override
  String get settingsPageUserLabels => 'Rótulos de usuário';

  @override
  String get settingsPageVideo => 'Vídeo';

  @override
  String get share => 'Compartilhar';

  @override
  String get shareComment => 'Compartilhar link do comentário';

  @override
  String get shareCommentLocal =>
      'Compartilhar link do comentário (minha instância)';

  @override
  String get shareCommunity => 'Compartilhar comunidade';

  @override
  String get shareCommunityLink => 'Compartilhar link da comunidade';

  @override
  String get shareCommunityLinkLocal =>
      'Compartilhar link da comunidade (minha instância)';

  @override
  String get shareImage => 'Compartilhar imagem';

  @override
  String get shareLemmyLink => 'Compartilhar link do Lemmy';

  @override
  String get shareLink => 'Compartilhar link externo';

  @override
  String get shareMedia => 'Compartilhar mídia';

  @override
  String get shareMediaLink => 'Compartilhar link da mídia';

  @override
  String get shareOriginalLink => 'Compartilhar link original';

  @override
  String get sharePost => 'Compartilhar link da postagem';

  @override
  String get sharePostLocal =>
      'Compartilhar link da postagem (minha instância)';

  @override
  String get shareThumbnail => 'Compartilhar miniatura';

  @override
  String get shareThumbnailAsImage => 'Compartilhar miniatura como imagem';

  @override
  String get shareUser => 'Compartilhar usuário';

  @override
  String get shareUserLink => 'Compartilhar link do usuário';

  @override
  String get shareUserLinkLocal =>
      'Compartilhar link do usuário (minha instância)';

  @override
  String get showAll => 'Mostrar tudo';

  @override
  String get showBotAccounts => 'Mostrar contas de robô';

  @override
  String get showCommentActionButtons =>
      'Mostrar botões de ações de comentários';

  @override
  String get showCommunityDisplayNames =>
      'Mostrar nomes de exibição de comunidades';

  @override
  String get showCrossPosts => 'Mostrar postagens cruzadas';

  @override
  String get showEdgeToEdgeImages => 'Mostrar imagens de borda a borda';

  @override
  String get showExpandedTaglines => 'Mostrar linhas de etiquetas expandidas';

  @override
  String get showFullDate => 'Mostrar data completa';

  @override
  String get showFullDateDescription => 'Mostrar data completa nas postagens';

  @override
  String get showFullHeightImages => 'Mostrar imagens em altura total';

  @override
  String get showHiddenPosts => 'Mostrar postagens ocultas';

  @override
  String get showInAppUpdateNotifications =>
      'Receba notificações sobre novos lançamentos no GitHub';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get showMore => 'Mostrar mais';

  @override
  String get showNavigationLabels => 'Mostrar rótulos de navegação';

  @override
  String get showNavigationLabelsDescription =>
      'Definir se os rótulos devem ser exibidos abaixo dos botões de navegação inferiores';

  @override
  String get showNsfwContent => 'Mostrar conteúdo NSFW';

  @override
  String get showOwnContent => 'Mostrar conteúdo próprio';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get showPostAuthor => 'Mostrar autor de postagem';

  @override
  String get showPostAuthorSubtitle =>
      'O autor da postagem é sempre exibido nos feeds da comunidade';

  @override
  String get showPostCommunityFirst => 'Mostrar comunidade e autor primeiro';

  @override
  String get showPostCommunityIcons => 'Mostrar ícones das comunidades';

  @override
  String get showPostSaveAction => 'Mostrar botão salvar';

  @override
  String get showPostTextContentPreview => 'Mostrar pré-visualização de texto';

  @override
  String get showPostTitleFirst => 'Mostrar título primeiro';

  @override
  String get showPostVoteActions => 'Mostrar botões para votar';

  @override
  String get showReadPosts => 'Mostrar postagens lidas';

  @override
  String get showSavedContent => 'Mostrar conteúdo salvo';

  @override
  String get showScoreCounters => 'Exibir pontuações dos usuários';

  @override
  String get showScores => 'Exibir pontuações das postagens/dos comentários';

  @override
  String get showTextPostIndicator => 'Mostrar indicador de postagem de texto';

  @override
  String get showThumbnailPreviewOnRight => 'Mostrar miniaturas à direita';

  @override
  String get showUnreadOnly => 'Mostrar somente não lidas';

  @override
  String get showUpdateChangelogs =>
      'Mostrar registros de alterações para atualizações';

  @override
  String get showUpdateChangelogsSubtitle =>
      'Exibir uma lista de alterações após uma atualização';

  @override
  String get showUserAvatar => 'Mostrar avatar de usuário';

  @override
  String get showUserDisplayNames => 'Mostrar nomes de exibição dos usuários';

  @override
  String get showUserInstance => 'Mostrar instância de usuário';

  @override
  String get sidebar => 'Barra lateral';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Toque duas vezes na barra de navegação inferior para abrir a barra lateral';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Deslize a barra de navegação inferior para abrir a barra lateral';

  @override
  String get small => 'Pequeno';

  @override
  String get somethingWentWrong => 'Opa, algo deu errado!';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortByTop => 'Ordenar por melhores';

  @override
  String get sortOptions => 'Opções de ordenação';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get standard => 'Padrão';

  @override
  String get stats => 'Estatísticas';

  @override
  String get status => 'Status';

  @override
  String get submit => 'Enviar';

  @override
  String get subscribe => 'Inscrever-se';

  @override
  String get subscribeToCommunity => 'Inscrever-se na comunidade';

  @override
  String get subscribed => 'Inscrito';

  @override
  String get subscriptionRequestSent => 'Pedido de inscrição enviado';

  @override
  String get subscriptions => 'Inscrições';

  @override
  String successfullyBannedUser(Object username) {
    return '$username banido';
  }

  @override
  String get successfullyBlocked => 'Bloqueado.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return '$communityName bloqueado';
  }

  @override
  String successfullyBlockedUser(Object username) {
    return '$username bloqueado(a)';
  }

  @override
  String successfullyUnbannedUser(Object username) {
    return '$username desbanido(a)';
  }

  @override
  String get successfullyUnblocked => 'Desbloqueado.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return '$communityName desbloqueado';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return '$username desbloqueado(a)';
  }

  @override
  String get suchAs => 'como';

  @override
  String get suggestedTitle => 'Título sugerido';

  @override
  String switchedAccount(Object username) {
    return 'Mudou para $username';
  }

  @override
  String get system => 'Sistema';

  @override
  String get systemDarkMode => 'Preto puro';

  @override
  String get systemDarkModeDescription =>
      'Ativar tema preto puro para o modo escuro';

  @override
  String get tabletMode => 'Modo tablet (visualização em 2 colunas)';

  @override
  String get tapToExit => 'Pressione voltar novamente para sair';

  @override
  String get tappableAuthorCommunity => 'Autores e comunidades tocáveis';

  @override
  String get teal => 'Azul-petróleo';

  @override
  String get testBackgroundNotificationDescription =>
      'O Thunder será fechado e tentará gerar uma notificação em segundo plano. (Isso levará pelo menos 15 minutos.)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'O Thunder solicitará ao servidor de notificações que envie uma notificação atrasada e, em seguida, se fechará. (Isso pode levar alguns minutos.)';

  @override
  String get text => 'Texto';

  @override
  String get textActions => 'Ações de texto';

  @override
  String get theme => 'Tema';

  @override
  String get themeAccentColor => 'Cores de destaque';

  @override
  String get themePrimary => 'Tema primário';

  @override
  String get themeSecondary => 'Tema secundário';

  @override
  String get themeTertiary => 'Tema terciário';

  @override
  String get theming => 'Temas';

  @override
  String get thickness => 'Espessura';

  @override
  String get thisAccount => 'Esta conta';

  @override
  String get thumbnailUrl => 'URL da miniatura';

  @override
  String thunderHasBeenUpdated(Object version) {
    return 'O Thunder foi atualizado para a versão $version!';
  }

  @override
  String thunderNotificationServer(Object server) {
    return 'Servidor de notificações do Thunder: $server';
  }

  @override
  String get timeoutComments =>
      'Erro: Tempo limite ao tentar buscar comentários';

  @override
  String get timeoutErrorMessage =>
      'Houve um tempo limite aguardando uma resposta.';

  @override
  String get timeoutSaveComment =>
      'Erro: Tempo limite ao tentar salvar um comentário';

  @override
  String get timeoutSavingPost =>
      'Erro: Tempo limite ao tentar salvar a postagem.';

  @override
  String get timeoutUpvoteComment =>
      'Erro: Tempo limite ao tentar votar em um comentário';

  @override
  String get timeoutVotingPost =>
      'Erro: Tempo limite ao tentar votar na postagem.';

  @override
  String get toggelRead => 'Alternar status de leitura';

  @override
  String get top => 'Melhores';

  @override
  String get topAll => 'Melhores te todos os tempos';

  @override
  String get topDay => 'Melhores hoje';

  @override
  String get topHour => 'Melhores na última hora';

  @override
  String get topMonth => 'Melhores mês';

  @override
  String get topNineMonths => 'Melhores nos últimos 9 meses';

  @override
  String get topSixHour => 'Melhores nas últimas 6 horas';

  @override
  String get topSixMonths => 'Melhores nos últimos 6 meses';

  @override
  String get topThreeMonths => 'Melhores nos últimos 3 meses';

  @override
  String get topTwelveHour => 'Melhores nas últimas 12 horas';

  @override
  String get topWeek => 'Melhores semana';

  @override
  String get topYear => 'Melhores ano';

  @override
  String totalComments(Object x) {
    return '$x comentários';
  }

  @override
  String totalPosts(Object x) {
    return '$x postagens';
  }

  @override
  String get totp => 'TOTP (opcional)';

  @override
  String get transferredModToCommunity => 'Comunidade transferida';

  @override
  String get translationsMayNotBeComplete =>
      'Observe que as traduções podem não estar completas';

  @override
  String get trendingCommunities => 'Comunidades em destaque';

  @override
  String get trySearchingFor => 'Tente pesquisar por…';

  @override
  String get unableToFindCommunity => 'Não é possível encontrar a comunidade';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'Não é possível encontrar a comunidade \'$communityName\'';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Não é possível encontrar a comunidade selecionada na instância do usuário selecionado.';

  @override
  String get unableToFindInstance => 'Não é possível encontrar a instância';

  @override
  String get unableToFindLanguage => 'Não é possível encontrar o idioma';

  @override
  String get unableToFindPost => 'Não é possível encontrar a postagem';

  @override
  String get unableToFindUser => 'Não é possível encontrar o usuário';

  @override
  String unableToFindUserName(Object username) {
    return 'Não é possível encontrar o usuário \'$username\'';
  }

  @override
  String get unableToLoadImage => 'Não é possível carregar a imagem';

  @override
  String unableToLoadImageFrom(Object domain) {
    return 'Não é possível carregar a imagem de $domain';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return 'Não é possível carregar $instance';
  }

  @override
  String get unableToLoadPost => 'Não é possível carregar a postagem';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return 'Não é possível carregar postagens de $instance';
  }

  @override
  String get unableToLoadReplies => 'Não é possível carregar mais respostas.';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return 'Não é possível navegar a $instanceHost. Pode não ser uma instância Lemmy válida.';
  }

  @override
  String get unableToResolveReport => 'Não é possível resolver o relatório';

  @override
  String unableToRetrieveChangelog(Object version) {
    return 'Não é possível recuperar o registro de alterações da versão $version.';
  }

  @override
  String get unbanFromCommunity => 'Desbanir da comunidade';

  @override
  String get unbannedUser => 'Usuário desbanido';

  @override
  String unbannedUserFromCommunity(Object username) {
    return '$username desbanido(a) da comunidade';
  }

  @override
  String get unblock => 'Desbloquear';

  @override
  String get unblockCommunity => 'Desbloquear comunidade';

  @override
  String get unblockCommunityInstance => 'Desbloquear instância da comunidade';

  @override
  String get unblockInstance => 'Desbloquear instância';

  @override
  String get unblockUser => 'Desbloquear usuário';

  @override
  String get unblockUserInstance => 'Desbloquear instância do usuário';

  @override
  String get understandEnable => 'Eu entendo, ative';

  @override
  String get unexpectedError => 'Erro inesperado';

  @override
  String get unfavorite => 'Desfavoritar';

  @override
  String get unfeaturedPost => 'Postagem marcada como não em destaque';

  @override
  String get unhidCommunity => 'Comunidade desocultada';

  @override
  String get unhide => 'Desocultar';

  @override
  String unifiedPushDistributorApp(Object app, Object count) {
    return 'Aplicativo distribuidor UnifiedPush: $app ($count disponíveis)';
  }

  @override
  String get unifiedPushNotifications => 'Notificações UnifiedPush';

  @override
  String unifiedPushServer(Object server) {
    return 'Servidor UnifiedPush: $server';
  }

  @override
  String get unifiedpush => 'UnifiedPush';

  @override
  String get unlockPost => 'Destrancar postagem';

  @override
  String get unlockedPost => 'Postagem destrancada';

  @override
  String get unpinFromCommunity => 'Desfixar da comunidade';

  @override
  String get unpinPostFromCommunity => 'Desfixar postagem da comunidade';

  @override
  String get unpinnedPostFromCommunity => 'Postagem desfixada da comunidade';

  @override
  String get unreachable => 'Inacessível';

  @override
  String get unresolved => 'Não resolvido';

  @override
  String get unsubscribe => 'Cancelar inscrição';

  @override
  String get unsubscribeFromCommunity => 'Cancelar inscrição da comunidade';

  @override
  String get unsubscribePending => 'Cancelar inscrição (inscrição pendente)';

  @override
  String get unsubscribed => 'Inscrição cancelada';

  @override
  String updateReleased(Object version) {
    return 'Atualização lançada: $version';
  }

  @override
  String get uploadImage => 'Fazer upload de imagem';

  @override
  String uploadedDate(Object date) {
    return 'Upload: $date';
  }

  @override
  String get upvote => 'Voto positivo';

  @override
  String get upvoteColor => 'Cor de voto positivo';

  @override
  String get upvoted => 'Voto positivo';

  @override
  String get uriNotSupported => 'Este tipo de link não é suportado no momento.';

  @override
  String get url => 'URL';

  @override
  String get useAdvancedShareSheet =>
      'Usar o painel de compartilhamento avançado';

  @override
  String get useApplePushNotifications => 'Usar notificações APN';

  @override
  String get useApplePushNotificationsDescription =>
      'Utiliza o serviço de notificações push da Apple';

  @override
  String get useCompactView =>
      'Ative para postagens pequenas, desative para grandes.';

  @override
  String get useLocalNotifications => 'Usar notificações locais (experimental)';

  @override
  String get useLocalNotificationsDescription =>
      'Verifica periodicamente se há notificações em segundo plano';

  @override
  String get useMaterialYouTheme => 'Usar tema Material You';

  @override
  String get useMaterialYouThemeDescription =>
      'Substitui o tema personalizado selecionado';

  @override
  String get useProfilePictureForDrawer => 'Usar foto de perfil para gaveta';

  @override
  String get useProfilePictureForDrawerSubtitle =>
      'Quando logado, mostra a foto do perfil do usuário no lugar do ícone da gaveta';

  @override
  String useSuggestedTitle(Object title) {
    return 'Usar título sugerido: $title';
  }

  @override
  String get useUnifiedPushNotifications => 'Usar notificações UnifiedPush';

  @override
  String get useUnifiedPushNotificationsDescription =>
      'Requer um aplicativo compatível';

  @override
  String get user => 'Usuário';

  @override
  String get userActions => 'Ações de usuário';

  @override
  String userEntry(Object username) {
    return 'Usuário \'$username\'';
  }

  @override
  String get userFormat => 'Formato do usuário';

  @override
  String get userLabelHint => 'Este é o meu usuário favorito';

  @override
  String get userLabels => 'Rótulos de usuário';

  @override
  String get userLabelsSettingsPageDescription =>
      'Você pode adicionar, modificar ou remover rótulos associados aos usuários.';

  @override
  String get userNameColor => 'Cor do nome de usuário';

  @override
  String get userNameThickness => 'Espessura do nome de usuário';

  @override
  String get userNotLoggedIn => 'Usuário não logado';

  @override
  String get userProfiles => 'Perfis de usuário';

  @override
  String get userSettingDescription =>
      'Estas configurações são sincronizadas com sua conta Lemmy e são aplicadas apenas por conta.';

  @override
  String get userStyle => 'Estilo de usuário';

  @override
  String get username => 'Nome de usuário';

  @override
  String get usernameFormattingRedirect =>
      'Procurando por formatação de nome de usuário?';

  @override
  String get users => 'Usuários';

  @override
  String versionNumber(Object version) {
    return 'Versão $version';
  }

  @override
  String get video => 'Vídeo';

  @override
  String get videoAutoFullscreen => 'Tela cheia automática';

  @override
  String get videoAutoLoop => 'Vídeo em loop';

  @override
  String get videoAutoMute => 'Silenciar vídeos';

  @override
  String get videoAutoPlay => 'Reprodução automática de vídeos';

  @override
  String get videoDefaultPlaybackSpeed => 'Velocidade de reprodução padrão';

  @override
  String get videoLinkHandlingExternal =>
      'Reproduzir vídeo com um aplicativo externo';

  @override
  String get videoPlayerInApp => 'Use o reprodutor integrado do Thunder';

  @override
  String get videoPlayerMode => 'Modo de reprodutor';

  @override
  String get viewAll => 'Ver tudo';

  @override
  String get viewAllComments => 'Ver todos os comentários';

  @override
  String get viewCommentSource => 'Ver fonte do comentário';

  @override
  String get viewModlog => 'Ver registro de moderação';

  @override
  String get viewOriginal => 'Ver original';

  @override
  String get viewPostAsDifferentAccount => 'Ver postagem como conta diferente';

  @override
  String get viewPostSource => 'Ver fonte da postagem';

  @override
  String get viewSource => 'Ver fonte';

  @override
  String get viewingAll => 'Exibindo todos';

  @override
  String visibility(Object visibility) {
    return 'Visibilidade: $visibility';
  }

  @override
  String get visitCommunity => 'Visitar comunidade';

  @override
  String get visitCommunityInstance => 'Visitar instância da comunidade';

  @override
  String get visitInstance => 'Visitar instância';

  @override
  String get visitUserInstance => 'Visitar instância do usuário';

  @override
  String get visitUserProfile => 'Visitar perfil do usuário';

  @override
  String get warning => 'Aviso';

  @override
  String xDownvotes(Object x) {
    return '$x votos negativos';
  }

  @override
  String xScore(Object x) {
    return '$x pontuação';
  }

  @override
  String xUpvotes(Object x) {
    return '$x votos positivos';
  }

  @override
  String xYearsOld(num count, Object x) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$x anos de idade',
      one: '$x ano de idade',
      zero: '$x anos de idade',
    );
    return '$_temp0';
  }

  @override
  String get yes => 'Sim';

  @override
  String get youMustSelectAJsonFile => 'Você deve selecionar um arquivo .json.';
}
