import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musitory/components/background_container.dart';
import 'package:musitory/components/lastplay.dart';
import 'package:musitory/components/my_appbar.dart';
import 'package:musitory/components/my_drawer.dart';
import 'package:musitory/components/song_avatar.dart';
import 'package:musitory/database/database_client.dart';
import 'package:musitory/pages/now_playing.dart';


class ListSongs extends StatefulWidget {
  final DatabaseClient db;
  final int mode;

  // mode 1 = recent, 2 - top, 3 -fav

  ListSongs(this.db, this.mode);

  @override
  _ListSongsState createState() => _ListSongsState();
}

class _ListSongsState extends State<ListSongs> {
  List<Song> songs;
  IconData icon = Icons.favorite;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initSongs();
  }

  void initSongs() async {
    switch (widget.mode) {
      case 1:
        songs = await widget.db.fetchRecentSong();
        icon = FontAwesomeIcons.lastfm;
        break;
      case 2:
        songs = await widget.db.fetchTopSong();
        icon = FontAwesomeIcons.chartLine;
        break;
      case 3:
        songs = await widget.db.fetchFavSong();
        icon = FontAwesomeIcons.solidHeart;
        break;
      default:
        break;
    }
    setState(() {
      isLoading = false;
    });
  }

  String getTitle(int mode) {
    switch (mode) {
      case 1:
        return "Recently played";
        break;
      case 2:
        return "Top tracks";
        break;
      case 3:
        return "Favourites";
        break;
      default:
        return null;
    }
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: MyDrawer(),
      body: Stack(
        children: <Widget>[
          BackgroundContainer(
            expandedIcon: icon,
          ),
          Container(
            margin: EdgeInsets.only(top: 100),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: songs.length == null ? 0 : songs.length,
                    itemBuilder: (context, i) => Column(
                      children: <Widget>[
                        Divider(height: 8),
                        ListTile(
                          leading: Hero(
                            tag: songs[i].id,
                            child: avatar(
                                context, getImage(songs[i]), songs[i].title),
                          ),
                          title: Text(
                            songs[i].title,
                            maxLines: 1,
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Text(
                            songs[i].artist,
                            maxLines: 1,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          trailing: widget.mode == 2
                              ? Text(
                                  (i + 1).toString(),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                )
                              : Text(
                                  Duration(milliseconds: songs[i].duration)
                                      .toString()
                                      .split('.')
                                      .first,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                          onTap: () {
                            MyQueue.songs = songs;
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return NowPlaying(widget.db, MyQueue.songs, i, 0);
                            }));
                          },
                        ),
                      ],
                    ),
                  ),
          ),
          SafeArea(
            child: MyAppBar(
                scaffoldState: widget.mode == 3 ? _key : null,
                toPop: widget.mode == 3 ? false : true,
                title: getTitle(widget.mode)),
          )
        ],
      ),
    );
  }
}
