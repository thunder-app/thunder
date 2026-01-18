// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get about => 'பற்றி';

  @override
  String get accept => 'ஏற்றுக்கொள்';

  @override
  String get accessibility => 'அணுகல்';

  @override
  String get accessibilityProfilesDescription =>
      'அணுகல் சுயவிவரங்கள் ஒரு குறிப்பிட்ட அணுகல் தேவைக்கு ஏற்ப பல அமைப்புகளை ஒரே நேரத்தில் பயன்படுத்த அனுமதிக்கிறது.';

  @override
  String account(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'கணக்குகள்',
      one: 'கணக்கு',
      zero: 'Account',
    );
    return '$_temp0 ';
  }

  @override
  String accountBirthday(Object additionalInfo) {
    return 'கணக்கு பிறந்த நாள் $additionalInfo';
  }

  @override
  String get accountSettingOverrideWarning =>
      'உங்கள் கணக்கு அமைப்புகள் பின்வரும் அமைப்புகளை மீறுகின்றன';

  @override
  String get accountSettings => 'கணக்கு அமைப்புகள்';

  @override
  String accountSettingsExportedSuccessfully(Object savedFilePath) {
    return 'லெம்மி கணக்கு அமைப்புகள் வெற்றிகரமாக $savedFilePath க்கு ஏற்றுமதி செய்யப்பட்டன!';
  }

  @override
  String get accountSettingsImportedSuccessfully =>
      'லெம்மி கணக்கு அமைப்புகள் வெற்றிகரமாக இறக்குமதி செய்யப்படுகின்றன!';

  @override
  String accountSwitchParentCommentNotFound(Object instance) {
    return 'தேர்ந்தெடுக்கப்பட்ட கருத்து \'$instance\' இல் காணப்படவில்லை';
  }

  @override
  String accountSwitchPostNotFound(Object instance) {
    return 'தேர்ந்தெடுக்கப்பட்ட இடுகை \'$instance\' இல் காணப்படவில்லை';
  }

  @override
  String get actionColors => 'செயல் வண்ணங்கள்';

  @override
  String get actionColorsRedirect =>
      'வண்ணங்களைத் தனிப்பயனாக்க விரும்புகிறீர்களா?';

  @override
  String get actions => 'செயல்கள்';

  @override
  String get active => 'செயலில்';

  @override
  String get activity => 'செய்கைப்பாடு';

  @override
  String get add => 'கூட்டு';

  @override
  String get addAccount => 'கணக்கைச் சேர்க்கவும்';

  @override
  String get addAccountToSeeProfile => 'உங்கள் கணக்கைக் காண உள்நுழைக.';

  @override
  String get addAnonymousInstance => 'அநாமதேய நிகழ்வைச் சேர்க்கவும்';

  @override
  String get addAsCommunityModerator => 'சமூக மதிப்பீட்டாளராகச் சேர்க்கவும்';

  @override
  String get addDiscussionLanguage => 'மொழியைச் சேர்க்கவும்';

  @override
  String get addKeywordFilter => 'முக்கிய சொல்லைச் சேர்க்கவும்';

  @override
  String get addOriginalPostBody => 'அசல் இடுகை உடலைச் சேர்க்கவா?';

  @override
  String get addToFavorites => 'பிடித்தவைகளில் சேர்க்கவும்';

  @override
  String get addUserLabel => 'பயனர் லேபிளைச் சேர்க்கவும்';

  @override
  String get addedCommunityToSubscriptions => 'சமூகத்திற்கு குழுசேர்ந்தது';

  @override
  String get addedInstanceMod => 'நிகழ்வு மோட் சேர்க்கப்பட்டது';

  @override
  String get addedModToCommunity => 'சமூகத்திற்கு மோட் சேர்க்கப்பட்டது';

  @override
  String addedUserAsCommunityModerator(Object username) {
    return 'சமூக மதிப்பீட்டாளராக $username சேர்க்கப்பட்டார்';
  }

  @override
  String get admin => 'நிர்வாகி';

  @override
  String get advanced => 'மேம்பட்ட';

  @override
  String ago(Object time) {
    return '$time முன்பு';
  }

  @override
  String get all => 'அனைத்தும்';

  @override
  String get allPosts => 'அனைத்து இடுகைகளும்';

  @override
  String get allowOpenSupportedLinks =>
      'உதவி இணைப்புகளைத் திறக்க பயன்பாட்டை அனுமதிக்கவும்.';

  @override
  String get alreadyPostedTo => 'ஏற்கனவே இடுகையிடப்பட்டது';

  @override
  String get altText => 'மாற்று உரை';

  @override
  String get alternateSources => 'மாற்று ஆதாரங்கள்';

  @override
  String get always => 'எப்போதும்';

  @override
  String andXMore(Object count) {
    return 'மேலும் $count மேலும்';
  }

  @override
  String get animations => 'அனிமேசன்கள்';

  @override
  String get anonymous => 'அநாமதேய';

  @override
  String get anonymousInstances => 'அநாமதேய நிகழ்வுகள்';

  @override
  String get appLanguage => 'பயன்பாட்டு மொழி';

  @override
  String get appearance => 'தோற்றம்';

  @override
  String get applePushNotificationService => 'ஆப்பிள் புச் அறிவிப்பு பணி';

  @override
  String get applied => 'பயன்படுத்தப்பட்டது';

  @override
  String get apply => 'இடு';

  @override
  String areNotificationsAllowedBySystem(Object yesOrNo) {
    return 'அறிவிப்புகள் கணினி மூலம் அனுமதிக்கப்படுகின்றன: $yesOrNo';
  }

  @override
  String averageComments(Object x) {
    return '$x கருத்துகள்/மாதம்';
  }

  @override
  String averageContributions(Object x) {
    return '$x பங்களிப்புகள்/மாதம்';
  }

  @override
  String averagePosts(Object x) {
    return '$x இடுகைகள்/மாதம்';
  }

  @override
  String get back => 'பின்';

  @override
  String get backButton => 'பின் பொத்தான்';

  @override
  String get backToTop => 'மீண்டும் மேலே';

  @override
  String get backgroundCheckWarning =>
      'அறிவிப்பு காசோலைகள் கூடுதல் பேட்டரியை நுகரும் என்பதை நினைவில் கொள்க';

  @override
  String get ban => 'தடை வெற்றி';

  @override
  String get banFromCommunity => 'சமூகத்திலிருந்து தடை';

  @override
  String get bannedUser => 'தடைசெய்யப்பட்ட பயனர்';

  @override
  String get bannedUserFromCommunity => 'சமூகத்திலிருந்து தடைசெய்யப்பட்ட பயனர்';

  @override
  String get base => 'காரம்';

  @override
  String get block => 'தொகுதி';

  @override
  String get blockCommunity => 'தொகுதி சமூகம்';

  @override
  String get blockCommunityInstance => 'சமூக உதாரணத்தைத் தடுக்கும்';

  @override
  String get blockInstance => 'தொகுதி நிகழ்வு';

  @override
  String get blockManagement => 'தொகுதி மேலாண்மை';

  @override
  String get blockSettingLabel => 'பயனர்/சமூகம்/நிகழ்வு தொகுதிகள்';

  @override
  String get blockUser => 'தொகுதி பயனர்';

  @override
  String get blockUserInstance => 'பயனர் உதாரணத்தைத் தடுக்கும்';

  @override
  String get blockedCommunities => 'தடுக்கப்பட்ட சமூகங்கள்';

  @override
  String get blockedInstances => 'தடுக்கப்பட்ட நிகழ்வுகள்';

  @override
  String get blockedUsers => 'தடுக்கப்பட்ட பயனர்கள்';

  @override
  String get blue => 'நீலம்';

  @override
  String get bold => 'தடிமான';

  @override
  String get boldCommunityName => 'தைரியமான சமூக பெயர்';

  @override
  String get boldInstanceName => 'தைரியமான நிகழ்வு பெயர்';

  @override
  String get boldUserName => 'தைரியமான பயனர் பெயர்';

  @override
  String get bot => 'போட்';

  @override
  String get browserMode => 'இணைப்பு கையாளுதல்';

  @override
  String browsingAnonymously(Object instance) {
    return 'நீங்கள் தற்போது $instance அநாமதேயமாக உலாவுகிறீர்கள்.';
  }

  @override
  String get cancel => 'ரத்துசெய்';

  @override
  String get cannotReportOwnComment =>
      'உங்கள் சொந்த கருத்துக்கு நீங்கள் ஒரு அறிக்கையை சமர்ப்பிக்கக்கூடாது.';

  @override
  String get cantBlockAdmin =>
      'நீங்கள் ஒரு நிகழ்வு நிர்வாகியைத் தடுக்கக்கூடாது.';

  @override
  String get cantBlockYourself => 'நீங்களே தடுக்கக்கூடாது.';

  @override
  String get cardPostCardMetadataItems => 'அட்டை பார்வை மேனிலை தரவு';

  @override
  String get cardView => 'அட்டை பார்வை';

  @override
  String get cardViewDescription =>
      'அமைப்புகளை சரிசெய்ய அட்டை காட்சியை இயக்கவும்';

  @override
  String get cardViewSettings => 'அட்டை காட்சி அமைப்புகள்';

  @override
  String get changeAccountSettingsFor => 'கணக்கு அமைப்புகளை மாற்றவும்';

  @override
  String get changeNotificationSettings => 'அறிவிப்பு அமைப்புகளை மாற்றவும் ...';

  @override
  String get changePassword => 'கடவுச்சொல்லை மாற்றவும்';

  @override
  String get changePasswordWarning =>
      'உங்கள் கடவுச்சொல்லை மாற்ற, நீங்கள் உங்கள் நிகழ்வு தளத்திற்கு திருப்பி விடப்படுவீர்கள்.\n\n நீங்கள் தொடர விரும்புகிறீர்களா?';

  @override
  String get changeSort => 'வரிசைப்படுத்துங்கள்';

  @override
  String clearCache(Object cacheSize) {
    return 'தெளிவான தற்காலிக சேமிப்பு ($cacheSize)';
  }

  @override
  String get clearCacheLabel => 'தெளிவான தற்காலிக சேமிப்பு';

  @override
  String get clearDatabase => 'தரவுத்தளத்தை அழிக்கவும்';

  @override
  String get clearPreferences => 'தெளிவான விருப்பத்தேர்வுகள்';

  @override
  String get clearSearch => 'தேடலை அழி';

  @override
  String get clearedCache => 'கேச் வெற்றிகரமாக அழிக்கப்பட்டது.';

  @override
  String get clearedDatabase =>
      'உள்ளக தரவுத்தளம் அழிக்கப்பட்டது. புதிய மாற்றங்கள் நடைமுறைக்கு வர தண்டரை மறுதொடக்கம் செய்யுங்கள்.';

  @override
  String get clearedUserPreferences =>
      'அனைத்து பயனர் விருப்பங்களையும் அழித்துவிட்டது';

  @override
  String get close => 'மூடு';

  @override
  String get collapse => 'சரிவு';

  @override
  String get collapseCommentPreview => 'கருத்து முன்னோட்டம்';

  @override
  String get collapseInformation => 'தகவல்களை சரிவு';

  @override
  String get collapseParentCommentBodyOnGesture =>
      'சரிந்தபோது பெற்றோரின் கருத்தை மறைக்கவும்';

  @override
  String get collapsePost => 'வீழ்ச்சி இடுகை';

  @override
  String get collapsePostPreview => 'இடுகை முன்னோட்டத்தை வீழ்த்துங்கள்';

  @override
  String get collapseSpoiler => 'ச்பாய்லர் சரிவு';

  @override
  String get color => 'நிறம்';

  @override
  String get colorizeCommunityName => 'சமூக பெயரை வண்ணமயமாக்கவும்';

  @override
  String get colorizeInstanceName => 'நிகழ்வு பெயரை வண்ணமயமாக்குங்கள்';

  @override
  String get colorizeUserName => 'பயனர் பெயரை வண்ணமயமாக்குங்கள்';

  @override
  String get colors => 'நிறங்கள்';

  @override
  String get combineCommentScores => 'கருத்து மதிப்பெண்களை இணைக்கவும்';

  @override
  String get combineCommentScoresLabel => 'கருத்து மதிப்பெண்களை இணைக்கவும்';

  @override
  String get combineNavAndFab =>
      'FAB மற்றும் வழிசெலுத்தல் பொத்தான்களை இணைக்கவும்';

  @override
  String get combineNavAndFabDescription =>
      'வழிசெலுத்தல் பொத்தான்களுக்கு இடையில் மிதக்கும் செயல் பொத்தானைக் காண்பிக்கும்.';

  @override
  String get comfortable => 'வசதியானது';

  @override
  String get comment => 'கருத்து';

  @override
  String get commentActions => 'கருத்து நடவடிக்கைகள்';

  @override
  String get commentBehaviourSettings => 'கருத்துகள்';

  @override
  String get commentFontScale => 'கருத்து உள்ளடக்க எழுத்துரு அளவு';

  @override
  String get commentPreview =>
      'கொடுக்கப்பட்ட அமைப்புகளுடன் கருத்துகளின் முன்னோட்டத்தைக் காட்டுங்கள்';

  @override
  String get commentReported => 'கருத்து மதிப்பாய்வுக்காக குறிக்கப்பட்டுள்ளது.';

  @override
  String get commentSavedAsDraft => 'கருத்து வரைவாக சேமிக்கப்பட்டது';

  @override
  String get commentShowUserAvatar => 'பயனர் அவதாரத்தைக் காட்டு';

  @override
  String get commentShowUserInstance => 'பயனர் உதாரணத்தைக் காட்டு';

  @override
  String get commentSortType => 'கருத்து வரிசை வகை';

  @override
  String get commentSwipeActions => 'கருத்து ச்வைப் செயல்கள்';

  @override
  String get commentSwipeGesturesHint =>
      'அதற்கு பதிலாக பொத்தான்களைப் பயன்படுத்த விரும்புகிறீர்களா? பொது அமைப்புகளில் கருத்துகள் பிரிவில் அவற்றை இயக்கவும்.';

  @override
  String get comments => 'கருத்துகள்';

  @override
  String get communities => 'சமூகங்கள்';

  @override
  String get community => 'சமூகம்';

  @override
  String get communityActions => 'சமூக நடவடிக்கைகள்';

  @override
  String communityEntry(Object community) {
    return 'சமூகம் \'$community\'';
  }

  @override
  String get communityFormat => 'சமூக வடிவம்';

  @override
  String get communityNameColor => 'சமூக பெயர் நிறம்';

  @override
  String get communityNameThickness => 'சமூக பெயர் தடிமன்';

  @override
  String get communityStyle => 'சமூக நடை';

  @override
  String get compact => 'கச்சிதமான';

  @override
  String get compactPostCardMetadataItems => 'சிறிய பார்வை மேனிலை தரவு';

  @override
  String get compactView => 'சிறிய பார்வை';

  @override
  String get compactViewDescription =>
      'அமைப்புகளை சரிசெய்ய சிறிய பார்வையை இயக்கவும்';

  @override
  String get compactViewSettings => 'சிறிய பார்வை அமைப்புகள்';

  @override
  String get condensed => 'ஒடுக்கப்பட்ட';

  @override
  String get confirm => 'உறுதிப்படுத்தவும்';

  @override
  String get confirmLogOutBody =>
      'நீங்கள் நிச்சயமாக வெளியேற விரும்புகிறீர்களா?';

  @override
  String get confirmLogOutTitle => 'வெளியேறு?';

  @override
  String get confirmMarkAllAsReadBody =>
      'எல்லா பதில்கள், குறிப்பிடல்கள் மற்றும் செய்திகளையும் படித்ததாகக் குறிக்க விரும்புகிறீர்களா?';

  @override
  String get confirmMarkAllAsReadTitle => 'அனைத்தையும் படித்தபடி குறிக்கவும்?';

  @override
  String get confirmResetCommentPreferences =>
      'இது அனைத்து கருத்து விருப்பங்களையும் மீட்டமைக்கும். நீங்கள் தொடர விரும்புகிறீர்களா?';

  @override
  String get confirmResetPostPreferences =>
      'இது அனைத்து இடுகை விருப்பங்களையும் மீட்டமைக்கும். நீங்கள் தொடர விரும்புகிறீர்களா?';

  @override
  String get confirmUnsubscription =>
      'நீங்கள் நிச்சயமாக குழுவிலக விரும்புகிறீர்களா?';

  @override
  String connectedToUnifiedPushDistributorApp(Object app) {
    return '$app உடன் இணைக்கப்பட்டுள்ளது';
  }

  @override
  String get contentManagement => 'உள்ளடக்க மேலாண்மை';

  @override
  String get contentWarning => 'உள்ளடக்க எச்சரிக்கை';

  @override
  String get controversial => 'சர்ச்சைக்குரிய';

  @override
  String get copiedToClipboard => 'இடைநிலைப்பலகைக்கு நகலெடுக்கப்பட்டது';

  @override
  String get copy => 'நகலெடு';

  @override
  String get copyComment => 'கருத்து நகல்';

  @override
  String get copySelected => 'தேர்ந்தெடுக்கப்பட்ட நகல்';

  @override
  String get copyText => 'உரையை நகலெடுக்கவும்';

  @override
  String get couldNotDetermineCommentDelete =>
      'பிழை: கருத்தை நீக்க இடுகையை தீர்மானிக்க முடியவில்லை.';

  @override
  String get couldNotDeterminePostComment =>
      'பிழை: கருத்து தெரிவிக்க இடுகையை தீர்மானிக்க முடியவில்லை.';

  @override
  String get couldntCreateReport =>
      'இந்த நேரத்தில் உங்கள் கருத்து அறிக்கையை சமர்ப்பிக்க முடியவில்லை. தயவுசெய்து பின்னர் மீண்டும் முயற்சிக்கவும்';

  @override
  String get couldntFindPost =>
      'கோரப்பட்ட இடுகையை ஏற்ற முடியவில்லை. இது நீக்கப்பட்டிருக்கலாம் அல்லது அகற்றப்பட்டிருக்கலாம்.';

  @override
  String countComments(Object count) {
    return '$count கருத்துகள்';
  }

  @override
  String countLocalSubscribers(Object count) {
    return '$count உள்ளக சந்தாதாரர்கள்';
  }

  @override
  String countPosts(Object count) {
    return '$count இடுகைகள்';
  }

  @override
  String countSubscribers(Object count) {
    return '$count சந்தாதாரர்கள்';
  }

  @override
  String countUsers(Object count) {
    return '$count பயனர்கள்';
  }

  @override
  String countUsersActiveDay(Object count) {
    return '$count பயனர்கள்/நாள்';
  }

  @override
  String countUsersActiveHalfYear(Object count) {
    return '$count பயனர்கள்/6 மோ';
  }

  @override
  String countUsersActiveMonth(Object count) {
    return '$count பயனர்கள்/மோ';
  }

  @override
  String countUsersActiveWeek(Object count) {
    return '$count பயனர்கள்/WK';
  }

  @override
  String get createAccount => 'கணக்கை உருவாக்கவும்';

  @override
  String get createComment => 'கருத்தை உருவாக்குங்கள்';

  @override
  String get createNewCrossPost => 'புதிய குறுக்கு இடுகையை உருவாக்கவும்';

  @override
  String get createPost => 'இடுகையை உருவாக்கவும்';

  @override
  String created(Object date) {
    return 'உருவாக்கப்பட்டது $date';
  }

  @override
  String get createdToday => 'இன்று உருவாக்கப்பட்டது';

  @override
  String get creator => 'உருவாக்கியவர்';

  @override
  String crossPostedFrom(Object postUrl) {
    return 'குறுக்கு இடுகையிடப்பட்டது: $postUrl';
  }

  @override
  String get crossPostedTo => 'குறுக்கு இடுகையிடப்பட்டது';

  @override
  String get currentLongPress =>
      'தற்போது நீண்ட பத்திரிகையாக அமைக்கப்பட்டுள்ளது';

  @override
  String currentNotificationsMode(Object mode) {
    return 'தற்போதைய அறிவிப்புகள் பயன்முறை: $mode';
  }

  @override
  String get currentSinglePress =>
      'தற்போது ஒற்றை பத்திரிகையாக அமைக்கப்பட்டுள்ளது';

  @override
  String get customizeSwipeActions =>
      'ச்வைப் செயல்களைத் தனிப்பயனாக்குங்கள் (மாற்றத் தட்டவும்)';

  @override
  String get dangerZone => 'இடர் மண்டலம்';

  @override
  String get dark => 'இருண்ட';

  @override
  String get databaseExportWarning =>
      'தரவுத்தளத்தில் உங்கள் லெம்மி கணக்கு தொடர்பான முக்கியமான தகவல்கள் இருக்கலாம். நீங்கள் அதை ஏற்றுமதி செய்தால், அதை யாருடனும் பகிர்ந்து கொள்ளக்கூடாது. நீங்கள் தொடர விரும்புகிறீர்களா?';

  @override
  String databaseExportedSuccessfully(Object savedFilePath) {
    return 'தரவுத்தளம் வெற்றிகரமாக \'$savedFilePath\' க்கு ஏற்றுமதி செய்யப்பட்டது';
  }

  @override
  String get databaseImportedSuccessfully =>
      'தரவுத்தளம் வெற்றிகரமாக இறக்குமதி செய்யப்பட்டது!';

  @override
  String get databaseNotExportedSuccessfully =>
      'தரவுத்தளம் வெற்றிகரமாக ஏற்றுமதி செய்யப்படவில்லை அல்லது செயல்பாடு ரத்து செய்யப்பட்டது.';

  @override
  String get databaseNotImportedSuccessfully =>
      'தரவுத்தளம் வெற்றிகரமாக இறக்குமதி செய்யப்படவில்லை, அல்லது செயல்பாடு ரத்து செய்யப்பட்டது.';

  @override
  String get dateFormat => 'தேதி வடிவம்';

  @override
  String get debug => 'பிழைத்திருத்தம்';

  @override
  String get debugDescription =>
      'பின்வரும் பிழைத்திருத்த அமைப்புகள் சரிசெய்தல் நோக்கங்களுக்காக மட்டுமே பயன்படுத்தப்பட வேண்டும்.';

  @override
  String get debugNotificationsDescription =>
      'அறிவிப்புகள் தொடர்பான சிக்கல்களை சரிசெய்ய பின்வரும் விருப்பங்களைப் பயன்படுத்தவும்.';

  @override
  String get decline => 'வீழ்ச்சி';

  @override
  String get defaultColor => 'இயல்புநிலை';

  @override
  String get defaultCommentSortType => 'இயல்புநிலை கருத்து வரிசை வகை';

  @override
  String get defaultFeedSortType => 'இயல்புநிலை ஊட்ட வரிசை வகை';

  @override
  String get defaultFeedType => 'இயல்புநிலை தீவன வகை';

  @override
  String get delete => 'நீக்கு';

  @override
  String get deleteAccount => 'கணக்கை நீக்கு';

  @override
  String get deleteAccountDescription =>
      'உங்கள் கணக்கை நிரந்தரமாக நீக்க, நீங்கள் உங்கள் நிகழ்வு தளத்திற்கு திருப்பி விடப்படுவீர்கள்.\n\n நீங்கள் தொடர விரும்புகிறீர்களா?';

  @override
  String get deleteComment => 'கருத்தை நீக்கு';

  @override
  String get deleteImageConfirmMessage =>
      'இந்த படத்தை நீக்க விரும்புகிறீர்களா?';

  @override
  String get deleteImageConfirmTitle => 'நீக்கவா?';

  @override
  String get deleteLocalDatabase => 'உள்ளக தரவுத்தளத்தை நீக்கு';

  @override
  String get deleteLocalDatabaseDescription =>
      'இந்த நடவடிக்கை உள்ளக தரவுத்தளத்தை அகற்றும், மேலும் உங்கள் எல்லா கணக்குகளிலிருந்தும் உங்களை உள்நுழைகிறது.\n\n நீங்கள் தொடர விரும்புகிறீர்களா?';

  @override
  String get deleteLocalPreferences => 'உள்ளக விருப்பங்களை நீக்கு';

  @override
  String get deleteLocalPreferencesDescription =>
      'இது உங்கள் பயனர் விருப்பத்தேர்வுகள் மற்றும் அமைப்புகளை இடியில் அழிக்கும்.\n\n நீங்கள் தொடர விரும்புகிறீர்களா?';

  @override
  String get deletePost => 'இடுகையை நீக்கு';

  @override
  String get deleteUserLabelConfirmation =>
      'நீங்கள் நிச்சயமாக லேபிளை நீக்க விரும்புகிறீர்களா?';

  @override
  String get deleted => 'நீக்கப்பட்டது';

  @override
  String get deletedByCreator => 'படைப்பாளரால் நீக்கப்பட்டது';

  @override
  String get deletedByModerator => 'மதிப்பீட்டாளரால் நீக்கப்பட்டது';

  @override
  String get deletedComment => 'நீக்கப்பட்ட கருத்து';

  @override
  String get deletedPost => 'நீக்கப்பட்ட இடுகை';

  @override
  String get deselectUndeterminedWarning =>
      'நீங்கள் தீர்மானிக்கப்படாமல் தேர்வுசெய்தால், நீங்கள் பெரும்பாலான உள்ளடக்கங்களைக் காண மாட்டீர்கள்.';

  @override
  String detailedReason(Object reason) {
    return 'காரணம்: $reason';
  }

  @override
  String get dimReadPosts => 'மங்கலான இடுகைகள்';

  @override
  String get disable => 'முடக்கு';

  @override
  String get disablePushNotifications => 'புச் அறிவிப்புகளை முடக்கு';

  @override
  String get disabled => 'முடக்கப்பட்டது';

  @override
  String get discussionLanguages => 'கலந்துரையாடல் மொழிகள்';

  @override
  String get discussionLanguagesTooltip =>
      'தேர்ந்தெடுக்கப்பட்ட மொழிகளுக்கு உள்ளடக்கம் வடிகட்டப்படுகிறது.';

  @override
  String get dismissRead => 'படித்தல்';

  @override
  String get displayName => 'காட்சி பெயர்';

  @override
  String get displayUserScore => 'பயனர் மதிப்பெண்களைக் காண்பி (கர்மா).';

  @override
  String get dividerAppearance => 'வகுப்பி தோற்றம்';

  @override
  String get doNotShowAgain => 'மீண்டும் காட்ட வேண்டாம்';

  @override
  String get doNotSupportMultipleUnifiedPushApps =>
      'பல இணக்கமான பயன்பாடுகள் கிடைத்தன; ஒன்றை மட்டும் நிறுவவும்';

  @override
  String get downloadingMedia => 'பகிர ஊடகத்தைப் பதிவிறக்குகிறது…';

  @override
  String get downvote => 'கீழ்வாக்கு';

  @override
  String get downvoteColor => 'வண்ணத்தை குறைக்கிறது';

  @override
  String get downvoted => 'கீழ்வாக்கிடப்பட்டது';

  @override
  String get downvotesDisabled =>
      'இந்த நிகழ்வில் டவுன்வோட்டுகள் அணைக்கப்படுகின்றன.';

  @override
  String get edit => 'தொகு';

  @override
  String get editComment => 'எப்படி திருத்து';

  @override
  String get editPost => 'இடுகையைத் திருத்து';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get empty => 'காலி';

  @override
  String get emptyInbox => 'வெற்று இன்பாக்ச்';

  @override
  String get emptyUri =>
      'இணைப்பு காலியாக உள்ளது. தொடர சரியான மாறும் இணைப்பை வழங்கவும்.';

  @override
  String get enableCommentNavigation => 'கருத்து வழிசெலுத்தலை இயக்கவும்';

  @override
  String get enableExperimentalFeatures => 'சோதனை அம்சங்களை இயக்கவும்';

  @override
  String get enableFeedFab => 'ஊட்டங்களில் மிதக்கும் பொத்தானை இயக்கவும்';

  @override
  String get enableFloatingButtonOnFeeds =>
      'ஊட்டங்களில் மிதக்கும் பொத்தானை இயக்கவும்';

  @override
  String get enableFloatingButtonOnPosts =>
      'இடுகைகளில் மிதக்கும் பொத்தானை இயக்கவும்';

  @override
  String get enableInboxNotifications => 'இன்பாக்ச் அறிவிப்புகளை இயக்கவும்';

  @override
  String get enablePostFab => 'இடுகைகளில் மிதக்கும் பொத்தானை இயக்கவும்';

  @override
  String get endOfComments => 'கருத்துகளின் முடிவு';

  @override
  String get endSearch => 'இறுதி தேடல்';

  @override
  String errorDeletingImage(Object error) {
    return 'படத்தை நீக்குவதில் பிழை இருந்தது: $error';
  }

  @override
  String errorDownloadingMedia(Object errorMessage) {
    return 'பகிர்வதற்கு மீடியா கோப்பை பதிவிறக்கம் செய்ய முடியவில்லை: $errorMessage';
  }

  @override
  String get errorImportingAccountSettings =>
      'அமைப்புகளை இறக்குமதி செய்வதில் பிழை ஏற்பட்டது. கோப்பு சரியான வடிவத்தில் இருக்காது.';

  @override
  String get errorInitializingClient => 'கிளையண்டை துவக்குவதில் பிழை';

  @override
  String get errorLoadingAccountSettings =>
      'அமைப்புகள் கோப்பை ஏற்றுவதில் பிழை ஏற்பட்டது அல்லது செயல்பாடு ரத்து செய்யப்பட்டது.';

  @override
  String get errorMarkingReplyRead => 'பதிலைக் குறிக்கும் பிழை இருந்தது.';

  @override
  String get errorMarkingReplyUnread =>
      'பதிலை படிக்காதது எனக் குறிக்கும் பிழை ஏற்பட்டது.';

  @override
  String get errorNoActiveInstance => 'செயலில் நிகழ்வு எதுவும் கிடைக்கவில்லை';

  @override
  String get errorParsingJson =>
      'தேர்ந்தெடுக்கப்பட்ட கோப்பை பாகுபடுத்துவதில் பிழை ஏற்பட்டது. இது செல்லுபடியாகாது சேசன்.';

  @override
  String get errorSavingAccountSettings =>
      'அமைப்புகள் கோப்பைச் சேமிப்பதில் பிழை ஏற்பட்டது அல்லது செயல்பாடு ரத்து செய்யப்பட்டது.';

  @override
  String get exceptionProcessingUri =>
      'இணைப்பை செயலாக்கும்போது பிழை ஏற்பட்டது. இது உங்கள் நிகழ்வில் கிடைக்காமல் போகலாம்.';

  @override
  String get excessiveApiCallsWarning =>
      'முக்கிய வடிப்பான்கள் காரணமாக ஏற்றுவதற்கு உங்கள் ஊட்டம் சிறிது நேரம் ஆகலாம்.';

  @override
  String get expand => 'விரிவாக்கு';

  @override
  String get expandCommentPreview => 'கருத்து முன்னோட்டத்தை விரிவாக்குங்கள்';

  @override
  String get expandInformation => 'தகவல்களை விரிவாக்குங்கள்';

  @override
  String get expandOptions => 'விருப்பங்களை விரிவாக்குங்கள்';

  @override
  String get expandPost => 'இடுகையை விரிவாக்கு';

  @override
  String get expandPostPreview => 'இடுகை முன்னோட்டத்தை விரிவாக்குங்கள்';

  @override
  String get expandSpoiler => 'ச்பாய்லரை விரிவாக்கு';

  @override
  String get expanded => 'விரிவாக்கப்பட்டது';

  @override
  String get experimentalFeatures => 'சோதனை நற்பொருத்தங்கள்';

  @override
  String get experimentalFeaturesDescription =>
      'இந்த நற்பொருத்தங்கள் இன்னும் வளர்ச்சியில் உள்ளன மற்றும் நிலையற்றதாக இருக்கலாம். அவற்றை உங்கள் சொந்த ஆபத்தில் பயன்படுத்தவும். நடைமுறைக்கு வர நீங்கள் தண்டரை மறுதொடக்கம் செய்ய வேண்டும்.';

  @override
  String get exploreInstance => 'நிகழ்வை ஆராயுங்கள்';

  @override
  String get exportDatabase => 'ஏற்றுமதி தரவுத்தளம்';

  @override
  String get exportDatabaseSubtitle =>
      'தரவுத்தளத்தில் கணக்குகள், பிடித்தவை, அநாமதேய சந்தாக்கள் மற்றும் பயனர் லேபிள்கள் பற்றிய தகவல்கள் உள்ளன.';

  @override
  String get exportLemmyAccountSettingsDescription =>
      'லெம்மி கணக்கு அமைப்புகளை ஏற்றுமதி செய்யுங்கள்';

  @override
  String get exportSettingsSubtitle =>
      'அமைப்புகளில் நீங்கள் இடியில் கட்டமைக்கப்பட்ட அனைத்து விருப்பங்களும் அடங்கும்.';

  @override
  String get extraLarge => 'கூடுதல் பெரிய';

  @override
  String failedToBlock(Object errorMessage) {
    return 'தடுப்பதில் தோல்வி: $errorMessage';
  }

  @override
  String failedToCommunicateWithThunderNotificationServer(
      Object serverAddress) {
    return '$serverAddress இல் Thunder அறிவிப்பு சேவையகத்துடன் தொடர்பு கொள்ள முடியவில்லை.';
  }

  @override
  String failedToLoadBlocks(Object errorMessage) {
    return 'தொகுதிகளை ஏற்ற முடியவில்லை: $errorMessage';
  }

  @override
  String get failedToLoadVideo =>
      'வீடியோவை ஏற்றுவதில் தோல்வி. உலாவியில் இணைப்பை திறக்கவா?';

  @override
  String get failedToPerformAction => 'செயலைச் செய்யத் தவறிவிட்டது';

  @override
  String failedToUnblock(Object errorMessage) {
    return 'தடைசெய்ய முடியவில்லை: $errorMessage';
  }

  @override
  String get failedToUpdateNotificationSettings =>
      'அறிவிப்பு அமைப்புகளைப் புதுப்பிக்கத் தவறிவிட்டது';

  @override
  String get favorite => 'பிடித்த';

  @override
  String get favorites => 'பிடித்தவை';

  @override
  String get featuredPost => 'பிரத்யேக இடுகை';

  @override
  String get feed => 'தீவனம்';

  @override
  String get feedBehaviourSettings => 'தீவனம்';

  @override
  String get feedSettings => 'அமைப்புகளுக்கு உணவளிக்கவும்';

  @override
  String get feedTypeAndSorts => 'இயல்புநிலை தீவன வகை மற்றும் வரிசையாக்கம்';

  @override
  String get fetchAccountError => 'கணக்கை தீர்மானிக்க முடியவில்லை';

  @override
  String filteringBy(Object entity) {
    return '$entity மூலம் வடிகட்டுதல்';
  }

  @override
  String get filters => 'வடிப்பான்கள்';

  @override
  String get floatingActionButton => 'மிதக்கும் செயல் பொத்தான்';

  @override
  String get floatingActionButtonInformation =>
      'தண்டர் ஒரு சில சைகைகளை ஆதரிக்கும் ஒரு முழுமையான தனிப்பயனாக்கக்கூடிய ஃபேப் அனுபவத்தைக் கொண்டுள்ளது.\n - கூடுதல் FAB செயல்களை வெளிப்படுத்த ச்வைப் செய்யவும்\n - ஃபேப்பை மறைக்க அல்லது வெளிப்படுத்த கீழே/மேலே ச்வைப்/மேலே\n\n FAB க்கான முக்கிய மற்றும் இரண்டாம் நிலை செயல்களைத் தனிப்பயனாக்க, கீழேயுள்ள செயல்களில் ஒன்றை நீண்ட அழுத்தவும்.';

  @override
  String get floatingActionButtonLongPressDescription =>
      'ஃபேப்பின் நீண்டகால செயலாக்கத்தைக் குறிக்கிறது.';

  @override
  String get floatingActionButtonSinglePressDescription =>
      'ஃபேப்பின் ஒற்றை-பத்திரிகை செயலைக் குறிக்கிறது.';

  @override
  String get fonts => 'எழுத்துருக்கள்';

  @override
  String get forward => 'முன்னோக்கி';

  @override
  String get foundUnifiedPushDistribtorApp =>
      'இணக்கமான பயன்பாட்டைக் கண்டறிந்தது; இணைக்க தண்டரை மறுதொடக்கம் செய்யுங்கள்';

  @override
  String get fullScreenNavigationSwipeDescription =>
      'இடமிருந்து வலமாக சைகைகள் முடக்கப்பட்டிருக்கும் போது திரும்பிச் செல்ல எங்கும் ச்வைப் செய்யவும்';

  @override
  String get fullscreen => 'முழு திரை';

  @override
  String get fullscreenSwipeGestures => 'முழுத்திரை ச்வைப் சைகைகள்';

  @override
  String get general => 'பொது';

  @override
  String get generalSettings => 'பொது அமைப்புகள்';

  @override
  String get gestures => 'சைகைகள்';

  @override
  String get gettingStarted => 'தொடங்குதல்';

  @override
  String get green => 'பச்சை';

  @override
  String get guestModeFeedSettings => 'விருந்தினர் பயன்முறை தீவன அமைப்புகள்';

  @override
  String get guestModeFeedSettingsLabel =>
      'பின்வரும் அமைப்புகள் விருந்தினர் கணக்குகளுக்கு மட்டுமே பயன்படுத்தப்படுகின்றன. உங்கள் கணக்கிற்கான ஊட்ட அமைப்புகளை சரிசெய்ய, கணக்கு அமைப்புகளுக்குச் செல்லவும்.';

  @override
  String get havingIssuesWithNotifications =>
      'அறிவிப்புகளில் சிக்கல்கள் உள்ளதா?';

  @override
  String get hidCommunity => 'மறை சமூகம்';

  @override
  String get hidden => 'மறைக்கப்பட்ட';

  @override
  String get hide => 'மறை';

  @override
  String get hideBottomBarOnScroll => 'Hide Bottom Bar on Scroll';

  @override
  String get hideColor => 'நிறத்தை மறைக்கவும்';

  @override
  String get hideNsfwPostsFromFeed =>
      'ஊட்டத்திலிருந்து NSFW இடுகைகளை மறைக்கவும்';

  @override
  String get hideNsfwPreviews => 'மங்கலான NSFW முன்னோட்டங்கள்';

  @override
  String get hidePassword => 'கடவுச்சொல்லை மறைக்கவும்';

  @override
  String get hideThumbnails => 'சிறு உருவங்களை மறைக்கவும்';

  @override
  String get hideTopBarOnScroll => 'சுருளில் மேல் பட்டியை மறைக்கவும்';

  @override
  String get hostInstance => 'புரவலன் நிகழ்வு';

  @override
  String get hot => 'சூடான';

  @override
  String get image => 'படம்';

  @override
  String get imageCachingMode => 'பட கேச்சிங் பயன்முறை';

  @override
  String get imageCachingModeAggressive =>
      'படங்களை ஆக்ரோசமாக கேச் (அதிக நினைவகத்தைப் பயன்படுத்துகிறது)';

  @override
  String get imageCachingModeAggressiveShort => 'வன்கவர்வு';

  @override
  String get imageCachingModeRelaxed =>
      'பட தற்காலிக சேமிப்புகள் காலாவதியாகட்டும் (குறைந்த நினைவகத்தைப் பயன்படுத்துகிறது, ஆனால் படங்களை அடிக்கடி மீண்டும் ஏற்றுகிறது)';

  @override
  String get imageCachingModeRelaxedShort => 'நிதானமாக';

  @override
  String get imageDimensionTimeout => 'பட பரிமாண நேரம் முடிந்தது';

  @override
  String get imagePeekDuration => 'Image Peek Duration';

  @override
  String get imagePeekDurationDescription =>
      'Duration of long press before image peek is triggered';

  @override
  String get importDatabase => 'தரவுத்தளத்தை இறக்குமதி செய்யுங்கள்';

  @override
  String get importExportDatabase =>
      'தண்டர் தரவுத்தளத்தை இறக்குமதி/ஏற்றுமதி செய்யுங்கள்';

  @override
  String get importExportLemmyAccountSettings =>
      'லெம்மி கணக்கு அமைப்புகளை இறக்குமதி/ஏற்றுமதி செய்யுங்கள்';

  @override
  String get importExportLemmyAccountSettingsSubtitle =>
      'சந்தா சமூகங்கள், தடுப்புப்பட்டிகள் மற்றும் கணக்கு விருப்பத்தேர்வுகள் அடங்கும்';

  @override
  String get importExportSettings => 'இறக்குமதி/ஏற்றுமதி அமைப்புகள்';

  @override
  String get importExportThunderSettings =>
      'தண்டர் அமைப்புகளை இறக்குமதி/ஏற்றுமதி செய்யுங்கள்';

  @override
  String get importLemmyAccountSettingsDescription =>
      'லெம்மி கணக்கு அமைப்புகளை இறக்குமதி செய்யுங்கள்';

  @override
  String get importSettings => 'அமைப்புகளை இறக்குமதி செய்யுங்கள்';

  @override
  String inReplyTo(Object post, Object community) {
    return '$communityஇல் $postஇதற்குப் பதிலளிக்கும் விதமாக';
  }

  @override
  String get in_ => 'இல்';

  @override
  String get inbox => 'இன்பாக்ச்';

  @override
  String get includeCommunity => 'சமூகத்தைச் சேர்க்கவும்';

  @override
  String get includeExternalLink => 'வெளிப்புற இணைப்பைச் சேர்க்கவும்';

  @override
  String get includeImage => 'படத்தைச் சேர்க்கவும்';

  @override
  String get includePostLink => 'இடுகை இணைப்பு சேர்க்கவும்';

  @override
  String get includeText => 'உரை சேர்க்கவும்';

  @override
  String get includeTitle => 'தலைப்பு சேர்க்கவும்';

  @override
  String get information => 'தகவல்';

  @override
  String instance(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'நிகழ்வுகள்',
      one: 'நிகழ்வு',
      zero: 'நிகழ்வு',
    );
    return '$_temp0 ';
  }

  @override
  String get instanceActions => 'நிகழ்வு செயல்கள்';

  @override
  String instanceEntry(Object username) {
    return 'சான்று \'$username\'';
  }

  @override
  String instanceHasAlreadyBenAdded(Object instance) {
    return '$instance ஏற்கனவே சேர்க்கப்பட்டுள்ளது.';
  }

  @override
  String get instanceNameColor => 'உதாரணத்தின் பெயர் நிறம்';

  @override
  String get instanceNameThickness => 'உதாரணத்தின் பெயர் தடிமன்';

  @override
  String get instances => 'நிகழ்வுகள்';

  @override
  String get internetOrInstanceIssues =>
      'நீங்கள் இணையத்துடன் இணைக்கப்படாமல் இருக்கலாம், அல்லது உங்கள் நிகழ்வு தற்போது கிடைக்காமல் இருக்கலாம்.';

  @override
  String get invalidUrl => 'தவறான முகவரி வடிவம்';

  @override
  String joined(Object x) {
    return '$x இல் சேர்ந்தார்';
  }

  @override
  String get keywordFilterDescription =>
      'தலைப்பு, உடல் அல்லது முகவரி இல் ஏதேனும் முக்கிய வார்த்தைகளைக் கொண்ட இடுகைகளை வடிகட்டுகிறது';

  @override
  String get keywordFilters => 'முக்கிய வடிப்பான்கள்';

  @override
  String get label => 'சிட்டை';

  @override
  String get language => 'மொழி';

  @override
  String get languageFilters => 'மொழி வடிப்பான்களைத் தேடுகிறீர்களா?';

  @override
  String get languageNotAllowed =>
      'நீங்கள் இடுகையிடும் சமூகம் நீங்கள் தேர்ந்தெடுத்த மொழியில் இடுகைகளை அனுமதிக்காது. வேறு மொழியை முயற்சிக்கவும்.';

  @override
  String get large => 'பெரிய';

  @override
  String get leftLongSwipe => 'இடது நீண்ட ச்வைப்';

  @override
  String get leftShortSwipe => 'இடது குறுகிய ச்வைப்';

  @override
  String get light => 'ஒளி';

  @override
  String link(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'இணைப்புகள்',
      one: 'இணைப்பு',
      zero: 'இணைப்பு',
    );
    return '$_temp0 ';
  }

  @override
  String get linkActions => 'இணைப்பு செயல்கள்';

  @override
  String get linkHandlingCustomTabs =>
      'பயன்பாட்டில் உட்பொதிக்கப்பட்ட கணினி உலாவியில் திறக்கவும்';

  @override
  String get linkHandlingCustomTabsShort => 'பயன்பாட்டில் உட்பொதிக்கப்பட்டது';

  @override
  String get linkHandlingExternal => 'கணினி உலாவியில் வெளிப்புறமாக திறக்கவும்';

  @override
  String get linkHandlingExternalShort => 'வெளிப்புறம்';

  @override
  String get linkHandlingInApp =>
      'தண்டரின் உள்ளமைக்கப்பட்ட உலாவியைப் பயன்படுத்தவும்';

  @override
  String get linkHandlingInAppShort => 'பயன்பாட்டில்';

  @override
  String get linkPostsUseCompactView => 'Show Compact Link Posts';

  @override
  String get linksBehaviourSettings => 'இணைப்புகள்';

  @override
  String loadMorePlural(Object count) {
    return '$count மேலும் பதில்களை ஏற்றவும்…';
  }

  @override
  String loadMoreSingular(Object count) {
    return 'ஏற்றவும் $count மேலும் பதில்…';
  }

  @override
  String get loading => 'ஏற்றுகிறது ...';

  @override
  String get local => 'உள்ளக';

  @override
  String get localNotifications => 'உள்ளக அறிவிப்புகள்';

  @override
  String get localOnly => 'உள்ளக மட்டும்';

  @override
  String get localPosts => 'உள்ளக இடுகைகள்';

  @override
  String get lockPost => 'பூட்டு இடுகை';

  @override
  String get locked => 'பூட்டப்பட்டுள்ளது';

  @override
  String get lockedPost => 'பூட்டப்பட்ட இடுகை';

  @override
  String get logOut => 'விடுபதிகை';

  @override
  String get login => 'புகுபதிகை';

  @override
  String get loginAttemptCanceled => 'உள்நுழைவு முயற்சி ரத்து செய்யப்பட்டது.';

  @override
  String loginFailed(Object errorMessage) {
    return 'உள்நுழைய முடியவில்லை. தயவுசெய்து மீண்டும் முயற்சிக்கவும். (பிழை: $errorMessage)';
  }

  @override
  String get loginSucceeded => 'உள்நுழைந்தது.';

  @override
  String get loginToPerformAction =>
      'இந்த பணியைச் செய்ய நீங்கள் உள்நுழைய வேண்டும்.';

  @override
  String get loginToSeeInbox => 'உங்கள் இன்பாக்சைப் பார்க்க உள்நுழைக';

  @override
  String get lookingForAccountSpecificFeedSettings =>
      'கணக்கு-குறிப்பிட்ட ஊட்ட அமைப்புகளைத் தேடுகிறீர்களா?';

  @override
  String get malformedUri =>
      'நீங்கள் வழங்கிய இணைப்பு ஆதரிக்கப்படாத வடிவத்தில் உள்ளது. இது சரியான இணைப்பு என்பதை உறுதிப்படுத்தவும்.';

  @override
  String get manageAccounts => 'கணக்குகளை நிர்வகிக்கவும்';

  @override
  String get manageMedia => 'மீடியாவை நிர்வகிக்கவும்';

  @override
  String get markAllAsRead => 'அனைத்தையும் படித்தபடி குறிக்கவும்';

  @override
  String get markAsRead => 'படித்தபடி குறி';

  @override
  String get markPostAsReadOnMediaView =>
      'மீடியாவைப் பார்த்த பிறகு மார்க் படித்தார்';

  @override
  String get markPostAsReadOnScroll => 'சுருளில் மார்க் படித்தார்';

  @override
  String get markReadColor => 'மார்க் படிக்க/படிக்காத வண்ணம்';

  @override
  String get matrixUser => 'அணி பயனர்';

  @override
  String get me => 'நான்';

  @override
  String get media => 'Media';

  @override
  String get medium => 'சராசரி';

  @override
  String mention(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'குறிப்பிடுகள்',
      one: 'குறிப்பிடு',
      zero: 'குறிப்பிடு',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'பட்டியல்';

  @override
  String message(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'செய்திகள்',
      one: 'செய்தி',
      zero: 'செய்தி',
    );
    return '$_temp0';
  }

  @override
  String get metadataFontScale => 'மேனிலை தரவு எழுத்துரு அளவு';

  @override
  String get missingErrorMessage => 'பிழை செய்தி எதுவும் கிடைக்கவில்லை';

  @override
  String get modAdd => 'நிகழ்வு மதிப்பீட்டாளர்களைச் சேர்க்கவும்/அகற்றவும்';

  @override
  String get modAddCommunity =>
      'சமூகங்களில் மதிப்பீட்டாளர்களைச் சேர்க்கவும்/அகற்றவும்';

  @override
  String get modBan => 'தடை/தடைசெய்யும் பயனர்கள்';

  @override
  String get modBanFromCommunity =>
      'சமூகங்களைச் சேர்ந்த பயனர்களை தடை/தடைசெய்யவும்';

  @override
  String get modFeaturePost => 'அம்சம்/அவிழ்க்கப்படாத இடுகைகள்';

  @override
  String get modLockPost => 'இடுகைகளை பூட்டவும்/திறக்கவும்';

  @override
  String get modRemoveComment => 'கருத்துகளை அகற்று/மீட்டமைக்கவும்';

  @override
  String get modRemoveCommunity => 'சமூகங்களை அகற்றவும்/மீட்டெடுக்கவும்';

  @override
  String get modRemovePost => 'இடுகைகளை அகற்று/மீட்டமைக்கவும்';

  @override
  String get modTransferCommunity => 'சமூகங்களை மாற்றுதல்';

  @override
  String get moderatedCommunities => 'மிதமான சமூகங்கள்';

  @override
  String get moderates => 'மிதவாதிகள்';

  @override
  String moderator(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'மதிப்பீட்டாளர்கள்',
      one: 'மதிப்பீட்டாளர்',
      zero: 'மதிப்பீட்டாளர்',
    );
    return '$_temp0';
  }

  @override
  String get moderatorActions => 'மதிப்பீட்டாளர் செயல்கள்';

  @override
  String get modlog => 'மோட்லாக்';

  @override
  String get mostComments => 'பெரும்பாலான கருத்துகள்';

  @override
  String get mustBeLoggedIn => 'நீங்கள் உள்நுழைய வேண்டும்';

  @override
  String get mustBeLoggedInComment =>
      'கருத்து தெரிவிக்க நீங்கள் உள்நுழைந்திருக்க வேண்டும்';

  @override
  String get mustBeLoggedInPost =>
      'ஒரு இடுகையை உருவாக்க நீங்கள் உள்நுழைய வேண்டும்';

  @override
  String get names => 'பெயர்கள்';

  @override
  String get navbarDoubleTapGestures => 'NAVBAR இரட்டை தட்டு சைகைகள்';

  @override
  String get navbarSwipeGestures => 'நவ்பர் ச்வைப் சைகைகள்';

  @override
  String get navigateDown => 'அடுத்த கருத்து';

  @override
  String get navigateUp => 'முந்தைய கருத்து';

  @override
  String get navigation => 'வானோடல்';

  @override
  String get nestedCommentIndicatorColor =>
      'உள்ளமைக்கப்பட்ட கருத்து காட்டி நிறம்';

  @override
  String get nestedCommentIndicatorStyle =>
      'உள்ளமைக்கப்பட்ட கருத்து காட்டி பாணி';

  @override
  String get never => 'ஒருபோதும்';

  @override
  String get newComments => 'புதிய கருத்துகள்';

  @override
  String get newPost => 'புதிய இடுகை';

  @override
  String get new_ => 'புதிய';

  @override
  String get no => 'இல்லை';

  @override
  String get noAccountsAdded => 'கணக்குகள் எதுவும் சேர்க்கப்படவில்லை';

  @override
  String get noAnonymousInstances =>
      'அநாமதேய நிகழ்வுகள் எதுவும் சேர்க்கப்படவில்லை';

  @override
  String get noCommentsFound => 'எந்தக் கருத்தும் கிடைக்கவில்லை';

  @override
  String get noCommunitiesFound => 'எந்த சமூகங்களும் கிடைக்கவில்லை';

  @override
  String get noCommunityBlocks => 'தடுக்கப்பட்ட சமூகங்கள் இல்லை';

  @override
  String get noCompatibleAppFound => 'இணக்கமான பயன்பாடு எதுவும் கிடைக்கவில்லை';

  @override
  String get noDiscussionLanguages =>
      'மொழியின் அடிப்படையில் எந்த உள்ளடக்கமும் மறைக்கப்படவில்லை.';

  @override
  String get noDisplayNameSet => 'காட்சி பெயர் தொகுப்பு இல்லை';

  @override
  String get noEmailSet => 'மின்னஞ்சல் தொகுப்பு இல்லை';

  @override
  String get noFavoritedCommunities => 'பிடித்த சமூகங்கள் இல்லை';

  @override
  String get noImages =>
      'நீங்கள் எந்த படங்களையும் பதிவேற்றவில்லை என்று தெரிகிறது.';

  @override
  String get noInstanceBlocks => 'தடுக்கப்பட்ட நிகழ்வுகள் இல்லை.';

  @override
  String get noItems => 'உருப்படிகள் இல்லை';

  @override
  String get noKeywordFilters =>
      'முக்கிய வடிப்பான்கள் எதுவும் சேர்க்கப்படவில்லை';

  @override
  String get noLanguage => 'மொழி இல்லை';

  @override
  String get noMatrixUserSet => 'மேட்ரிக்ச் பயனர் தொகுப்பு இல்லை';

  @override
  String get noMentions => 'குறிப்புகள் இல்லை';

  @override
  String get noMessages => 'செய்திகள் இல்லை';

  @override
  String get noPostsFound => 'இடுகைகள் எதுவும் கிடைக்கவில்லை.';

  @override
  String get noProfileBioSet => 'சுயவிவர உயிர் தொகுப்பு இல்லை';

  @override
  String get noReferencesToImage =>
      'இந்த படத்தைக் கொண்ட இடுகைகள் அல்லது கருத்துகள் எதுவும் காணப்படவில்லை. இருப்பினும், இது இணையத்தில் வேறு எங்கும் பயன்படுத்தப்படலாம்.';

  @override
  String get noReplies => 'பதில்கள் இல்லை';

  @override
  String get noResultsFound => 'முடிவுகள் எதுவும் கிடைக்கவில்லை.';

  @override
  String get noSubscriptions => 'சந்தாக்கள் இல்லை';

  @override
  String get noUserBlocks => 'தடுக்கப்பட்ட பயனர்கள் இல்லை.';

  @override
  String get noUserLabels =>
      'நீங்கள் இதுவரை எந்த பயனர் லேபிள்களையும் உருவாக்கவில்லை';

  @override
  String get noUsersFound => 'பயனர்கள் எதுவும் கிடைக்கவில்லை.';

  @override
  String get noVisibleComments =>
      'சமூகம் தடுக்கப்பட்டிருப்பதால் கருத்துகள் தெரியவில்லை.';

  @override
  String get none => 'எதுவுமில்லை';

  @override
  String get normal => 'சாதாரண';

  @override
  String notValidLemmyInstance(Object instance) {
    return '$instance செல்லுபடியாகும் உதாரணமாகத் தெரியவில்லை';
  }

  @override
  String get notValidUrl => 'செல்லுபடியாகும் முகவரி அல்ல';

  @override
  String get nothingToShare => 'பகிர எதுவும் இல்லை';

  @override
  String notifications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'அறிவிப்புகள்',
      one: 'அறிவிப்பு',
      zero: 'அறிவிப்பு',
    );
    return '$_temp0';
  }

  @override
  String get notificationsBehaviourSettings => 'அறிவிப்புகள்';

  @override
  String get notificationsNotAllowed =>
      'கணினி அமைப்புகளில் இடிக்கு அறிவிப்புகள் அனுமதிக்கப்படவில்லை';

  @override
  String get notificationsWarningDialog =>
      'அறிவிப்புகள் ஒரு ** சோதனை அம்சமாகும் ** இது எல்லா சாதனங்களிலும் சரியாக செயல்படாது.\n\n - ஒவ்வொரு ~ 15 நிமிடங்களுக்கும் காசோலைகள் நிகழும், மேலும் கூடுதல் பேட்டரியை உட்கொள்ளும்.\n\n - வெற்றிகரமான அறிவிப்புகளின் அதிக சாத்தியக்கூறுகளுக்கு பேட்டரி மேம்படுத்தல்களை முடக்கு.\n\n மேலும் தகவலுக்கு பின்வரும் பக்கத்தைப் பார்க்கவும்.';

  @override
  String get nsfw => 'NSFW';

  @override
  String get nsfwWarning => 'NSFW - வெளிப்படுத்த தட்டவும்';

  @override
  String get off => 'அணை';

  @override
  String get offline => 'இணையமில்லாமல்';

  @override
  String get ok => 'சரி';

  @override
  String get old => 'பழைய';

  @override
  String get on => 'ஆன்';

  @override
  String get onWifi => 'வைஃபை மீது';

  @override
  String get onlyModsCanPostInCommunity =>
      'இந்த சமூகத்தில் மதிப்பீட்டாளர்கள் மட்டுமே இடுகையிடலாம்';

  @override
  String get open => 'திற';

  @override
  String get openAccountSwitcher => 'கணக்கு ச்விட்சர் திறக்கவும்';

  @override
  String get openByDefault => 'இயல்பாக திறக்கவும்';

  @override
  String get openInBrowser => 'உலாவியில் திற';

  @override
  String get openInstance => 'திறந்த நிகழ்வு';

  @override
  String get openLinksInExternalBrowser =>
      'வெளிப்புற உலாவியில் இணைப்புகளைத் திறக்கவும்';

  @override
  String get openLinksInReaderMode =>
      'வாசகர் பயன்முறையில் இணைப்புகளைத் திறக்கவும்';

  @override
  String get openSettings => 'திறந்த அமைப்புகள்';

  @override
  String get orange => 'ஆரஞ்சு';

  @override
  String get originalPoster => 'அசல் சுவரொட்டி';

  @override
  String get overview => 'கண்ணோட்டம்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get pending => 'நிலுவையில் உள்ளது';

  @override
  String performedBy(Object user) {
    return 'செய்தவர்: $user';
  }

  @override
  String get permissionDenied =>
      'அறிவிப்புகளைக் காண்பிக்க தண்டருக்கு இசைவு வழங்கப்படவில்லை. கணினி அமைப்புகளில் இயக்கவும்.';

  @override
  String get permissionDeniedMessage =>
      'மறுக்கப்பட்ட இந்த படத்தை சேமிக்க தண்டருக்கு சில அனுமதிகள் தேவை.';

  @override
  String get pinPostToCommunity => 'சமூகத்திற்கு முள் இடுகை';

  @override
  String get pinToCommunity => 'சமூகத்திற்கு முள்';

  @override
  String get pinned => 'குத்திவைக்கப்பட்டது';

  @override
  String get pinnedPostToCommunity => 'சமூகத்தில் பின் செய்யப்பட்ட இடுகை';

  @override
  String get pinnedPostsUseCompactView => 'Show Compact Pinned Posts';

  @override
  String get placeholderText =>
      'லோரெம் மிகவும் கேரட், தக்காளி இளங்கலை உருவாக்குபவர், ஆனால் நான் ஒரு இன்கோடில் இருப்பேன், ஒரு சிறந்த நேரத்தின் வலி. ஒரு விசித்திரமான மன்னிப்பைச் செய்வதற்காக, உல்லாம்கோ வேலையை அவர் பயன்படுத்துகிறார், இதன் விளைவாக வசதியின் அலிகிபிப் தவிர. வீட்டுப்பாடம் அல்லது விமர்சிக்கப்பட்ட இன்பத்தில் வலி ஏற்பட்ட வலி ஒரு இணை வலி கால்பந்து தப்பிக்கும். தவிர, அவர்கள் செய்ய ஆர்வமுள்ள கண்மூடித்தனமானவர்கள், சேவைகள் தின்பண்டங்கள் என்ற ஆன்மாவை கைவிடுகின்றன என்பதில் அவர்கள் தவறு செய்கிறார்கள்.';

  @override
  String get post => 'இடுகை';

  @override
  String get postActions => 'செயல்கள் இடுகை';

  @override
  String get postBehaviourSettings => 'இடுகைகள்';

  @override
  String get postBody => 'போச்ட் உடல்';

  @override
  String get postBodySettings => 'உடல் அமைப்புகளை இடுகையிடவும்';

  @override
  String get postBodySettingsDescription =>
      'இந்த அமைப்புகள் பிந்தைய உடலின் காட்சியை பாதிக்கின்றன';

  @override
  String get postBodyShowCommunityInstance => 'சமூக நிகழ்வைக் காட்டு';

  @override
  String get postBodyShowUserInstance => 'பயனர் உதாரணத்தைக் காட்டு';

  @override
  String get postBodyViewType => 'உடல் பார்வை வகை';

  @override
  String get postContentFontScale => 'உள்ளடக்க எழுத்துரு அளவை இடுங்கள்';

  @override
  String get postCreatedSuccessfully => 'இடுகை வெற்றிகரமாக உருவாக்கப்பட்டது!';

  @override
  String get postLocked =>
      'இடுகை பூட்டப்பட்டுள்ளது. பதில்கள் எதுவும் அனுமதிக்கப்படவில்லை.';

  @override
  String get postMetadataInstructions =>
      'விரும்பிய தகவல்களை இழுத்து கைவிடுவதன் மூலம் மேனிலை தரவு தகவல்களைத் தனிப்பயனாக்கலாம்';

  @override
  String get postNSFW => 'NSFW ஆக குறிக்கவும்';

  @override
  String get postPreview =>
      'கொடுக்கப்பட்ட அமைப்புகளுடன் இடுகையின் முன்னோட்டத்தைக் காட்டு';

  @override
  String get postSavedAsDraft => 'இடுகை வரைவாக சேமிக்கப்பட்டது';

  @override
  String get postShowUserInstance => 'பயனர் உதாரணத்தைக் காட்டு';

  @override
  String get postSwipeActions => 'இடுகை ச்வைப் செயல்கள்';

  @override
  String get postSwipeGesturesHint =>
      'அதற்கு பதிலாக பொத்தான்களைப் பயன்படுத்த விரும்புகிறீர்களா? பொது அமைப்புகளில் தபால் அட்டைகளில் பொத்தான்கள் தோன்றுவதை மாற்றவும்.';

  @override
  String get postTitle => 'தலைப்பு';

  @override
  String get postTitleFontScale => 'தலைப்பு எழுத்துரு அளவை இடுங்கள்';

  @override
  String get postTogglePreview => 'முன்னோட்டத்தை மாற்றவும்';

  @override
  String get postURL => 'முகவரி';

  @override
  String get postUploadImageError => 'படத்தை பதிவேற்ற முடியவில்லை';

  @override
  String get postViewType => 'பார்வை வகை';

  @override
  String get posts => 'இடுகைகள்';

  @override
  String get preview => 'முன்னோட்டம்';

  @override
  String profileAppliedSuccessfully(Object profile) {
    return '$profile வெற்றிகரமாக பயன்படுத்தப்படுகிறது!';
  }

  @override
  String get profileBio => 'சுயவிவர உயிர்';

  @override
  String get profiles => 'சுயவிவரங்கள்';

  @override
  String get public => 'பொது';

  @override
  String get pureBlack => 'தூய கருப்பு';

  @override
  String get purgedComment => 'சுத்திகரிக்கப்பட்ட கருத்து';

  @override
  String get purgedCommunity => 'தூய்மைப்படுத்தப்பட்ட சமூகம்';

  @override
  String get purgedPerson => 'சுத்திகரிக்கப்பட்ட நபர்';

  @override
  String get purgedPost => 'சுத்திகரிக்கப்பட்ட இடுகை';

  @override
  String get purple => 'ஊதா';

  @override
  String get pushNotification => 'அறிவிப்புகளை அழுத்தவும்';

  @override
  String get pushNotificationDescription =>
      'இயக்கப்பட்டால், புதிய அறிவிப்புகளுக்கு வாக்கெடுப்பு செய்வதற்காக தண்டர் உங்கள் JWT கிள்ளாக்கை (களை) சேவையகத்திற்கு அனுப்பும்.\n\n ** குறிப்பு: ** பயன்பாடு தொடங்கப்படும் வரை இது நடைமுறைக்கு வராது.';

  @override
  String get pushNotificationServer => 'அறிவிப்பு சேவையகத்தை அழுத்தவும்';

  @override
  String get pushNotificationServerDescription =>
      'புச் அறிவிப்பு சேவையகத்தை உள்ளமைக்கவும். உங்கள் சாதனத்திற்கு புச் அறிவிப்புகளை அனுப்ப சேவையகம் சரியாக கட்டமைக்கப்பட வேண்டும்.\n\n ** உங்கள் சான்றுகளுடன் நீங்கள் நம்பும் சேவையகத்தை மட்டும் உள்ளிடவும். **';

  @override
  String get rateLimitErrorMessage =>
      'இந்த கோரிக்கைக்கான விகித வரம்பை நீங்கள் தாக்கியுள்ளீர்கள். தயவுசெய்து காத்திருந்து பின்னர் மீண்டும் முயற்சிக்கவும்.';

  @override
  String get reachedTheBottom => 'ஏற்ற இன்னும் உருப்படிகள் இல்லை';

  @override
  String get read => 'படிக்க';

  @override
  String get readAll => 'அனைத்தையும் படியுங்கள்';

  @override
  String get readerMode => 'வாசகர் பயன்முறை';

  @override
  String get reason => 'காரணம்';

  @override
  String get red => 'சிவப்பு';

  @override
  String get reduceAnimations => 'அனிமேசன்களைக் குறைக்கவும்';

  @override
  String get reducesAnimations =>
      'தண்டருக்குள் பயன்படுத்தப்படும் அனிமேசன்களைக் குறைக்கிறது';

  @override
  String get refresh => 'புதுப்பிப்பு';

  @override
  String get refreshContent => 'உள்ளடக்கத்தைப் புதுப்பிக்கவும்';

  @override
  String get removalReason => 'அகற்றுதல் காரணம்';

  @override
  String get remove => 'அகற்று';

  @override
  String get removeAccount => 'கணக்கை அகற்று';

  @override
  String get removeAsCommunityModerator => 'சமூக மதிப்பீட்டாளராக அகற்று';

  @override
  String get removeComment => 'கருத்தை அகற்று';

  @override
  String get removeFromFavorites => 'பிடித்தவைகளிலிருந்து அகற்று';

  @override
  String get removeInstance => 'உதாரணத்தை அகற்று';

  @override
  String removeKeyword(Object keyword) {
    return '\"$keyword\" ஐ அகற்றவா?';
  }

  @override
  String get removeKeywordFilter => 'முக்கிய சொல்லை அகற்று';

  @override
  String get removePost => 'இடுகையை அகற்று';

  @override
  String get removeUserData => 'பயனர் தரவை அகற்று';

  @override
  String get removed => 'அகற்றப்பட்டது';

  @override
  String get removedComment => 'அகற்றப்பட்ட கருத்து';

  @override
  String get removedCommunity => 'அகற்றப்பட்ட சமூகம்';

  @override
  String get removedCommunityFromSubscriptions =>
      'சமூகத்திலிருந்து குழுவிலகப்படாதது';

  @override
  String get removedInstanceMod => 'அகற்றப்பட்ட நிகழ்வு மோட்';

  @override
  String get removedModFromCommunity => 'சமூகத்திலிருந்து மோட் அகற்றப்பட்டது';

  @override
  String get removedPost => 'அகற்றப்பட்ட இடுகை';

  @override
  String removedUserAsCommunityModerator(Object username) {
    return 'சமூக மதிப்பீட்டாளராக $username அகற்றப்பட்டார்';
  }

  @override
  String get reorder => 'மறுவரிசை';

  @override
  String reply(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'மறுமொழிகள்',
      one: 'மறுமொழி',
      zero: 'மறுமொழி',
    );
    return '$_temp0';
  }

  @override
  String get replyColor => 'பதில் நிறம்';

  @override
  String get replyNotSupported =>
      'இந்த பார்வையில் இருந்து பதிலளிப்பது தற்போது ஆதரிக்கப்படவில்லை';

  @override
  String get replyToPost => 'இடுகைக்கு பதில்';

  @override
  String replyingTo(Object author) {
    return '$author க்கு பதிலளித்தல்';
  }

  @override
  String report(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'அறிக்கைகள்',
      one: 'அறிக்கை',
      zero: 'அறிக்கை',
    );
    return '$_temp0 ';
  }

  @override
  String get reportComment => 'கருத்து தெரிவிக்கவும்';

  @override
  String get reportPost => 'அறிக்கை இடுகை';

  @override
  String get reportedComment => 'கருத்து தெரிவிக்கப்பட்டது';

  @override
  String get reportedPost => 'அறிக்கையிடப்பட்ட இடுகை';

  @override
  String get reporter => 'நிருபர்:';

  @override
  String get requiredField => '*தேவை';

  @override
  String get reset => 'மீட்டமை';

  @override
  String get resetCommentPreferences => 'கருத்து விருப்பங்களை மீட்டமைக்கவும்';

  @override
  String get resetPostPreferences => 'இடுகை விருப்பங்களை மீட்டமைக்கவும்';

  @override
  String get resetPreferences => 'விருப்பங்களை மீட்டமைக்கவும்';

  @override
  String get resetPreferencesAndData =>
      'விருப்பத்தேர்வுகள் மற்றும் தரவை மீட்டமைக்கவும்';

  @override
  String get restore => 'மீட்டெடு';

  @override
  String get restoreComment => 'கருத்தை மீட்டெடுங்கள்';

  @override
  String get restorePost => 'இடுகையை மீட்டெடுங்கள்';

  @override
  String get restoredComment => 'கருத்து மீட்டெடுக்கப்பட்டது';

  @override
  String get restoredCommentFromDraft => 'வரைவில் இருந்து மீட்டெடுக்கப்பட்டது';

  @override
  String get restoredCommunity => 'மீட்டெடுக்கப்பட்ட சமூகம்';

  @override
  String get restoredPost => 'மீட்டமைக்கப்பட்ட இடுகை';

  @override
  String get restoredPostFromDraft => 'வரைவிலிருந்து மீட்டெடுக்கப்பட்ட இடுகை';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get rightLongSwipe => 'வலது நீண்ட ச்வைப்';

  @override
  String get rightShortSwipe => 'வலது குறுகிய ச்வைப்';

  @override
  String get save => 'சேமி';

  @override
  String get saveColor => 'நிறத்தை சேமிக்கவும்';

  @override
  String get saveSettings => 'அமைப்புகளை சேமிக்கவும்';

  @override
  String get saved => 'சேமிக்கப்பட்டது';

  @override
  String get scaled => 'அளவிடப்பட்டது';

  @override
  String get scrapeMissingLinkPreviews =>
      'காணாமல் போன இணைப்பு முன்னோட்டங்களைத் துடைக்கவும்';

  @override
  String get screenReaderProfile => 'திரை ரீடர் சுயவிவரம்';

  @override
  String get screenReaderProfileDescription =>
      'ஒட்டுமொத்த கூறுகளைக் குறைப்பதன் மூலமும், முரண்பட்ட சைகைகளை அகற்றுவதன் மூலமும் திரை வாசகர்களுக்கான இடியை மேம்படுத்துகிறது.';

  @override
  String get search => 'தேடல்';

  @override
  String get searchByText => 'உரை மூலம் தேடுங்கள்';

  @override
  String get searchByUrl => 'முகவரி மூலம் தேடுங்கள்';

  @override
  String get searchComments => 'கருத்துகளைத் தேடுங்கள்';

  @override
  String searchCommentsFederatedWith(Object instance) {
    return '$instance உடன் கூட்டாக்கப்பட்ட கருத்துகளைத் தேடு';
  }

  @override
  String searchCommunitiesFederatedWith(Object instance) {
    return '$instance உடன் கூட்டாக்கப்பட்ட சமூகங்களைத் தேடு';
  }

  @override
  String searchInstance(Object instance) {
    return 'தேடல் $instance';
  }

  @override
  String searchInstancesFederatedWith(Object instance) {
    return '$instance உடன் கூட்டமைப்பு செய்யப்பட்ட நிகழ்வுகளைத் தேடு';
  }

  @override
  String get searchPostSearchType => 'இடுகை தேடல் வகையைத் தேர்ந்தெடுக்கவும்';

  @override
  String searchPostsFederatedWith(Object instance) {
    return '$instance உடன் கூட்டாக்கப்பட்ட இடுகைகளைத் தேடு';
  }

  @override
  String get searchTerm => 'தேடல் கால';

  @override
  String searchUsersFederatedWith(Object instance) {
    return '$instance உடன் கூட்டாக்கப்பட்ட பயனர்களைத் தேடு';
  }

  @override
  String get selectAccountToCommentAs =>
      'கருத்து தெரிவிக்க கணக்கைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectAccountToPostAs => 'இடுகையிட கணக்கைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectAll => 'அனைத்தையும் தெரிவுசெய்';

  @override
  String get selectCommunity => 'ஒரு சமூகத்தைத் தேர்ந்தெடுக்கவும் (தேவை)';

  @override
  String get selectFeedType => 'தீவன வகையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectLanguage => 'மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectSearchType => 'தேடல் வகையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectText => 'உரையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get sendBackgroundTestLocalNotification =>
      'பின்னணி சோதனை உள்ளக அறிவிப்பை அனுப்பவும்';

  @override
  String get sendBackgroundTestUnifiedPushNotification =>
      'பின்னணி சோதனை ஒருங்கிணைந்த புச் அறிவிப்பை அனுப்பவும்';

  @override
  String get sendTestLocalNotification => 'சோதனை உள்ளக அறிவிப்பை அனுப்பவும்';

  @override
  String get sendTestUnifiedPushNotification =>
      'சோதனை ஒருங்கிணைந்த புச் அறிவிப்பை அனுப்பவும்';

  @override
  String get sensitiveContentWarning =>
      'முக்கியமான உள்ளடக்கம் இருக்கலாம். வெளிப்படுத்த தட்டவும்.';

  @override
  String get sentRequestForTestNotification =>
      'சோதனை அறிவிப்புக்கான கோரிக்கை அனுப்பப்பட்டது.';

  @override
  String serverErrorComments(Object message) {
    return 'மேலும் கருத்துகளைப் பெறும்போது சேவையக பிழை ஏற்பட்டது: $message';
  }

  @override
  String get setAction => 'நடவடிக்கை அமைக்கவும்';

  @override
  String get setLongPress => 'நீண்ட அழுத்த செயலாக அமைக்கவும்';

  @override
  String get setShortPress => 'குறுகிய செய்தித் தாள் செயலாக அமைக்கவும்';

  @override
  String get settingOverrideLabel =>
      'இந்த அமைப்புகள் தண்டரின் இயல்புநிலை அமைப்புகளை மீறுகின்றன.';

  @override
  String settingTypeNotSupported(Object settingType) {
    return 'வகை $settingType இன் அமைப்புகள் இன்னும் ஆதரிக்கப்படவில்லை.';
  }

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String settingsExportedSuccessfully(Object savedFilePath) {
    return 'அமைப்புகள் வெற்றிகரமாக \'$savedFilePath\'';
  }

  @override
  String get settingsFeedCards =>
      'இந்த அமைப்புகள் முக்கிய ஊட்டத்தில் உள்ள அட்டைகளுக்கு பொருந்தும், உண்மையில் இடுகைகளைத் திறக்கும்போது செயல்கள் எப்போதும் கிடைக்கும்.';

  @override
  String get settingsImportedSuccessfully =>
      'அமைப்புகள் வெற்றிகரமாக இறக்குமதி செய்யப்பட்டன!';

  @override
  String get settingsNotExportedSuccessfully =>
      'அமைப்புகள் வெற்றிகரமாக சேமிக்கப்படவில்லை, அல்லது அறுவை மருத்தீடு ரத்து செய்யப்பட்டது.';

  @override
  String get settingsNotImportedSuccessfully =>
      'அமைப்புகள் வெற்றிகரமாக இறக்குமதி செய்யப்படவில்லை அல்லது செயல்பாடு ரத்து செய்யப்பட்டது.';

  @override
  String get settingsPage => 'அமைப்புகள் பக்கம்';

  @override
  String get settingsPageAbout => 'பற்றி';

  @override
  String get settingsPageAccessibility => 'அணுகல்';

  @override
  String get settingsPageAccount => 'கணக்கு';

  @override
  String get settingsPageAccountBlocks => 'பிளாக்லிச்ட்கள்';

  @override
  String get settingsPageAccountLanguages => 'கலந்துரையாடல் மொழிகள்';

  @override
  String get settingsPageAccountMedia => 'மீடியாவை நிர்வகிக்கவும்';

  @override
  String get settingsPageAppearance => 'தோற்றம்';

  @override
  String get settingsPageAppearanceComments => 'கருத்துகள்';

  @override
  String get settingsPageAppearancePosts => 'இடுகைகள்';

  @override
  String get settingsPageAppearanceTheming => 'தீமிங்';

  @override
  String get settingsPageDebug => 'பிழைத்திருத்தம்';

  @override
  String get settingsPageFilters => 'வடிப்பான்கள்';

  @override
  String get settingsPageFloatingActionButton => 'மிதக்கும் செயல் பொத்தான்';

  @override
  String get settingsPageGeneral => 'பொது';

  @override
  String get settingsPageGestures => 'சைகைகள்';

  @override
  String get settingsPageUserLabels => 'பயனர் லேபிள்கள்';

  @override
  String get settingsPageVideo => 'ஒளிதோற்றம்';

  @override
  String get share => 'பங்கு';

  @override
  String get shareComment => 'கருத்து இணைப்பைப் பகிரவும்';

  @override
  String get shareCommentLocal => 'கருத்து இணைப்பைப் பகிரவும் (எனது நிகழ்வு)';

  @override
  String get shareCommunity => 'சமூகத்தைப் பகிர்ந்து கொள்ளுங்கள்';

  @override
  String get shareCommunityLink => 'சமூக இணைப்பைப் பகிரவும்';

  @override
  String get shareCommunityLinkLocal =>
      'சமூக இணைப்பைப் பகிரவும் (எனது நிகழ்வு)';

  @override
  String get shareImage => 'படத்தைப் பகிரவும்';

  @override
  String get shareLemmyLink => 'லெம்மி இணைப்பைப் பகிரவும்';

  @override
  String get shareLink => 'வெளிப்புற இணைப்பைப் பகிரவும்';

  @override
  String get shareMedia => 'ஊடகத்தைப் பகிரவும்';

  @override
  String get shareMediaLink => 'மீடியா இணைப்பைப் பகிரவும்';

  @override
  String get shareOriginalLink => 'அசல் இணைப்பைப் பகிரவும்';

  @override
  String get sharePost => 'இடுகை இணைப்பைப் பகிரவும்';

  @override
  String get sharePostLocal => 'இடுகை இணைப்பைப் பகிரவும் (எனது நிகழ்வு)';

  @override
  String get shareThumbnail => 'சிறுபடத்தைப் பகிரவும்';

  @override
  String get shareThumbnailAsImage => 'சிறுபடத்தை படமாக பகிரவும்';

  @override
  String get shareUser => 'பயனரைப் பகிரவும்';

  @override
  String get shareUserLink => 'பயனர் இணைப்பைப் பகிரவும்';

  @override
  String get shareUserLinkLocal => 'பயனர் இணைப்பைப் பகிரவும் (எனது நிகழ்வு)';

  @override
  String get showAll => 'அனைத்தையும் காட்டு';

  @override
  String get showBotAccounts => 'போட் கணக்குகளைக் காட்டு';

  @override
  String get showCommentActionButtons =>
      'கருத்து நடவடிக்கை பொத்தான்களைக் காட்டு';

  @override
  String get showCommunityDisplayNames => 'சமூக காட்சி பெயர்களைக் காட்டு';

  @override
  String get showCrossPosts => 'குறுக்கு இடுகைகளைக் காட்டு';

  @override
  String get showEdgeToEdgeImages => 'எட்ச் டு எட்ச் படங்களைக் காட்டு';

  @override
  String get showExpandedTaglines => 'விரிவாக்கப்பட்ட டேக்லைன்களைக் காட்டு';

  @override
  String get showFullDate => 'முழு தேதியைக் காட்டு';

  @override
  String get showFullDateDescription => 'இடுகைகளில் முழு தேதியைக் காட்டு';

  @override
  String get showFullHeightImages => 'முழு உயர படங்களைக் காட்டுங்கள்';

  @override
  String get showHiddenPosts => 'மறைக்கப்பட்ட இடுகைகளைக் காட்டு';

  @override
  String get showInAppUpdateNotifications =>
      'புதிய அறிவிலிமையம் வெளியீடுகளுக்கு அறிவிக்கப்படும்';

  @override
  String get showLess => 'குறைவாகக் காட்டு';

  @override
  String get showMore => 'மேலும் காட்டு';

  @override
  String get showNavigationLabels => 'வழிசெலுத்தல் லேபிள்களைக் காட்டு';

  @override
  String get showNavigationLabelsDescription =>
      'கீழே உள்ள வழிசெலுத்தல் பொத்தான்களுக்கு அடியில் லேபிள்களைக் காண்பிக்க வேண்டுமா';

  @override
  String get showNsfwContent => 'NSFW உள்ளடக்கத்தைக் காட்டு';

  @override
  String get showOwnContent => 'சொந்த உள்ளடக்கத்தைக் காட்டு';

  @override
  String get showPassword => 'கடவுச்சொல்லைக் காட்டு';

  @override
  String get showPostAuthor => 'இடுகை எழுத்தாளரைக் காட்டு';

  @override
  String get showPostAuthorSubtitle =>
      'இடுகை ஆசிரியர் எப்போதும் சமூக ஊட்டங்களில் காட்டப்படுகிறார்';

  @override
  String get showPostCommunityFirst => 'Show Community and Author First';

  @override
  String get showPostCommunityIcons => 'சமூக சின்னங்களைக் காட்டு';

  @override
  String get showPostSaveAction => 'சேமி பொத்தானைக் காட்டு';

  @override
  String get showPostTextContentPreview => 'உரை முன்னோட்டத்தைக் காட்டு';

  @override
  String get showPostTitleFirst => 'முதலில் தலைப்பைக் காட்டு';

  @override
  String get showPostVoteActions => 'வாக்கு பொத்தான்களைக் காட்டு';

  @override
  String get showReadPosts => 'வாசிப்பு இடுகைகளைக் காட்டு';

  @override
  String get showSavedContent => 'சேமித்த உள்ளடக்கத்தைக் காட்டு';

  @override
  String get showScoreCounters => 'பயனர் மதிப்பெண்களைக் காண்பி';

  @override
  String get showScores => 'இடுகை/கருத்து மதிப்பெண்களைக் காட்டு';

  @override
  String get showTextPostIndicator => 'உரை இடுகை காட்டி காட்டு';

  @override
  String get showThumbnailPreviewOnRight =>
      'வலதுபுறத்தில் சிறு உருவங்களைக் காட்டு';

  @override
  String get showUnreadOnly => 'படிக்க மட்டும் காட்டு';

  @override
  String get showUpdateChangelogs => 'புதுப்பிப்பு சேஞ்ச்லாக்சைக் காட்டு';

  @override
  String get showUpdateChangelogsSubtitle =>
      'புதுப்பிப்புக்குப் பிறகு மாற்றங்களின் பட்டியலைக் காண்பி';

  @override
  String get showUserAvatar => 'பயனர் அவதாரத்தைக் காட்டு';

  @override
  String get showUserDisplayNames => 'பயனர் காட்சி பெயர்களைக் காட்டு';

  @override
  String get showUserInstance => 'பயனர் உதாரணத்தைக் காட்டு';

  @override
  String get sidebar => 'பக்கப்பட்டி';

  @override
  String get sidebarBottomNavDoubleTapDescription =>
      'பக்கப்பட்டியைத் திறக்க இரட்டை தட்டுதல் கீழே NAV';

  @override
  String get sidebarBottomNavSwipeDescription =>
      'பக்கப்பட்டியைத் திறக்க கீழே NAV ஐ ச்வைப் செய்யவும்';

  @override
  String get small => 'சிறிய';

  @override
  String get somethingWentWrong => 'அச்சச்சோ, ஏதோ தவறு நடந்தது!';

  @override
  String get sortBy => 'வரிசைப்படுத்தவும்';

  @override
  String get sortByTop => 'மேலே வரிசைப்படுத்துங்கள்';

  @override
  String get sortOptions => 'வரிசைப்படுத்து விருப்பங்கள்';

  @override
  String get spoiler => 'இறக்கைத்தடை';

  @override
  String get standard => 'தரநிலை';

  @override
  String get stats => 'புள்ளிவிவரங்கள்';

  @override
  String get status => 'நிலை';

  @override
  String get submit => 'சமர்ப்பிக்கவும்';

  @override
  String get subscribe => 'குழுசேர்';

  @override
  String get subscribeToCommunity => 'சமூகத்திற்கு குழுசேரவும்';

  @override
  String get subscribed => 'சந்தா';

  @override
  String get subscriptionRequestSent => 'சந்தா கோரிக்கை அனுப்பப்பட்டது';

  @override
  String get subscriptions => 'சந்தாக்கள்';

  @override
  String successfullyBannedUser(Object username) {
    return 'தடைசெய்யப்பட்டது $username';
  }

  @override
  String get successfullyBlocked => 'தடுக்கப்பட்டது.';

  @override
  String successfullyBlockedCommunity(Object communityName) {
    return 'தடுக்கப்பட்ட $communityName';
  }

  @override
  String successfullyBlockedUser(Object username) {
    return 'தடுக்கப்பட்டது $username';
  }

  @override
  String successfullyUnbannedUser(Object username) {
    return 'தடைசெய்யப்படாத $username';
  }

  @override
  String get successfullyUnblocked => 'தடைசெய்யப்பட்டது.';

  @override
  String successfullyUnblockedCommunity(Object communityName) {
    return 'தடைசெய்யப்படாத $communityName';
  }

  @override
  String successfullyUnblockedUser(Object username) {
    return 'தடைசெய்யப்பட்ட $username';
  }

  @override
  String get suchAs => 'போன்றவை';

  @override
  String get suggestedTitle => 'பரிந்துரைக்கப்பட்ட தலைப்பு';

  @override
  String switchedAccount(Object username) {
    return '$username க்கு மாறியது';
  }

  @override
  String get system => 'மண்டலம்';

  @override
  String get systemDarkMode => 'தூய கருப்பு';

  @override
  String get systemDarkModeDescription =>
      'இருண்ட பயன்முறைக்கு தூய கருப்பு கருப்பொருள் இயக்கவும்';

  @override
  String get tabletMode => 'டேப்லெட் பயன்முறை (2 நெடுவரிசை பார்வை)';

  @override
  String get tapToExit => 'வெளியேற மீண்டும் அழுத்தவும்';

  @override
  String get tappableAuthorCommunity =>
      'தட்டக்கூடிய ஆசிரியர்கள் மற்றும் சமூகங்கள்';

  @override
  String get teal => 'டீல்';

  @override
  String get testBackgroundNotificationDescription =>
      'தண்டர் தன்னை மூடிவிட்டு பின்னர் பின்னணியில் ஒரு அறிவிப்பை உருவாக்க முயற்சிக்கும். (இது குறைந்தது 15 நிமிடங்கள் ஆகும்.)';

  @override
  String get testBackgroundUnifiedPushNotificationDescription =>
      'தாமதமான அறிவிப்பை அனுப்பவும் பின்னர் தன்னை மூடிமறைக்கவும் தண்டர் அறிவிப்பு சேவையகத்தைக் கேட்கும். (இது சில நிமிடங்கள் ஆகலாம்.)';

  @override
  String get text => 'உரை';

  @override
  String get textActions => 'உரை செயல்கள்';

  @override
  String get theme => 'கருப்பொருள்';

  @override
  String get themeAccentColor => 'உச்சரிப்பு வண்ணங்கள்';

  @override
  String get themePrimary => 'கருப்பொருள் முதன்மை';

  @override
  String get themeSecondary => 'கருப்பொருள் இரண்டாம் நிலை';

  @override
  String get themeTertiary => 'கருப்பொருள் மூன்றாம் நிலை';

  @override
  String get theming => 'தீமிங்';

  @override
  String get thickness => 'தடிமன்';

  @override
  String get thisAccount => 'இந்த கணக்கு';

  @override
  String get thumbnailUrl => 'சிறு முகவரி';

  @override
  String thunderHasBeenUpdated(Object version) {
    return '$version க்கு இடி புதுப்பிக்கப்பட்டது!';
  }

  @override
  String thunderNotificationServer(Object server) {
    return 'தண்டர் அறிவிப்பு சேவையகம்: $server';
  }

  @override
  String get timeoutComments =>
      'பிழை: கருத்துகளைப் பெற முயற்சிக்கும்போது நேரம் முடிந்தது';

  @override
  String get timeoutErrorMessage =>
      'பதிலுக்காக காத்திருக்கும் நேரம் முடிந்தது.';

  @override
  String get timeoutSaveComment =>
      'பிழை: கருத்தைச் சேமிக்க முயற்சிக்கும்போது நேரம் முடிந்தது';

  @override
  String get timeoutSavingPost =>
      'பிழை: இடுகையைச் சேமிக்க முயற்சிக்கும்போது நேரம் முடிந்தது.';

  @override
  String get timeoutUpvoteComment =>
      'பிழை: கருத்தில் வாக்களிக்க முயற்சிக்கும்போது நேரம் முடிந்தது';

  @override
  String get timeoutVotingPost =>
      'பிழை: வாக்களிக்க முயற்சிக்கும்போது நேரம் முடிந்தது.';

  @override
  String get toggelRead => 'படிக்கவும்';

  @override
  String get top => 'மேலே';

  @override
  String get topAll => 'எல்லா நேரத்திலும் மேல்';

  @override
  String get topDay => 'இன்று மேலே';

  @override
  String get topHour => 'கடந்த மணிநேரத்தில் மேலே';

  @override
  String get topMonth => 'முதல் மாதம்';

  @override
  String get topNineMonths => 'கடந்த 9 மாதங்களில் முதலிடம்';

  @override
  String get topSixHour => 'கடந்த 6 மணி நேரத்தில் மேலே';

  @override
  String get topSixMonths => 'கடந்த 6 மாதங்களில் முதலிடம்';

  @override
  String get topThreeMonths => 'கடந்த 3 மாதங்களில் முதலிடம்';

  @override
  String get topTwelveHour => 'கடந்த 12 மணி நேரத்தில் மேலே';

  @override
  String get topWeek => 'முதல் வாரம்';

  @override
  String get topYear => 'முதல் ஆண்டு';

  @override
  String totalComments(Object x) {
    return '$x கருத்துகள்';
  }

  @override
  String totalPosts(Object x) {
    return '$x இடுகைகள்';
  }

  @override
  String get totp => 'TOTP (விரும்பினால்)';

  @override
  String get transferredModToCommunity => 'மாற்றப்பட்ட சமூகம்';

  @override
  String get translationsMayNotBeComplete =>
      'மொழிபெயர்ப்புகள் முழுமையடையாது என்பதை நினைவில் கொள்க';

  @override
  String get trendingCommunities => 'பிரபலமான சமூகங்கள்';

  @override
  String get trySearchingFor => 'தேட முயற்சிக்கவும் ...';

  @override
  String get unableToFindCommunity => 'சமூகத்தைக் கண்டுபிடிக்க முடியவில்லை';

  @override
  String unableToFindCommunityName(Object communityName) {
    return 'சமூகத்தைக் கண்டுபிடிக்க முடியவில்லை \'$communityName\'';
  }

  @override
  String get unableToFindCommunityOnInstance =>
      'தேர்ந்தெடுக்கப்பட்ட பயனரின் நிகழ்வில் தேர்ந்தெடுக்கப்பட்ட சமூகத்தைக் கண்டுபிடிக்க முடியவில்லை.';

  @override
  String get unableToFindInstance => 'உதாரணத்தைக் கண்டுபிடிக்க முடியவில்லை';

  @override
  String get unableToFindLanguage => 'மொழியைக் கண்டுபிடிக்க முடியவில்லை';

  @override
  String get unableToFindPost => 'இடுகையைக் கண்டுபிடிக்க முடியவில்லை';

  @override
  String get unableToFindUser => 'பயனரைக் கண்டுபிடிக்க முடியவில்லை';

  @override
  String unableToFindUserName(Object username) {
    return 'பயனரை \'$username\' கண்டுபிடிக்க முடியவில்லை';
  }

  @override
  String get unableToLoadImage => 'படத்தை ஏற்ற முடியவில்லை';

  @override
  String unableToLoadImageFrom(Object domain) {
    return '$domain';
  }

  @override
  String unableToLoadInstance(Object instance) {
    return '$instance';
  }

  @override
  String get unableToLoadPost => 'இடுகையை ஏற்ற முடியவில்லை';

  @override
  String unableToLoadPostsFrominstance(Object instance) {
    return '$instance இருந்து இலிருந்து இடுகைகளை ஏற்ற முடியவில்லை';
  }

  @override
  String get unableToLoadReplies => 'மேலும் பதில்களை ஏற்ற முடியவில்லை.';

  @override
  String unableToNavigateToInstance(Object instanceHost) {
    return '$instanceHost க்கு செல்ல முடியவில்லை. இது செல்லுபடியாகும் லெம்மி நிகழ்வாக இருக்காது.';
  }

  @override
  String get unableToResolveReport => 'அறிக்கையைத் தீர்க்க முடியவில்லை';

  @override
  String unableToRetrieveChangelog(Object version) {
    return 'பதிப்பு $version க்கான மாற்றபதிப்பு மீட்டெடுக்க முடியவில்லை.';
  }

  @override
  String get unbanFromCommunity => 'சமூகத்திலிருந்து தடையின்றி';

  @override
  String get unbannedUser => 'தடைசெய்யப்படாத பயனர்';

  @override
  String unbannedUserFromCommunity(Object username) {
    return 'சமூகத்திலிருந்து $username தடைநீக்கப்பட்டது';
  }

  @override
  String get unblock => 'தடை';

  @override
  String get unblockCommunity => 'சமூகத்தைத் தடைசெய்க';

  @override
  String get unblockCommunityInstance => 'சமூக நிகழ்வைத் தடைசெய்க';

  @override
  String get unblockInstance => 'உதாரணத்தைத் தடைசெய்க';

  @override
  String get unblockUser => 'பயனரைத் தடைசெய்க';

  @override
  String get unblockUserInstance => 'பயனர் உதாரணத்தைத் தடைசெய்க';

  @override
  String get understandEnable => 'எனக்கு புரிகிறது, இயக்கு';

  @override
  String get unexpectedError => 'எதிர்பாராத பிழை';

  @override
  String get unfavorite => 'மாறாத';

  @override
  String get unfeaturedPost => 'தயாரிக்கப்படாத இடுகை';

  @override
  String get unhidCommunity => 'உலகளாவிய சமூகம்';

  @override
  String get unhide => 'இரக்கமற்றது';

  @override
  String unifiedPushDistributorApp(Object app, Object count) {
    return 'UNIFIDEPUSH விநியோகச்தர் பயன்பாடு: $app ($count கிடைக்கிறது)';
  }

  @override
  String get unifiedPushNotifications => 'ஒருங்கிணைந்த புச் அறிவிப்புகள்';

  @override
  String unifiedPushServer(Object server) {
    return 'UNIFIDEPUSH சேவையகம்: $server';
  }

  @override
  String get unifiedpush => 'UNIFIDEPUSH';

  @override
  String get unlockPost => 'இடுகை திறக்க';

  @override
  String get unlockedPost => 'திறக்கப்பட்ட இடுகை';

  @override
  String get unpinFromCommunity => 'சமூகத்திலிருந்து அவிழ்த்து விடுங்கள்';

  @override
  String get unpinPostFromCommunity =>
      'சமூகத்திலிருந்து இடுக்கையை அவிழ்த்து விடுங்கள்';

  @override
  String get unpinnedPostFromCommunity =>
      'சமூகத்திலிருந்து பின் நீக்கப்பட்ட இடுகை';

  @override
  String get unreachable => 'அணுக முடியாதது';

  @override
  String get unresolved => 'தீர்க்கப்படாதது';

  @override
  String get unsubscribe => 'குழுவிலகவும்';

  @override
  String get unsubscribeFromCommunity => 'சமூகத்திலிருந்து குழுவிலகவும்';

  @override
  String get unsubscribePending => 'குழுவிலகவும் (சந்தா நிலுவையில் உள்ளது)';

  @override
  String get unsubscribed => 'குழுவிலகப்பட்டது';

  @override
  String updateReleased(Object version) {
    return 'புதுப்பிப்பு வெளியிடப்பட்டது: $version';
  }

  @override
  String get uploadImage => 'படத்தைப் பதிவேற்றவும்';

  @override
  String uploadedDate(Object date) {
    return 'பதிவேற்றப்பட்டது: $date';
  }

  @override
  String get upvote => 'எழுப்பவும்';

  @override
  String get upvoteColor => 'வண்ணத்தை உயர்த்தவும்';

  @override
  String get upvoted => 'மேம்பட்டது';

  @override
  String get uriNotSupported =>
      'இந்த வகை இணைப்பு இந்த நேரத்தில் ஆதரிக்கப்படவில்லை.';

  @override
  String get url => 'முகவரி';

  @override
  String get useAdvancedShareSheet => 'மேம்பட்ட பங்கு தாளைப் பயன்படுத்தவும்';

  @override
  String get useApplePushNotifications => 'APNS அறிவிப்புகளைப் பயன்படுத்தவும்';

  @override
  String get useApplePushNotificationsDescription =>
      'ஆப்பிளின் புச் அறிவிப்பு சேவையைப் பயன்படுத்துகிறது';

  @override
  String get useCompactView => 'சிறிய இடுகைகளுக்கு இயக்கு, பெரியதை முடக்கு.';

  @override
  String get useLocalNotifications =>
      'உள்ளக அறிவிப்புகளைப் பயன்படுத்தவும் (சோதனை)';

  @override
  String get useLocalNotificationsDescription =>
      'பின்னணியில் அறிவிப்புகளை அவ்வப்போது சரிபார்க்கிறது';

  @override
  String get useMaterialYouTheme => 'நீங்கள் கருப்பொருளைப் பயன்படுத்தவும்';

  @override
  String get useMaterialYouThemeDescription =>
      'தேர்ந்தெடுக்கப்பட்ட தனிப்பயன் கருப்பொருளை மீறுகிறது';

  @override
  String get useProfilePictureForDrawer =>
      'டிராயருக்கு சுயவிவரப் படத்தைப் பயன்படுத்தவும்';

  @override
  String get useProfilePictureForDrawerSubtitle =>
      'உள்நுழையும்போது, டிராயர் ஐகானுக்கு பதிலாக பயனரின் சுயவிவரப் படத்தைக் காட்டுகிறது';

  @override
  String useSuggestedTitle(Object title) {
    return 'பரிந்துரைக்கப்பட்ட தலைப்பைப் பயன்படுத்தவும்: $title';
  }

  @override
  String get useUnifiedPushNotifications =>
      'ஒருங்கிணைந்த புச் அறிவிப்புகளைப் பயன்படுத்தவும்';

  @override
  String get useUnifiedPushNotificationsDescription => 'இணக்கமான பயன்பாடு தேவை';

  @override
  String get user => 'பயனர்';

  @override
  String get userActions => 'பயனர் செயல்கள்';

  @override
  String userEntry(Object username) {
    return 'பயனர் \'$username\'';
  }

  @override
  String get userFormat => 'பயனர் வடிவம்';

  @override
  String get userLabelHint => 'இது எனக்கு பிடித்த பயனர்';

  @override
  String get userLabels => 'பயனர் லேபிள்கள்';

  @override
  String get userLabelsSettingsPageDescription =>
      'பயனர்களுடன் தொடர்புடைய லேபிள்களை நீங்கள் சேர்க்கலாம், மாற்றலாம் அல்லது அகற்றலாம்.';

  @override
  String get userNameColor => 'பயனர் பெயர் நிறம்';

  @override
  String get userNameThickness => 'பயனர் பெயர் தடிமன்';

  @override
  String get userNotLoggedIn => 'பயனர் உள்நுழையவில்லை';

  @override
  String get userProfiles => 'பயனர் சுயவிவரங்கள்';

  @override
  String get userSettingDescription =>
      'இந்த அமைப்புகள் உங்கள் லெம்மி கணக்குடன் ஒத்திசைக்கப்படுகின்றன, மேலும் அவை ஒரு கணக்கில் மட்டுமே பயன்படுத்தப்படுகின்றன.';

  @override
  String get userStyle => 'பயனர் நடை';

  @override
  String get username => 'பயனர்பெயர்';

  @override
  String get usernameFormattingRedirect =>
      'பயனர்பெயர் வடிவமைப்பைத் தேடுகிறீர்களா?';

  @override
  String get users => 'பயனர்கள்';

  @override
  String versionNumber(Object version) {
    return 'பதிப்பு $version';
  }

  @override
  String get video => 'ஒளிதோற்றம்';

  @override
  String get videoAutoFullscreen => 'ஆட்டோ முழுத்திரை';

  @override
  String get videoAutoLoop => 'லூப் வீடியோ';

  @override
  String get videoAutoMute => 'முடக்கு வீடியோக்கள்';

  @override
  String get videoAutoPlay => 'வீடியோ ஆட்டோபிளே';

  @override
  String get videoDefaultPlaybackSpeed => 'இயல்புநிலை பின்னணி விரைவு';

  @override
  String get videoLinkHandlingExternal =>
      'வெளிப்புற பயன்பாட்டுடன் வீடியோவை இயக்கவும்';

  @override
  String get videoPlayerInApp =>
      'தண்டர் உள்ளமைக்கப்பட்ட பிளேயரைப் பயன்படுத்தவும்';

  @override
  String get videoPlayerMode => 'பிளேயர் பயன்முறை';

  @override
  String get viewAll => 'அனைத்தையும் காண்க';

  @override
  String get viewAllComments => 'அனைத்து கருத்துகளையும் காண்க';

  @override
  String get viewCommentSource => 'கருத்து மூலத்தைக் காண்க';

  @override
  String get viewModlog => 'மோட்லாக் காண்க';

  @override
  String get viewOriginal => 'அசல் காண்க';

  @override
  String get viewPostAsDifferentAccount => 'இடுகையை வெவ்வேறு கணக்காக காண்க';

  @override
  String get viewPostSource => 'பிந்தைய மூலத்தைக் காண்க';

  @override
  String get viewSource => 'மூலத்தைக் காண்க';

  @override
  String get viewingAll => 'அனைத்தையும் பார்க்கிறது';

  @override
  String visibility(Object visibility) {
    return 'தெரிவுநிலை: $visibility';
  }

  @override
  String get visitCommunity => 'சமூகத்தைப் பார்வையிடவும்';

  @override
  String get visitCommunityInstance => 'சமூக நிகழ்வைப் பார்வையிடவும்';

  @override
  String get visitInstance => 'நிகழ்வைப் பார்வையிடவும்';

  @override
  String get visitUserInstance => 'பயனர் நிகழ்வைப் பார்வையிடவும்';

  @override
  String get visitUserProfile => 'பயனர் சுயவிவரத்தைப் பார்வையிடவும்';

  @override
  String get warning => 'எச்சரிக்கை';

  @override
  String xDownvotes(Object x) {
    return '$x கீழ்நோக்கி';
  }

  @override
  String xScore(Object x) {
    return '$x மதிப்பெண்';
  }

  @override
  String xUpvotes(Object x) {
    return '$x மேல்வாக்குகள்';
  }

  @override
  String xYearsOld(num count, Object x) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$x ஆண்டுகள் பழையது',
      one: '$x ஆண்டு பழையது',
      zero: '$x ஆண்டு பழையது',
    );
    return '$_temp0';
  }

  @override
  String get yes => 'ஆம்';

  @override
  String get youMustSelectAJsonFile =>
      'நீங்கள் ஒரு .json கோப்பைத் தேர்ந்தெடுக்க வேண்டும்.';
}
