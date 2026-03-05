import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;

  const BannerAdWidget({super.key, this.adSize = AdSize.banner});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final canShow = await AdService().canShowAds();
    if (!canShow) {
      debugPrint('Ad loading skipped: Ads disabled or Premium active');
      return;
    }

    _bannerAd = AdService().createBannerAd(
      size: widget.adSize,
      onLoaded: () {
        debugPrint('Banner ad loaded successfully');
        if (mounted) {
          setState(() => _isLoaded = true);
        }
      },
      onFailed: () {
        debugPrint('Banner ad failed to load');
        if (mounted) {
          setState(() => _isLoaded = false);
        }
      },
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.adSize.width.toDouble(),
      height: widget.adSize.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
