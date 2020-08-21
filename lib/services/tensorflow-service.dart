import 'dart:async';

import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

class TensorflowService {
  static final TensorflowService _tensorflowService = TensorflowService._internal();

  factory TensorflowService() {
    return _tensorflowService;
  }

  TensorflowService._internal();

  StreamController<List<dynamic>> _predictionController = StreamController();
  Stream get predictionStream => _predictionController.stream;

  bool _modelLoaded = false;

  Future<void> loadModel() async {
    try {
      _predictionController.add(null);
      await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/labels.txt",
      );
      _modelLoaded = true;
    } catch (e) {
      print('error loading model');
      print(e);
    }
  }

  Future<void> runModel(CameraImage img) async {
    if (_modelLoaded) {
      List<dynamic> predictions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: img.height,
        imageWidth: img.width,
      );

      // shows predictions on screen
      if (predictions.isNotEmpty) {
        if (_predictionController.isClosed) {
          // restart if was closed
          _predictionController = StreamController();
        }
        // notify to listeners
        _predictionController.add(predictions);
      }
    }
  }

  Future<void> stopPredictions() async {
    _predictionController.add(null);
    await _predictionController.close();
  }

  void dispose() async {
    await stopPredictions();
  }
}
