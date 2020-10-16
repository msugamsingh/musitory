import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:musitory/components/constants.dart';
import 'package:musitory/models/song_model.dart';
import 'package:musitory/music_home.dart';
import 'package:musitory/pages/about.dart';
import 'package:musitory/pages/no_music_home.dart';
import 'package:musitory/pages/settings.dart';
import 'package:musitory/pages/splash_screen.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => ThemeData(
        primaryColor: mainColor,
        accentColor: acc,
        brightness: brightness,
      ),
      themedWidgetBuilder: (context, theme) {
        return ScopedModel<SongModel>(
          model: SongModel(),
          child: MaterialApp(
            theme: theme,
            routes: {
              SplashScreen.id: (context) => SplashScreen(),
              About.id: (context) => About(),
              Settings.id: (context) => Settings(),
              NoMusicFound.id: (context) => NoMusicFound(),
              MusicHome.id: (context) => MusicHome(),
            },
            initialRoute: SplashScreen.id,
              debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
