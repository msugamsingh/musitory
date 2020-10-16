import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musitory/components/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vector_math/vector_math.dart' show radians;

class RadialMenu extends StatefulWidget {
  @override
  _RadialMenuState createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 900), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return RadialAnimation(controller: controller);
  }
}

class RadialAnimation extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> scale;
  final Animation<double> translation;
  final Animation<double> rotation;

  RadialAnimation({this.controller})
      : scale = Tween<double>(
          begin: 1.5,
          end: 0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutCubic,
          ),
        ),
        translation = Tween<double>(
          begin: 0,
          end: 80,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutCubic,
          ),
        ),
        rotation = Tween<double>(
          begin: 0,
          end: 360,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.0,
              1,
              curve: Curves.easeOutCubic,
            ),
          ),
        );

  _close() => controller.reverse();

  _open() => controller.forward();

  _buildButton(double angle, BuildContext context,
      {Color color, IconData icon, String heroTag, Function onClick}) {
    final double rad = radians(angle);
    return Transform(
      transform: Matrix4.identity()
        ..translate(
          (translation.value) * cos(rad),
          (translation.value) * sin(rad),
        ),
      child: FloatingActionButton(
        heroTag: heroTag,
        child: Icon(icon),
        backgroundColor: color,
        onPressed: onClick,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, builder) {
        return Transform.rotate(
          angle: radians(rotation.value),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              _buildButton(0, context,
                  color: Colors.pink,
                  icon: FontAwesomeIcons.instagram,
                  heroTag: 'insta', onClick: () {
                launchUrl('https://www.instagram.com/forolinc');
              }),
              _buildButton(90, context,
                  color: Colors.indigo,
                  icon: FontAwesomeIcons.facebook,
                  heroTag: 'guest', onClick: () {
                launchUrl('https://www.facebook.com/forolinc');
              }),
              _buildButton(180, context,
                  color: Colors.lightBlueAccent,
                  icon: FontAwesomeIcons.twitter,
                  heroTag: 'phone', onClick: () {
                launchUrl('https://www.twitter.com/MSugamSingh');
              }),
              _buildButton(270, context,
                  color: Colors.redAccent,
                  icon: Icons.email,
                  heroTag: 'email', onClick: () {
                launchUrl("mailto:forolinc@gmail.com");
              }),
              Transform.scale(
                scale: scale.value - 1, // -1 = 1 in scale
                child: FloatingActionButton(
                  heroTag: 'close',
                  child: Icon(FontAwesomeIcons.timesCircle),
                  onPressed: _close,
                ),
              ),
              Transform.scale(
                scale: scale.value,
                child: FloatingActionButton(
                  heroTag: 'open',
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.touch_app,
                    color: mainColor,
                  ),
                  onPressed: _open,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not open';
    }
  }
}
