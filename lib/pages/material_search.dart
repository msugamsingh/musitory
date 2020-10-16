import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musitory/components/background_container.dart';
import 'package:musitory/components/lastplay.dart';
import 'package:musitory/components/song_avatar.dart';
import 'package:musitory/database/database_client.dart';
import 'package:musitory/pages/now_playing.dart';

class SearchSong extends StatefulWidget {
  final DatabaseClient db;
  final List<Song> songs;

  SearchSong(this.db, this.songs);

  @override
  _SearchSongState createState() => _SearchSongState();
}

class _SearchSongState extends State<SearchSong> {
  List<Song> results;

  @override
  void initState() {
    super.initState();
    results = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          BackgroundContainer(expandedIcon: FontAwesomeIcons.search),
          FloatingSearchBar.builder(
            itemCount: results.length,
            itemBuilder: (context, i) {
              return ListTile(
                leading: Hero(
                  tag: results[i].id,
                  child: avatar(context, getImage(results[i]), results[i].title),
                ),
                title: Text(
                  results[i].title,
                  maxLines: 1,
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: Text(
                  results[i].artist,
                  maxLines: 1,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: Text(
                  Duration(milliseconds: results[i].duration)
                      .toString()
                      .split('.')
                      .first,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  MyQueue.songs = results;
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return NowPlaying(widget.db, results, i, 0);
                  }));
                },
              );
            },
            trailing: Icon(Icons.search),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            onChanged: (val) {
              if (val.trim() == '') {
                setState(() {
                  results = [];
                });
              } else {
                setState(() {
                  results = widget.songs
                      .where((song) =>
                          song.title.toLowerCase().contains(val.toLowerCase()) ||
                          song.artist.toLowerCase().contains(val.toLowerCase()) ||
                          song.album.toLowerCase().contains(val.toLowerCase()))
                      .toList();
                });
              }
            },
            onTap: () {
              // Nothing to do here.
            },
            decoration: InputDecoration.collapsed(hintText: 'Search'),
          ),
        ],
      ),
    );
  }
}
