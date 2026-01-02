import 'package:flutter/foundation.dart';

enum SplashStatus { loading, adsLoaded, ready }

@immutable
class SplashState {
  final SplashStatus status;
  final bool adsLoaded;
  final bool minTimeElapsed;
  final String loadingMessage;

  const SplashState({
    this.status = SplashStatus.loading,
    this.adsLoaded = false,
    this.minTimeElapsed = false,
    this.loadingMessage = 'Loading...',
  });

  bool get isReady => adsLoaded && minTimeElapsed;

  SplashState copyWith({
    SplashStatus? status,
    bool? adsLoaded,
    bool? minTimeElapsed,
    String? loadingMessage,
  }) {
    return SplashState(
      status: status ?? this.status,
      adsLoaded: adsLoaded ?? this.adsLoaded,
      minTimeElapsed: minTimeElapsed ?? this.minTimeElapsed,
      loadingMessage: loadingMessage ?? this.loadingMessage,
    );
  }
}
