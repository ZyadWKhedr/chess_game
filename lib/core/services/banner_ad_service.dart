import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// State class for banner ad
class BannerAdState {
  final BannerAd? bannerAd;
  final bool isLoaded;
  final String? error;

  const BannerAdState({this.bannerAd, this.isLoaded = false, this.error});

  BannerAdState copyWith({BannerAd? bannerAd, bool? isLoaded, String? error}) {
    return BannerAdState(
      bannerAd: bannerAd ?? this.bannerAd,
      isLoaded: isLoaded ?? this.isLoaded,
      error: error ?? this.error,
    );
  }
}

/// StateNotifier for managing banner ad state with proper reactivity
class BannerAdNotifier extends StateNotifier<BannerAdState> {
  BannerAdNotifier() : super(const BannerAdState());

  // Toggle this to switch between test and production
  final bool _isTestMode = false;

  // Test Ad Unit IDs (AdMob default test IDs)
  final String _testAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  final String _testAdUnitIdiOS = 'ca-app-pub-3940256099942544/2934735716';

  // Production Ad Unit ID
  final String _productionAdUnitId = 'ca-app-pub-2227439392595568/4022423258';

  String get _adUnitId {
    if (_isTestMode) {
      return Platform.isAndroid ? _testAdUnitIdAndroid : _testAdUnitIdiOS;
    }
    return _productionAdUnitId;
  }

  Future<void> loadAd() async {
    debugPrint('BannerAd: Starting to load ad with ID: $_adUnitId');

    final bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BannerAd: Ad loaded successfully!');
          if (mounted) {
            state = state.copyWith(
              bannerAd: ad as BannerAd,
              isLoaded: true,
              error: null,
            );
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            'BannerAd: Failed to load - ${error.message} (code: ${error.code})',
          );
          ad.dispose();
          if (mounted) {
            state = state.copyWith(
              bannerAd: null,
              isLoaded: false,
              error: error.message,
            );
          }
        },
        onAdOpened: (ad) => debugPrint('BannerAd: Ad opened'),
        onAdClosed: (ad) => debugPrint('BannerAd: Ad closed'),
        onAdImpression: (ad) => debugPrint('BannerAd: Ad impression recorded'),
        onAdClicked: (ad) => debugPrint('BannerAd: Ad clicked'),
      ),
    );

    await bannerAd.load();
  }

  @override
  void dispose() {
    state.bannerAd?.dispose();
    super.dispose();
  }
}
