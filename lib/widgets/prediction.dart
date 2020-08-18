import 'dart:async';

import 'package:FlutterMobilenet/services/tensorflow-service.dart';
import 'package:flutter/material.dart';

class Prediction extends StatefulWidget {
  Prediction({Key key}) : super(key: key);

  @override
  _PredictionState createState() => _PredictionState();
}

class _PredictionState extends State<Prediction> {
  String _currentPrediction = "";
  StreamSubscription _streamSubscription;

  TensorflowService _tensorflowService = TensorflowService();

  @override
  void initState() {
    super.initState();
    startSubscription();
  }

  stopSubscription() {
    _streamSubscription.pause();
  }

  startSubscription() {
    _streamSubscription = _tensorflowService.predictionStream.listen((prediction) {
      if (prediction != null) {
        setState(() {
          _currentPrediction = prediction;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Prediction"),
          Text(_currentPrediction),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
