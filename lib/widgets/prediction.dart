import 'dart:async';

import 'package:FlutterMobilenet/services/tensorflow-service.dart';
import 'package:flutter/material.dart';

class Prediction extends StatefulWidget {
  Prediction({Key key}) : super(key: key);

  @override
  _PredictionState createState() => _PredictionState();
}

class _PredictionState extends State<Prediction> {
  List<dynamic> _currentPrediction = [];
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          color: Color(0xFF120320),
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[_titleWidget(), _contentWidget()],
          ),
        )
      ],
    );
  }

  Widget _titleWidget() {
    return Container(
      padding: EdgeInsets.only(top: 15, bottom: 10),
      child: Text(
        "Predictions",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
      ),
    );
  }

  Widget _contentWidget() {
    if (_currentPrediction.length > 0) {
      return Container(
        height: 100,
        child: ListView.builder(
          itemCount: _currentPrediction.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_currentPrediction[index]['label']),
              subtitle: Text(_currentPrediction[index]['confidence'].toString()),
            );
          },
        ),
      );
    } else {
      return Text('');
    }
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
