import 'dart:async';

import 'package:flutter/services.dart';

import 'lot_values/lot_value.dart';

enum LottieAnimationState {
  loaded,
  started,
  finished,
  cancelled,
}

class LottieController {
  late final int id;
  late final MethodChannel _channel;
  late final EventChannel _stateChannel;

  Stream<LottieAnimationState>? _stateStream;
  Stream<bool>? _playFinishedStream;

  LottieController(this.id) {
    _channel = MethodChannel('de.lotum/lottie_native_$id');
    _stateChannel = EventChannel('de.lotum/lottie_native_state_$id');
  }

  // Main cleanup method
  Future<void> dispose() async {
    // try {
    //   // await stop(); // Optional: stop animation
    //   await _channel.invokeMethod('clearCache');
    // } catch (e) {
    //   // Log error or ignore if already disposed
    // }
  }

  Future<void> setLoopAnimation(bool loop) =>
      _channel.invokeMethod('setLoopAnimation', {"loop": loop});

  Future<void> setAutoReverseAnimation(bool reverse) =>
      _channel.invokeMethod('setAutoReverseAnimation', {"reverse": reverse});

  Future<void> play() => _channel.invokeMethod('play');

  Future<void> playWithProgress({
    double? fromProgress,
    required double toProgress,
  }) =>
      _channel.invokeMethod('playWithProgress', {
        "fromProgress": fromProgress,
        "toProgress": toProgress,
      });

  Future<void> playWithFrames({int? fromFrame, required int toFrame}) =>
      _channel.invokeMethod('playWithFrames', {
        "fromFrame": fromFrame,
        "toFrame": toFrame,
      });

  Future<void> stop() => _channel.invokeMethod('stop');

  Future<void> pause() => _channel.invokeMethod('pause');

  Future<void> resume() => _channel.invokeMethod('resume');

  Future<void> setAnimationSpeed(double speed) =>
      _channel.invokeMethod('setAnimationSpeed', {
        "speed": speed.clamp(0.0, 1.0),
      });

  Future<void> setAnimationProgress(double progress) =>
      _channel.invokeMethod('setAnimationProgress', {
        "progress": progress.clamp(0.0, 1.0),
      });

  Future<void> setProgressWithFrame(int frame) =>
      _channel.invokeMethod('setProgressWithFrame', {"frame": frame});

  Future<double?> getAnimationDuration() =>
      _channel.invokeMethod<double>('getAnimationDuration');

  Future<double?> getAnimationProgress() =>
      _channel.invokeMethod<double>('getAnimationProgress');

  Future<double?> getAnimationSpeed() =>
      _channel.invokeMethod<double>('getAnimationSpeed');

  Future<bool?> isAnimationPlaying() =>
      _channel.invokeMethod<bool>('isAnimationPlaying');

  Future<bool?> getLoopAnimation() =>
      _channel.invokeMethod<bool>('getLoopAnimation');

  Future<bool?> getAutoReverseAnimation() =>
      _channel.invokeMethod<bool>('getAutoReverseAnimation');

  Future<void> setValue({
    required LOTValue value,
    required String keyPath,
  }) =>
      _channel.invokeMethod('setValue', {
        "value": value.value,
        "type": value.type,
        "keyPath": keyPath,
      });

  // Lazy stream getter for animation state
  Stream<LottieAnimationState> get onStateChanged {
    return _stateStream ??= _stateChannel
        .receiveBroadcastStream()
        .map((value) => LottieAnimationState.values.byName(value));
  }

  Stream<bool> get onPlayFinished {
    return _playFinishedStream ??= onStateChanged
        .where((state) =>
            state == LottieAnimationState.finished ||
            state == LottieAnimationState.cancelled)
        .map((state) => state == LottieAnimationState.finished);
  }
}
