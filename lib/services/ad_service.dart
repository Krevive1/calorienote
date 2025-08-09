import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // 本番用のAdMob設定 - すべての広告ユニットIDが設定完了
  
  static String get bannerAdUnitId {
    // 本番用のバナー広告ユニットID
    return 'ca-app-pub-6807460116780712/8801538840';
  }

  static String get interstitialAdUnitId {
    // 本番用のインタースティシャル広告ユニットID
    return 'ca-app-pub-6807460116780712/2304413250';
  }

  static String get rewardedAdUnitId {
    // 本番用のリワード広告ユニットID
    return 'ca-app-pub-6807460116780712/5129887145';
  }

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }

  static InterstitialAd? _interstitialAd;

  static Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          debugPrint('Interstitial ad loaded.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  static Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      debugPrint('Interstitial ad not loaded.');
    }
  }

  static RewardedAd? _rewardedAd;

  static Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          debugPrint('Rewarded ad loaded.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  static Future<void> showRewardedAd({
    required VoidCallback onRewarded,
  }) async {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Rewarded ad failed to show: $error');
          ad.dispose();
          _rewardedAd = null;
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewarded();
        },
      );
    } else {
      debugPrint('Rewarded ad not loaded.');
    }
  }
}
