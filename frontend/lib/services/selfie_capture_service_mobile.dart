import 'package:image_picker/image_picker.dart';

import 'selfie_capture_service.dart';

class MobileSelfieCaptureService implements SelfieCaptureService {
  MobileSelfieCaptureService();

  final ImagePicker _picker = ImagePicker();

  @override
  Future<CapturedSelfie?> capture() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 75,
      maxWidth: 1080,
      maxHeight: 1920,
    );

    if (image == null) return null;

    final bytes = await image.readAsBytes();
    return CapturedSelfie(
      bytes: bytes,
      filename: image.name.isNotEmpty ? image.name : 'selfie.jpg',
    );
  }
}

SelfieCaptureService createSelfieCaptureServiceImpl() => MobileSelfieCaptureService();
