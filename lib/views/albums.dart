import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musitory/components/background_container.dart';
import 'package:musitory/components/my_appbar.dart';
import 'package:musitory/components/my_drawer.dart';
import 'package:musitory/components/song_avatar.dart';
import 'package:musitory/database/database_client.dart';
import 'package:musitory/pages/card_details.dart';

class Albums extends StatefulWidget {
  final DatabaseClient db;

  Albums(this.db);

  @override
  _AlbumsState createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> {
  List<Song> songs;
  var f;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initAlbum();
  }

  void initAlbum() async {
    songs = await widget.db.fetchAlbum();
    setState(() {
      isLoading = false;
    });
  }

  List<Widget> _buildGridCards(BuildContext context) {
    return songs.map((song) {
      return InkResponse(
        child: Hero(
          tag: song.album,
          child: Stack(
            children: <Widget>[
              getImage(song) != null
                  ? Image.file(getImage(song),
                      height: 250, width: MediaQuery.of(context).size.width, fit: BoxFit.cover)
                  : Image.asset('assets/images/back.png',
                      height: 250, width: MediaQuery.of(context).size.width, fit: BoxFit.cover),
              Container(
                margin: EdgeInsets.only(top: 220),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter),
                ),
                child: Text(
                  song.album,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(fontFamily: 'pac', color: Colors.white, fontSize: 18),
                ),
              )
            ],
          ),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CardDetail(widget.db, song, 0);
          }));
        },
      );
    }).toList();
  }

  final GlobalKey<ScaffoldState> _albumKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _albumKey,
      drawer: MyDrawer(),
      body: Stack(
        children: <Widget>[
          BackgroundContainer(expandedIcon: FontAwesomeIcons.compactDisc),
          Container(
            margin: EdgeInsets.only(top: 100),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    children: _buildGridCards(context),
                  ),
          ),
          SafeArea(child: MyAppBar(title: 'Albums', scaffoldState: _albumKey,)),
        ],
      ),
    );
  }
}
