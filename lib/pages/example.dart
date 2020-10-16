import 'package:flutter/material.dart';
import 'package:swipedetector/swipedetector.dart';

class EG extends StatefulWidget {
  @override
  _EGState createState() => _EGState();
}

class _EGState extends State<EG> {
  @override
  Widget build(BuildContext context) {
    return SwipeDetector(

      onSwipeLeft: () {
        print('next song');
      },
      onSwipeRight: () {
        print('prev song');
      },
    );
  }
}
