import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/interstitial_ad_service.dart';
import '../services/banner_ad_service.dart';

final interstitialAdProvider = Provider<InterstitialAdService>((ref) {
  final service = InterstitialAdService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// StateNotifierProvider for banner ads - enables reactive UI updates
final bannerAdProvider = StateNotifierProvider<BannerAdNotifier, BannerAdState>(
  (ref) {
    return BannerAdNotifier();
  },
);
