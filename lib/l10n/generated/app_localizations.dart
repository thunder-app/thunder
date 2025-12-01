import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_be.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_eo.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('be'),
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('en', 'AU'),
    Locale('en', 'GB'),
    Locale('eo'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('hu'),
    Locale('it'),
    Locale('nb'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('sk'),
    Locale('sv'),
    Locale('ta'),
    Locale('tr'),
    Locale('uk'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans')
  ];

  /// About settings category.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// The ability to accept an option
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @accessibilityProfilesDescription.
  ///
  /// In en, this message translates to:
  /// **'Accessibility profiles allows applying several settings at once to accommodate a particular accessibility requirement.'**
  String get accessibilityProfilesDescription;

  /// Describes the user account
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Account} one {Account} other {Accounts} } '**
  String account(num count);

  /// User descriptor for accounts created on today's date
  ///
  /// In en, this message translates to:
  /// **'Account Birthday {additionalInfo}'**
  String accountBirthday(Object additionalInfo);

  /// Warning for account settings override
  ///
  /// In en, this message translates to:
  /// **'Your account settings override the following settings'**
  String get accountSettingOverrideWarning;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Message shown to user when account settings are exported successfully
  ///
  /// In en, this message translates to:
  /// **'Lemmy account settings exported successfully to {savedFilePath}!'**
  String accountSettingsExportedSuccessfully(Object savedFilePath);

  /// Message shown to user when account settings are imported successfully
  ///
  /// In en, this message translates to:
  /// **'Lemmy account settings imported successfully!'**
  String get accountSettingsImportedSuccessfully;

  /// Error message for when we couldn't resolve comment to reply to
  ///
  /// In en, this message translates to:
  /// **'The selected comment was not found on \'{instance}\''**
  String accountSwitchParentCommentNotFound(Object instance);

  /// Error message for when we couldn't resolve post to reply to
  ///
  /// In en, this message translates to:
  /// **'The selected post was not found on \'{instance}\''**
  String accountSwitchPostNotFound(Object instance);

  /// Setting heading for action colors
  ///
  /// In en, this message translates to:
  /// **'Action Colors'**
  String get actionColors;

  /// Redirect hint to action colors
  ///
  /// In en, this message translates to:
  /// **'Looking to customize colors?'**
  String get actionColorsRedirect;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// A heading describing a user's activity statistics (e.g., posts/comments created)
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @addAccountToSeeProfile.
  ///
  /// In en, this message translates to:
  /// **'Log in to see your account.'**
  String get addAccountToSeeProfile;

  /// No description provided for @addAnonymousInstance.
  ///
  /// In en, this message translates to:
  /// **'Add Anonymous Instance'**
  String get addAnonymousInstance;

  /// Moderator action to add a user as community moderator
  ///
  /// In en, this message translates to:
  /// **'Add as Community Moderator'**
  String get addAsCommunityModerator;

  /// Hint for text field to add language
  ///
  /// In en, this message translates to:
  /// **'Add Language'**
  String get addDiscussionLanguage;

  /// Hint for text field to add keyword
  ///
  /// In en, this message translates to:
  /// **'Add Keyword'**
  String get addKeywordFilter;

  /// Prompt to add the original post body to a cross post
  ///
  /// In en, this message translates to:
  /// **'Add original post body?'**
  String get addOriginalPostBody;

  /// Action to add a community in drawer to favorites
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// Action for adding a user label
  ///
  /// In en, this message translates to:
  /// **'Add User Label'**
  String get addUserLabel;

  /// No description provided for @addedCommunityToSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscribed to community'**
  String get addedCommunityToSubscriptions;

  /// Short decription for moderator action to add a mod to an instance
  ///
  /// In en, this message translates to:
  /// **'Added Instance Mod'**
  String get addedInstanceMod;

  /// Short decription for moderator action to add a mod to a community
  ///
  /// In en, this message translates to:
  /// **'Added Mod to Community'**
  String get addedModToCommunity;

  /// Short decription for moderator action to add a user as community moderator
  ///
  /// In en, this message translates to:
  /// **'Added {username} as community moderator'**
  String addedUserAsCommunityModerator(Object username);

  /// Role name for admin
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// Heading for advanced settings
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// Represents a duration in the past
  ///
  /// In en, this message translates to:
  /// **'{time} ago'**
  String ago(Object time);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allPosts.
  ///
  /// In en, this message translates to:
  /// **'All Posts'**
  String get allPosts;

  /// Option to permit the app to open supported links.
  ///
  /// In en, this message translates to:
  /// **'Allow app to open supported links.'**
  String get allowOpenSupportedLinks;

  /// No description provided for @alreadyPostedTo.
  ///
  /// In en, this message translates to:
  /// **'Already posted to'**
  String get alreadyPostedTo;

  /// Create/edit post field for adding alt text to an image post
  ///
  /// In en, this message translates to:
  /// **'Alt Text'**
  String get altText;

  /// Action for viewing a link from alternate sources
  ///
  /// In en, this message translates to:
  /// **'Alternate Sources'**
  String get alternateSources;

  /// No description provided for @always.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get always;

  /// Represents a number of items
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String andXMore(Object count);

  /// No description provided for @animations.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get animations;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// Heading for the anonymous instances section of the login page
  ///
  /// In en, this message translates to:
  /// **'Anonymous Instances'**
  String get anonymousInstances;

  /// Language selection in settings.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// Title of Appearance in Settings -> Appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Describes the notification type for Apple Push Notification Service
  ///
  /// In en, this message translates to:
  /// **'Apple Push Notification Service'**
  String get applePushNotificationService;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// A status indicator for whether notifications are allowed by OS permissions
  ///
  /// In en, this message translates to:
  /// **'Notifications are allowed by system: {yesOrNo}'**
  String areNotificationsAllowedBySystem(Object yesOrNo);

  /// Describes the average number of comments created in the past month
  ///
  /// In en, this message translates to:
  /// **'{x} comments/month'**
  String averageComments(Object x);

  /// Describes the average number of contributions (both posts and comments) in the past month
  ///
  /// In en, this message translates to:
  /// **'{x} contributions/month'**
  String averageContributions(Object x);

  /// Describes the average number of posts created in the past month
  ///
  /// In en, this message translates to:
  /// **'{x} posts/month'**
  String averagePosts(Object x);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back button'**
  String get backButton;

  /// No description provided for @backToTop.
  ///
  /// In en, this message translates to:
  /// **'Back To Top'**
  String get backToTop;

  /// Warning for enabling notifications
  ///
  /// In en, this message translates to:
  /// **'Note that notification checks will consume additional battery'**
  String get backgroundCheckWarning;

  /// Short decription for moderator action to ban a user
  ///
  /// In en, this message translates to:
  /// **'Ban'**
  String get ban;

  /// Moderator action to ban a user from a community
  ///
  /// In en, this message translates to:
  /// **'Ban from Community'**
  String get banFromCommunity;

  /// Short decription for moderator action to ban a user
  ///
  /// In en, this message translates to:
  /// **'Banned User'**
  String get bannedUser;

  /// Short decription for moderator action to ban a user from a community
  ///
  /// In en, this message translates to:
  /// **'Banned User from Community'**
  String get bannedUserFromCommunity;

  /// Description for base font scale
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get base;

  /// Action for blocking an item
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @blockCommunity.
  ///
  /// In en, this message translates to:
  /// **'Block Community'**
  String get blockCommunity;

  /// Action to block the instance of a community
  ///
  /// In en, this message translates to:
  /// **'Block Community Instance'**
  String get blockCommunityInstance;

  /// No description provided for @blockInstance.
  ///
  /// In en, this message translates to:
  /// **'Block Instance'**
  String get blockInstance;

  /// Setting for user, community, and instance block settings
  ///
  /// In en, this message translates to:
  /// **'Block Management'**
  String get blockManagement;

  /// Setting for user, community, and instance block settings
  ///
  /// In en, this message translates to:
  /// **'User/Community/Instance Blocks'**
  String get blockSettingLabel;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// Action to block the instance of a user
  ///
  /// In en, this message translates to:
  /// **'Block User Instance'**
  String get blockUserInstance;

  /// No description provided for @blockedCommunities.
  ///
  /// In en, this message translates to:
  /// **'Blocked Communities'**
  String get blockedCommunities;

  /// No description provided for @blockedInstances.
  ///
  /// In en, this message translates to:
  /// **'Blocked Instances'**
  String get blockedInstances;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// The color blue
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// Bold name thickness/weight
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// Setting for bolding the community name
  ///
  /// In en, this message translates to:
  /// **'Bold Community Name'**
  String get boldCommunityName;

  /// Setting for bolding the instance name
  ///
  /// In en, this message translates to:
  /// **'Bold Instance Name'**
  String get boldInstanceName;

  /// Setting for bolding the username
  ///
  /// In en, this message translates to:
  /// **'Bold User Name'**
  String get boldUserName;

  /// Label for a bot user.
  ///
  /// In en, this message translates to:
  /// **'Bot'**
  String get bot;

  /// Title for link handling setting (called browserMode internally)
  ///
  /// In en, this message translates to:
  /// **'Link handling'**
  String get browserMode;

  /// Message shown to user when browsing anonymously
  ///
  /// In en, this message translates to:
  /// **'You are currently browsing {instance} anonymously.'**
  String browsingAnonymously(Object instance);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cannotReportOwnComment.
  ///
  /// In en, this message translates to:
  /// **'You may not submit a report for your own comment.'**
  String get cannotReportOwnComment;

  /// No description provided for @cantBlockAdmin.
  ///
  /// In en, this message translates to:
  /// **'You may not block an instance administrator.'**
  String get cantBlockAdmin;

  /// No description provided for @cantBlockYourself.
  ///
  /// In en, this message translates to:
  /// **'You may not block yourself.'**
  String get cantBlockYourself;

  /// Name of setting for card post card metadata items
  ///
  /// In en, this message translates to:
  /// **'Card View Metadata'**
  String get cardPostCardMetadataItems;

  /// Label for the card view option in Setting -> Appearance -> Posts
  ///
  /// In en, this message translates to:
  /// **'Card View'**
  String get cardView;

  /// Description for the card view subcategory in Setting -> Appearance -> Posts
  ///
  /// In en, this message translates to:
  /// **'Enable card view to adjust settings'**
  String get cardViewDescription;

  /// Subcategory in Setting -> Appearance -> Posts
  ///
  /// In en, this message translates to:
  /// **'Card View Settings'**
  String get cardViewSettings;

  /// Heading for the profiler modal when changing account settings
  ///
  /// In en, this message translates to:
  /// **'Change account settings for'**
  String get changeAccountSettingsFor;

  /// A shortcut to navigate to the notification settings
  ///
  /// In en, this message translates to:
  /// **'Change notification settings...'**
  String get changeNotificationSettings;

  /// Label for action to change password
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Warning label for changing password
  ///
  /// In en, this message translates to:
  /// **'To change your password, you will be redirected to your instance site. \n\nAre you sure you want to continue?'**
  String get changePasswordWarning;

  /// No description provided for @changeSort.
  ///
  /// In en, this message translates to:
  /// **'Change Sort'**
  String get changeSort;

  /// Label for action to clear cache in the dialog
  ///
  /// In en, this message translates to:
  /// **'Clear Cache ({cacheSize})'**
  String clearCache(Object cacheSize);

  /// Label for action to clear cache in the dialog
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCacheLabel;

  /// Label for action to clear local database in the dialog
  ///
  /// In en, this message translates to:
  /// **'Clear Database'**
  String get clearDatabase;

  /// Label for action to clear local user preferences in the dialog
  ///
  /// In en, this message translates to:
  /// **'Clear Preferences'**
  String get clearPreferences;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// Message indicating that cache was cleared successfully
  ///
  /// In en, this message translates to:
  /// **'Cleared cache successfully.'**
  String get clearedCache;

  /// No description provided for @clearedDatabase.
  ///
  /// In en, this message translates to:
  /// **'Local database cleared. Restart Thunder for new changes to take effect.'**
  String get clearedDatabase;

  /// No description provided for @clearedUserPreferences.
  ///
  /// In en, this message translates to:
  /// **'Cleared all user preferences'**
  String get clearedUserPreferences;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Action to collapse something
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// Semantic label for the collapse button in Setting -> Appearance -> Comments
  ///
  /// In en, this message translates to:
  /// **'Collapse Comment Preview'**
  String get collapseCommentPreview;

  /// Describes the action to collapse information - used in FAB settings
  ///
  /// In en, this message translates to:
  /// **'Collapse Information'**
  String get collapseInformation;

  /// Toggle to collapse parent comment body on gesture.
  ///
  /// In en, this message translates to:
  /// **'Hide Parent Comment when Collapsed'**
  String get collapseParentCommentBodyOnGesture;

  /// No description provided for @collapsePost.
  ///
  /// In en, this message translates to:
  /// **'Collapse post'**
  String get collapsePost;

  /// Semantic label for the collapse button in Setting -> Appearance -> Posts
  ///
  /// In en, this message translates to:
  /// **'Collapse Post Preview'**
  String get collapsePostPreview;

  /// Label for collapsing spoiler
  ///
  /// In en, this message translates to:
  /// **'Collapse Spoiler'**
  String get collapseSpoiler;

  /// Describes a color
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Setting for colorizing community name
  ///
  /// In en, this message translates to:
  /// **'Colorize Community Name'**
  String get colorizeCommunityName;

  /// Setting for colorizing instance name
  ///
  /// In en, this message translates to:
  /// **'Colorize Instance Name'**
  String get colorizeInstanceName;

  /// Setting for colorizing username
  ///
  /// In en, this message translates to:
  /// **'Colorize User Name'**
  String get colorizeUserName;

  /// Heading for colors
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get colors;

  /// Toggle to combine comment scores.
  ///
  /// In en, this message translates to:
  /// **'Combine Comment Scores'**
  String get combineCommentScores;

  /// Label for setting to combine comment scores
  ///
  /// In en, this message translates to:
  /// **'Combine Comment Scores'**
  String get combineCommentScoresLabel;

  /// No description provided for @combineNavAndFab.
  ///
  /// In en, this message translates to:
  /// **'Combine FAB and Navigation Buttons'**
  String get combineNavAndFab;

  /// No description provided for @combineNavAndFabDescription.
  ///
  /// In en, this message translates to:
  /// **'Floating Action Button will be shown between navigation buttons.'**
  String get combineNavAndFabDescription;

  /// Describes a comfortable visual density
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get comfortable;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// Title for the comment actions bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Comment Actions'**
  String get commentActions;

  /// Subcategory in Setting -> General
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentBehaviourSettings;

  /// Setting for comment font scale
  ///
  /// In en, this message translates to:
  /// **'Comment Content Font Scale'**
  String get commentFontScale;

  /// Description for the comment preview in Setting -> Appearance -> Comments
  ///
  /// In en, this message translates to:
  /// **'Show a preview of the comments with the given settings'**
  String get commentPreview;

  /// No description provided for @commentReported.
  ///
  /// In en, this message translates to:
  /// **'The comment has been marked for review.'**
  String get commentReported;

  /// No description provided for @commentSavedAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Comment saved as draft'**
  String get commentSavedAsDraft;

  /// Settings toggle to display user avatar alongside their display name in comments
  ///
  /// In en, this message translates to:
  /// **'Show User Avatar'**
  String get commentShowUserAvatar;

  /// Settings toggle to display user instance alongside their display name in comments
  ///
  /// In en, this message translates to:
  /// **'Show User Instance'**
  String get commentShowUserInstance;

  /// No description provided for @commentSortType.
  ///
  /// In en, this message translates to:
  /// **'Comment Sort Type'**
  String get commentSortType;

  /// Setting for comment swipe actions
  ///
  /// In en, this message translates to:
  /// **'Comment Swipe Actions'**
  String get commentSwipeActions;

  /// No description provided for @commentSwipeGesturesHint.
  ///
  /// In en, this message translates to:
  /// **'Looking to use buttons instead? Enable them in the comments section in general settings.'**
  String get commentSwipeGesturesHint;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @communities.
  ///
  /// In en, this message translates to:
  /// **'Communities'**
  String get communities;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// Heading for community actions page
  ///
  /// In en, this message translates to:
  /// **'Community Actions'**
  String get communityActions;

  /// Entry in list for a community to perform further actions
  ///
  /// In en, this message translates to:
  /// **'Community \'{community}\''**
  String communityEntry(Object community);

  /// Setting for community full name format
  ///
  /// In en, this message translates to:
  /// **'Community Format'**
  String get communityFormat;

  /// Setting for community name color
  ///
  /// In en, this message translates to:
  /// **'Community Name Color'**
  String get communityNameColor;

  /// Setting for community name thickness
  ///
  /// In en, this message translates to:
  /// **'Community Name Thickness'**
  String get communityNameThickness;

  /// Heading for community style setting
  ///
  /// In en, this message translates to:
  /// **'Community Style'**
  String get communityStyle;

  /// Describes a compact visual density
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get compact;

  /// Name of setting for compact post card metadata items
  ///
  /// In en, this message translates to:
  /// **'Compact View Metadata'**
  String get compactPostCardMetadataItems;

  /// Label for the compact view option in Setting -> Appearance -> Posts
  ///
  /// In en, this message translates to:
  /// **'Compact View'**
  String get compactView;

  /// Description for the compact view subcategory in Setting -> Appearance -> Posts
  ///
  /// In en, this message translates to:
  /// **'Enable compact view to adjust settings'**
  String get compactViewDescription;

  /// Subcategory in Setting -> Appearance -> Posts
  ///
  /// In en, this message translates to:
  /// **'Compact View Settings'**
  String get compactViewSettings;

  /// Condensed post body view type
  ///
  /// In en, this message translates to:
  /// **'Condensed'**
  String get condensed;

  /// Label for the confirm action in the dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// The body of the confirm logout dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogOutBody;

  /// The title of the confirm logout dialog
  ///
  /// In en, this message translates to:
  /// **'Log Out?'**
  String get confirmLogOutTitle;

  /// The body of the confirm mark all as read dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark all replies, mentions, and messages as read?'**
  String get confirmMarkAllAsReadBody;

  /// The title of the confirm mark all as read dialog
  ///
  /// In en, this message translates to:
  /// **'Mark all as read?'**
  String get confirmMarkAllAsReadTitle;

  /// Description for reset preferences dialog in Setting -> Appearance -> Comments
  ///
  /// In en, this message translates to:
  /// **'This will reset all comment preferences. Are you sure you want to proceed?'**
  String get confirmResetCommentPreferences;

  /// Description for reset preferences dialog in Setting -> Appearance -> Posts
  ///
  /// In en, this message translates to:
  /// **'This will reset all post preferences. Are you sure you want to proceed?'**
  String get confirmResetPostPreferences;

  /// Ask the user to confirm that they want to unsubscribe
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unsubscribe?'**
  String get confirmUnsubscription;

  /// Tell the user which UnifiedPush app we're connected to
  ///
  /// In en, this message translates to:
  /// **'Conected to {app}'**
  String connectedToUnifiedPushDistributorApp(Object app);

  /// Setting for content management (languages/blocking)
  ///
  /// In en, this message translates to:
  /// **'Content Management'**
  String get contentManagement;

  /// Heading for content warning dialog
  ///
  /// In en, this message translates to:
  /// **'Content Warning'**
  String get contentWarning;

  /// No description provided for @controversial.
  ///
  /// In en, this message translates to:
  /// **'Controversial'**
  String get controversial;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Action for copying a whole comment
  ///
  /// In en, this message translates to:
  /// **'Copy Comment'**
  String get copyComment;

  /// Action for copying selected text
  ///
  /// In en, this message translates to:
  /// **'Copy selected'**
  String get copySelected;

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy Text'**
  String get copyText;

  /// No description provided for @couldNotDetermineCommentDelete.
  ///
  /// In en, this message translates to:
  /// **'Error: Could not determine post to delete the comment.'**
  String get couldNotDetermineCommentDelete;

  /// No description provided for @couldNotDeterminePostComment.
  ///
  /// In en, this message translates to:
  /// **'Error: Could not determine post to comment to.'**
  String get couldNotDeterminePostComment;

  /// No description provided for @couldntCreateReport.
  ///
  /// In en, this message translates to:
  /// **'Your comment report could not be submitted at this time. Please try again later'**
  String get couldntCreateReport;

  /// Error message for when we can't load a post.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the requested post. It may have been deleted or removed.'**
  String get couldntFindPost;

  /// Number of comments
  ///
  /// In en, this message translates to:
  /// **'{count} Comments'**
  String countComments(Object count);

  /// Number of local subscribers
  ///
  /// In en, this message translates to:
  /// **'{count} Local Subscribers'**
  String countLocalSubscribers(Object count);

  /// Number of posts
  ///
  /// In en, this message translates to:
  /// **'{count} Posts'**
  String countPosts(Object count);

  /// Number of subscribers
  ///
  /// In en, this message translates to:
  /// **'{count} Subscribers'**
  String countSubscribers(Object count);

  /// Describes a certain number of users
  ///
  /// In en, this message translates to:
  /// **'{count} users'**
  String countUsers(Object count);

  /// Number of users active in the last day
  ///
  /// In en, this message translates to:
  /// **'{count} users/day'**
  String countUsersActiveDay(Object count);

  /// Number of users active in the last half year
  ///
  /// In en, this message translates to:
  /// **'{count} users/6 mo'**
  String countUsersActiveHalfYear(Object count);

  /// Number of users active in the last month
  ///
  /// In en, this message translates to:
  /// **'{count} users/mo'**
  String countUsersActiveMonth(Object count);

  /// Number of users active in the last week
  ///
  /// In en, this message translates to:
  /// **'{count} users/wk'**
  String countUsersActiveWeek(Object count);

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createComment.
  ///
  /// In en, this message translates to:
  /// **'Create Comment'**
  String get createComment;

  /// No description provided for @createNewCrossPost.
  ///
  /// In en, this message translates to:
  /// **'Create new cross-post'**
  String get createNewCrossPost;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// The date that something was created
  ///
  /// In en, this message translates to:
  /// **'Created {date}'**
  String created(Object date);

  /// An account descriptor for an account with a birthday today
  ///
  /// In en, this message translates to:
  /// **'Created Today'**
  String get createdToday;

  /// The creator filter for searches.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creator;

  /// Initial heading for text-based cross-post
  ///
  /// In en, this message translates to:
  /// **'cross-posted from: {postUrl}'**
  String crossPostedFrom(Object postUrl);

  /// No description provided for @crossPostedTo.
  ///
  /// In en, this message translates to:
  /// **'Cross-posted to'**
  String get crossPostedTo;

  /// No description provided for @currentLongPress.
  ///
  /// In en, this message translates to:
  /// **'Currently set as long press'**
  String get currentLongPress;

  /// A status indicator for the current notifications mode
  ///
  /// In en, this message translates to:
  /// **'Current notifications mode: {mode}'**
  String currentNotificationsMode(Object mode);

  /// No description provided for @currentSinglePress.
  ///
  /// In en, this message translates to:
  /// **'Currently set as single press'**
  String get currentSinglePress;

  /// No description provided for @customizeSwipeActions.
  ///
  /// In en, this message translates to:
  /// **'Customize swipe actions (tap to change)'**
  String get customizeSwipeActions;

  /// Describes a section where the actions could be dangerous (e.g., permanently deleting account)
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// Describes using the dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Message shown to the user when exporting the db
  ///
  /// In en, this message translates to:
  /// **'The database may contain sensitive information related to your Lemmy account. If you export it, you should not share it with anyone. Do you want to proceed?'**
  String get databaseExportWarning;

  /// Message shown to the user when the db was successfully exported
  ///
  /// In en, this message translates to:
  /// **'The database was successfully exported to \'{savedFilePath}\''**
  String databaseExportedSuccessfully(Object savedFilePath);

  /// Message shown to the user when the db was successfully imported
  ///
  /// In en, this message translates to:
  /// **'The database was imported successfully!'**
  String get databaseImportedSuccessfully;

  /// Message shown to the user when the db was unsuccessfully exported
  ///
  /// In en, this message translates to:
  /// **'The database was not exported successfully or the operation was canceled.'**
  String get databaseNotExportedSuccessfully;

  /// Message shown to the user when the db was unsuccessfully imported
  ///
  /// In en, this message translates to:
  /// **'The database was not imported successfully, or the operation was canceled.'**
  String get databaseNotImportedSuccessfully;

  /// Setting for date format
  ///
  /// In en, this message translates to:
  /// **'Date Format'**
  String get dateFormat;

  /// Debug settings category.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get debug;

  /// Explanation for debug settings page
  ///
  /// In en, this message translates to:
  /// **'The following debug settings should only be used for troubleshooting purposes.'**
  String get debugDescription;

  /// A description for the notification debugging section
  ///
  /// In en, this message translates to:
  /// **'Use the following options to troubleshoot issues related to notifications.'**
  String get debugNotificationsDescription;

  /// The ability to decline an option
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Default setting value (e.g., color)
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultColor;

  /// Setting for default comment sort type
  ///
  /// In en, this message translates to:
  /// **'Default Comment Sort Type'**
  String get defaultCommentSortType;

  /// Default sorting type for the feed.
  ///
  /// In en, this message translates to:
  /// **'Default Feed Sort Type'**
  String get defaultFeedSortType;

  /// Default listing type for the feed.
  ///
  /// In en, this message translates to:
  /// **'Default Feed Type'**
  String get defaultFeedType;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Label for action to delete account
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Description for confirmation action to delete account
  ///
  /// In en, this message translates to:
  /// **'To permanently delete your account, you will be redirected to your instance site. \n\nAre you sure you want to continue?'**
  String get deleteAccountDescription;

  /// Action for deleting a comment
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteComment;

  /// Confirmation messages for deleting an image
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this image?'**
  String get deleteImageConfirmMessage;

  /// Confirmation title message for deleting an image
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get deleteImageConfirmTitle;

  /// Label for action to delete local database
  ///
  /// In en, this message translates to:
  /// **'Delete Local Database'**
  String get deleteLocalDatabase;

  /// Description for confirmation action to delete local database
  ///
  /// In en, this message translates to:
  /// **'This action will remove the local database and will log you out of all your accounts.\n\nAre you sure you want to continue?'**
  String get deleteLocalDatabaseDescription;

  /// Label for action to delete local preferences
  ///
  /// In en, this message translates to:
  /// **'Delete Local Preferences'**
  String get deleteLocalPreferences;

  /// Description for confirmation action to delete local preferences
  ///
  /// In en, this message translates to:
  /// **'This will clear all your user preferences and settings in Thunder.\n\nDo you want to continue?'**
  String get deleteLocalPreferencesDescription;

  /// Action for deleting a post
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// Confirmation message for deleting a label
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the label?'**
  String get deleteUserLabelConfirmation;

  /// Status to indicate that an item has been deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// Placeholder text for a comment deleted by the creator. Be sure to keep this lowercase.
  ///
  /// In en, this message translates to:
  /// **'deleted by creator'**
  String get deletedByCreator;

  /// Placeholder text for a comment deleted by a moderator. Be sure to keep this lowercase.
  ///
  /// In en, this message translates to:
  /// **'deleted by moderator'**
  String get deletedByModerator;

  /// Message shown when a comment is deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted comment'**
  String get deletedComment;

  /// Message shown when a post is deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted post'**
  String get deletedPost;

  /// No description provided for @deselectUndeterminedWarning.
  ///
  /// In en, this message translates to:
  /// **'If you deselect Undetermined, you will not see most content.'**
  String get deselectUndeterminedWarning;

  /// The reason for the moderation action
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String detailedReason(Object reason);

  /// Description of the effect on read posts.
  ///
  /// In en, this message translates to:
  /// **'Dim Read Posts'**
  String get dimReadPosts;

  /// Action for disabling something
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// Description when disabling push notifications
  ///
  /// In en, this message translates to:
  /// **'Disable Push Notifications'**
  String get disablePushNotifications;

  /// Describes the state of something that is disabled
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Only load posts and communities in your language(s)
  ///
  /// In en, this message translates to:
  /// **'Discussion Languages'**
  String get discussionLanguages;

  /// No description provided for @discussionLanguagesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Content is filtered to the selected languages.'**
  String get discussionLanguagesTooltip;

  /// No description provided for @dismissRead.
  ///
  /// In en, this message translates to:
  /// **'Dismiss Read'**
  String get dismissRead;

  /// Label for display name
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// Option for displaying user scores or karma.
  ///
  /// In en, this message translates to:
  /// **'Display User Scores (Karma).'**
  String get displayUserScore;

  /// Divider appearance category
  ///
  /// In en, this message translates to:
  /// **'Divider Appearance'**
  String get dividerAppearance;

  /// Action for hiding something permanently
  ///
  /// In en, this message translates to:
  /// **'Do Not Show Again'**
  String get doNotShowAgain;

  /// Tell the user we don't currently support multiple UnifiedPush apps
  ///
  /// In en, this message translates to:
  /// **'Found multiple compatible apps; please install only one'**
  String get doNotSupportMultipleUnifiedPushApps;

  /// No description provided for @downloadingMedia.
  ///
  /// In en, this message translates to:
  /// **'Downloading media to share…'**
  String get downloadingMedia;

  /// Action for downvoting a post/comment
  ///
  /// In en, this message translates to:
  /// **'Downvote'**
  String get downvote;

  /// Name of downvote color setting
  ///
  /// In en, this message translates to:
  /// **'Downvote Color'**
  String get downvoteColor;

  /// Short description for downvoting a post/comment
  ///
  /// In en, this message translates to:
  /// **'Downvoted'**
  String get downvoted;

  /// No description provided for @downvotesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Downvotes are turned off on this instance.'**
  String get downvotesDisabled;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editComment.
  ///
  /// In en, this message translates to:
  /// **'Edit Comment'**
  String get editComment;

  /// Title when editing a post.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPost;

  /// Label for email input
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @emptyInbox.
  ///
  /// In en, this message translates to:
  /// **'Empty Inbox'**
  String get emptyInbox;

  /// Error message for empty link.
  ///
  /// In en, this message translates to:
  /// **'The link is empty. Please provide a valid dynamic link to proceed.'**
  String get emptyUri;

  /// Setting for enable comment navigation
  ///
  /// In en, this message translates to:
  /// **'Enable Comment Navigation'**
  String get enableCommentNavigation;

  /// Setting to enable experimental features
  ///
  /// In en, this message translates to:
  /// **'Enable experimental features'**
  String get enableExperimentalFeatures;

  /// Enable the Floating Action Button for the feed
  ///
  /// In en, this message translates to:
  /// **'Enable Floating Button on Feeds'**
  String get enableFeedFab;

  /// Setting for enable floating button on feeds
  ///
  /// In en, this message translates to:
  /// **'Enable Floating Button On Feeds'**
  String get enableFloatingButtonOnFeeds;

  /// Setting for enable floating button on posts
  ///
  /// In en, this message translates to:
  /// **'Enable Floating Button On Posts'**
  String get enableFloatingButtonOnPosts;

  /// Setting name for inbox notifications
  ///
  /// In en, this message translates to:
  /// **'Enable Inbox Notifications'**
  String get enableInboxNotifications;

  /// Enable the Floating Action Button for the post
  ///
  /// In en, this message translates to:
  /// **'Enable Floating Button on Posts'**
  String get enablePostFab;

  /// No description provided for @endOfComments.
  ///
  /// In en, this message translates to:
  /// **'End of comments'**
  String get endOfComments;

  /// No description provided for @endSearch.
  ///
  /// In en, this message translates to:
  /// **'End Search'**
  String get endSearch;

  /// Error message for deleting an image
  ///
  /// In en, this message translates to:
  /// **'There was an error deleting the image: {error}'**
  String errorDeletingImage(Object error);

  /// Error message for downloading media
  ///
  /// In en, this message translates to:
  /// **'Could not download the media file to share: {errorMessage}'**
  String errorDownloadingMedia(Object errorMessage);

  /// Message shown to user when account there was an error importing the settings
  ///
  /// In en, this message translates to:
  /// **'There was an error importing the settings. The file might not be in the right format.'**
  String get errorImportingAccountSettings;

  /// Error message for initializing client
  ///
  /// In en, this message translates to:
  /// **'Error initializing client'**
  String get errorInitializingClient;

  /// Message shown to user when there was an error loading the settings file
  ///
  /// In en, this message translates to:
  /// **'There was an error loading the settings file or the operation was canceled.'**
  String get errorLoadingAccountSettings;

  /// Error message for marking a reply read
  ///
  /// In en, this message translates to:
  /// **'There was an error marking the reply as read.'**
  String get errorMarkingReplyRead;

  /// Error message for marking a reply unread
  ///
  /// In en, this message translates to:
  /// **'There was an error marking the reply as unread.'**
  String get errorMarkingReplyUnread;

  /// Error message for no active instance found
  ///
  /// In en, this message translates to:
  /// **'No active instance found'**
  String get errorNoActiveInstance;

  /// Message shown to user when there was an error parsing the selected file
  ///
  /// In en, this message translates to:
  /// **'There was an error parsing the selected file. It may not be valid JSON.'**
  String get errorParsingJson;

  /// Message shown to user when there was an error saving the settings file
  ///
  /// In en, this message translates to:
  /// **'There was an error saving the settings file or the operation was canceled.'**
  String get errorSavingAccountSettings;

  /// An unspecified error during link processing.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while processing the link. It may not be available on your instance.'**
  String get exceptionProcessingUri;

  /// A message shown to the user when the feed is taking a long time to load, possibly because many posts are being filtered out due to their keyword filters
  ///
  /// In en, this message translates to:
  /// **'Your feed may be taking a while to load due to keyword filters.'**
  String get excessiveApiCallsWarning;

  /// Action to expand something
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// Semantic label for the expand button in Setting -> Appearance -> Comments
  ///
  /// In en, this message translates to:
  /// **'Expand Comment Preview'**
  String get expandCommentPreview;

  /// Describes the action to expand information - used in FAB settings
  ///
  /// In en, this message translates to:
  /// **'Expand Information'**
  String get expandInformation;

  /// No description provided for @expandOptions.
  ///
  /// In en, this message translates to:
  /// **'Expand options'**
  String get expandOptions;

  /// No description provided for @expandPost.
  ///
  /// In en, this message translates to:
  /// **'Expand post'**
  String get expandPost;

  /// Semantic label for the expand button in Setting -> Appearance -> Posts
  ///
  /// In en, this message translates to:
  /// **'Expand Post Preview'**
  String get expandPostPreview;

  /// Label for expanding spoiler
  ///
  /// In en, this message translates to:
  /// **'Expand Spoiler'**
  String get expandSpoiler;

  /// Expanded post body view type
  ///
  /// In en, this message translates to:
  /// **'Expanded'**
  String get expanded;

  /// Name of setting for experimental features
  ///
  /// In en, this message translates to:
  /// **'Experimental Features'**
  String get experimentalFeatures;

  /// Description for experimental features setting
  ///
  /// In en, this message translates to:
  /// **'These features are still in development and may be unstable. Use them at your own risk. You must restart Thunder to take effect.'**
  String get experimentalFeaturesDescription;

  /// Button for exploring an instance
  ///
  /// In en, this message translates to:
  /// **'Explore instance'**
  String get exploreInstance;

  /// Name of the setting for exporting the db
  ///
  /// In en, this message translates to:
  /// **'Export Database'**
  String get exportDatabase;

  /// Subtitle of setting for exporting the db
  ///
  /// In en, this message translates to:
  /// **'The database contains info about accounts, favorites, anonymous subscriptions, and user labels.'**
  String get exportDatabaseSubtitle;

  /// Description for setting related to Lemmy account settings export
  ///
  /// In en, this message translates to:
  /// **'Export Lemmy account settings'**
  String get exportLemmyAccountSettingsDescription;

  /// Subtitle of setting for exporting settings
  ///
  /// In en, this message translates to:
  /// **'The settings includes all of the preferences that you have configured in Thunder.'**
  String get exportSettingsSubtitle;

  /// Description for extra large font scale
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get extraLarge;

  /// Error message for when we fail to block a user
  ///
  /// In en, this message translates to:
  /// **'Failed to block: {errorMessage}'**
  String failedToBlock(Object errorMessage);

  /// Error message for when we fail to communicate with Thunder notification server
  ///
  /// In en, this message translates to:
  /// **'Failed to communicate with Thunder notification server at {serverAddress}.'**
  String failedToCommunicateWithThunderNotificationServer(Object serverAddress);

  /// Error message for when we fail to load blocks
  ///
  /// In en, this message translates to:
  /// **'Could not load blocks: {errorMessage}'**
  String failedToLoadBlocks(Object errorMessage);

  /// Error message that displays when we fail to load a video
  ///
  /// In en, this message translates to:
  /// **'Failed to load video. Open link in browser?'**
  String get failedToLoadVideo;

  /// Error message when we fail to perform an action
  ///
  /// In en, this message translates to:
  /// **'Failed to perform action'**
  String get failedToPerformAction;

  /// Error message for when we fail to unblock a user
  ///
  /// In en, this message translates to:
  /// **'Could not unblock: {errorMessage}'**
  String failedToUnblock(Object errorMessage);

  /// Error message when failed to update notification settings.
  ///
  /// In en, this message translates to:
  /// **'Failed to update notification settings'**
  String get failedToUpdateNotificationSettings;

  /// Action for favoriting a community
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// The favorited communities on the drawer
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Short decription for moderator action to feature a post
  ///
  /// In en, this message translates to:
  /// **'Featured Post'**
  String get featuredPost;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// Subcategory in Setting -> General
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feedBehaviourSettings;

  /// Feed settings category.
  ///
  /// In en, this message translates to:
  /// **'Feed Settings'**
  String get feedSettings;

  /// Subcategory in Setting -> General
  ///
  /// In en, this message translates to:
  /// **'Default Feed Type and Sorting'**
  String get feedTypeAndSorts;

  /// No description provided for @fetchAccountError.
  ///
  /// In en, this message translates to:
  /// **'Could not determine account'**
  String get fetchAccountError;

  /// Filtering by a community or creator in search.
  ///
  /// In en, this message translates to:
  /// **'Filtering by {entity}'**
  String filteringBy(Object entity);

  /// Category to describe various filters (user, community, instance blocking)
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Floating Action Button settings category.
  ///
  /// In en, this message translates to:
  /// **'Floating Action Button'**
  String get floatingActionButton;

  /// Description of the FAB in the settings page
  ///
  /// In en, this message translates to:
  /// **'Thunder has a fully customizable FAB experience that supports a few gestures.\n- Swipe up to reveal additional FAB actions\n- Swipe down/up to hide or reveal the FAB\n\nTo customize the main and secondary actions for the FAB, long press on one of the actions below.'**
  String get floatingActionButtonInformation;

  /// Description of the FAB's long-press action
  ///
  /// In en, this message translates to:
  /// **'denotes the FAB\'s long-press action.'**
  String get floatingActionButtonLongPressDescription;

  /// Description of the FAB's single-press action
  ///
  /// In en, this message translates to:
  /// **'denotes the FAB\'s single-press action.'**
  String get floatingActionButtonSinglePressDescription;

  /// Settings category for fonts
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get fonts;

  /// Label for navigating forward (e.g., in a browser)
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// Tell the user we found a compatible UnifiedPush app but they have to restart to connect
  ///
  /// In en, this message translates to:
  /// **'Found compatible app; restart Thunder to connect'**
  String get foundUnifiedPushDistribtorApp;

  /// No description provided for @fullScreenNavigationSwipeDescription.
  ///
  /// In en, this message translates to:
  /// **'Swipe anywhere to go back when left-to-right gestures are disabled'**
  String get fullScreenNavigationSwipeDescription;

  /// Action for entering fullscreen
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get fullscreen;

  /// Setting for fullscreen swipe gestures
  ///
  /// In en, this message translates to:
  /// **'Fullscreen Swipe Gestures'**
  String get fullscreenSwipeGestures;

  /// General settings category.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Subcategory in Settings
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @gestures.
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get gestures;

  /// No description provided for @gettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get gettingStarted;

  /// The color green
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// Feed settings for guest accounts
  ///
  /// In en, this message translates to:
  /// **'Guest Mode Feed Settings'**
  String get guestModeFeedSettings;

  /// Description for guest mode feed settings
  ///
  /// In en, this message translates to:
  /// **'The following settings are only applied to guest accounts. To adjust feed settings for your account, go to Account Settings.'**
  String get guestModeFeedSettingsLabel;

  /// A shortcut to navigate to the notification debugging section
  ///
  /// In en, this message translates to:
  /// **'Having issues with notifications?'**
  String get havingIssuesWithNotifications;

  /// Short decription for moderator action to hide a community
  ///
  /// In en, this message translates to:
  /// **'Hid Community'**
  String get hidCommunity;

  /// Describes a post that is hidden
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get hidden;

  /// The action to hide a post
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// Settings toggle to hide the bottom navigation bar on scroll
  ///
  /// In en, this message translates to:
  /// **'Hide Bottom Bar on Scroll'**
  String get hideBottomBarOnScroll;

  /// Name of the hide color setting
  ///
  /// In en, this message translates to:
  /// **'Hide Color'**
  String get hideColor;

  /// Toggle to hide NSFW posts from the feed.
  ///
  /// In en, this message translates to:
  /// **'Hide NSFW Posts from Feed'**
  String get hideNsfwPostsFromFeed;

  /// Toggle to blur NSFW previews.
  ///
  /// In en, this message translates to:
  /// **'Blur NSFW Previews'**
  String get hideNsfwPreviews;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide Password'**
  String get hidePassword;

  /// Option to hide thumbnails in feed
  ///
  /// In en, this message translates to:
  /// **'Hide Thumbnails'**
  String get hideThumbnails;

  /// Settings toggle to hide the top bar on scroll
  ///
  /// In en, this message translates to:
  /// **'Hide Top Bar on Scroll'**
  String get hideTopBarOnScroll;

  /// The instance hosting a community
  ///
  /// In en, this message translates to:
  /// **'Host Instance'**
  String get hostInstance;

  /// No description provided for @hot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get hot;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// Title for setting related to image caching mode
  ///
  /// In en, this message translates to:
  /// **'Image Caching Mode'**
  String get imageCachingMode;

  /// Long description for aggressive image caching mode
  ///
  /// In en, this message translates to:
  /// **'Aggressively cache images (uses more memory)'**
  String get imageCachingModeAggressive;

  /// Short description for aggressive image caching mode
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get imageCachingModeAggressiveShort;

  /// Long description for relaxed image caching mode
  ///
  /// In en, this message translates to:
  /// **'Let image caches expire (uses less memory but causes images to reload more often)'**
  String get imageCachingModeRelaxed;

  /// Short description for relaxed image caching mode
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get imageCachingModeRelaxedShort;

  /// Setting for how long to wait for the image dimensions to be fetched
  ///
  /// In en, this message translates to:
  /// **'Image Dimension Timeout'**
  String get imageDimensionTimeout;

  /// Name of setting for importing the db
  ///
  /// In en, this message translates to:
  /// **'Import Database'**
  String get importDatabase;

  /// Overall name of setting for importing or exporting the db (for searching)
  ///
  /// In en, this message translates to:
  /// **'Import/Export Thunder Database'**
  String get importExportDatabase;

  /// This is specifically used in search results to distinguish from Thunder import/export
  ///
  /// In en, this message translates to:
  /// **'Import/Export Lemmy Account Settings'**
  String get importExportLemmyAccountSettings;

  /// Subtitle for Lemmy account settings import/export section
  ///
  /// In en, this message translates to:
  /// **'Includes subscribed communities, blocklists, and account preferences'**
  String get importExportLemmyAccountSettingsSubtitle;

  /// Category for settings related to import and export.
  ///
  /// In en, this message translates to:
  /// **'Import/Export Settings'**
  String get importExportSettings;

  /// This is specifically used in search results to distinguish from Lemmy import/export
  ///
  /// In en, this message translates to:
  /// **'Import/Export Thunder Settings'**
  String get importExportThunderSettings;

  /// Description for setting related to Lemmy account settings import
  ///
  /// In en, this message translates to:
  /// **'Import Lemmy account settings'**
  String get importLemmyAccountSettingsDescription;

  /// Action to import application settings.
  ///
  /// In en, this message translates to:
  /// **'Import Settings'**
  String get importSettings;

  /// Indicates that a comment/post is in reply to a certain post in a certain community
  ///
  /// In en, this message translates to:
  /// **'In reply to {post} in {community}'**
  String inReplyTo(Object post, Object community);

  /// Connecting word used to indicate that a certain comment/post post came from a certain community
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get in_;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @includeCommunity.
  ///
  /// In en, this message translates to:
  /// **'Include Community'**
  String get includeCommunity;

  /// No description provided for @includeExternalLink.
  ///
  /// In en, this message translates to:
  /// **'Include External Link'**
  String get includeExternalLink;

  /// No description provided for @includeImage.
  ///
  /// In en, this message translates to:
  /// **'Include Image'**
  String get includeImage;

  /// No description provided for @includePostLink.
  ///
  /// In en, this message translates to:
  /// **'Include Post Link'**
  String get includePostLink;

  /// No description provided for @includeText.
  ///
  /// In en, this message translates to:
  /// **'Include Text'**
  String get includeText;

  /// No description provided for @includeTitle.
  ///
  /// In en, this message translates to:
  /// **'Include Title'**
  String get includeTitle;

  /// Information heading - used in the FAB settings page
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// Heading for an instance
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Instance} one {Instance} other {Instances} } '**
  String instance(num count);

  /// Heading for instance actions page
  ///
  /// In en, this message translates to:
  /// **'Instance Actions'**
  String get instanceActions;

  /// Entry in list for a instance to perform further actions
  ///
  /// In en, this message translates to:
  /// **'Instance \'{username}\''**
  String instanceEntry(Object username);

  /// Error message for when an instance has already been added
  ///
  /// In en, this message translates to:
  /// **'{instance} has already been added.'**
  String instanceHasAlreadyBenAdded(Object instance);

  /// Setting for instance name color
  ///
  /// In en, this message translates to:
  /// **'Instance Name Color'**
  String get instanceNameColor;

  /// Setting for instance name thickness
  ///
  /// In en, this message translates to:
  /// **'Instance Name Thickness'**
  String get instanceNameThickness;

  /// Title for settings related to instances
  ///
  /// In en, this message translates to:
  /// **'Instances'**
  String get instances;

  /// No description provided for @internetOrInstanceIssues.
  ///
  /// In en, this message translates to:
  /// **'You may not be connected to the Internet, or your instance may be currently unavailable.'**
  String get internetOrInstanceIssues;

  /// Error message for invalid URL format
  ///
  /// In en, this message translates to:
  /// **'Invalid URL format'**
  String get invalidUrl;

  /// Describes the time when a user joined the site (or was created)
  ///
  /// In en, this message translates to:
  /// **'Joined {x}'**
  String joined(Object x);

  /// Description of keyword filter settings
  ///
  /// In en, this message translates to:
  /// **'Filters posts containing any keywords in the title, body, or URL'**
  String get keywordFilterDescription;

  /// Subcategory in Settings -> Filters
  ///
  /// In en, this message translates to:
  /// **'Keyword Filters'**
  String get keywordFilters;

  /// Text field label for a user label
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get label;

  /// Label when creating or editing a post.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageFilters.
  ///
  /// In en, this message translates to:
  /// **'Looking for language filters?'**
  String get languageFilters;

  /// The error message for the language_not_allowed Lemmy exception
  ///
  /// In en, this message translates to:
  /// **'The community you are posting to does not allow posts in the language that you have selected. Try another language.'**
  String get languageNotAllowed;

  /// Description for large font scale
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// Setting for left long swipe
  ///
  /// In en, this message translates to:
  /// **'Left Long Swipe'**
  String get leftLongSwipe;

  /// Setting for left short swipe
  ///
  /// In en, this message translates to:
  /// **'Left Short Swipe'**
  String get leftShortSwipe;

  /// Describes using the light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Describes a link
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Link} one {Link} other {Links} } '**
  String link(num count);

  /// No description provided for @linkActions.
  ///
  /// In en, this message translates to:
  /// **'Link Actions'**
  String get linkActions;

  /// Description for custom tabs link handling
  ///
  /// In en, this message translates to:
  /// **'Open in system browser embedded in-app'**
  String get linkHandlingCustomTabs;

  /// Short description for custom tabs link handling
  ///
  /// In en, this message translates to:
  /// **'In-app embedded'**
  String get linkHandlingCustomTabsShort;

  /// Description for external link handling
  ///
  /// In en, this message translates to:
  /// **'Open in system browser externally'**
  String get linkHandlingExternal;

  /// Short description for external link handling
  ///
  /// In en, this message translates to:
  /// **'External'**
  String get linkHandlingExternalShort;

  /// Description for in-app link handling
  ///
  /// In en, this message translates to:
  /// **'Use Thunder\'s built-in browser'**
  String get linkHandlingInApp;

  /// Short description for in-app link handling
  ///
  /// In en, this message translates to:
  /// **'In-app'**
  String get linkHandlingInAppShort;

  /// Subcategory in Setting -> General
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get linksBehaviourSettings;

  /// Load more replies
  ///
  /// In en, this message translates to:
  /// **'Load {count} more replies…'**
  String loadMorePlural(Object count);

  /// Load more replies
  ///
  /// In en, this message translates to:
  /// **'Load {count} more reply…'**
  String loadMoreSingular(Object count);

  /// Placeholder text for loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// Describes the notification type for Local Notifications
  ///
  /// In en, this message translates to:
  /// **'Local Notifications'**
  String get localNotifications;

  /// Local community visibility
  ///
  /// In en, this message translates to:
  /// **'Local Only'**
  String get localOnly;

  /// No description provided for @localPosts.
  ///
  /// In en, this message translates to:
  /// **'Local Posts'**
  String get localPosts;

  /// Action for locking a post (moderator action)
  ///
  /// In en, this message translates to:
  /// **'Lock Post'**
  String get lockPost;

  /// Status to indicate that an item has been locked
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// Short decription for moderator action to lock a post
  ///
  /// In en, this message translates to:
  /// **'Locked Post'**
  String get lockedPost;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// Message shown to user when they cancel a login attempt
  ///
  /// In en, this message translates to:
  /// **'Login attempt canceled.'**
  String get loginAttemptCanceled;

  /// Message shown to user when their login attempt failed
  ///
  /// In en, this message translates to:
  /// **'Could not log in. Please try again. (Error: {errorMessage})'**
  String loginFailed(Object errorMessage);

  /// No description provided for @loginSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Logged in.'**
  String get loginSucceeded;

  /// No description provided for @loginToPerformAction.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to carry out this task.'**
  String get loginToPerformAction;

  /// No description provided for @loginToSeeInbox.
  ///
  /// In en, this message translates to:
  /// **'Log in to see your inbox'**
  String get loginToSeeInbox;

  /// Helper setting which navigates to account page
  ///
  /// In en, this message translates to:
  /// **'Looking for account-specific feed settings?'**
  String get lookingForAccountSpecificFeedSettings;

  /// Error related to unsupported link format.
  ///
  /// In en, this message translates to:
  /// **'The link you provided is in an unsupported format. Please make sure it\'s a valid link.'**
  String get malformedUri;

  /// No description provided for @manageAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get manageAccounts;

  /// Setting name and page title for media management
  ///
  /// In en, this message translates to:
  /// **'Manage Media'**
  String get manageMedia;

  /// The mark all as read action
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// Label for the action to mark a message as read
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// Toggle to mark posts as read after viewing media.
  ///
  /// In en, this message translates to:
  /// **'Mark Read After Viewing Media'**
  String get markPostAsReadOnMediaView;

  /// Toggle to mark posts as read as you scroll past them in the feed.
  ///
  /// In en, this message translates to:
  /// **'Mark Read On Scroll'**
  String get markPostAsReadOnScroll;

  /// Name of mark read/unread color setting
  ///
  /// In en, this message translates to:
  /// **'Mark Read/Unread Color'**
  String get markReadColor;

  /// Label for Matrix user id
  ///
  /// In en, this message translates to:
  /// **'Matrix User'**
  String get matrixUser;

  /// Label for the current user.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// Description for medium font scale
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Describes a mention
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Mention} one {Mention} other {Mentions} }'**
  String mention(num count);

  /// Menu button description
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Describes a message
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Message} one {Message} other {Messages} }'**
  String message(num count);

  /// Setting for metadata font scale
  ///
  /// In en, this message translates to:
  /// **'Metadata Font Scale'**
  String get metadataFontScale;

  /// No description provided for @missingErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'No error message available'**
  String get missingErrorMessage;

  /// Description for modlog filter for actions that add instance moderators
  ///
  /// In en, this message translates to:
  /// **'Add/Remove Instance Moderators'**
  String get modAdd;

  /// Description for modlog filter for actions that add moderators to communities
  ///
  /// In en, this message translates to:
  /// **'Add/Remove Moderators to Communities'**
  String get modAddCommunity;

  /// Description for modlog filter for actions that ban instance users
  ///
  /// In en, this message translates to:
  /// **'Ban/Unban Instance Users'**
  String get modBan;

  /// Description for modlog filter for actions that ban users from communities
  ///
  /// In en, this message translates to:
  /// **'Ban/Unban Users from Communities'**
  String get modBanFromCommunity;

  /// Description for modlog filter for actions that feature posts
  ///
  /// In en, this message translates to:
  /// **'Feature/Unfeature Posts'**
  String get modFeaturePost;

  /// Description for modlog filter for actions that lock posts
  ///
  /// In en, this message translates to:
  /// **'Lock/Unlock Posts'**
  String get modLockPost;

  /// Description for modlog filter for actions that remove comments
  ///
  /// In en, this message translates to:
  /// **'Remove/Restore Comments'**
  String get modRemoveComment;

  /// Description for modlog filter for actions that remove communities
  ///
  /// In en, this message translates to:
  /// **'Remove/Restore Communities'**
  String get modRemoveCommunity;

  /// Description for modlog filter for actions that remove posts
  ///
  /// In en, this message translates to:
  /// **'Remove/Restore Posts'**
  String get modRemovePost;

  /// Description for modlog filter for actions that transfer moderators to another community
  ///
  /// In en, this message translates to:
  /// **'Transferring Communities'**
  String get modTransferCommunity;

  /// Describes a list of communities that are moderated by the current user.
  ///
  /// In en, this message translates to:
  /// **'Moderated Communities'**
  String get moderatedCommunities;

  /// A heading describing the communities that a user moderates
  ///
  /// In en, this message translates to:
  /// **'Moderates'**
  String get moderates;

  /// Role name for moderator
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Moderator} one {Moderator} other {Moderators}}'**
  String moderator(num count);

  /// Actions for moderators to perform on posts
  ///
  /// In en, this message translates to:
  /// **'Moderator Actions'**
  String get moderatorActions;

  /// Option for viewing modlog.
  ///
  /// In en, this message translates to:
  /// **'Modlog'**
  String get modlog;

  /// No description provided for @mostComments.
  ///
  /// In en, this message translates to:
  /// **'Most Comments'**
  String get mostComments;

  /// No description provided for @mustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in'**
  String get mustBeLoggedIn;

  /// No description provided for @mustBeLoggedInComment.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to comment'**
  String get mustBeLoggedInComment;

  /// No description provided for @mustBeLoggedInPost.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to create a post'**
  String get mustBeLoggedInPost;

  /// Heading for name-related settings
  ///
  /// In en, this message translates to:
  /// **'Names'**
  String get names;

  /// Setting for navbar double tap gestures
  ///
  /// In en, this message translates to:
  /// **'Navbar Double Tap Gestures'**
  String get navbarDoubleTapGestures;

  /// Setting for navbar swipe gestures
  ///
  /// In en, this message translates to:
  /// **'Navbar Swipe Gestures'**
  String get navbarSwipeGestures;

  /// No description provided for @navigateDown.
  ///
  /// In en, this message translates to:
  /// **'Next comment'**
  String get navigateDown;

  /// No description provided for @navigateUp.
  ///
  /// In en, this message translates to:
  /// **'Previous comment'**
  String get navigateUp;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// Setting for nested comment indicator color
  ///
  /// In en, this message translates to:
  /// **'Nested Comment Indicator Color'**
  String get nestedCommentIndicatorColor;

  /// Setting for nested comment indicator style
  ///
  /// In en, this message translates to:
  /// **'Nested Comment Indicator Style'**
  String get nestedCommentIndicatorStyle;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @newComments.
  ///
  /// In en, this message translates to:
  /// **'New Comments'**
  String get newComments;

  /// Setting for new post
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get newPost;

  /// No description provided for @new_.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get new_;

  /// A negative status
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Placeholder text when no accounts have been added
  ///
  /// In en, this message translates to:
  /// **'No accounts have been added'**
  String get noAccountsAdded;

  /// Placeholder text when no anonymous instances have been added
  ///
  /// In en, this message translates to:
  /// **'No anonymous instances have been added'**
  String get noAnonymousInstances;

  /// No description provided for @noCommentsFound.
  ///
  /// In en, this message translates to:
  /// **'No comments found'**
  String get noCommentsFound;

  /// No description provided for @noCommunitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No communities found'**
  String get noCommunitiesFound;

  /// No description provided for @noCommunityBlocks.
  ///
  /// In en, this message translates to:
  /// **'No blocked communities'**
  String get noCommunityBlocks;

  /// Tell the user we didn't find a compatible UnifiedPush app
  ///
  /// In en, this message translates to:
  /// **'No compatible app found'**
  String get noCompatibleAppFound;

  /// Message for no discussion languages added
  ///
  /// In en, this message translates to:
  /// **'No content is hidden based on language.'**
  String get noDiscussionLanguages;

  /// Message for no display name set
  ///
  /// In en, this message translates to:
  /// **'No display name set'**
  String get noDisplayNameSet;

  /// Message for no email set
  ///
  /// In en, this message translates to:
  /// **'No email set'**
  String get noEmailSet;

  /// Message for no favorited communities on the drawer
  ///
  /// In en, this message translates to:
  /// **'No favorited communities'**
  String get noFavoritedCommunities;

  /// Message for no uploaded images
  ///
  /// In en, this message translates to:
  /// **'It looks like you have not uploaded any images.'**
  String get noImages;

  /// No description provided for @noInstanceBlocks.
  ///
  /// In en, this message translates to:
  /// **'No blocked instances.'**
  String get noInstanceBlocks;

  /// Generic text when there are no items
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// Message for no keyword filters added
  ///
  /// In en, this message translates to:
  /// **'No keyword filters added'**
  String get noKeywordFilters;

  /// The entry for no language when selecting a post language
  ///
  /// In en, this message translates to:
  /// **'No language'**
  String get noLanguage;

  /// Message for no matrix user set
  ///
  /// In en, this message translates to:
  /// **'No matrix user set'**
  String get noMatrixUserSet;

  /// Label for when there are no person mentions in the list
  ///
  /// In en, this message translates to:
  /// **'No mentions'**
  String get noMentions;

  /// Label for when there are no messages in the inbox
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get noMessages;

  /// No description provided for @noPostsFound.
  ///
  /// In en, this message translates to:
  /// **'No posts found.'**
  String get noPostsFound;

  /// Message for no profile bio set
  ///
  /// In en, this message translates to:
  /// **'No profile bio set'**
  String get noProfileBioSet;

  /// Message indicating media was not found on Lemmy
  ///
  /// In en, this message translates to:
  /// **'No posts or comments were found containing this image. However, it may be used elsewhere on the internet.'**
  String get noReferencesToImage;

  /// Label for when there are no replies in the list
  ///
  /// In en, this message translates to:
  /// **'No replies'**
  String get noReplies;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// Message for no subscriptions on the drawer
  ///
  /// In en, this message translates to:
  /// **'No Subscriptions'**
  String get noSubscriptions;

  /// No description provided for @noUserBlocks.
  ///
  /// In en, this message translates to:
  /// **'No blocked users.'**
  String get noUserBlocks;

  /// Placeholder message for empty list of labels
  ///
  /// In en, this message translates to:
  /// **'You have not created any user labels yet'**
  String get noUserLabels;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;

  /// A message that shows up when a user navigates to a post but the associated community is blocked.
  ///
  /// In en, this message translates to:
  /// **'Comments may not be visible because the community is blocked.'**
  String get noVisibleComments;

  /// Describes the notification type when push notifications are disabled
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Normal name thickness/weight
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// Message for when an instance is not a valid Lemmy/PieFed instance
  ///
  /// In en, this message translates to:
  /// **'{instance} does not appear to be a valid instance'**
  String notValidLemmyInstance(Object instance);

  /// No description provided for @notValidUrl.
  ///
  /// In en, this message translates to:
  /// **'Not a valid URL'**
  String get notValidUrl;

  /// No description provided for @nothingToShare.
  ///
  /// In en, this message translates to:
  /// **'Nothing to share'**
  String get nothingToShare;

  /// Message formatting for notifications count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Notification} one {Notifications} other {Notifications}}'**
  String notifications(num count);

  /// Subcategory in Setting -> General
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsBehaviourSettings;

  /// Description for when notifications are now allowed for app
  ///
  /// In en, this message translates to:
  /// **'Notifications are not allowed for Thunder in system settings'**
  String get notificationsNotAllowed;

  /// The content of the warning dialog for the notifications feature
  ///
  /// In en, this message translates to:
  /// **'Notifications are an **experimental feature** which may not function correctly on all devices.\n\n - Checks will occur every ~15 minutes and will consume additional battery.\n\n - Disable battery optimizations for a higher likelihood of successful notifications.\n\n See the following page for more information.'**
  String get notificationsWarningDialog;

  /// Short description for NSFW label
  ///
  /// In en, this message translates to:
  /// **'NSFW'**
  String get nsfw;

  /// Warning for NSFW posts
  ///
  /// In en, this message translates to:
  /// **'NSFW - Tap to reveal'**
  String get nsfwWarning;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get off;

  /// Describes a service that is unavailable
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get offline;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @old.
  ///
  /// In en, this message translates to:
  /// **'Old'**
  String get old;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @onWifi.
  ///
  /// In en, this message translates to:
  /// **'On Wifi'**
  String get onWifi;

  /// No description provided for @onlyModsCanPostInCommunity.
  ///
  /// In en, this message translates to:
  /// **'Only moderators may post in this community'**
  String get onlyModsCanPostInCommunity;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @openAccountSwitcher.
  ///
  /// In en, this message translates to:
  /// **'Open account switcher'**
  String get openAccountSwitcher;

  /// Indicating the default behavior of opening links.
  ///
  /// In en, this message translates to:
  /// **'Open by default'**
  String get openByDefault;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get openInBrowser;

  /// No description provided for @openInstance.
  ///
  /// In en, this message translates to:
  /// **'Open Instance'**
  String get openInstance;

  /// Toggle to open links in an external browser.
  ///
  /// In en, this message translates to:
  /// **'Open Links in External Browser'**
  String get openLinksInExternalBrowser;

  /// Toggle to open links in reader mode when available.
  ///
  /// In en, this message translates to:
  /// **'Open Links in Reader Mode'**
  String get openLinksInReaderMode;

  /// Prompt for the user to open system settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// The color orange
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orange;

  /// Label for the original poster.
  ///
  /// In en, this message translates to:
  /// **'Original Poster'**
  String get originalPoster;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Describes the subscription status for 'Pending'
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Describes the user who performed an action (e.g., moderator)
  ///
  /// In en, this message translates to:
  /// **'Performed by: {user}'**
  String performedBy(Object user);

  /// Title for error when user denies OS permissions
  ///
  /// In en, this message translates to:
  /// **'Thunder has not been granted permission to display notifications. Please enable in system settings.'**
  String get permissionDenied;

  /// Explanation for error when user denies OS permissions
  ///
  /// In en, this message translates to:
  /// **'Thunder requires some permissions in order to save this image which have been denied.'**
  String get permissionDeniedMessage;

  /// Action for pinning a post to a community (moderator action)
  ///
  /// In en, this message translates to:
  /// **'Pin Post to Community'**
  String get pinPostToCommunity;

  /// Setting for pinning a post to a community (moderator action)
  ///
  /// In en, this message translates to:
  /// **'Pin to Community'**
  String get pinToCommunity;

  /// Status to indicate that an item has been pinned
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// Message shown when a post is pinned to a community
  ///
  /// In en, this message translates to:
  /// **'Pinned post to community'**
  String get pinnedPostToCommunity;

  /// Placeholder text for any previews. This comes from https://www.lipsum.com/
  ///
  /// In en, this message translates to:
  /// **'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'**
  String get placeholderText;

  /// Describes a single post
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// Describes a given set of actions that can be performed on a post
  ///
  /// In en, this message translates to:
  /// **'Post Actions'**
  String get postActions;

  /// Subcategory in Setting -> General
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get postBehaviourSettings;

  /// No description provided for @postBody.
  ///
  /// In en, this message translates to:
  /// **'Post Body'**
  String get postBody;

  /// Settings heading for post body settings
  ///
  /// In en, this message translates to:
  /// **'Post Body Settings'**
  String get postBodySettings;

  /// Description of post body settings
  ///
  /// In en, this message translates to:
  /// **'These settings affect the display of the post body'**
  String get postBodySettingsDescription;

  /// Whether to show the community instance for post bodies
  ///
  /// In en, this message translates to:
  /// **'Show Community Instance'**
  String get postBodyShowCommunityInstance;

  /// Whether to show the user instance for post bodies
  ///
  /// In en, this message translates to:
  /// **'Show User Instance'**
  String get postBodyShowUserInstance;

  /// Setting name for the post body view type setting
  ///
  /// In en, this message translates to:
  /// **'Post Body View Type'**
  String get postBodyViewType;

  /// Setting for post content font scale
  ///
  /// In en, this message translates to:
  /// **'Post Content Font Scale'**
  String get postContentFontScale;

  /// Notifying the user that their post was created successfully
  ///
  /// In en, this message translates to:
  /// **'Post created successfully!'**
  String get postCreatedSuccessfully;

  /// No description provided for @postLocked.
  ///
  /// In en, this message translates to:
  /// **'Post locked. No replies allowed.'**
  String get postLocked;

  /// Instructions on how to customize the post metadata information. This is found in the Appearance -> Post settings page
  ///
  /// In en, this message translates to:
  /// **'You can customize the metadata information by dragging and dropping the desired information'**
  String get postMetadataInstructions;

  /// No description provided for @postNSFW.
  ///
  /// In en, this message translates to:
  /// **'Mark as NSFW'**
  String get postNSFW;

  /// Description for the post preview in Setting -> Appearance -> Posts
  ///
  /// In en, this message translates to:
  /// **'Show a preview of the post with the given settings'**
  String get postPreview;

  /// No description provided for @postSavedAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Post saved as draft'**
  String get postSavedAsDraft;

  /// Whether to show the user instance for post listings
  ///
  /// In en, this message translates to:
  /// **'Show User Instance'**
  String get postShowUserInstance;

  /// Setting for post swipe actions
  ///
  /// In en, this message translates to:
  /// **'Post Swipe Actions'**
  String get postSwipeActions;

  /// No description provided for @postSwipeGesturesHint.
  ///
  /// In en, this message translates to:
  /// **'Looking to use buttons instead? Change what buttons appear on post cards in general settings.'**
  String get postSwipeGesturesHint;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get postTitle;

  /// Setting for post title font scale
  ///
  /// In en, this message translates to:
  /// **'Post Title Font Scale'**
  String get postTitleFontScale;

  /// No description provided for @postTogglePreview.
  ///
  /// In en, this message translates to:
  /// **'Toggle Preview'**
  String get postTogglePreview;

  /// No description provided for @postURL.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get postURL;

  /// No description provided for @postUploadImageError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload image'**
  String get postUploadImageError;

  /// Label for the post view type (compact/card) in Setting -> Appearance -> Posts
  ///
  /// In en, this message translates to:
  /// **'Post View Type'**
  String get postViewType;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Message shown to user when a profile is applied successfully
  ///
  /// In en, this message translates to:
  /// **'{profile} applied successfully!'**
  String profileAppliedSuccessfully(Object profile);

  /// Setting for profile bio
  ///
  /// In en, this message translates to:
  /// **'Profile Bio'**
  String get profileBio;

  /// No description provided for @profiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get profiles;

  /// Public community visibility
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// Describes using the pure black theme
  ///
  /// In en, this message translates to:
  /// **'Pure Black'**
  String get pureBlack;

  /// Short decription for moderator action to purge a comment
  ///
  /// In en, this message translates to:
  /// **'Purged Comment'**
  String get purgedComment;

  /// Short decription for moderator action to purge a community
  ///
  /// In en, this message translates to:
  /// **'Purged Community'**
  String get purgedCommunity;

  /// Short decription for moderator action to purge a person
  ///
  /// In en, this message translates to:
  /// **'Purged Person'**
  String get purgedPerson;

  /// Short decription for moderator action to purge a post
  ///
  /// In en, this message translates to:
  /// **'Purged Post'**
  String get purgedPost;

  /// The color purple
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// Setting for push notifications
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotification;

  /// Description of push notification setting
  ///
  /// In en, this message translates to:
  /// **'If enabled, Thunder will send your JWT token(s) to the server in order to poll for new notifications. \n\n **NOTE:** This will not take effect until the next time the app is launched.'**
  String get pushNotificationDescription;

  /// Setting for choosing push notification server
  ///
  /// In en, this message translates to:
  /// **'Push Notification Server'**
  String get pushNotificationServer;

  /// Description of choosing push notification server setting
  ///
  /// In en, this message translates to:
  /// **'Configure the push notification server. The server must be properly configured to send push notifications to your device.\n\n **Only enter a server that you trust with your credentials.**'**
  String get pushNotificationServerDescription;

  /// Error message for the rate-limit Lemmy exception
  ///
  /// In en, this message translates to:
  /// **'You have hit the rate limit for this request. Please wait and try again later.'**
  String get rateLimitErrorMessage;

  /// No description provided for @reachedTheBottom.
  ///
  /// In en, this message translates to:
  /// **'No more items to load'**
  String get reachedTheBottom;

  /// Indicates that a post has been read
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @readAll.
  ///
  /// In en, this message translates to:
  /// **'Read All'**
  String get readAll;

  /// Menu item for toggling reader mode
  ///
  /// In en, this message translates to:
  /// **'Reader mode'**
  String get readerMode;

  /// The reason for the moderation action (e.g., removing post)
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// The color red
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// Toggle to reduce animations.
  ///
  /// In en, this message translates to:
  /// **'Reduce Animations'**
  String get reduceAnimations;

  /// No description provided for @reducesAnimations.
  ///
  /// In en, this message translates to:
  /// **'Reduces the animations used within Thunder'**
  String get reducesAnimations;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @refreshContent.
  ///
  /// In en, this message translates to:
  /// **'Refresh Content'**
  String get refreshContent;

  /// Title for the dialog for removing a post
  ///
  /// In en, this message translates to:
  /// **'Removal Reason'**
  String get removalReason;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeAccount.
  ///
  /// In en, this message translates to:
  /// **'Remove Account'**
  String get removeAccount;

  /// Moderator action to remove user as community moderator
  ///
  /// In en, this message translates to:
  /// **'Remove as Community Moderator'**
  String get removeAsCommunityModerator;

  /// Moderator action to remove a comment
  ///
  /// In en, this message translates to:
  /// **'Remove Comment'**
  String get removeComment;

  /// Action to remove a community in drawer from favorites
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @removeInstance.
  ///
  /// In en, this message translates to:
  /// **'Remove instance'**
  String get removeInstance;

  /// Description of removing a keyword filter
  ///
  /// In en, this message translates to:
  /// **'Remove \"{keyword}\"?'**
  String removeKeyword(Object keyword);

  /// Title for dialog to remove keyword filter
  ///
  /// In en, this message translates to:
  /// **'Remove Keyword'**
  String get removeKeywordFilter;

  /// Action to remove a post (moderator action)
  ///
  /// In en, this message translates to:
  /// **'Remove Post'**
  String get removePost;

  /// Description for removing user data when banning user
  ///
  /// In en, this message translates to:
  /// **'Remove user data'**
  String get removeUserData;

  /// Status to indicate that an item has been removed
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get removed;

  /// Short decription for moderator action to remove a comment
  ///
  /// In en, this message translates to:
  /// **'Removed Comment'**
  String get removedComment;

  /// Short decription for moderator action to remove a community
  ///
  /// In en, this message translates to:
  /// **'Removed Community'**
  String get removedCommunity;

  /// No description provided for @removedCommunityFromSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribed from community'**
  String get removedCommunityFromSubscriptions;

  /// Short decription for moderator action to remove a mod from an instance
  ///
  /// In en, this message translates to:
  /// **'Removed Instance Mod'**
  String get removedInstanceMod;

  /// Short decription for moderator action to remove a mod from a community
  ///
  /// In en, this message translates to:
  /// **'Removed Mod from Community'**
  String get removedModFromCommunity;

  /// Short decription for moderator action to remove a post
  ///
  /// In en, this message translates to:
  /// **'Removed Post'**
  String get removedPost;

  /// Short decription for moderator action to remove a user as community moderator
  ///
  /// In en, this message translates to:
  /// **'Removed {username} as community moderator'**
  String removedUserAsCommunityModerator(Object username);

  /// Tooltip text for the list editor button
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// Message formatting for reply count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Reply} one {Reply} other {Replies} }'**
  String reply(num count);

  /// Name of reply color setting
  ///
  /// In en, this message translates to:
  /// **'Reply Color'**
  String get replyColor;

  /// No description provided for @replyNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Replying from this view is currently not supported yet'**
  String get replyNotSupported;

  /// No description provided for @replyToPost.
  ///
  /// In en, this message translates to:
  /// **'Reply to Post'**
  String get replyToPost;

  /// Describes the author of the post that is being replied to
  ///
  /// In en, this message translates to:
  /// **'Replying to {author}'**
  String replyingTo(Object author);

  /// Message formatting for report count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Report} one {Report} other {Reports} } '**
  String report(num count);

  /// No description provided for @reportComment.
  ///
  /// In en, this message translates to:
  /// **'Report Comment'**
  String get reportComment;

  /// Action to report a post (moderator action)
  ///
  /// In en, this message translates to:
  /// **'Report Post'**
  String get reportPost;

  /// Message shown when a comment is reported
  ///
  /// In en, this message translates to:
  /// **'Reported comment'**
  String get reportedComment;

  /// Message shown when a post is reported
  ///
  /// In en, this message translates to:
  /// **'Reported post'**
  String get reportedPost;

  /// Name of reporter that reported a post/comment
  ///
  /// In en, this message translates to:
  /// **'Reporter:'**
  String get reporter;

  /// Helper text for a required form field
  ///
  /// In en, this message translates to:
  /// **'*required'**
  String get requiredField;

  /// Label for the reset button in Setting -> Appearance -> Posts/Comments
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Semantic label for button in comment appearance settings.
  ///
  /// In en, this message translates to:
  /// **'Reset comment preferences'**
  String get resetCommentPreferences;

  /// Semantic label for button in post appearance settings.
  ///
  /// In en, this message translates to:
  /// **'Reset post preferences'**
  String get resetPostPreferences;

  /// No description provided for @resetPreferences.
  ///
  /// In en, this message translates to:
  /// **'Reset Preferences'**
  String get resetPreferences;

  /// Debug setting header for resetting all user preferences and data.
  ///
  /// In en, this message translates to:
  /// **'Reset Preferences and Data'**
  String get resetPreferencesAndData;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Moderator action to restore a comment
  ///
  /// In en, this message translates to:
  /// **'Restore Comment'**
  String get restoreComment;

  /// Action to restore a post (moderator action)
  ///
  /// In en, this message translates to:
  /// **'Restore Post'**
  String get restorePost;

  /// Short decription for moderator action to restore a comment
  ///
  /// In en, this message translates to:
  /// **'Restored comment'**
  String get restoredComment;

  /// No description provided for @restoredCommentFromDraft.
  ///
  /// In en, this message translates to:
  /// **'Restored comment from draft'**
  String get restoredCommentFromDraft;

  /// Short decription for moderator action to restore a community
  ///
  /// In en, this message translates to:
  /// **'Restored Community'**
  String get restoredCommunity;

  /// Short decription for moderator action to restore a post
  ///
  /// In en, this message translates to:
  /// **'Restored Post'**
  String get restoredPost;

  /// No description provided for @restoredPostFromDraft.
  ///
  /// In en, this message translates to:
  /// **'Restored post from draft'**
  String get restoredPostFromDraft;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Setting for right long swipe
  ///
  /// In en, this message translates to:
  /// **'Right Long Swipe'**
  String get rightLongSwipe;

  /// Setting for right short swipe
  ///
  /// In en, this message translates to:
  /// **'Right Short Swipe'**
  String get rightShortSwipe;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Name of save color setting
  ///
  /// In en, this message translates to:
  /// **'Save Color'**
  String get saveColor;

  /// Action to save the application settings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @scaled.
  ///
  /// In en, this message translates to:
  /// **'Scaled'**
  String get scaled;

  /// Toggle to scrape missing external link previews.
  ///
  /// In en, this message translates to:
  /// **'Scrape Missing Link Previews'**
  String get scrapeMissingLinkPreviews;

  /// No description provided for @screenReaderProfile.
  ///
  /// In en, this message translates to:
  /// **'Screen Reader Profile'**
  String get screenReaderProfile;

  /// No description provided for @screenReaderProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Optimizes Thunder for screen readers by reducing overall elements and removing potentially conflicting gestures.'**
  String get screenReaderProfileDescription;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchByText.
  ///
  /// In en, this message translates to:
  /// **'Search by text'**
  String get searchByText;

  /// No description provided for @searchByUrl.
  ///
  /// In en, this message translates to:
  /// **'Search by URL'**
  String get searchByUrl;

  /// No description provided for @searchComments.
  ///
  /// In en, this message translates to:
  /// **'Search Comments'**
  String get searchComments;

  /// Placeholder text for searching for comments
  ///
  /// In en, this message translates to:
  /// **'Search for comments federated with {instance}'**
  String searchCommentsFederatedWith(Object instance);

  /// Placeholder text for searching for communities
  ///
  /// In en, this message translates to:
  /// **'Search for communities federated with {instance}'**
  String searchCommunitiesFederatedWith(Object instance);

  /// Placeholder text for searching for an instance
  ///
  /// In en, this message translates to:
  /// **'Search {instance}'**
  String searchInstance(Object instance);

  /// Placeholder text for searching for instances
  ///
  /// In en, this message translates to:
  /// **'Search for instances federated with {instance}'**
  String searchInstancesFederatedWith(Object instance);

  /// No description provided for @searchPostSearchType.
  ///
  /// In en, this message translates to:
  /// **'Select Post Search Type'**
  String get searchPostSearchType;

  /// Placeholder text for searching for posts
  ///
  /// In en, this message translates to:
  /// **'Search for posts federated with {instance}'**
  String searchPostsFederatedWith(Object instance);

  /// No description provided for @searchTerm.
  ///
  /// In en, this message translates to:
  /// **'Search term'**
  String get searchTerm;

  /// Placeholder text for searching for users
  ///
  /// In en, this message translates to:
  /// **'Search for users federated with {instance}'**
  String searchUsersFederatedWith(Object instance);

  /// Profile modal heading for commenting as other user
  ///
  /// In en, this message translates to:
  /// **'Select account to comment as'**
  String get selectAccountToCommentAs;

  /// Heading for account selector when posting
  ///
  /// In en, this message translates to:
  /// **'Select account to post as'**
  String get selectAccountToPostAs;

  /// Action for selecting all text
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @selectCommunity.
  ///
  /// In en, this message translates to:
  /// **'Select a community (required)'**
  String get selectCommunity;

  /// No description provided for @selectFeedType.
  ///
  /// In en, this message translates to:
  /// **'Select Feed Type'**
  String get selectFeedType;

  /// The prompt to select a language in the post creation page
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectSearchType.
  ///
  /// In en, this message translates to:
  /// **'Select Search Type'**
  String get selectSearchType;

  /// Post and comment action for selecting text
  ///
  /// In en, this message translates to:
  /// **'Select Text'**
  String get selectText;

  /// The option to send a background notification for testing
  ///
  /// In en, this message translates to:
  /// **'Send background test local notification'**
  String get sendBackgroundTestLocalNotification;

  /// The option to send a background UnifiedPUsh notification for testing
  ///
  /// In en, this message translates to:
  /// **'Send background test UnifiedPush notification'**
  String get sendBackgroundTestUnifiedPushNotification;

  /// The option to send a notification for testing
  ///
  /// In en, this message translates to:
  /// **'Send test local notification'**
  String get sendTestLocalNotification;

  /// The option to send a UnifiedPush notification for testing
  ///
  /// In en, this message translates to:
  /// **'Send test UnifiedPush notification'**
  String get sendTestUnifiedPushNotification;

  /// Warning for sensitive content (e.g., from modlog)
  ///
  /// In en, this message translates to:
  /// **'May contain sensitive content. Tap to reveal.'**
  String get sensitiveContentWarning;

  /// No description provided for @sentRequestForTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Sent request for test notification.'**
  String get sentRequestForTestNotification;

  /// Error message for when we fail to fetch more comments
  ///
  /// In en, this message translates to:
  /// **'A server error was encountered when fetching more comments: {message}'**
  String serverErrorComments(Object message);

  /// Label for the action to set (short-press, long-press)
  ///
  /// In en, this message translates to:
  /// **'Set Action'**
  String get setAction;

  /// No description provided for @setLongPress.
  ///
  /// In en, this message translates to:
  /// **'Set as long-press action'**
  String get setLongPress;

  /// No description provided for @setShortPress.
  ///
  /// In en, this message translates to:
  /// **'Set as short-press action'**
  String get setShortPress;

  /// Message which indicates that the (instance) settings override the app settings
  ///
  /// In en, this message translates to:
  /// **'These settings override Thunder\'s default settings.'**
  String get settingOverrideLabel;

  /// Error message for when a setting type is not supported
  ///
  /// In en, this message translates to:
  /// **'Settings of type {settingType} are not yet supported.'**
  String settingTypeNotSupported(Object settingType);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Message shown to the user when the settings were exported successfully
  ///
  /// In en, this message translates to:
  /// **'Settings were successfully saved to \'{savedFilePath}\''**
  String settingsExportedSuccessfully(Object savedFilePath);

  /// Settings for controlling the display of cards in the main feed.
  ///
  /// In en, this message translates to:
  /// **'These settings apply to the cards in the main feed, actions are always available when actually opening posts.'**
  String get settingsFeedCards;

  /// Message shown to the user when the settings were imported successfully
  ///
  /// In en, this message translates to:
  /// **'Settings were imported successfully!'**
  String get settingsImportedSuccessfully;

  /// Message shown to the user when the settings were exported unsuccessfully
  ///
  /// In en, this message translates to:
  /// **'Settings were not saved successfully, or the operation was canceled.'**
  String get settingsNotExportedSuccessfully;

  /// Message shown to the user when the settings were imported unsuccessfully
  ///
  /// In en, this message translates to:
  /// **'Settings were not imported successfully or the operation was canceled.'**
  String get settingsNotImportedSuccessfully;

  /// Settings page subtitle for search results
  ///
  /// In en, this message translates to:
  /// **'Settings Page'**
  String get settingsPage;

  /// About settings page
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsPageAbout;

  /// Accessibility settings page
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsPageAccessibility;

  /// Account settings page
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsPageAccount;

  /// Account blocklist (user/community/instance) page
  ///
  /// In en, this message translates to:
  /// **'Blocklists'**
  String get settingsPageAccountBlocks;

  /// Account discussion languages page
  ///
  /// In en, this message translates to:
  /// **'Discussion Languages'**
  String get settingsPageAccountLanguages;

  /// Account manage media page
  ///
  /// In en, this message translates to:
  /// **'Manage Media'**
  String get settingsPageAccountMedia;

  /// Appearance settings page
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsPageAppearance;

  /// Theming comments page
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get settingsPageAppearanceComments;

  /// Theming posts page
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get settingsPageAppearancePosts;

  /// Theming settings page
  ///
  /// In en, this message translates to:
  /// **'Theming'**
  String get settingsPageAppearanceTheming;

  /// Debug settings page
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get settingsPageDebug;

  /// Filters settings page
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get settingsPageFilters;

  /// Floating action button settings page
  ///
  /// In en, this message translates to:
  /// **'Floating Action Button'**
  String get settingsPageFloatingActionButton;

  /// General settings page
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsPageGeneral;

  /// Gestures settings page
  ///
  /// In en, this message translates to:
  /// **'Gestures'**
  String get settingsPageGestures;

  /// User labels settings page
  ///
  /// In en, this message translates to:
  /// **'User Labels'**
  String get settingsPageUserLabels;

  /// Video settings page
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get settingsPageVideo;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Menu item for sharing a comment
  ///
  /// In en, this message translates to:
  /// **'Share Comment Link'**
  String get shareComment;

  /// Menu item for sharing a local link to comment
  ///
  /// In en, this message translates to:
  /// **'Share Comment Link (My Instance)'**
  String get shareCommentLocal;

  /// Heading for sharing a community
  ///
  /// In en, this message translates to:
  /// **'Share Community'**
  String get shareCommunity;

  /// Menu item for sharing a community
  ///
  /// In en, this message translates to:
  /// **'Share Community Link'**
  String get shareCommunityLink;

  /// Menu item for sharing a local community link
  ///
  /// In en, this message translates to:
  /// **'Share Community Link (My Instance)'**
  String get shareCommunityLinkLocal;

  /// Action for sharing an image
  ///
  /// In en, this message translates to:
  /// **'Share Image'**
  String get shareImage;

  /// Menu item for sharing a Lemmy link
  ///
  /// In en, this message translates to:
  /// **'Share Lemmy Link'**
  String get shareLemmyLink;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share External Link'**
  String get shareLink;

  /// No description provided for @shareMedia.
  ///
  /// In en, this message translates to:
  /// **'Share Media'**
  String get shareMedia;

  /// Action for sharing the link to the media associated with a post
  ///
  /// In en, this message translates to:
  /// **'Share Media Link'**
  String get shareMediaLink;

  /// Action for sharing the original link associated with a post
  ///
  /// In en, this message translates to:
  /// **'Share Original Link'**
  String get shareOriginalLink;

  /// No description provided for @sharePost.
  ///
  /// In en, this message translates to:
  /// **'Share Post Link'**
  String get sharePost;

  /// Item for sharing a link to a post on my instance
  ///
  /// In en, this message translates to:
  /// **'Share Post Link (My Instance)'**
  String get sharePostLocal;

  /// Action for sharing the thumbnail of a post
  ///
  /// In en, this message translates to:
  /// **'Share Thumbnail'**
  String get shareThumbnail;

  /// Action for sharing the thumbnail of a post as an image
  ///
  /// In en, this message translates to:
  /// **'Share Thumbnail As Image'**
  String get shareThumbnailAsImage;

  /// Heading for sharing a user
  ///
  /// In en, this message translates to:
  /// **'Share User'**
  String get shareUser;

  /// Menu item for sharing a user
  ///
  /// In en, this message translates to:
  /// **'Share User Link'**
  String get shareUserLink;

  /// Menu item for sharing a local user link
  ///
  /// In en, this message translates to:
  /// **'Share User Link (My Instance)'**
  String get shareUserLinkLocal;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// Option to show bot accounts.
  ///
  /// In en, this message translates to:
  /// **'Show Bot Accounts'**
  String get showBotAccounts;

  /// Toggle to show comment action buttons.
  ///
  /// In en, this message translates to:
  /// **'Show Comment Action Buttons'**
  String get showCommentActionButtons;

  /// Setting for showing community display names
  ///
  /// In en, this message translates to:
  /// **'Show Community Display Names'**
  String get showCommunityDisplayNames;

  /// Toggle to show cross posts.
  ///
  /// In en, this message translates to:
  /// **'Show Cross Posts'**
  String get showCrossPosts;

  /// Toggle to view edge to edge images.
  ///
  /// In en, this message translates to:
  /// **'Show Edge to Edge Images'**
  String get showEdgeToEdgeImages;

  /// Toggle that shows the full expanded tagline in the feed page
  ///
  /// In en, this message translates to:
  /// **'Show expanded taglines'**
  String get showExpandedTaglines;

  /// Toggle to show full date on posts
  ///
  /// In en, this message translates to:
  /// **'Show Full Date'**
  String get showFullDate;

  /// Description to show full date on posts
  ///
  /// In en, this message translates to:
  /// **'Show full date on posts'**
  String get showFullDateDescription;

  /// Toggle to view full height images.
  ///
  /// In en, this message translates to:
  /// **'Show Full Height Images'**
  String get showFullHeightImages;

  /// The name of the setting for showing hidden posts
  ///
  /// In en, this message translates to:
  /// **'Show Hidden Posts'**
  String get showHiddenPosts;

  /// Toggle to get notified of new GitHub releases.
  ///
  /// In en, this message translates to:
  /// **'Get Notified of new GitHub Releases'**
  String get showInAppUpdateNotifications;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// Setting for showing navigation labels
  ///
  /// In en, this message translates to:
  /// **'Show Navigation Labels'**
  String get showNavigationLabels;

  /// Description for setting for showing navigation labels
  ///
  /// In en, this message translates to:
  /// **'Whether to display labels beneath the bottom navigation buttons'**
  String get showNavigationLabelsDescription;

  /// Toggle to show NSFW content.
  ///
  /// In en, this message translates to:
  /// **'Show NSFW Content'**
  String get showNsfwContent;

  /// Toggle to show your own posts/comments.
  ///
  /// In en, this message translates to:
  /// **'Show own content'**
  String get showOwnContent;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show Password'**
  String get showPassword;

  /// Toggle to show post author.
  ///
  /// In en, this message translates to:
  /// **'Show Post Author'**
  String get showPostAuthor;

  /// Subtitle for the Show Post Author setting
  ///
  /// In en, this message translates to:
  /// **'Post author is always shown in community feeds'**
  String get showPostAuthorSubtitle;

  /// Toggle to show community icons.
  ///
  /// In en, this message translates to:
  /// **'Show Community Icons'**
  String get showPostCommunityIcons;

  /// Toggle to show save button.
  ///
  /// In en, this message translates to:
  /// **'Show Save Button'**
  String get showPostSaveAction;

  /// Toggle to show text previews.
  ///
  /// In en, this message translates to:
  /// **'Show Text Preview'**
  String get showPostTextContentPreview;

  /// Toggle to show post title first.
  ///
  /// In en, this message translates to:
  /// **'Show Title First'**
  String get showPostTitleFirst;

  /// Toggle to show vote buttons.
  ///
  /// In en, this message translates to:
  /// **'Show Vote Buttons'**
  String get showPostVoteActions;

  /// Setting to show read posts in feed.
  ///
  /// In en, this message translates to:
  /// **'Show Read Posts'**
  String get showReadPosts;

  /// Toggle to show saved posts/comments.
  ///
  /// In en, this message translates to:
  /// **'Show saved content'**
  String get showSavedContent;

  /// Toggle to display user scores.
  ///
  /// In en, this message translates to:
  /// **'Display User Scores'**
  String get showScoreCounters;

  /// Option to show scores on posts and comments.
  ///
  /// In en, this message translates to:
  /// **'Show Post/Comment Scores'**
  String get showScores;

  /// Toggle to show text post indicator.
  ///
  /// In en, this message translates to:
  /// **'Show Text Post Indicator'**
  String get showTextPostIndicator;

  /// Toggle to show thumbnails on the right side.
  ///
  /// In en, this message translates to:
  /// **'Show Thumbnails on the Right'**
  String get showThumbnailPreviewOnRight;

  /// Show unread replies/mentions/messages only
  ///
  /// In en, this message translates to:
  /// **'Show unread only'**
  String get showUnreadOnly;

  /// Setting for showing changelogs after updates
  ///
  /// In en, this message translates to:
  /// **'Show Update Changelogs'**
  String get showUpdateChangelogs;

  /// Subtitle for setting for showing changelogs after updates
  ///
  /// In en, this message translates to:
  /// **'Display a list of changes after an update'**
  String get showUpdateChangelogsSubtitle;

  /// Toggle to show user avatar.
  ///
  /// In en, this message translates to:
  /// **'Show User Avatar'**
  String get showUserAvatar;

  /// Toggle to show user display names.
  ///
  /// In en, this message translates to:
  /// **'Show User Display Names'**
  String get showUserDisplayNames;

  /// Toggle to show user instance.
  ///
  /// In en, this message translates to:
  /// **'Show User Instance'**
  String get showUserInstance;

  /// No description provided for @sidebar.
  ///
  /// In en, this message translates to:
  /// **'Sidebar'**
  String get sidebar;

  /// No description provided for @sidebarBottomNavDoubleTapDescription.
  ///
  /// In en, this message translates to:
  /// **'Double-tap bottom nav to open sidebar'**
  String get sidebarBottomNavDoubleTapDescription;

  /// No description provided for @sidebarBottomNavSwipeDescription.
  ///
  /// In en, this message translates to:
  /// **'Swipe bottom nav to open sidebar'**
  String get sidebarBottomNavSwipeDescription;

  /// Description for small font scale
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Oops, something went wrong!'**
  String get somethingWentWrong;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @sortByTop.
  ///
  /// In en, this message translates to:
  /// **'Sort by Top'**
  String get sortByTop;

  /// No description provided for @sortOptions.
  ///
  /// In en, this message translates to:
  /// **'Sort Options'**
  String get sortOptions;

  /// Placeholder label for spoiler
  ///
  /// In en, this message translates to:
  /// **'Spoiler'**
  String get spoiler;

  /// Describes a standard visual density
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// Community statistics
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// Status of the action
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// Action for subscribing to a community
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Community'**
  String get subscribeToCommunity;

  /// No description provided for @subscribed.
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscribed;

  /// Message for subscription request sent
  ///
  /// In en, this message translates to:
  /// **'Subscription request sent'**
  String get subscriptionRequestSent;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// Notification for successfully banning a user
  ///
  /// In en, this message translates to:
  /// **'Banned {username}'**
  String successfullyBannedUser(Object username);

  /// No description provided for @successfullyBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked.'**
  String get successfullyBlocked;

  /// Notification for successfully blocking a community
  ///
  /// In en, this message translates to:
  /// **'Blocked {communityName}'**
  String successfullyBlockedCommunity(Object communityName);

  /// Notification for successfully blocking a user
  ///
  /// In en, this message translates to:
  /// **'Blocked {username}'**
  String successfullyBlockedUser(Object username);

  /// Notification for successfully unbanning a user
  ///
  /// In en, this message translates to:
  /// **'Unbanned {username}'**
  String successfullyUnbannedUser(Object username);

  /// No description provided for @successfullyUnblocked.
  ///
  /// In en, this message translates to:
  /// **'Unblocked.'**
  String get successfullyUnblocked;

  /// Notification for successfully unblocking a community
  ///
  /// In en, this message translates to:
  /// **'Unblocked {communityName}'**
  String successfullyUnblockedCommunity(Object communityName);

  /// Notification for successfully unblocking a user
  ///
  /// In en, this message translates to:
  /// **'Unblocked {username}'**
  String successfullyUnblockedUser(Object username);

  /// This is a connecting phrase and could be translated into anything equivalent of 'like', 'e.g.,', 'for example', etc.
  ///
  /// In en, this message translates to:
  /// **'such as'**
  String get suchAs;

  /// Suggested title for the post.
  ///
  /// In en, this message translates to:
  /// **'Suggested title'**
  String get suggestedTitle;

  /// Message shown to the user when Thunder automatically switches accounts
  ///
  /// In en, this message translates to:
  /// **'Switched to {username}'**
  String switchedAccount(Object username);

  /// Describes using the system settings for theme
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Setting which toggles the pure black theme type when the theme is dark
  ///
  /// In en, this message translates to:
  /// **'Pure Black'**
  String get systemDarkMode;

  /// Toggle which enables the pure black theme when dark mode is selected
  ///
  /// In en, this message translates to:
  /// **'Enable pure black theme for dark mode'**
  String get systemDarkModeDescription;

  /// Toggle to enable 2-column tablet mode.
  ///
  /// In en, this message translates to:
  /// **'Tablet Mode (2-column view)'**
  String get tabletMode;

  /// No description provided for @tapToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get tapToExit;

  /// Toggle to make authors and communities tappable.
  ///
  /// In en, this message translates to:
  /// **'Tappable Authors & Communities'**
  String get tappableAuthorCommunity;

  /// The color teal
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get teal;

  /// A message describing the background test notification
  ///
  /// In en, this message translates to:
  /// **'Thunder will close itself and then attempt to generate a notification in the background. (It will take at least 15 minutes.)'**
  String get testBackgroundNotificationDescription;

  /// A message describing the UnifiedPush background test notification
  ///
  /// In en, this message translates to:
  /// **'Thunder will ask the notification server to send a delayed notification and then close itself. (It may take a few minutes.)'**
  String get testBackgroundUnifiedPushNotificationDescription;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// Option for text actions
  ///
  /// In en, this message translates to:
  /// **'Text Actions'**
  String get textActions;

  /// Setting for theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Setting for theme accent color
  ///
  /// In en, this message translates to:
  /// **'Accent Colors'**
  String get themeAccentColor;

  /// Name of primary theme color
  ///
  /// In en, this message translates to:
  /// **'Theme Primary'**
  String get themePrimary;

  /// Name of secondary theme color
  ///
  /// In en, this message translates to:
  /// **'Theme Secondary'**
  String get themeSecondary;

  /// Name of primary theme color
  ///
  /// In en, this message translates to:
  /// **'Theme Tertiary'**
  String get themeTertiary;

  /// Title of Theming in Settings -> Appearance -> Theming
  ///
  /// In en, this message translates to:
  /// **'Theming'**
  String get theming;

  /// Describes a thickness (e.g., divider)
  ///
  /// In en, this message translates to:
  /// **'Thickness'**
  String get thickness;

  /// Referring to the currently active account in account settings
  ///
  /// In en, this message translates to:
  /// **'This Account'**
  String get thisAccount;

  /// Post field for adding a custom thumbnail to the post
  ///
  /// In en, this message translates to:
  /// **'Thumbnail URL'**
  String get thumbnailUrl;

  /// Heading for changelog when Thunder has been updated
  ///
  /// In en, this message translates to:
  /// **'Thunder updated to {version}!'**
  String thunderHasBeenUpdated(Object version);

  /// Text for the user to know what the currently selected notification server is
  ///
  /// In en, this message translates to:
  /// **'Thunder Notification Server: {server}'**
  String thunderNotificationServer(Object server);

  /// No description provided for @timeoutComments.
  ///
  /// In en, this message translates to:
  /// **'Error: Timeout when attempting to fetch comments'**
  String get timeoutComments;

  /// No description provided for @timeoutErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'There was a timeout waiting for a response.'**
  String get timeoutErrorMessage;

  /// No description provided for @timeoutSaveComment.
  ///
  /// In en, this message translates to:
  /// **'Error: Timeout when attempting to save a comment'**
  String get timeoutSaveComment;

  /// No description provided for @timeoutSavingPost.
  ///
  /// In en, this message translates to:
  /// **'Error: Timeout when attempting to save post.'**
  String get timeoutSavingPost;

  /// No description provided for @timeoutUpvoteComment.
  ///
  /// In en, this message translates to:
  /// **'Error: Timeout when attempting to vote on comment'**
  String get timeoutUpvoteComment;

  /// No description provided for @timeoutVotingPost.
  ///
  /// In en, this message translates to:
  /// **'Error: Timeout when attempting to vote post.'**
  String get timeoutVotingPost;

  /// No description provided for @toggelRead.
  ///
  /// In en, this message translates to:
  /// **'Toggle Read'**
  String get toggelRead;

  /// No description provided for @top.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get top;

  /// No description provided for @topAll.
  ///
  /// In en, this message translates to:
  /// **'Top of all time'**
  String get topAll;

  /// No description provided for @topDay.
  ///
  /// In en, this message translates to:
  /// **'Top Today'**
  String get topDay;

  /// No description provided for @topHour.
  ///
  /// In en, this message translates to:
  /// **'Top in Past Hour'**
  String get topHour;

  /// No description provided for @topMonth.
  ///
  /// In en, this message translates to:
  /// **'Top Month'**
  String get topMonth;

  /// Sort mode for top in past 9 months
  ///
  /// In en, this message translates to:
  /// **'Top in Past 9 Months'**
  String get topNineMonths;

  /// No description provided for @topSixHour.
  ///
  /// In en, this message translates to:
  /// **'Top in Past 6 Hours'**
  String get topSixHour;

  /// Sort mode for top in past 6 months
  ///
  /// In en, this message translates to:
  /// **'Top in Past 6 Months'**
  String get topSixMonths;

  /// Sort mode for top in past 3 months
  ///
  /// In en, this message translates to:
  /// **'Top in Past 3 Months'**
  String get topThreeMonths;

  /// No description provided for @topTwelveHour.
  ///
  /// In en, this message translates to:
  /// **'Top in Past 12 Hours'**
  String get topTwelveHour;

  /// No description provided for @topWeek.
  ///
  /// In en, this message translates to:
  /// **'Top Week'**
  String get topWeek;

  /// No description provided for @topYear.
  ///
  /// In en, this message translates to:
  /// **'Top Year'**
  String get topYear;

  /// The total comments created by a user
  ///
  /// In en, this message translates to:
  /// **'{x} Comments'**
  String totalComments(Object x);

  /// The total posts created by a user
  ///
  /// In en, this message translates to:
  /// **'{x} Posts'**
  String totalPosts(Object x);

  /// No description provided for @totp.
  ///
  /// In en, this message translates to:
  /// **'TOTP (optional)'**
  String get totp;

  /// Short decription for moderator action to transfer a community
  ///
  /// In en, this message translates to:
  /// **'Transferred Community'**
  String get transferredModToCommunity;

  /// Warning that translations may not be complete when selecting a language in the settings
  ///
  /// In en, this message translates to:
  /// **'Please note that the translations may not be complete'**
  String get translationsMayNotBeComplete;

  /// No description provided for @trendingCommunities.
  ///
  /// In en, this message translates to:
  /// **'Trending Communities'**
  String get trendingCommunities;

  /// Suggestion for the user to try searching for a different type
  ///
  /// In en, this message translates to:
  /// **'Try searching for...'**
  String get trySearchingFor;

  /// No description provided for @unableToFindCommunity.
  ///
  /// In en, this message translates to:
  /// **'Unable to find community'**
  String get unableToFindCommunity;

  /// Error message for when we are unable to find a community, including the name
  ///
  /// In en, this message translates to:
  /// **'Unable to find community \'{communityName}\''**
  String unableToFindCommunityName(Object communityName);

  /// An error message for when we can't find a community on an instance
  ///
  /// In en, this message translates to:
  /// **'Unable to find the selected community on the selected user\'s instance.'**
  String get unableToFindCommunityOnInstance;

  /// No description provided for @unableToFindInstance.
  ///
  /// In en, this message translates to:
  /// **'Unable to find instance'**
  String get unableToFindInstance;

  /// Error message when language cannot be found.
  ///
  /// In en, this message translates to:
  /// **'Unable to find language'**
  String get unableToFindLanguage;

  /// Error message when we are unable to find a post
  ///
  /// In en, this message translates to:
  /// **'Unable to find post'**
  String get unableToFindPost;

  /// No description provided for @unableToFindUser.
  ///
  /// In en, this message translates to:
  /// **'Unable to find user'**
  String get unableToFindUser;

  /// Error message when we are unable to find a user
  ///
  /// In en, this message translates to:
  /// **'Unable to find user \'{username}\''**
  String unableToFindUserName(Object username);

  /// Placeholder for when we are unable to load a binary image
  ///
  /// In en, this message translates to:
  /// **'Unable to load image'**
  String get unableToLoadImage;

  /// Placeholder for when we are unable to load an image from a URL
  ///
  /// In en, this message translates to:
  /// **'Unable to load image from {domain}'**
  String unableToLoadImageFrom(Object domain);

  /// Error message when we are unable to load an instance
  ///
  /// In en, this message translates to:
  /// **'Unable to load {instance}'**
  String unableToLoadInstance(Object instance);

  /// Error message shown when we are unable to load a post.
  ///
  /// In en, this message translates to:
  /// **'Unable to load post'**
  String get unableToLoadPost;

  /// Error message when we are unable to load posts from an instance
  ///
  /// In en, this message translates to:
  /// **'Unable to load posts from {instance}'**
  String unableToLoadPostsFrominstance(Object instance);

  /// No description provided for @unableToLoadReplies.
  ///
  /// In en, this message translates to:
  /// **'Unable to load more replies.'**
  String get unableToLoadReplies;

  /// Error message for when we can't navigate to a Lemmy instance
  ///
  /// In en, this message translates to:
  /// **'Unable to navigate to {instanceHost}. It may not be a valid Lemmy instance.'**
  String unableToNavigateToInstance(Object instanceHost);

  /// Error message when we are unable to resolve a report
  ///
  /// In en, this message translates to:
  /// **'Unable to resolve report'**
  String get unableToResolveReport;

  /// Error message for when we are unable to retrieve the changelog.
  ///
  /// In en, this message translates to:
  /// **'Unable to retrieve changelog for version {version}.'**
  String unableToRetrieveChangelog(Object version);

  /// Moderator action to unban a user from a community
  ///
  /// In en, this message translates to:
  /// **'Unban from Community'**
  String get unbanFromCommunity;

  /// Short decription for moderator action to unban a user
  ///
  /// In en, this message translates to:
  /// **'Unbanned User'**
  String get unbannedUser;

  /// Short decription for moderator action to unban a user from a community
  ///
  /// In en, this message translates to:
  /// **'Unbanned {username} from Community'**
  String unbannedUserFromCommunity(Object username);

  /// Action for unblocking an item
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// Action to unblock a community
  ///
  /// In en, this message translates to:
  /// **'Unblock Community'**
  String get unblockCommunity;

  /// Action to unblock the instance of a given community
  ///
  /// In en, this message translates to:
  /// **'Unblock Community Instance'**
  String get unblockCommunityInstance;

  /// Tooltip for unblocking an instance
  ///
  /// In en, this message translates to:
  /// **'Unblock Instance'**
  String get unblockInstance;

  /// Action to unblock a user
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUser;

  /// Action to unblock the instance of a given user
  ///
  /// In en, this message translates to:
  /// **'Unblock User Instance'**
  String get unblockUserInstance;

  /// Action for acknowledging and enabling something
  ///
  /// In en, this message translates to:
  /// **'I Understand, Enable'**
  String get understandEnable;

  /// Error message for unexpected error
  ///
  /// In en, this message translates to:
  /// **'Unexpected Error'**
  String get unexpectedError;

  /// Action for unfavoriting a community
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get unfavorite;

  /// Short decription for moderator action to unfeature a post
  ///
  /// In en, this message translates to:
  /// **'Unfeatured Post'**
  String get unfeaturedPost;

  /// Short decription for moderator action to unhide a community
  ///
  /// In en, this message translates to:
  /// **'Unhid Community'**
  String get unhidCommunity;

  /// The action to unhide a post
  ///
  /// In en, this message translates to:
  /// **'Unhide'**
  String get unhide;

  /// A status indicator telling the current state of the UnifiedPush distributor app
  ///
  /// In en, this message translates to:
  /// **'UnifiedPush Distributor app: {app} ({count} available)'**
  String unifiedPushDistributorApp(Object app, Object count);

  /// Describes the notification type for UnifiedPush Notifications
  ///
  /// In en, this message translates to:
  /// **'UnifiedPush Notifications'**
  String get unifiedPushNotifications;

  /// Debug text that tells the user what UnifiedPush server is being used
  ///
  /// In en, this message translates to:
  /// **'UnifiedPush Server: {server}'**
  String unifiedPushServer(Object server);

  /// The UnifiedPush notification type (maybe shouldn't be translated)
  ///
  /// In en, this message translates to:
  /// **'UnifiedPush'**
  String get unifiedpush;

  /// Action for unlocking a post (moderator action)
  ///
  /// In en, this message translates to:
  /// **'Unlock Post'**
  String get unlockPost;

  /// Short decription for moderator action to unlock a post
  ///
  /// In en, this message translates to:
  /// **'Unlocked Post'**
  String get unlockedPost;

  /// Setting for unpinning a post from a community (moderator action)
  ///
  /// In en, this message translates to:
  /// **'Unpin from Community'**
  String get unpinFromCommunity;

  /// Moderator action to unpin a post from a community
  ///
  /// In en, this message translates to:
  /// **'Unpin Post from Community'**
  String get unpinPostFromCommunity;

  /// Message shown when a post is unpinned from a community
  ///
  /// In en, this message translates to:
  /// **'Unpinned post from community'**
  String get unpinnedPostFromCommunity;

  /// Describes an instance that is currently unreachable
  ///
  /// In en, this message translates to:
  /// **'Unreachable'**
  String get unreachable;

  /// Description for unresolved status (e.g., unresolved reports)
  ///
  /// In en, this message translates to:
  /// **'Unresolved'**
  String get unresolved;

  /// No description provided for @unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribe;

  /// Action for unsubscribing from a community
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe from Community'**
  String get unsubscribeFromCommunity;

  /// No description provided for @unsubscribePending.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe (subscription pending)'**
  String get unsubscribePending;

  /// No description provided for @unsubscribed.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribed'**
  String get unsubscribed;

  /// Message shown to the user when a new update is released
  ///
  /// In en, this message translates to:
  /// **'Update released: {version}'**
  String updateReleased(Object version);

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadImage;

  /// Metadata for image uploads
  ///
  /// In en, this message translates to:
  /// **'Uploaded: {date}'**
  String uploadedDate(Object date);

  /// Action for upvoting a post/comment
  ///
  /// In en, this message translates to:
  /// **'Upvote'**
  String get upvote;

  /// Name of upvote color setting
  ///
  /// In en, this message translates to:
  /// **'Upvote Color'**
  String get upvoteColor;

  /// Short description for upvoted post/comment
  ///
  /// In en, this message translates to:
  /// **'Upvoted'**
  String get upvoted;

  /// Unsupported link type at the present time.
  ///
  /// In en, this message translates to:
  /// **'This type of link is not supported at the moment.'**
  String get uriNotSupported;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get url;

  /// Toggle to use advanced share sheet.
  ///
  /// In en, this message translates to:
  /// **'Use Advanced Share Sheet'**
  String get useAdvancedShareSheet;

  /// Toggle to use APNs.
  ///
  /// In en, this message translates to:
  /// **'Use APNs Notifications'**
  String get useApplePushNotifications;

  /// Subtitle of the setting for using APNs
  ///
  /// In en, this message translates to:
  /// **'Uses Apple\'s Push Notification service'**
  String get useApplePushNotificationsDescription;

  /// Option to enable or disable compact view for small posts.
  ///
  /// In en, this message translates to:
  /// **'Enable for small posts, disable for big.'**
  String get useCompactView;

  /// Toggle to use local notifications.
  ///
  /// In en, this message translates to:
  /// **'Use Local Notifications (Experimental)'**
  String get useLocalNotifications;

  /// Subtitle of the setting for using local notifications
  ///
  /// In en, this message translates to:
  /// **'Periodically checks for notifications in the background'**
  String get useLocalNotificationsDescription;

  /// Toggle to use Material You theme.
  ///
  /// In en, this message translates to:
  /// **'Use Material You Theme'**
  String get useMaterialYouTheme;

  /// Subtitle of the setting for using Material You theme
  ///
  /// In en, this message translates to:
  /// **'Overrides the selected custom theme'**
  String get useMaterialYouThemeDescription;

  /// Setting name for using the profile picture for the drawer
  ///
  /// In en, this message translates to:
  /// **'Use Profile Picture for Drawer'**
  String get useProfilePictureForDrawer;

  /// Setting subtitle for using the profile picture for the drawer
  ///
  /// In en, this message translates to:
  /// **'When logged in, shows the user\'s profile picture in place of the drawer icon'**
  String get useProfilePictureForDrawerSubtitle;

  /// Message shown to the user when the suggested title is found
  ///
  /// In en, this message translates to:
  /// **'Use suggested title: {title}'**
  String useSuggestedTitle(Object title);

  /// Toggle to use UnifiedPush Notifications
  ///
  /// In en, this message translates to:
  /// **'Use UnifiedPush Notifications'**
  String get useUnifiedPushNotifications;

  /// Subtitle of the setting for using UnifiedPush Notifications
  ///
  /// In en, this message translates to:
  /// **'Requires a compatible app'**
  String get useUnifiedPushNotificationsDescription;

  /// Role name for user
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Heading for user actions page
  ///
  /// In en, this message translates to:
  /// **'User Actions'**
  String get userActions;

  /// Entry in list for a user to perform further actions
  ///
  /// In en, this message translates to:
  /// **'User \'{username}\''**
  String userEntry(Object username);

  /// Setting for user full name format
  ///
  /// In en, this message translates to:
  /// **'User Format'**
  String get userFormat;

  /// Hint text for adding a new user label
  ///
  /// In en, this message translates to:
  /// **'This is my favorite user'**
  String get userLabelHint;

  /// Heading for user labels settings
  ///
  /// In en, this message translates to:
  /// **'User Labels'**
  String get userLabels;

  /// Description text for user labels settings page
  ///
  /// In en, this message translates to:
  /// **'You can add, modify, or remove labels associated with users.'**
  String get userLabelsSettingsPageDescription;

  /// Setting for username color
  ///
  /// In en, this message translates to:
  /// **'User Name Color'**
  String get userNameColor;

  /// Setting for user name thickness
  ///
  /// In en, this message translates to:
  /// **'User Name Thickness'**
  String get userNameThickness;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;

  /// Settings related to user profiles.
  ///
  /// In en, this message translates to:
  /// **'User Profiles'**
  String get userProfiles;

  /// Description which explains that the settings are applied globally to the current user.
  ///
  /// In en, this message translates to:
  /// **'These settings sync with your Lemmy account and are only applied on a per-account basis.'**
  String get userSettingDescription;

  /// Heading for user style setting
  ///
  /// In en, this message translates to:
  /// **'User Style'**
  String get userStyle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Setting title for sending the user to the new formatting options
  ///
  /// In en, this message translates to:
  /// **'Looking for username formatting?'**
  String get usernameFormattingRedirect;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// String for describing the current version
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionNumber(Object version);

  /// String for video
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// Option to always start the video players in landscape
  ///
  /// In en, this message translates to:
  /// **'Auto Fullscreen'**
  String get videoAutoFullscreen;

  /// Option to always loop a video
  ///
  /// In en, this message translates to:
  /// **'Loop Video'**
  String get videoAutoLoop;

  /// Option to always mute videos
  ///
  /// In en, this message translates to:
  /// **'Mute Videos'**
  String get videoAutoMute;

  /// Option to always autoplay videos
  ///
  /// In en, this message translates to:
  /// **'Video Autoplay'**
  String get videoAutoPlay;

  /// Option to select the default video playback Speed
  ///
  /// In en, this message translates to:
  /// **'Default Playback Speed'**
  String get videoDefaultPlaybackSpeed;

  /// Description to Open video with an external application
  ///
  /// In en, this message translates to:
  /// **'Play video with an external app'**
  String get videoLinkHandlingExternal;

  /// Description for using in-app video player
  ///
  /// In en, this message translates to:
  /// **'Use Thunder built-in player'**
  String get videoPlayerInApp;

  /// Option to select video player mode (in-app or external)
  ///
  /// In en, this message translates to:
  /// **'Player Mode'**
  String get videoPlayerMode;

  /// A title for viewing all of something (e.g., instances)
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @viewAllComments.
  ///
  /// In en, this message translates to:
  /// **'View all comments'**
  String get viewAllComments;

  /// Menu item for viewing a comment's source
  ///
  /// In en, this message translates to:
  /// **'View Comment Source'**
  String get viewCommentSource;

  /// Action which allows the user to navigate to the modlog for a particular entity
  ///
  /// In en, this message translates to:
  /// **'View Modlog'**
  String get viewModlog;

  /// Action for viewing original text (as opposed to raw markdown)
  ///
  /// In en, this message translates to:
  /// **'View original'**
  String get viewOriginal;

  /// Action for viewing a post as a different account
  ///
  /// In en, this message translates to:
  /// **'View post as different account'**
  String get viewPostAsDifferentAccount;

  /// Menu item for viewing a post's source
  ///
  /// In en, this message translates to:
  /// **'View post source'**
  String get viewPostSource;

  /// Action for viewing source (raw markdown)
  ///
  /// In en, this message translates to:
  /// **'View source'**
  String get viewSource;

  /// Chip for viewing all possible search results
  ///
  /// In en, this message translates to:
  /// **'Viewing all'**
  String get viewingAll;

  /// Visibility heading for community
  ///
  /// In en, this message translates to:
  /// **'Visibility: {visibility}'**
  String visibility(Object visibility);

  /// No description provided for @visitCommunity.
  ///
  /// In en, this message translates to:
  /// **'Visit Community'**
  String get visitCommunity;

  /// Action to visit the instance of a community
  ///
  /// In en, this message translates to:
  /// **'Visit Community Instance'**
  String get visitCommunityInstance;

  /// No description provided for @visitInstance.
  ///
  /// In en, this message translates to:
  /// **'Visit Instance'**
  String get visitInstance;

  /// Action to visit the instance of a user
  ///
  /// In en, this message translates to:
  /// **'Visit User Instance'**
  String get visitUserInstance;

  /// No description provided for @visitUserProfile.
  ///
  /// In en, this message translates to:
  /// **'Visit User Profile'**
  String get visitUserProfile;

  /// Heading for warning dialogs
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// The total downvotes of post or comment
  ///
  /// In en, this message translates to:
  /// **'{x} downvotes'**
  String xDownvotes(Object x);

  /// The total score of post or comment
  ///
  /// In en, this message translates to:
  /// **'{x} score'**
  String xScore(Object x);

  /// The total upvotes of post or comment
  ///
  /// In en, this message translates to:
  /// **'{x} upvotes'**
  String xUpvotes(Object x);

  /// An account descriptor representing how old an account is
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {{x} year old} one {{x} year old} other {{x} years old}}'**
  String xYearsOld(num count, Object x);

  /// A positive status
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Error message shown to user when they attempt to import a JSON file that doesn't have the right extension
  ///
  /// In en, this message translates to:
  /// **'You must select a .json file.'**
  String get youMustSelectAJsonFile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'be',
        'cs',
        'de',
        'en',
        'eo',
        'es',
        'fi',
        'fr',
        'hu',
        'it',
        'nb',
        'nl',
        'pl',
        'pt',
        'ru',
        'sk',
        'sv',
        'ta',
        'tr',
        'uk',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'AU':
            return AppLocalizationsEnAu();
          case 'GB':
            return AppLocalizationsEnGb();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'be':
      return AppLocalizationsBe();
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'eo':
      return AppLocalizationsEo();
    case 'es':
      return AppLocalizationsEs();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'hu':
      return AppLocalizationsHu();
    case 'it':
      return AppLocalizationsIt();
    case 'nb':
      return AppLocalizationsNb();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sv':
      return AppLocalizationsSv();
    case 'ta':
      return AppLocalizationsTa();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
