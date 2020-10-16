import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:koukicons/settings4.dart';
import 'package:musitory/components/background_container.dart';
import 'package:musitory/components/constants.dart';
import 'package:musitory/components/my_appbar.dart';
import 'package:musitory/database/database_client.dart';

class Settings extends StatefulWidget {
  static const id = "settings";
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var isLoading = false;
  var selected = 0;
  var db;

  @override
  void initState() {
    super.initState();
    db = DatabaseClient();
    db.create();
  }

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            BackgroundContainer(expandedIcon: Icons.settings),
            Column(
              children: <Widget>[
                SizedBox(height: 80),
                ListTile(
                  leading: Icon(Icons.style, color: mainColor),
                  title: Text('Theme'),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: Text('Select theme'),
                            children: <Widget>[
                              ListTile(
                                title: Text('Light'),
                                onTap: () {
                                  DynamicTheme.of(context)
                                      .setBrightness(Brightness.light);
                                  Navigator.pop(context);
                                },
                                trailing: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Icon(Icons.check)
                                    : null,
                              ),
                              ListTile(
                                title: Text('Dark'),
                                onTap: () {
                                  DynamicTheme.of(context)
                                      .setBrightness(Brightness.dark);
                                  Navigator.pop(context);
                                },
                                trailing: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Icon(Icons.check)
                                    : null,
                              ),
                            ],
                          );
                        });
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(FontAwesomeIcons.chartBar, color: mainColor),
                  title: Text('Activity'),
                  subtitle: Text('Coming Soon'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.build, color: mainColor),
                  title: Text('Re-scan Media'),
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    var db = DatabaseClient();
                    await db.create();
                    var songs;
                    try {
                      songs = await MusicFinder.allSongs();
                    } catch (e) {
                      print('failed to get songs');
                    }
                    List<Song> list = List.from(songs);
                    for (Song song in list) db.updateList(song);
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                Divider(),
                Container(
                    child: isLoading
                        ? Center(
                            child: Column(
                              children: <Widget>[
                                CircularProgressIndicator(),
                                Text('Loading songs')
                              ],
                            ),
                          )
                        : Container()),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: MyAppBar(toPop: true, title: 'Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
