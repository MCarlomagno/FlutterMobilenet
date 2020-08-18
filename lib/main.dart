import 'dart:async';
import 'package:FlutterMobilenet/services/camera-service.dart';
import 'package:FlutterMobilenet/services/tensorflow-service.dart';
import 'package:FlutterMobilenet/widgets/prediction.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'widgets/camera-header.dart';
import 'widgets/camera-screen.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: Home(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class Home extends StatefulWidget {
  final CameraDescription camera;

  const Home({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  TensorflowService _tensorflowService = TensorflowService();
  CameraService _cameraService = CameraService();

  String firstPrediction = "";
  Future<void> _initializeControllerFuture;
  bool working = false;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _initializeControllerFuture = _cameraService.startService(widget.camera);

    _initializeControllerFuture.then((value) {
      _tensorflowService.loadModel().then((value) {
        startPredictions();
      });
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraService.dispose();
    _tensorflowService.dispose();
    super.dispose();
  }

  startPredictions() async {
    try {
      setState(() {
        working = true;
      });

      _cameraService.startStreaming();

    } catch (e) {
      print('error streaming camera image');
      print(e);
    }
  }

  stopPredictions() async {
    setState(() {
      working = false;
    });
    await _cameraService.stopImageStream();
    await _tensorflowService.stopPredictions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.

            return Stack(
              children: <Widget>[
                CameraScreen(
                  controller: _cameraService.cameraController,
                ),
                CameraHeader(),
                Prediction(),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: working ? stopPredictions : startPredictions,
      //   child: Icon(
      //     working ? Icons.stop : Icons.play_arrow,
      //     color: Color(0xFF880e4f),
      //   ),
      //   backgroundColor: Colors.white,
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
