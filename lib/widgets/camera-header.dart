import 'package:flutter/material.dart';

class CameraHeader extends StatelessWidget {
  const CameraHeader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        minimum: EdgeInsets.only(top: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'FlutterMobilenet',
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
