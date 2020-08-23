import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  CameraScreen({Key key, @required this.controller}) : super(key: key);
  final CameraController controller;
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;

    return Container(
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.center, colors: [Colors.black, Colors.transparent])
              .createShader(Rect.fromLTRB(0, 0, rect.width, rect.height / 4));
        },
        blendMode: BlendMode.darken,
        child: Transform.scale(
          scale: 1.0,
          child: AspectRatio(
            aspectRatio: MediaQuery.of(context).size.aspectRatio,
            child: OverflowBox(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Container(
                  width: size,
                  height: size / widget.controller.value.aspectRatio,
                  child: Stack(
                    children: <Widget>[
                      CameraPreview(widget.controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
