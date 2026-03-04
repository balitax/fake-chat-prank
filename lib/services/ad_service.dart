import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/ad_ids.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static const String _premiumUnlockKey = 'premium_unlock_time';
  static const String _adsWatchedKey = 'ads_watched_count';
  static const int premiumDurationHours = 6;
  static const int adsRequiredForPremium = 3;

  // Ad Unit IDs moved to lib/constants/ad_ids.dart

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;
  bool _isShowingAppOpenAd = false;

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadInterstitialAd();
    loadRewardedAd();
    loadAppOpenAd();
  }

  // ─── Banner Ad ───
  BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    required void Function() onLoaded,
    required void Function() onFailed,
  }) {
    return BannerAd(
      adUnitId: AdIds.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');
          ad.dispose();
          onFailed();
        },
      ),
    );
  }

  // ─── Interstitial Ad ───
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdIds.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> showInterstitialAd({VoidCallback? onComplete}) async {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
          onComplete?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
          onComplete?.call();
        },
      );
      await _interstitialAd!.show();
    } else {
      onComplete?.call();
    }
  }

  bool get isInterstitialReady => _interstitialAd != null;

  // ─── Rewarded Ad ───
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdIds.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  Future<bool> showRewardedAd({required void Function() onRewarded}) async {
    if (_rewardedAd == null) {
      loadRewardedAd();
      return false;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded();
      },
    );
    return true;
  }

  bool get isRewardedReady => _rewardedAd != null;

  // ─── App Open Ad ───
  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: AdIds.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('App open ad failed to load: $error');
          _appOpenAd = null;
        },
      ),
    );
  }

  Future<void> showAppOpenAd() async {
    if (_appOpenAd == null || _isShowingAppOpenAd) return;

    _isShowingAppOpenAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );
    await _appOpenAd!.show();
  }

  // ─── Premium Unlock Logic ───
  Future<void> unlockPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _premiumUnlockKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    // Reset ads count after unlocking
    await resetAdsWatchedCount();
  }

  Future<int> getAdsWatchedCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_adsWatchedKey) ?? 0;
  }

  Future<void> incrementAdsWatchedCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_adsWatchedKey) ?? 0;
    await prefs.setInt(_adsWatchedKey, current + 1);
  }

  Future<void> resetAdsWatchedCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_adsWatchedKey);
  }

  Future<bool> isPremiumActive() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockTime = prefs.getInt(_premiumUnlockKey);
    if (unlockTime == null) return false;

    final unlockDateTime = DateTime.fromMillisecondsSinceEpoch(unlockTime);
    final difference = DateTime.now().difference(unlockDateTime);
    return difference.inHours < premiumDurationHours;
  }

  Future<Duration?> premiumTimeRemaining() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockTime = prefs.getInt(_premiumUnlockKey);
    if (unlockTime == null) return null;

    final unlockDateTime = DateTime.fromMillisecondsSinceEpoch(unlockTime);
    final expiry = unlockDateTime.add(
      const Duration(hours: premiumDurationHours),
    );
    final remaining = expiry.difference(DateTime.now());

    if (remaining.isNegative) return null;
    return remaining;
  }
}
