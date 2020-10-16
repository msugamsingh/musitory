import 'package:flutter/material.dart';
import 'package:koukicons/music.dart';
import 'package:musitory/components/constants.dart';
import 'package:musitory/components/musitory_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:musitory/components/my_appbar.dart';
import 'package:musitory/components/radial_menu.dart';

class About extends StatelessWidget {
  static const id = 'about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: Theme.of(context).brightness == Brightness.light
                    ? LinearGradient(
                        colors: [
                          Colors.grey[50],
                          Colors.grey[100],
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      )
                    : null,
                color: Theme.of(context).brightness == Brightness.light
                    ? null
                    : Colors.blueGrey[900],
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                  ),
                  Expanded(
                      child: Container(
                          child: KoukiconsMusic(
                    height: MediaQuery.of(context).size.height,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[200]
                        : Colors.blueGrey[700],
                  ))),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 70),
                  child: Column(
                    children: <Widget>[
                      SizedBox(width: double.infinity),
                      BigMusitoryIcon(),
                      Text('Musitory', style: welcomeMusitoryTitleStyle),
                      SizedBox(height: 10),
                      Text(
                        version,
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 18,
                            fontFamily: 'lob'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: RadialMenu(),
                  ),
                ),
                SizedBox(height: 20),
//                Container(
//                  margin: EdgeInsets.only(bottom: 50),
//                  child: Transform.rotate(
//                    angle: -math.pi /12,
//                    child: Text(
//                      "Sugam Singh.",
//                      style: TextStyle(
//                          color: Colors.grey[700],
//                          fontSize: 24,
//                          fontFamily: 'sign'),
//                    ),
//                  ),
//                ),
                Text(
                  'Made with ❤️ by Sugam Singh',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[700], fontSize: 18, fontFamily: 'lob'),
                ),
                SizedBox(height: 20),
              ],
            ),
            MyAppBar(toPop: true, title: 'About'),
          ],
        ),
      ),
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
