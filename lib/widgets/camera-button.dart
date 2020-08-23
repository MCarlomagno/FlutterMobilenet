import 'package:flutter/material.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({Key key, @required this.onToggle, @required this.ripplesAnimationController}) : super(key: key);
  final Function onToggle;
  final AnimationController ripplesAnimationController;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Stack(
        overflow: Overflow.visible,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: 200,
            child: _buildRipples(),
          ),
          Container(
            height: 80,
            decoration: new BoxDecoration(
              border: Border.all(width: 3, color: Colors.white),
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
          ),
          InkWell(
            onTap: () => onToggle(),
            child: Container(
              height: 50,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF00FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRipples() {
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: ripplesAnimationController, curve: Curves.fastOutSlowIn),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            _buildContainer(150 * ripplesAnimationController.value),
          ],
        );
      },
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFF00FF).withOpacity(1 - ripplesAnimationController.value),
      ),
    );
  }
}
