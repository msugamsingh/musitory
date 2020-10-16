import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:koukicons/profile2.dart';
import 'package:musitory/components/background_container.dart';
import 'package:musitory/components/my_appbar.dart';
import 'package:musitory/components/my_drawer.dart';
import 'package:musitory/database/database_client.dart';
import 'package:musitory/pages/card_details.dart';
import 'package:musitory/pages/material_search.dart';

class Artists extends StatefulWidget {
  DatabaseClient db;
  Artists(this.db);

  @override
  _ArtistsState createState() => _ArtistsState();
}

class _ArtistsState extends State<Artists> {
  List<Song> songs;
  var f;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initArtists();
  }

  void initArtists() async {
    songs = await widget.db.fetchArtist();
    setState(() {
      isLoading = false;
    });
  }

  List<Card> _buildGridCards(BuildContext context) {
    return songs.map((Song song) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: InkResponse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Hero(
                tag: song.artist,
                child: AspectRatio(
                  aspectRatio: 18/16,
                  child: KoukiconsProfile2(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 4, top: 8),
                  child: Text(
                    song.artist,
                    style: TextStyle(fontSize: 18),
                    maxLines: 1,
                  ),
                ),
              )
            ],
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CardDetail(widget.db, song, 1);
            }));
          },
        ),
      );
    }).toList();
  }

  final GlobalKey<ScaffoldState> _artistKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      key: _artistKey,
      body: Stack(
        children: <Widget>[
          BackgroundContainer(expandedIcon: Icons.person),
          Container(
            margin: EdgeInsets.only(top: 100),
            child: isLoading ? Center(child: CircularProgressIndicator())
                : GridView.count(crossAxisCount: 2,
            children: _buildGridCards(context),
              padding: EdgeInsets.all(2),
              childAspectRatio: 8/10,
            )
          ),
          SafeArea(child: MyAppBar(scaffoldState: _artistKey, title: 'Artists'),)
        ],
      ),
    );
  }
}

