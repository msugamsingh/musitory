import 'package:flutter/material.dart';
import 'package:musitory/components/constants.dart';
import 'package:musitory/database/database_client.dart';
import 'package:musitory/pages/list_songs.dart';

class PlayList extends StatefulWidget {
  final DatabaseClient db;
  PlayList(this.db);

  @override
  _PlayListState createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  var mode;
  var selected;

  @override
  void initState() {
    mode = 1;
    selected = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.call_received, color: mainColor),
            title: Text('Recently Played'),
            subtitle: Text('songs'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ListSongs(widget.db, 1);
              }));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.show_chart, color: mainColor),
            title: Text('Top Tracks'),
            subtitle: Text('songs'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ListSongs(widget.db, 2);
              }));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.show_chart, color: mainColor),
            title: Text('Favorites'),
            subtitle: Text('songs'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ListSongs(widget.db, 3);
              }));
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
