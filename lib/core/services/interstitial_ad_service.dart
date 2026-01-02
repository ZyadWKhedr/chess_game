import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdService {
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;

  // Toggle this to switch between test and production
  final bool _isTestMode = false;

  // Test Ad Unit IDs (AdMob default test IDs for Interstitial)
  final String _testAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  final String _testAdUnitIdiOS = 'ca-app-pub-3940256099942544/4411468910';

  // Real Ad Unit ID provided by user
  final String _productionAdUnitId = 'ca-app-pub-2227439392595568/2448954300';

  String get _adUnitId {
    if (_isTestMode) {
      return Platform.isAndroid ? _testAdUnitIdAndroid : _testAdUnitIdiOS;
    }
    return _productionAdUnitId;
  }

  void loadAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('$ad loaded');
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error.');
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            loadAd();
          }
        },
      ),
    );
  }

  void showAd({VoidCallback? onAdDismissed}) {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      onAdDismissed?.call();
      loadAd(); // Try to load for next time
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        onAdDismissed?.call();
        loadAd(); // Reload for next time
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        onAdDismissed?.call(); // Ensure callback is called even on failure
        loadAd(); // Reload for next time
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
