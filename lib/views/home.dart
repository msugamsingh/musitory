import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musitory/components/background_container.dart';
import 'package:musitory/components/constants.dart';
import 'package:musitory/components/lastplay.dart';
import 'package:musitory/components/my_drawer.dart';
import 'package:musitory/components/song_avatar.dart';
import 'package:musitory/database/database_client.dart';
import 'package:musitory/models/song_model.dart';
import 'package:musitory/pages/list_songs.dart';
import 'package:musitory/pages/material_search.dart';
import 'package:musitory/pages/now_playing.dart';
import 'package:scoped_model/scoped_model.dart';

class Home extends StatefulWidget {
  final DatabaseClient db;

  Home(this.db);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Song> albums, recents, songs;
  bool isLoading = true;
  Song last;
  Song top;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    albums = await widget.db.fetchRandomAlbum();
    last = await widget.db.fetchLastSong();
    songs = await widget.db.fetchSongs();
    recents = await widget.db.fetchRecentSong();
    recents.removeAt(0);
    top = await widget.db.fetchTopSong().then((item) => item[0]);
    ScopedModel.of<SongModel>(context, rebuildOnChange: true).init(widget.db);
    setState(() {
      isLoading = false;
    });
  }

  final GlobalKey<ScaffoldState> _homeScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _homeScaffoldKey,
      drawer: MyDrawer(),
      body: Stack(
        children: <Widget>[
          BackgroundContainer(),
          CustomScrollView(
            shrinkWrap: true,
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height / 2,
                floating: false,
                bottom: PreferredSize(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ScopedModelDescendant<SongModel>(builder: (context, child, model) {
                    return Text(model.song == null ? "" : model.song.title,
                      maxLines: 1,
                      style: TextStyle(fontFamily: 'pac'),);
                  },),
                ), preferredSize: Size(40, 40)),
                pinned: true,

                title: Text(
                  'Musitory',
                  style: TextStyle(fontFamily: 'pac'),
                ),
                leading: IconButton(
                  icon: Icon(CustomIcons.menu),
                  onPressed: () {
                    _homeScaffoldKey.currentState.openDrawer();
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return SearchSong(widget.db, songs);
                      }));
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ScopedModelDescendant<SongModel>(
                        builder: (context, child, model) {
                          return Hero(
                            tag: model.song == null ? "" : model.song.id,
                            child: GestureDetector(
                                child: model.song == null
                                    ? Image.asset('assets/images/back.png',
                                        fit: BoxFit.cover)
                                    : getImage(model.song) != null
                                        ? Image.file(getImage(model.song),
                                            fit: BoxFit.cover)
                                        : Image.asset('assets/images/back.png',
                                            fit: BoxFit.cover),
                                onTap: () async {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      if (MyQueue.songs == null) {
                                        List<Song> list = [];
                                        list.add(last);
                                        MyQueue.songs = list;
                                        return NowPlaying(widget.db, list, 0, 0);
                                      } else
                                        return NowPlaying(widget.db, MyQueue.songs,
                                            MyQueue.index, 1);
                                    },
                                  ));
                                }),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: !isLoading
                    ? SliverChildListDelegate([
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
//                            Row(
//                              children: <Widget>[
//                                Icon(Icons.play_circle_outline,
//                                    size: 50, color: mainColor),
//                                ScopedModelDescendant<SongModel>(
//                                  builder: (context, child, model) {
//                                    return Flexible(
//                                      child: RotateAnimatedTextKit(
//                                          text: model.song == null
//                                              ? [
//                                                  "One good thing about music, when it hits you, you feel no pain.",
//                                                  "Music is the strongest form of magic.",
//                                                  "Music is an outburst of the soul"
//                                                ]
//                                              : [
//                                                  model.song.title,
//                                                  model.song.artist,
//                                                  model.song.album
//                                                ],
//                                          textStyle: TextStyle(fontSize: 17),
//                                          textAlign: TextAlign.left,
//                                          alignment:
//                                              AlignmentDirectional.topStart),
//                                    );
//                                  },
//                                ),
//                              ],
//                            ),
                              ],
                            ),
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(8, 8, 0, 8),
                          child: Text(
                            'Playlists',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'pac',
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(FontAwesomeIcons.lastfm, color: mainColor),
                          title: Text('Recently Played'),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ListSongs(widget.db, 1);
                            }));
                          },
                        ),
                        ListTile(
                          leading:
                              Icon(FontAwesomeIcons.chartLine, color: mainColor),
                          title: Text('Top Tracks'),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ListSongs(widget.db, 2);
                            }));
                          },
                        ),
                        Divider(),
