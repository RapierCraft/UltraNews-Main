import 'package:nb_utils/nb_utils.dart';

const mAppName = 'UltraNews';
const mWebName = 'UltraNews';

String get appName => isMobile ? mAppName : mWebName;

const mAboutApp =
    '$mAppName is a news app that latest news and other content such as videos & blogs and summarizes in less than 200 words and update you with latest news in seconds. We have given the option to choose the language i.e English & Hindi.';

const mFirebaseAppId = 'ultranews-3a7d6.appspot.com';
const mAppIconUrl = 'https://firebasestorage.googleapis.com/v0/b/$mFirebaseAppId/o/app_logo.png?alt=media&token=55faf2c8-84ca-4776-80aa-c67222e58ff8';
//region URLs & Keys

const mOneSignalAppId = '7adff19b-c38d-45cf-83be-9027186efb7b';
const mOneSignalRestKey = 'YTM5YWMyYTAtZDc3Yy00YTNjLWE1NWMtMmU3ODYwNDRmYjVh';
const mOneSignalChannelId = 'fbfc884b-d847-4b81-9fd4-afbd47e58755';

const mFirebaseStorageFilePath = 'images';
const mTesterNotAllowedMsg = 'Tester role not allowed to perform this action';

// Testing ca-app-pub-8691767875673769~4558778609
const mAdMobAppId = 'ca-app-pub-3461068968033719~2303570723';
const mAdMobBannerId = 'ca-app-pub-3461068968033719/6086386147';
const mAdMobInterstitialId = 'ca-app-pub-3461068968033719/4369995708';

// Facebook
const fbBannerId = "YOUR_FACEBOOK_BANNER_ID";
const fbBannerIdIos = "";
const fbInterstitialId = "YOUR_FACEBOOK_INTERSTITIAL_ID";
const fbInterstitialIdIos = "";

const mWeatherBaseUrl = 'https://api.weatherapi.com/v1/current.json';

const mMoreAppsLink = 'https://play.google.com/store/apps/developer?id=MeetMighty';

//endregion

const FilterByPost = 'filter_by_post';
const FilterByCategory = 'filter_by_category';

bool isRTL = getStringAsync(SELECTED_LANGUAGE_CODE) == 'ar';

/// NewsType
const NewsTypeRecent = 'recent';
const NewsTypeBreaking = 'breaking';
const NewsTypeStory = 'story';

/// NewsStatus
const NewsStatusPublished = 'published';
const NewsStatusUnpublished = 'unpublished';
const NewsStatusDraft = 'draft';

/// Dashboard Widgets
const DashboardWidgetsBreakingNewsMarquee = 'BreakingNewsMarquee';
const DashboardWidgetsStory = 'Story';
const DashboardWidgetsPoll = 'Poll';
const DashboardWidgetsBreakingNews = 'BreakingNews';
const DashboardWidgetsQuickRead = 'QuickRead';
const DashboardWidgetsRecentNews = 'RecentNews';

///Ads
const Admob = 'Admob';
const Facebook = 'Facebook';

const DefaultLanguage = 'en';
const EnableSocialLogin = true;
const DocLimit = 20;
const PollLimit = 5;

//App store URL
const appStoreBaseUrl = 'https://www.apple.com/app-store/';

//region LiveStream Keys
const StreamRefresh = 'StreamRefresh';
const StreamRefreshBookmark = 'StreamRefreshBookmark';
const StreamSelectItem = 'StreamSelectItem';
const String StreamUpdateDrawer = 'StreamUpdateDrawer';
const PollStreamRefresh = 'PollStreamRefresh';
//endregion

/* Login Type */
const LoginTypeApp = 'app';
const LoginTypeGoogle = 'google';
const LoginTypeOTP = 'otp';
const LoginTypeApple = 'apple';

/* Theme Mode Type */
const ThemeModeLight = 1;
const ThemeModeDark = 0;
const ThemeModeSystem = 2;

List<String> adMobTestDevices = ['3610AB2566A57ABBD1D93687699877E2'];

//region SharedPreferences Keys..

class DefaultValues {
  final String defaultLanguage = "en";
}

