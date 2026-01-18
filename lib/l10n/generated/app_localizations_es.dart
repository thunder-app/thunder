// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get about => 'Acerca de';

  @override
  String get accept => 'Aceptar';

  @override
  String get accessibility => 'Accesibilidad';

  @override
  String get accessibilityProfilesDescription =>
      'Los perfiles de accesibilidad permiten aplicar varios ajustes a la vez para adaptarse a un requisito de accesibilidad concreto.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cuentas',
      one: 'Cuenta',
      zero: 'Cuentas',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'Cuenta creada el $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'Su configuración de cuenta sobreescribe las siguientes configuraciones';

  @override
  String get accountSettings => 'Ajustes de la cuenta';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'Lemmy account settings exported successfully to $savedFilePath!';
  }

  @override
  String get accountSettingsImportedSuccessfully =>
      'Lemmy account settings imported successfully!';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return 'El comentario seleccionado no se encontró en \'$instance\'. Volver a la cuenta anterior.';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'La publicación seleccionada no se encontró en \'$instance\'. Volver a la cuenta anterior.';
  }

  @override
  String get actionColors => 'Colores de acción';

  @override
  String get actionColorsRedirect => '¿Buscas personalizar los colores?';

  @override
  String get actions => 'Acciones';

  @override
  String get active => 'Activo';

  @override
  String get activity => 'Activity';

  @override
  String get add => 'Agregar';

  @override
  String get addAccount => 'Agregar cuenta';

  @override
  String get addAccountToSeeProfile => 'Inicia sesión para ver tu cuenta.';

  @override
  String get addAnonymousInstance => 'Añadir una instancia anónima';

  @override
  String get addAsCommunityModerator => 'Añadir como moderador de la comunidad';

  @override
  String get addDiscussionLanguage => 'Añadir idioma';

  @override
  String get addKeywordFilter => 'Añadir palabra clave';

  @override
  String get addOriginalPostBody => 'Add original post body?';

  @override
  String get addToFavorites => 'Añadir a favoritos';

  @override
  String get addUserLabel => 'Agregar Etiqueta de Usuario';

  @override
  String get addedCommunityToSubscriptions => 'Suscrito a la comunidad';

  @override
  String get addedInstanceMod => 'Añadido Instancia Mod';

  @override
  String get addedModToCommunity => 'Mod añadido a la Comunidad';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return 'Added $username as community moderator';
  }

  @override
  String get admin => 'Admón.';

  @override
  String get advanced => 'Avanzado';

  @override
  String ago(Object time) {
    return 'Hace $time';
  }

  @override
  String get all => 'Todo';

  @override
  String get allPosts => 'Todos los mensajes';

  @override
  String get allowOpenSupportedLinks =>
      'Permitir que la aplicación abra los enlaces compatibles.';

  @override
  String get alreadyPostedTo => 'Ya se ha publicado en';

  @override
  String get altText => 'Alt Text';

  @override
  String get alternateSources => 'Fuentes alternativas';

  @override
  String get always => 'Siempre';

  @override
  String andXMore(Object count) {
    return 'y $count más';
  }

  @override
  String get animations => 'Animaciones';

  @override
  String get anonymous => 'Anónimo';

  @override
  String get anonymousInstances => 'Instancias anónimas';

  @override
  String get appLanguage => 'Idioma de la aplicación';

  @override
  String get appearance => 'Apariencia';

  @override
  String get applePushNotificationService =>
      'Servicio de notificaciones push de Apple';

  @override
  String get applied => 'Aplicada';

  @override
  String get apply => 'Aplicar';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return 'Las notificaciones están permitidas por el sistema: $yesOrNo';
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
  String get back => 'Atrás';

  @override
  String get backButton => 'Botón de retroceso';

  @override
  String get backToTop => 'Volver arriba';

  @override
  String get backgroundCheckWarning =>
      'Tenga en cuenta que las comprobaciones de notificaciones consumirán más batería';

  @override
  String get ban => 'Ban';

  @override
  String get banFromCommunity => 'Bloquear de la comunidad';

  @override
  String get bannedUser => 'Usuario baneado';

  @override
  String get bannedUserFromCommunity => 'Usuario expulsado de la Comunidad';

  @override
  String get base => 'Base';

  @override
  String get block => 'Block';

  @override
  String get blockCommunity => 'Bloquear comunidad';

  @override
  String get blockCommunityInstance => 'Bloquear la instancia de una comunidad';

  @override
  String get blockInstance => 'Bloquear la instancia';

  @override
  String get blockManagement => 'Bloquear Gestión';

  @override
  String get blockSettingLabel => 'Bloqueo Usuario/Comunidad/Instancia';

  @override
  String get blockUser => 'Bloquear usuario';

  @override
  String get blockUserInstance => 'Bloquear la instancia de un usuario';

  @override
  String get blockedCommunities => 'Comunidades bloqueadas';

  @override
  String get blockedInstances => 'Instancias bloqueadas';

  @override
  String get blockedUsers => 'Usuarios bloqueados';

  @override
  String get blue => 'Azul';

  @override
  String get bold => 'Negrita';

  @override
  String get boldCommunityName => 'Nombre de la comunidad en negrita';

  @override
  String get boldInstanceName => 'Nombre de la instancia en negrita';

  @override
  String get boldUserName => 'Nombre del usuario en negrita';

  @override
  String get bot => 'Bot';

  @override
  String get browserMode => 'Gestión de enlaces';

  @override
  String browsingAnonymously(Object instance) {
    return 'Está navegando por $instance de forma anónima.';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get cannotReportOwnComment =>
      'No puede presentar un informe para su propio comentario.';

  @override
  String get cantBlockAdmin =>
      'No se puede bloquear un administrador de instancia.';

  @override
  String get cantBlockYourself => 'No puedes bloquearte.';

  @override
  String get cardPostCardMetadataItems => 'Metadatos de la vista de tarjetas';

  @override
  String get cardView => 'Vista de tarjeta';

  @override
  String get cardViewDescription =>
      'Habilitar la vista de tarjeta para ajustar la configuración';

  @override
  String get cardViewSettings => 'Configuración de la vista de tarjeta';

  @override
  String get changeAccountSettingsFor =>
      'Cambiar la configuración de la cuenta para';

  @override
  String get changeNotificationSettings =>
      'Cambiar los ajustes de notificación...';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get changePasswordWarning =>
      'Para cambiar tu contraseña, será redirigido al sitio de tu instancia. \n\n¿Está seguro de que deseas continuar?';

  @override
  String get changeSort => 'Cambiar orden';

  @override
  String clearCache(Object cacheSize) {
    return 'Borrar la caché ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Limpiar la cache';

  @override
  String get clearDatabase => 'Borrar la base de datos';

  @override
  String get clearPreferences => 'Borrar los ajustes';

  @override
  String get clearSearch => 'Borrar la búsqueda';

  @override
  String get clearedCache => 'Borrado de la caché con éxito.';

  @override
  String get clearedDatabase =>
      'Base de datos local borrada. Reinicie Thunder para que los nuevos cambios surtan efecto.';

  @override
  String get clearedUserPreferences => 'Preferencias del usuario borradas';

  @override
  String get close => 'Cerrar';

  @override
  String get collapse => 'Contraer';

  @override
  String get collapseCommentPreview =>
      'Contraer la vista previa de los comentarios';

  @override
  String get collapseInformation => 'Contraer información';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Ocultar comentario principal cuando está contraído';

  @override
  String get collapsePost => 'Contraer el hilo';

  @override
  String get collapsePostPreview =>
      'Contraer la vista previa de la publicación';

  @override
  String get collapseSpoiler => 'Contraer el spoiler';

  @override
  String get color => 'Color';

  @override
  String get colorizeCommunityName => 'Colorear el nombre de la comunidad';

  @override
  String get colorizeInstanceName => 'Colorear el nombre de la instancia';

  @override
  String get colorizeUserName => 'Colorear el nombre del usuario';

  @override
  String get colors => 'Colores';

  @override
  String get combineCommentScores => 'Combinar notas de comentarios';

  @override
  String get combineCommentScoresLabel =>
      'Combinar las puntuaciones de los comentarios';

  @override
  String get combineNavAndFab => 'Combinar botones FAB y de navegación';

  @override
  String get combineNavAndFabDescription =>
      'El botón de acción flotante se mostrará entre los botones de navegación.';

  @override
  String get comfortable => 'Cómodo';

  @override
  String get comment => 'Comentario';

  @override
  String get commentActions => 'Comment Actions';

  @override
  String get commentBehaviourSettings => 'Comentarios';

  @override
  String get commentFontScale => 'Tamaño de la fuente del comentario';

  @override
  String get commentPreview =>
      'Mostrar una vista previa de los comentarios con la configuración';

  @override
  String get commentReported =>
      'El comentario ha sido marcado para su revisión.';

  @override
  String get commentSavedAsDraft => 'Comentario guardado como borrador';

  @override
  String get commentShowUserAvatar => 'Mostrar el avatar del usuario';

  @override
  String get commentShowUserInstance => 'Mostrar instancia de usuario';

  @override
  String get commentSortType => 'Tipo de clasificación de los comentarios';

  @override
  String get commentSwipeActions => 'Acciones de deslizar los comentarios';

  @override
  String get commentSwipeGesturesHint =>
      '¿Quieres utilizar los botones? Habilítalos en la sección de comentarios de los ajustes generales.';

  @override
  String get comments => 'Comentarios';

  @override
  String get communities => 'Comunidades';

  @override
  String get community => 'Comunidad';

  @override
  String get communityActions => 'Acciones comunitarias';

  @override
  String communityEntry(Object community) {
    return 'Comunidad \'$community\'';
  }

  @override
  String get communityFormat => 'Formato de la comunidad';

  @override
  String get communityNameColor => 'Color del nombre de la comunidad';

  @override
  String get communityNameThickness => 'Espesor del nombre de la comunidad';

  @override
  String get communityStyle => 'Estilo de la comunidad';

  @override
  String get compact => 'Compacto';

  @override
  String get compactPostCardMetadataItems => 'Metadatos de la vista compacta';

  @override
  String get compactView => 'Vista compacta';

  @override
  String get compactViewDescription =>
      'Habilitar la vista compacta para ajustar la configuración';

  @override
  String get compactViewSettings => 'Configuración de la vista compacta';

  @override
  String get condensed => 'Condensado';

  @override
  String get confirm => 'Confirmar';

  @override
  String get confirmLogOutBody => '¿Seguro que quieres cerrar la sesión?';

  @override
  String get confirmLogOutTitle => '¿Cerrar sesión?';

  @override
  String get confirmMarkAllAsReadBody =>
      '¿Estás seguro de que quieres marcar todos los mensajes como leídos?';

  @override
  String get confirmMarkAllAsReadTitle => '¿Marcar todo como leído?';

  @override
  String get confirmResetCommentPreferences =>
      'Esto restablecerá todas las preferencias de los comentarios. ¿Seguro que quieres proceder?';

  @override
  String get confirmResetPostPreferences =>
      'Esto restablecerá todas las preferencias de la publicación. ¿Seguro que quieres proceder?';

  @override
  String get confirmUnsubscription =>
      '¿Estás seguro de que quieres darte de baja?';

  @override
  String connectedToUnifiedPushDistributorApp(Object app) {
    return 'Conectado a la $app';
  }

  @override
  String get contentManagement => 'Gestión de Contenido';

  @override
  String get contentWarning => 'Aviso de contenido';

  @override
  String get controversial => 'Polémico';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get copy => 'Copiar';

  @override
  String get copyComment => 'Copiar comentario';

  @override
  String get copySelected => 'Copiar selección';

  @override
  String get copyText => 'Copiar el texto';

  @override
  String get couldNotDetermineCommentDelete =>
      'Error: No se pudo determinar el puesto para eliminar el comentario.';

  @override
  String get couldNotDeterminePostComment =>
      'Error: No se pudo determinar el post para comentar.';

  @override
  String get couldntCreateReport =>
      'Su comentario no ha podido ser enviado en este momento. Vuelva a intentarlo más tarde';

  @override
  String get couldntFindPost =>
      'No se puede cargar la publicación solicitada. Es posible que haya sido eliminado o eliminado.';

  @override
  String countComments(Object count) {
    return '$count Comentarios';
  }

  @override
  String countLocalSubscribers(Object count) {
    return '$count Subscriptores Locales';
  }

  @override
  String countPosts(Object count) {
    return '$count Publicaciones';
  }

  @override
  String countSubscribers(Object count) {
    return '$count Subscriptores';
  }

  @override
  String countUsers(Object count) {
    return '$count usuarios';
  }

  @override
  String countUsersActiveDay(Object count) {
    return '$count usuarios/dia';
  }

  @override
  String countUsersActiveHalfYear(Object count) {
    return '$count usuarios/6 meses';
  }

  @override
  String countUsersActiveMonth(Object count) {
    return '$count usuarios/mes';
  }

  @override
  String countUsersActiveWeek(Object count) {
    return '$count usuarios/semana';
  }

  @override
  String get createAccount => 'Crear una cuenta';

  @override
  String get createComment => 'Crear comentario';

  @override
  String get createNewCrossPost => 'Crear un nuevo mensaje cruzado';

  @override
  String get createPost => 'Crear publicación';

  @override
  String created(Object date) {
    return 'Creado $date';
  }

  @override
  String get createdToday => 'Creada hoy';

  @override
  String get creator => 'Creador';

  @override
  String crossPostedFrom(Object postUrl) {
    return 'publicación cruzada desde:  $postUrl';
  }

  @override
  String get crossPostedTo => 'Trasladado a';

  @override
  String get currentLongPress => 'Actualmente configurado como pulsación larga';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Modo actual de notificaciones: $mode';
  }

  @override
  String get currentSinglePress =>
      'Actualmente configurado como pulsación corta';

  @override
  String get customizeSwipeActions =>
      'Personalizar acciones al deslizar (tocar para cambiar)';

  @override
  String get dangerZone => 'Zona peligrosa';

  @override
  String get dark => 'Oscuro';

  @override
  String get databaseExportWarning =>
      'La base de datos puede contener información sensible relacionada con su cuenta de Lemmy. Si es exportada, no debería compartirla con nadie. ¿Desea continuar?';

  @override
  String databaseExportedSuccessfully(Object savedFilePath) {
    return 'La base de datos fue exportada exitosamente a \'$savedFilePath\'';
  }

  @override
  String get databaseImportedSuccessfully =>
      '¡La base de datos fue importada exitosamente!';

  @override
  String get databaseNotExportedSuccessfully =>
      'La base de datos no fue exportada exitosamente o la operación fue cancelada.';

  @override
  String get databaseNotImportedSuccessfully =>
      'La base de datos no fue importada exitosamente o la operación fue cancelada.';

  @override
  String get dateFormat => 'Formato de la fecha';

  @override
  String get debug => 'Depurar';

  @override
  String get debugDescription =>
      'Las siguientes configuraciones de depuración solo deben usarse para solucionar problemas.';

  @override
  String get debugNotificationsDescription =>
      'Utilice las siguientes opciones para solucionar problemas relacionados con las notificaciones.';

  @override
  String get decline => 'Rechazar';

  @override
  String get defaultColor => 'Por defecto';

  @override
  String get defaultCommentSortType =>
      'Tipo de clasificación de comentarios predeterminado';

  @override
  String get defaultFeedSortType =>
      'Tipo de clasificación del feed predeterminado';

  @override
  String get defaultFeedType => 'Tipo de feed predeterminado';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountDescription =>
      'Para eliminar definitivamente su cuenta, será redirigido al sitio de su instancia. \n\n¿Está seguro de que desea continuar?';

  @override
  String get deleteComment => 'Delete Comment';

  @override
  String get deleteImageConfirmMessage =>
      'Are you sure you want to delete this image?';

  @override
  String get deleteImageConfirmTitle => 'Delete?';

  @override
  String get deleteLocalDatabase => 'Borrar la base de datos local';

  @override
  String get deleteLocalDatabaseDescription =>
      'Esta acción eliminará la base de datos local y te desconectará de todas tus cuentas.\n\n¿Está seguro de que desea continuar?';

  @override
  String get deleteLocalPreferences => 'Borrar las preferencias locales';

  @override
  String get deleteLocalPreferencesDescription =>
      'Esto borrará todas sus preferencias y configuraciones en Thunder.\n\n¿Quieres continuar?';

  @override
  String get deletePost => 'Eliminar mensaje';

  @override
  String get deleteUserLabelConfirmation =>
      '¿Seguro que quieres borrar la etiqueta?';

  @override
  String get deleted => 'Deleted';

  @override
  String get deletedByCreator => 'borrado por el creador';

  @override
  String get deletedByModerator => 'borrado por el moderador';

  @override
  String get deletedComment => 'Deleted comment';

  @override
  String get deletedPost => 'Deleted post';

  @override
  String get deselectUndeterminedWarning =>
      'Si anula la selección Indeterminada, no verá la mayoría de los contenidos.';

  @override
  String detailedReason(Object reason) {
    return 'Razón: $reason';
  }

  @override
  String get dimReadPosts => 'Publicaciones de lectura oscura';

  @override
  String get disable => 'Desactivar';

  @override
  String get disablePushNotifications => 'Desactivar las notificaciones push';

  @override
  String get disabled => 'Desactivar';

  @override
  String get discussionLanguages => 'Idiomas de debate';

  @override
  String get discussionLanguagesTooltip =>
      'El contenido se filtra a los idiomas seleccionados.';

  @override
  String get dismissRead => 'Descartar leídos';

  @override
  String get displayName => 'Nombre para mostrar';

  @override
  String get displayUserScore =>
      'Mostrar las puntuaciones del usuario (Karma).';

  @override
  String get dividerAppearance => 'Aspecto del divisor';

  @override
  String get doNotShowAgain => 'No volver a mostrar';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Se han encontrado varias aplicaciones compatibles; instale solo una';

  @override
  String get downloadingMedia => 'Descargando los medios para compartir…';

  @override
  String get downvote => 'Voto negativo';

  @override
  String get downvoteColor => 'Color de voto negativo';

  @override
  String get downvoted => 'Votado en contra';

  @override
  String get downvotesDisabled =>
      'Los votos negativos están desactivados en esta instancia.';

  @override
  String get edit => 'Editar';

  @override
  String get editComment => 'Editar comentario';

  @override
  String get editPost => 'Editar el mensaje';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get empty => 'Vacío';

  @override
  String get emptyInbox => 'Buzón vacío';

  @override
  String get emptyUri =>
      'El enlace está vacío. Por favor, proporcione un enlace dinámico válido para continuar.';

  @override
  String get enableCommentNavigation => 'Activar la navegación por comentarios';

  @override
  String get enableExperimentalFeatures => 'Activar funciones experimentales';

  @override
  String get enableFeedFab => 'Activar el botón flotante en los feeds';

  @override
  String get enableFloatingButtonOnFeeds =>
      'Activar el botón flotante en los feeds';

  @override
  String get enableFloatingButtonOnPosts =>
      'Habilitar el botón flotante en los mensajes';

  @override
  String get enableInboxNotifications =>
      'Activar las notificaciones de la bandeja de entrada';

  @override
  String get enablePostFab => 'Habilitar botón flotante en los mensajes';

  @override
  String get endOfComments => 'Fin de las observaciones';

  @override
  String get endSearch => 'Finalizar la búsqueda';

  @override
  String errorDeletingImage(Object error) {
    return 'There was an error deleting the image: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'No se ha podido descargar el archivo multimedia para compartir: $errorMessage';
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
      'Se produjo un error al marcar la respuesta como leída.';

  @override
  String get errorMarkingReplyUnread =>
      'Se produjo un error al marcar la respuesta como no leída.';

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
      'Se ha producido un error al procesar el enlace. Puede que no esté disponible en su instancia.';

  @override
  String get excessiveApiCallsWarning =>
      'Es posible que tu feed tarde en cargarse debido a los filtros de palabras clave.';

  @override
  String get expand => 'Expandir';

  @override
  String get expandCommentPreview =>
      'Expandir la vista previa de los comentarios';

  @override
  String get expandInformation => 'Ampliar la información';

  @override
  String get expandOptions => 'Ampliar opciones';

  @override
  String get expandPost => 'Ampliar el tema';

  @override
  String get expandPostPreview => 'Expandir la vista previa del tema';

  @override
  String get expandSpoiler => 'Ampliar spoiler';

  @override
  String get expanded => 'Ampliado';

  @override
  String get experimentalFeatures => 'Funciones experimentales';

  @override
  String get experimentalFeaturesDescription =>
      'Estas funciones aún están en desarrollo y pueden ser inestables. Usélos bajo su propio riesgo. Debes reiniciar Thunder para que surta efecto.';

  @override
  String get exploreInstance => 'Explorar instancia';

  @override
  String get exportDatabase => 'Exportar Base de Datos';

  @override
  String get exportDatabaseSubtitle =>
      'La base de datos contiene información acerca de cuentas, favoritos, subscripciones anónimas y etiquetas de usuario.';

  @override
  String get exportLemmyAccountSettingsDescription =>
      'Export Lemmy account settings';

  @override
  String get exportSettingsSubtitle =>
      'Las configuraciones incluyen todas las preferencias que ha configurado en Thunder.';

  @override
  String get extraLarge => 'Extra grande';

  @override
  String failedToBlock(Object errorMessage) {
    return 'Fallo al bloquear: $errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return 'Error al comunicarse con el servidor de notificación de Thunder en \'$serverAddress\'';
  }

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return 'No se han podido cargar los bloques: $errorMessage';
  }

  @override
  String get failedToLoadVideo =>
      'No se pudo cargar el video. ¿Abrir enlace en el navegador?';

  @override
  String get failedToPerformAction => 'No se pudo realizar la acción';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'No se ha podido desbloquear: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Error al actualizar los ajustes de las notificaciones';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Favoritos';

  @override
  String get featuredPost => 'Publicación destacada';

  @override
  String get feed => 'Feed';

  @override
  String get feedBehaviourSettings => 'Feed';

  @override
  String get feedSettings => 'Configuración del feed';

  @override
  String get feedTypeAndSorts =>
      'Tipo de Feed predeterminado y de clasificación';

  @override
  String get fetchAccountError => 'No se pudo determinar la cuenta';

  @override
  String filteringBy(Object entity) {
    return 'Filtrar por $entity';
  }

  @override
  String get filters => 'Filtros';

  @override
  String get floatingActionButton => 'Botón de acción flotante';

  @override
  String get floatingActionButtonInformation =>
      'Thunder tiene una experiencia FAB totalmente personalizable que admite algunos gestos.\n- Desliza el dedo hacia arriba para ver acciones FAB adicionales\n- Desliza hacia abajo/arriba para ocultar o mostrar el FAB\n\nPara personalizar las acciones principales y secundarias del FAB, mantén pulsada una de las acciones que aparecen a continuación.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'indica la acción de la pulsación larga del FAB.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'denota la acción de pulsación única del FAB.';

  @override
  String get fonts => 'Fuentes';

  @override
  String get forward => 'Adelante';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Encontrada aplicación compatible; reiniciar Thunder para conectar';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Desliza el dedo en cualquier lugar para volver atrás cuando los gestos de izquierda a derecha estén desactivados';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get fullscreenSwipeGestures =>
      'Gestos de deslizamiento a pantalla completa';

  @override
  String get general => 'General';

  @override
  String get generalSettings => 'Ajustes generales';

  @override
  String get gestures => 'Gestos';

  @override
  String get gettingStarted => 'Primeros pasos';

  @override
  String get green => 'Verde';

  @override
  String get guestModeFeedSettings => 'Configuración de Feed Modo Invitado';

  @override
  String get guestModeFeedSettingsLabel =>
      'Las siguientes configuraciones aplican solo para cuentas de invitado. Para ajustar las configuraciones del feed de su cuenta, vaya a Configuración de Cuenta.';

  @override
  String get havingIssuesWithNotifications =>
      '¿Tienes problemas con las notificaciones?';

  @override
  String get hidCommunity => 'Comunidad oculta';

  @override
  String get hidden => 'Oculto';

  @override
  String get hide => 'Ocultar';

  @override
  String get hideBottomBarOnScroll => 'Hide Bottom Bar on Scroll';

  @override
  String get hideColor => 'Ocultar el color';

  @override
  String get hideNsfwPostsFromFeed => 'Ocultar publicaciones NSFW del Feed';

  @override
  String get hideNsfwPreviews => 'Desenfocar vistas previas NSFW';

  @override
  String get hidePassword => 'Ocultar la contraseña';

  @override
  String get hideThumbnails => 'Ocultar miniaturas';

  @override
  String get hideTopBarOnScroll => 'Ocultar la barra superior al desplazarse';

  @override
  String get hostInstance => 'Instancia de Host';

  @override
  String get hot => 'Caliente';

  @override
  String get image => 'Imagen';

  @override
  String get imageCachingMode => 'Modo de almacenamiento en caché de imágenes';

  @override
  String get imageCachingModeAggressive =>
      'Almacenamiento agresivo de imágenes en caché (utiliza más memoria)';

  @override
  String get imageCachingModeAggressiveShort => 'Agresivos';

  @override
  String get imageCachingModeRelaxed =>
      'Permitir que los cachés de imagen expiren (utiliza menos memoria pero hace que las imágenes se recarguen más a menudo)';

  @override
  String get imageCachingModeRelaxedShort => 'Relajado';

  @override
  String get imageDimensionTimeout => 'Tiempo de Espera de Dimensión de Imagen';

  @override
  String get imagePeekDuration => 'Image Peek Duration';

  @override
  String get imagePeekDurationDescription =>
      'Duration of long press before image peek is triggered';

  @override
  String get importDatabase => 'Importar Base de Datos';

  @override
  String get importExportDatabase => 'Importar/Exportar Base de Datos';

  @override
  String get importExportLemmyAccountSettings =>
      'Import/Export Lemmy Account Settings';

  @override
  String get importExportLemmyAccountSettingsSubtitle =>
      'Includes subscribed communities, blocklists, and account preferences';

  @override
  String get importExportSettings => 'Ajustes para la importación/exportación';

  @override
  String get importExportThunderSettings => 'Import/Export Thunder Settings';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Import Lemmy account settings';

  @override
  String get importSettings => 'Importar la configuración';

  @override
  String inReplyTo(Object post, Object community) {
    return 'En respuesta a $post en $community';
  }

  @override
  String get in_ => 'en';

  @override
  String get inbox => 'Buzón';

  @override
  String get includeCommunity => 'Incluir a la comunidad';

  @override
  String get includeExternalLink => 'Incluir enlace externo';

  @override
  String get includeImage => 'Incluir la imagen';

  @override
  String get includePostLink => 'Incluir enlace a la entrada';

  @override
  String get includeText => 'Incluir el texto';

  @override
  String get includeTitle => 'Incluir el título';

  @override
  String get information => 'Información';

  @override
  String instance(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Instancias',
      one: 'Instancias',
      zero: 'Instancia',
    );
    return '$_temp0 ';
  }

  @override
  String get instanceActions => 'Acciones de la instancia';

  @override
  String instanceEntry(Object username) {
    return 'Instancia \'$username\'';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance ya ha sido añadido.';
  }

  @override
  String get instanceNameColor => 'Color del nombre de la instancia';

  @override
  String get instanceNameThickness => 'Espesor del nombre de la instancia';

  @override
  String get instances => 'Instancias';

  @override
  String get internetOrInstanceIssues =>
      'Es posible que no esté conectado a Internet o que tu instancia no esté disponible actualmente.';

  @override
  String get invalidUrl => 'Invalid URL format';

  @override
  String joined(Object x) {
    return 'Joined $x';
  }

  @override
  String get keywordFilterDescription =>
      'Filtra los mensajes que contienen palabras clave en el título, cuerpo o URL';

  @override
  String get keywordFilters => 'Filtros por palabra clave';

  @override
  String get label => 'Etiqueta';

  @override
  String get language => 'Idioma';

  @override
  String get languageFilters => '¿Buscar filtros de idiomas?';

  @override
  String get languageNotAllowed =>
      'La comunidad en la que estás publicando no permite publicar en el idioma que has seleccionado. Prueba con otro idioma.';

  @override
  String get large => 'Grande';

  @override
  String get leftLongSwipe => 'Deslizamiento largo a la izquierda';

  @override
  String get leftShortSwipe => 'Deslizamiento corto a la izquierda';

  @override
  String get light => 'Claro';

  @override
  String link(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enlaces',
      one: 'Enlace',
      zero: 'Enlace',
    );
    return '$_temp0 ';
  }

  @override
  String get linkActions => 'Acciones del enlace';

  @override
  String get linkHandlingCustomTabs =>
      'Abrir en el navegador del sistema integrado en la aplicación';

  @override
  String get linkHandlingCustomTabsShort => 'Integrado en la aplicación';

  @override
  String get linkHandlingExternal =>
      'Abrir externamente en el navegador del sistema';

  @override
  String get linkHandlingExternalShort => 'Externo';

  @override
  String get linkHandlingInApp => 'Utiliza el navegador integrado en Thunder';

  @override
  String get linkHandlingInAppShort => 'En la aplicación';

  @override
  String get linkPostsUseCompactView => 'Show Compact Link Posts';

  @override
  String get linksBehaviourSettings => 'Enlaces';

  @override
  String loadMorePlural(Object count) {
    return 'Cargar $count más respuestas…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Cargando $count respuesta(s) más…';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get local => 'Local';

  @override
  String get localNotifications => 'Notificaciones locales';

  @override
  String get localOnly => 'Solo Local';

  @override
  String get localPosts => 'Mensajes locales';

  @override
  String get lockPost => 'Bloquear Publicación';

  @override
  String get locked => 'Locked';

  @override
  String get lockedPost => 'Tema bloqueado';

  @override
  String get logOut => 'Cerrar sesión';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get loginAttemptCanceled => 'Intento de inicio de sesión cancelado.';

  @override
  String loginFailed(Object errorMessage) {
    return 'No se ha podido iniciar sesión. Inténtelo de nuevo. (Error: $errorMessage)';
  }

  @override
  String get loginSucceeded => 'Conectado.';

  @override
  String get loginToPerformAction =>
      'Para realizar esta tarea, debe iniciar sesión.';

  @override
  String get loginToSeeInbox => 'Conéctate para ver tu bandeja de entrada';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      '¿Buscas ajustes de feed específicos para tu cuenta?';

  @override
  String get malformedUri =>
      'El enlace que has proporcionado tiene un formato no válido. Por favor, asegúrese de que es un enlace válido.';

  @override
  String get manageAccounts => 'Administrar cuentas';

  @override
  String get manageMedia => 'Manage Media';

  @override
  String get markAllAsRead => 'Marcar todo como leído';

  @override
  String get markAsRead => 'Marcar como leído';

  @override
  String get markPostAsReadOnMediaView =>
      'Marcar como leído después de ver los medios';

  @override
  String get markPostAsReadOnScroll => 'Marcar como leído al desplazarse';

  @override
  String get markReadColor => 'Marcar color leído/no leído';

  @override
  String get matrixUser => 'Usuario de Matrix';

  @override
  String get me => 'Yo';

  @override
  String get media => 'Media';

  @override
  String get medium => 'Medio';

  @override
  String mention(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Menciones',
      one: 'Mención',
      zero: 'Mención',
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
      other: 'Mensajes',
      one: 'Mensaje',
      zero: 'Mensaje',
    );
    return '$_temp0';
  }

  @override
  String get metadataFontScale => 'Escala de las fuentes de metadatos';

  @override
  String get missingErrorMessage => 'Mensaje de error no disponible';

  @override
  String get modAdd => 'Añadir/eliminar moderadores de la instancia';

  @override
  String get modAddCommunity => 'Añadir/eliminar moderadores a las comunidades';

  @override
  String get modBan => 'Bloquear/Desbloquear usuarios de la instancia';

  @override
  String get modBanFromCommunity =>
      'Bloquear/desbloquear usuarios de las comunidades';

  @override
  String get modFeaturePost => 'Entradas destacadas/no destacadas';

  @override
  String get modLockPost => 'Bloquear/Desbloquear mensajes';

  @override
  String get modRemoveComment => 'Eliminar/restaurar comentarios';

  @override
  String get modRemoveCommunity => 'Eliminar/restaurar comunidades';

  @override
  String get modRemovePost => 'Eliminar/Restaurar mensajes';

  @override
  String get modTransferCommunity => 'Transferir comunidades';

  @override
  String get moderatedCommunities => 'Comunidades moderadas';

  @override
  String get moderates => 'Moderates';

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
  String get moderatorActions => 'Acciones del moderador';

  @override
  String get modlog => 'Registros de moderadores';

  @override
  String get mostComments => 'La mayoría de los comentarios';

  @override
  String get mustBeLoggedIn => 'Tienes que iniciar sesión';

  @override
  String get mustBeLoggedInComment =>
      'Hay que iniciar sesión para crear un comentario';

  @override
  String get mustBeLoggedInPost => 'Hay que iniciar sesión para crear un post';

  @override
  String get names => 'Nombres';

  @override
  String get navbarDoubleTapGestures =>
      'Gestos de doble toque en la barra de navegación';

  @override
  String get navbarSwipeGestures =>
      'Gestos de deslizar en la barra de navegación';

  @override
  String get navigateDown => 'Siguiente comentario';

  @override
  String get navigateUp => 'Comentario anterior';

  @override
  String get navigation => 'Navegación';

  @override
  String get nestedCommentIndicatorColor =>
      'Color del indicador del comentario fijado';

  @override
  String get nestedCommentIndicatorStyle =>
      'Estilo del indicador del comentario fijado';

  @override
  String get never => 'Nunca';

  @override
  String get newComments => 'Nuevos comentarios';

  @override
  String get newPost => 'Nuevo tema';

  @override
  String get new_ => 'Nuevo';

  @override
  String get no => 'No';

  @override
  String get noAccountsAdded => 'No se han añadido cuentas';

  @override
  String get noAnonymousInstances => 'No se han añadido instancias anónimas';

  @override
  String get noCommentsFound => 'No hay comentarios';

  @override
  String get noCommunitiesFound => 'No se han encontrado comunidades';

  @override
  String get noCommunityBlocks => 'Ninguna comunidad bloqueada';

  @override
  String get noCompatibleAppFound =>
      'No se ha encontrado una aplicación compatible';

  @override
  String get noDiscussionLanguages =>
      'No se oculta ningún contenido por motivos de idiomas.';

  @override
  String get noDisplayNameSet => 'Nombre para mostrar no establecido';

  @override
  String get noEmailSet => 'Correo electrónico no establecido';

  @override
  String get noFavoritedCommunities => 'Ninguna comunidad favorita';

  @override
  String get noImages => 'It looks like you have not uploaded any images.';

  @override
  String get noInstanceBlocks => 'Ninguna instancia bloqueada.';

  @override
  String get noItems => 'Sin artículos';

  @override
  String get noKeywordFilters => 'No se han añadido filtros de palabras clave';

  @override
  String get noLanguage => 'Ningún idioma';

  @override
  String get noMatrixUserSet => 'Usuario Matrix no establecido';

  @override
  String get noMentions => 'Sin menciones';

  @override
  String get noMessages => 'Sin mensajes';

  @override
  String get noPostsFound => 'No se ha encontrado ningún tema.';

  @override
  String get noProfileBioSet => 'Biografía de perfíl no establecida';

  @override
  String get noReferencesToImage =>
      'No posts or comments were found containing this image. However, it may be used elsewhere on the internet.';

  @override
  String get noReplies => 'No hay respuestas';

  @override
  String get noResultsFound => 'No se han encontrado resultados.';

  @override
  String get noSubscriptions => 'Sin suscripciones';

  @override
  String get noUserBlocks => 'Ningún usuario bloqueado.';

  @override
  String get noUserLabels => 'Aún no has creado ninguna etiqueta de usuario';

  @override
  String get noUsersFound => 'No se encontraron usuarios.';

  @override
  String get noVisibleComments =>
      'Comments may not be visible because the community is blocked.';

  @override
  String get none => 'Ninguna';

  @override
  String get normal => 'Normal';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance no parece ser una instancia válida de Lemmy';
  }

  @override
  String get notValidUrl => 'URL no válida';

  @override
  String get nothingToShare => 'Nada para compartir';

  @override
  String notifications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notificaciones',
      one: 'Notificación',
      zero: 'Notificación',
    );
    return '$_temp0';
  }

  @override
  String get notificationsBehaviourSettings => 'Notificaciones';

  @override
  String get notificationsNotAllowed =>
      'Las notificaciones no están permitidas para Thunder en la configuración del sistema';

  @override
  String get notificationsWarningDialog =>
      'Las notificaciones son una **característica experimental** que puede no funcionar correctamente en todos los dispositivos.\n\n - Las comprobaciones se producirán cada ~15 minutos y consumirán batería adicional.\n\n - Desactiva las optimizaciones de batería para una mayor probabilidad de éxito de las notificaciones.\n\n Consulta la siguiente página para obtener más información.';

  @override
  String get nsfw => 'NSFW';

  @override
  String get nsfwWarning => 'NSFW - Toque para mostrar';

  @override
  String get off => 'apagado';

  @override
  String get offline => 'sin conexión';

  @override
  String get ok => 'OK';

  @override
  String get old => 'Old';

  @override
  String get on => 'on';

  @override
  String get onWifi => 'En Wifi';

  @override
  String get onlyModsCanPostInCommunity =>
      'Sólo los moderadores pueden publicar en esta comunidad';

  @override
  String get open => 'Abrir';

  @override
  String get openAccountSwitcher => 'Abrir el conmutador de cuentas';

  @override
  String get openByDefault => 'Abrir por defecto';

  @override
  String get openInBrowser => 'Abrir en el navegador';

  @override
  String get openInstance => 'Abrir una instancia';

  @override
  String get openLinksInExternalBrowser =>
      'Abrir enlaces en un navegador externo';

  @override
  String get openLinksInReaderMode => 'Abrir enlaces en modo lectura';

  @override
  String get openSettings => 'Abrir la configuración';

  @override
  String get orange => 'Naranja';

  @override
  String get originalPoster => 'Cartel original';

  @override
  String get overview => 'Resumen';

  @override
  String get password => 'Password';

  @override
  String get pending => 'Pendiente';

  @override
  String performedBy(Object user) {
    return 'Performed by: $user';
  }

  @override
  String get permissionDenied =>
      'Thunder no tiene permiso para mostrar notificaciones. Por favor, habilítelo en los ajustes del sistema.';

  @override
  String get permissionDeniedMessage =>
      'Thunder requiere algunos permisos para guardar esta imagen que han sido denegados.';

  @override
  String get pinPostToCommunity => 'Fijar publicación a la Comunidad';

  @override
  String get pinToCommunity => 'Fijar a la comunidad';

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
  String get post => 'Tema';

  @override
  String get postActions => 'Acciones en los temas';

  @override
  String get postBehaviourSettings => 'Temas';

  @override
  String get postBody => 'Cuerpo de la publicación';

  @override
  String get postBodySettings => 'Configuración del cuerpo del mensaje';

  @override
  String get postBodySettingsDescription =>
      'Estos ajustes afectan a la visualización del cuerpo del mensaje';

  @override
  String get postBodyShowCommunityInstance => 'Mostrar instancia de comunidad';

  @override
  String get postBodyShowUserInstance => 'Mostrar la instancia del usuario';

  @override
  String get postBodyViewType => 'Tipo de vista del cuerpo de la publicación';

  @override
  String get postContentFontScale =>
      'Tamaño de las fuentes del contenido de la entrada';

  @override
  String get postCreatedSuccessfully => '¡Publicación creada exitosamente!';

  @override
  String get postLocked => 'Tema bloqueado. No se permiten respuestas.';

  @override
  String get postMetadataInstructions =>
      'Puede personalizar la información de metadatos arrastrando y soltando la información deseada';

  @override
  String get postNSFW => 'Marcar como NSFW';

  @override
  String get postPreview =>
      'Mostrar una vista previa del mensaje con la configuración';

  @override
  String get postSavedAsDraft => 'Publicación guardada como borrador';

  @override
  String get postShowUserInstance => 'Mostrar instancia de usuario';

  @override
  String get postSwipeActions => 'Acciones posteriores al deslizamiento';

  @override
  String get postSwipeGesturesHint =>
      '¿Quieres utilizar los botones? Cambia los botones que aparecen en los temas en los ajustes generales.';

  @override
  String get postTitle => 'Título';

  @override
  String get postTitleFontScale =>
      'Tamaño de la fuente del título de la publicación';

  @override
  String get postTogglePreview => 'Cambiar vista previa';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'No se ha podido cargar la imagen';

  @override
  String get postViewType => 'Tipo de vista del tema';

  @override
  String get posts => 'Posts';

  @override
  String get preview => 'Previsualizar';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '¡$profile aplicado correctamente!';
  }

  @override
  String get profileBio => 'Biografía de Perfil';

  @override
  String get profiles => 'Perfiles';

  @override
  String get public => 'Público';

  @override
  String get pureBlack => 'Negro puro';

  @override
  String get purgedComment => 'Comentario depurado';

  @override
  String get purgedCommunity => 'Comunidad depurada';

  @override
  String get purgedPerson => 'Persona depurada';

  @override
  String get purgedPost => 'Tema depurado';

  @override
  String get purple => 'Morado';

  @override
  String get pushNotification => 'Notificaciones Push';

  @override
  String get pushNotificationDescription =>
      'Si se activa, Thunder enviará su(s) token(s) JWT al servidor para sondear nuevas notificaciones. \n\n **NOTA:** Esto no tendrá efecto hasta la próxima vez que se inicie la aplicación.';

  @override
  String get pushNotificationServer => 'Servidor de notificaciones push';

  @override
  String get pushNotificationServerDescription =>
      'Configure el servidor de notificaciones push. El servidor debe estar correctamente configurado para enviar notificaciones push a tu dispositivo.\n\n **Introduzca solo un servidor en el que confíe con sus credenciales.**';

  @override
  String get rateLimitErrorMessage =>
      'You have hit the rate limit for this request. Please wait and try again later.';

  @override
  String get reachedTheBottom => 'No hay elementos para cargar';

  @override
  String get read => 'Leer';

  @override
  String get readAll => 'Leer todo';

  @override
  String get readerMode => 'Modo lectura';

  @override
  String get reason => 'Motivo';

  @override
  String get red => 'Rojo';

  @override
  String get reduceAnimations => 'Reducir las animaciones';

  @override
  String get reducesAnimations =>
      'Reducir las animaciones utilizadas en Thunder';

  @override
  String get refresh => 'Refrescar';

  @override
  String get refreshContent => 'Refrescar contenido';

  @override
  String get removalReason => 'Razón de la eliminación';

  @override
  String get remove => 'Eliminar';

  @override
  String get removeAccount => 'Eliminar cuenta';

  @override
  String get removeAsCommunityModerator =>
      'Eliminar como Moderador de la Comunidad';

  @override
  String get removeComment => 'Remove Comment';

  @override
  String get removeFromFavorites => 'Eliminar de favoritos';

  @override
  String get removeInstance => 'Eliminar instancia';

  @override
  String removeKeyword(Object keyword) {
    return '¿Quitar \"$keyword\"?';
  }

  @override
  String get removeKeywordFilter => 'Eliminar palabra clave';

  @override
  String get removePost => 'Eliminar el tema';

  @override
  String get removeUserData => 'Remove user data';

  @override
  String get removed => 'Removed';

  @override
  String get removedComment => 'Comentario eliminado';

  @override
  String get removedCommunity => 'Comunidad eliminada';

  @override
  String get removedCommunityFromSubscriptions =>
      'Darse de baja de la comunidad';

  @override
  String get removedInstanceMod => 'Moderador de instancia eliminado';

  @override
  String get removedModFromCommunity =>
      'Eliminado el moderador de la comunidad';

  @override
  String get removedPost => 'Mensaje eliminado';

  @override
  String removedUserAsCommunityModerator(Object username) {
    return 'Removed $username as community moderator';
  }

  @override
  String get reorder => 'Reordenar';

  @override
  String reply(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Replies',
      one: 'Responder',
      zero: 'Responder',
    );
    return '$_temp0';
  }

  @override
  String get replyColor => 'Color de la respuesta';

  @override
  String get replyNotSupported =>
      'Responder desde esta página aún no está disponible';

  @override
  String get replyToPost => 'Responder a la publicación';

  @override
  String replyingTo(Object author) {
    return 'Responder a $author';
  }

  @override
  String report(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reportes',
      one: 'Reporte',
      zero: 'Reportes',
    );
    return '$_temp0 ';
  }

  @override
  String get reportComment => 'Reportar comentario';

  @override
  String get reportPost => 'Reportar el tema';

  @override
  String get reportedComment => 'Reported comment';

  @override
  String get reportedPost => 'Reported post';

  @override
  String get reporter => 'Reportero:';

  @override
  String get requiredField => '*obligatorio';

  @override
  String get reset => 'Restablecer';

  @override
  String get resetCommentPreferences =>
      'Restablecer las preferencias de los comentarios';

  @override
  String get resetPostPreferences =>
      'Restablecer las preferencias de la publicación';

  @override
  String get resetPreferences => 'Restablecer los ajustes';

  @override
  String get resetPreferencesAndData => 'Restablecer los ajustes y los datos';

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreComment => 'Restore Comment';

  @override
  String get restorePost => 'Restaurar el tema';

  @override
  String get restoredComment => 'Comentario restaurado';

  @override
  String get restoredCommentFromDraft => 'Comentario restaurado del borrador';

  @override
  String get restoredCommunity => 'Comunidad restaurada';

  @override
  String get restoredPost => 'Tema restaurado';

  @override
  String get restoredPostFromDraft => 'Post restaurado desde el borrador';

  @override
  String get retry => 'Reintentar';

  @override
  String get rightLongSwipe => 'Deslizamiento largo hacia la derecha';

  @override
  String get rightShortSwipe => 'Deslizamiento corto hacia la derecha';

  @override
  String get save => 'Guardar';

  @override
  String get saveColor => 'Guardar el color';

  @override
  String get saveSettings => 'Guardar la configuración';

  @override
  String get saved => 'Guardado';

  @override
  String get scaled => 'Escala';

  @override
  String get scrapeMissingLinkPreviews =>
      'Eliminación de las vistas previas de los enlaces borrados';

  @override
  String get screenReaderProfile => 'Perfil del lector de pantalla';

  @override
  String get screenReaderProfileDescription =>
      'Optimiza Thunder para los lectores de pantalla reduciendo los elementos generales y eliminando los gestos potencialmente conflictivos.';

  @override
  String get search => 'Buscar';

  @override
  String get searchByText => 'Buscar por el texto';

  @override
  String get searchByUrl => 'Buscar por dirección URL';

  @override
  String get searchComments => 'Buscar comentarios';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return 'Buscar los comentarios federados con $instance';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return 'Buscar comunidades asociadas con $instance';
  }

  @override
  String searchInstance(Object instance) {
    return 'Buscar $instance';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return 'Buscar instancias federadas con $instance';
  }

  @override
  String get searchPostSearchType => 'Seleccionar el tipo de la búsqueda';

  @override
  String searchPostsFederatedWith(Object instance) {
    return 'Buscar los puestos federados con $instance';
  }

  @override
  String get searchTerm => 'Buscar términos';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Buscar los usuarios federados con $instance';
  }

  @override
  String get selectAccountToCommentAs => 'Seleccione cuenta para comentar como';

  @override
  String get selectAccountToPostAs => 'Seleccione la cuenta para publicar como';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get selectCommunity => 'Elija una comunidad (obligatorio)';

  @override
  String get selectFeedType => 'Seleccione el tipo del Feed';

  @override
  String get selectLanguage => 'Selecciona el idioma';

  @override
  String get selectSearchType => 'Seleccione el tipo de la búsqueda';

  @override
  String get selectText => 'Seleccionar el texto';

  @override
  String get sendBackgroundTestLocalNotification =>
      'Enviar notificación local de prueba en segundo plano';

  @override
  String get sendBackgroundTestUnifiedPushNotification =>
      'Enviar notificación UnifiedPush de prueba en segundo plano';

  @override
  String get sendTestLocalNotification => 'Enviar notificación local de prueba';

  @override
  String get sendTestUnifiedPushNotification =>
      'Enviar notificación UnifiedPush de prueba';

  @override
  String get sensitiveContentWarning =>
      'Puede contener contenido sensible. Toque para revelar.';

  @override
  String get sentRequestForTestNotification =>
      'Solicitud enviada para notificación de prueba.';

  @override
  String serverErrorComments(Object message) {
    return 'Se ha producido un error en el servidor al obtener más comentarios: $message';
  }

  @override
  String get setAction => 'Establecer acción';

  @override
  String get setLongPress => 'Fijar como acción de pulsación larga';

  @override
  String get setShortPress => 'Fijar como acción de pulsación corta';

  @override
  String get settingOverrideLabel =>
      'Estas configuraciones sobrescriben las configuraciones por defecto de Thunder.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'Las configuraciones $settingType aún no son compatibles.';
  }

  @override
  String get settings => 'Ajustes';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'Las configuraciones fueron guardadas exitosamente en \'$savedFilePath\'';
  }

  @override
  String get settingsFeedCards =>
      'Estos ajustes se aplican a las tarjetas del feed principal, las acciones están siempre disponibles al abrir las publicaciones.';

  @override
  String get settingsImportedSuccessfully =>
      '¡Las configuraciones fueron importadas exitosamente!';

  @override
  String get settingsNotExportedSuccessfully =>
      'Las configuraciones no fueron guardadas exitosamente, o la operación fue cancelada.';

  @override
  String get settingsNotImportedSuccessfully =>
      'Las configuraciones no fueron importadas exitosamente o la operación fue cancelada.';

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
  String get share => 'Compartir';

  @override
  String get shareComment => 'Compartir enlace del comentario';

  @override
  String get shareCommentLocal =>
      'Compartir enlace del comentario (Mi instancia)';

  @override
  String get shareCommunity => 'Compartir la comunidad';

  @override
  String get shareCommunityLink => 'Compartir enlace a la comunidad';

  @override
  String get shareCommunityLinkLocal =>
      'Compartir enlace comunitario (Mi instancia)';

  @override
  String get shareImage => 'Compartir imagen';

  @override
  String get shareLemmyLink => 'Compartir enlace Lemmy';

  @override
  String get shareLink => 'Compartir enlace externo';

  @override
  String get shareMedia => 'Compartir medios';

  @override
  String get shareMediaLink => 'Compartir enlace multimedia';

  @override
  String get shareOriginalLink => 'Compartir enlace original';

  @override
  String get sharePost => 'Compartir enlace al tema';

  @override
  String get sharePostLocal => 'Compartir enlace de publicación (Mi instancia)';

  @override
  String get shareThumbnail => 'Compartir miniatura';

  @override
  String get shareThumbnailAsImage => 'Compartir miniatura como imagen';

  @override
  String get shareUser => 'Compartir usuario';

  @override
  String get shareUserLink => 'Compartir enlace del usuario';

  @override
  String get shareUserLinkLocal =>
      'Compartir el enlace del usuario (Mi Instancia)';

  @override
  String get showAll => 'Mostrar todo';

  @override
  String get showBotAccounts => 'Mostrar las cuentas de los bots';

  @override
  String get showCommentActionButtons =>
      'Mostrar botones de acción del comentario';

  @override
  String get showCommunityDisplayNames =>
      'Mostrar nombres para mostrar de la comunidad';

  @override
  String get showCrossPosts => 'Mostrar publicaciones cruzadas';

  @override
  String get showEdgeToEdgeImages => 'Mostrar imágenes de borde a borde';

  @override
  String get showExpandedTaglines => 'Mostrar lemas ampliados';

  @override
  String get showFullDate => 'Mostrar la fecha completa';

  @override
  String get showFullDateDescription =>
      'Mostrar la fecha completa en los mensajes';

  @override
  String get showFullHeightImages => 'Mostrar imágenes a tamaño completo';

  @override
  String get showHiddenPosts => 'Mostrar los mensajes ocultos';

  @override
  String get showInAppUpdateNotifications =>
      'Recibe notificaciones de las nuevas versiones de GitHub';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get showMore => 'Mostrar más';

  @override
  String get showNavigationLabels => 'Mostrar etiquetas de navegación';

  @override
  String get showNavigationLabelsDescription =>
      'Mostrar o no etiquetas debajo de los botones de navegación inferiores';

  @override
  String get showNsfwContent => 'Mostrar Contenido NSFW';

  @override
  String get showOwnContent => 'Mostrar el contenido propio';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get showPostAuthor => 'Mostrar el autor del mensaje';

  @override
  String get showPostAuthorSubtitle =>
      'El autor del tema siempre se muestra en las fuentes de la comunidad';

  @override
  String get showPostCommunityFirst => 'Show Community and Author First';

  @override
  String get showPostCommunityIcons => 'Mostrar iconos de la comunidad';

  @override
  String get showPostSaveAction => 'Mostrar el botón guardar';

  @override
  String get showPostTextContentPreview => 'Mostrar vista previa del texto';

  @override
  String get showPostTitleFirst => 'Mostrar el título primero';

  @override
  String get showPostVoteActions => 'Mostrar los botones de votación';

  @override
  String get showReadPosts => 'Mostrar las publicaciones leídas';

  @override
  String get showSavedContent => 'Mostrar contenido guardado';

  @override
  String get showScoreCounters => 'Visualizar las puntuaciones de los usuarios';

  @override
  String get showScores =>
      'Mostrar las puntuaciones de publicaciones/comentarios';

  @override
  String get showTextPostIndicator =>
      'Mostrar indicador de la publicación del texto';

  @override
  String get showThumbnailPreviewOnRight => 'Mostrar miniaturas a la derecha';

  @override
  String get showUnreadOnly => 'Mostrar solo los no leídos';

  @override
  String get showUpdateChangelogs =>
      'Mostrar los registros de cambios de la actualización';

  @override
  String get showUpdateChangelogsSubtitle =>
      'Mostrar una lista con los cambios después de actualizar';

  @override
  String get showUserAvatar => 'Mostrar el avatar del usuario';

  @override
  String get showUserDisplayNames => 'Mostrar los nombres de usuario';

  @override
  String get showUserInstance => 'Mostrar la instancia del usuario';

  @override
  String get sidebar => 'Barra lateral';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Doble toque en la barra inferior para abrir la barra lateral';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Deslizar la barra inferior para abrir la barra lateral';

  @override
  String get small => 'Pequeño';

  @override
  String get somethingWentWrong => '¡Vaya, algo salió mal!';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortByTop => 'Ordenar por mejor';

  @override
  String get sortOptions => 'Opciones para ordenar';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get standard => 'Estándar';

  @override
  String get stats => 'Stats';

  @override
  String get status => 'Estado';

  @override
  String get submit => 'Submit';

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get subscribeToCommunity => 'Suscribirse a la comunidad';

  @override
  String get subscribed => 'Suscrito';

  @override
  String get subscriptionRequestSent => 'Solicitud de suscripción enviada';

  @override
  String get subscriptions => 'Suscripciones';

  @override
  String successfullyBannedUser(Object username) {
    return '$username Baneado';
  }

  @override
  String get successfullyBlocked => 'Bloqueado.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return '$communityName bloqueado';
  }

  @override
  String successfullyBlockedUser(Object username) {
    return '$username bloqueado';
  }

  @override
  String successfullyUnbannedUser(Object username) {
    return '$username desbaneado';
  }

  @override
  String get successfullyUnblocked => 'Desbloqueado.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return '$communityName desbloqueado';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return '$username desbloqueado';
  }

  @override
  String get suchAs => 'tales como';

  @override
  String get suggestedTitle => 'Título sugerido';

  @override
  String switchedAccount(Object username) {
    return 'Switched to $username';
  }

  @override
  String get system => 'Sistema';

  @override
  String get systemDarkMode => 'Modo oscuro del sistema';

  @override
  String get systemDarkModeDescription =>
      'Activar el tema negro puro en el modo oscuro del sistema';

  @override
  String get tabletMode => 'Modo tableta (vista en 2 columnas)';

  @override
  String get tapToExit => 'Vuelve a pulsar atrás para salir';

  @override
  String get tappableAuthorCommunity => 'Autores y comunidades de Tappable';

  @override
  String get teal => 'Verde azulado';

  @override
  String get testBackgroundNotificationDescription =>
      'Thunder se cerrará y luego intentará generar una notificación en segundo plano (esto demorará al menos 15 minutos)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'Thunder pedirá al servidor de notificaciones que envíe una notificación diferida y luego se cerrará. (Puede tardar unos minutos)';

  @override
  String get text => 'Texto';

  @override
  String get textActions => 'Acciones del texto';

  @override
  String get theme => 'Tema';

  @override
  String get themeAccentColor => 'Colores del acento';

  @override
  String get themePrimary => 'Tema primario';

  @override
  String get themeSecondary => 'Tema secundario';

  @override
  String get themeTertiary => 'Tema terciario';

  @override
  String get theming => 'Temática';

  @override
  String get thickness => 'Espesor';

  @override
  String get thisAccount => 'Esta cuenta';

  @override
  String get thumbnailUrl => 'URL de la miniatura';

  @override
  String thunderHasBeenUpdated(Object version) {
    return '¡Thunder actualizado a $version!';
  }

  @override
  String thunderNotificationServer(Object server) {
    return 'Servidor de notificaciones de Thunder: $server';
  }

  @override
  String get timeoutComments =>
      'Error: se agotó el tiempo de espera al cargar comentarios';

  @override
  String get timeoutErrorMessage =>
      'Se agotó el tiempo esperando una respuesta.';

  @override
  String get timeoutSaveComment =>
      'Error: se agotó el tiempo de espera al guardar el comentario';

  @override
  String get timeoutSavingPost =>
      'Error: se agotó el tiempo de espera al guardar el post.';

  @override
  String get timeoutUpvoteComment =>
      'Error: se agotó el tiempo de espera al votar el comentario';

  @override
  String get timeoutVotingPost =>
      'Error: se agotó el tiempo de espera al votar el post.';

  @override
  String get toggelRead => 'Alternar lectura';

  @override
  String get top => 'Top';

  @override
  String get topAll => 'Lo mejor de todos los tiempos';

  @override
  String get topDay => 'Lo mejor de hoy';

  @override
  String get topHour => 'Lo mejor de la última hora';

  @override
  String get topMonth => 'Lo mejor del mes';

  @override
  String get topNineMonths => 'Lo mejor en los últimos 9 meses';

  @override
  String get topSixHour => 'Lo mejor de las últimas 6 horas';

  @override
  String get topSixMonths => 'Lo mejor en los últimos 6 meses';

  @override
  String get topThreeMonths => 'Lo mejor en los últimos 3 meses';

  @override
  String get topTwelveHour => 'Lo mejor de las últimas 12 horas';

  @override
  String get topWeek => 'Lo mejor de la semana';

  @override
  String get topYear => 'Lo mejor del año';

  @override
  String totalComments(Object x) {
    return '$x Comments';
  }

  @override
  String totalPosts(Object x) {
    return '$x Posts';
  }

  @override
  String get totp => 'TOTP (opcional)';

  @override
  String get transferredModToCommunity => 'Comunidad transferida';

  @override
  String get translationsMayNotBeComplete =>
      'Por favor, tenga en cuenta que las traducciones pueden no estar completas';

  @override
  String get trendingCommunities => 'Comunidades de moda';

  @override
  String get trySearchingFor => 'Intentando buscar por...';

  @override
  String get unableToFindCommunity => 'Imposible encontrar a la comunidad';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'No se ha podido encontrar la comunidad \'$communityName\'';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'No se puede encontrar la comunidad seleccionada en la instancia del usuario seleccionado.';

  @override
  String get unableToFindInstance => 'No se encuentra la instancia';

  @override
  String get unableToFindLanguage => 'No se encuentra el idioma';

  @override
  String get unableToFindPost => 'No se encuentra el mensaje';

  @override
  String get unableToFindUser => 'No se encuentra el usuario';

  @override
  String unableToFindUserName(Object username) {
    return 'No se puede encontrar el usuario \'$username\'';
  }

  @override
  String get unableToLoadImage => 'No es posible cargar la imagen';

  @override
  String unableToLoadImageFrom(Object domain) {
    return 'No se ha podido cargar la imagen de $domain';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return 'No se puede cargar $instance';
  }

  @override
  String get unableToLoadPost => 'Unable to load post';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return 'No se pueden cargar los posts de $instance';
  }

  @override
  String get unableToLoadReplies => 'No es posible cargar más respuestas.';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return 'No se puede navegar a $instanceHost. Puede que no sea una instancia Lemmy válida.';
  }

  @override
  String get unableToResolveReport => 'No se puede resolver el informe';

  @override
  String unableToRetrieveChangelog(Object version) {
    return 'No se ha podido recuperar el registro de cambios para la versión $version.';
  }

  @override
  String get unbanFromCommunity => 'Desbaneo de la comunidad';

  @override
  String get unbannedUser => 'Usuario no bloqueado';

  @override
  String unbannedUserFromCommunity(Object username) {
    return 'Usuario no expulsado de la comunidad';
  }

  @override
  String get unblock => 'Unblock';

  @override
  String get unblockCommunity => 'Desbloquear Cominudad';

  @override
  String get unblockCommunityInstance =>
      'Desbloquear instancia de la comunidad';

  @override
  String get unblockInstance => 'Desbloquear la instancia';

  @override
  String get unblockUser => 'Desbloquear usuario';

  @override
  String get unblockUserInstance => 'Desbloquear instancia de usuario';

  @override
  String get understandEnable => 'Comprendo, Activar';

  @override
  String get unexpectedError => 'Error inesperado';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get unfeaturedPost => 'Tema sin categoría';

  @override
  String get unhidCommunity => 'Comunidad sin ocultar';

  @override
  String get unhide => 'Mostrar';

  @override
  String unifiedPushDistributorApp(Object app, Object count) {
    return 'Aplicación Distribuidor UnifiedPush: $app ($count disponible)';
  }

  @override
  String get unifiedPushNotifications => 'Notificaciones UnifiedPush';

  @override
  String unifiedPushServer(Object server) {
    return 'Servidor UnifiedPush: $server';
  }

  @override
  String get unifiedpush => 'UnifiedPush';

  @override
  String get unlockPost => 'Desbloquear el tema';

  @override
  String get unlockedPost => 'Tema desbloqueado';

  @override
  String get unpinFromCommunity => 'Desvincular de la comunidad';

  @override
  String get unpinPostFromCommunity =>
      'Desvincular publicación de la comunidad';

  @override
  String get unpinnedPostFromCommunity => 'Unpinned post from community';

  @override
  String get unreachable => 'Inaccesible';

  @override
  String get unresolved => 'Sin resolver';

  @override
  String get unsubscribe => 'Eliminar suscripción';

  @override
  String get unsubscribeFromCommunity => 'Darse de baja de la comunidad';

  @override
  String get unsubscribePending =>
      'Cancelar suscripción (suscripción pendiente)';

  @override
  String get unsubscribed => 'Suscripción eliminada';

  @override
  String updateReleased(Object version) {
    return 'Actualización publicada: $version';
  }

  @override
  String get uploadImage => 'Subir imagen';

  @override
  String uploadedDate(Object date) {
    return 'Uploaded: $date';
  }

  @override
  String get upvote => 'Voto positivo';

  @override
  String get upvoteColor => 'Color del voto positivo';

  @override
  String get upvoted => 'Votado a favor';

  @override
  String get uriNotSupported =>
      'Este tipo de enlace no es compatible por el momento.';

  @override
  String get url => 'Dirección URL';

  @override
  String get useAdvancedShareSheet =>
      'Utilice el formulario para compartir avanzado';

  @override
  String get useApplePushNotifications => 'Utilizar notificaciones APN';

  @override
  String get useApplePushNotificationsDescription =>
      'Utilizar el servicio de notificaciones push de Apple';

  @override
  String get useCompactView =>
      'Activar para mensajes pequeños, desactivar para grandes.';

  @override
  String get useLocalNotifications =>
      'Utilizar notificaciones locales (Experimental)';

  @override
  String get useLocalNotificationsDescription =>
      'Comprueba periódicamente si hay notificaciones en segundo plano';

  @override
  String get useMaterialYouTheme => 'Utilizar en el tema Material You';

  @override
  String get useMaterialYouThemeDescription =>
      'Anula el tema personalizado seleccionado';

  @override
  String get useProfilePictureForDrawer => 'Usar imagen de perfil para cajón';

  @override
  String get useProfilePictureForDrawerSubtitle =>
      'Cuando inicia sesión, muestra la imagen de perfil del usuario en lugar del ícono del cajón';

  @override
  String useSuggestedTitle(Object title) {
    return 'Utilice el título sugerido: $title';
  }

  @override
  String get useUnifiedPushNotifications =>
      'Utiliza las notificaciones de UnifiedPush';

  @override
  String get useUnifiedPushNotificationsDescription =>
      'Requiere una aplicación compatible';

  @override
  String get user => 'Usuario';

  @override
  String get userActions => 'Acciones del usuario';

  @override
  String userEntry(Object username) {
    return 'Usuario \'$username\'';
  }

  @override
  String get userFormat => 'Formato del usuario';

  @override
  String get userLabelHint => 'Este es mi usuario favorito';

  @override
  String get userLabels => 'Etiquetas de usuario';

  @override
  String get userLabelsSettingsPageDescription =>
      'Puedes añadir, modificar o eliminar etiquetas asociadas a los usuarios.';

  @override
  String get userNameColor => 'Color del nombre de usuario';

  @override
  String get userNameThickness => 'Espesor del nombre del usuario';

  @override
  String get userNotLoggedIn => 'Usuario no conectado';

  @override
  String get userProfiles => 'Perfiles de los usuarios';

  @override
  String get userSettingDescription =>
      'Estos ajustes se sincronizan con tu cuenta de Lemmy y sólo se aplican por cuenta.';

  @override
  String get userStyle => 'Estilo del usuario';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get usernameFormattingRedirect =>
      '¿Buscas el formato de un nombre de usuario?';

  @override
  String get users => 'Usuarios';

  @override
  String versionNumber(Object version) {
    return 'Versión $version';
  }

  @override
  String get video => 'Vídeo';

  @override
  String get videoAutoFullscreen => 'Pantalla completa automática';

  @override
  String get videoAutoLoop => 'Vídeo en bucle';

  @override
  String get videoAutoMute => 'Silenciar vídeos';

  @override
  String get videoAutoPlay => 'Reproducción automática del vídeo';

  @override
  String get videoDefaultPlaybackSpeed =>
      'Velocidad de reproducción predeterminada';

  @override
  String get videoLinkHandlingExternal =>
      'Reproducir vídeo con una aplicación externa';

  @override
  String get videoPlayerInApp => 'Utilizar el reproductor integrado Thunder';

  @override
  String get videoPlayerMode => 'Modo de reproducción';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get viewAllComments => 'Ver todos los comentarios';

  @override
  String get viewCommentSource => 'Ver el origen de los comentarios';

  @override
  String get viewModlog => 'Ver registro de modificaciones';

  @override
  String get viewOriginal => 'Mostrar el original';

  @override
  String get viewPostAsDifferentAccount =>
      'Ver publicación como una cuenta diferente';

  @override
  String get viewPostSource => 'Ver origen de la publicación';

  @override
  String get viewSource => 'Ver la fuente';

  @override
  String get viewingAll => 'Mostrando todo';

  @override
  String visibility(Object visibility) {
    return 'Visibilidad: $visibility';
  }

  @override
  String get visitCommunity => 'Visitar la comunidad';

  @override
  String get visitCommunityInstance => 'Visitar la instancia de una comunidad';

  @override
  String get visitInstance => 'Instancia de la visita';

  @override
  String get visitUserInstance => 'Visitar la instancia de un usuario';

  @override
  String get visitUserProfile => 'Visitar el perfil del usuario';

  @override
  String get warning => 'Advertencia';

  @override
  String xDownvotes(Object x) {
    return '$x votos negativos';
  }

  @override
  String xScore(Object x) {
    return '$x puntuación';
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
      other: '$x años',
      one: '$x año',
      zero: '$x años',
    );
    return '$_temp0';
  }

  @override
  String get yes => 'Sí';

  @override
  String get youMustSelectAJsonFile => 'You must select a .json file.';
}