//                    Column(
//                      mainAxisAlignment: MainAxisAlignment.spaceAround,
//                      children: <Widget>[
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          children: <Widget>[
//                            FloatingActionButton(
//                              heroTag: 'favorites',
//                              onPressed: () {
//                                Navigator.push(context,
//                                    MaterialPageRoute(builder: (context) {
//                                  return ListSongs(widget.db, 2);
//                                }));
//                              },
//                              child: Icon(FontAwesomeIcons.chartLine),
//                            ),
//                            SizedBox(height: 4),
//                            Text('Top Songs'),
//                          ],
//                        ),
//                        Column(
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          children: <Widget>[
//                            FloatingActionButton(
//                              heroTag: 'albums',
//                              onPressed: () {
//                                Navigator.push(context,
//                                    MaterialPageRoute(builder: (context) {
//                                  return Albums(widget.db);
//                                }));
//                              },
//                              child: Icon(FontAwesomeIcons.chartLine),
//                            ),
//                            SizedBox(height: 4),
//                            Text('Albums'),
//                          ],
//                        ),
//                        Column(
//                          children: <Widget>[
//                            FloatingActionButton(
//                              heroTag: 'shuffle',
//                              onPressed: () {
//                                MyQueue.songs = songs;
//                                Navigator.push(context,
//                                    MaterialPageRoute(builder: (context) {
//                                  return NowPlaying(widget.db, songs,
//                                      Random().nextInt(songs.length), 0);
//                                }));
//                              },
//                              child: Icon(FontAwesomeIcons.random),
//                            ),
//                            SizedBox(height: 4),
//                            Text('Random')
//                          ],
//                        ),
//                      ],
//                    ),
//                    Padding(
//                      padding: EdgeInsets.fromLTRB(8, 8, 0, 8),
//                      child: Text(
//                        'Recents',
//                        style: TextStyle(
//                          fontSize: 20,
//                          fontFamily: 'pac',
//                        ),
//                      ),
//                    ),
//                    recentW(),
//                    Divider(),
//                    new Padding(
//                      padding:
//                          EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
//                      child: new Text(
//                        "Albums you may like!",
//                        style: new TextStyle(
//                          fontSize: 20.0,
//                          fontFamily: 'pac',
//                        ),
//                      ),
//                    ),
//                    randomW(),
//                    new Divider(),
                        new Padding(
                          padding:
                              EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                          child: new Text(
                            "Most ❤️ Song",
                            style: new TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'pac',
                            ),
                          ),
                        ),
                        ScopedModelDescendant<SongModel>(
                          builder: (context, child, model) {
                            return Card(
                              child: InkResponse(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      child: Hero(
                                        tag: _top(model),
                                        child: getImage(_top(model)) != null
                                            ? Image.file(getImage(_top(model)),
                                                height: 180,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                fit: BoxFit.cover)
                                            : Image.asset(
                                                "assets/images/back.png",
                                                height: 180.0,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(4, 8, 0, 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              _top(model).title,
                                              style: TextStyle(fontSize: 18),
                                              maxLines: 1,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              _top(model).artist,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontSize: 14, color: Colors.grey),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  List<Song> list = List();
                                  list.add(_top(model));
                                  MyQueue.songs = list;
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return NowPlaying(widget.db, list, 0, 0);
                                  }));
                                },
                              ),
                            );
                          },
                        )
                      ])
                    : SliverChildListDelegate([
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

//
//  Widget randomW() {
//    return Container(
//      height: 200,
//      child: ListView.builder(
//        itemCount: albums.length,
//        scrollDirection: Axis.horizontal,
//        itemBuilder: (context, i) => Card(
//          child: InkResponse(
//            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.start,
//              children: <Widget>[
//                SizedBox(
//                  child: Hero(
//                    tag: albums[i].album,
//                    child: getImage(albums[i]) != null
//                        ? Image.file(getImage(albums[i]),
//                            height: 120, width: 200, fit: BoxFit.cover)
//                        : Image.asset('assets/images/back.png',
//                            height: 120, width: 200, fit: BoxFit.cover),
//                  ),
//                ),
//                SizedBox(
//                  width: 200,
//                  child: Padding(
//                    padding: EdgeInsets.fromLTRB(4, 8, 0, 0),
//                    child: Column(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: <Widget>[
//                        Text(
//                          albums[i].album,
//                          style: TextStyle(fontSize: 18),
//                          maxLines: 1,
//                        ),
//                        SizedBox(height: 8),
//                        Text(
//                          albums[i].artist,
//                          maxLines: 1,
//                          style: TextStyle(color: Colors.grey),
//                        ),
//                      ],
//                    ),
//                  ),
//                )
//              ],
//            ),
//            onTap: () {
//              Navigator.push(context, MaterialPageRoute(builder: (context) {
//                return CardDetail(widget.db, albums[i], 0);
//              }));
//            },
//          ),
//        ),
//      ),
//    );
//  }
//
//  Widget recentW() {
//    return Container(
//      height: 200,
//      child: ScopedModelDescendant<SongModel>(builder: (context, child, model) {
//        return ListView.builder(
//          itemCount: _recents(model).length,
//          scrollDirection: Axis.horizontal,
//          itemBuilder: (context, i) {
//            return Card(
//              child: InkResponse(
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    SizedBox(
//                      child: Hero(
//                          tag: _recents(model)[i],
//                          child: getImage(_recents(model)[i]) != null
//                              ? Image.file(
//                                  getImage(_recents(model)[i]),
//                                  height: 120,
//                                  width: 200,
//                                  fit: BoxFit.cover,
//                                )
//                              : Image.asset(
//                                  'assets/images/back.png',
//                                  height: 120,
//                                  width: 200,
//                                  fit: BoxFit.cover,
//                                )),
//                    ),
//                    SizedBox(
//                      width: 200,
//                      child: Padding(
//                        padding: EdgeInsets.fromLTRB(4, 8, 0, 0),
//                        child: Column(
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          children: <Widget>[
//                            Text(
//                              _recents(model)[i].title,
//                              style: TextStyle(fontSize: 18),
//                              maxLines: 1,
//                            ),
//                            SizedBox(height: 8),
//                            Text(
//                              _recents(model)[i].artist,
//                              maxLines: 1,
//                              style: TextStyle(color: Colors.grey),
//                            ),
//                          ],
//                        ),
//                      ),
//                    )
//                  ],
//                ),
//                onTap: () {
//                  MyQueue.songs = model.recents;
//                  Navigator.push(context, MaterialPageRoute(builder: (context) {
//                    return NowPlaying(widget.db, model.recents, i, 0);
//                  }));
//                },
//              ),
//            );
//          },
//        );
//      }),
//    );
//  }

//  List<Song> _recents(SongModel model) {
//    return model.recents == null ? recents : model.recents;
//  }

  Song _top(model) {
    return model.top == null ? top : model.top;
  }
}
