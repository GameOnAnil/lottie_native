import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lottie_controller.dart';

const viewType = 'de.lotum/lottie_native';

typedef LottieViewCreatedCallback = void Function(LottieController controller);

class LottieView extends StatefulWidget {
  LottieView.fromURL({
    this.onViewCreated,
    required this.url,
    Key? key,
    this.loop = true,
    this.autoPlay = true,
    this.reverse = false,
  })  : filePath = null,
        json = null,
        super(key: key);

  LottieView.fromAsset({
    Key? key,
    this.onViewCreated,
    required this.filePath,
    this.loop = true,
    this.autoPlay = true,
    this.reverse = false,
  })  : url = null,
        json = null,
        super(key: key);

  LottieView.fromJson({
    Key? key,
    this.onViewCreated,
    required this.json,
    this.loop = true,
    this.autoPlay = true,
    this.reverse = false,
  })  : url = null,
        filePath = null,
        super(key: key);

  final bool loop;
  final bool autoPlay;
  final bool reverse;
  final String? url;
  final String? filePath;
  final String? json;

  final LottieViewCreatedCallback? onViewCreated;

  @override
  _LottieViewState createState() => _LottieViewState();
}

class _LottieViewState extends State<LottieView> {
  LottieController? _controller;

  @override
  Widget build(BuildContext context) {
    final creationParams = {
      "url": widget.url,
      "filePath": widget.filePath,
      "json": widget.json,
      "loop": widget.loop,
      "reverse": widget.reverse,
      "autoPlay": widget.autoPlay,
    };

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: viewType,
          creationParams: creationParams,
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
        );

      case TargetPlatform.iOS:
        return UiKitView(
          viewType: viewType,
          creationParams: creationParams,
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
        );

      default:
        return Text(
          '$defaultTargetPlatform is not yet supported by this plugin',
        );
    }
  }

  Future<void> onPlatformViewCreated(int id) async {
    _controller = LottieController(id);
    widget.onViewCreated?.call(_controller!);
  }

  @override
  void dispose() {
    // Clean up the controller and associated resources
    _controller?.dispose(); // You must implement this in LottieController
    super.dispose();
  }
}
