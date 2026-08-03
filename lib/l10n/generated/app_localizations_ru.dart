// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get about => 'О приложении';

  @override
  String get accept => 'Принять';

  @override
  String get accessibility => 'Специальные возможности';

  @override
  String get accessibilityProfilesDescription =>
      'Специальные возможности позволяют одновременно применять несколько настроек для удовлетворения конкретного требования доступности.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Аккаунта',
      one: 'Аккаунт',
      zero: 'Аккаунтов',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'День рождения аккаунта $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'Your account settings override the following settings';

  @override
  String get accountSettings => 'Настройки аккаунта';

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
  String get actions => 'Действия';

  @override
  String get active => 'Активный';

  @override
  String get activity => 'Activity';

  @override
  String get add => 'Добавить';

  @override
  String get addAccount => 'Добавить аккаунт';

  @override
  String get addAccountToSeeProfile => 'Войдите, чтобы увидеть свой аккаунт.';

  @override
  String get addAnonymousInstance => 'Добавить анонимный инстанс';

  @override
  String get addAsCommunityModerator => 'Add as Community Moderator';

  @override
  String get addDiscussionLanguage => 'Add Language';

  @override
  String get addKeywordFilter => 'Добавить ключевое слово';

  @override
  String get addOriginalPostBody => 'Add original post body?';

  @override
  String get addToFavorites => 'Добавить в избранное';

  @override
  String get addUserLabel => 'Add User Label';

  @override
  String get addedCommunityToSubscriptions => 'Подписались на сообщество';

  @override
  String get addedInstanceMod => 'Added Instance Mod';

  @override
  String get addedModToCommunity => 'Added Mod to Community';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return 'Added $username as community moderator';
  }

  @override
  String get admin => 'Админ';

  @override
  String get advanced => 'Дополнительно';

  @override
  String ago(Object time) {
    return '$time ago';
  }

  @override
  String get all => 'Все';

  @override
  String get allPosts => 'Все посты';

  @override
  String get allowOpenSupportedLinks =>
      'Разрешить приложению открывать поддерживаемые ссылки.';

  @override
  String get alreadyPostedTo => 'Уже опубликовано в';

  @override
  String get altText => 'Alt Text';

  @override
  String get alternateSources => 'Alternate Sources';

  @override
  String get always => 'Всегда';

  @override
  String andXMore(Object count) {
    return 'и ещё $count';
  }

  @override
  String get animations => 'Анимации';

  @override
  String get anonymous => 'Анонимно';

  @override
  String get anonymousInstances => 'Anonymous Instances';

  @override
  String get appLanguage => 'Язык приложения';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get applePushNotificationService => 'Apple Push Notification Service';

  @override
  String get applied => 'Применено';

  @override
  String get apply => 'Применить';

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
  String get back => 'Назад';

  @override
  String get backButton => 'Кнопка назад';

  @override
  String get backToTop => 'Наверх';

  @override
  String get backgroundCheckWarning =>
      'Note that notification checks will consume additional battery';

  @override
  String get ban => 'Ban';

  @override
  String get banFromCommunity => 'Ban from Community';

  @override
  String get bannedUser => 'Забанненый пользователь';

  @override
  String get bannedUserFromCommunity => 'Banned User from Community';

  @override
  String get base => 'База';

  @override
  String get block => 'Block';

  @override
  String get blockCommunity => 'Заблокировать сообщество';

  @override
  String get blockCommunityInstance => 'Block Community Instance';

  @override
  String get blockInstance => 'Заблокировать инстанс';

  @override
  String get blockManagement => 'Block Management';

  @override
  String get blockSettingLabel => 'User/Community/Instance Blocks';

  @override
  String get blockUser => 'Заблокировать пользователя';

  @override
  String get blockUserInstance => 'Block User Instance';

  @override
  String get blockedCommunities => 'Заблокированные сообщества';

  @override
  String get blockedInstances => 'Заблокированные инстансы';

  @override
  String get blockedUsers => 'Заблокированные пользователи';

  @override
  String get blue => 'Синий';

  @override
  String get bold => 'Толстый';

  @override
  String get boldCommunityName => 'Bold Community Name';

  @override
  String get boldInstanceName => 'Bold Instance Name';

  @override
  String get boldUserName => 'Bold User Name';

  @override
  String get bot => 'Бот';

  @override
  String get browserMode => 'Обработка ссылок';

  @override
  String browsingAnonymously(Object instance) {
    return 'Вы уже просматриваете $instance анонимно.';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get cannotReportOwnComment =>
      'Вы не можете пожаловаться на свой комментарий.';

  @override
  String get cantBlockAdmin =>
      'Вы не можете заблокировать администратора инстанса.';

  @override
  String get cantBlockYourself => 'Вы можете не блокировать себя.';

  @override
  String get cardPostCardMetadataItems => 'Card View Metadata';

  @override
  String get cardView => 'Карточки';

  @override
  String get cardViewDescription =>
      'Включите вид карточек чтобы применить настройки';

  @override
  String get cardViewSettings => 'Настройки карточек';

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
  String get changeSort => 'Изменить сортировку';

  @override
  String clearCache(Object cacheSize) {
    return 'Clear Cache ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Clear Cache';

  @override
  String get clearDatabase => 'Очистить базу данных';

  @override
  String get clearPreferences => 'Очистить предпочтения';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get clearedCache => 'Cleared cache successfully.';

  @override
  String get clearedDatabase =>
      'Локальная база данных очищена. Перезапустить Thunder, чтобы изменения вступили в силу.';

  @override
  String get clearedUserPreferences => 'Очищены все пользовательские параметры';

  @override
  String get close => 'Закрыть';

  @override
  String get collapse => 'Свернуть';

  @override
  String get collapseCommentPreview => 'Свернуть предпросмотр комментария';

  @override
  String get collapseInformation => 'Свернуть информацию';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Hide Parent Comment when Collapsed';

  @override
  String get collapsePost => 'Свернуть публикацию';

  @override
  String get collapsePostPreview => 'Свернуть предпросмотр сообщения';

  @override
  String get collapseSpoiler => 'Свернуть спойлер';

  @override
  String get color => 'Цвет';

  @override
  String get colorizeCommunityName => 'Colorize Community Name';

  @override
  String get colorizeInstanceName => 'Colorize Instance Name';

  @override
  String get colorizeUserName => 'Colorize User Name';

  @override
  String get colors => 'Цвета';

  @override
  String get combineCommentScores => 'Combine Comment Scores';

  @override
  String get combineCommentScoresLabel => 'Свернуть оценки комментария';

  @override
  String get combineNavAndFab =>
      'Плавающая кнопка действия будет отображаться между кнопками навигации.';

  @override
  String get combineNavAndFabDescription =>
      'Floating Action Button will be shown between navigation buttons.';

  @override
  String get comfortable => 'Комфортный';

  @override
  String get comment => 'Комментарий';

  @override
  String get commentActions => 'Comment Actions';

  @override
  String get commentBehaviourSettings => 'Комментарии';

  @override
  String get commentFontScale => 'Comment Content Font Scale';

  @override
  String get commentPreview =>
      'Показать предпросмотр комментариев с заданными настройками';

  @override
  String get commentReported =>
      'Этот комментарий был отмечен для рассмотрения.';

  @override
  String get commentSavedAsDraft => 'Комментарий сохранен как черновик';

  @override
  String get commentShowUserAvatar => 'Show User Avatar';

  @override
  String get commentShowUserInstance => 'Показывать инстанс пользователя';

  @override
  String get commentSortType => 'Тип сортировки комментариев';

  @override
  String get commentSwipeActions => 'Comment Swipe Actions';

  @override
  String get commentSwipeGesturesHint =>
      'Хотите вместо этого использовать кнопки? Включите их в разделе комментариев в общих настройках.';

  @override
  String get comments => 'Комментарии';

  @override
  String get communities => 'Сообщества';

  @override
  String get community => 'Сообщество';

  @override
  String get communityActions => 'Community Actions';

  @override
  String communityEntry(Object community) {
    return 'Community \'$community\'';
  }

  @override
  String get communityFormat => 'Формат сообщества';

  @override
  String get communityNameColor => 'Community Name Color';

  @override
  String get communityNameThickness => 'Community Name Thickness';

  @override
  String get communityStyle => 'Community Style';

  @override
  String get compact => 'Компактный';

  @override
  String get compactPostCardMetadataItems => 'Compact View Metadata';

  @override
  String get compactView => 'Компактный вид';

  @override
  String get compactViewDescription =>
      'Включите компактный вид, чтобы настроить параметры';

  @override
  String get compactViewSettings => 'Настройки компактного вида';

  @override
  String get condensed => 'Сжатый';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get confirmLogOutBody => 'Вы уверены, что хотите выйти?';

  @override
  String get confirmLogOutTitle => 'Выйти?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Вы уверены, что хотите отметить все сообщения прочитанными?';

  @override
  String get confirmMarkAllAsReadTitle => 'Пометить всё прочитанным?';

  @override
  String get confirmResetCommentPreferences =>
      'Это сбросит все настройки комментариев. Вы уверены, что хотите продолжить?';

  @override
  String get confirmResetPostPreferences =>
      'Это сбросит все настройки публикаций. Вы уверены, что хотите продолжить?';

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
  String get controversial => 'Разговор';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get copy => 'Копировать';

  @override
  String get copyComment => 'Copy Comment';

  @override
  String get copySelected => 'Copy selected';

  @override
  String get copyText => 'Копировать текст';

  @override
  String get couldNotDetermineCommentDelete =>
      'Ошибка: не удалось определить публикацию для удаления комментария.';

  @override
  String get couldNotDeterminePostComment =>
      'Ошибка: не удалось определить публикацию для комментария.';

  @override
  String get couldntCreateReport =>
      'В настоящее время не удалось отправить ваш отчет о комментариях. Пожалуйста, повторите попытку позже';

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
    return '$count Подписчиков';
  }

  @override
  String countUsers(Object count) {
    return '$count пользователей';
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
  String get createAccount => 'Создать аккаунт';

  @override
  String get createComment => 'Создать комментарий';

  @override
  String get createNewCrossPost => 'Создать новый кросс-пост';

  @override
  String get createPost => 'Создать пост';

  @override
  String created(Object date) {
    return 'Created $date';
  }

  @override
  String get createdToday => 'Created Today';

  @override
  String get creator => 'Создатель';

  @override
  String crossPostedFrom(Object postUrl) {
    return 'cross-posted from: $postUrl';
  }

  @override
  String get crossPostedTo => 'Кросс-пост в';

  @override
  String get currentLongPress =>
      'В настоящее время установлено как длительное нажатие';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Current notifications mode: $mode';
  }

  @override
  String get currentSinglePress =>
      'В настоящее время установлено как однократное нажатие';

  @override
  String get customizeSwipeActions =>
      'Настройте действия свайпа (нажмите, чтобы изменить)';

  @override
  String get dangerZone => 'Опасная зона';

  @override
  String get dark => 'Тёмная';

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
  String get debug => 'Отладка';

  @override
  String get debugDescription =>
      'Следующие параметры отладки следует использовать только в целях устранения неполадок.';

  @override
  String get debugNotificationsDescription =>
      'Use the following options to troubleshoot issues related to notifications.';

  @override
  String get decline => 'Decline';

  @override
  String get defaultColor => 'По умолчанию';

  @override
  String get defaultCommentSortType => 'Сортировка комментариев по умолчанию';

  @override
  String get defaultFeedSortType => 'Сортировка ленты по умолчанию';

  @override
  String get defaultFeedType => 'Тип новостей по умолчанию';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountDescription =>
      'To permanently delete your account, you will be redirected to your instance site. \n\nAre you sure you want to continue?';

  @override
  String get deleteComment => 'Delete Comment';

  @override
  String get deleteDraftConfirmation =>
      'Are you sure you want to delete this draft?';

  @override
  String get deleteImageConfirmMessage =>
      'Are you sure you want to delete this image?';

  @override
  String get deleteImageConfirmTitle => 'Удалить?';

  @override
  String get deleteLocalDatabase => 'Удалить локальную базу данных';

  @override
  String get deleteLocalDatabaseDescription =>
      'Это действие удалит локальную базу данных и сбросит вас из всех ваших аккаунтов.\n\nВы уверены, что хотите продолжить?';

  @override
  String get deleteLocalPreferences => 'Удалить локальные предпочтения';

  @override
  String get deleteLocalPreferencesDescription =>
      'Это очистит все ваши пользовательские предпочтения и настройки в Thunder.\n\nВы хотите продолжить?';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get deleteUserLabelConfirmation =>
      'Are you sure you want to delete the label?';

  @override
  String get deleted => 'Удалено';

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
    return 'Причина: $reason';
  }

  @override
  String get dimReadPosts =>
      'Прочитанные сообщения будут выделены серым цветом';

  @override
  String get directMessage => 'Direct message';

  @override
  String get disable => 'Отключить';

  @override
  String get disablePushNotifications => 'Disable Push Notifications';

  @override
  String get disabled => 'Выключено';

  @override
  String get discussionLanguages => 'Discussion Languages';

  @override
  String get discussionLanguagesTooltip =>
      'Content is filtered to the selected languages.';

  @override
  String get dismissRead => 'Отклонить чтение';

  @override
  String get displayName => 'Display Name';

  @override
  String get displayUserScore => 'Показывать очки пользователей (Карма).';

  @override
  String get dividerAppearance => 'Divider Appearance';

  @override
  String get doNotShowAgain => 'Do Not Show Again';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Found multiple compatible apps; please install only one';

  @override
  String get downloadingMedia => 'Загрузка медиа для отправки…';

  @override
  String get downvote => 'Понизить';

  @override
  String get downvoteColor => 'Downvote Color';

  @override
  String get downvoted => 'Downvoted';

  @override
  String get downvotesDisabled =>
      'На этом инстансе отключены голоса \"Против\".';

  @override
  String get drafts => 'Drafts';

  @override
  String get edit => 'Редактировать';

  @override
  String get editComment => 'Изменить комментарий';

  @override
  String get editPost => 'Изменение поста';

  @override
  String get email => 'Эл. почта';

  @override
  String get empty => 'Пусто';

  @override
  String get emptyInbox => 'Пустые входящие';

  @override
  String get emptyUri =>
      'Ссылка пуста. Пожалуйста, предоставьте действительную динамическую ссылку для продолжения.';

  @override
  String get enableCommentNavigation => 'Enable Comment Navigation';

  @override
  String get enableExperimentalFeatures => 'Enable experimental features';

  @override
  String get enableFeedFab => 'Включить плавающую кнопку в лентах';

  @override
  String get enableFloatingButtonOnFeeds => 'Enable Floating Button On Feeds';

  @override
  String get enableFloatingButtonOnPosts => 'Enable Floating Button On Posts';

  @override
  String get enableInboxNotifications => 'Enable Inbox Notifications';

  @override
  String get enablePostFab => 'Включить плавающую кнопку в сообщениях';

  @override
  String get endOfComments => 'End of comments';

  @override
  String get endSearch => 'Конец поиска';

  @override
  String errorDeletingImage(Object error) {
    return 'There was an error deleting the image: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Не удалось загрузить медиа для отправки: $errorMessage';
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
      'При обработке ссылки произошла ошибка. Она не может быть доступна на вашем инстансе.';

  @override
  String get excessiveApiCallsWarning =>
      'Your feed may be taking a while to load due to keyword filters.';

  @override
  String get expand => 'Раскрыть';

  @override
  String get expandCommentPreview => 'Расширить предпросмотр комментариев';

  @override
  String get expandInformation => 'Расширить информацию';

  @override
  String get expandOptions => 'Развернуть параметры';

  @override
  String get expandPost => 'Развернуть публикацию';

  @override
  String get expandPostPreview => 'Развернуть предпросмотр сообщения';

  @override
  String get expandSpoiler => 'Развернуть спойлер';

  @override
  String get expanded => 'Расширенный';

  @override
  String get experimentalFeatures => 'Experimental Features';

  @override
  String get experimentalFeaturesDescription =>
      'These features are still in development and may be unstable. Use them at your own risk. You must restart Thunder to take effect.';

  @override
  String get exploreInstance => 'Просмотреть инстансы';

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
  String get extraLarge => 'Очень большой';

  @override
  String failedToBlock(Object errorMessage) {
    return 'Не удалось заблокировать : $errorMessage';
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
    return 'Невозможно загрузить заблокированных: $errorMessage';
  }

  @override
  String get failedToLoadVideo => 'Failed to load video. Open link in browser?';

  @override
  String get failedToPerformAction => 'Failed to perform action';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'Не удалось разблокировать: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Failed to update notification settings';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorites => 'Избранные';

  @override
  String get featuredPost => 'Featured Post';

  @override
  String get feed => 'Новости';

  @override
  String get feedBehaviourSettings => 'Новости';

  @override
  String get feedSettings => 'Feed Settings';

  @override
  String get feedTypeAndSorts => 'Тип новостей по умолчанию и сортировка';

  @override
  String get fetchAccountError => 'Не удалось определить аккаунт';

  @override
  String filteringBy(Object entity) {
    return 'Отсортировано по $entity';
  }

  @override
  String get filters => 'Фильтры';

  @override
  String get floatingActionButton => 'Действия летающей кнопки';

  @override
  String get floatingActionButtonInformation =>
      'Thunder имеет полностью настраиваемый интерфейс FAB, поддерживающий несколько жестов.\n- Проведите пальцем вверх, чтобы открыть дополнительные действия FAB.\n- Проведите пальцем вниз/вверх, чтобы скрыть или показать FAB.\n\nЧтобы настроить основные и дополнительные действия для FAB, нажмите и удерживайте одно из действий ниже.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'обозначает длительное нажатие действия FAB.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'обозначает однократное нажатие FAB.';

  @override
  String get fonts => 'Шрифты';

  @override
  String get forward => 'Вперед';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Found compatible app; restart Thunder to connect';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Проведите пальцем в любом месте, чтобы вернуться назад, когда жесты слева направо отключены';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get fullscreenSwipeGestures => 'Fullscreen Swipe Gestures';

  @override
  String get general => 'Общее';

  @override
  String get generalSettings => 'Общие настройки';

  @override
  String get gestures => 'Жесты';

  @override
  String get gettingStarted => 'Начало';

  @override
  String get green => 'Зеленый';

  @override
  String get guestModeFeedSettings => 'Guest Mode Feed Settings';

  @override
  String get guestModeFeedSettingsLabel =>
      'The following settings are only applied to guest accounts. To adjust feed settings for your account, go to Account Settings.';

  @override
  String get havingIssuesWithNotifications =>
      'Having issues with notifications?';

  @override
  String get hidCommunity => 'Скрыть сообщество';

  @override
  String get hidden => 'Скрытый';

  @override
  String get hide => 'Скрыть';

  @override
  String get hideBottomBarOnScroll => 'Hide Bottom Bar on Scroll';

  @override
  String get hideColor => 'Hide Color';

  @override
  String get hideNsfwPostsFromFeed => 'Hide NSFW Posts from Feed';

  @override
  String get hideNsfwPreviews => 'Blur NSFW Previews';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get hideThumbnails => 'Hide Thumbnails';

  @override
  String get hideTopBarOnScroll => 'Hide Top Bar on Scroll';

  @override
  String get hostInstance => 'Host Instance';

  @override
  String get hot => 'Горячее';

  @override
  String get image => 'Изображение';

  @override
  String get imageCachingMode => 'Image Caching Mode';

  @override
  String get imageCachingModeAggressive =>
      'Aggressively cache images (uses more memory)';

  @override
  String get imageCachingModeAggressiveShort => 'Агрессивный';

  @override
  String get imageCachingModeRelaxed =>
      'Let image caches expire (uses less memory but causes images to reload more often)';

  @override
  String get imageCachingModeRelaxedShort => 'Расслабление';

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
  String get importExportSettings => 'Импорт/экспорт настроек';

  @override
  String get importExportThunderSettings => 'Import/Export Thunder Settings';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Import Lemmy account settings';

  @override
  String get importSettings => 'Настройки импорта';

  @override
  String inReplyTo(Object post, Object community) {
    return 'Ответ на $post в $community';
  }

  @override
  String get in_ => 'в';

  @override
  String get inbox => 'Входящие';

  @override
  String get includeCommunity => 'Включить сообщество';

  @override
  String get includeExternalLink => 'Включить внешние ссылки';

  @override
  String get includeImage => 'Включить изображение';

  @override
  String get includePostLink => 'Включить ссылку на публикацию';

  @override
  String get includeText => 'Включить текст';

  @override
  String get includeTitle => 'Включить заголовок';

  @override
  String get information => 'Информация';

  @override
  String instance(num count) {
    return 'Инстанс';
  }

  @override
  String get instanceActions => 'Instance Actions';

  @override
  String instanceEntry(Object username) {
    return 'Instance \'$username\'';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance уже добавлен.';
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
  String get instances => 'Инстансы';

  @override
  String get internetOrInstanceIssues =>
      'Возможно, вы не подключены к Интернету или ваш инстанс в данный момент недоступен.';

  @override
  String get invalidUrl => 'Invalid URL format';

  @override
  String joined(Object x) {
    return 'Joined $x';
  }

  @override
  String get keywordFilterDescription =>
      'Фильтрует сообщения, содержащие любые ключевые слова в заголовке или тексте';

  @override
  String get keywordFilters => 'Фильтры ключевых слов';

  @override
  String get label => 'Label';

  @override
  String get language => 'Язык';

  @override
  String get languageFilters => 'Looking for language filters?';

  @override
  String get languageNotAllowed =>
      'Сообщество, в котором вы публикуете сообщение, не разрешает публиковать сообщения на выбранном вами языке. Попробуйте другой язык.';

  @override
  String get large => 'Большой';

  @override
  String get leftLongSwipe => 'Left Long Swipe';

  @override
  String get leftShortSwipe => 'Left Short Swipe';

  @override
  String get light => 'Светлая';

  @override
  String link(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ссылки',
      one: 'Ссылка',
      zero: 'Ссылок',
    );
    return '$_temp0 ';
  }

  @override
  String get linkActions => 'Действие по ссылкам';

  @override
  String get linkHandlingCustomTabs => 'Open in system browser embedded in-app';

  @override
  String get linkHandlingCustomTabsShort => 'Прямо в приложении';

  @override
  String get linkHandlingExternal => 'Open in system browser externally';

  @override
  String get linkHandlingExternalShort => 'Внешний';

  @override
  String get linkHandlingInApp => 'Use Thunder\'s built-in browser';

  @override
  String get linkHandlingInAppShort => 'В приложении';

  @override
  String get linkPostsUseCompactView => 'Show Compact Link Posts';

  @override
  String get linksBehaviourSettings => 'Ссылки';

  @override
  String loadMorePlural(Object count) {
    return 'Загрузить $count ответов…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'Загрузить $count ответ…';
  }

  @override
  String get loading => 'Загрузка...';

  @override
  String get local => 'Местные';

  @override
  String get localNotifications => 'Local Notifications';

  @override
  String get localOnly => 'Local Only';

  @override
  String get localPosts => 'Местные посты';

  @override
  String get lockPost => 'Закрыть пост';

  @override
  String get locked => 'Заблокировано';

  @override
  String get lockedPost => 'Закрыть доступ к посту';

  @override
  String get logOut => 'Выйти';

  @override
  String get login => 'Войти';

  @override
  String get loginAttemptCanceled => 'Login attempt canceled.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Не удалось войти. Попробуйте еще раз: ($errorMessage)';
  }

  @override
  String get loginSucceeded => 'Вход выполнен.';

  @override
  String get loginToPerformAction =>
      'Вам необходимо войти в систему, чтобы выполнить эту задачу.';

  @override
  String get loginToSeeInbox => 'Войдите, чтобы увидеть свои входящие';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Looking for account-specific feed settings?';

  @override
  String get malformedUri =>
      'Предоставленная вами ссылка имеет неподдерживаемый формат. Пожалуйста, убедитесь, что это действительная ссылка.';

  @override
  String get manageAccounts => 'Управление аккаунтами';

  @override
  String get manageMedia => 'Manage Media';

  @override
  String get markAllAsRead => 'Пометить всё прочитанным';

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
  String get me => 'Я';

  @override
  String get media => 'Media';

  @override
  String get medium => 'Средний';

  @override
  String mention(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Упоминаний',
      one: 'Упоминание',
      zero: 'Упоминаний',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'Меню';

  @override
  String message(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сообщений',
      one: 'Сообщение',
      zero: 'Сообщений',
    );
    return '$_temp0';
  }

  @override
  String get metadataFontScale => 'Metadata Font Scale';

  @override
  String get missingErrorMessage => 'Сообщение об ошибке отсутствует';

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
  String get modLockPost => 'Открыть/закрыть посты';

  @override
  String get modRemoveComment => 'Удалить/вернуть комментарии';

  @override
  String get modRemoveCommunity => 'Удалить/вернуть сообщества';

  @override
  String get modRemovePost => 'Удалить/вернуть посты';

  @override
  String get modTransferCommunity => 'Передача сообщества';

  @override
  String get moderatedCommunities => 'Управляемые сообщества';

  @override
  String get moderates => 'Moderates';

  @override
  String moderator(num count) {
    return 'Модератор';
  }

  @override
  String get moderatorActions => 'Действия модератора';

  @override
  String get modlog => 'Модлог';

  @override
  String get mostComments => 'Большинство комментариев';

  @override
  String get mustBeLoggedIn => 'You need to be logged in';

  @override
  String get mustBeLoggedInComment =>
      'Вы должны войти в систему, чтобы оставлять комментарии';

  @override
  String get mustBeLoggedInPost =>
      'Вам необходимо войти в систему, чтобы создать сообщение';

  @override
  String get names => 'Имена';

  @override
  String get navbarDoubleTapGestures => 'Navbar Double Tap Gestures';

  @override
  String get navbarSwipeGestures => 'Navbar Swipe Gestures';

  @override
  String get navigateDown => 'Следующий комментарий';

  @override
  String get navigateUp => 'Предыдущий комментарий';

  @override
  String get navigation => 'Навигация';

  @override
  String get nestedCommentIndicatorColor => 'Nested Comment Indicator Color';

  @override
  String get nestedCommentIndicatorStyle => 'Nested Comment Indicator Style';

  @override
  String get networkErrorMessage =>
      'Unable to reach the server. Check your connection and try again.';

  @override
  String get never => 'Никогда';

  @override
  String get newComments => 'Новые комментарии';

  @override
  String get newPost => 'Новый пост';

  @override
  String get new_ => 'Новый';

  @override
  String get no => 'Нет';

  @override
  String get noAccountsAdded => 'No accounts have been added';

  @override
  String get noAnonymousInstances => 'No anonymous instances have been added';

  @override
  String get noCommentsFound => 'Нет комментариев';

  @override
  String get noCommunitiesFound => 'Нет сообществ';

  @override
  String get noCommunityBlocks => 'Нет заблокированных сообществ.';

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
  String get noFavoritedCommunities => 'Нет избранных сообществ';

  @override
  String get noImages => 'It looks like you have not uploaded any images.';

  @override
  String get noInstanceBlocks => 'Нет заблокированных инстансов.';

  @override
  String get noItems => 'Нет предметов';

  @override
  String get noKeywordFilters => 'Фильтры ключевых слов не добавлены';

  @override
  String get noLanguage => 'Нет языка';

  @override
  String get noMatrixUserSet => 'No matrix user set';

  @override
  String get noMentions => 'No mentions';

  @override
  String get noMessages => 'No messages';

  @override
  String get noPostsFound => 'Нет постов';

  @override
  String get noProfileBioSet => 'No profile bio set';

  @override
  String get noReferencesToImage =>
      'No posts or comments were found containing this image. However, it may be used elsewhere on the internet.';

  @override
  String get noReplies => 'No replies';

  @override
  String get noResultsFound => 'Результаты не найдены.';

  @override
  String get noSubscriptions => 'Нет подписок';

  @override
  String get noUserBlocks => 'Нет заблокированных пользователей.';

  @override
  String get noUserLabels => 'You have not created any user labels yet';

  @override
  String get noUsersFound => 'Нет пользователей';

  @override
  String get noVisibleComments =>
      'Comments may not be visible because the community is blocked.';

  @override
  String get none => 'Нет';

  @override
  String get normal => 'Нормальный';

  @override
  String get notAvailable => 'N/A';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance не является действительным инстансом Lemmy';
  }

  @override
  String get notValidUrl => 'Недействительный URL-адрес';

  @override
  String get nothingToShare => 'Нечем поделиться';

  @override
  String notifications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Уведомления',
      one: 'Уведомление',
      zero: 'Уведомлений',
    );
    return '$_temp0';
  }

  @override
  String get notificationsBehaviourSettings => 'Уведомления';

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
  String get off => 'выключено';

  @override
  String get offline => 'оффлайн';

  @override
  String get ok => 'OK';

  @override
  String get old => 'Старое';

  @override
  String get on => 'включено';

  @override
  String get onWifi => 'On Wifi';

  @override
  String get onlyModsCanPostInCommunity =>
      'Только модераторы могут публиковать сообщения в этом сообществе';

  @override
  String get open => 'Открыть';

  @override
  String get openAccountSwitcher => 'Открыть переключение аккаунтов';

  @override
  String get openByDefault => 'Открыть по умолчанию';

  @override
  String get openInBrowser => 'Открыть в браузере';

  @override
  String get openInstance => 'Открыть инстанс';

  @override
  String get openLinksInExternalBrowser => 'Open Links in External Browser';

  @override
  String get openLinksInReaderMode => 'Open Links in Reader Mode';

  @override
  String get openSettings => 'Откройте настройки';

  @override
  String get orange => 'Оранжевый';

  @override
  String get originalPoster => 'Original Poster';

  @override
  String get overview => 'Обзор';

  @override
  String get password => 'Пароль';

  @override
  String get pending => 'Ожидание';

  @override
  String performedBy(Object user) {
    return 'Performed by: $user';
  }

  @override
  String get permissionDenied => 'Разрешение не дано';

  @override
  String get permissionDeniedMessage =>
      'Для сохранения этого изображения Thunder требуются некоторые разрешения, которые были отклонены.';

  @override
  String get piefedSupportBeta =>
      'PieFed support is currently in beta.\nNot all features are supported yet.';

  @override
  String get pinPostToCommunity => 'Pin Post to Community';

  @override
  String get pinToCommunity => 'Pin to Community';

  @override
  String get pinned => 'Прикреплено';

  @override
  String get pinnedPostToCommunity => 'Pinned post to community';

  @override
  String get pinnedPostsUseCompactView => 'Show Compact Pinned Posts';

  @override
  String get placeholderText =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  @override
  String get post => 'Пост';

  @override
  String get postActions => 'Post Actions';

  @override
  String get postBehaviourSettings => 'Посты';

  @override
  String get postBody => 'Текст сообщения';

  @override
  String get postBodySettings => 'Настройки тела сообщения';

  @override
  String get postBodySettingsDescription =>
      'Эти настройки влияют на отображение тела сообщения';

  @override
  String get postBodyShowCommunityInstance => 'Show Community Instance';

  @override
  String get postBodyShowUserInstance => 'Show User Instance';

  @override
  String get postBodyViewType => 'Тип представления тела сообщения';

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
  String get postLocked => 'Пост заблокирован. Ответы не допускаются.';

  @override
  String get postMetadataInstructions =>
      'You can customize the metadata information by dragging and dropping the desired information';

  @override
  String get postNSFW => 'Пометить как NSFW';

  @override
  String get postPreview =>
      'Показать предпросмотр публикации с заданными настройками';

  @override
  String get postSavedAsDraft => 'Сообщение сохранено как черновик';

  @override
  String get postShowUserInstance => 'Show User Instance';

  @override
  String get postSwipeActions => 'Post Swipe Actions';

  @override
  String get postSwipeGesturesHint =>
      'Хотите вместо этого использовать кнопки? Измените, какие кнопки отображаются на открытках, в общих настройках.';

  @override
  String get postTags => 'Tags';

  @override
  String get postTagsHelperText => 'Separate tags with commas';

  @override
  String get postTitle => 'Название';

  @override
  String get postTitleBold => 'Bold post titles';

  @override
  String get postTitleFontScale => 'Post Title Font Scale';

  @override
  String get postTitleFontWeight => 'Post Title Weight';

  @override
  String get postTitleFontWeightBold => 'Bold';

  @override
  String get postTitleFontWeightExtraBold => 'Extra bold';

  @override
  String get postTitleFontWeightNormal => 'Normal';

  @override
  String get postTogglePreview => 'Переключить просмотр';

  @override
  String get postURL => 'Ссылка';

  @override
  String get postUploadImageError => 'Не удалось загрузить изображение';

  @override
  String get postViewType => 'Тип просмотра сообщения';

  @override
  String get posts => 'Посты';

  @override
  String get preview => 'Предпросмотр';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile применён успешно!';
  }

  @override
  String get profileBio => 'Profile Bio';

  @override
  String get profileOperationInProgress => 'Profile operation in progress';

  @override
  String get profiles => 'Профили';

  @override
  String get public => 'Публично';

  @override
  String get pureBlack => 'Чистый черный';

  @override
  String get purgedComment => 'Purged Comment';

  @override
  String get purgedCommunity => 'Purged Community';

  @override
  String get purgedPerson => 'Purged Person';

  @override
  String get purgedPost => 'Purged Post';

  @override
  String get purple => 'Фиолетовый';

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
  String get reachedTheBottom => 'Хм. Кажется, вы достигли конца.';

  @override
  String get read => 'Read';

  @override
  String get readAll => 'Прочитать всё';

  @override
  String get readerMode => 'Reader mode';

  @override
  String get reason => 'Причина';

  @override
  String get red => 'Красный';

  @override
  String get reduceAnimations => 'Меньше анимаций';

  @override
  String get reducesAnimations =>
      'Уменьшает количество анимаций, используемых в Thunder';

  @override
  String get refresh => 'Обновить';

  @override
  String get refreshContent => 'Обновить контент';

  @override
  String get removalReason => 'Причина удаления';

  @override
  String get remove => 'Удалить';

  @override
  String get removeAccount => 'Удалить аккаунт';

  @override
  String get removeAsCommunityModerator => 'Remove as Community Moderator';

  @override
  String get removeComment => 'Remove Comment';

  @override
  String get removeFromFavorites => 'Удалить из избранных';

  @override
  String get removeInstance => 'Удалить инстанс';

  @override
  String removeKeyword(Object keyword) {
    return 'Удалить \"$keyword\"?';
  }

  @override
  String get removeKeywordFilter => 'Удалить ключевое слово';

  @override
  String get removePost => 'Удалить пост';

  @override
  String get removeUserData => 'Remove user data';

  @override
  String get removed => 'Удалено';

  @override
  String get removedComment => 'Удаленный комментарий';

  @override
  String get removedCommunity => 'Removed Community';

  @override
  String get removedCommunityFromSubscriptions => 'Отписались от сообщества';

  @override
  String get removedInstanceMod => 'Removed Instance Mod';

  @override
  String get removedModFromCommunity => 'Removed Mod from Community';

  @override
  String get removedPost => 'Удаленный пост';

  @override
  String removedUserAsCommunityModerator(Object username) {
    return 'Removed $username as community moderator';
  }

  @override
  String get reorder => 'Переместить';

  @override
  String reply(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ответы',
      one: 'Ответ',
      zero: 'Ответов',
    );
    return '$_temp0';
  }

  @override
  String get replyColor => 'Reply Color';

  @override
  String get replyNotSupported =>
      'Ответ из этого инстанса в настоящее время пока не поддерживается';

  @override
  String get replyToComment => 'Reply to Comment';

  @override
  String get replyToPost => 'Ответ на пост';

  @override
  String replyingTo(Object author) {
    return 'Ответ $author';
  }

  @override
  String report(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Жалоба о нарушении',
      few: 'Жалобы о нарушении',
      one: 'Жалоба о нарушении',
    );
    return '$_temp0 ';
  }

  @override
  String get reportComment => 'Пожаловаться на комментарий';

  @override
  String get reportPost => 'Report Post';

  @override
  String get reportedComment => 'Reported comment';

  @override
  String get reportedPost => 'Reported post';

  @override
  String get reporter => 'Reporter:';

  @override
  String get requiredField => '*обязательно';

  @override
  String get reset => 'Сбросить';

  @override
  String get resetCommentPreferences => 'Сбросить параметры комментариев';

  @override
  String get resetPostPreferences => 'Сбросить параметры постов';

  @override
  String get resetPreferences => 'Сброс предпочтений';

  @override
  String get resetPreferencesAndData => 'Сбросить настройки и данные';

  @override
  String get restore => 'Восстановить';

  @override
  String get restoreComment => 'Restore Comment';

  @override
  String get restorePost => 'Вернуть пост';

  @override
  String get restoredComment => 'Восстановленный комментарий';

  @override
  String get restoredCommentFromDraft =>
      'Восстановлен комментарий из черновика';

  @override
  String get restoredCommunity => 'Восстановленное сообщество';

  @override
  String get restoredPost => 'Restored Post';

  @override
  String get restoredPostFromDraft => 'Восстановлен пост из черновика';

  @override
  String get retry => 'Ещё раз';

  @override
  String get rightLongSwipe => 'Right Long Swipe';

  @override
  String get rightShortSwipe => 'Right Short Swipe';

  @override
  String get save => 'Сохранить';

  @override
  String get saveColor => 'Save Color';

  @override
  String get saveSettings => 'Сохранить настройки';

  @override
  String get saved => 'Сохранено';

  @override
  String get scaled => 'Масштабированный';

  @override
  String get scrapeMissingLinkPreviews => 'Scrape Missing Link Previews';

  @override
  String get screenReaderProfile => 'Профиль чтения экрана';

  @override
  String get screenReaderProfileDescription =>
      'Оптимизирует Thunder для программ чтения с экрана, уменьшая количество элементов и удаляя потенциально конфликтующие жесты.';

  @override
  String get search => 'Поиск';

  @override
  String get searchByText => 'Поиск по тексту';

  @override
  String get searchByUrl => 'Поиск по ссылке';

  @override
  String get searchComments => 'Поиск комментариев';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return 'Поиск комментариев с помощью $instance';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return 'Поиск сообществ с $instance';
  }

  @override
  String searchInstance(Object instance) {
    return 'Поиск $instance';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return 'Search for instances federated with $instance';
  }

  @override
  String get searchPostSearchType => 'Выберите тип поиска сообщений';

  @override
  String searchPostsFederatedWith(Object instance) {
    return 'Поиск постов с $instance';
  }

  @override
  String get searchTerm => 'Поиск термина';

  @override
  String searchUsersFederatedWith(Object instance) {
    return 'Поиск пользователей с $instance';
  }

  @override
  String get selectAccountToCommentAs => 'Select account to comment as';

  @override
  String get selectAccountToPostAs => 'Select account to post as';

  @override
  String get selectAll => 'Select all';

  @override
  String get selectCommunity => 'Выберите сообщество';

  @override
  String get selectFeedType => 'Выберите тип новостей';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get selectRecipient => 'Select recipient';

  @override
  String get selectSearchType => 'Выберите тип поиска';

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
    return 'Ошибка сервера была обнаружена при получении дополнительных комментариев: $message';
  }

  @override
  String get setAction => 'Выбрать действие';

  @override
  String get setLongPress => 'Установить как действие при длительном нажатии';

  @override
  String get setShortPress => 'Установить как действие короткого нажатия';

  @override
  String get settingOverrideLabel =>
      'These settings override Thunder\'s default settings.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'Настройки типа $settingType пока не поддерживаются.';
  }

  @override
  String get settings => 'Настройки';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'Settings were successfully saved to \'$savedFilePath\'';
  }

  @override
  String get settingsFeedCards =>
      'Эти настройки применяются к карточкам в основной ленте, действия доступны всегда при фактическом открытии постов.';

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
  String get settingsPageAccessibility => 'Специальные возможности';

  @override
  String get settingsPageAccount => 'Аккаунт';

  @override
  String get settingsPageAccountBlocks => 'Чёрные списки';

  @override
  String get settingsPageAccountLanguages => 'Discussion Languages';

  @override
  String get settingsPageAccountMedia => 'Manage Media';

  @override
  String get settingsPageAppearance => 'Внешний вид';

  @override
  String get settingsPageAppearanceComments => 'Комментарии';

  @override
  String get settingsPageAppearancePosts => 'Посты';

  @override
  String get settingsPageAppearanceTheming => 'Темы';

  @override
  String get settingsPageDebug => 'Отладка';

  @override
  String get settingsPageFilters => 'Фильтры';

  @override
  String get settingsPageFloatingActionButton => 'Floating Action Button';

  @override
  String get settingsPageGeneral => 'Главное';

  @override
  String get settingsPageGestures => 'Жесты';

  @override
  String get settingsPageUserLabels => 'User Labels';

  @override
  String get settingsPageVideo => 'Видео';

  @override
  String get share => 'Поделиться';

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
  String get shareLink => 'Поделиться ссылкой';

  @override
  String get shareMedia => 'Поделиться медиа';

  @override
  String get shareMediaLink => 'Share Media Link';

  @override
  String get shareOriginalLink => 'Share Original Link';

  @override
  String get sharePost => 'Поделиться постом';

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
  String get showAll => 'Показать все';

  @override
  String get showBotAccounts => 'Показать аккаунты ботов';

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
      'Уведомлять о новых релизах из GitHub';

  @override
  String get showLess => 'Показать меньше';

  @override
  String get showMore => 'Показать больше';

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
  String get showPassword => 'Показать пароль';

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
  String get showReadPosts => 'Показать прочитанные сообщения';

  @override
  String get showSavedContent => 'Show saved content';

  @override
  String get showScoreCounters => 'Display User Scores';

  @override
  String get showScores => 'Показать оценки сообщений/комментариев';

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
  String get sidebar => 'Боковая панель';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Дважды коснитесь нижней панели навигации, чтобы открыть боковую панель';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Проведите пальцем по нижней панели навигации, чтобы открыть боковую панель';

  @override
  String get small => 'Маленький';

  @override
  String get somethingWentWrong => 'Упс! Что-то пошло не так!';

  @override
  String get sortBy => 'Сортировать по';

  @override
  String get sortByTop => 'Сортировать по топу';

  @override
  String get sortOptions => 'Опции сортировки';

  @override
  String get spoiler => 'Спойлер';

  @override
  String get standard => 'Стандартный';

  @override
  String get stats => 'Статистика';

  @override
  String get status => 'Статус';

  @override
  String get submit => 'Отправить';

  @override
  String get subscribe => 'Подписаться';

  @override
  String get subscribeToCommunity => 'Subscribe to Community';

  @override
  String get subscribed => 'Подписано';

  @override
  String get subscriptionRequestSent => 'Subscription request sent';

  @override
  String get subscriptions => 'Подписки';

  @override
  String successfullyBannedUser(Object username) {
    return 'Banned $username';
  }

  @override
  String get successfullyBlocked => 'Заблокировано.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return 'Заблокировано $communityName';
  }

  @override
  String successfullyBlockedUser(Object username) {
    return 'Заблокирован $username';
  }

  @override
  String successfullyUnbannedUser(Object username) {
    return 'Unbanned $username';
  }

  @override
  String get successfullyUnblocked => 'Разблокировано.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return 'Разблокировано $communityName';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return 'Разблокирован $username';
  }

  @override
  String get suchAs => 'such as';

  @override
  String get suggestedTitle => 'Предлагаемое название';

  @override
  String switchedAccount(Object username) {
    return 'Switched to $username';
  }

  @override
  String get system => 'Система';

  @override
  String get systemDarkMode => 'Pure Black';

  @override
  String get systemDarkModeDescription =>
      'Enable pure black theme for dark mode';

  @override
  String get tabletMode => 'Tablet Mode (2-column view)';

  @override
  String get tapToExit => 'Вернитесь дважды, чтобы выйти';

  @override
  String get tappableAuthorCommunity => 'Tappable Authors & Communities';

  @override
  String get teal => 'Бирюзовый';

  @override
  String get testBackgroundNotificationDescription =>
      'Thunder will close itself and then attempt to generate a notification in the background. (It will take at least 15 minutes.)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'Thunder will ask the notification server to send a delayed notification and then close itself. (It may take a few minutes.)';

  @override
  String get text => 'Текст';

  @override
  String get textActions => 'Text Actions';

  @override
  String get theme => 'Тема';

  @override
  String get themeAccentColor => 'Акцентные цвета';

  @override
  String get themePrimary => 'Theme Primary';

  @override
  String get themeSecondary => 'Theme Secondary';

  @override
  String get themeTertiary => 'Theme Tertiary';

  @override
  String get theming => 'Темы';

  @override
  String get thickness => 'Толщина';

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
      'Ошибка: тайм-аут при попытке получить комментарии';

  @override
  String get timeoutErrorMessage => 'Был тайм-аут ожидания ответа.';

  @override
  String get timeoutSaveComment =>
      'Ошибка: тайм-аут при попытке сохранить комментарий';

  @override
  String get timeoutSavingPost =>
      'Ошибка: тайм-аут при попытке сохранить сообщение.';

  @override
  String get timeoutUpvoteComment =>
      'Ошибка: тайм-аут при попытке проголосовать за комментарий';

  @override
  String get timeoutVotingPost =>
      'Ошибка: тайм-аут при попытке проголосовать за публикацию.';

  @override
  String get toggelRead => 'Переключить чтение';

  @override
  String get top => 'Топ';

  @override
  String get topAll => 'Топ за всё время';

  @override
  String get topDay => 'Популярно сегодня';

  @override
  String get topHour => 'Топ за час';

  @override
  String get topMonth => 'Популярно за месяц';

  @override
  String get topNineMonths => 'Топ за 9 месяцев';

  @override
  String get topSixHour => 'Топ за 6 часов';

  @override
  String get topSixMonths => 'Топ за полгода';

  @override
  String get topThreeMonths => 'Топ за 3 месяца';

  @override
  String get topTwelveHour => 'Топ за 12 часов';

  @override
  String get topWeek => 'Популярно за неделю';

  @override
  String get topYear => 'Популярно за год';

  @override
  String totalComments(Object x) {
    return '$x Comments';
  }

  @override
  String totalPosts(Object x) {
    return '$x Posts';
  }

  @override
  String get totp => 'TOTP (необязательно)';

  @override
  String get transferredModToCommunity => 'Transferred Community';

  @override
  String get translationsMayNotBeComplete =>
      'Обратите внимание, что переводы могут быть неполными';

  @override
  String get trendingCommunities => 'Популярные сообщества';

  @override
  String get trySearchingFor => 'Try searching for...';

  @override
  String get unableToFindCommunity => 'Не удалось найти сообщество';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'Unable to find community \'$communityName\'';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Unable to find the selected community on the selected user\'s instance.';

  @override
  String get unableToFindInstance => 'Не удалось найти инстанс';

  @override
  String get unableToFindLanguage => 'Невозможно найти язык';

  @override
  String get unableToFindPost => 'Unable to find post';

  @override
  String get unableToFindUser => 'Не удалось найти пользователя';

  @override
  String unableToFindUserName(Object username) {
    return 'Unable to find user \'$username\'';
  }

  @override
  String get unableToLoadImage => 'Невозможно загрузить изображение';

  @override
  String unableToLoadImageFrom(Object domain) {
    return 'Невозможно загрузить изображение с $domain';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return 'Невозможно загрузить $instance';
  }

  @override
  String get unableToLoadPost => 'Unable to load post';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return 'Невозможно загрузить посты из $instance';
  }

  @override
  String get unableToLoadReplies => 'Не удалось загрузить больше ответов.';

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
  String get unblockInstance => 'Разблокировать инстанс';

  @override
  String get unblockUser => 'Unblock User';

  @override
  String get unblockUserInstance => 'Unblock User Instance';

  @override
  String get understandEnable => 'I Understand, Enable';

  @override
  String get unexpectedError => 'Неожиданная ошибка';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get unfeaturedPost => 'Unfeatured Post';

  @override
  String get unhidCommunity => 'Unhid Community';

  @override
  String get unhide => 'Раскрыть';

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
  String get unlockPost => 'Открыть пост';

  @override
  String get unlockedPost => 'Unlocked Post';

  @override
  String get unpinFromCommunity => 'Unpin from Community';

  @override
  String get unpinPostFromCommunity => 'Unpin Post from Community';

  @override
  String get unpinnedPostFromCommunity => 'Unpinned post from community';

  @override
  String get unreachable => 'Недоступно';

  @override
  String get unresolved => 'Unresolved';

  @override
  String get unsubscribe => 'Отписаться';

  @override
  String get unsubscribeFromCommunity => 'Unsubscribe from Community';

  @override
  String get unsubscribePending => 'Отписаться (подписка в ожидании)';

  @override
  String get unsubscribed => 'Отписались';

  @override
  String get untitledCommentDraft => 'Untitled comment draft';

  @override
  String get untitledPostDraft => 'Untitled post draft';

  @override
  String updateReleased(Object version) {
    return 'Вышло обновление: $version';
  }

  @override
  String get uploadImage => 'Загрузка изображения';

  @override
  String uploadedDate(Object date) {
    return 'Uploaded: $date';
  }

  @override
  String get upvote => 'Против';

  @override
  String get upvoteColor => 'Upvote Color';

  @override
  String get upvoted => 'Upvoted';

  @override
  String get uriNotSupported =>
      'Этот тип ссылки на данный момент не поддерживается.';

  @override
  String get url => 'Ссылка';

  @override
  String get useAdvancedShareSheet => 'Use Advanced Share Sheet';

  @override
  String get useApplePushNotifications => 'Use APNs Notifications';

  @override
  String get useApplePushNotificationsDescription =>
      'Uses Apple\'s Push Notification service';

  @override
  String get useCompactView =>
      'Включить для небольших постов, отключить для больших.';

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
    return 'Использовать предложенное название: $title';
  }

  @override
  String get useUnifiedPushNotifications => 'Use UnifiedPush Notifications';

  @override
  String get useUnifiedPushNotificationsDescription =>
      'Requires a compatible app';

  @override
  String get user => 'Пользователь';

  @override
  String get userActions => 'Действия пользователя';

  @override
  String userEntry(Object username) {
    return 'User \'$username\'';
  }

  @override
  String get userFormat => 'Формат пользователя';

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
  String get userNotLoggedIn => 'Пользователь не авторизован';

  @override
  String get userProfiles => 'Профили пользователей';

  @override
  String get userSettingDescription =>
      'Эти настройки синхронизируются с вашим аккаунтом Lemmy и применяются только к каждому аккаунту.';

  @override
  String get userStyle => 'User Style';

  @override
  String get username => 'Имя пользователя';

  @override
  String get usernameFormattingRedirect => 'Looking for username formatting?';

  @override
  String get users => 'Пользователи';

  @override
  String versionNumber(Object version) {
    return 'Версия $version';
  }

  @override
  String get video => 'Видео';

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
  String get viewAll => 'Посмотреть все';

  @override
  String get viewAllComments => 'Показать все комментарии';

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
  String get visitCommunity => 'Посетите сообщество';

  @override
  String get visitCommunityInstance => 'Visit Community Instance';

  @override
  String get visitInstance => 'Посетите инстанс';

  @override
  String get visitUserInstance => 'Visit User Instance';

  @override
  String get visitUserProfile => 'Посетить профиль пользователя';

  @override
  String get warning => 'Предупреждение';

  @override
  String xDownvotes(Object x) {
    return '$x против';
  }

  @override
  String xScore(Object x) {
    return '$x очков';
  }

  @override
  String xUpvotes(Object x) {
    return '$x за';
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
  String get yes => 'Да';

  @override
  String get youMustSelectAJsonFile => 'You must select a .json file.';
}
