import 'dart:async';

import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

// singleton class used as a service
class TensorflowService {
  // singleton boilerplate
  static final TensorflowService _tensorflowService = TensorflowService._internal();

  factory TensorflowService() {
    return _tensorflowService;
  }
  // singleton boilerplate
  TensorflowService._internal();

  StreamController<List<dynamic>> _predictionController = StreamController();
  Stream get predictionStream => this._predictionController.stream;

  bool _modelLoaded = false;

  Future<void> loadModel() async {
    try {
      this._predictionController.add(null);
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
        numResults: 3,
      );
      // shows predictions on screen
      if (predictions.isNotEmpty) {
        print(predictions[0].toString());
        if (this._predictionController.isClosed) {
          // restart if was closed
          this._predictionController = StreamController();
        }
        // notify to listeners
        this._predictionController.add(predictions);
      }
    }
  }

  Future<void> stopPredictions() async {
    if (!this._predictionController.isClosed) {
      this._predictionController.add(null);
      this._predictionController.close();
    }
  }

  void dispose() async {
    this._predictionController.close();
  }
}
