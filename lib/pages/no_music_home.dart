import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musitory/components/constants.dart';
import 'package:musitory/components/musitory_icon.dart';
import 'package:musitory/components/my_appbar.dart';

class NoMusicFound extends StatelessWidget {
  static const id = 'no_music_found';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[50],
                      Colors.grey[100],
//                  Colors.pink,
//                    Colors.purple
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                    ),
                    Expanded(
                        child: Icon(
                      FontAwesomeIcons.volumeMute,
                      color: Colors.grey[200],
                      size: MediaQuery.of(context).size.width - 40,
                    )),
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
                        NoMusicIcon(),
                        Text('Sorry!', style: welcomeMusitoryTitleStyle),
                        SizedBox(height: 10),
                        Text(
                          'No music found in your storage.',
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 18,
                              fontFamily: 'lob'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(28.0),
                    child: Text('Musitory!', style: welcomeMusitoryTitleStyle),
                  ),
                ),
              ),
              MyAppBar(title: 'No Music Found'),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    SystemNavigator.pop(animated: true);
  }
}
