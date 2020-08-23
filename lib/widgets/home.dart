import 'package:FlutterMobilenet/services/camera-service.dart';
import 'package:FlutterMobilenet/services/tensorflow-service.dart';
import 'package:FlutterMobilenet/widgets/camera-button.dart';
import 'package:FlutterMobilenet/widgets/camera-frame.dart';
import 'package:FlutterMobilenet/widgets/prediction.dart';
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

  // for ripples animation in camera button
  AnimationController _ripplesAnimationcontroller;

  // flag that represents if the predictions are showed
  bool isPredictionsOpened = false;

  // flag that represents if the animation opening and closing the predictions is running
  bool animationFinished = true;

  AppLifecycleState _appLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // starts button animation
    _buildRipplesAnimation();

    // starts camera and then loads the tensorflow model
    _initializeCamera().then((value) async => {await _tensorflowService.loadModel()});
  }

  _buildRipplesAnimation() {
    _ripplesAnimationcontroller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  Future _initializeCamera() async {
    _initializeControllerFuture = _cameraService.startService(widget.camera);
  }

  startPredictions() async {
    try {
      // starts the camera stream on every frame and then uses it to predict the result every 1 second
      _cameraService.startStreaming();
    } catch (e) {
      print('error streaming camera image');
      print(e);
    }
  }

  stopPredictions() async {
    // closes the streams
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

                // shows the camera preview
                CameraScreen(
                  controller: _cameraService.cameraController,
                ),

                // shows the header with the icon
                CameraHeader(),

                // shows the frame with the corners
                CameraFrame(),

                // shows the camera button
                CameraButton(
                  onToggle: onToggle,
                  ripplesAnimationController: _ripplesAnimationcontroller,
                ),

                // shows the predictions on the bottom
                Prediction(
                  ready: animationFinished,
                  onEndAnimation: onEndAnimation,
                  isPredictionsOpened: isPredictionsOpened,
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: animationFinished && isPredictionsOpened
          ? Padding(
              padding: EdgeInsets.only(bottom: 155),
              child: FloatingActionButton(
                  backgroundColor: Color(0xFFFF00FF),
                  child: Icon(
                    Icons.stop,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    onToggle();
                  }),
            )
          : Container(),
    );
  }

  onToggle() {
    setState(() {
      animationFinished = false;
      isPredictionsOpened = !isPredictionsOpened;
    });
  }

  onEndAnimation() {
    if (isPredictionsOpened) {
      startPredictions();
    }

    setState(() {
      animationFinished = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
    if (_appLifecycleState == AppLifecycleState.resumed) {
      // starts button animation
      _buildRipplesAnimation();

      // starts camera and then loads the tensorflow model
      _initializeCamera().then((value) async => {await _tensorflowService.loadModel()});
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