DefaultValues defaultValues = DefaultValues();

///User keys
const IS_LOGGED_IN = 'IS_LOGGED_IN';
const IS_ADMIN = 'IS_ADMIN';
const IS_TESTER = 'IS_TESTER';
const USER_ID = 'USER_ID';
const FULL_NAME = 'FULL_NAME';
const USER_EMAIL = 'USER_EMAIL';
const USER_ROLE = 'USER_ROLE';
const PASSWORD = 'PASSWORD';
const PROFILE_IMAGE = 'PROFILE_IMAGE';
const IS_NOTIFICATION_ON = "IS_NOTIFICATION_ON";
const IS_REMEMBERED = "IS_REMEMBERED";
const LANGUAGE = 'LANGUAGE';
const PLAYER_ID = 'PLAYER_ID';
const IS_SOCIAL_LOGIN = 'IS_SOCIAL_LOGIN';
const LOGIN_TYPE = 'LOGIN_TYPE';
const BOOKMARKS = 'BOOKMARKS';
const POST_VIEWED_LIST = 'POST_VIEWED_LIST';
const REDIRECT_INDEX = 'REDIRECT_INDEX';

const NOTIFICATION = 'notification';
const ADVERTISEMENT = 'advertisement';
const Ads = 'ads';
const CUSTOM = 'custom';

///

const IS_FIRST_TIME = 'IS_FIRST_TIME';
const TERMS_AND_CONDITION_PREF = 'TERMS_AND_CONDITION_PREF';
const PRIVACY_POLICY_PREF = 'PRIVACY_POLICY_PREF';
const CONTACT_PREF = 'CONTACT_PREF';
const FLUTTER_WEB_BUILD_VERSION = 'FLUTTER_WEB_BUILD_VERSION';
const DISABLE_LOCATION_WIDGET = 'DISABLE_LOCATION_WIDGET';
const DISABLE_QUICK_READ_WIDGET = 'DISABLE_QUICK_READ_WIDGET';
const DISABLE_STORY_WIDGET = 'DISABLE_STORY_WIDGET';
const DISABLE_HEADLINE_WIDGET = 'DISABLE_HEADLINE_WIDGET';
const DISABLE_AD = 'DISABLE_AD';
//const DISABLE_SPONSORED_AD = 'DISABLE_SPONSORED_AD';
const AD_TYPE = 'AD_TYPE';




const FONT_SIZE_PREF = 'FONT_SIZE_PREF';
const DASHBOARD_WIDGET_ORDER = 'DASHBOARD_WIDGET_ORDER';

const DASHBOARD_DATA = 'DASHBOARD_DATA';

const POST_LAYOUT = 'POST_LAYOUT';
const NOTIFICATION_LIST = 'NOTIFICATION_LIST';

const ADMOB_BANNER_ID = 'ADMOB_BANNER_ID';
const ADMOB_INTERSTITIAL_ID = 'ADMOB_INTERSTITIAL_ID';
const ADMOB_BANNER_ID_IOS = 'ADMOB_BANNER_ID_IOS';
const ADMOB_INTERSTITIAL_ID_IOS = 'ADMOB_INTERSTITIAL_ID_IOS';

const FACEBOOK_BANNER_ID = 'FACEBOOK_BANNER_ID';
const FACEBOOK_INTERSTITIAL_ID = 'FACEBOOK_INTERSTITIAL_ID';
const FACEBOOK_BANNER_ID_IOS = 'FACEBOOK_BANNER_ID_IOS';
const FACEBOOK_INTERSTITIAL_ID_IOS = 'FACEBOOK_INTERSTITIAL_ID_IOS';

const IS_FIRST_TIME_SCREEN = 'IS_FIRST_TIME_SCREEN';

/// ADDED BY SMARTINTEL
const TIMES_OPENED = 'TIMES_OPENED';


const GOOGLE_LOGIN_NEW = 'GOOGLE_LOGIN_NEW';

//endregion

/// Audience Poll
const perDayPoll = 5;


const APP_CATEGORIES_LOCAL = 'APP_CATEGORIES';


