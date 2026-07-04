import 'dart:typed_data';

import 'selfie_capture_service_mobile.dart'
    if (dart.library.html) 'selfie_capture_service_web.dart';

class CapturedSelfie {
  CapturedSelfie({
    required this.bytes,
    required this.filename,
  });

  final Uint8List bytes;
  final String filename;
}

abstract class SelfieCaptureService {
  Future<CapturedSelfie?> capture();

  factory SelfieCaptureService() => createSelfieCaptureServiceImpl();
}
