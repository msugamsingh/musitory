import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:koukicons/music.dart';
import 'package:musitory/components/constants.dart';
import 'package:musitory/database/database_client.dart';

import '../music_home.dart';
import 'no_music_home.dart';

class SplashScreen extends StatefulWidget {
  static const id = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var db;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                mainColor,
                acc,
                Colors.grey[100],
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            )),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: double.infinity),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    color: Colors.white70,
                    boxShadow: [
                      BoxShadow(
                          color: mainColor.withOpacity(0.2),
                          offset: Offset(0, 20),
                          blurRadius: 50),
                      BoxShadow(
                          color: Colors.white12,
                          offset: Offset(0, -20),
                          blurRadius: 50)
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white70,
                  minRadius: 60,
                  maxRadius: 80,
                  child:
                      KoukiconsMusic(height: 80, width: 80, color: mainColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(40),
                child: Text('Musitory', style: welcomeMusitoryTitleStyle),
              ),
              SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: isLoading ? CircularProgressIndicator() : Container(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  loadSongs() async {
    setState(() {
      isLoading = true;
    });
    var db = DatabaseClient();
    await db.create();
    if (await db.alreadyLoaded()) {   //TODO by removing these codes the player will check for new songs every motherfucking time
      Navigator.popAndPushNamed(context, MusicHome.id);
    } else {
    var songs;
    try {
      songs = await MusicFinder.allSongs();
      List<Song> list = List.from(songs);
      if (list == null || list.length == 0) {
        Navigator.popAndPushNamed(context, NoMusicFound.id);
      } else {
        for (Song song in list) db.upsertSOng(song);
        if (!mounted) {
          return;
        }
        Navigator.popAndPushNamed(context, MusicHome.id);
      }
    } catch (e, st) {
      print(e);
      print(st);
    }
    }
  }
}
