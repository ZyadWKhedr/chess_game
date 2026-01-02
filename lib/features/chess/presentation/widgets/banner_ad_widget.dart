import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/providers/ad_provider.dart';

class BannerAdWidget extends ConsumerWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the state directly - will rebuild when state changes
    final adState = ref.watch(bannerAdProvider);

    debugPrint(
      'BannerAdWidget build: isLoaded=${adState.isLoaded}, hasAd=${adState.bannerAd != null}',
    );

    if (adState.isLoaded && adState.bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: adState.bannerAd!.size.width.toDouble(),
        height: adState.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: adState.bannerAd!),
      );
    }

    // Show placeholder or nothing while loading
    return const SizedBox.shrink();
  }
}
