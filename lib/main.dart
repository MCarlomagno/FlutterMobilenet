import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

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
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  String firstPrediction = "";
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.veryHigh,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    _initializeControllerFuture.then((value) {
      onLoadModel();
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<String> loadModel() async {
    return Tflite.loadModel(
      model: "assets/mobilenet_v1_1.0_224.tflite",
      labels: "assets/labels.txt",
    );
  }

  onLoadModel() async {
    try {
      String res = await loadModel();
      print(res);
    } catch (e) {
      print('error while model loading');
      print(e);
    }
  }

  startPredictions() {
    try {
      _controller.startImageStream((img) async {
        try {
          var recognitions = await Tflite.runModelOnFrame(
            bytesList: img.planes.map((plane) {
              return plane.bytes;
            }).toList(), // required
            imageHeight: img.height,
            imageWidth: img.width,
          );
          if (recognitions.isNotEmpty) {
            setState(() {
              firstPrediction = recognitions[0].toString();
            });
          }
        } catch (e) {
          print('error while running model with current frame');
          print(e);
        }
      });
    } catch (e) {
      print('error while streaming camera image');
      print(e);
    }
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

            final size = MediaQuery.of(context).size.width;

            return Stack(
              children: <Widget>[
                Transform.scale(
                  scale: 1.0,
                  child: AspectRatio(
                    aspectRatio: MediaQuery.of(context).size.aspectRatio,
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Container(
                          width: size,
                          height: size / _controller.value.aspectRatio,
                          child: Stack(
                            children: <Widget>[
                              CameraPreview(_controller),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(child: Text(firstPrediction))
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startPredictions,
        child: Icon(Icons.play_arrow),
        backgroundColor: Colors.white,
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.camera_alt),
      //   // Provide an onPressed callback.
      //   onPressed: () async {
      //     // Take the Picture in a try / catch block. If anything goes wrong,
      //     // catch the error.
      //     try {
      //       // Ensure that the camera is initialized.
      //       await _initializeControllerFuture;

      //       // Construct the path where the image should be saved using the
      //       // pattern package.
      //       final path = join(
      //         // Store the picture in the temp directory.
      //         // Find the temp directory using the `path_provider` plugin.
      //         (await getTemporaryDirectory()).path,
      //         '${DateTime.now()}.png',
      //       );

      //       // Attempt to take a picture and log where it's been saved.
      //       await _controller.takePicture(path);

      //       // If the picture was taken, display it on a new screen.
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => DisplayPictureScreen(imagePath: path),
      //         ),
      //       );
      //     } catch (e) {
      //       // If an error occurs, log the error to the console.
      //       print(e);
      //     }
      //   },
      // ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
