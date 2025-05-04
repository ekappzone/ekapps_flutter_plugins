import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A utility class that manages all types of Google Mobile Ads
/// including Banner, Interstitial, Rewarded, App Open, and Native Ads.
///
/// ### Initialization:
/// Call [initialize] in the `main()` function before running the app:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await MobileAds.instance.initialize();
///   EkappzAdManager.initialize(
///     androidBannerId: 'ca-app-pub-xxx/banner-id',
///     iosBannerId: 'ca-app-pub-xxx/banner-id-ios',
///     androidInterstitialId: 'ca-app-pub-xxx/interstitial-id',
///     iosInterstitialId: 'ca-app-pub-xxx/interstitial-id-ios',
///     androidRewardedId: 'ca-app-pub-xxx/rewarded-id',
///     iosRewardedId: 'ca-app-pub-xxx/rewarded-id-ios',
///     androidAppOpenId: 'ca-app-pub-xxx/appopen-id',
///     iosAppOpenId: 'ca-app-pub-xxx/appopen-id-ios',
///     androidNativeId: 'ca-app-pub-xxx/native-id',
///     iosNativeId: 'ca-app-pub-xxx/native-id-ios',
///   );
///   runApp(MyApp());
/// }
/// ```
class EkappzAdManager {
  // Static ad instances
  static BannerAd? bannerAd;
  static InterstitialAd? interstitialAd;
  static RewardedAd? rewardedAd;
  static AppOpenAd? appOpenAd;
  static NativeAd? nativeAd;

  static bool isAppOpenAdShowing = false;
  static DateTime? _appOpenLoadTime;

  // Load attempt counters
  static int interstitialLoadAttempts = 0;
  static int rewardedLoadAttempts = 0;
  static const int maxLoadAttempts = 3;

  static final AdRequest _request = AdRequest();

  // Ad unit IDs
  static late String _androidBannerId;
  static late String _iosBannerId;
  static late String _androidInterstitialId;
  static late String _iosInterstitialId;
  static late String _androidRewardedId;
  static late String _iosRewardedId;
  static late String _androidAppOpenId;
  static late String _iosAppOpenId;
  static late String _androidNativeId;
  static late String _iosNativeId;

  /// Initializes the ad manager and loads all ad types.
  static void initialize({
    String androidBannerId = "",
    String iosBannerId = "",
    String androidInterstitialId = "",
    String iosInterstitialId = "",
    String androidRewardedId = "",
    String iosRewardedId = "",
    String androidAppOpenId = "",
    String iosAppOpenId = "",
    String androidNativeId = "",
    String iosNativeId = "",
  }) {
    MobileAds.instance.initialize();

    _androidBannerId = androidBannerId;
    _iosBannerId = iosBannerId;
    _androidInterstitialId = androidInterstitialId;
    _iosInterstitialId = iosInterstitialId;
    _androidRewardedId = androidRewardedId;
    _iosRewardedId = iosRewardedId;
    _androidAppOpenId = androidAppOpenId;
    _iosAppOpenId = iosAppOpenId;
    _androidNativeId = androidNativeId;
    _iosNativeId = iosNativeId;

    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
    loadAppOpenAd();
    loadNativeAd();
  }

  // Platform-specific ID getters
  static String get _bannerId =>
      Platform.isAndroid ? _androidBannerId : _iosBannerId;
  static String get _interstitialId =>
      Platform.isAndroid ? _androidInterstitialId : _iosInterstitialId;
  static String get _rewardedId =>
      Platform.isAndroid ? _androidRewardedId : _iosRewardedId;
  static String get _appOpenId =>
      Platform.isAndroid ? _androidAppOpenId : _iosAppOpenId;
  static String get _nativeId =>
      Platform.isAndroid ? _androidNativeId : _iosNativeId;

  /// Loads a banner ad and assigns it to [bannerAd].
  static void loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: _bannerId,
      request: _request,
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => debugPrint("✅ Banner Ad Loaded"),
        onAdFailedToLoad: (ad, error) {
          debugPrint("❌ Banner Ad Failed: $error");
          ad.dispose();
        },
      ),
    )..load();
  }

  /// Loads an interstitial ad with retry on failure.
  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: _request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          interstitialAd = null;
          interstitialLoadAttempts++;
          if (interstitialLoadAttempts < maxLoadAttempts) {
            loadInterstitialAd();
          }
        },
      ),
    );
  }

  /// Shows the loaded interstitial ad and reloads it after dismissal.
  static void showInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.show();
      interstitialAd = null;
      loadInterstitialAd();
    }
  }

  /// Loads a rewarded ad with retry on failure.
  static void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: _request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          rewardedLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          rewardedAd = null;
          rewardedLoadAttempts++;
          if (rewardedLoadAttempts < maxLoadAttempts) {
            loadRewardedAd();
          }
        },
      ),
    );
  }

  /// Shows the rewarded ad and executes [onRewardEarned] when the reward is granted.
  static void showRewardedAd(VoidCallback onRewardEarned) {
    if (rewardedAd != null) {
      rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          onRewardEarned();
        },
      );
      rewardedAd = null;
      loadRewardedAd();
    }
  }

  /// Loads an App Open Ad.
  static void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: _appOpenId,
      request: _request,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          debugPrint("✅ App Open Ad Loaded");
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint("❌ App Open Ad Failed to Load: $error");
          appOpenAd = null;
        },
      ),
    );
  }

  /// Shows the App Open Ad if it's loaded and not expired.
  static void showAppOpenAdIfAvailable() {
    if (appOpenAd == null || isAppOpenAdShowing) return;

    final now = DateTime.now();
    if (_appOpenLoadTime != null &&
        now.difference(_appOpenLoadTime!).inHours >= 4) {
      loadAppOpenAd();
      return;
    }

    appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        isAppOpenAdShowing = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        isAppOpenAdShowing = false;
        ad.dispose();
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        isAppOpenAdShowing = false;
        ad.dispose();
        loadAppOpenAd();
      },
    );

    appOpenAd!.show();
  }

  /// Loads a Native Ad using a factory ID (e.g., 'listTile').
  static void loadNativeAd() {
    nativeAd = NativeAd(
      adUnitId: _nativeId,
      factoryId: 'listTile',
      request: _request,
      listener: NativeAdListener(
        onAdLoaded: (ad) => debugPrint("✅ Native Ad Loaded"),
        onAdFailedToLoad: (ad, error) {
          debugPrint("❌ Native Ad Failed: $error");
          ad.dispose();
        },
      ),
    )..load();
  }
}
