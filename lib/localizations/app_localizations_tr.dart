// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get about => 'Hakkında';

  @override
  String get accept => 'Accept';

  @override
  String get accessibility => 'Erişilebilirlik';

  @override
  String get accessibilityProfilesDescription =>
      'Erişilebilirlik profilleri, belirli bir erişilebilirlik gereksinimini karşılamak için birkaç ayarı aynı anda uygulamaya olanak sağlar.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hesaplar',
      one: 'Hesap',
      zero: 'Hesap',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'Hesap Doğum Günü $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'Hesap ayarlarınız aşağıdaki ayarların üzerine yazılır.';

  @override
  String get accountSettings => 'Hesap Ayarları';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'Lemmy account settings exported successfully to $savedFilePath!';
  }

  @override
  String get accountSettingsImportedSuccessfully =>
      'Lemmy account settings imported successfully!';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return 'Seçilen yorum \'$instance\' üzerinde bulunamadı. Önceki hesaba geri dönülüyor.';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'Seçilen gönderi \'$instance\' üzerinde bulunamadı. Önceki hesaba geri dönülüyor.';
  }

  @override
  String get actionColors => 'Eylem Renkleri';

  @override
  String get actionColorsRedirect => 'Renkleri özelleştirmek mi istiyorsunuz?';

  @override
  String get actions => 'Eylemler';

  @override
  String get active => 'Aktif';

  @override
  String get activity => 'Activity';

  @override
  String get add => 'Ekle';

  @override
  String get addAccount => 'Hesap Ekle';

  @override
  String get addAccountToSeeProfile => 'Hesabınızı görmek için giriş yapın.';

  @override
  String get addAnonymousInstance => 'Anonim Örnek Ekle';

  @override
  String get addAsCommunityModerator => 'Add as Community Moderator';

  @override
  String get addDiscussionLanguage => 'Dil Ekle';

  @override
  String get addKeywordFilter => 'Anahtar Kelime Ekle';

  @override
  String get addOriginalPostBody => 'Add original post body?';

  @override
  String get addToFavorites => 'Favorilere ekle';

  @override
  String get addUserLabel => 'Kullanıcı Etiketi Ekle';

  @override
  String get addedCommunityToSubscriptions => 'Topluluğa abone olundu';

  @override
  String get addedInstanceMod => 'Eklenen Örnek Mod';

  @override
  String get addedModToCommunity => 'Topluluğa Mod Eklendi';

  @override
  String get admin => 'Yönetici';

  @override
  String get advanced => 'İleri düzey';

  @override
  String ago(Object time) {
    return '$time önce';
  }

  @override
  String get all => 'Hepsi';

  @override
  String get allPosts => 'Tüm Gönderiler';

  @override
  String get allowOpenSupportedLinks =>
      'Uygulamanın desteklenen bağlantıları açmasına izin ver.';

  @override
  String get alreadyPostedTo => 'Zaten gönderildi';

  @override
  String get altText => 'Alt Text';

  @override
  String get alternateSources => 'Alternate Sources';

  @override
  String get always => 'Her zaman';

  @override
  String andXMore(Object count) {
    return 've $count daha fazla';
  }

  @override
  String get animations => 'Animasyonlar';

  @override
  String get anonymous => 'Anonim';

  @override
  String get anonymousInstances => 'Anonymous Instances';

  @override
  String get appLanguage => 'Uygulama Dili';

  @override
  String get appearance => 'Görünüm';

  @override
  String get applePushNotificationService => 'Apple Push Bildirim Servisi';

  @override
  String get applied => 'Uygulanan';

  @override
  String get apply => 'Uygula';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return 'Sistem tarafından bildirimlere izin verilir: $yesOrNo';
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
  String get back => 'Geri';

  @override
  String get backButton => 'Geri düğmesi';

  @override
  String get backToTop => 'Başa Dön';

  @override
  String get backgroundCheckWarning =>
      'Bildirim kontrolünün ekstra pil tüketimine neden olacağını unutmayın.';

  @override
  String get banFromCommunity => 'Ban from Community';

  @override
  String get bannedUser => 'Yasaklanmış Kullanıcı';

  @override
  String get bannedUserFromCommunity => 'Topluluktan Yasaklanan Kullanıcı';

  @override
  String get base => 'Taban';

  @override
  String get block => 'Block';

  @override
  String get blockCommunity => 'Blok Topluluğu';

  @override
  String get blockCommunityInstance => 'Block Community Instance';

  @override
  String get blockInstance => 'Blok Örneği';

  @override
  String get blockManagement => 'Blok Yönetimi';

  @override
  String get blockSettingLabel => 'Kullanıcı/Topluluk/Örnek Engelleri';

  @override
  String get blockUser => 'Kullanıcıyı Engelle';

  @override
  String get blockUserInstance => 'Block User Instance';

  @override
  String get blockedCommunities => 'Engellenmiş Topluluklar';

  @override
  String get blockedInstances => 'Engellenmiş Örnekler';

  @override
  String get blockedUsers => 'Engellenen Kullanıcılar';

  @override
  String get blue => 'Mavi';

  @override
  String get bold => 'Cesur';

  @override
  String get boldCommunityName => 'Cesur Topluluk Adı';

  @override
  String get boldInstanceName => 'Kalın Örnek İsmi';

  @override
  String get boldUserName => 'Cesur Kullanıcı Adı';

  @override
  String get bot => 'Bot';

  @override
  String get browserMode => 'Bağlantı işleme';

  @override
  String browsingAnonymously(Object instance) {
    return 'Şu anda $instance sitesinde anonim olarak geziniyorsunuz.';
  }

  @override
  String get cancel => 'İptal';

  @override
  String get cannotReportOwnComment =>
      'Kendi yorumunuz için bir rapor sunamazsınız.';

  @override
  String get cantBlockAdmin => 'Bir örnek yöneticisini engelleyemezsiniz.';

  @override
  String get cantBlockYourself => 'Kendini engelleyemezsin.';

  @override
  String get cardPostCardMetadataItems => 'Kart Görünümü Meta Verisi';

  @override
  String get cardView => 'Kart Görünümü';

  @override
  String get cardViewDescription =>
      'Kart görünümünü ayarları ayarlamak için etkinleştirin';

  @override
  String get cardViewSettings => 'Kart Görünümü Ayarları';

  @override
  String get changeAccountSettingsFor => 'Hesap ayarlarını değiştirin için';

  @override
  String get changeNotificationSettings => 'Bildirim ayarlarını değiştir...';

  @override
  String get changePassword => 'Şifre Değiştir';

  @override
  String get changePasswordWarning =>
      'Şifrenizi değiştirmek için, örnek siteye yönlendirileceksiniz. \n\nDevam etmek istediğinizden emin misiniz?';

  @override
  String get changeSort => 'Sıralamayı Değiştir';

  @override
  String clearCache(Object cacheSize) {
    return 'Önbelleği Temizle ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Clear Cache';

  @override
  String get clearDatabase => 'Veritabanını Temizle';

  @override
  String get clearPreferences => 'Tercihleri Temizle';

  @override
  String get clearSearch => 'Aramayı Temizle';

  @override
  String get clearedCache => 'Önbellek başarıyla temizlendi.';

  @override
  String get clearedDatabase =>
      'Yerel veritabanı temizlendi. Yeni değişikliklerin etkili olması için Thunder\'ı yeniden başlatın.';

  @override
  String get clearedUserPreferences => 'Tüm kullanıcı tercihleri temizlendi';

  @override
  String get close => 'Kapat';

  @override
  String get collapse => 'Çökme';

  @override
  String get collapseCommentPreview => 'Yorum Önizlemesini Daralt';

  @override
  String get collapseInformation => 'Bilgi Çöküşü';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Çöktüğünde Üst Yorumu Gizle';

  @override
  String get collapsePost => 'Gönderiyi çökert';

  @override
  String get collapsePostPreview => 'Gönderi Önizlemesini Daralt';

  @override
  String get collapseSpoiler => 'Spoiler\'ı Çökert';

  @override
  String get color => 'Renk';

  @override
  String get colorizeCommunityName => 'Topluluk Adını Renklendir';

  @override
  String get colorizeInstanceName => 'Örnek İsmi Renklendir';

  @override
  String get colorizeUserName => 'Kullanıcı Adını Renklendir';

  @override
  String get colors => 'Renkler';

  @override
  String get combineCommentScores => 'Yorum Puanlarını Birleştir';

  @override
  String get combineCommentScoresLabel => 'Yorum Puanlarını Birleştir';

  @override
  String get combineNavAndFab => 'FAB ve Navigasyon Düğmelerini Birleştirin';

  @override
  String get combineNavAndFabDescription =>
      'Yüzen İşlem Düğmesi, navigasyon düğmeleri arasında gösterilecektir.';

  @override
  String get comfortable => 'Rahat';

  @override
  String get comment => 'Yorum';

  @override
  String get commentBehaviourSettings => 'Yorumlar';

  @override
  String get commentFontScale => 'Yorum İçeriği Yazı Tipi Ölçeği';

  @override
  String get commentPreview =>
      'Verilen ayarlarla yorumların bir önizlemesini göster';

  @override
  String get commentReported => 'Yorum inceleme için işaretlendi.';

  @override
  String get commentSavedAsDraft => 'Taslak olarak yorum kaydedildi';

  @override
  String get commentShowUserAvatar => 'Kullanıcı Avatarını Göster';

  @override
  String get commentShowUserInstance => 'Kullanıcı Örneğini Göster';

  @override
  String get commentSortType => 'Yorum Sıralama Türü';

  @override
  String get commentSwipeActions => 'Yorum Kaydırma Eylemleri';

  @override
  String get commentSwipeGesturesHint =>
      'Düğmeleri kullanmayı mı düşünüyorsunuz? Genel ayarlarda yorumlar bölümünü etkinleştirin.';

  @override
  String get comments => 'Yorumlar';

  @override
  String get communities => 'Topluluklar';

  @override
  String get community => 'Topluluk';

  @override
  String get communityActions => 'Topluluk Eylemleri';

  @override
  String communityEntry(Object community) {
    return '\'Topluluk \'$community\'';
  }

  @override
  String get communityFormat => 'Topluluk Formatı';

  @override
  String get communityNameColor => 'Topluluk Adı Rengi';

  @override
  String get communityNameThickness => 'Topluluk Adı Kalınlığı';

  @override
  String get communityStyle => 'Topluluk Stili';

  @override
  String get compact => 'Kompakt';

  @override
  String get compactPostCardMetadataItems => 'Kompakt Görünüm Meta Verileri';

  @override
  String get compactView => 'Kompakt Görünüm';

  @override
  String get compactViewDescription =>
      'Ayarları ayarlamak için kompakt görünümü etkinleştirin';

  @override
  String get compactViewSettings => 'Kompakt Görünüm Ayarları';

  @override
  String get condensed => 'Yoğunlaştırılmış';

  @override
  String get confirm => 'Onayla';

  @override
  String get confirmLogOutBody => 'Çıkış yapmak istediğinize emin misiniz?';

  @override
  String get confirmLogOutTitle => 'Çıkış Yap?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Tüm mesajları okundu olarak işaretlemek istediğinize emin misiniz?';

  @override
  String get confirmMarkAllAsReadTitle => 'Tümünü Okundu Olarak İşaretle?';

  @override
  String get confirmResetCommentPreferences =>
      'Bu, tüm yorum tercihlerini sıfırlayacak. Devam etmek istediğinizden emin misiniz?';

  @override
  String get confirmResetPostPreferences =>
      'Bu, tüm gönderi tercihlerini sıfırlayacak. Devam etmek istediğinizden emin misiniz?';

  @override
  String get confirmUnsubscription =>
      'Abonelikten çıkmak istediğinize emin misiniz?';

  @override
  String connectedToUnifiedPushDistributorApp(Object app) {
    return '$app ile bağlandı.';
  }

  @override
  String get contentManagement => 'İçerik Yönetimi';

  @override
  String get contentWarning => 'Content Warning';

  @override
  String get controversial => 'Tartışmalı';

  @override
  String get copiedToClipboard => 'Panoya kopyalandı';

  @override
  String get copy => 'Kopyala';

  @override
  String get copyComment => 'Yorumu Kopyala';

  @override
  String get copySelected => 'Seçileni kopyala';

  @override
  String get copyText => 'Metin Kopyala';

  @override
  String get couldNotDetermineCommentDelete =>
      'Hata: Yorumu silmek için gönderi belirlenemedi.';

  @override
  String get couldNotDeterminePostComment =>
      'Hata: Yorum yapılacak gönderi belirlenemedi.';

  @override
  String get couldntCreateReport =>
      'Yorum raporunuz şu anda gönderilemedi. Lütfen daha sonra tekrar deneyin.';

  @override
  String get couldntFindPost =>
      'İstenilen gönderi yüklenemiyor. Silinmiş veya kaldırılmış olabilir.';

  @override
  String countComments(Object count) {
    return '$count Yorum';
  }

  @override
  String countLocalSubscribers(Object count) {
    return '$count Yerel Aboneler';
  }

  @override
  String countPosts(Object count) {
    return '$count Gönderi';
  }

  @override
  String countSubscribers(Object count) {
    return '$count Abone';
  }

  @override
  String countUsers(Object count) {
    return '$count kullanıcı';
  }

  @override
  String countUsersActiveDay(Object count) {
    return '$count kullanıcı/gün';
  }

  @override
  String countUsersActiveHalfYear(Object count) {
    return '$count kullanıcı/6 ay';
  }

  @override
  String countUsersActiveMonth(Object count) {
    return '$count kullanıcı/ay';
  }

  @override
  String countUsersActiveWeek(Object count) {
    return '$count kullanıcı/hafta';
  }

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get createComment => 'Yorum Oluştur';

  @override
  String get createNewCrossPost => 'Yeni çapraz gönderi oluştur';

  @override
  String get createPost => 'Gönderi Oluştur';

  @override
  String created(Object date) {
    return 'Oluşturulma tarihi $date';
  }

  @override
  String get createdToday => 'Bugün Oluşturuldu';

  @override
  String get creator => 'Yaratıcı';

  @override
  String crossPostedFrom(Object postUrl) {
    return '$postUrl adresinden paylaşıldı.';
  }

  @override
  String get crossPostedTo => 'Çapraz yayınlandı';

  @override
  String get currentLongPress => 'Uzun basma olarak ayarlandı';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Mevcut bildirim modu: $mode';
  }

  @override
  String get currentSinglePress => 'Tek basılı olarak ayarlandı';

  @override
  String get customizeSwipeActions =>
      'Kaydırma eylemlerini özelleştir (değiştirmek için dokunun)';

  @override
  String get dangerZone => 'Tehlike Bölgesi';

  @override
  String get dark => 'Karanlık';

  @override
  String get databaseExportWarning =>
      'Veritabanı, Lemmy hesabınızla ilgili hassas bilgiler içerebilir. Eğer onu dışa aktarırsanız, kimseyle paylaşmamalısınız. Devam etmek istiyor musunuz?';

  @override
  String databaseExportedSuccessfully(Object savedFilePath) {
    return 'Veritabanı başarıyla \'$savedFilePath\' konumuna aktarıldı.';
  }

  @override
  String get databaseImportedSuccessfully =>
      'Veritabanı başarıyla içe aktarıldı!';

  @override
  String get databaseNotExportedSuccessfully =>
      'Veritabanı başarıyla dışa aktarılamadı veya işlem iptal edildi.';

  @override
  String get databaseNotImportedSuccessfully =>
      'Veritabanı başarıyla içe aktarılmadı veya işlem iptal edildi.';

  @override
  String get dateFormat => 'Tarih Formatı';

  @override
  String get debug => 'Hata ayıklama';

  @override
  String get debugDescription =>
      'Aşağıdaki hata ayıklama ayarları sadece sorun giderme amaçları için kullanılmalıdır.';

  @override
  String get debugNotificationsDescription =>
      'Bildirimlerle ilgili sorunları gidermek için aşağıdaki seçenekleri kullanın.';

  @override
  String get decline => 'Decline';

  @override
  String get defaultColor => 'Varsayılan';

  @override
  String get defaultCommentSortType => 'Varsayılan Yorum Sıralama Türü';

  @override
  String get defaultFeedSortType => 'Varsayılan Besleme Sıralama Türü';

  @override
  String get defaultFeedType => 'Varsayılan Besleme Türü';

  @override
  String get delete => 'Sil';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountDescription =>
      'Hesabınızı kalıcı olarak silmek için, örnek siteye yönlendirileceksiniz. \n\nDevam etmek istediğinizden emin misiniz?';

  @override
  String get deleteComment => 'Delete Comment';

  @override
  String get deleteImageConfirmMessage =>
      'Are you sure you want to delete this image?';

  @override
  String get deleteImageConfirmTitle => 'Delete?';

  @override
  String get deleteLocalDatabase => 'Yerel Veritabanını Sil';

  @override
  String get deleteLocalDatabaseDescription =>
      'Bu eylem, yerel veritabanını kaldıracak ve sizi tüm hesaplarınızdan çıkaracaktır.\n\nDevam etmek istediğinizden emin misiniz?';

  @override
  String get deleteLocalPreferences => 'Yerel Tercihleri Sil';

  @override
  String get deleteLocalPreferencesDescription =>
      'Bu, Thunder\'daki tüm kullanıcı tercihlerinizi ve ayarlarınızı silecektir.\n\nDevam etmek ister misiniz?';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get deleteUserLabelConfirmation =>
      'Are you sure you want to delete the label?';

  @override
  String get deleted => 'Deleted';

  @override
  String get deletedByCreator => 'yaratıcı tarafından silindi';

  @override
  String get deletedByModerator => 'moderatör tarafından silindi';

  @override
  String get deselectUndeterminedWarning =>
      'Belirsiz\'i seçimi kaldırırsanız, çoğu içeriği göremezsiniz.';

  @override
  String detailedReason(Object reason) {
    return 'Sebep: $reason';
  }

  @override
  String get dimReadPosts => 'Gönderileri Oku';

  @override
  String get disable => 'Devre dışı bırak';

  @override
  String get disablePushNotifications => 'Bildirimleri Kapat';

  @override
  String get disabled => 'Engelli';

  @override
  String get discussionLanguages => 'Tartışma Dilleri';

  @override
  String get discussionLanguagesTooltip =>
      'İçerik, seçilen dillere göre filtrelenmiştir.';

  @override
  String get dismissRead => 'Okuma İptal Et';

  @override
  String get displayName => 'Görünen İsim';

  @override
  String get displayUserScore => 'Kullanıcı Skorlarını Göster (Karma).';

  @override
  String get dividerAppearance => 'Bölücü Görünümü';

  @override
  String get doNotShowAgain => 'Bir Daha Gösterme';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Birden fazla uyumlu uygulama bulundu; lütfen sadece birini yükleyin.';

  @override
  String get downloadingMedia => 'Medya indiriliyor ve paylaşılıyor...';

  @override
  String get downvote => 'Aşağı oyla';

  @override
  String get downvoteColor => 'Aşağı Oy Rengi';

  @override
  String get downvoted => 'Oy aşağı';

  @override
  String get downvotesDisabled => 'Bu durumda eksilenme özelliği kapalıdır.';

  @override
  String get edit => 'Düzenle';

  @override
  String get editComment => 'Yorumu Düzenle';

  @override
  String get editPost => 'Gönderiyi Düzenle';

  @override
  String get email => 'E-posta';

  @override
  String get empty => 'Boş';

  @override
  String get emptyInbox => 'Boş Gelen Kutusu';

  @override
  String get emptyUri =>
      'Bağlantı boş. Lütfen devam etmek için geçerli bir dinamik bağlantı sağlayın.';

  @override
  String get enableCommentNavigation => 'Yorum Navigasyonunu Etkinleştir';

  @override
  String get enableExperimentalFeatures => 'Deneysel özellikleri etkinleştir';

  @override
  String get enableFeedFab => 'Beslemelerde Yüzen Düğmeyi Etkinleştir';

  @override
  String get enableFloatingButtonOnFeeds =>
      'Beslemelerde Yüzen Düğmeyi Etkinleştir';

  @override
  String get enableFloatingButtonOnPosts =>
      'Gönderilerde Yüzen Düğmeyi Etkinleştir';

  @override
  String get enableInboxNotifications =>
      'Gelen Kutusu Bildirimlerini Etkinleştir';

  @override
  String get enablePostFab => 'Gönderilerde Yüzen Düğmeyi Etkinleştir';

  @override
  String get endOfComments => 'End of comments';

  @override
  String get endSearch => 'Aramayı Sonlandır';

  @override
  String errorDeletingImage(Object error) {
    return 'There was an error deleting the image: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Medya dosyasını paylaşmak için indirilemedi: $errorMessage';
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
      'Yanıtı okundu olarak işaretleme hatası oluştu.';

  @override
  String get errorMarkingReplyUnread =>
      'Yanıtı okunmadı olarak işaretleme hatası oluştu.';

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
      'Bağlantı işlenirken bir hata oluştu. Bu, sizin örneğinizde mevcut olmayabilir.';

  @override
  String get excessiveApiCallsWarning =>
      'Your feed may be taking a while to load due to keyword filters.';

  @override
  String get expand => 'Genişle';

  @override
  String get expandCommentPreview => 'Yorum Önizlemesini Genişlet';

  @override
  String get expandInformation => 'Bilgiyi Genişlet';

  @override
  String get expandOptions => 'Seçenekleri genişlet';

  @override
  String get expandPost => 'Gönderiyi genişlet';

  @override
  String get expandPostPreview => 'Gönderi Önizlemesini Genişlet';

  @override
  String get expandSpoiler => 'Spoiler\'ı Genişlet';

  @override
  String get expanded => 'Genişletilmiş';

  @override
  String get experimentalFeatures => 'Deneysel Özellikler';

  @override
  String get experimentalFeaturesDescription =>
      'Bu özellikler hala geliştirme aşamasındadır ve kararsız olabilir. Onları kendi riskinizde kullanın. Etkili olması için Thunder\'ı yeniden başlatmalısınız.';

  @override
  String get exploreInstance => 'Örneklemi keşfet';

  @override
  String get exportDatabase => 'Veritabanını Dışa Aktar';

  @override
  String get exportDatabaseSubtitle =>
      'Veritabanı, hesaplar, favoriler, anonim abonelikler ve kullanıcı etiketleri hakkında bilgi içerir.';

  @override
  String get exportLemmyAccountSettingsDescription =>
      'Export Lemmy account settings';

  @override
  String get exportSettingsSubtitle =>
      'Ayarlar, Thunder\'da yapılandırdığınız tüm tercihleri içerir.';

  @override
  String get extraLarge => 'Ekstra Büyük';

  @override
  String failedToBlock(Object errorMessage) {
    return 'Engellenemedi: $errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return '\'$serverAddress\' adresindeki Thunder bildirim sunucusuyla iletişim kurulamadı.';
  }

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return 'Blok yüklenemedi: $errorMessage';
  }

  @override
  String get failedToLoadVideo =>
      'Video yüklenemedi. Tarayıcıda bağlantıyı aç?';

  @override
  String get failedToPerformAction => 'Failed to perform action';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'Açılamadı: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Bildirim ayarları güncellenemedi';

  @override
  String get favorites => 'Favoriler';

  @override
  String get featuredPost => 'Öne Çıkan Gönderi';

  @override
  String get feed => 'Besle';

  @override
  String get feedBehaviourSettings => 'Besle';

  @override
  String get feedSettings => 'Besleme Ayarları';

  @override
  String get feedTypeAndSorts => 'Varsayılan Besleme Türü ve Sıralama';

  @override
  String get fetchAccountError => 'Hesap belirlenemedi';

  @override
  String filteringBy(Object entity) {
    return '$entity tarafından filtreleme';
  }

  @override
  String get filters => 'Filtreler';

  @override
  String get floatingActionButton => 'Yüzen İşlem Düğmesi';

  @override
  String get floatingActionButtonInformation =>
      'Gök gürültüsü, birkaç jesti destekleyen tamamen özelleştirilebilir bir FAB deneyimine sahiptir.\n- Ek FAB eylemlerini göstermek için yukarı kaydırın\n- FAB\'ı gizlemek veya göstermek için aşağı/yukarı kaydırın\n\nFAB için ana ve ikincil eylemleri özelleştirmek için, aşağıdaki eylemlerden birine uzun basın.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'FAB\'ın uzun basma eylemini belirtir.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'FAB\'ın tek basmalı eylemini belirtir.';

  @override
  String get fonts => 'Yazı tipleri';

  @override
  String get forward => 'İleri';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Uygun uygulama bulundu; Thunder\'ı bağlanmak için yeniden başlatın.';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Sol-a sağ hareketler devre dışıyken geri gitmek için herhangi bir yere sürükleyin.';

  @override
  String get fullscreenSwipeGestures => 'Tam Ekran Kaydırma Hareketleri';

  @override
  String get general => 'Genel';

  @override
  String get generalSettings => 'Genel Ayarlar';

  @override
  String get gestures => 'Jestler';

  @override
  String get gettingStarted => 'Başlamak';

  @override
  String get green => 'Yeşil';

  @override
  String get guestModeFeedSettings => 'Konuk Modu Besleme Ayarları';

  @override
  String get guestModeFeedSettingsLabel =>
      'Aşağıdaki ayarlar yalnızca misafir hesaplarına uygulanır. Hesabınız için besleme ayarlarını düzenlemek için Hesap Ayarları\'na gidin.';

  @override
  String get havingIssuesWithNotifications =>
      'Bildirimlerle ilgili sorunlar mı yaşıyorsunuz?';

  @override
  String get hidCommunity => 'Hid Topluluğu';

  @override
  String get hidden => 'Hidden';

  @override
  String get hide => 'Hide';

  @override
  String get hideColor => 'Hide Color';

  @override
  String get hideNsfwPostsFromFeed => 'Beslemeden NSFW Gönderileri Gizle';

  @override
  String get hideNsfwPreviews => 'NSFW Önizlemeleri Bulanıklaştır';

  @override
  String get hidePassword => 'Şifreyi Gizle';

  @override
  String get hideThumbnails => 'Küçük Resimleri Gizle';

  @override
  String get hideTopBarOnScroll => 'Kaydırma Sırasında Üst Çubuğu Gizle';

  @override
  String get hostInstance => 'Ana Bilgisayar Örneği';

  @override
  String get hot => 'Sıcak';

  @override
  String get image => 'Görüntü';

  @override
  String get imageCachingMode => 'Görüntü Önbellekleme Modu';

  @override
  String get imageCachingModeAggressive =>
      'Resimleri agresif bir şekilde önbelleğe al (daha fazla bellek kullanır)';

  @override
  String get imageCachingModeAggressiveShort => 'Saldırgan';

  @override
  String get imageCachingModeRelaxed =>
      'Görüntü önbelleklerinin süresi dolmasına izin ver (daha az bellek kullanır ancak görüntülerin daha sık yeniden yüklenmesine neden olur)';

  @override
  String get imageCachingModeRelaxedShort => 'Rahat';

  @override
  String get imageDimensionTimeout => 'Görüntü Boyutu Zaman Aşımı';

  @override
  String get importDatabase => 'Veritabanını İçe Aktar';

  @override
  String get importExportDatabase => 'Veritabanı İçe Aktar/Dışa Aktar';

  @override
  String get importExportLemmyAccountSettings =>
      'Import/Export Lemmy Account Settings';

  @override
  String get importExportLemmyAccountSettingsSubtitle =>
      'Includes subscribed communities, blocklists, and account preferences';

  @override
  String get importExportSettings => 'İçe/Dışa Ayarları Aktarma';

  @override
  String get importExportThunderSettings => 'Import/Export Thunder Settings';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Import Lemmy account settings';

  @override
  String get importSettings => 'Ayarları İçe Aktar';

  @override
  String inReplyTo(Object community, Object post) {
    return '$post başlıklı $community topluluğundaki mesaja yanıt olarak';
  }

  @override
  String get in_ => 'içinde';

  @override
  String get inbox => 'Gelen Kutusu';

  @override
  String get includeCommunity => 'Topluluğu Dahil Et';

  @override
  String get includeExternalLink => 'Harici Bağlantıyı Dahil Et';

  @override
  String get includeImage => 'Resim Ekleyin';

  @override
  String get includePostLink => 'Gönderi Bağlantısını Dahil Et';

  @override
  String get includeText => 'Metni Dahil Et';

  @override
  String get includeTitle => 'Başlık Dahil Et';

  @override
  String get information => 'Bilgi';

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
  String get instanceActions => 'Örnek Eylemler';

  @override
  String instanceEntry(Object username) {
    return '\'$username\' örneği';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance zaten eklendi.';
  }

  @override
  String get instanceNameColor => 'Örnek İsim Renk';

  @override
  String get instanceNameThickness => 'Örnek İsim Kalınlık';

  @override
  String get instances => 'Örnekler';

  @override
  String get internetOrInstanceIssues =>
      'İnternete bağlı olmayabilirsiniz veya örneğiniz şu anda kullanılamıyor olabilir.';

  @override
  String get invalidUrl => 'Invalid URL format';

  @override
  String joined(Object x) {
    return 'Joined $x';
  }

  @override
  String get keywordFilterDescription =>
      'Başlık, gövde veya URL\'deki herhangi bir anahtar kelimeyi içeren gönderileri filtreler.';

  @override
  String get keywordFilters => 'Anahtar Kelime Filtreleri';

  @override
  String get label => 'Etiket';

  @override
  String get language => 'Dil';

  @override
  String get languageFilters => 'Dil filtreleri mi arıyorsunuz?';

  @override
  String get languageNotAllowed =>
      'Seçtiğiniz dilde gönderi yapmaya izin verilmeyen bir topluluğa gönderi yapıyorsunuz. Başka bir dil dene.';

  @override
  String get large => 'Büyük';

  @override
  String get leftLongSwipe => 'Uzun Sol Kaydırma';

  @override
  String get leftShortSwipe => 'Sol Kısa Sürükleyiş';

  @override
  String get light => 'Işık';

  @override
  String link(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bağlantılar',
      one: 'Bağlantı',
      zero: 'Bağlantı',
    );
    return '$_temp0 ';
  }

  @override
  String get linkActions => 'Bağlantı Eylemleri';

  @override
  String get linkHandlingCustomTabs =>
      'Uygulama içine gömülü sistem tarayıcısında aç';

  @override
  String get linkHandlingCustomTabsShort => 'Uygulama içi gömülü';

  @override
  String get linkHandlingExternal => 'Sistemin dış tarayıcısında açın';

  @override
  String get linkHandlingExternalShort => 'Dış\n';

  @override
  String get linkHandlingInApp => 'Thunder\'ın yerleşik tarayıcısını kullanın';

  @override
  String get linkHandlingInAppShort => 'Uygulama içi';

  @override
  String get linksBehaviourSettings => 'Bağlantılar';

  @override
  String loadMorePlural(Object count) {
    return '$count tane daha yanıt yükleyin...';
  }

  @override
  String loadMoreSingular(Object count) {
    return '$count tane daha yanıt yükle…';
  }

  @override
  String get loading => 'Loading...';

  @override
  String get local => 'Yerel';

  @override
  String get localNotifications => 'Yerel Bildirimler';

  @override
  String get localOnly => 'Yerel Sadece';

  @override
  String get localPosts => 'Yerel Gönderiler';

  @override
  String get lockPost => 'Gönderiyi Kilitle';

  @override
  String get locked => 'Locked';

  @override
  String get lockedPost => 'Kilitli Gönderi';

  @override
  String get logOut => 'Çıkış yap';

  @override
  String get login => 'Giriş yap';

  @override
  String get loginAttemptCanceled => 'Login attempt canceled.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Giriş yapılamadı. Lütfen tekrar deneyin:($errorMessage)';
  }

  @override
  String get loginSucceeded => 'Giriş yapıldı.';

  @override
  String get loginToPerformAction =>
      'Bu görevi gerçekleştirebilmek için giriş yapmış olmanız gerekmektedir.';

  @override
  String get loginToSeeInbox => 'Gelen kutunuzu görmek için giriş yapın.';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Looking for account-specific feed settings?';

  @override
  String get malformedUri =>
      'Sağladığınız bağlantı desteklenmeyen bir formatta. Lütfen geçerli bir bağlantı olduğundan emin olun.';

  @override
  String get manageAccounts => 'Hesapları Yönet';

  @override
  String get manageMedia => 'Manage Media';

  @override
  String get markAllAsRead => 'Tümünü Okundu Olarak İşaretle';

  @override
  String get markAsRead => 'Okundu olarak işaretle';

  @override
  String get markPostAsReadOnMediaView =>
      'Medya Görüntülendikten Sonra İşaretle Okundu';

  @override
  String get markPostAsReadOnScroll => 'Kaydırma İşareti Okundu';

  @override
  String get markReadColor => 'Okundu/Okunmadı Rengi';

  @override
  String get matrixUser => 'Matris Kullanıcısı';

  @override
  String get me => 'Ben';

  @override
  String get medium => 'Orta';

  @override
  String mention(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bahsetmeler',
      one: 'Bahsetme',
      zero: 'Bahsetme',
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
      other: 'Mesajlar',
      one: 'Mesaj',
      zero: 'Mesaj',
    );
    return '$_temp0';
  }

  @override
  String get metadataFontScale => 'Metaveri Yazı Tipi Ölçeği';

  @override
  String get missingErrorMessage => 'Hata mesajı mevcut değil';

  @override
  String get modAdd => 'Örnek Moderatörleri Ekle/Kaldır';

  @override
  String get modAddCommunity => 'Topluluklara Moderatör Ekle/Kaldır';

  @override
  String get modBan => 'Örnek Kullanıcıları Yasakla/Yasağı Kaldır';

  @override
  String get modBanFromCommunity =>
      'Topluluklardan Kullanıcıları Yasakla/Yasağı Kaldır';

  @override
  String get modFeaturePost => 'Gönderileri Öne Çıkar/Kaldır';

  @override
  String get modLockPost => 'Gönderileri Kilitle/Aç';

  @override
  String get modRemoveComment => 'Yorumları Kaldır/Geri Yükle';

  @override
  String get modRemoveCommunity => 'Toplulukları Kaldır/Geri Yükle';

  @override
  String get modRemovePost => 'Gönderileri Kaldır/Geri Yükle';

  @override
  String get modTransferCommunity => 'Toplulukları Aktarma';

  @override
  String get moderatedCommunities => 'Denetlenen Topluluklar';

  @override
  String get moderates => 'Moderates';

  @override
  String moderator(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moderatörler',
      one: 'Moderatör',
      zero: 'Moderatör',
    );
    return '$_temp0';
  }

  @override
  String get moderatorActions => 'Moderatör Eylemleri';

  @override
  String get modlog => 'Mod kaydı';

  @override
  String get mostComments => 'En Çok Yorumlar';

  @override
  String get mustBeLoggedIn => 'Giriş yapmanız gerekiyor';

  @override
  String get mustBeLoggedInComment =>
      'Yorum yapmak için giriş yapmanız gerekiyor.';

  @override
  String get mustBeLoggedInPost =>
      'Bir gönderi oluşturmak için giriş yapmanız gerekiyor.';

  @override
  String get names => 'İsimler';

  @override
  String get navbarDoubleTapGestures => 'Navbar Çift Dokunma Hareketleri';

  @override
  String get navbarSwipeGestures => 'Navbar Kaydırma Hareketleri';

  @override
  String get navigateDown => 'Sonraki yorum';

  @override
  String get navigateUp => 'Önceki yorum';

  @override
  String get navigation => 'Navigasyon';

  @override
  String get nestedCommentIndicatorColor => 'İç İçe Yorum Göstergesi Rengi';

  @override
  String get nestedCommentIndicatorStyle => 'İç İçe Yorum Gösterim Stili';

  @override
  String get never => 'Asla';

  @override
  String get newComments => 'Yeni Yorumlar';

  @override
  String get newPost => 'Yeni Gönderi';

  @override
  String get new_ => 'Yeni';

  @override
  String get no => 'Hayır';

  @override
  String get noAccountsAdded => 'No accounts have been added';

  @override
  String get noAnonymousInstances => 'No anonymous instances have been added';

  @override
  String get noCommentsFound => 'Yorum bulunamadı.';

  @override
  String get noCommunitiesFound => 'Hiçbir topluluk bulunamadı.';

  @override
  String get noCommunityBlocks => 'Engellenmiş topluluklar yok.';

  @override
  String get noCompatibleAppFound => 'Uygun uygulama bulunamadı';

  @override
  String get noDiscussionLanguages =>
      'Dil temelli hiçbir içerik gizlenmemiştir.';

  @override
  String get noDisplayNameSet => 'Görüntüleme adı ayarlanmamış';

  @override
  String get noEmailSet => 'E-posta ayarlanmadı';

  @override
  String get noFavoritedCommunities => 'Favori topluluklar yok';

  @override
  String get noImages => 'It looks like you have not uploaded any images.';

  @override
  String get noInstanceBlocks => 'Engellenmiş örnek yok.';

  @override
  String get noItems => 'Hiçbir öğe';

  @override
  String get noKeywordFilters => 'Hiçbir anahtar kelime filtresi eklenmedi';

  @override
  String get noLanguage => 'Hiçbir dil';

  @override
  String get noMatrixUserSet => 'Hiçbir matris kullanıcısı ayarlanmadı';

  @override
  String get noMentions => 'No mentions';

  @override
  String get noMessages => 'No messages';

  @override
  String get noPostsFound => 'Hiç gönderi bulunamadı.';

  @override
  String get noProfileBioSet => 'Profil biyografisi ayarlanmamış.';

  @override
  String get noReferencesToImage =>
      'No posts or comments were found containing this image. However, it may be used elsewhere on the internet.';

  @override
  String get noReplies => 'Cevap yok';

  @override
  String get noResultsFound => 'Sonuç bulunamadı.';

  @override
  String get noSubscriptions => 'Abonelik Yok';

  @override
  String get noUserBlocks => 'Engellenmiş kullanıcı yok.';

  @override
  String get noUserLabels => 'You have not created any user labels yet';

  @override
  String get noUsersFound => 'Kullanıcı bulunamadı.';

  @override
  String get noVisibleComments =>
      'Comments may not be visible because the community is blocked.';

  @override
  String get none => 'Hiçbiri';

  @override
  String get normal => 'Normal';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance geçerli bir Lemmy örneği gibi görünmüyor.';
  }

  @override
  String get notValidUrl => 'Geçerli bir URL değil';

  @override
  String get nothingToShare => 'Paylaşacak bir şey yok';

  @override
  String notifications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bildirimler',
      one: 'Bildirimler',
      zero: 'Bildirim',
    );
    return '$_temp0';
  }

  @override
  String get notificationsBehaviourSettings => 'Bildirimler';

  @override
  String get notificationsNotAllowed =>
      'Sistem ayarlarında Thunder için bildirimlere izin verilmiyor';

  @override
  String get notificationsWarningDialog =>
      'Bildirimler, tüm cihazlarda doğru şekilde çalışmayabilecek bir **deneysel özellik**tir.\n\n - Kontroller her ~15 dakikada bir gerçekleşecek ve ekstra pil tüketilecektir.\n\n - Başarılı bildirimlerin olasılığını artırmak için pil optimizasyonlarını devre dışı bırakın.\n\n Daha fazla bilgi için aşağıdaki sayfayı görüntüleyin.';

  @override
  String get nsfw => 'Uygunsuz İçerik';

  @override
  String get nsfwWarning => 'NSFW - Açmak için dokunun';

  @override
  String get off => 'kapalı';

  @override
  String get offline => 'çevrimdışı';

  @override
  String get ok => 'Tamam';

  @override
  String get old => 'Eski';

  @override
  String get on => 'üzerinde';

  @override
  String get onWifi => 'Wifi Üzerinde';

  @override
  String get onlyModsCanPostInCommunity =>
      'Bu toplulukta sadece moderatörler gönderi yapabilir.';

  @override
  String get open => 'Açık';

  @override
  String get openAccountSwitcher => 'Hesap değiştiriciyi açın';

  @override
  String get openByDefault => 'Varsayılan olarak açık';

  @override
  String get openInBrowser => 'Tarayıcıda Aç';

  @override
  String get openInstance => 'Açık Örnek';

  @override
  String get openLinksInExternalBrowser => 'Harici Tarayıcıda Bağlantıları Aç';

  @override
  String get openLinksInReaderMode => 'Okuyucu Modunda Linkleri Açın';

  @override
  String get openSettings => 'Ayarları Aç';

  @override
  String get orange => 'Portakal';

  @override
  String get originalPoster => 'Orijinal Gönderen';

  @override
  String get overview => 'Genel Bakış';

  @override
  String get password => 'Şifre';

  @override
  String get pending => 'Beklemede';

  @override
  String performedBy(Object user) {
    return 'Performed by: $user';
  }

  @override
  String get permissionDenied =>
      'Thunder\'ın bildirimleri gösterme izni verilmedi. Lütfen sistem ayarlarında etkinleştirin.';

  @override
  String get permissionDeniedMessage =>
      'Bu resmi kaydetmek için Thunder\'ın bazı izinlere ihtiyacı vardır ve bu izinler reddedilmiştir.';

  @override
  String get pinPostToCommunity => 'Pin Post to Community';

  @override
  String get pinToCommunity => 'Topluluğa Sabitle';

  @override
  String get pinned => 'Pinned';

  @override
  String get placeholderText =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. En azından küçük bir özür dilemek için, kimse işçilik hakkında egzersiz yapmamı istemiyor, ancak bu rahatlıkla sonuçlanabilir. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, suçlu olanlar işleri terk eden mollit anim id est laborum.';

  @override
  String get post => 'Post';

  @override
  String get postActions => 'Post Actions';

  @override
  String get postBehaviourSettings => 'Gönderiler';

  @override
  String get postBody => 'Gönderi İçeriği';

  @override
  String get postBodySettings => 'Gönderi Gövde Ayarları';

  @override
  String get postBodySettingsDescription =>
      'Bu ayarlar, gönderi gövdesinin görüntülenmesini etkiler.';

  @override
  String get postBodyShowCommunityInstance => 'Topluluk Örneğini Göster';

  @override
  String get postBodyShowUserInstance => 'Kullanıcı Örneğini Göster';

  @override
  String get postBodyViewType => 'Gönderi Gövde Görünüm Tipi';

  @override
  String get postContentFontScale => 'Gönderi İçeriği Yazı Tipi Ölçeği';

  @override
  String get postCreatedSuccessfully => 'Gönderi başarıyla oluşturuldu!';

  @override
  String get postLocked => 'Gönderi kilitlendi. Cevap vermek yasaktır.';

  @override
  String get postMetadataInstructions =>
      'İstenilen bilgileri sürükleyip bırakarak metaveri bilgilerini özelleştirebilirsiniz.';

  @override
  String get postNSFW => 'NSFW olarak işaretle';

  @override
  String get postPreview => 'Verilen ayarlarla bir gönderi önizlemesi gösterin';

  @override
  String get postSavedAsDraft => 'Taslak olarak kaydedildi';

  @override
  String get postShowUserInstance => 'Kullanıcı Örneğini Göster';

  @override
  String get postSwipeActions => 'Kaydırma Sonrası Eylemler';

  @override
  String get postSwipeGesturesHint =>
      'Düğmeleri kullanmayı mı düşünüyorsunuz? Genel ayarlarda posta kartlarındaki düğmelerin ne olduğunu değiştirin.';

  @override
  String get postTitle => 'Başlık';

  @override
  String get postTitleFontScale => 'Yazı Başlığı Font Ölçeği';

  @override
  String get postTogglePreview => 'Önizleme Geçişi';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Resim yüklenemedi';

  @override
  String get postViewType => 'Gönderi Görünüm Tipi';

  @override
  String get posts => 'Gönderiler';

  @override
  String get preview => 'Önizleme';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile başarıyla uygulandı!';
  }

  @override
  String get profileBio => 'Profil Biyografisi';

  @override
  String get profiles => 'Profiller';

  @override
  String get public => 'Kamu';

  @override
  String get pureBlack => 'Saf Siyah';

  @override
  String get purgedComment => 'Silinmiş Yorum';

  @override
  String get purgedCommunity => 'Temizlenmiş Topluluk';

  @override
  String get purgedPerson => 'Temizlenmiş Kişi';

  @override
  String get purgedPost => 'Silinmiş Gönderi';

  @override
  String get purple => 'Mor';

  @override
  String get pushNotification => 'Bildirimler';

  @override
  String get pushNotificationDescription =>
      'Etkinleştirilirse, Thunder JWT belirteç(ler)inizi sunucuya göndererek yeni bildirimler için anket yapar. \n\n **NOT:** Bu, uygulama bir sonraki sefer başlatıldığında etkili olacaktır.';

  @override
  String get pushNotificationServer => 'Bildirim Sunucusu';

  @override
  String get pushNotificationServerDescription =>
      'Push bildirim sunucusunu yapılandırın. Sunucu, cihazınıza push bildirimleri göndermek için doğru şekilde yapılandırılmalıdır.\n\n **Yalnızca kimlik bilgilerinize güvendiğiniz bir sunucuya girin.**';

  @override
  String get rateLimitErrorMessage =>
      'You have hit the rate limit for this request. Please wait and try again later.';

  @override
  String get reachedTheBottom => 'Hmm. Görünüşe göre dibe ulaştınız.';

  @override
  String get read => 'Read';

  @override
  String get readAll => 'Hepsini Oku';

  @override
  String get readerMode => 'Reader mode';

  @override
  String get reason => 'Sebep';

  @override
  String get red => 'Kırmızı';

  @override
  String get reduceAnimations => 'Animasyonları Azalt';

  @override
  String get reducesAnimations =>
      'Thunder içinde kullanılan animasyonları azaltır';

  @override
  String get refresh => 'Yenile';

  @override
  String get refreshContent => 'İçeriği Yenile';

  @override
  String get removalReason => 'Kaldırma Sebebi';

  @override
  String get remove => 'Kaldır';

  @override
  String get removeAccount => 'Hesabı Kaldır';

  @override
  String get removeAsCommunityModerator => 'Remove as Community Moderator';

  @override
  String get removeComment => 'Remove Comment';

  @override
  String get removeFromFavorites => 'Favorilerden çıkar';

  @override
  String get removeInstance => 'Örneği kaldır';

  @override
  String removeKeyword(Object keyword) {
    return '\"$keyword\" kaldırılsın mı?';
  }

  @override
  String get removeKeywordFilter => 'Anahtar Kelimeyi Kaldır';

  @override
  String get removePost => 'Gönderiyi Kaldır';

  @override
  String get removed => 'Removed';

  @override
  String get removedComment => 'Kaldırılmış Yorum';

  @override
  String get removedCommunity => 'Kaldırılan Topluluk';

  @override
  String get removedCommunityFromSubscriptions =>
      'Topluluktan abonelik iptal edildi.';

  @override
  String get removedInstanceMod => 'Kaldırılan Örnek Mod';

  @override
  String get removedModFromCommunity => 'Topluluktan Mod Kaldırıldı';

  @override
  String get removedPost => 'Kaldırılan Gönderi';

  @override
  String get reorder => 'Reorder';

  @override
  String reply(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yanıtlar',
      one: 'Yanıt',
      zero: 'Yanıt',
    );
    return '$_temp0';
  }

  @override
  String get replyColor => 'Cevap Renk';

  @override
  String get replyNotSupported =>
      'Bu görünümden yanıt verme şu anda henüz desteklenmiyor.';

  @override
  String get replyToPost => 'Posta Yanıtla';

  @override
  String replyingTo(Object author) {
    return '$author adlı kişiye yanıt veriyor.';
  }

  @override
  String report(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Raporlar',
      one: 'Rapor',
      zero: 'Rapor',
    );
    return '$_temp0 ';
  }

  @override
  String get reportComment => 'Yorumu Bildir';

  @override
  String get reportPost => 'Report Post';

  @override
  String get reporter => 'Reporter:';

  @override
  String get requiredField => '*required';

  @override
  String get reset => 'Sıfırla';

  @override
  String get resetCommentPreferences => 'Yorum tercihlerini sıfırla';

  @override
  String get resetPostPreferences => 'Gönderi tercihlerini sıfırla';

  @override
  String get resetPreferences => 'Tercihleri Sıfırla';

  @override
  String get resetPreferencesAndData => 'Tercihleri ve Verileri Sıfırla';

  @override
  String get restore => 'Geri yükle';

  @override
  String get restoreComment => 'Restore Comment';

  @override
  String get restorePost => 'Gönderiyi Geri Yükle';

  @override
  String get restoredComment => 'Yeniden Yorumlanan Yorum';

  @override
  String get restoredCommentFromDraft => 'Taslaktan geri yüklenen yorum';

  @override
  String get restoredCommunity => 'Onarılmış Topluluk';

  @override
  String get restoredPost => 'Onarılmış Gönderi';

  @override
  String get restoredPostFromDraft => 'Taslaktan geri yüklenen gönderi';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get rightLongSwipe => 'Sağ Uzun Kaydırma';

  @override
  String get rightShortSwipe => 'Sağ Kısa Sürükleme';

  @override
  String get save => 'Kaydet';

  @override
  String get saveColor => 'Renk Kaydet';

  @override
  String get saveSettings => 'Ayarları Kaydet';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get scaled => 'Ölçeklendirilmiş';

  @override
  String get scrapeMissingLinkPreviews => 'Eksik Link Önizlemelerini Kazı';

  @override
  String get screenReaderProfile => 'Ekran Okuyucu Profili';

  @override
  String get screenReaderProfileDescription =>
      'Ekran okuyucuları için Thunder\'ı optimize eder, genel öğeleri azaltır ve potansiyel olarak çelişkili hareketleri kaldırır.';

  @override
  String get search => 'Ara';

  @override
  String get searchByText => 'Metinle ara';

  @override
  String get searchByUrl => 'URL ile ara';

  @override
  String get searchComments => 'Yorumları Ara';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return '$instance ile federasyon yapılan yorumları ara';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return '$instance ile federasyon kurmuş toplulukları ara';
  }

  @override
  String searchInstance(Object instance) {
    return '$instance ara';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return '$instance ile federasyon kurulan örnekleri arayın.';
  }

  @override
  String get searchPostSearchType => 'Gönderi Arama Türünü Seçin';

  @override
  String searchPostsFederatedWith(Object instance) {
    return '$instance ile federasyon kurulan gönderileri ara';
  }

  @override
  String get searchTerm => 'Arama terimi';

  @override
  String searchUsersFederatedWith(Object instance) {
    return '$instance ile federasyon kurmuş kullanıcıları ara';
  }

  @override
  String get selectAccountToCommentAs => 'Yorum yapmak için hesap seçin';

  @override
  String get selectAccountToPostAs => 'Yayın yapılacak hesabı seçin';

  @override
  String get selectAll => 'Tümünü seç';

  @override
  String get selectCommunity => 'Bir topluluk seçin';

  @override
  String get selectFeedType => 'Besleme Türünü Seçin';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get selectSearchType => 'Arama Türü Seçin';

  @override
  String get selectText => 'Metni Seçin';

  @override
  String get sendBackgroundTestLocalNotification =>
      'Arka plan testi yerel bildirimini gönder';

  @override
  String get sendBackgroundTestUnifiedPushNotification =>
      'Arka plan testi UnifiedPush bildirimi gönder';

  @override
  String get sendTestLocalNotification => 'Yerel bildirim testi gönder';

  @override
  String get sendTestUnifiedPushNotification =>
      'Test UnifiedPush bildirimi gönderin';

  @override
  String get sensitiveContentWarning =>
      'Hassas içerik içerebilir. Açmak için dokunun.';

  @override
  String get sentRequestForTestNotification =>
      'Test bildirimi için istek gönderildi.';

  @override
  String serverErrorComments(Object message) {
    return 'Daha fazla yorum getirilirken bir sunucu hatasıyla karşılaşıldı: $message';
  }

  @override
  String get setAction => 'Eylemi Ayarla';

  @override
  String get setLongPress => 'Uzun basma eylemi olarak ayarla';

  @override
  String get setShortPress => 'Kısa basma eylemi olarak ayarla';

  @override
  String get settingOverrideLabel =>
      'Bu ayarlar, Thunder\'ın varsayılan ayarlarını geçersiz kılar.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return '$settingType türü ayarlar henüz desteklenmiyor.';
  }

  @override
  String get settings => 'Ayarlar';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'Ayarlar başarıyla \'\'$savedFilePath\' konumuna kaydedildi.';
  }

  @override
  String get settingsFeedCards =>
      'Bu ayarlar ana beslemekteki kartlara uygulanır, gönderileri gerçekten açtığınızda eylemler her zaman kullanılabilir.';

  @override
  String get settingsImportedSuccessfully => 'Ayarlar başarıyla içe aktarıldı!';

  @override
  String get settingsNotExportedSuccessfully =>
      'Ayarlar başarıyla kaydedilmedi veya işlem iptal edildi.';

  @override
  String get settingsNotImportedSuccessfully =>
      'Ayarlar başarıyla içe aktarılmadı veya işlem iptal edildi.';

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
  String get share => 'Paylaş';

  @override
  String get shareComment => 'Yorumu Paylaş Linki';

  @override
  String get shareCommentLocal => 'Yorum Paylaş Linki (Benim Örneğim)';

  @override
  String get shareCommunity => 'Topluluğu Paylaş';

  @override
  String get shareCommunityLink => 'Topluluk Bağlantısını Paylaş';

  @override
  String get shareCommunityLinkLocal =>
      'Topluluk Bağlantısını Paylaş (Benim Örneğim)';

  @override
  String get shareImage => 'Resim Paylaş';

  @override
  String get shareLemmyLink => 'Lemmy Linkini Paylaş';

  @override
  String get shareLink => 'Dış Bağlantıyı Paylaş';

  @override
  String get shareMedia => 'Medya Paylaş';

  @override
  String get shareMediaLink => 'Medya Bağlantısını Paylaş';

  @override
  String get shareOriginalLink => 'Orijinal Bağlantıyı Paylaş';

  @override
  String get sharePost => 'Gönderi Bağlantısını Paylaş';

  @override
  String get sharePostLocal => 'Gönderi Bağlantısını Paylaş (Benim Örneğim)';

  @override
  String get shareThumbnail => 'Önizleme Paylaş';

  @override
  String get shareThumbnailAsImage => 'Önizlemeyi Resim Olarak Paylaş';

  @override
  String get shareUser => 'Kullanıcıyı Paylaş';

  @override
  String get shareUserLink => 'Kullanıcı Bağlantısını Paylaş';

  @override
  String get shareUserLinkLocal =>
      'Kullanıcı Bağlantısını Paylaş (Benim Örneğim)';

  @override
  String get showAll => 'Hepsini Göster';

  @override
  String get showBotAccounts => 'Bot Hesapları Göster';

  @override
  String get showCommentActionButtons => 'Yorum Eylem Düğmelerini Göster';

  @override
  String get showCommunityDisplayNames => 'Topluluk Görünen İsimlerini Göster';

  @override
  String get showCrossPosts => 'Çapraz Gönderileri Göster';

  @override
  String get showEdgeToEdgeImages => 'Kenarından Kenarına Görseller Göster';

  @override
  String get showExpandedTaglines => 'Show expanded taglines';

  @override
  String get showFullDate => 'Tam Tarihi Göster';

  @override
  String get showFullDateDescription => 'Gönderilerde tam tarihi göster';

  @override
  String get showFullHeightImages => 'Tam Yükseklikte Görüntüleri Göster';

  @override
  String get showHiddenPosts => 'Show Hidden Posts';

  @override
  String get showInAppUpdateNotifications =>
      'Yeni GitHub Sürümlerinden Haberdar Olun';

  @override
  String get showLess => 'Daha az göster';

  @override
  String get showMore => 'Daha fazla göster';

  @override
  String get showNavigationLabels => 'Navigasyon Etiketlerini Göster';

  @override
  String get showNavigationLabelsDescription =>
      'Alt navigasyon düğmelerinin altında etiketlerin görüntülenip görüntülenmeyeceği';

  @override
  String get showNsfwContent => 'NSFW İçeriği Göster';

  @override
  String get showOwnContent => 'Show own content';

  @override
  String get showPassword => 'Şifreyi Göster';

  @override
  String get showPostAuthor => 'Gönderi Yazarını Göster';

  @override
  String get showPostAuthorSubtitle =>
      'Yazı yazarı her zaman topluluk beslemelerinde gösterilir.';

  @override
  String get showPostCommunityIcons => 'Topluluk Simgelerini Göster';

  @override
  String get showPostSaveAction => 'Kaydet Butonunu Göster';

  @override
  String get showPostTextContentPreview => 'Metin Önizlemesini Göster';

  @override
  String get showPostTitleFirst => 'İlk Önce Gösteri Başlığını';

  @override
  String get showPostVoteActions => 'Oy Verme Düğmelerini Göster';

  @override
  String get showReadPosts => 'Okunan Gönderileri Göster';

  @override
  String get showSavedContent => 'Show saved content';

  @override
  String get showScoreCounters => 'Kullanıcı Skorlarını Göster';

  @override
  String get showScores => 'Gönderi/Yorum Puanlarını Göster';

  @override
  String get showTextPostIndicator => 'Metin Gönderi Göstergesini Göster';

  @override
  String get showThumbnailPreviewOnRight => 'Sağda Küçük Resimleri Göster';

  @override
  String get showUnreadOnly => 'Show unread only';

  @override
  String get showUpdateChangelogs =>
      'Güncelleme Değişiklik Günlüklerini Göster';

  @override
  String get showUpdateChangelogsSubtitle =>
      'Bir güncellemeden sonra değişikliklerin bir listesini gösterin';

  @override
  String get showUserAvatar => 'Kullanıcı Avatarını Göster';

  @override
  String get showUserDisplayNames => 'Kullanıcı Görünen İsimlerini Göster';

  @override
  String get showUserInstance => 'Kullanıcı Örneğini Göster';

  @override
  String get sidebar => 'Kenar çubuğu';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Alt menüyü çift tıklayarak yan menüyü açın';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Alt navigasyonu kaydırarak yan menüyü açın';

  @override
  String get small => 'Küçük';

  @override
  String get somethingWentWrong => 'Hata oluştu, bir şeyler yanlış gitti!';

  @override
  String get sortBy => 'Sırala Göre';

  @override
  String get sortByTop => 'En Üste Göre Sırala';

  @override
  String get sortOptions => 'Sıralama Seçenekleri';

  @override
  String get spoiler => 'Spoiler';

  @override
  String get standard => 'Standart';

  @override
  String get stats => 'İstatistikler';

  @override
  String get status => 'Durum';

  @override
  String get submit => 'Gönder';

  @override
  String get subscribe => 'Abone ol';

  @override
  String get subscribeToCommunity => 'Topluluğa Abone Ol';

  @override
  String get subscribed => 'Abone olundu';

  @override
  String get subscriptionRequestSent => 'Subscription request sent';

  @override
  String get subscriptions => 'Abonelikler';

  @override
  String successfullyBannedUser(Object username) {
    return 'Banned $username';
  }

  @override
  String get successfullyBlocked => 'Engellendi.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return '$communityName engellendi';
  }

  @override
  String successfullyBlockedUser(Object username) {
    return '$username engellendi';
  }

  @override
  String successfullyUnbannedUser(Object username) {
    return 'Unbanned $username';
  }

  @override
  String get successfullyUnblocked => 'Engellenmemiş.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return 'Engellenmemiş $communityName';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return '$username engellemesini kaldırdı.';
  }

  @override
  String get suchAs => 'gibi';

  @override
  String get suggestedTitle => 'Önerilen başlık';

  @override
  String get system => 'Sistem';

  @override
  String get systemDarkMode => 'Pure Black';

  @override
  String get systemDarkModeDescription =>
      'Enable pure black theme for dark mode';

  @override
  String get tabletMode => 'Tablet Modu (2-sütun görünümü)';

  @override
  String get tapToExit => 'Tekrar geri basın çıkmak için';

  @override
  String get tappableAuthorCommunity => 'Dokunulabilir Yazarlar & Topluluklar';

  @override
  String get teal => 'Cam göbeği';

  @override
  String get testBackgroundNotificationDescription =>
      'Gök gürültüsü kendini kapatacak ve ardından arka planda bir bildirim oluşturmaya çalışacak. (Birkaç dakika sürebilir.)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'Gök gürültüsü, bildirim sunucusundan gecikmeli bir bildirim göndermesini isteyecek ve sonra kendini kapatacaktır. (Birkaç dakika sürebilir.)';

  @override
  String get text => 'Metin';

  @override
  String get textActions => 'Metin İşlemleri';

  @override
  String get theme => 'Tema';

  @override
  String get themeAccentColor => 'Aksan Renkleri';

  @override
  String get themePrimary => 'Birincil Tema';

  @override
  String get themeSecondary => 'İkincil Tema';

  @override
  String get themeTertiary => 'Üçüncül Tema';

  @override
  String get theming => 'Temalandırma';

  @override
  String get thickness => 'Kalınlık';

  @override
  String get thisAccount => 'Bu Hesap';

  @override
  String get thumbnailUrl => 'Thumbnail URL';

  @override
  String thunderHasBeenUpdated(Object version) {
    return 'Gök gürültüsü $version sürümüne güncellendi!';
  }

  @override
  String thunderNotificationServer(Object server) {
    return 'Gök Gürültüsü Bildirim Sunucusu: $server';
  }

  @override
  String get timeoutComments =>
      'Hata: Yorumları almak için yapılan denemede zaman aşımı oldu.';

  @override
  String get timeoutErrorMessage => 'Bir yanıt beklerken zaman aşımına uğradı.';

  @override
  String get timeoutSaveComment =>
      'Hata: Bir yorumu kaydetmeye çalışırken zaman aşımı oldu.';

  @override
  String get timeoutSavingPost =>
      'Hata: Gönderi kaydedilmeye çalışılırken zaman aşımı oldu.';

  @override
  String get timeoutUpvoteComment =>
      'Hata: Yorumda oy kullanmaya çalışırken zaman aşımı oldu.';

  @override
  String get timeoutVotingPost =>
      'Hata: Gönderiye oy verme girişiminde zaman aşımı.';

  @override
  String get toggelRead => 'Okuma Modunu Değiştir';

  @override
  String get top => 'Üst';

  @override
  String get topAll => 'Tüm zamanların en iyisi';

  @override
  String get topDay => 'Bugünün En İyileri';

  @override
  String get topHour => 'Son Saatteki En Üstteki';

  @override
  String get topMonth => 'En İyi Ay';

  @override
  String get topNineMonths => 'Son 9 Ayın En İyileri';

  @override
  String get topSixHour => 'Son 6 Saatte En Üstte';

  @override
  String get topSixMonths => 'Son 6 Ayın En İyileri';

  @override
  String get topThreeMonths => 'Son 3 Ayın En İyileri';

  @override
  String get topTwelveHour => 'Son 12 Saatte En Çok İzlenenler';

  @override
  String get topWeek => 'Haftanın Zirvesi';

  @override
  String get topYear => 'En İyi Yıl';

  @override
  String totalComments(Object x) {
    return '$x Comments';
  }

  @override
  String totalPosts(Object x) {
    return '$x Posts';
  }

  @override
  String get totp => 'TOTP (isteğe bağlı)';

  @override
  String get transferredModToCommunity => 'Aktarılan Topluluk';

  @override
  String get translationsMayNotBeComplete =>
      'Lütfen çevirilerin tam olmayabileceğini unutmayın.';

  @override
  String get trendingCommunities => 'Trend Olan Topluluklar';

  @override
  String get trySearchingFor => '... aramayı deneyin.';

  @override
  String get unableToFindCommunity => 'Topluluk bulunamadı';

  @override
  String unableToFindCommunityName(Object communityName) {
    return '\'$communityName\' adlı topluluk bulunamadı.';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Seçilen kullanıcının örneğinde seçilen topluluk bulunamadı.';

  @override
  String get unableToFindInstance => 'Örnek bulunamadı';

  @override
  String get unableToFindLanguage => 'Dil bulunamadı';

  @override
  String get unableToFindPost => 'Gönderi bulunamadı';

  @override
  String get unableToFindUser => 'Kullanıcı bulunamadı';

  @override
  String unableToFindUserName(Object username) {
    return 'Kullanıcı \'$username\' bulunamadı.';
  }

  @override
  String get unableToLoadImage => 'Resim yüklenemiyor';

  @override
  String unableToLoadImageFrom(Object domain) {
    return '$domain adresinden resim yüklenemiyor';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return '$instance yüklenemiyor';
  }

  @override
  String get unableToLoadPost => 'Unable to load post';

  @override
  String unableToLoadPostsFrominstance(Object Instance, Object instance) {
    return '$Instance \'dan gönderiler yüklenemiyor';
  }

  @override
  String get unableToLoadReplies => 'Daha fazla yanıt yüklenemiyor.';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return '$instanceHost\'a gidilemiyor. Geçerli bir Lemmy örneği olmayabilir.';
  }

  @override
  String get unableToResolveReport => 'Raporu çözme konusunda başarısız oldu';

  @override
  String unableToRetrieveChangelog(Object version) {
    return '$version sürümü için değişiklik günlüğü alınamıyor.';
  }

  @override
  String get unbanFromCommunity => 'Unban from Community';

  @override
  String get unbannedUser => 'Yasağı Kaldırılmış Kullanıcı';

  @override
  String get unbannedUserFromCommunity =>
      'Topluluktan Engeli Kaldırılan Kullanıcı';

  @override
  String get unblock => 'Unblock';

  @override
  String get unblockCommunity => 'Topluluğun Engelini Kaldır';

  @override
  String get unblockCommunityInstance => 'Unblock Community Instance';

  @override
  String get unblockInstance => 'Örneği Engeli Kaldır';

  @override
  String get unblockUser => 'Unblock User';

  @override
  String get unblockUserInstance => 'Unblock User Instance';

  @override
  String get understandEnable => 'Anladım, Etkinleştir';

  @override
  String get unexpectedError => 'Beklenmeyen Hata';

  @override
  String get unfeaturedPost => 'Öne Çıkmayan Gönderi';

  @override
  String get unhidCommunity => 'Unhid Topluluğu';

  @override
  String get unhide => 'Unhide';

  @override
  String unifiedPushDistributorApp(Object app, Object count) {
    return 'UnifiedPush Dağıtıcı uygulaması: $app ($count mevcut)';
  }

  @override
  String get unifiedPushNotifications => 'BirleşikPush Bildirimleri';

  @override
  String unifiedPushServer(Object server) {
    return 'BirleşikPush Sunucusu: $server';
  }

  @override
  String get unifiedpush => 'BirleşikPush';

  @override
  String get unlockPost => 'Gönderiyi Kilidini Aç';

  @override
  String get unlockedPost => 'Kilit Açılmış Gönderi';

  @override
  String get unpinFromCommunity => 'Topluluktan Kaldır';

  @override
  String get unpinPostFromCommunity => 'Unpin Post from Community';

  @override
  String get unreachable => 'Ulaşılamaz';

  @override
  String get unresolved => 'Çözülmemiş';

  @override
  String get unsubscribe => 'Abonelikten çık';

  @override
  String get unsubscribeFromCommunity => 'Topluluktan Aboneliği İptal Et';

  @override
  String get unsubscribePending => 'Abonelikten çık (abonelik bekleniyor)';

  @override
  String get unsubscribed => 'Abonelikten çıktı';

  @override
  String updateReleased(Object version) {
    return 'Güncelleme yayınlandı: $version';
  }

  @override
  String get uploadImage => 'Görsel yükle';

  @override
  String uploadedDate(Object date) {
    return 'Uploaded: $date';
  }

  @override
  String get upvote => 'Oy ver';

  @override
  String get upvoteColor => 'Oy Renk';

  @override
  String get upvoted => 'Oy verildi';

  @override
  String get uriNotSupported => 'Bu tür bağlantı şu anda desteklenmiyor.';

  @override
  String get url => 'URL';

  @override
  String get useAdvancedShareSheet => 'Gelişmiş Paylaşım Sayfasını Kullanın';

  @override
  String get useApplePushNotifications => 'APNs Bildirimlerini Kullanın';

  @override
  String get useApplePushNotificationsDescription =>
      'Apple\'ın Push Bildirim hizmetini kullanır';

  @override
  String get useCompactView =>
      'Küçük gönderiler için etkinleştir, büyükler için devre dışı bırak.';

  @override
  String get useLocalNotifications => 'Yerel Bildirimleri Kullanın (Deneysel)';

  @override
  String get useLocalNotificationsDescription =>
      'Arka planda bildirimler için periyodik olarak kontrol eder';

  @override
  String get useMaterialYouTheme => 'Material You Tema Kullanın';

  @override
  String get useMaterialYouThemeDescription =>
      'Seçili özel temayı geçersiz kılar';

  @override
  String get useProfilePictureForDrawer => 'Çekmece için Profil Resmi Kullanın';

  @override
  String get useProfilePictureForDrawerSubtitle =>
      'Giriş yapıldığında, çekmece simgesinin yerine kullanıcının profil resmini gösterir.';

  @override
  String useSuggestedTitle(Object title) {
    return 'Önerilen başlığı kullanın: $title';
  }

  @override
  String get useUnifiedPushNotifications =>
      'UnifiedPush Bildirimlerini Kullanın';

  @override
  String get useUnifiedPushNotificationsDescription =>
      'Uyumlu bir uygulama gerektirir';

  @override
  String get user => 'Kullanıcı';

  @override
  String get userActions => 'Kullanıcı Eylemleri';

  @override
  String userEntry(Object username) {
    return 'Kullanıcı \'$username\'';
  }

  @override
  String get userFormat => 'Kullanıcı Formatı';

  @override
  String get userLabelHint => 'Bu benim favori kullanıcım';

  @override
  String get userLabels => 'User Labels';

  @override
  String get userLabelsSettingsPageDescription =>
      'You can add, modify, or remove labels associated with users.';

  @override
  String get userNameColor => 'Kullanıcı Adı Rengi';

  @override
  String get userNameThickness => 'Kullanıcı Adı Kalınlığı';

  @override
  String get userNotLoggedIn => 'Kullanıcı giriş yapmadı';

  @override
  String get userProfiles => 'Kullanıcı Profilleri';

  @override
  String get userSettingDescription =>
      'Bu ayarlar Lemmy hesabınızla senkronize olur ve yalnızca hesap bazında uygulanır.';

  @override
  String get userStyle => 'Kullanıcı Stili';

  @override
  String get username => 'Kullanıcı adı';

  @override
  String get usernameFormattingRedirect =>
      'Kullanıcı adı biçimlendirme mi arıyorsunuz?';

  @override
  String get users => 'Kullanıcılar';

  @override
  String versionNumber(Object version) {
    return 'Sürüm $version';
  }

  @override
  String get video => 'Video';

  @override
  String get videoAutoFullscreen => 'Otomatik Tam Ekran';

  @override
  String get videoAutoLoop => 'Video Döngüsü';

  @override
  String get videoAutoMute => 'Sessiz Videolar';

  @override
  String get videoAutoPlay => 'Video Otomatik Oynatma';

  @override
  String get videoDefaultPlaybackSpeed => 'Varsayılan Oynatma Hızı';

  @override
  String get videoLinkHandlingExternal => 'Play video with an external app';

  @override
  String get videoPlayerInApp => 'Use Thunder built-in player';

  @override
  String get videoPlayerMode => 'Player Mode';

  @override
  String get viewAll => 'Hepsini gör';

  @override
  String get viewAllComments => 'Tüm yorumları gör';

  @override
  String get viewCommentSource => 'Yorum Kaynağını Görüntüle';

  @override
  String get viewModlog => 'View Modlog';

  @override
  String get viewOriginal => 'Orijinali görüntüle';

  @override
  String get viewPostAsDifferentAccount =>
      'Farklı bir hesap olarak gönderiyi görüntüle';

  @override
  String get viewPostSource => 'Gönderi kaynağını görüntüle';

  @override
  String get viewSource => 'Kaynak kodunu görüntüle';

  @override
  String get viewingAll => 'Hepsini görüntüle';

  @override
  String visibility(Object visibility) {
    return 'Görünürlük: $visibility';
  }

  @override
  String get visitCommunity => 'Topluluğu Ziyaret Et';

  @override
  String get visitCommunityInstance => 'Visit Community Instance';

  @override
  String get visitInstance => 'Ziyaret Etme Örneği';

  @override
  String get visitUserInstance => 'Visit User Instance';

  @override
  String get visitUserProfile => 'Kullanıcı Profilini Ziyaret Et';

  @override
  String get warning => 'Uyarı';

  @override
  String xDownvotes(Object x) {
    return '$x aşağı oy';
  }

  @override
  String xScore(Object x) {
    return '$x puan';
  }

  @override
  String xUpvotes(Object x) {
    return '$x beğeni';
  }

  @override
  String xYearsOld(num count, Object x) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$x yaşında',
      one: '$x yaşında',
      zero: '$x yaşında',
    );
    return '$_temp0';
  }

  @override
  String get yes => 'Evet';

  @override
  String get youMustSelectAJsonFile => 'You must select a .json file.';
}
