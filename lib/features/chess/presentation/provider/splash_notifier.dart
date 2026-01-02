import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/providers/ad_provider.dart';
import 'splash_state.dart';

class SplashNotifier extends StateNotifier<SplashState> {
  final Ref _ref;
  Timer? _minTimer;
  Timer? _maxTimer;

  SplashNotifier(this._ref) : super(const SplashState()) {
    _initialize();
  }

  void _initialize() {
    _loadAds();
    _startTimers();
  }

  Future<void> _loadAds() async {
    try {
      // Load banner ad first
      final bannerNotifier = _ref.read(bannerAdProvider.notifier);
      await bannerNotifier.loadAd();

      // Load interstitial ad
      final interstitialService = _ref.read(interstitialAdProvider);
      interstitialService.loadAd();

      // Give some time for interstitial to start loading
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        state = state.copyWith(
          adsLoaded: true,
          status: state.minTimeElapsed
              ? SplashStatus.ready
              : SplashStatus.adsLoaded,
          loadingMessage: 'Starting...',
        );
      }
    } catch (e) {
      // If ads fail to load, continue anyway
      if (mounted) {
        state = state.copyWith(
          adsLoaded: true,
          status: state.minTimeElapsed
              ? SplashStatus.ready
              : SplashStatus.adsLoaded,
          loadingMessage: 'Starting...',
        );
      }
    }
  }

  void _startTimers() {
    // Minimum splash screen duration of 2.5 seconds
    _minTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        state = state.copyWith(
          minTimeElapsed: true,
          status: state.adsLoaded ? SplashStatus.ready : state.status,
        );
      }
    });

    // Maximum wait time of 5 seconds (fallback if ads take too long)
    _maxTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !state.adsLoaded) {
        state = state.copyWith(
          adsLoaded: true,
          status: SplashStatus.ready,
          loadingMessage: 'Starting...',
        );
      }
    });
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    _maxTimer?.cancel();
    super.dispose();
  }
}

final splashProvider =
    StateNotifierProvider.autoDispose<SplashNotifier, SplashState>((ref) {
      return SplashNotifier(ref);
    });
