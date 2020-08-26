import 'package:FlutterMobilenet/services/camera-service.dart';
import 'package:FlutterMobilenet/services/tensorflow-service.dart';
import 'package:FlutterMobilenet/widgets/camera-button.dart';
import 'package:FlutterMobilenet/widgets/camera-frame.dart';
import 'package:FlutterMobilenet/widgets/prediction.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
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
        startPredictions();
      });
    } else {
      await _tensorflowService.loadModel();
      startPredictions();
    }
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
    var wavesHeight = 1 - 310 / MediaQuery.of(context).size.height;

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
                // CameraFrame(),

                // test
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: WaveWidget(
                      config: CustomConfig(
                        colors: [Color(0xFFFF00FF), Color(0xFFFF00FF), Color(0xFFFF00FF), Color(0xFFFF00FF)],
                        durations: [6000, 12000, 24000, 48000],
                        heightPercentages: [wavesHeight, wavesHeight, wavesHeight, wavesHeight],
                        blur: MaskFilter.blur(BlurStyle.outer, 5.0),
                      ),
                      backgroundColor: Colors.transparent,
                      size: Size(double.infinity, double.infinity),
                      waveAmplitude: 5.0,
                    ),
                  ),
                ),

                // shows the camera button
                // CameraButton(
                //   onToggle: onToggle,
                //   ripplesAnimationController: _ripplesAnimationcontroller,
                // ),

                // shows the predictions on the bottom
                Prediction(
                  ready: true,
                  // onEndAnimation: onEndAnimation,
                  // isPredictionsOpened: isPredictionsOpened,
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      // floatingActionButton: animationFinished && isPredictionsOpened
      //     ? Padding(
      //         padding: EdgeInsets.only(bottom: 155),
      //         child: FloatingActionButton(
      //             backgroundColor: Color(0xFFFF00FF),
      //             child: Icon(
      //               Icons.stop,
      //               color: Colors.white,
      //             ),
      //             onPressed: () {
      //               onToggle();
      //             }),
      //       )
      //     : Container(),
    );
  }

  // onToggle() {
  //   setState(() {
  //     animationFinished = false;
  //     isPredictionsOpened = !isPredictionsOpened;
  //   });
  // }

  // onEndAnimation() {
  //   if (isPredictionsOpened) {
  //     startPredictions();
  //   }

  //   setState(() {
  //     animationFinished = true;
  //   });
  // }

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
