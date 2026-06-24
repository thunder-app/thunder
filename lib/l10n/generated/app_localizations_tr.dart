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
  String get accept => 'Kabul Et';

  @override
  String get accessibility => 'Erişilebilirlik';

  @override
  String get accessibilityProfilesDescription =>
      'Erişilebilirlik profilleri, belirli bir erişilebilirlik gereksinimini karşılamak için birkaç ayarın aynı anda uygulanmasına olanak tanır.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hesap',
      one: 'Hesap',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'Hesap Doğum Günü $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'Hesap ayarlarınız aşağıdaki ayarları geçersiz kılıyor';

  @override
  String get accountSettings => 'Hesap Ayarları';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'Lemmy hesap ayarları başarıyla $savedFilePath konumuna aktarıldı!';
  }

  @override
  String get accountSettingsImportedSuccessfully =>
      'Lemmy hesap ayarları başarıyla içe aktarıldı!';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return 'Seçilen yorum \'$instance\' üzerinde bulunamadı.';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'Seçilen gönderi \'$instance\' üzerinde bulunamadı.';
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
  String get activity => 'Aktivite';

  @override
  String get add => 'Ekle';

  @override
  String get addAccount => 'Hesap Ekle';

  @override
  String get addAccountToSeeProfile => 'Hesabınızı görmek için giriş yapın.';

  @override
  String get addAnonymousInstance => 'Anonim Sunucu Ekle';

  @override
  String get addAsCommunityModerator => 'Topluluk Moderatörü Olarak Ekle';

  @override
  String get addDiscussionLanguage => 'Dil Ekle';

  @override
  String get addKeywordFilter => 'Anahtar Kelime Ekle';

  @override
  String get addOriginalPostBody => 'Orijinal gönderi metni eklensin mi?';

  @override
  String get addToFavorites => 'Favorilere ekle';

  @override
  String get addUserLabel => 'Kullanıcı Etiketi Ekle';

  @override
  String get addedCommunityToSubscriptions => 'Topluluğa abone olundu';

  @override
  String get addedInstanceMod => 'Sunucuya Mod Eklendi';

  @override
  String get addedModToCommunity => 'Topluluğa Mod Eklendi';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return '$username topluluk moderatörü olarak eklendi';
  }

  @override
  String get admin => 'Yönetici';

  @override
  String get advanced => 'Gelişmiş';

  @override
  String ago(Object time) {
    return '$time önce';
  }

  @override
  String get all => 'Tümü';

  @override
  String get allPosts => 'Tüm Gönderiler';

  @override
  String get allowOpenSupportedLinks =>
      'Uygulamanın desteklenen bağlantıları açmasına izin ver.';

  @override
  String get alreadyPostedTo => 'Zaten şuraya gönderildi';

  @override
  String get altText => 'Alternatif Metin';

  @override
  String get alternateSources => 'Alternatif Kaynaklar';

  @override
  String get always => 'Her zaman';

  @override
  String andXMore(Object count) {
    return 've $count tane daha';
  }

  @override
  String get animations => 'Animasyonlar';

  @override
  String get anonymous => 'Anonim';

  @override
  String get anonymousInstances => 'Anonim Sunucular';

  @override
  String get appLanguage => 'Uygulama Dili';

  @override
  String get appearance => 'Görünüm';

  @override
  String get applePushNotificationService => 'Apple Anlık Bildirim Servisi';

  @override
  String get applied => 'Uygulandı';

  @override
  String get apply => 'Uygula';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return 'Bildirimlere sistem tarafından izin veriliyor: $yesOrNo';
  }

  @override
  String averageComments(Object x) {
    return '$x yorum/ay';
  }

  @override
  String averageContributions(Object x) {
    return '$x katkı/ay';
  }

  @override
  String averagePosts(Object x) {
    return '$x gönderi/ay';
  }

  @override
  String get back => 'Geri';

  @override
  String get backButton => 'Geri düğmesi';

  @override
  String get backToTop => 'Başa Dön';

  @override
  String get backgroundCheckWarning =>
      'Bildirim kontrollerinin ek pil tüketeceğini unutmayın';

  @override
  String get ban => 'Yasakla';

  @override
  String get banFromCommunity => 'Topluluktan Yasakla';

  @override
  String get bannedUser => 'Yasaklanmış Kullanıcı';

  @override
  String get bannedUserFromCommunity => 'Kullanıcı Topluluktan Yasaklandı';

  @override
  String get base => 'Temel';

  @override
  String get block => 'Engelle';

  @override
  String get blockCommunity => 'Topluluğu Engelle';

  @override
  String get blockCommunityInstance => 'Topluluk Sunucusunu Engelle';

  @override
  String get blockInstance => 'Sunucuyu Engelle';

  @override
  String get blockManagement => 'Engelleme Yönetimi';

  @override
  String get blockSettingLabel => 'Kullanıcı/Topluluk/Sunucu Engelleri';

  @override
  String get blockUser => 'Kullanıcıyı Engelle';

  @override
  String get blockUserInstance => 'Kullanıcı Sunucusunu Engelle';

  @override
  String get blockedCommunities => 'Engellenen Topluluklar';

  @override
  String get blockedInstances => 'Engellenen Sunucular';

  @override
  String get blockedUsers => 'Engellenen Kullanıcılar';

  @override
  String get blue => 'Mavi';

  @override
  String get bold => 'Kalın';

  @override
  String get boldCommunityName => 'Topluluk Adını Kalın Yap';

  @override
  String get boldInstanceName => 'Sunucu Adını Kalın Yap';

  @override
  String get boldUserName => 'Kullanıcı Adını Kalın Yap';

  @override
  String get bot => 'Bot';

  @override
  String get browserMode => 'Bağlantı yönetimi';

  @override
  String browsingAnonymously(Object instance) {
    return 'Şu anda $instance sunucusunda anonim olarak geziniyorsunuz.';
  }

  @override
  String get cancel => 'İptal';

  @override
  String get cannotReportOwnComment =>
      'Kendi yorumunuz için bir şikayet gönderemezsiniz.';

  @override
  String get cantBlockAdmin => 'Bir sunucu yöneticisini engelleyemezsiniz.';

  @override
  String get cantBlockYourself => 'Kendinizi engelleyemezsiniz.';

  @override
  String get cardPostCardMetadataItems => 'Kart Görünümü Meta Verileri';

  @override
  String get cardView => 'Kart Görünümü';

  @override
  String get cardViewDescription =>
      'Ayarları düzenlemek için kart görünümünü etkinleştirin';

  @override
  String get cardViewSettings => 'Kart Görünümü Ayarları';

  @override
  String get changeAccountSettingsFor => 'Şunun için hesap ayarlarını değiştir';

  @override
  String get changeNotificationSettings => 'Bildirim ayarlarını değiştir...';

  @override
  String get changePassword => 'Şifreyi Değiştir';

  @override
  String get changePasswordWarning =>
      'Şifrenizi değiştirmek için sunucu sitenize yönlendirileceksiniz. \n\nDevam etmek istediğinizden emin misiniz?';

  @override
  String get changeSort => 'Sıralamayı Değiştir';

  @override
  String clearCache(Object cacheSize) {
    return 'Önbelleği Temizle ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'Önbelleği Temizle';

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
  String get collapse => 'Daralt';

  @override
  String get collapseCommentPreview => 'Yorum Önizlemesini Daralt';

  @override
  String get collapseInformation => 'Bilgiyi Daralt';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'Daraltıldığında Üst Yorumu Gizle';

  @override
  String get collapsePost => 'Gönderiyi daralt';

  @override
  String get collapsePostPreview => 'Gönderi Önizlemesini Daralt';

  @override
  String get collapseSpoiler => 'Spoiler\'ı Daralt';

  @override
  String get color => 'Renk';

  @override
  String get colorizeCommunityName => 'Topluluk Adını Renklendir';

  @override
  String get colorizeInstanceName => 'Sunucu Adını Renklendir';

  @override
  String get colorizeUserName => 'Kullanıcı Adını Renklendir';

  @override
  String get colors => 'Renkler';

  @override
  String get combineCommentScores => 'Yorum Puanlarını Birleştir';

  @override
  String get combineCommentScoresLabel => 'Yorum Puanlarını Birleştir';

  @override
  String get combineNavAndFab => 'FAB ve Gezinme Düğmelerini Birleştir';

  @override
  String get combineNavAndFabDescription =>
      'Kayan Eylem Düğmesi, gezinme düğmeleri arasında gösterilecektir.';

  @override
  String get comfortable => 'Rahat';

  @override
  String get comment => 'Yorum';

  @override
  String get commentActions => 'Yorum İşlemleri';

  @override
  String get commentBehaviourSettings => 'Yorumlar';

  @override
  String get commentFontScale => 'Yorum İçeriği Yazı Tipi Ölçeği';

  @override
  String get commentPreview =>
      'Verilen ayarlarla yorumların bir önizlemesini göster';

  @override
  String get commentReported => 'Yorum incelenmek üzere işaretlendi.';

  @override
  String get commentSavedAsDraft => 'Yorum taslak olarak kaydedildi';

  @override
  String get commentShowUserAvatar => 'Kullanıcı Avatarını Göster';

  @override
  String get commentShowUserInstance => 'Kullanıcı Sunucusunu Göster';

  @override
  String get commentSortType => 'Yorum Sıralama Türü';

  @override
  String get commentSwipeActions => 'Yorum Kaydırma Eylemleri';

  @override
  String get commentSwipeGesturesHint =>
      'Bunun yerine düğmeleri mi kullanmak istiyorsunuz? Onları genel ayarlardaki yorumlar bölümünde etkinleştirin.';

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
    return 'Topluluk \'$community\'';
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
      'Ayarları düzenlemek için kompakt görünümü etkinleştirin';

  @override
  String get compactViewSettings => 'Kompakt Görünüm Ayarları';

  @override
  String get condensed => 'Yoğunlaştırılmış';

  @override
  String get confirm => 'Onayla';

  @override
  String get confirmLogOutBody => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get confirmLogOutTitle => 'Çıkış yapılsın mı?';

  @override
  String get confirmMarkAllAsReadBody =>
      'Tüm yanıtları, bahsetmeleri ve mesajları okundu olarak işaretlemek istediğinizden emin misiniz?';

  @override
  String get confirmMarkAllAsReadTitle => 'Tümü okundu olarak işaretlensin mi?';

  @override
  String get confirmResetCommentPreferences =>
      'Bu, tüm yorum tercihlerini sıfırlayacaktır. Devam etmek istediğinizden emin misiniz?';

  @override
  String get confirmResetPostPreferences =>
      'Bu, tüm gönderi tercihlerini sıfırlayacaktır. Devam etmek istediğinizden emin misiniz?';

  @override
  String get confirmUnsubscription =>
      'Abonelikten çıkmak istediğinizden emin misiniz?';

  @override
  String connectedToUnifiedPushDistributorApp(Object app) {
    return '$app uygulamasına bağlandı';
  }

  @override
  String get contentManagement => 'İçerik Yönetimi';

  @override
  String get contentWarning => 'İçerik Uyarısı';

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
  String get copyText => 'Metni Kopyala';

  @override
  String get couldNotDetermineCommentDelete =>
      'Hata: Yorumu silmek için gönderi belirlenemedi.';

  @override
  String get couldNotDeterminePostComment =>
      'Hata: Yorum yapılacak gönderi belirlenemedi.';

  @override
  String get couldntCreateReport =>
      'Yorum şikayetiniz şu anda gönderilemedi. Lütfen daha sonra tekrar deneyin';

  @override
  String get couldntFindPost =>
      'İstenen gönderi yüklenemiyor. Silinmiş veya kaldırılmış olabilir.';

  @override
  String countComments(Object count) {
    return '$count Yorum';
  }

  @override
  String countLocalSubscribers(Object count) {
    return '$count Yerel Abone';
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
    return 'Oluşturulma: $date';
  }

  @override
  String get createdToday => 'Bugün Oluşturuldu';

  @override
  String get creator => 'Oluşturan';

  @override
  String crossPostedFrom(Object postUrl) {
    return 'şuradan çapraz gönderildi: $postUrl';
  }

  @override
  String get crossPostedTo => 'Şuraya çapraz gönderildi';

  @override
  String get currentLongPress => 'Şu anda uzun basma olarak ayarlı';

  @override
  String currentNotificationsMode(Object mode) {
    return 'Mevcut bildirim modu: $mode';
  }

  @override
  String get currentSinglePress => 'Şu anda tek basma olarak ayarlı';

  @override
  String get customizeSwipeActions =>
      'Kaydırma eylemlerini özelleştir (değiştirmek için dokun)';

  @override
  String get dangerZone => 'Tehlikeli Bölge';

  @override
  String get dark => 'Karanlık';

  @override
  String get databaseExportWarning =>
      'Veritabanı, Lemmy hesabınızla ilgili hassas bilgiler içerebilir. Dışa aktarırsanız, kimseyle paylaşmamalısınız. Devam etmek istiyor musunuz?';

  @override
  String databaseExportedSuccessfully(Object savedFilePath) {
    return 'Veritabanı başarıyla \'$savedFilePath\' konumuna aktarıldı';
  }

  @override
  String get databaseImportedSuccessfully =>
      'Veritabanı başarıyla içe aktarıldı!';

  @override
  String get databaseNotExportedSuccessfully =>
      'Veritabanı başarıyla dışa aktarılamadı veya işlem iptal edildi.';

  @override
  String get databaseNotImportedSuccessfully =>
      'Veritabanı başarıyla içe aktarılamadı veya işlem iptal edildi.';

  @override
  String get dateFormat => 'Tarih Formatı';

  @override
  String get debug => 'Hata Ayıklama';

  @override
  String get debugDescription =>
      'Aşağıdaki hata ayıklama ayarları yalnızca sorun giderme amacıyla kullanılmalıdır.';

  @override
  String get debugNotificationsDescription =>
      'Bildirimlerle ilgili sorunları gidermek için aşağıdaki seçenekleri kullanın.';

  @override
  String get decline => 'Reddet';

  @override
  String get defaultColor => 'Varsayılan';

  @override
  String get defaultCommentSortType => 'Varsayılan Yorum Sıralama Türü';

  @override
  String get defaultFeedSortType => 'Varsayılan Akış Sıralama Türü';

  @override
  String get defaultFeedType => 'Varsayılan Akış Türü';

  @override
  String get delete => 'Sil';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountDescription =>
      'Hesabınızı kalıcı olarak silmek için sunucu sitenize yönlendirileceksiniz. \n\nDevam etmek istediğinizden emin misiniz?';

  @override
  String get deleteComment => 'Yorumu Sil';

  @override
  String get deleteDraftConfirmation =>
      'Are you sure you want to delete this draft?';

  @override
  String get deleteImageConfirmMessage =>
      'Bu resmi silmek istediğinizden emin misiniz?';

  @override
  String get deleteImageConfirmTitle => 'Silinsin mi?';

  @override
  String get deleteLocalDatabase => 'Yerel Veritabanını Sil';

  @override
  String get deleteLocalDatabaseDescription =>
      'Bu işlem yerel veritabanını kaldıracak ve tüm hesaplarınızdan çıkış yapmanızı sağlayacaktır.\n\nDevam etmek istediğinizden emin misiniz?';

  @override
  String get deleteLocalPreferences => 'Yerel Tercihleri Sil';

  @override
  String get deleteLocalPreferencesDescription =>
      'Bu, Thunder\'daki tüm kullanıcı tercihlerinizi ve ayarlarınızı temizleyecektir.\n\nDevam etmek istiyor musunuz?';

  @override
  String get deletePost => 'Gönderiyi Sil';

  @override
  String get deleteUserLabelConfirmation =>
      'Etiketi silmek istediğinizden emin misiniz?';

  @override
  String get deleted => 'Silindi';

  @override
  String get deletedByCreator => 'oluşturan tarafından silindi';

  @override
  String get deletedByModerator => 'moderatör tarafından silindi';

  @override
  String get deletedComment => 'Silinmiş yorum';

  @override
  String get deletedPost => 'Silinmiş gönderi';

  @override
  String get deselectUndeterminedWarning =>
      'Belirsiz\'i seçmezseniz, çoğu içeriği görmezsiniz.';

  @override
  String detailedReason(Object reason) {
    return 'Sebep: $reason';
  }

  @override
  String get dimReadPosts => 'Okunmuş Gönderileri Soluklaştır';

  @override
  String get directMessage => 'Direct message';

  @override
  String get disable => 'Devre Dışı Bırak';

  @override
  String get disablePushNotifications => 'Anlık Bildirimleri Devre Dışı Bırak';

  @override
  String get disabled => 'Devre dışı';

  @override
  String get discussionLanguages => 'Tartışma Dilleri';

  @override
  String get discussionLanguagesTooltip =>
      'İçerik, seçilen dillere göre filtrelenir.';

  @override
  String get dismissRead => 'Okunanı Kapat';

  @override
  String get displayName => 'Görünen Ad';

  @override
  String get displayUserScore => 'Kullanıcı Puanlarını (Karma) Görüntüle.';

  @override
  String get dividerAppearance => 'Ayırıcı Görünümü';

  @override
  String get doNotShowAgain => 'Tekrar Gösterme';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'Birden fazla uyumlu uygulama bulundu; lütfen yalnızca bir tane yükleyin';

  @override
  String get downloadingMedia => 'Paylaşmak için medya indiriliyor…';

  @override
  String get downvote => 'Eksi Oy';

  @override
  String get downvoteColor => 'Eksi Oy Rengi';

  @override
  String get downvoted => 'Eksi Oylandı';

  @override
  String get downvotesDisabled => 'Bu sunucuda eksi oylar kapalı.';

  @override
  String get drafts => 'Drafts';

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
      'Bağlantı boş. Devam etmek için lütfen geçerli bir dinamik bağlantı sağlayın.';

  @override
  String get enableCommentNavigation => 'Yorum Navigasyonunu Etkinleştir';

  @override
  String get enableExperimentalFeatures => 'Deneysel özellikleri etkinleştir';

  @override
  String get enableFeedFab => 'Akışlarda Kayan Düğmeyi Etkinleştir';

  @override
  String get enableFloatingButtonOnFeeds =>
      'Akışlarda Kayan Düğmeyi Etkinleştir';

  @override
  String get enableFloatingButtonOnPosts =>
      'Gönderilerde Kayan Düğmeyi Etkinleştir';

  @override
  String get enableInboxNotifications =>
      'Gelen Kutusu Bildirimlerini Etkinleştir';

  @override
  String get enablePostFab => 'Gönderilerde Kayan Düğmeyi Etkinleştir';

  @override
  String get endOfComments => 'Yorumların sonu';

  @override
  String get endSearch => 'Aramayı Bitir';

  @override
  String errorDeletingImage(Object error) {
    return 'Resim silinirken bir hata oluştu: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'Paylaşmak için medya dosyası indirilemedi: $errorMessage';
  }

  @override
  String get errorImportingAccountSettings =>
      'Ayarlar içe aktarılırken bir hata oluştu. Dosya doğru formatta olmayabilir.';

  @override
  String get errorInitializingClient => 'İstemci başlatılırken hata oluştu';

  @override
  String get errorLoadingAccountSettings =>
      'Ayarlar dosyası yüklenirken bir hata oluştu veya işlem iptal edildi.';

  @override
  String get errorMarkingReplyRead =>
      'Yanıt okundu olarak işaretlenirken bir hata oluştu.';

  @override
  String get errorMarkingReplyUnread =>
      'Yanıt okunmadı olarak işaretlenirken bir hata oluştu.';

  @override
  String get errorNoActiveInstance => 'Aktif sunucu bulunamadı';

  @override
  String get errorParsingJson =>
      'Seçilen dosya ayrıştırılırken bir hata oluştu. Geçerli bir JSON olmayabilir.';

  @override
  String get errorSavingAccountSettings =>
      'Ayarlar dosyası kaydedilirken bir hata oluştu veya işlem iptal edildi.';

  @override
  String get exceptionProcessingUri =>
      'Bağlantı işlenirken bir hata oluştu. Sunucunuzda mevcut olmayabilir.';

  @override
  String get excessiveApiCallsWarning =>
      'Anahtar kelime filtreleri nedeniyle akışınızın yüklenmesi biraz zaman alabilir.';

  @override
  String get expand => 'Genişlet';

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
      'Bu özellikler hala geliştirme aşamasındadır ve kararsız olabilir. Riski size ait olmak üzere kullanın. Etkili olması için Thunder\'ı yeniden başlatmanız gerekir.';

  @override
  String get exploreInstance => 'Sunucuyu keşfet';

  @override
  String get exportDatabase => 'Veritabanını Dışa Aktar';

  @override
  String get exportDatabaseSubtitle =>
      'Veritabanı hesaplar, favoriler, anonim abonelikler ve kullanıcı etiketleri hakkında bilgi içerir.';

  @override
  String get exportLemmyAccountSettingsDescription =>
      'Lemmy hesap ayarlarını dışa aktar';

  @override
  String get exportSettingsSubtitle =>
      'Ayarlar, Thunder\'da yapılandırdığınız tüm tercihleri içerir.';

  @override
  String get extraLarge => 'Çok Büyük';

  @override
  String failedToBlock(Object errorMessage) {
    return 'Engelleme başarısız: $errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return '$serverAddress adresindeki Thunder bildirim sunucusuyla iletişim kurulamadı.';
  }

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return 'Engeller yüklenemedi: $errorMessage';
  }

  @override
  String get failedToLoadVideo =>
      'Video yüklenemedi. Bağlantıyı tarayıcıda açmak ister misiniz?';

  @override
  String get failedToPerformAction => 'Eylem gerçekleştirilemedi';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'Engelleme kaldırılamadı: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'Bildirim ayarları güncellenemedi';

  @override
  String get favorite => 'Favori';

  @override
  String get favorites => 'Favoriler';

  @override
  String get featuredPost => 'Öne Çıkan Gönderi';

  @override
  String get feed => 'Akış';

  @override
  String get feedBehaviourSettings => 'Akış';

  @override
  String get feedSettings => 'Akış Ayarları';

  @override
  String get feedTypeAndSorts => 'Varsayılan Akış Türü ve Sıralama';

  @override
  String get fetchAccountError => 'Hesap belirlenemedi';

  @override
  String filteringBy(Object entity) {
    return '$entity ile filtreleniyor';
  }

  @override
  String get filters => 'Filtreler';

  @override
  String get floatingActionButton => 'Kayan Eylem Düğmesi';

  @override
  String get floatingActionButtonInformation =>
      'Thunder, birkaç hareketi destekleyen tamamen özelleştirilebilir bir FAB deneyimine sahiptir.\n- Ek FAB eylemlerini ortaya çıkarmak için yukarı kaydırın\n- FAB\'ı gizlemek veya göstermek için aşağı/yukarı kaydırın\n\nFAB için ana ve ikincil eylemleri özelleştirmek için aşağıdaki eylemlerden birine uzun basın.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'FAB\'ın uzun basma eylemini belirtir.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'FAB\'ın tek basma eylemini belirtir.';

  @override
  String get fonts => 'Yazı Tipleri';

  @override
  String get forward => 'İleri';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'Uyumlu uygulama bulundu; bağlanmak için Thunder\'ı yeniden başlatın';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'Soldan sağa hareketler devre dışı bırakıldığında geri gitmek için herhangi bir yere kaydırın';

  @override
  String get fullscreen => 'Tam ekran';

  @override
  String get fullscreenSwipeGestures => 'Tam Ekran Kaydırma Hareketleri';

  @override
  String get general => 'Genel';

  @override
  String get generalSettings => 'Genel Ayarlar';

  @override
  String get gestures => 'Hareketler';

  @override
  String get gettingStarted => 'Başlarken';

  @override
  String get green => 'Yeşil';

  @override
  String get guestModeFeedSettings => 'Misafir Modu Akış Ayarları';

  @override
  String get guestModeFeedSettingsLabel =>
      'Aşağıdaki ayarlar yalnızca misafir hesaplarına uygulanır. Hesabınız için akış ayarlarını düzenlemek için Hesap Ayarları\'na gidin.';

  @override
  String get havingIssuesWithNotifications =>
      'Bildirimlerle ilgili sorun mu yaşıyorsunuz?';

  @override
  String get hidCommunity => 'Topluluk Gizlendi';

  @override
  String get hidden => 'Gizli';

  @override
  String get hide => 'Gizle';

  @override
  String get hideBottomBarOnScroll => 'Kaydırma sırasında alt çubuğu gizle';

  @override
  String get hideColor => 'Gizleme Rengi';

  @override
  String get hideNsfwPostsFromFeed => 'NSFW Gönderileri Akıştan Gizle';

  @override
  String get hideNsfwPreviews => 'NSFW Önizlemelerini Bulanıklaştır';

  @override
  String get hidePassword => 'Şifreyi Gizle';

  @override
  String get hideThumbnails => 'Küçük Resimleri Gizle';

  @override
  String get hideTopBarOnScroll => 'Kaydırırken Üst Çubuğu Gizle';

  @override
  String get hostInstance => 'Barındıran Sunucu';

  @override
  String get hot => 'Popüler';

  @override
  String get image => 'Resim';

  @override
  String get imageCachingMode => 'Resim Önbellekleme Modu';

  @override
  String get imageCachingModeAggressive =>
      'Resimleri agresif bir şekilde önbelleğe al (daha fazla bellek kullanır)';

  @override
  String get imageCachingModeAggressiveShort => 'Agresif';

  @override
  String get imageCachingModeRelaxed =>
      'Resim önbelleklerinin süresinin dolmasına izin ver (daha az bellek kullanır ancak resimlerin daha sık yeniden yüklenmesine neden olur)';

  @override
  String get imageCachingModeRelaxedShort => 'Rahat';

  @override
  String get imageDimensionTimeout => 'Resim Boyutu Zaman Aşımı';

  @override
  String get imagePeekDuration => 'Görüntü önizleme süresi';

  @override
  String get imagePeekDurationDescription =>
      'Görüntü önizlemeyi tetiklemek için uzun basma süresi';

  @override
  String get importDatabase => 'Veritabanını İçe Aktar';

  @override
  String get importExportDatabase => 'Thunder Veritabanını İçe/Dışa Aktar';

  @override
  String get importExportLemmyAccountSettings =>
      'Lemmy Hesap Ayarlarını İçe/Dışa Aktar';

  @override
  String get importExportLemmyAccountSettingsSubtitle =>
      'Abone olunan toplulukları, engelleme listelerini ve hesap tercihlerini içerir';

  @override
  String get importExportSettings => 'Ayarları İçe/Dışa Aktar';

  @override
  String get importExportThunderSettings => 'Thunder Ayarlarını İçe/Dışa Aktar';

  @override
  String get importLemmyAccountSettingsDescription =>
      'Lemmy hesap ayarlarını içe aktar';

  @override
  String get importSettings => 'Ayarları İçe Aktar';

  @override
  String inReplyTo(Object post, Object community) {
    return '$post gönderisine $community içinde yanıt olarak';
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
  String get includeImage => 'Resmi Dahil Et';

  @override
  String get includePostLink => 'Gönderi Bağlantısını Dahil Et';

  @override
  String get includeText => 'Metni Dahil Et';

  @override
  String get includeTitle => 'Başlığı Dahil Et';

  @override
  String get information => 'Bilgi';

  @override
  String instance(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sunucu',
      one: 'Sunucu',
    );
    return '$_temp0';
  }

  @override
  String get instanceActions => 'Sunucu Eylemleri';

  @override
  String instanceEntry(Object username) {
    return 'Sunucu \'$username\'';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance zaten eklendi.';
  }

  @override
  String get instanceNameColor => 'Sunucu Adı Rengi';

  @override
  String get instanceNameThickness => 'Sunucu Adı Kalınlığı';

  @override
  String get instanceOffline => 'Instance is offline';

  @override
  String get instanceOnline => 'Instance is online';

  @override
  String get instanceStatusUnknown => 'Instance status unknown';

  @override
  String get instances => 'Sunucular';

  @override
  String get internetOrInstanceIssues =>
      'İnternete bağlı olmayabilirsiniz veya sunucunuz şu anda kullanılamıyor olabilir.';

  @override
  String get invalidUrl => 'Geçersiz URL formatı';

  @override
  String joined(Object x) {
    return 'Katılım: $x';
  }

  @override
  String get keywordFilterDescription =>
      'Başlık, gövde veya URL\'de herhangi bir anahtar kelime içeren gönderileri filtreler';

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
      'Gönderi yaptığınız topluluk, seçtiğiniz dilde gönderilere izin vermiyor. Başka bir dil deneyin.';

  @override
  String get large => 'Büyük';

  @override
  String get leftLongSwipe => 'Sola Uzun Kaydırma';

  @override
  String get leftShortSwipe => 'Sola Kısa Kaydırma';

  @override
  String get light => 'Aydınlık';

  @override
  String link(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bağlantı',
      one: 'Bağlantı',
    );
    return '$_temp0';
  }

  @override
  String get linkActions => 'Bağlantı Eylemleri';

  @override
  String get linkHandlingCustomTabs =>
      'Sistem tarayıcısında uygulama içi gömülü olarak aç';

  @override
  String get linkHandlingCustomTabsShort => 'Uygulama içi gömülü';

  @override
  String get linkHandlingExternal => 'Sistem tarayıcısında harici olarak aç';

  @override
  String get linkHandlingExternalShort => 'Harici';

  @override
  String get linkHandlingInApp => 'Thunder\'ın yerleşik tarayıcısını kullan';

  @override
  String get linkHandlingInAppShort => 'Uygulama içi';

  @override
  String get linkPostsUseCompactView => 'Kompakt bağlantı gönderilerini göster';

  @override
  String get linksBehaviourSettings => 'Bağlantılar';

  @override
  String loadMorePlural(Object count) {
    return '$count yanıt daha yükle…';
  }

  @override
  String loadMoreSingular(Object count) {
    return '$count yanıt daha yükle…';
  }

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get local => 'Yerel';

  @override
  String get localNotifications => 'Yerel Bildirimler';

  @override
  String get localOnly => 'Yalnızca Yerel';

  @override
  String get localPosts => 'Yerel Gönderiler';

  @override
  String get lockPost => 'Gönderiyi Kilitle';

  @override
  String get locked => 'Kilitli';

  @override
  String get lockedPost => 'Kilitli Gönderi';

  @override
  String get logOut => 'Çıkış Yap';

  @override
  String get login => 'Giriş Yap';

  @override
  String get loginAttemptCanceled => 'Giriş denemesi iptal edildi.';

  @override
  String loginFailed(Object errorMessage) {
    return 'Giriş yapılamadı. Lütfen tekrar deneyin. (Hata: $errorMessage)';
  }

  @override
  String get loginSucceeded => 'Giriş yapıldı.';

  @override
  String get loginToPerformAction =>
      'Bu görevi gerçekleştirmek için giriş yapmış olmanız gerekir.';

  @override
  String get loginToSeeInbox => 'Gelen kutunuzu görmek için giriş yapın';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'Hesaba özgü akış ayarlarını mı arıyorsunuz?';

  @override
  String get malformedUri =>
      'Sağladığınız bağlantı desteklenmeyen bir biçimde. Lütfen geçerli bir bağlantı olduğundan emin olun.';

  @override
  String get manageAccounts => 'Hesapları Yönet';

  @override
  String get manageMedia => 'Medyayı Yönet';

  @override
  String get markAllAsRead => 'Tümünü okundu olarak işaretle';

  @override
  String get markAsRead => 'Okundu olarak işaretle';

  @override
  String get markPostAsReadOnMediaView =>
      'Medyayı Görüntüledikten Sonra Okundu Olarak İşaretle';

  @override
  String get markPostAsReadOnScroll => 'Kaydırırken Okundu Olarak İşaretle';

  @override
  String get markReadColor => 'Okundu/Okunmadı Rengi';

  @override
  String get matrixUser => 'Matrix Kullanıcısı';

  @override
  String get me => 'Ben';

  @override
  String get media => 'Ortam';

  @override
  String get medium => 'Orta';

  @override
  String mention(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bahsetme',
      one: 'Bahsetme',
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
      other: 'Mesaj',
      one: 'Mesaj',
    );
    return '$_temp0';
  }

  @override
  String get metadataFontScale => 'Meta Veri Yazı Tipi Ölçeği';

  @override
  String get missingErrorMessage => 'Hata mesajı mevcut değil';

  @override
  String get modAdd => 'Sunucu Moderatörleri Ekle/Kaldır';

  @override
  String get modAddCommunity => 'Topluluklara Moderatör Ekle/Kaldır';

  @override
  String get modBan => 'Sunucu Kullanıcılarını Yasakla/Yasağı Kaldır';

  @override
  String get modBanFromCommunity =>
      'Kullanıcıları Topluluklardan Yasakla/Yasağını Kaldır';

  @override
  String get modFeaturePost => 'Gönderileri Öne Çıkar/Öne Çıkarmayı Kaldır';

  @override
  String get modLockPost => 'Gönderileri Kilitle/Kilidini Aç';

  @override
  String get modRemoveComment => 'Yorumları Kaldır/Geri Yükle';

  @override
  String get modRemoveCommunity => 'Toplulukları Kaldır/Geri Yükle';

  @override
  String get modRemovePost => 'Gönderileri Kaldır/Geri Yükle';

  @override
  String get modTransferCommunity => 'Toplulukları Aktarma';

  @override
  String get moderatedCommunities => 'Moderatörü Olduğum Topluluklar';

  @override
  String get moderates => 'Moderatörlükleri';

  @override
  String moderator(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moderatör',
      one: 'Moderatör',
    );
    return '$_temp0';
  }

  @override
  String get moderatorActions => 'Moderatör Eylemleri';

  @override
  String get modlog => 'Mod Kayıtları';

  @override
  String get mostComments => 'En Çok Yorum Alanlar';

  @override
  String get mustBeLoggedIn => 'Giriş yapmanız gerekiyor';

  @override
  String get mustBeLoggedInComment =>
      'Yorum yapmak için giriş yapmanız gerekiyor';

  @override
  String get mustBeLoggedInPost =>
      'Gönderi oluşturmak için giriş yapmanız gerekiyor';

  @override
  String get names => 'İsimler';

  @override
  String get navbarDoubleTapGestures =>
      'Gezinme Çubuğu Çift Dokunma Hareketleri';

  @override
  String get navbarSwipeGestures => 'Gezinme Çubuğu Kaydırma Hareketleri';

  @override
  String get navigateDown => 'Sonraki yorum';

  @override
  String get navigateUp => 'Önceki yorum';

  @override
  String get navigation => 'Gezinme';

  @override
  String get nestedCommentIndicatorColor => 'İç İçe Yorum Göstergesi Rengi';

  @override
  String get nestedCommentIndicatorStyle => 'İç İçe Yorum Göstergesi Stili';

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
  String get noAccountsAdded => 'Hiç hesap eklenmedi';

  @override
  String get noAnonymousInstances => 'Hiç anonim sunucu eklenmedi';

  @override
  String get noCommentsFound => 'Hiç yorum bulunamadı';

  @override
  String get noCommunitiesFound => 'Hiç topluluk bulunamadı';

  @override
  String get noCommunityBlocks => 'Engellenen topluluk yok';

  @override
  String get noCommunitySelected => 'No community selected';

  @override
  String get noCompatibleAppFound => 'Uyumlu uygulama bulunamadı';

  @override
  String get noDiscussionLanguages => 'Dile göre gizlenmiş içerik yok.';

  @override
  String get noDisplayNameSet => 'Görünen ad ayarlanmamış';

  @override
  String get noDrafts => 'You do not have any drafts yet';

  @override
  String get noEmailSet => 'E-posta ayarlanmamış';

  @override
  String get noFavoritedCommunities => 'Favori topluluk yok';

  @override
  String get noImages => 'Görünüşe göre hiç resim yüklemediniz.';

  @override
  String get noInstanceBlocks => 'Engellenen sunucu yok.';

  @override
  String get noItems => 'Öğe yok';

  @override
  String get noKeywordFilters => 'Eklenmiş anahtar kelime filtresi yok';

  @override
  String get noLanguage => 'Dil yok';

  @override
  String get noMatrixUserSet => 'Matrix kullanıcısı ayarlanmamış';

  @override
  String get noMentions => 'Bahsetme yok';

  @override
  String get noMessages => 'Mesaj yok';

  @override
  String get noPostsFound => 'Hiç gönderi bulunamadı.';

  @override
  String get noProfileBioSet => 'Profil biyografisi ayarlanmamış';

  @override
  String get noReferencesToImage =>
      'Bu resmi içeren hiçbir gönderi veya yorum bulunamadı. Ancak, internetin başka bir yerinde kullanılıyor olabilir.';

  @override
  String get noReplies => 'Yanıt yok';

  @override
  String get noResultsFound => 'Sonuç bulunamadı.';

  @override
  String get noSubscriptions => 'Abonelik Yok';

  @override
  String get noUserBlocks => 'Engellenen kullanıcı yok.';

  @override
  String get noUserLabels => 'Henüz hiç kullanıcı etiketi oluşturmadınız';

  @override
  String get noUsersFound => 'Hiç kullanıcı bulunamadı.';

  @override
  String get noVisibleComments =>
      'Topluluk engellendiği için yorumlar görünmüyor olabilir.';

  @override
  String get none => 'Hiçbiri';

  @override
  String get normal => 'Normal';

  @override
  String get notAvailable => 'N/A';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance geçerli bir örnek gibi görünmüyor';
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
      other: 'Bildirim',
      one: 'Bildirim',
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
      'Bildirimler, tüm cihazlarda doğru çalışmayabilecek **deneysel bir özelliktir**.\n\n - Kontroller yaklaşık 15 dakikada bir gerçekleşir ve ek pil tüketir.\n\n - Başarılı bildirim olasılığını artırmak için pil optimizasyonlarını devre dışı bırakın.\n\n Daha fazla bilgi için aşağıdaki sayfaya bakın.';

  @override
  String get nsfw => 'NSFW';

  @override
  String get nsfwWarning => 'NSFW - Görmek için dokunun';

  @override
  String get off => 'kapalı';

  @override
  String get offline => 'çevrimdışı';

  @override
  String get ok => 'Tamam';

  @override
  String get old => 'Eski';

  @override
  String get on => 'açık';

  @override
  String get onWifi => 'Wi-Fi\'de';

  @override
  String get onlyModsCanPostInCommunity =>
      'Bu toplulukta yalnızca moderatörler gönderi yapabilir';

  @override
  String get open => 'Aç';

  @override
  String get openAccountSwitcher => 'Hesap değiştiriciyi aç';

  @override
  String get openByDefault => 'Varsayılan olarak aç';

  @override
  String get openInBrowser => 'Tarayıcıda Aç';

  @override
  String get openInstance => 'Sunucuyu Aç';

  @override
  String get openLinksInExternalBrowser => 'Bağlantıları Harici Tarayıcıda Aç';

  @override
  String get openLinksInReaderMode => 'Bağlantıları Okuyucu Modunda Aç';

  @override
  String get openSettings => 'Ayarları Aç';

  @override
  String get orange => 'Turuncu';

  @override
  String get originalPoster => 'Gönderi Sahibi';

  @override
  String get overview => 'Genel Bakış';

  @override
  String get password => 'Şifre';

  @override
  String get pending => 'Beklemede';

  @override
  String performedBy(Object user) {
    return 'Gerçekleştiren: $user';
  }

  @override
  String get permissionDenied =>
      'Thunder\'a bildirimleri görüntüleme izni verilmedi. Lütfen sistem ayarlarında etkinleştirin.';

  @override
  String get permissionDeniedMessage =>
      'Thunder, bu resmi kaydetmek için reddedilen bazı izinlere ihtiyaç duyar.';

  @override
  String get piefedSupportBeta =>
      'PieFed support is currently in beta.\nNot all features are supported yet.';

  @override
  String get pinPostToCommunity => 'Gönderiyi Topluluğa Sabitle';

  @override
  String get pinToCommunity => 'Topluluğa Sabitle';

  @override
  String get pinned => 'Sabitlenmiş';

  @override
  String get pinnedPostToCommunity => 'Gönderi topluluğa sabitlendi';

  @override
  String get pinnedPostsUseCompactView =>
      'Kompakt sabitlenmiş gönderileri göster';

  @override
  String get placeholderText =>
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

  @override
  String get post => 'Gönderi';

  @override
  String get postActions => 'Gönderi Eylemleri';

  @override
  String get postBehaviourSettings => 'Gönderiler';

  @override
  String get postBody => 'Gönderi Metni';

  @override
  String get postBodySettings => 'Gönderi Metni Ayarları';

  @override
  String get postBodySettingsDescription =>
      'Bu ayarlar gönderi metninin görüntülenmesini etkiler';

  @override
  String get postBodyShowCommunityInstance => 'Topluluk Sunucusunu Göster';

  @override
  String get postBodyShowUserInstance => 'Kullanıcı Sunucusunu Göster';

  @override
  String get postBodyViewType => 'Gönderi Metni Görünüm Türü';

  @override
  String get postContentFontScale => 'Gönderi İçeriği Yazı Tipi Ölçeği';

  @override
  String get postCreatedSuccessfully => 'Gönderi başarıyla oluşturuldu!';

  @override
  String get postFlairs => 'Flairs';

  @override
  String get postFlairsUnavailable =>
      'No flair options available for this community';

  @override
  String get postLocked => 'Gönderi kilitli. Yanıtlara izin verilmiyor.';

  @override
  String get postMetadataInstructions =>
      'Meta veri bilgilerini istenen bilgileri sürükleyip bırakarak özelleştirebilirsiniz';

  @override
  String get postNSFW => 'NSFW olarak işaretle';

  @override
  String get postPreview =>
      'Verilen ayarlarla gönderinin bir önizlemesini göster';

  @override
  String get postSavedAsDraft => 'Gönderi taslak olarak kaydedildi';

  @override
  String get postShowUserInstance => 'Kullanıcı Sunucusunu Göster';

  @override
  String get postSwipeActions => 'Gönderi Kaydırma Eylemleri';

  @override
  String get postSwipeGesturesHint =>
      'Bunun yerine düğmeleri mi kullanmak istiyorsunuz? Genel ayarlarda gönderi kartlarında hangi düğmelerin görüneceğini değiştirin.';

  @override
  String get postTags => 'Tags';

  @override
  String get postTagsHelperText => 'Separate tags with commas';

  @override
  String get postTitle => 'Başlık';

  @override
  String get postTitleFontScale => 'Gönderi Başlığı Yazı Tipi Ölçeği';

  @override
  String get postTogglePreview => 'Önizlemeyi Aç/Kapat';

  @override
  String get postURL => 'URL';

  @override
  String get postUploadImageError => 'Resim yüklenemedi';

  @override
  String get postViewType => 'Gönderi Görünüm Türü';

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
  String get profileOperationInProgress => 'Profile operation in progress';

  @override
  String get profiles => 'Profiller';

  @override
  String get public => 'Herkese Açık';

  @override
  String get pureBlack => 'Saf Siyah';

  @override
  String get purgedComment => 'Temizlenmiş Yorum';

  @override
  String get purgedCommunity => 'Temizlenmiş Topluluk';

  @override
  String get purgedPerson => 'Temizlenmiş Kişi';

  @override
  String get purgedPost => 'Temizlenmiş Gönderi';

  @override
  String get purple => 'Mor';

  @override
  String get pushNotification => 'Anlık Bildirimler';

  @override
  String get pushNotificationDescription =>
      'Etkinleştirilirse, Thunder yeni bildirimleri yoklamak için JWT jeton(lar)ınızı sunucuya gönderir. \n\n **NOT:** Bu, uygulama bir sonraki başlatılana kadar etkili olmayacaktır.';

  @override
  String get pushNotificationServer => 'Anlık Bildirim Sunucusu';

  @override
  String get pushNotificationServerDescription =>
      'Anlık bildirim sunucusunu yapılandırın. Sunucunun cihazınıza anlık bildirim göndermek için doğru şekilde yapılandırılması gerekir.\n\n **Yalnızca kimlik bilgilerinizle güvendiğiniz bir sunucu girin.**';

  @override
  String get rateLimitErrorMessage =>
      'Bu istek için sınıra ulaştınız. Lütfen bekleyip daha sonra tekrar deneyin.';

  @override
  String get reachedTheBottom => 'Yüklenecek başka öğe yok';

  @override
  String get read => 'Okundu';

  @override
  String get readAll => 'Tümünü Oku';

  @override
  String get readerMode => 'Okuyucu modu';

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
  String get removeAsCommunityModerator => 'Topluluk Moderatörlüğünden Kaldır';

  @override
  String get removeComment => 'Yorumu Kaldır';

  @override
  String get removeFromFavorites => 'Favorilerden kaldır';

  @override
  String get removeInstance => 'Sunucuyu kaldır';

  @override
  String removeKeyword(Object keyword) {
    return '\"$keyword\" kaldırılsın mı?';
  }

  @override
  String get removeKeywordFilter => 'Anahtar Kelimeyi Kaldır';

  @override
  String get removePost => 'Gönderiyi Kaldır';

  @override
  String get removeUserData => 'Kullanıcısı verisini kaldır';

  @override
  String get removed => 'Kaldırıldı';

  @override
  String get removedComment => 'Kaldırılmış Yorum';

  @override
  String get removedCommunity => 'Kaldırılmış Topluluk';

  @override
  String get removedCommunityFromSubscriptions =>
      'Topluluk aboneliğinden çıkıldı';

  @override
  String get removedInstanceMod => 'Sunucu Modu Kaldırıldı';

  @override
  String get removedModFromCommunity => 'Topluluktan Mod Kaldırıldı';

  @override
  String get removedPost => 'Kaldırılmış Gönderi';

  @override
  String removedUserAsCommunityModerator(Object username) {
    return '$username topluluk moderatörlüğünden kaldırıldı';
  }

  @override
  String get reorder => 'Yeniden Sırala';

  @override
  String reply(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yanıtla',
      one: 'Yanıtla',
    );
    return '$_temp0';
  }

  @override
  String get replyColor => 'Yanıt Rengi';

  @override
  String get replyNotSupported =>
      'Bu görünümden yanıtlamak şu anda desteklenmiyor';

  @override
  String get replyToComment => 'Reply to Comment';

  @override
  String get replyToPost => 'Gönderiye Yanıtla';

  @override
  String replyingTo(Object author) {
    return '$author kullanıcısına yanıt veriliyor';
  }

  @override
  String report(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Şikayet',
      one: 'Şikayet',
    );
    return '$_temp0';
  }

  @override
  String get reportComment => 'Yorumu Şikayet Et';

  @override
  String get reportPost => 'Gönderiyi Şikayet Et';

  @override
  String get reportedComment => 'Yorum şikayet edildi';

  @override
  String get reportedPost => 'Gönderi şikayet edildi';

  @override
  String get reporter => 'Şikayet Eden:';

  @override
  String get requiredField => '*zorunlu';

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
  String get restore => 'Geri Yükle';

  @override
  String get restoreComment => 'Yorumu Geri Yükle';

  @override
  String get restorePost => 'Gönderiyi Geri Yükle';

  @override
  String get restoredComment => 'Yorum geri yüklendi';

  @override
  String get restoredCommentFromDraft => 'Taslaktan yorum geri yüklendi';

  @override
  String get restoredCommunity => 'Geri Yüklenmiş Topluluk';

  @override
  String get restoredPost => 'Geri Yüklenmiş Gönderi';

  @override
  String get restoredPostFromDraft => 'Taslaktan gönderi geri yüklendi';

  @override
  String get retry => 'Yeniden Dene';

  @override
  String get rightLongSwipe => 'Sağa Uzun Kaydırma';

  @override
  String get rightShortSwipe => 'Sağa Kısa Kaydırma';

  @override
  String get save => 'Kaydet';

  @override
  String get saveColor => 'Kaydetme Rengi';

  @override
  String get saveSettings => 'Ayarları Kaydet';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get scaled => 'Ölçeklendi';

  @override
  String get scrapeMissingLinkPreviews => 'Eksik Bağlantı Önizlemelerini Tara';

  @override
  String get screenReaderProfile => 'Ekran Okuyucu Profili';

  @override
  String get screenReaderProfileDescription =>
      'Genel öğeleri azaltarak ve potansiyel olarak çakışan hareketleri kaldırarak Thunder\'ı ekran okuyucular için optimize eder.';

  @override
  String get search => 'Ara';

  @override
  String get searchByText => 'Metne göre ara';

  @override
  String get searchByUrl => 'URL\'ye göre ara';

  @override
  String get searchComments => 'Yorumlarda Ara';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return '$instance ile federasyonlu yorumları ara';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return '$instance ile federasyonlu toplulukları ara';
  }

  @override
  String searchInstance(Object instance) {
    return '$instance Ara';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return '$instance ile federasyonlu sunucuları ara';
  }

  @override
  String get searchPostSearchType => 'Gönderi Arama Türünü Seç';

  @override
  String searchPostsFederatedWith(Object instance) {
    return '$instance ile federasyonlu gönderileri ara';
  }

  @override
  String get searchTerm => 'Arama terimi';

  @override
  String searchUsersFederatedWith(Object instance) {
    return '$instance ile federasyonlu kullanıcıları ara';
  }

  @override
  String get selectAccountToCommentAs => 'Yorum yapılacak hesabı seç';

  @override
  String get selectAccountToPostAs => 'Gönderi yapılacak hesabı seç';

  @override
  String get selectAll => 'Tümünü seç';

  @override
  String get selectCommunity => 'Bir topluluk seçin (gerekli)';

  @override
  String get selectFeedType => 'Akış Türünü Seç';

  @override
  String get selectLanguage => 'Dil Seç';

  @override
  String get selectRecipient => 'Select recipient';

  @override
  String get selectSearchType => 'Arama Türünü Seç';

  @override
  String get selectText => 'Metni Seç';

  @override
  String get send => 'Send';

  @override
  String get sendBackgroundTestLocalNotification =>
      'Arka planda test yerel bildirimi gönder';

  @override
  String get sendBackgroundTestUnifiedPushNotification =>
      'Arka planda test UnifiedPush bildirimi gönder';

  @override
  String get sendTestLocalNotification => 'Test yerel bildirimi gönder';

  @override
  String get sendTestUnifiedPushNotification =>
      'Test UnifiedPush bildirimi gönder';

  @override
  String get sensitiveContentWarning =>
      'Hassas içerik içerebilir. Görmek için dokunun.';

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
      'Bu ayarlar Thunder\'ın varsayılan ayarlarını geçersiz kılar.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return '$settingType türündeki ayarlar henüz desteklenmiyor.';
  }

  @override
  String get settings => 'Ayarlar';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'Ayarlar başarıyla \'$savedFilePath\' konumuna kaydedildi';
  }

  @override
  String get settingsFeedCards =>
      'Bu ayarlar ana akıştaki kartlara uygulanır, gönderileri açtığınızda eylemler her zaman kullanılabilir.';

  @override
  String get settingsImportedSuccessfully => 'Ayarlar başarıyla içe aktarıldı!';

  @override
  String get settingsNotExportedSuccessfully =>
      'Ayarlar başarıyla kaydedilemedi veya işlem iptal edildi.';

  @override
  String get settingsNotImportedSuccessfully =>
      'Ayarlar başarıyla içe aktarılamadı veya işlem iptal edildi.';

  @override
  String get settingsPage => 'Ayarlar Sayfası';

  @override
  String get settingsPageAbout => 'Hakkında';

  @override
  String get settingsPageAccessibility => 'Erişilebilirlik';

  @override
  String get settingsPageAccount => 'Hesap';

  @override
  String get settingsPageAccountBlocks => 'Engelleme Listeleri';

  @override
  String get settingsPageAccountLanguages => 'Tartışma Dilleri';

  @override
  String get settingsPageAccountMedia => 'Medyayı Yönet';

  @override
  String get settingsPageAppearance => 'Görünüm';

  @override
  String get settingsPageAppearanceComments => 'Yorumlar';

  @override
  String get settingsPageAppearancePosts => 'Gönderiler';

  @override
  String get settingsPageAppearanceTheming => 'Temalandırma';

  @override
  String get settingsPageDebug => 'Hata Ayıklama';

  @override
  String get settingsPageFilters => 'Filtreler';

  @override
  String get settingsPageFloatingActionButton => 'Kayan Eylem Düğmesi';

  @override
  String get settingsPageGeneral => 'Genel';

  @override
  String get settingsPageGestures => 'Hareketler';

  @override
  String get settingsPageUserLabels => 'Kullanıcı Etiketleri';

  @override
  String get settingsPageVideo => 'Video';

  @override
  String get share => 'Paylaş';

  @override
  String get shareComment => 'Yorum Bağlantısını Paylaş';

  @override
  String get shareCommentLocal => 'Yorum Bağlantısını Paylaş (Benim Sunucum)';

  @override
  String get shareCommunity => 'Topluluğu Paylaş';

  @override
  String get shareCommunityLink => 'Topluluk Bağlantısını Paylaş';

  @override
  String get shareCommunityLinkLocal =>
      'Topluluk Bağlantısını Paylaş (Benim Sunucum)';

  @override
  String get shareImage => 'Resmi Paylaş';

  @override
  String get shareLemmyLink => 'Lemmy Bağlantısını Paylaş';

  @override
  String get shareLink => 'Harici Bağlantıyı Paylaş';

  @override
  String get shareMedia => 'Medyayı Paylaş';

  @override
  String get shareMediaLink => 'Medya Bağlantısını Paylaş';

  @override
  String get shareOriginalLink => 'Orijinal Bağlantıyı Paylaş';

  @override
  String get sharePost => 'Gönderi Bağlantısını Paylaş';

  @override
  String get sharePostLocal => 'Gönderi Bağlantısını Paylaş (Benim Sunucum)';

  @override
  String get shareThumbnail => 'Küçük Resmi Paylaş';

  @override
  String get shareThumbnailAsImage => 'Küçük Resmi Resim Olarak Paylaş';

  @override
  String get shareUser => 'Kullanıcıyı Paylaş';

  @override
  String get shareUserLink => 'Kullanıcı Bağlantısını Paylaş';

  @override
  String get shareUserLinkLocal =>
      'Kullanıcı Bağlantısını Paylaş (Benim Sunucum)';

  @override
  String get showAll => 'Tümünü göster';

  @override
  String get showBotAccounts => 'Bot Hesaplarını Göster';

  @override
  String get showCommentActionButtons => 'Yorum Eylem Düğmelerini Göster';

  @override
  String get showCommunityDisplayNames => 'Topluluk Görünen Adlarını Göster';

  @override
  String get showCrossPosts => 'Çapraz Gönderileri Göster';

  @override
  String get showEdgeToEdgeImages => 'Kenardan Kenara Resimleri Göster';

  @override
  String get showExpandedTaglines => 'Genişletilmiş sloganları göster';

  @override
  String get showFullDate => 'Tam Tarihi Göster';

  @override
  String get showFullDateDescription => 'Gönderilerde tam tarihi göster';

  @override
  String get showFullHeightImages => 'Tam Yükseklikte Resimleri Göster';

  @override
  String get showHiddenPosts => 'Gizli Gönderileri Göster';

  @override
  String get showInAppUpdateNotifications =>
      'Yeni GitHub Sürümlerinden Haberdar Ol';

  @override
  String get showLess => 'Daha az göster';

  @override
  String get showMore => 'Daha fazla göster';

  @override
  String get showNavigationLabels => 'Gezinme Etiketlerini Göster';

  @override
  String get showNavigationLabelsDescription =>
      'Alt gezinme düğmelerinin altında etiketlerin gösterilip gösterilmeyeceği';

  @override
  String get showNsfwContent => 'NSFW İçeriği Göster';

  @override
  String get showOwnContent => 'Kendi içeriğini göster';

  @override
  String get showPassword => 'Şifreyi Göster';

  @override
  String get showPostAuthor => 'Gönderi Yazarını Göster';

  @override
  String get showPostAuthorSubtitle =>
      'Gönderi yazarı topluluk akışlarında her zaman gösterilir';

  @override
  String get showPostCommunityFirst => 'Topluluğu ve yazarı önce göster';

  @override
  String get showPostCommunityIcons => 'Topluluk Simgelerini Göster';

  @override
  String get showPostSaveAction => 'Kaydet Düğmesini Göster';

  @override
  String get showPostTextContentPreview => 'Metin Önizlemesini Göster';

  @override
  String get showPostTitleFirst => 'Önce Başlığı Göster';

  @override
  String get showPostVoteActions => 'Oy Düğmelerini Göster';

  @override
  String get showReadPosts => 'Okunmuş Gönderileri Göster';

  @override
  String get showSavedContent => 'Kaydedilen içeriği göster';

  @override
  String get showScoreCounters => 'Kullanıcı Puanlarını Görüntüle';

  @override
  String get showScores => 'Gönderi/Yorum Puanlarını Göster';

  @override
  String get showTextPostIndicator => 'Metin Gönderisi Göstergesini Göster';

  @override
  String get showThumbnailPreviewOnRight => 'Küçük Resimleri Sağda Göster';

  @override
  String get showUnreadOnly => 'Yalnızca okunmamışları göster';

  @override
  String get showUpdateChangelogs =>
      'Güncelleme Değişiklik Günlüklerini Göster';

  @override
  String get showUpdateChangelogsSubtitle =>
      'Bir güncellemeden sonra değişikliklerin bir listesini görüntüle';

  @override
  String get showUserAvatar => 'Kullanıcı Avatarını Göster';

  @override
  String get showUserDisplayNames => 'Kullanıcı Görünen Adlarını Göster';

  @override
  String get showUserInstance => 'Kullanıcı Sunucusunu Göster';

  @override
  String get sidebar => 'Kenar Çubuğu';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'Kenar çubuğunu açmak için alt gezinme çubuğuna çift dokunun';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'Kenar çubuğunu açmak için alt gezinme çubuğunu kaydırın';

  @override
  String get small => 'Küçük';

  @override
  String get somethingWentWrong => 'Bir şeyler ters gitti!';

  @override
  String get sortBy => 'Sırala';

  @override
  String get sortByTop => 'En İyilere Göre Sırala';

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
  String get subscribe => 'Abone Ol';

  @override
  String get subscribeToCommunity => 'Topluluğa Abone Ol';

  @override
  String get subscribed => 'Abone Olundu';

  @override
  String get subscriptionRequestSent => 'Abonelik isteği gönderildi';

  @override
  String get subscriptions => 'Abonelikler';

  @override
  String successfullyBannedUser(Object username) {
    return '$username yasaklandı';
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
    return '$username kullanıcısının yasağı kaldırıldı';
  }

  @override
  String get successfullyUnblocked => 'Engelleme kaldırıldı.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return '$communityName topluluğunun engeli kaldırıldı';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return '$username kullanıcısının engeli kaldırıldı';
  }

  @override
  String get suchAs => 'örneğin';

  @override
  String get suggestedTitle => 'Önerilen başlık';

  @override
  String switchedAccount(Object username) {
    return '$username hesabına geçildi';
  }

  @override
  String get system => 'Sistem';

  @override
  String get systemDarkMode => 'Saf Siyah';

  @override
  String get systemDarkModeDescription =>
      'Karanlık mod için saf siyah temayı etkinleştir';

  @override
  String get tabletMode => 'Tablet Modu (2 sütunlu görünüm)';

  @override
  String get tapToExit => 'Çıkmak için tekrar geri tuşuna basın';

  @override
  String get tappableAuthorCommunity => 'Dokunulabilir Yazarlar ve Topluluklar';

  @override
  String get teal => 'Camgöbeği';

  @override
  String get testBackgroundNotificationDescription =>
      'Thunder kendini kapatacak ve ardından arka planda bir bildirim oluşturmaya çalışacaktır. (En az 15 dakika sürecektir.)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'Thunder, bildirim sunucusundan gecikmeli bir bildirim göndermesini isteyecek ve ardından kendini kapatacaktır. (Birkaç dakika sürebilir.)';

  @override
  String get text => 'Metin';

  @override
  String get textActions => 'Metin Eylemleri';

  @override
  String get theme => 'Tema';

  @override
  String get themeAccentColor => 'Vurgu Renkleri';

  @override
  String get themePrimary => 'Birincil Tema Rengi';

  @override
  String get themeSecondary => 'İkincil Tema Rengi';

  @override
  String get themeTertiary => 'Üçüncül Tema Rengi';

  @override
  String get theming => 'Temalandırma';

  @override
  String get thickness => 'Kalınlık';

  @override
  String get thisAccount => 'Bu Hesap';

  @override
  String get thumbnailUrl => 'Küçük Resim URL\'si';

  @override
  String thunderHasBeenUpdated(Object version) {
    return 'Thunder $version sürümüne güncellendi!';
  }

  @override
  String thunderNotificationServer(Object server) {
    return 'Thunder Bildirim Sunucusu: $server';
  }

  @override
  String get timeoutComments =>
      'Hata: Yorumları getirmeye çalışırken zaman aşımı';

  @override
  String get timeoutErrorMessage => 'Bir yanıt beklerken zaman aşımı oldu.';

  @override
  String get timeoutSaveComment =>
      'Hata: Bir yorumu kaydetmeye çalışırken zaman aşımı';

  @override
  String get timeoutSavingPost =>
      'Hata: Gönderiyi kaydetmeye çalışırken zaman aşımı.';

  @override
  String get timeoutUpvoteComment =>
      'Hata: Yoruma oy vermeye çalışırken zaman aşımı';

  @override
  String get timeoutVotingPost =>
      'Hata: Gönderiye oy vermeye çalışırken zaman aşımı.';

  @override
  String get toggelRead => 'Okundu/Okunmadı Yap';

  @override
  String get top => 'En İyiler';

  @override
  String get topAll => 'Tüm Zamanların En İyileri';

  @override
  String get topDay => 'Bugünün En İyileri';

  @override
  String get topHour => 'Son Saatin En İyileri';

  @override
  String get topMonth => 'Ayın En İyileri';

  @override
  String get topNineMonths => 'Son 9 Ayın En İyileri';

  @override
  String get topSixHour => 'Son 6 Saatin En İyileri';

  @override
  String get topSixMonths => 'Son 6 Ayın En İyileri';

  @override
  String get topThreeMonths => 'Son 3 Ayın En İyileri';

  @override
  String get topTwelveHour => 'Son 12 Saatin En İyileri';

  @override
  String get topWeek => 'Haftanın En İyileri';

  @override
  String get topYear => 'Yılın En İyileri';

  @override
  String totalComments(Object x) {
    return '$x Yorum';
  }

  @override
  String totalPosts(Object x) {
    return '$x Gönderi';
  }

  @override
  String get totp => 'TOTP (isteğe bağlı)';

  @override
  String get transferredModToCommunity => 'Topluluk Aktarıldı';

  @override
  String get translationsMayNotBeComplete =>
      'Lütfen çevirilerin tam olmayabileceğini unutmayın';

  @override
  String get trendingCommunities => 'Trend Olan Topluluklar';

  @override
  String get trySearchingFor => 'Şunu aramayı deneyin...';

  @override
  String get unableToFindCommunity => 'Topluluk bulunamadı';

  @override
  String unableToFindCommunityName(Object communityName) {
    return '\'$communityName\' topluluğu bulunamadı';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'Seçilen topluluk, seçilen kullanıcının sunucusunda bulunamadı.';

  @override
  String get unableToFindInstance => 'Sunucu bulunamadı';

  @override
  String get unableToFindLanguage => 'Dil bulunamadı';

  @override
  String get unableToFindPost => 'Gönderi bulunamadı';

  @override
  String get unableToFindUser => 'Kullanıcı bulunamadı';

  @override
  String unableToFindUserName(Object username) {
    return '\'$username\' kullanıcısı bulunamadı';
  }

  @override
  String get unableToLoadImage => 'Resim yüklenemedi';

  @override
  String unableToLoadImageFrom(Object domain) {
    return '$domain adresinden resim yüklenemedi';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return '$instance yüklenemedi';
  }

  @override
  String get unableToLoadPost => 'Gönderi yüklenemedi';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return '$instance adresinden gönderiler yüklenemedi';
  }

  @override
  String get unableToLoadReplies => 'Daha fazla yanıt yüklenemedi.';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return '$instanceHost adresine gidilemiyor. Geçerli bir Lemmy sunucusu olmayabilir.';
  }

  @override
  String get unableToResolveReport => 'Şikayet çözümlenemedi';

  @override
  String unableToRetrieveChangelog(Object version) {
    return '$version sürümü için değişiklik günlüğü alınamadı.';
  }

  @override
  String get unbanFromCommunity => 'Topluluktan Yasağı Kaldır';

  @override
  String get unbannedUser => 'Yasağı Kaldırılmış Kullanıcı';

  @override
  String unbannedUserFromCommunity(Object username) {
    return '$username kullanıcısının topluluk yasağı kaldırıldı';
  }

  @override
  String get unblock => 'Engeli Kaldır';

  @override
  String get unblockCommunity => 'Topluluğun Engelini Kaldır';

  @override
  String get unblockCommunityInstance => 'Topluluk Sunucusunun Engelini Kaldır';

  @override
  String get unblockInstance => 'Sunucunun Engelini Kaldır';

  @override
  String get unblockUser => 'Kullanıcının Engelini Kaldır';

  @override
  String get unblockUserInstance => 'Kullanıcı Sunucusunun Engelini Kaldır';

  @override
  String get understandEnable => 'Anladım, Etkinleştir';

  @override
  String get unexpectedError => 'Beklenmeyen Hata';

  @override
  String get unfavorite => 'Favorilerden Çıkar';

  @override
  String get unfeaturedPost => 'Öne Çıkarılmamış Gönderi';

  @override
  String get unhidCommunity => 'Topluluk Gösterildi';

  @override
  String get unhide => 'Göster';

  @override
  String unifiedPushDistributorApp(Object app, Object count) {
    return 'UnifiedPush Dağıtıcı uygulaması: $app ($count mevcut)';
  }

  @override
  String get unifiedPushNotifications => 'UnifiedPush Bildirimleri';

  @override
  String unifiedPushServer(Object server) {
    return 'UnifiedPush Sunucusu: $server';
  }

  @override
  String get unifiedpush => 'UnifiedPush';

  @override
  String get unlockPost => 'Gönderinin Kilidini Aç';

  @override
  String get unlockedPost => 'Kilidi Açılmış Gönderi';

  @override
  String get unpinFromCommunity => 'Topluluktan Sabitlemeyi Kaldır';

  @override
  String get unpinPostFromCommunity =>
      'Gönderiyi Topluluktan Sabitlemeyi Kaldır';

  @override
  String get unpinnedPostFromCommunity =>
      'Topluluktaki sabitlenmiş gönderinin sabitlemesi kaldırıldı';

  @override
  String get unreachable => 'Ulaşılamıyor';

  @override
  String get unresolved => 'Çözülmemiş';

  @override
  String get unsubscribe => 'Abonelikten Çık';

  @override
  String get unsubscribeFromCommunity => 'Topluluktan Abonelikten Çık';

  @override
  String get unsubscribePending => 'Abonelikten Çık (abonelik beklemede)';

  @override
  String get unsubscribed => 'Abonelikten Çıkıldı';

  @override
  String get untitledCommentDraft => 'Untitled comment draft';

  @override
  String get untitledPostDraft => 'Untitled post draft';

  @override
  String updateReleased(Object version) {
    return 'Güncelleme yayınlandı: $version';
  }

  @override
  String get uploadImage => 'Resim yükle';

  @override
  String uploadedDate(Object date) {
    return 'Yüklendi: $date';
  }

  @override
  String get upvote => 'Artı Oy';

  @override
  String get upvoteColor => 'Artı Oy Rengi';

  @override
  String get upvoted => 'Artı Oylandı';

  @override
  String get uriNotSupported => 'Bu tür bir bağlantı şu anda desteklenmiyor.';

  @override
  String get url => 'URL';

  @override
  String get useAdvancedShareSheet => 'Gelişmiş Paylaşım Sayfasını Kullan';

  @override
  String get useApplePushNotifications => 'APNs Bildirimlerini Kullan';

  @override
  String get useApplePushNotificationsDescription =>
      'Apple\'ın Anlık Bildirim servisini kullanır';

  @override
  String get useCompactView =>
      'Küçük gönderiler için etkinleştirin, büyükler için devre dışı bırakın.';

  @override
  String get useLocalNotifications => 'Yerel Bildirimleri Kullan (Deneysel)';

  @override
  String get useLocalNotificationsDescription =>
      'Arka planda periyodik olarak bildirimleri kontrol eder';

  @override
  String get useMaterialYouTheme => 'Material You Temasını Kullan';

  @override
  String get useMaterialYouThemeDescription =>
      'Seçilen özel temayı geçersiz kılar';

  @override
  String get useProfilePictureForDrawer => 'Çekmece İçin Profil Resmini Kullan';

  @override
  String get useProfilePictureForDrawerSubtitle =>
      'Giriş yapıldığında, çekmece simgesi yerine kullanıcının profil resmini gösterir';

  @override
  String useSuggestedTitle(Object title) {
    return 'Önerilen başlığı kullan: $title';
  }

  @override
  String get useUnifiedPushNotifications => 'UnifiedPush Bildirimlerini Kullan';

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
  String get userLabels => 'Kullanıcı Etiketleri';

  @override
  String get userLabelsSettingsPageDescription =>
      'Kullanıcılarla ilişkili etiketleri ekleyebilir, değiştirebilir veya kaldırabilirsiniz.';

  @override
  String get userNameColor => 'Kullanıcı Adı Rengi';

  @override
  String get userNameThickness => 'Kullanıcı Adı Kalınlığı';

  @override
  String get userNotLoggedIn => 'Kullanıcı giriş yapmamış';

  @override
  String get userProfiles => 'Kullanıcı Profilleri';

  @override
  String get userSettingDescription =>
      'Bu ayarlar Lemmy hesabınızla senkronize olur ve yalnızca hesap bazında uygulanır.';

  @override
  String get userStyle => 'Kullanıcı Stili';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get usernameFormattingRedirect =>
      'Kullanıcı adı biçimlendirmesi mi arıyorsunuz?';

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
  String get videoAutoLoop => 'Videoyu Döngüye Al';

  @override
  String get videoAutoMute => 'Videoları Sessize Al';

  @override
  String get videoAutoPlay => 'Video Otomatik Oynatma';

  @override
  String get videoDefaultPlaybackSpeed => 'Varsayılan Oynatma Hızı';

  @override
  String get videoLinkHandlingExternal =>
      'Videoyu harici bir uygulamayla oynat';

  @override
  String get videoPlayerInApp => 'Thunder yerleşik oynatıcısını kullan';

  @override
  String get videoPlayerMode => 'Oynatıcı Modu';

  @override
  String get viewAll => 'Tümünü görüntüle';

  @override
  String get viewAllComments => 'Tüm yorumları görüntüle';

  @override
  String get viewCommentSource => 'Yorum Kaynağını Görüntüle';

  @override
  String get viewModlog => 'Mod Kayıtlarını Görüntüle';

  @override
  String get viewOriginal => 'Orijinali görüntüle';

  @override
  String get viewPostAsDifferentAccount =>
      'Gönderiyi farklı hesap olarak görüntüle';

  @override
  String get viewPostSource => 'Gönderi kaynağını görüntüle';

  @override
  String get viewSource => 'Kaynağı görüntüle';

  @override
  String get viewingAll => 'Tümü görüntüleniyor';

  @override
  String visibility(Object visibility) {
    return 'Görünürlük: $visibility';
  }

  @override
  String get visitCommunity => 'Topluluğu Ziyaret Et';

  @override
  String get visitCommunityInstance => 'Topluluk Sunucusunu Ziyaret Et';

  @override
  String get visitInstance => 'Sunucuyu Ziyaret Et';

  @override
  String get visitUserInstance => 'Kullanıcı Sunucusunu Ziyaret Et';

  @override
  String get visitUserProfile => 'Kullanıcı Profilini Ziyaret Et';

  @override
  String get warning => 'Uyarı';

  @override
  String xDownvotes(Object x) {
    return '$x eksi oy';
  }

  @override
  String xScore(Object x) {
    return '$x puan';
  }

  @override
  String xUpvotes(Object x) {
    return '$x artı oy';
  }

  @override
  String xYearsOld(num count, Object x) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$x yaşında',
      one: '$x yaşında',
    );
    return '$_temp0';
  }

  @override
  String get yes => 'Evet';

  @override
  String get youMustSelectAJsonFile => 'Bir .json dosyası seçmelisiniz.';
}
