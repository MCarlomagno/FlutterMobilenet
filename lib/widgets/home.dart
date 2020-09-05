import 'package:FlutterMobilenet/services/camera-service.dart';
import 'package:FlutterMobilenet/services/tensorflow-service.dart';
import 'package:FlutterMobilenet/widgets/recognition.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'camera-header.dart';
import 'camera-screen.dart';

class Home extends StatefulWidget {
  final CameraDescription camera;

  const Home({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with TickerProviderStateMixin, WidgetsBindingObserver {
  // Services injection
  TensorflowService _tensorflowService = TensorflowService();
  CameraService _cameraService = CameraService();

  // future for camera initialization
  Future<void> _initializeControllerFuture;

  AppLifecycleState _appLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // starts camera and then loads the tensorflow model
    startUp();
  }

  Future startUp() async {
    if (!mounted) {
      return;
    }
    if (_initializeControllerFuture == null) {
      _initializeControllerFuture = _cameraService.startService(widget.camera).then((value) async {
        await _tensorflowService.loadModel();
        startRecognitions();
      });
    } else {
      await _tensorflowService.loadModel();
      startRecognitions();
    }
  }

  startRecognitions() async {
    try {
      // starts the camera stream on every frame and then uses it to recognize the result every 1 second
      _cameraService.startStreaming();
    } catch (e) {
      print('error streaming camera image');
      print(e);
    }
  }

  stopRecognitions() async {
    // closes the streams
    await _cameraService.stopImageStream();
    await _tensorflowService.stopRecognitions();
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
                // shows the camera preview
                CameraScreen(
                  controller: _cameraService.cameraController,
                ),

                // shows the header with the icon
                CameraHeader(),

                // shows the recognition on the bottom
                Recognition(
                  ready: true,
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (_appLifecycleState == AppLifecycleState.resumed) {
      // starts camera and then loads the tensorflow model
      startUp();
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraService.dispose();
    _tensorflowService.dispose();
    _initializeControllerFuture = null;
    super.dispose();
  }
}
