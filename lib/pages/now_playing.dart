import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:koukicons/shuffle2.dart';
import 'package:media_notification/media_notification.dart';
import 'package:musitory/components/constants.dart';
import 'package:musitory/components/lastplay.dart';
import 'package:musitory/components/my_appbar.dart';
import 'package:musitory/components/song_avatar.dart';
import 'package:musitory/database/database_client.dart';
import 'package:musitory/models/song_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class NowPlaying extends StatefulWidget {
  final int mode;
  final List<Song> songs;
  int index;
  final DatabaseClient db;

  NowPlaying(this.db, this.songs, this.index, this.mode);

  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> with TickerProviderStateMixin {
  MusicFinder player;
  Duration duration;
  Duration position;
  bool isPlaying = false;
  Song song;
  int ratingData;
  int isFavData;

  bool ifTapped = false;
  bool heartTapped = false;
  int heartTappedFor;
  DatabaseClient mainDb;

  int tappedStar = 0;
  int fav = 0;
  bool shuffle;
  AnimationController _controller;

//  var justRating;
  bool isOpened = true;
  String status = 'hidden';

  @override
  void initState() {
    super.initState();
    initAnim();
    initPlayer();
    initStuff();

    MediaNotification.setListener('pause', () {
      _playPause();
    });

    MediaNotification.setListener('play', () {
      _playPause();
    });

    MediaNotification.setListener('next', () {
      next();
    });

    MediaNotification.setListener('prev', () {
      prev();
    });

    MediaNotification.setListener('select', () {
      // YET yo be implement
    });
  }

  Future<void> hide() async {
    try {
      await MediaNotification.hide();
      setState(() {
        status = 'hidden';
      });
    } on PlatformException {}
  }

  initStuff() async {
    var pref = await SharedPreferences.getInstance();
    shuffle = pref.getBool('shuffle');
//    var f = await widget.db.fetchFaveFromSecond(song.id);
//    print('initStuff');
//    setState(() {
//      fav = f;
//      print(f);
//    });
//    print(fav);
  }

  Future<void> show(title, author) async {
    try {
      await MediaNotification.show(title: title, author: author);
      setState(() => status = 'play');
    } on PlatformException {}
  }

  initAnim() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 36))
          ..addListener(() {
            setState(() {});
          });
