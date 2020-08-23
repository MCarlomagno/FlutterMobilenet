import 'dart:async';
import 'package:FlutterMobilenet/services/tensorflow-service.dart';
import 'package:flutter/material.dart';

class Prediction extends StatefulWidget {
  Prediction({Key key, @required this.ready, @required this.onEndAnimation, @required this.isPredictionsOpened})
      : super(key: key);

  // indicates if the animation is finished to start streaming (for better performance)
  final bool ready;

  // function that notify to parent widget when the animation is finished
  final Function onEndAnimation;

  final bool isPredictionsOpened;

  @override
  _PredictionState createState() => _PredictionState();
}

// to track the subscription state during the lifecicle of the component
enum SubscriptionState { Active, Done }

class _PredictionState extends State<Prediction> {
  // current list of predictions
  List<dynamic> _currentPrediction = [];

  // listens the changes in tensorflow predictions
  StreamSubscription _streamSubscription;

  // tensorflow service injection
  TensorflowService _tensorflowService = TensorflowService();

  @override
  void initState() {
    super.initState();

    // starts the streaming to tensorflow results
    _startPredictionStreaming();
  }

  _startPredictionStreaming() {
    if (_streamSubscription == null) {
      _streamSubscription = _tensorflowService.predictionStream.listen((prediction) {
        if (prediction != null) {
          // rebuilds the screen with the new predictions
          setState(() {
            _currentPrediction = prediction;
          });
        } else {
          _currentPrediction = [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        width: !widget.isPredictionsOpened ? 0 : MediaQuery.of(context).size.width,
        height: !widget.isPredictionsOpened ? 0 : 200,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF120320),
                ),
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: widget.ready
                      ? <Widget>[
                          // shows prediction title
                          _titleWidget(),

                          // shows predictions list
                          _contentWidget(),
                        ]
                      : <Widget>[],
                ),
              ),
            ),
          ],
        ),
        onEnd: () => widget.onEndAnimation(),
      ),
    );
  }

  Widget _titleWidget() {
    return Container(
      padding: EdgeInsets.only(top: 15, left: 20, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Predictions",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  Widget _contentWidget() {
    var _width = MediaQuery.of(context).size.width;
    var _padding = 20.0;
    var _labelWitdth = 150.0;
    var _labelConfidence = 30.0;
    var _barWitdth = _width - _labelWitdth - _labelConfidence - _padding * 2.0;

    if (_currentPrediction.length > 0) {
      return Container(
        height: 150,
        child: ListView.builder(
          itemCount: _currentPrediction.length,
          itemBuilder: (context, index) {
            if (_currentPrediction.length > index) {
              return Container(
                height: 40,
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: _padding, right: _padding),
                      width: _labelWitdth,
                      child: Text(
                        _currentPrediction[index]['label'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: _barWitdth,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        value: _currentPrediction[index]['confidence'],
                      ),
                    ),
                    Container(
                      width: _labelConfidence,
                      child: Text(
                        _currentPrediction[index]['confidence'].toStringAsFixed(2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      );
    } else {
      return Text('');
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
