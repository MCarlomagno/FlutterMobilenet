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

  StreamController<List<dynamic>> _recognitionController = StreamController();
  Stream get recognitionStream => this._recognitionController.stream;

  bool _modelLoaded = false;

  Future<void> loadModel() async {
    try {
      this._recognitionController.add(null);
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
      List<dynamic> recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: img.height,
        imageWidth: img.width,
        numResults: 3,
      );
      // shows recognitions on screen
      if (recognitions.isNotEmpty) {
        print(recognitions[0].toString());
        if (this._recognitionController.isClosed) {
          // restart if was closed
          this._recognitionController = StreamController();
        }
        // notify to listeners
        this._recognitionController.add(recognitions);
      }
    }
  }

  Future<void> stopRecognitions() async {
    if (!this._recognitionController.isClosed) {
      this._recognitionController.add(null);
      this._recognitionController.close();
    }
  }

  void dispose() async {
    this._recognitionController.close();
  }
}
