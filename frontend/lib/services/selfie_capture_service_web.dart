// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'selfie_capture_service.dart';

class WebSelfieCaptureService implements SelfieCaptureService {
  WebSelfieCaptureService();

  @override
  Future<CapturedSelfie?> capture() async {
    final video = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.maxWidth = '100%'
      ..style.height = 'auto'
      ..style.objectFit = 'cover';

    final viewType = 'web-selfie-${DateTime.now().microsecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) => video);

    final stream = await html.window.navigator.mediaDevices
        ?.getUserMedia({'video': {'facingMode': 'user'}});
    if (stream == null) {
      Get.snackbar('Camera', 'Camera access is not available in this browser.');
      return null;
    }

    video.srcObject = stream;

    final snapshot = await Get.dialog<CapturedSelfie?>(
      AlertDialog(
        title: const Text('Capture Selfie'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 320,
                child: HtmlElementView(viewType: viewType),
              ),
              const SizedBox(height: 12),
              const Text('Use your front camera, then capture the selfie.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _stopStream(video);
              Get.back(result: null);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final canvas = html.CanvasElement(
                width: video.videoWidth,
                height: video.videoHeight,
              );
              final ctx = canvas.context2D;
              ctx.drawImage(video, 0, 0);
              final dataUrl = canvas.toDataUrl('image/jpeg', 0.85);
              final base64Data = dataUrl.split(',').last;
              final bytes = base64Decode(base64Data);
              _stopStream(video);
              Get.back(
                result: CapturedSelfie(
                  bytes: bytes,
                  filename: 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
                ),
              );
            },
            child: const Text('Capture'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    _stopStream(video);
    return snapshot;
  }

  void _stopStream(html.VideoElement video) {
    final stream = video.srcObject;
    if (stream is html.MediaStream) {
      for (final track in stream.getTracks()) {
        track.stop();
      }
    }
    video.srcObject = null;
  }
}

SelfieCaptureService createSelfieCaptureServiceImpl() => WebSelfieCaptureService();
