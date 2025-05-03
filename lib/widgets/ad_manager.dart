import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // Static ad instances
  static BannerAd? bannerAd;
  static InterstitialAd? interstitialAd;
  static RewardedAd? rewardedAd;

  // Load attempt counters
  static int interstitialLoadAttempts = 0;
  static int rewardedLoadAttempts = 0;
  static const int maxLoadAttempts = 3;

  // Ad request object
  static final AdRequest _request = AdRequest();

  // Ad unit IDs (set during initialization)
  static late String _androidBannerId;
  static late String _iosBannerId;
  static late String _androidInterstitialId;
  static late String _iosInterstitialId;
  static late String _androidRewardedId;
  static late String _iosRewardedId;

  /// Initialize Google Mobile Ads and set Ad Unit IDs
  static void initialize({
    required String androidBannerId,
    required String iosBannerId,
    required String androidInterstitialId,
    required String iosInterstitialId,
    required String androidRewardedId,
    required String iosRewardedId,
  }) {
    MobileAds.instance.initialize();

    _androidBannerId = androidBannerId;
    _iosBannerId = iosBannerId;
    _androidInterstitialId = androidInterstitialId;
    _iosInterstitialId = iosInterstitialId;
    _androidRewardedId = androidRewardedId;
    _iosRewardedId = iosRewardedId;

    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  static String get _bannerId =>
      Platform.isAndroid ? _androidBannerId : _iosBannerId;
  static String get _interstitialId =>
      Platform.isAndroid ? _androidInterstitialId : _iosInterstitialId;
  static String get _rewardedId =>
      Platform.isAndroid ? _androidRewardedId : _iosRewardedId;

  /// Load Banner Ad
  static void loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: _bannerId,
      request: _request,
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint("✅ Banner Ad Loaded"),
        onAdFailedToLoad: (ad, error) {
          debugPrint("❌ Banner Ad Failed: $error");
          ad.dispose();
        },
      ),
    )..load();
  }

  /// Load Interstitial Ad
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

  /// Show Interstitial Ad
  static void showInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.show();
      interstitialAd = null;
      loadInterstitialAd();
    }
  }

  /// Load Rewarded Ad
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

  /// Show Rewarded Ad
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
}
