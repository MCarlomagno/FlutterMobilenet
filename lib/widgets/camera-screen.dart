import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({Key key, @required this.controller}) : super(key: key);

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;

    return Container(
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.transparent, Colors.black]
          ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height/2));
        },
        blendMode: BlendMode.dstIn,
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
                  height: size / controller.value.aspectRatio,
                  child: Stack(
                    children: <Widget>[
                      CameraPreview(controller),
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
}
