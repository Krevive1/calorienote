import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // ビルド時に切り替え可能なフラグ（--dart-define=INTERNAL_TEST=true で有効化）
  static final bool _isInternalTest =
      const String.fromEnvironment('INTERNAL_TEST', defaultValue: 'false')
          .toLowerCase() ==
      'true';
  
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
    if (!_isInternalTest) {
      await MobileAds.instance.initialize();
    }
  }

  static BannerAd? createBannerAd() {
    if (_isInternalTest) {
      return null;
    }
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            debugPrint('Banner ad loaded.');
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            debugPrint('Banner ad failed to load: $error');
          }
          ad.dispose();
        },
      ),
    );
  }

  static InterstitialAd? _interstitialAd;

  static Future<void> loadInterstitialAd() async {
    if (_isInternalTest) {
      return;
    }
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          if (kDebugMode) {
            debugPrint('Interstitial ad loaded.');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint('Interstitial ad failed to load: $error');
          }
        },
      ),
    );
  }

  static Future<void> showInterstitialAd() async {
    if (_isInternalTest) {
      // 内部テストモードの場合、何もしない
      return;
    }
    
    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      if (kDebugMode) {
        debugPrint('Interstitial ad not loaded.');
      }
    }
  }

  static RewardedAd? _rewardedAd;

  static Future<void> loadRewardedAd() async {
    if (_isInternalTest) {
      return;
    }
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          if (kDebugMode) {
            debugPrint('Rewarded ad loaded.');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            debugPrint('Rewarded ad failed to load: $error');
          }
        },
      ),
    );
  }

  static Future<void> showRewardedAd({
    required VoidCallback onRewarded,
  }) async {
    if (_isInternalTest) {
      // 内部テストモードの場合、直接報酬を付与
      onRewarded();
      return;
    }
    
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          if (kDebugMode) {
            debugPrint('Rewarded ad failed to show: $error');
          }
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
      if (kDebugMode) {
        debugPrint('Rewarded ad not loaded.');
      }
    }
  }
}
