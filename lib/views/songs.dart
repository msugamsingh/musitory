import 'dart:math';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musitory/components/background_container.dart';
import 'package:musitory/components/constants.dart';
import 'package:musitory/components/lastplay.dart';
import 'package:musitory/components/my_appbar.dart';
import 'package:musitory/components/my_drawer.dart';
import 'package:musitory/components/song_avatar.dart';
import 'package:musitory/database/database_client.dart';
import 'package:musitory/music_home.dart';
import 'package:musitory/pages/material_search.dart';
import 'package:musitory/pages/now_playing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Songs extends StatefulWidget {
  final DatabaseClient db;

  Songs(this.db);

  @override
  _SongsState createState() => _SongsState();
}

class _SongsState extends State<Songs> {
  List<Song> songs;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initSongs();
  }

  void initSongs() async {
    songs = await widget.db.fetchSongs();
    sortSongs();
    setState(() {
      isLoading = false;
    });
  }

  sortSongs() async {
    var pref = await SharedPreferences.getInstance();
    int sort = pref.getInt('sort') ?? 1;
    if (sort == 2) {
      songs.sort((a, b) => a.duration.compareTo(b.duration));
    } else if (sort == 1) {
      songs.sort((a, b) => a.title.compareTo(b.title));
    } else if (sort == 3) {
      songs.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sort == 4) {
      songs.sort((a, b) => b.duration.compareTo(a.duration));
    } else if (sort == 5) {
      songs.sort((a, b) => a.rating.compareTo(b.rating));
    }
  }

  final GlobalKey<ScaffoldState> _songsScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _songsScaffoldKey,
      drawer: MyDrawer(),
      body: Stack(
        children: <Widget>[
          BackgroundContainer(expandedIcon: FontAwesomeIcons.headphonesAlt),
          Container(
            margin: EdgeInsets.only(top: 90),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: <Widget>[
//                      TODO
                      Container(
                        padding: EdgeInsets.only(bottom: 4),
                        height: 42,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            IconButton(
                              tooltip: 'random',
                              icon: Icon(Icons.shuffle),
                              onPressed: () {
                                MyQueue.songs = songs;
                                Navigator.of(context).push(
                                    new MaterialPageRoute(builder: (context) {
                                  return new NowPlaying(
                                      widget.db,
                                      songs,
                                      new Random().nextInt(songs.length),
                                      0); //TODO randoms
                                }));
                              },
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return SearchSong(widget.db, songs);
                                }));
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.grey[300]
                                      : Colors.blueGrey[700],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Search',
                                            style: TextStyle(
                                                fontFamily: 'lob',
                                                color: Colors.grey)),
                                        Icon(Icons.search, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            PopupMenuButton(
                              elevation: 24,
                              tooltip: 'sort',
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey[50]
                                  : Colors.blueGrey[900],
                              onSelected: (val) async {
                                var pref = await SharedPreferences.getInstance();
                                pref.setBool('shuffle', false); // TODO check this also
                                if (val == 1) {
                                  pref.setInt('sort', 1);
                                  setState(() {
                                    songs.sort(
                                        (a, b) => a.title.compareTo(b.title));
                                  });
                                } else if (val == 2) {
                                  pref.setInt('sort', 2);
                                  setState(() {
                                    songs.sort((a, b) =>
                                        a.duration.compareTo(b.duration));
                                  });
                                } else if (val == 3) {
                                  pref.setInt('sort', 3);
                                  setState(() {
                                    songs.sort(
                                        (a, b) => b.rating.compareTo(a.rating));
                                  });
                                } else if (val == 4) {
                                  pref.setInt('sort', 4);
                                  setState(() {
                                    songs.sort((a, b) =>
                                        b.duration.compareTo(a.duration));
                                  });
                                } else if (val == 5) {
                                  pref.setInt('sort', 5);
                                  setState(() {
                                    songs.sort(
                                        (a, b) => a.rating.compareTo(b.rating));
                                  });
                                }
                              },
                              icon: Icon(Icons.sort),
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    value: 1,
                                    child: Text('A-Z'),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child: Text('Duration'),
                                  ),
                                  PopupMenuItem(
                                    value: 3,
                                    child: Text('Rating'),
                                  ),
                                  PopupMenuItem(
                                    value: 4,
                                    child: Text('Duration (Desc.)'),
                                  ),
                                  PopupMenuItem(
                                    value: 5,
                                    child: Text('Rating (Asc.)'),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: songs.length,
                          itemBuilder: (context, i) {
//                            var r = await widget.db.fetchRatingsFromSecond(songs[i].id);  TODO cud you make this possible
                          var r = songs[i].rating;
                            return Column(
                              children: <Widget>[
                                Divider(
                                  height: 8,
                                  indent: 60,
                                  endIndent: 60,
                                ),
                                Stack(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Hero(
                                        tag: songs[i].id,
                                        child: avatar(context,
                                            getImage(songs[i]), songs[i].title),
                                      ),
                                      title: Text(
                                        songs[i].title,
                                        maxLines: 1,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      subtitle: new Text(
                                        songs[i].artist,
                                        maxLines: 1,
                                        style: new TextStyle(
                                            fontSize: 12.0, color: Colors.grey),
                                      ),
                                      trailing: Text(
                                        Duration(
                                                milliseconds: songs[i].duration)
                                            .toString()
                                            .split('.')
                                            .first,
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      onTap: () {
                                        MyQueue.songs = songs;
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                              // Todo check this else return the 0th one.
                                          return MyQueue.index == i
                                              ? NowPlaying(widget.db,
                                                  MyQueue.songs, i, 1)
                                              : NowPlaying(widget.db,
                                                  MyQueue.songs, i, 0);
                                        }));
                                      },
//                                      onLongPress: () {
//                                        setFav(songs[i]);
//                                      },
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 12,
                                      child: Container(
                                        child: FutureBuilder(
                                          initialData: 0,
                                          future: fetchRatingForSong(songs[i].id),
                                          builder: (context, snap) {
                                            return Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Icon(
                                                    snap.data == 0
                                                        ? Icons.star_border
                                                        : Icons.star,
                                                    color: acc),
                                                Icon(
                                                    snap.data == 2 || snap.data == 3
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: acc),
                                                Icon(
                                                    snap.data == 3
                                                        ? Icons.star
                                                        : Icons.star_border,
                                                    color: acc),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          SafeArea(
            child: MyAppBar(
              scaffoldState: _songsScaffoldKey,
              title: 'Songs',
              actionIcon: Icons.refresh,
              hasAction: true,
              onActionPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MusicHome();
                }));
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<int> fetchRatingForSong(int songId) async {
    return await widget.db.fetchRatingsFromSecond(songId) ?? 0;
  }

//  Future<void> setFav(Song song) {
//    showDialog(
//      context: context,
//      child: new AlertDialog(
//        title: new Text('Add this to favourites?'),
//        content: new Text(song.title),
//        actions: <Widget>[
//          new FlatButton(
//            onPressed: () => Navigator.of(context).pop(false),
//            child: new Text(
//              'No',
//            ),
//          ),
//          new FlatButton(
//            onPressed: () async {
//              await widget.db.favSong(song);
//
//              Navigator.of(context).pop();
//            },
//            child: new Text('Yes'),
//          ),
//        ],
//      ),
//    );
//  }


/*
                                    Positioned(
                                      bottom: 0,
                                      right: 12,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                                r == 0
                                                    ? Icons.star_border
                                                    : Icons.star,
                                                color: acc),
                                            Icon(
                                                r == 2 || r == 3
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: acc),
                                            Icon(
                                                r == 3
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: acc),
                                          ],
                                        ),
                                      ),
                                    ),*/
}
