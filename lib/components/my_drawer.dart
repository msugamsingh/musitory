import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musitory/components/constants.dart';
import 'package:musitory/pages/about.dart';
import 'package:musitory/pages/settings.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatelessWidget {
  @override
  Drawer build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).brightness ==
            Brightness.light ? Colors.grey[50] : Colors.blueGrey[900],
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text('Musitory', style: TextStyle(fontFamily: 'pac', fontSize: 18)),
                accountEmail: null,
                currentAccountPicture: CircleAvatar(
                  child: Text('M',style: welcomeMusitoryTitleStyle,),
                  backgroundColor: Colors.grey[200],
                ),
              ),
              Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.settings, color: Theme
                        .of(context)
                        .accentColor),
                    title: Text('Settings'),
                    onTap: () {
                      Navigator.popAndPushNamed(context, Settings.id);
                    },
                  ),
                  ListTile(
                    leading: new Icon(Icons.info,
                        color: Theme
                            .of(context)
                            .accentColor),
                    title: Text("About"),
                    onTap: () {
                      Navigator.popAndPushNamed(context, About.id);
                    },
                  ),
//                  Divider(),
//                  ListTile(
//                    leading: Icon(Icons.share, color: Theme
//                        .of(context)
//                        .accentColor),
//                    title: Text('Share'),
//                    onTap: () {
//                      Share.share(
//                          'Hey, checkout this cool music player at link'
//                      );
//                      Navigator.pop(context);
//                    },
//                  ),
//                  ListTile(
//                    leading: Icon(Icons.stars, color: Theme
//                        .of(context)
//                        .accentColor),
//                    title: Text('Rate the app'),
//                    onTap: () {
//                      Navigator.pop(context);
//                      launchUrl(
//                          'SOME URL'
//                      );
//                    },
//                  ),
//                  ListTile(
//                    leading: Icon(FontAwesomeIcons.donate, color: Theme
//                        .of(context)
//                        .accentColor),
//                    title: Text('Donate'),
//                    onTap: () {
//                      Navigator.pop(context);
//                      launchUrl('https://paypal.me/msugamsingh');
//                    },
//                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not open';
    }
  }
}