//    if (mounted) {
//      _controller.repeat();
//    } else {
//      _controller.dispose(); //todo remove if make situation worse
//    }
  }

  @override
  void dispose() async {
//    _controller.dispose(); // TODO will be removing this later
    await MediaNotification.hide();
    super.dispose();
  }

  void initPlayer() async {
    if (player == null) {
      player = MusicFinder();
      MyQueue.player = player;
      var pref = await SharedPreferences.getInstance();
      pref.setBool('played', true);
    }
    setState(() {
      if (widget.mode == 0) {
        player.stop();
      }
      updatePage(widget.index);
      isPlaying = true;
    });
    player.setDurationHandler((d) {
      setState(() {
        duration = d;
      });
    });
    player.setPositionHandler((p) {
      setState(() {
        position = p;
      });
    });
    player.setCompletionHandler(() {
      onComplete();
    });
    player.setErrorHandler((e) {
      setState(() {
        player.stop();
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  void updatePage(int index) {
    MyQueue.index = index;
    song = widget.songs[index];
    widget.index = index;
    song.timeStamp = DateTime.now().millisecondsSinceEpoch;
    widget.db.updateSong(song);
    player.play(song.uri);
    show(song.title, song.artist);
    ScopedModel.of<SongModel>(context).updateUI(song, widget.db);
    setState(() {
      isPlaying = true;
      status = 'play';
    });
  }

  void _playPause() {
    if (isPlaying) {
      player.pause();
      setState(() {
        status = 'pause';
        isPlaying = false;
      });
    } else {
      player.play(song.uri);
      show(song.title, song.artist);
      setState(() {
        status = 'play';
        isPlaying = true;
      });
    }
  }

  Future next() async {
    player.stop();
    setState(() {
      int i = ++widget.index;
      if (i >= widget.songs.length) {
        i = widget.index = 0;
      }
      updatePage(i);
    });
  }

  Future prev() async {
    player.stop();
    setState(() {
      int i = --widget.index;
      if (i < 0) {
        widget.index = 0;
        i = widget.index;
      }
      updatePage(i);
    });
  }

  void onComplete() {
    next();
  }

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  @override
  Widget build(BuildContext context) {
    var _counter = 0;
    return Scaffold(
      key: scaffoldState,
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 1.2,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24))),
            child: song == null
                ? Container()
                : Stack(
                    children: <Widget>[
                      Hero(
                        tag: song.id,
                        child: getImage(song) != null
                            ? Image.file(getImage(song), fit: BoxFit.cover)
                            : Image.asset('assets/images/back.png',
                                fit: BoxFit.cover),
                      ),
                      ScopedModelDescendant<SongModel>(
                          builder: (con, child, model) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Expanded(
                                child: GestureDetector(
                              child: FlatButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onPressed: () {},
                                child: null,
                              ),
                              onDoubleTap: () {
                                prev();
                                model.updateUI(song, widget.db);
                              },
                            )),
                            Expanded(
                                child: GestureDetector(
                              onDoubleTap: _playPause,
                              child: FlatButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onPressed: () {},
                                child: null,
                              ),
                            )),
                            Expanded(
                                child: GestureDetector(
                              child: FlatButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onPressed: () {},
                                child: null,
                              ),
                              onDoubleTap: () {
                                next();
                                model.updateUI(song, widget.db);
                              },
                            )),
                          ],
                        );
                      })
                    ],
                  ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                child: song == null ? Container() : mediaStuff(_counter),
              ),
            ],
          ),
          SafeArea(
            child: MyAppBar(title: '', toPop: true),
          ),
        ],
      ),
    );
  }

  Widget mediaStuff(c) {
    var colorAnim = SequenceAnimationBuilder()
        .addAnimatable(
          animatable:
              ColorTween(begin: Colors.blue, end: Colors.deepPurpleAccent),
          from: Duration(seconds: 0),
          to: Duration(seconds: 4),
          tag: 'colorbutton',
//          curve: Curves.easeOutCubic,
        )
        .addAnimatable(
          animatable: ColorTween(
              begin: Colors.deepPurpleAccent, end: Colors.pinkAccent),
          from: Duration(seconds: 8),
          to: Duration(seconds: 12),
          tag: 'colorbutton',
//          curve: Curves.easeOutCubic,
        )
        .addAnimatable(
          animatable:
              ColorTween(begin: Colors.pinkAccent, end: Colors.redAccent),
          from: Duration(seconds: 16),
          to: Duration(seconds: 20),
          tag: 'colorbutton',
//          curve: Curves.easeOutCubic,
        )
        .addAnimatable(
          animatable:
              ColorTween(begin: Colors.redAccent, end: Colors.blueAccent),
          from: Duration(seconds: 24),
          to: Duration(seconds: 28),
          tag: 'colorbutton',
//          curve: Curves.easeOutCubic,
        )
        .addAnimatable(
          animatable: ColorTween(begin: Colors.blueAccent, end: Colors.blue),
          from: Duration(seconds: 32),
          to: Duration(seconds: 36),
          tag: 'colorbutton',
//          curve: Curves.easeOutCubic,
        )
        .animate(_controller);

    var colorAnim2 = SequenceAnimationBuilder()
        .addAnimatable(
          animatable: ColorTween(
              begin: Colors.lightBlueAccent, end: Colors.purpleAccent),
          from: Duration(seconds: 0),
          to: Duration(seconds: 4),
          tag: 'colorbutton2',
//          curve: Curves.easeOutCubic,
        )
        .addAnimatable(
          animatable:
              ColorTween(begin: Colors.purpleAccent, end: Colors.redAccent),
          from: Duration(seconds: 8),
          to: Duration(seconds: 12),
          tag: 'colorbutton2',
//          curve: Curves.easeOutCubic,
        )
        .addAnimatable(
          animatable: ColorTween(begin: Colors.redAccent, end: Colors.blue),
          from: Duration(seconds: 16),
          to: Duration(seconds: 20),
          tag: 'colorbutton2',
//          curve: Curves.easeOutCubic,
        )
        .addAnimatable(
          animatable: ColorTween(begin: Colors.blue, end: Colors.pinkAccent),
          from: Duration(seconds: 24),
          to: Duration(seconds: 28),
          tag: 'colorbutton2',
//          curve: Curves.easeOutCubic,
        )
        .addAnimatable(
          animatable:
              ColorTween(begin: Colors.pinkAccent, end: Colors.lightBlueAccent),
          from: Duration(seconds: 32),
          to: Duration(seconds: 36),
          tag: 'colorbutton2',
//          curve: Curves.easeOutCubic,
        )
        .animate(_controller);

    return Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height / 1.9,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[100]
                    : Colors.blueGrey[900],
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    topLeft: Radius.circular(24))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  completeSlider(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            song.title,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontFamily: 'pac'),
                          ),
                          Text(
                            song.artist,
                            maxLines: 1,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(bottom: 8),
                      width: MediaQuery.of(context).size.width / 2,
                      child: FutureBuilder(
                        initialData: 0,
                        future: fetchRatingFromSecond(),
                        builder: (context, snap) {
                          return showStar();
                        },
                      )),
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.grey
                                        : Colors.black12,
                                    blurRadius: 24)
                              ],
                              gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    colorAnim['colorbutton'].value,
                                    colorAnim2['colorbutton2'].value,
                                  ]),
                            ),
                            child: RawMaterialButton(
                              onPressed: _playPause,
                              shape: CircleBorder(),
                              elevation: 24,
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: ScopedModelDescendant<SongModel>(
                                  builder: (con, child, model) {
                                    return Dismissible(
                                      resizeDuration: null,
                                      onDismissed:
                                          (DismissDirection direction) {
//                                        setState(() {
//                                          c;
//                                        });
                                        direction == DismissDirection.endToStart
                                            ? next()
                                            : prev();
                                        model.updateUI(song, widget.db);
                                      },
                                      key: ValueKey(c),
                                      child:
                                          Container(color: Colors.transparent),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: _playPause,
                            child: Text('M',
                                style: welcomeMusitoryTitleStyle.copyWith(
                                    color: Colors.white, shadows: [])),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Shuffle',
                        icon: KoukiconsShuffle2(
                          height: 20,
                          width: 20,
                          color: shuffle == true
                              ? acc
                              : Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                        ),
                        onPressed: () async {
                          var pref = await SharedPreferences.getInstance();
                          shuffle = pref.getBool('shuffle') ?? false;
                          var lastSortType = pref.getInt('sort');

                          if (shuffle) {
                            if (lastSortType == 2) {
                              widget.songs.sort(
                                  (a, b) => a.duration.compareTo(b.duration));
                            } else if (lastSortType == 1) {
                              widget.songs
                                  .sort((a, b) => a.title.compareTo(b.title));
                            } else if (lastSortType == 3) {
                              widget.songs
                                  .sort((a, b) => b.rating.compareTo(a.rating));
                            } else if (lastSortType == 4) {
                              widget.songs.sort(
                                  (a, b) => b.duration.compareTo(a.duration));
                            } else if (lastSortType == 5) {
                              widget.songs
                                  .sort((a, b) => a.rating.compareTo(b.rating));
                            }
                            pref.setBool('shuffle', false);
                            setState(() {
                              shuffle = false;
                            });
                          } else {
                            widget.songs.shuffle();
                            pref.setBool('shuffle', true);
                            setState(() {
                              shuffle = true;
                            });
                          }
                        },
                      ),
                      IconButton(
                        tooltip: 'Playing queue',
                        icon: Icon(Icons.queue_music),
                        onPressed: _showBottomSheet,
                      ),
                      FutureBuilder(
                        initialData: 0,
                        future: fetchFavoriteFromSecond(),
                        builder: (context, snap) {
                          return IconButton(
                            tooltip: 'Add to favorites',
                            icon: !heartTapped
                                ? isFavData == 1
                                    ? Icon(
                                        FontAwesomeIcons.solidHeart,
                                        color: acc,
                                        size: 20,
                                      )
                                    : Icon(
                                        FontAwesomeIcons.heart,
                                        size: 20,
                                      )
                                : heartTappedFor == 1
                                    ? Icon(
                                        FontAwesomeIcons.solidHeart,
                                        color: acc,
                                        size: 20,
                                      )
                                    : Icon(
                                        FontAwesomeIcons.heart,
                                        size: 20,
                                      ),
                            onPressed: () async {
                              if (isFavData == 1) {
                                setState(() {
                                  heartTappedFor = 0;
                                  heartTapped = true;
                                });
                                await widget.db.saveFav(song.id, 0);
                              } else {
                                setState(() {
                                  heartTappedFor = 1;
                                  heartTapped = true;
                                });
                                await widget.db.saveFav(song.id, 1);
                              }
                            },
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget completeSlider() {
    return Column(
      children: <Widget>[
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbColor: mainColor,
            activeTrackColor: acc,
            inactiveTrackColor: Colors.grey[400],
            overlayColor: acc.withOpacity(0.3),
            trackHeight: 4,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
            trackShape: RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            min: 0,
            value: position?.inMilliseconds?.toDouble() ?? 0.0,
            onChanged: (val) => player.seek((val / 1000).roundToDouble()),
            max: song.duration.toDouble() + 1000,
            divisions: song.duration,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(position.toString().split('.').first),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                Duration(milliseconds: song.duration)
                    .toString()
                    .split('.')
                    .first,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future _showBottomSheet() async {
    showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.grey[100]
            : Colors.blueGrey[900],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height / 1.8,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  textBaseline: , TODO
                  children: <Widget>[
                    Text(
                      'Playing Queue',
                      style: appBarStyle,
                      textAlign: TextAlign.center,
                    ),
                    Text('${widget.index + 1}/${widget.songs.length} song(s)',
                        textAlign: TextAlign.end)
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
//                    shrinkWrap: true, //todo
                    itemCount: widget.songs.length,
                    itemBuilder: (context, i) {
                      return Column(
                        children: <Widget>[
                          ListTile(
                            leading: avatar(context, getImage(widget.songs[i]),
                                widget.songs[i].title),
                            title: Text(widget.songs[i].title,
                                maxLines: 1, style: TextStyle(fontSize: 18)),
                            subtitle: Text(
                              widget.songs[i].artist,
                              maxLines: 1,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            trailing: song.id == widget.songs[i].id
                                ? new Icon(
                                    Icons.play_circle_filled,
                                    color: mainColor,
                                  )
                                : new Text(
                                    (i + 1).toString(),
                                    style: new TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
                                  ),
                            onTap: () {
                              player.stop();
                              updatePage(i);
                              Navigator.pop(context);
                            },
                          ),
                          Divider(
                            height: 6,
                          ),
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget showStar() {
    Future<void> onLongTap() async {
      setState(() {
        tappedStar = 0;
        ifTapped = true;
      });
      await widget.db.saveRating(song.id, 0);

//      widget.db.updateRating(song, 0);
    }

    return !ifTapped
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                child: Icon(ratingData == 0 ? Icons.star_border : Icons.star,
                    color: acc),
                onTap: () async {
                  setState(() {
                    tappedStar = 1;
                    ifTapped = true;
                  });
                  await widget.db.saveRating(song.id, 1);

//                    widget.db.updateRating(song, 1);
//                    widget.db.saveRatings(song.id, 1);
                },
                onLongPress: onLongTap,
              ),
              InkWell(
                child: Icon(
                    ratingData == 2 || ratingData == 3
                        ? Icons.star
                        : Icons.star_border,
                    color: acc),
                onTap: () async {
                  setState(() {
                    tappedStar = 2;
                    ifTapped = true;
                  });
                  await widget.db.saveRating(song.id, 2);

//                    widget.db.updateRating(song, 2);
//                    widget.db.saveRatings(song.id, 2);
                },
                onLongPress: onLongTap,
              ),
              InkWell(
                child: Icon(ratingData == 3 ? Icons.star : Icons.star_border,
                    color: acc),
                onTap: () async {
                  setState(() {
                    tappedStar = 3;
                    ifTapped = true;
                  });
                  await widget.db.saveRating(song.id, 3);

//                    widget.db.updateRating(song, 3);
//                    widget.db.saveRatings(song.id, 3);
                },
                onLongPress: onLongTap,
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                child: Icon(tappedStar == 0 ? Icons.star_border : Icons.star,
                    color: acc),
                onTap: () async {
                  setState(() {
                    ifTapped = true;
                    tappedStar = 1;
                  });
                  await widget.db.saveRating(song.id, 1);

//                  widget.db.updateRating(song, 1);
//                  widget.db.saveRatings(song.id, 1);
                },
                onLongPress: onLongTap,
              ),
              InkWell(
                child: Icon(
                    tappedStar == 2 || tappedStar == 3
                        ? Icons.star
                        : Icons.star_border,
                    color: acc),
                onTap: () async {
                  setState(() {
                    ifTapped = true;
                    tappedStar = 2;
                  });
                  await widget.db.saveRating(song.id, 2);

//                  widget.db.updateRating(song, 2);
//                  widget.db.saveRatings(song.id, 2);
                },
                onLongPress: onLongTap,
              ),
              InkWell(
                child: Icon(tappedStar == 3 ? Icons.star : Icons.star_border,
                    color: acc),
                onTap: () async {
                  setState(() {
                    ifTapped = true;
                    tappedStar = 3;
                  });
                  await widget.db.saveRating(song.id, 3);
//                  widget.db.updateRating(song, 3);
//                  widget.db.saveRatings(song.id, 3);
                },
                onLongPress: onLongTap,
              ),
            ],
          );
  }

//  Widget showStars() {
//    void onLongTap() async {
////      setState(() {
////        ifTapped = true;
////        tappedStar = 0;
////      });
//      await widget.db.saveRating(song.id, 0);
////      widget.db.setRatingOfSong(song.id, 0);
////      widget.db.updateRating(song, 0);
//    }
//
//    return FutureBuilder(
//      initialData: 0,
//      future: fetchRatingFromSecond(),
//      builder: (context, snap) {
//        print('snap data ${snap.data}');
////        int data = snap.data ?? 0;
//        return Row(
//          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//          children: <Widget>[
//            InkWell(
//              child: Icon(ratingData == 0 ? Icons.star_border : Icons.star,
//                  color: acc),
//              onTap: () {
//                widget.db.saveRating(song.id, 1);
//              },
//              onLongPress: onLongTap,
//            ),
//            InkWell(
//              child: Icon(
//                  ratingData == 2 || ratingData == 3
//                      ? Icons.star
//                      : Icons.star_border,
//                  color: acc),
//              onTap: () {
//                widget.db.saveRating(song.id, 2);
//              },
//              onLongPress: onLongTap,
//            ),
//            InkWell(
//              child: Icon(ratingData == 3 ? Icons.star : Icons.star_border,
//                  color: acc),
//              onTap: () {
//                widget.db.saveRating(song.id, 3);
//              },
//              onLongPress: onLongTap,
//            ),
//          ],
//        );
//      },
//    );
//  }

//  Future<void> setFav(song) async {
//    await widget.db.favSong(song);
////    var i = await widget.db.favSong(song);
//  }

  Future<int> fetchFavoriteFromSecond() async {
    var isFav = await widget.db.fetchFavFromSecond(song.id);
    await widget.db.setIsFavOfSong(song.id, isFav);
    setState(() {
      isFavData = isFav ?? 0;
    });
    return isFav ?? 0;
  }

  Future<int> fetchRatingFromSecond() async {
    var rating = await widget.db.fetchRatingsFromSecond(song.id);
    await widget.db.setRatingOfSong(song.id, rating);
    setState(() {
      ratingData = rating ?? 0;
    });
    return rating ?? 0;
  }

//  Future<int> fetchRatings() async {
//    int someRating;
//    await widget.db.fetchMainRatings(song.id).then((v) {
//      someRating = v;
//      setState(() {
//        justRating = v;
//      });
//    });
//    print(justRating);
//    return someRating;
//  }

//  Future<void> removeFav(song) async {
//    print('removed fav');
//    await widget.db.removeFavSong(song);
//  }
}
