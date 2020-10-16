import 'dart:io';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musitory/components/lastplay.dart';
import 'package:musitory/components/song_avatar.dart';
import 'package:musitory/database/database_client.dart';
import 'package:musitory/pages/now_playing.dart';


class CardDetail extends StatefulWidget {
  final Song song;
  final int mode;
  final DatabaseClient db;

  CardDetail(this.db, this.song, this.mode);

  @override
  _CardDetailState createState() => _CardDetailState();
}

class _CardDetailState extends State<CardDetail> {
  List<Song> songs;
  bool isLoading = true;
  int id;
  var album;
  var image;

  @override
  void initState() {
    super.initState();
    initAlbum();
  }

  void initAlbum() async {
    image = widget.song.albumArt == null
        ? null
        : File.fromUri(Uri.parse(widget.song.albumArt));

    if (widget.mode == 0)
      songs = await widget.db.fetchSongsFromAlbum(widget.song.albumId);
    else
      songs = await widget.db.fetchSongsByArtist(widget.song.artist);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 350,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: widget.mode == 0
                          ? Text(widget.song.album)
                          : Text(widget.song.artist),
                      background: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Hero(
                            tag: widget.mode == 0
                                ? widget.song.album
                                : widget.song.artist,
                            child: image != null
                                ? Image.file(image, fit: BoxFit.cover)
                                : Image.asset('assets/images/back.png'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(<Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 8, top: 10, bottom: 10),
                        child: Text(songs.length.toString() + 'song(s)'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('songs', style: TextStyle(fontSize: 18)),
                      ),
                    ]),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((builder, i) {
                      //TODO
                      return ListTile(
                        leading: CircleAvatar(
                          child: Hero(
                            tag: songs[i].id,
                            child: avatar(
                                context, getImage(songs[i]), songs[i].title),
                          ),
                        ),
                        title: Text(songs[i].title,
                            maxLines: 1, style: TextStyle(fontSize: 18)),
                        subtitle: Text(songs[i].artist,
                            maxLines: 1,
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: Text(
                          Duration(milliseconds: songs[i].duration).toString().split('.').first,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        onTap: () {
                          MyQueue.songs = songs;
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => NowPlaying(widget.db, songs, i, 0)
                          ));
                        },
                      );
                    }, childCount: songs.length),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          MyQueue.songs = songs;
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => NowPlaying(widget.db, MyQueue.songs, 0, 0)
          ));
        },
        child: Icon(Icons.shuffle),
      ),
    );
  }
}
