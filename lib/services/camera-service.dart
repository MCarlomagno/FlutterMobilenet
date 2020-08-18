import 'package:FlutterMobilenet/services/tensorflow-service.dart';
import 'package:camera/camera.dart';

class CameraService {
  static final CameraService _cameraService = CameraService._internal();

  factory CameraService() {
    return _cameraService;
  }

  CameraService._internal();

  TensorflowService _tensorflowService = TensorflowService();

  CameraController _cameraController;
  CameraController get cameraController => _cameraController;

  int frameFrecuencyInSeconds = 2;
  bool available = true;

  Future startService(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
      // Get a specific camera from the list of available cameras.
      cameraDescription,
      // Define the resolution to use.
      ResolutionPreset.veryHigh,
    );

    // Next, initialize the controller. This returns a Future.
    return _cameraController.initialize();
  }

  dispose() {
    _cameraController.dispose();
  }

  Future<void> startStreaming() async {
    _cameraController.startImageStream((img) async {
      try {
        if (available) {
          // Loads the model and recognizes frames
          available = false;
          await _tensorflowService.runModel(img);
          available = true;
        }
      } catch (e) {
        print('error running model with current frame');
        print(e);
      }
    });
  }

  Future stopImageStream() async {
    await this._cameraController.stopImageStream();
  }
}
