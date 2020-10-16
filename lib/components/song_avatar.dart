import 'dart:io';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musitory/components/constants.dart';

dynamic getImage(Song song) {
  return song.albumArt == null ? null : File.fromUri(Uri.parse(song.albumArt));
}

Widget avatar(BuildContext context, File f, String title) {
  return Material(
    borderRadius: BorderRadius.circular(30),
    elevation: 8,
    child: f != null
        ? CircleAvatar(
            backgroundColor: mainColor,
            backgroundImage: FileImage(f),
          )
        : CircleAvatar(
            backgroundColor: mainColor,
            child: Text(
              title[0].toUpperCase(),
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontFamily: 'pac',
              ),
            ),
          ),
  );
}
