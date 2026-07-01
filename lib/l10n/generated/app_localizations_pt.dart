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
    return 'O comentário selecionado não foi encontrado em \'$instance\'';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'A postagem selecionada não foi encontrada em \'$instance\'';
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
  String get activity => 'Atividade';

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
  String get addOriginalPostBody => 'Adicionar o corpo da postagem original?';

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
    return 'Adicionou $username como moderador de comunidade';
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
      'Tenha em conta que as verificações de notificação irão consumir mais bateria';

  @override
  String get ban => 'Banir';

  @override
  String get banFromCommunity => 'Banir da comunidade';

  @override
  String get bannedUser => 'Utilizador banido';

  @override
  String get bannedUserFromCommunity => 'Utilizador banido da comunidade';

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
  String get collapsePostPreview => 'Recolher pré-visualização da postagem';

  @override
  String get collapseSpoiler => 'Recolher spoiler';

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
  String get combineCommentScores => 'Combinar pontuações dos comentários';

  @override
  String get combineCommentScoresLabel => 'Combinar pontuações dos comentários';

  @override
  String get combineNavAndFab => 'Combinar FAB e Botões de Navegação';

  @override
  String get combineNavAndFabDescription =>
      'Floating Action Button will be shown between navigation buttons.';

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
      'Mostrar prévia dos comentários com as configurações aplicadas';

  @override
  String get commentReported => 'O comentário foi marcado para revisão.';

  @override
  String get commentSavedAsDraft => 'Comentário gravado como rascunho';

  @override
  String get commentShowUserAvatar => 'Mostrar Avatar do Utilizador';

  @override
  String get commentShowUserInstance => 'Exibir instância do utilizador';

  @override
  String get commentSortType => 'Tipo de ordenação dos comentários';

  @override
  String get commentSwipeActions => 'Ações de deslizar no comentário';

  @override
  String get commentSwipeGesturesHint =>
      'Quer usar botões? Ative-os na secção de comentários nas configurações gerais.';

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
  String get communityNameColor => 'Cor do nome da comunidade';

  @override
  String get communityNameThickness => 'Espessura do nome da comunidade';

  @override
  String get communityStyle => 'Estilo da Comunidade';

  @override
  String get compact => 'Compactar';

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
  String get confirmLogOutBody => 'Tem certeza que deseja sair?';

  @override
  String get confirmLogOutTitle => 'Sair?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Tem certeza que deseja marcar todas as respostas, menções e mensagens como lidas?';

  @override
  String get confirmMarkAllAsReadTitle => 'Marcar todas como lidas?';

  @override
  String get confirmResetCommentPreferences =>
      'Isto redefinirá todas as preferências de comentários. Tem certeza que deseja continuar?';

  @override
  String get confirmResetPostPreferences =>
      'Isto redefinirá todas as preferências de postagem. Tem certeza que deseja continuar?';

  @override
  String get confirmUnsubscription =>
      'Tem certeza que deseja cancelar a inscrição?';

  @override
  String connectedToUnifiedPushDistributorApp(Object app) {
    return 'Conectado a $app';
  }

  @override
  String get contentManagement => 'Gestão de conteúdo';

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
      'Erro: Não foi possível determinar a postagem para apagar o comentário.';

  @override
  String get couldNotDeterminePostComment =>
      'Erro: Não foi possível determinar a postagem a comentar.';

  @override
  String get couldntCreateReport =>
      'O seu relatório de comentário não pôde ser enviado neste momento. Por favor, tente novamente mais tarde';

  @override
  String get couldntFindPost =>
      'Não foi possível carregar a postagem solicitada. Ela pode ter sido apagada ou removida.';

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
    return '$count utilizadores';
  }

  @override
  String countUsersActiveDay(Object count) {
    return '$count utilizadores/dia';
  }

  @override
  String countUsersActiveHalfYear(Object count) {
    return '$count utilizadores/6 meses';
  }

  @override
  String countUsersActiveMonth(Object count) {
    return '$count utilizadores/mês';
  }

  @override
  String countUsersActiveWeek(Object count) {
    return '$count utilizadores/sem';
  }

  @override
  String get createAccount => 'Criar conta';

  @override
  String get createComment => 'Criar comentário';

  @override
  String get createNewCrossPost => 'Criar postagem cruzada';

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
      'A base de dados pode conter informações confidenciais relacionadas à sua conta Lemmy. Se exportá-lo, não deve partilhá-lo com ninguém. Deseja continuar?';

  @override
  String databaseExportedSuccessfully(Object savedFilePath) {
    return 'A base de dados foi exportada com sucesso para \'$savedFilePath\'';
  }

  @override
  String get databaseImportedSuccessfully =>
      'A base de dados foi importada com sucesso!';

  @override
  String get databaseNotExportedSuccessfully =>
      'A base de dados não foi exportada com sucesso ou a operação foi cancelada.';

  @override
  String get databaseNotImportedSuccessfully =>
      'A base de dados não foi importada com sucesso ou a operação foi cancelada.';

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
  String get delete => 'Apagar';

  @override
  String get deleteAccount => 'Apagar conta';

  @override
  String get deleteAccountDescription =>
      'Para apagar a sua conta permanentemente, será redirecionado para o site da sua instância.\n\nTem certeza que deseja continuar?';

  @override
  String get deleteComment => 'Apagar comentário';

  @override
  String get deleteDraftConfirmation =>
      'Tem certeza que deseja apagar este rascunho?';

  @override
  String get deleteImageConfirmMessage =>
      'Tem certeza que deseja apagar esta imagem?';

  @override
  String get deleteImageConfirmTitle => 'Apagar?';

  @override
  String get deleteLocalDatabase => 'Apagar base de dados local';

  @override
  String get deleteLocalDatabaseDescription =>
      'Esta ação removerá a base de dados local e será desconectado de todas as suas contas.\n\nTem certeza que deseja continuar?';

  @override
  String get deleteLocalPreferences => 'Apagar preferências locais';

  @override
  String get deleteLocalPreferencesDescription =>
      'Isto limpará todas as suas preferências e configurações de utilizador no Thunder.\n\nDeseja continuar?';

  @override
  String get deletePost => 'Apagar postagem';

  @override
  String get deleteUserLabelConfirmation =>
      'Tem certeza que deseja apagar o rótulo?';

  @override
  String get deleted => 'Apagado';

  @override
  String get deletedByCreator => 'apagado pelo criador';

  @override
  String get deletedByModerator => 'apagado por um moderador';

  @override
  String get deletedComment => 'Apagou comentário';

  @override
  String get deletedPost => 'Apagou postagem';

  @override
  String get deselectUndeterminedWarning =>
      'Se desmarcar Indeterminado, não verá a maior parte do conteúdo.';

  @override
  String detailedReason(Object reason) {
    return 'Motivo: $reason';
  }

  @override
  String get dimReadPosts => 'Escurecer postagens lidas';

  @override
  String get directMessage => 'Mensagem direta';

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
  String get displayUserScore => 'Exibir pontuações dos utilizadores (karma).';

  @override
  String get dividerAppearance => 'Aparência do divisor';

  @override
  String get doNotShowAgain => 'Não mostrar novamente';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Encontradas várias apps compatíveis; instale apenas uma';

  @override
  String get downloadingMedia => 'A descarregar média a partilhar…';

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
  String get drafts => 'Rascunhos';

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
      'A ligação está vazia. Forneça uma ligação dinâmica válida para continuar.';

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
    return 'Ocorreu um erro ao apagar a imagem: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Não foi possível descarregar o ficheiro de média para partilhar: $errorMessage';
  }

  @override
  String get errorImportingAccountSettings =>
      'Ocorreu um erro ao importar as configurações. O ficheiro pode não estar no formato correto.';

  @override
  String get errorInitializingClient => 'Erro ao inicializar o cliente';

  @override
  String get errorLoadingAccountSettings =>
      'Ocorreu um erro ao carregar o ficheiro de configurações ou a operação foi cancelada.';

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
      'Ocorreu um erro ao analisar o ficheiro selecionado. Pode não ser um JSON válido.';

  @override
  String get errorSavingAccountSettings =>
      'Ocorreu um erro ao gravar o ficheiro de configurações ou a operação foi cancelada.';

  @override
  String get exceptionProcessingUri =>
      'Ocorreu um erro ao processar a ligação. Ele pode não estar disponível na sua instância.';

  @override
  String get excessiveApiCallsWarning =>
      'O seu feed pode se demorar a carregar devido aos filtros de palavras-chave.';

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
      'Estes recursos ainda estão em desenvolvimento e podem ser instáveis. Use-os pela sua própria conta e risco. É necessário reiniciar o Thunder para que as alterações tenham efeito.';

  @override
  String get exploreInstance => 'Explorar instância';

  @override
  String get exportDatabase => 'Exportar base de dados';

  @override
  String get exportDatabaseSubtitle =>
      'A base de dados contém informações sobre contas, favoritos, inscrições anônimas e rótulos de utilizadores.';

  @override
  String get exportLemmyAccountSettingsDescription =>
      'Exportar configurações de contas Lemmy';

  @override
  String get exportSettingsSubtitle =>
      'As configurações incluem todas as preferências que configurou no Thunder.';

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
  String get failedToCreateDefaultProfile => 'Failed to create default profile';

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return 'Não foi possível carregar bloqueios: $errorMessage';
  }

  @override
  String get failedToLoadVideo =>
      'Falha ao carregar o vídeo. Abrir a ligação no navegador?';

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
    return 'A filtrar por $entity';
  }

  @override
  String get filters => 'Filtros';

  @override
  String get floatingActionButton => 'Botão de ação flutuante';

  @override
  String get floatingActionButtonInformation =>
      'O Thunder tem uma experiência FAB totalmente personalizável que suporta alguns gestos.\n- Deslize para cima para revelar ações FAB adicionais\n- Deslize para baixo/cima para ocultar ou revelar o FAB\n\nPara personalizar as ações principais e secundárias do FAB, pressione longamente uma das ações abaixo.';

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
      'App compatível encontrada; reinicie o Thunder para conectar';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Deslize em qualquer lugar para voltar quando os gestos da esquerda para a direita estiverem desativados';

  @override
  String get fullscreen => 'Ecrã cheio';

  @override
  String get fullscreenSwipeGestures => 'Gestos de deslizar em ecrã cheio';

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
  String get havingIssuesWithNotifications => 'Tem problemas com notificações?';

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
  String get hidePassword => 'Ocultar palavra-passe';

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
  String get importDatabase => 'Importar base de dados';

  @override
  String get importExportDatabase =>
      'Importar/exportar a base de dados do Thunder';

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
  String get includeExternalLink => 'Incluir ligação externa';

  @override
  String get includeImage => 'Incluir imagem';

  @override
  String get includePostLink => 'Incluir ligação da postagem';

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
  String get instanceOffline => 'Instance is offline';

  @override
  String get instanceOnline => 'Instance is online';

  @override
  String get instanceStatusUnknown => 'Instance status unknown';

  @override
  String get instances => 'Instâncias';

  @override
  String get internetOrInstanceIssues =>
      'Pode não estar conectado à Internet ou a sua instância pode estar indisponível no momento.';

  @override
  String get invalidUrl => 'Formato de URL inválido';

  @override
  String joined(Object x) {
    return 'Cadastrou-se em $x';
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
  String get languageFilters => 'A procurar filtros de idioma?';

  @override
  String get languageNotAllowed =>
      'A comunidade em que está a postar não permite postagens no idioma que selecionou. Tente outro idioma.';

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
  String get linkActions => 'Ações de ligações';

  @override
  String get linkHandlingCustomTabs =>
      'Abrir no navegador do sistema incorporado na app';

  @override
  String get linkHandlingCustomTabsShort => 'incorporado na app';

  @override
  String get linkHandlingExternal =>
      'Abrir no navegador do sistema externamente';

  @override
  String get linkHandlingExternalShort => 'Externo';

  @override
  String get linkHandlingInApp => 'Use o navegador integrado do Thunder';

  @override
  String get linkHandlingInAppShort => 'Na app';

  @override
  String get linkPostsUseCompactView =>
      'Mostrar postagens de ligações compactas';

  @override
  String get linksBehaviourSettings => 'Ligações';

  @override
  String loadMorePlural(Object count) {
    return 'Carregar mais $count respostas…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Carregar mais $count resposta…';
  }

  @override
  String get loading => 'A carregar…';

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
      'Precisa estar logado para realizar esta tarefa.';

  @override
  String get loginToSeeInbox => 'Faça login para ver a sua caixa de entrada';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'A procurar configurações de feed específicas para a sua conta?';

  @override
  String get malformedUri =>
      'A ligação que forneceu está num formato não compatível. Certifique-se que seja uma ligação válida.';

  @override
  String get manageAccounts => 'Gerir contas';

  @override
  String get manageMedia => 'Gerir média';

  @override
  String get markAllAsRead => 'Marcar tudo como lido';

  @override
  String get markAsRead => 'Marcar como lido';

  @override
  String get markPostAsReadOnMediaView =>
      'Marcar como lido após visualizar a média';

  @override
  String get markPostAsReadOnScroll => 'Marcar como lido ao rolar';

  @override
  String get markReadColor => 'Cor da marcação lido/não lido';

  @override
  String get matrixUser => 'Utilizador Matrix';

  @override
  String get me => 'Eu';

  @override
  String get media => 'Média';

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
  String get modBan => 'Banir/desbanir utilizadores da instância';

  @override
  String get modBanFromCommunity =>
      'Banir/desbanir utilizadores das comunidades';

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
  String get moderates => 'Moderado';

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
  String get modlog => 'Registo da moderação';

  @override
  String get mostComments => 'Mais comentários';

  @override
  String get mustBeLoggedIn => 'Precisa estar logado';

  @override
  String get mustBeLoggedInComment => 'Precisa estar logado para comentar';

  @override
  String get mustBeLoggedInPost =>
      'Precisa estar logado para criar uma postagem';

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
  String get networkErrorMessage =>
      'Unable to reach the server. Check your connection and try again.';

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
  String get noCommunitySelected => 'Nenhuma comunidade selecionada';

  @override
  String get noCompatibleAppFound => 'Nenhuma app compatível encontrada';

  @override
  String get noDiscussionLanguages =>
      'Nenhum conteúdo é ocultado com base no idioma.';

  @override
  String get noDisplayNameSet => 'Nenhum nome de exibição definido';

  @override
  String get noDrafts => 'Ainda não tem nenhum rascunho';

  @override
  String get noEmailSet => 'Nenhum e-mail definido';

  @override
  String get noFavoritedCommunities => 'Nenhuma comunidade favoritada';

  @override
  String get noImages => 'Parece que não carregou nenhuma imagem.';

  @override
  String get noInstanceBlocks => 'Nenhuma instância bloqueada.';

  @override
  String get noItems => 'Sem elementos';

  @override
  String get noKeywordFilters => 'Nenhum filtro de palavra-chave adicionado';

  @override
  String get noLanguage => 'Nenhum idioma';

  @override
  String get noMatrixUserSet => 'Nenhum utilizador matrix definido';

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
      'Não foram encontradas postagens ou comentários a conterem esta imagem. No entanto, ela pode ser usada noutros locais na internet.';

  @override
  String get noReplies => 'Nenhuma resposta';

  @override
  String get noResultsFound => 'Nenhum resultado encontrado.';

  @override
  String get noSubscriptions => 'Sem inscrições';

  @override
  String get noUserBlocks => 'Nenhum utilizador bloqueado.';

  @override
  String get noUserLabels => 'Ainda não criou nenhum rótulo de utilizador';

  @override
  String get noUsersFound => 'Nenhum utilizador encontrado.';

  @override
  String get noVisibleComments =>
      'Os comentários podem não estar visíveis porque a comunidade está bloqueada.';

  @override
  String get none => 'Nenhum';

  @override
  String get normal => 'Normal';

  @override
  String get notAvailable => 'N/A';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance não parece ser uma instância válida';
  }

  @override
  String get notValidUrl => 'URL inválido';

  @override
  String get nothingToShare => 'Nada a partilhar';

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
      'As notificações são um **recurso experimental** que pode não funcionar corretamente em todos os dispositivos.\n\n- As verificações ocorrerão a cada 15 minutos e consumirão pilha adicional.\n\n- Desative as otimizações da pilha para aumentar a probabilidade de sucesso das notificações.\n\nConsulte a página a seguir para obter mais informações.';

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
  String get old => 'Velho';

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
  String get openLinksInExternalBrowser =>
      'Abrir ligações no navegador externo';

  @override
  String get openLinksInReaderMode => 'Abrir ligações no modo de leitor';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get orange => 'Laranja';

  @override
  String get originalPoster => 'Postador original';

  @override
  String get overview => 'Visão geral';

  @override
  String get password => 'Palavra-passe';

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
      'O Thunder requer algumas permissões para gravar esta imagem, que foram negadas.';

  @override
  String get piefedSupportBeta =>
      'PieFed support is currently in beta.\nNot all features are supported yet.';

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
  String get postBodyShowUserInstance => 'Exibir instância do utilizador';

  @override
  String get postBodyViewType => 'Tipo da visualização do corpo da postagem';

  @override
  String get postContentFontScale => 'Escala da fonte de conteúdo de postagens';

  @override
  String get postCreatedSuccessfully => 'Postagem criada com sucesso!';

  @override
  String get postFlairs => 'Enfeites';

  @override
  String get postFlairsUnavailable =>
      'Nenhuma opção de enfeite disponível nesta comunidade';

  @override
  String get postLocked => 'Postagem trancada. Não são permitidas respostas.';

  @override
  String get postMetadataInstructions =>
      'Pode personalizar as informações de metadados a arrastar e soltar as informações desejadas';

  @override
  String get postNSFW => 'Marcar como NSFW';

  @override
  String get postPreview =>
      'Mostrar uma pré-visualização da postagem com as configurações definidas';

  @override
  String get postSavedAsDraft => 'Postagem gravada como rascunho';

  @override
  String get postShowUserInstance => 'Exibir instância do utilizador';

  @override
  String get postSwipeActions => 'Ações de deslizar na postagem';

  @override
  String get postSwipeGesturesHint =>
      'Prefere usar botões? Altere os botões que aparecem nos cartões de postagem nas configurações gerais.';

  @override
  String get postTags => 'Etiquetas';

  @override
  String get postTagsHelperText => 'Separe as etiquetas com vírgulas';

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
  String get profileOperationInProgress => 'Profile operation in progress';

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
      'Se ativado, o Thunder enviará o(s) seu(s) token(s) JWT ao servidor para verificar se há novas notificações. \n\n **OBSERVAÇÃO:** Isto só entrará em vigor na próxima vez que a app for iniciada.';

  @override
  String get pushNotificationServer => 'Servidor de notificações push';

  @override
  String get pushNotificationServerDescription =>
      'Configure o servidor de notificações push. O servidor deve estar devidamente configurado para enviar notificações push para o seu dispositivo.\n\n **Insira apenas um servidor em que confia com as suas credenciais.**';

  @override
  String get rateLimitErrorMessage =>
      'Atingiu o limite de taxa para esta solicitação. Aguarde e tente novamente mais tarde.';

  @override
  String get reachedTheBottom => 'Não há mais elementos a carregar';

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
  String get removeUserData => 'Remover dados do utilizador';

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
  String get replyToComment => 'Responder ao comentário';

  @override
  String get replyToPost => 'Responder à postagem';

  @override
  String replyingTo(Object author) {
    return 'A responder a $author';
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
  String get save => 'Gravar';

  @override
  String get saveColor => 'Gravar cor';

  @override
  String get saveSettings => 'Gravar configurações';

  @override
  String get saved => 'Gravado';

  @override
  String get scaled => 'Escalonado';

  @override
  String get scrapeMissingLinkPreviews =>
      'Obter pré-visualizações de ligações ausentes';

  @override
  String get screenReaderProfile => 'Perfil do leitor de ecrã';

  @override
  String get screenReaderProfileDescription =>
      'Otimiza o Thunder para leitores de ecrã, a reduzir os elementos gerais e remover gestos potencialmente conflitantes.';

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
    return 'Pesquisar utilizadores federados com $instance';
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
  String get selectRecipient => 'Selecionar destinatário';

  @override
  String get selectSearchType => 'Selecionar tipo de pesquisa';

  @override
  String get selectText => 'Selecionar texto';

  @override
  String get send => 'Enviar';

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
    return 'As configurações foram gravadas com sucesso em \'$savedFilePath\'';
  }

  @override
  String get settingsFeedCards =>
      'Estas configurações aplicam-se aos cartões no feed principal, as ações estão sempre disponíveis ao abrir as postagens.';

  @override
  String get settingsImportedSuccessfully =>
      'As configurações foram importadas com sucesso!';

  @override
  String get settingsNotExportedSuccessfully =>
      'As configurações não foram gravadas com sucesso ou a operação foi cancelada.';

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
  String get settingsPageAccountMedia => 'Gerir média';

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
  String get settingsPageUserLabels => 'Rótulos de utilizador';

  @override
  String get settingsPageVideo => 'Vídeo';

  @override
  String get share => 'Partilhar';

  @override
  String get shareComment => 'Partilhar ligação do comentário';

  @override
  String get shareCommentLocal =>
      'Partilhar ligação do comentário (a minha instância)';

  @override
  String get shareCommunity => 'Partilhar comunidade';

  @override
  String get shareCommunityLink => 'Partilhar ligação da comunidade';

  @override
  String get shareCommunityLinkLocal =>
      'Partilhar ligação da comunidade (a minha instância)';

  @override
  String get shareImage => 'Partilhar imagem';

  @override
  String get shareLemmyLink => 'Partilhar ligação do Lemmy';

  @override
  String get shareLink => 'Partilhar ligação externa';

  @override
  String get shareMedia => 'Partilhar média';

  @override
  String get shareMediaLink => 'Partilhar ligação da média';

  @override
  String get shareOriginalLink => 'Partilhar ligação original';

  @override
  String get sharePost => 'Partilhar ligação da postagem';

  @override
  String get sharePostLocal =>
      'Partilhar ligação da postagem (a minha instância)';

  @override
  String get shareThumbnail => 'Partilhar miniatura';

  @override
  String get shareThumbnailAsImage => 'Partilhar miniatura como imagem';

  @override
  String get shareUser => 'Partilhar utilizador';

  @override
  String get shareUserLink => 'Partilhar ligação do utilizador';

  @override
  String get shareUserLinkLocal =>
      'Partilhar ligação do utilizador (a minha instância)';

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
  String get showPassword => 'Mostrar palavra-passe';

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
  String get showPostSaveAction => 'Mostrar botão gravar';

  @override
  String get showPostTextContentPreview => 'Mostrar pré-visualização de texto';

  @override
  String get showPostTitleFirst => 'Mostrar título primeiro';

  @override
  String get showPostVoteActions => 'Mostrar botões para votar';

  @override
  String get showReadPosts => 'Mostrar postagens lidas';

  @override
  String get showSavedContent => 'Mostrar conteúdo gravado';

  @override
  String get showScoreCounters => 'Exibir pontuações dos utilizadores';

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
      'Mostrar registos de alterações para atualizações';

  @override
  String get showUpdateChangelogsSubtitle =>
      'Exibir uma lista de alterações após uma atualização';

  @override
  String get showUserAvatar => 'Mostrar avatar de utilizador';

  @override
  String get showUserDisplayNames =>
      'Mostrar nomes de exibição dos utilizadores';

  @override
  String get showUserInstance => 'Mostrar instância de utilizador';

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
  String get status => 'Estado';

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
      'O Thunder será fechado e tentará gerar uma notificação em segundo plano. (Levará pelo menos 15 minutos.)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'O Thunder solicitará ao servidor de notificações que envie uma notificação atrasada e depois fechará-se. (Pode levar alguns minutos.)';

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
      'Houve um tempo limite a aguardar uma resposta.';

  @override
  String get timeoutSaveComment =>
      'Erro: Tempo limite ao tentar gravar um comentário';

  @override
  String get timeoutSavingPost =>
      'Erro: Tempo limite ao tentar gravar a postagem.';

  @override
  String get timeoutUpvoteComment =>
      'Erro: Tempo limite ao tentar votar num comentário';

  @override
  String get timeoutVotingPost =>
      'Erro: Tempo limite ao tentar votar na postagem.';

  @override
  String get toggelRead => 'Alternar estado de leitura';

  @override
  String get top => 'Melhores';

  @override
  String get topAll => 'Melhores de todos os tempos';

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
      'Não é possível encontrar a comunidade selecionada na instância do utilizador selecionado.';

  @override
  String get unableToFindInstance => 'Não é possível encontrar a instância';

  @override
  String get unableToFindLanguage => 'Não é possível encontrar o idioma';

  @override
  String get unableToFindPost => 'Não é possível encontrar a postagem';

  @override
  String get unableToFindUser => 'Não é possível encontrar o utilizador';

  @override
  String unableToFindUserName(Object username) {
    return 'Não é possível encontrar o utilizador \'$username\'';
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
    return 'Não é possível recuperar o registo de alterações da versão $version.';
  }

  @override
  String get unbanFromCommunity => 'Desbanir da comunidade';

  @override
  String get unbannedUser => 'Utilizador desbanido';

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
  String get unblockUser => 'Desbloquear utilizador';

  @override
  String get unblockUserInstance => 'Desbloquear instância do utilizador';

  @override
  String get understandEnable => 'Percebo, ative';

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
    return 'App distribuidora UnifiedPush: $app ($count disponíveis)';
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
  String get untitledCommentDraft => 'Rascunho de comentário sem título';

  @override
  String get untitledPostDraft => 'Rascunho de postagem sem título';

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
  String get uriNotSupported =>
      'Este tipo de ligação não é suportado no momento.';

  @override
  String get url => 'URL';

  @override
  String get useAdvancedShareSheet => 'Usar o painel de partilhamento avançado';

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
      'Quando logado, mostra a foto do perfil do utilizador no lugar do ícone da gaveta';

  @override
  String useSuggestedTitle(Object title) {
    return 'Usar título sugerido: $title';
  }

  @override
  String get useUnifiedPushNotifications => 'Usar notificações UnifiedPush';

  @override
  String get useUnifiedPushNotificationsDescription =>
      'Requer uma app compatível';

  @override
  String get user => 'Utilizador';

  @override
  String get userActions => 'Ações de utilizador';

  @override
  String userEntry(Object username) {
    return 'Utilizador \'$username\'';
  }

  @override
  String get userFormat => 'Formato do utilizador';

  @override
  String get userLabelHint => 'Este é o meu utilizador favorito';

  @override
  String get userLabels => 'Rótulos de utilizador';

  @override
  String get userLabelsSettingsPageDescription =>
      'Pode adicionar, modificar ou remover rótulos associados aos utilizadores.';

  @override
  String get userNameColor => 'Cor do nome de utilizador';

  @override
  String get userNameThickness => 'Espessura do nome de utilizador';

  @override
  String get userNotLoggedIn => 'Utilizador não logado';

  @override
  String get userProfiles => 'Perfis de utilizador';

  @override
  String get userSettingDescription =>
      'Estas configurações são sincronizadas com a sua conta Lemmy e são aplicadas apenas por conta.';

  @override
  String get userStyle => 'Estilo de utilizador';

  @override
  String get username => 'Nome de utilizador';

  @override
  String get usernameFormattingRedirect =>
      'A procurar por formatação de nome de utilizador?';

  @override
  String get users => 'Utilizadores';

  @override
  String versionNumber(Object version) {
    return 'Versão $version';
  }

  @override
  String get video => 'Vídeo';

  @override
  String get videoAutoFullscreen => 'Ecrã cheia automático';

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
      'Reproduzir vídeo com uma app externa';

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
  String get viewModlog => 'Ver registo de moderação';

  @override
  String get viewOriginal => 'Ver original';

  @override
  String get viewPostAsDifferentAccount => 'Ver postagem como conta diferente';

  @override
  String get viewPostSource => 'Ver fonte da postagem';

  @override
  String get viewSource => 'Ver fonte';

  @override
  String get viewingAll => 'A exibir todos';

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
  String get visitUserInstance => 'Visitar instância do utilizador';

  @override
  String get visitUserProfile => 'Visitar perfil do utilizador';

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
  String get youMustSelectAJsonFile => 'Deve selecionar um ficheiro .json.';
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
  String get deleteDraftConfirmation =>
      'Tem certeza de que deseja excluir este rascunho?';

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
  String get directMessage => 'Mensagem direta';

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
  String get drafts => 'Rascunhos';

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
  String get failedToCreateDefaultProfile => 'Falha ao criar o perfil padrão';

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
  String get instanceOffline => 'A instância está off-line';

  @override
  String get instanceOnline => 'A instância está on-line';

  @override
  String get instanceStatusUnknown => 'Status da instância desconhecido';

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
  String get noCommunitySelected => 'Nenhuma comunidade selecionada';

  @override
  String get noCompatibleAppFound => 'Nenhum aplicativo compatível encontrado';

  @override
  String get noDiscussionLanguages =>
      'Nenhum conteúdo é ocultado com base no idioma.';

  @override
  String get noDisplayNameSet => 'Nenhum nome de exibição definido';

  @override
  String get noDrafts => 'Você ainda não tem nenhum rascunho';

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
  String get notAvailable => 'N/A';

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
  String get piefedSupportBeta =>
      'O suporte ao PieFed está atualmente em fase beta.\nAinda nem todos os recursos são suportados.';

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
  String get postFlairs => 'Enfeites';

  @override
  String get postFlairsUnavailable =>
      'Nenhuma opção de enfeite disponível nesta comunidade';

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
  String get postTags => 'Etiquetas';

  @override
  String get postTagsHelperText => 'Separe as etiquetas com vírgulas';

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
  String get profileOperationInProgress => 'Operação de perfil em andamento';

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
  String get replyToComment => 'Responder ao comentário';

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
  String get selectRecipient => 'Selecionar destinatário';

  @override
  String get selectSearchType => 'Selecionar tipo de pesquisa';

  @override
  String get selectText => 'Selecionar texto';

  @override
  String get send => 'Enviar';

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
  String get untitledCommentDraft => 'Rascunho de comentário sem título';

  @override
  String get untitledPostDraft => 'Rascunho de postagem sem título';

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
