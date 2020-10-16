import 'package:flutter/material.dart';

// COLORS
Color mainColor = Color(0xff00859C);
Color acc = Color(0xff00D4DD);

//Color redPink = Color(0xffF54594);
//Color redSkin = Color(0xffF45165);
//Color redSkinAccent = Color(0xffEE7B88);
//Color redShade = Color(0xff9A444E);
//Color main = Color(0xff27787A);
//Color main2 = Color(0xff1A7F7F);
//Color main3 = Color(0xff00859C);
//Color darkViolet = Color(0xff1A1D38);
//int red = 0xffF4364D;
//int primary = 0xffF85D80;
//int accent = 0xff717FF4;

String version = 'Version 0.1';

// TextStyles
TextStyle welcomeMusitoryTitleStyle = TextStyle(
  fontSize: 36,
  color: mainColor,
  shadows: [
    Shadow(
        blurRadius: 30, color: mainColor.withOpacity(0.6), offset: Offset(0, 20))
  ],
  fontFamily: 'pac',
);

TextStyle appBarStyle = TextStyle(
  fontSize: 28,
  fontFamily: 'pac',
);

class CustomIcons {
  static const IconData menu = IconData(0xe900, fontFamily: "ci");
  static const IconData option = IconData(0xe902, fontFamily: "ci");
}
