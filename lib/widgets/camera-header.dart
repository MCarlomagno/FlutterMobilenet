import 'package:flutter/material.dart';

class CameraHeader extends StatelessWidget {
  const CameraHeader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        minimum: EdgeInsets.only(top: 45),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('assets/white_logo.png'),
              height: 40,
              width: 40,
            ),
          ],
        ),
      ),
    );
  }
}
