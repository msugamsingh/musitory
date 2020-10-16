import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musitory/components/constants.dart';
import 'package:musitory/components/my_drawer.dart';
import 'package:musitory/database/database_client.dart';
import 'package:musitory/pages/list_songs.dart';
import 'package:musitory/pages/now_playing.dart';
import 'package:musitory/views/albums.dart';
import 'package:musitory/views/artists.dart';
import 'package:musitory/views/home.dart';
import 'package:musitory/views/songs.dart';
import 'components/lastplay.dart';

class MusicHome extends StatefulWidget {
  static const id = 'music_home';

  @override
  _MusicHomeState createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  int _currentIndex = 2;
  List<Song> songs;
  String title = 'Musitory';
  DatabaseClient db;
  bool isLoading = true;
  Song last;

  Widget _callPage(int i) {
    switch (i) {
      case 0:
        return Home(db);
      case 1:
        return Artists(db);
      case 2:
        return Songs(db);
      case 3:
        return Albums(db);
      case 4:
        return ListSongs(db, 3); // Favorites
        break;
      default:
        return Songs(db);
    }
  }

  @override
  void initState() {
    super.initState();
    getLast();
  }

  void getLast() async {
    db = DatabaseClient();
    await db.create();
    last = await db.fetchLastSong();
    songs = await db.fetchSongs();
    setState(() {
      songs = songs;
      isLoading = false;
    });
  }

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          buttonBackgroundColor: mainColor,
          height: 55,
          animationDuration: Duration(milliseconds: 600),
          animationCurve: Curves.easeOutCubic,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[300]
              : Color(0xff151515),
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[50]
              : Colors.blueGrey[900],
          items: <Widget>[
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(FontAwesomeIcons.home,
                    size: _currentIndex == 0 ? 28 : 24,
                    color: _currentIndex == 0 ? Colors.white : mainColor),
              ),
            ),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(FontAwesomeIcons.microphoneAlt,
                    size: _currentIndex == 1 ? 28 : 24,
                    color: _currentIndex == 1 ? Colors.white : mainColor),
              ),
            ),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(FontAwesomeIcons.list,
                    size: _currentIndex == 2 ? 28 : 24,
                    color: _currentIndex == 2 ? Colors.white : mainColor),
              ),
            ),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(FontAwesomeIcons.compactDisc,
                    size: _currentIndex == 3 ? 28 : 24,
                    color: _currentIndex == 3 ? Colors.white : mainColor),
              ),
            ),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(FontAwesomeIcons.solidHeart,
                    size: _currentIndex == 4 ? 28 : 24,
                    color: _currentIndex == 4 ? Colors.white : mainColor),
              ),
            ),
          ],
          index: 2,
          onTap: (i) {
            setState(() {
              _currentIndex = i;
            });
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(FontAwesomeIcons.playCircle, color: Colors.white),
          onPressed: () async {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              if (MyQueue.songs == null) {
                List<Song> list = [];
                list.add(last);
                MyQueue.songs = list;
                return NowPlaying(db, list, 0, 0);
              } else
                return NowPlaying(db, MyQueue.songs, MyQueue.index, 1);
            }));
          },
        ),
        drawer: MyDrawer(),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : _callPage(_currentIndex),
      ),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Music will be stopped.'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(
              'No',
            ),
          ),
          new FlatButton(
            onPressed: () {
              MyQueue.player.stop();
              SystemNavigator.pop(animated: true);
            },
            child: new Text('Yes'),
          ),
        ],
      ),
    );
  }
}
 