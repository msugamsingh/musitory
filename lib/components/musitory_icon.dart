import 'package:flutter/material.dart';
import 'package:koukicons/music.dart';
import 'package:koukicons/mute2.dart';

class BigMusitoryIcon extends StatelessWidget {
  const BigMusitoryIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(80),
        color: Colors.white70,
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                BoxShadow(
                    color: Colors.grey[300],
                    offset: Offset(10, 18),
                    blurRadius: 30),
                BoxShadow(
                    color: Colors.grey[100],
                    offset: Offset(-10, -18),
                    blurRadius: 30)
              ]
            : [
                BoxShadow(
                    color: Colors.grey[700],
                    offset: Offset(10, 18),
                    blurRadius: 30),
                BoxShadow(
                    color: Colors.grey[800],
                    offset: Offset(-10, -18),
                    blurRadius: 30)
              ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white70,
        minRadius: 60,
        maxRadius: 80,
        child: KoukiconsMusic(height: 80, width: 80),
      ),
    );
  }
}

class NoMusicIcon extends StatelessWidget {
  const NoMusicIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(80),
          color: Colors.white70,
          boxShadow: [
            BoxShadow(
                color: Colors.grey[300],
                offset: Offset(10, 18),
                blurRadius: 30),
            BoxShadow(
                color: Colors.grey[100],
                offset: Offset(-10, -18),
                blurRadius: 30)
          ]),
      child: CircleAvatar(
        backgroundColor: Colors.white70,
        minRadius: 60,
        maxRadius: 80,
        child: KoukiconsMute2(),
      ),
    );
  }
}
