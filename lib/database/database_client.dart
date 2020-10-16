import 'dart:core';
import 'dart:io';

import "package:flute_music_player/flute_music_player.dart";
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseClient {
  Database _db;
  Song song;

  Future create() async {
    Directory path = await getApplicationDocumentsDirectory();
    String dbPath = join(path.path, 'database.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: this._create);
  }

  Future _create(Database db, int version) async {
    await db.execute("""
    CREATE TABLE songs(id NUMBER, title TEXT, duration NUMBER, albumArt TEXT, 
    album Text, uri TEXT, artist TEXT, albumId INTEGER, isFav NUMBER default 0, 
    rating INTEGER DEFAULT 0,
    timestamp NUMBER, count NUMBER NOT NULL default 0)
    """);

    await db.execute("""
    CREATE TABLE recents(id integer primary key autoincrement,title TEXT,duration NUMBER,albumArt TEXT,album TEXT,uri TEXT,artist TEXT,albumId NUMBER)
    """);

    await db.execute("""
    CREATE TABLE ratings(id integer primary key autoincrement, songId NUMBER,rating INTEGER NOT NULL default 0, isFav INTEGER NOT NULL default 0)
    """);
  }

  Future<dynamic> fetchFavFromSecond(int songId) async {
//    print(songId);
    var isFav;
    List<Map> results = await _db
        .rawQuery('select isFav from ratings where songId = "$songId"');
//    print(results);
    results.forEach((r) {
      isFav = r['isFav'];
    });
    return isFav;
  }

  Future<void> saveFav(int songId, int isFav) async {
    var firstResult =
        await _db.rawQuery('SELECT * FROM ratings where songId = "$songId"');
//    print(firstResult);
    if (firstResult.isNotEmpty) {
      await _db.update('ratings', {'isFav': isFav},
          where: 'songId = ?', whereArgs: [songId]);
    } else {
      await _db.insert('ratings', {'songId': songId, 'isFav': isFav});
    }
  }

  Future<void> setIsFavOfSong(int songId, int isFav) async {
    await _db.rawQuery("update songs set isFav = ? where id=$songId", [isFav]);
  }

  Future<int> fetchRatingsFromSecond(int songId) async {
    int rating = 0;
    List<Map> results = await _db
        .rawQuery('select rating from ratings where songId = "$songId"');
    results.forEach((r) {
      rating = r['rating'];
    });
    return rating;
  }

  Future<void> saveRating(int songId, int rating) async {
    var firstResult =
        await _db.rawQuery('SELECT * FROM ratings where songId = "$songId"');
//    print(firstResult);
    if (firstResult.isNotEmpty) {
      await _db.update('ratings', {'rating': rating},
          where: 'songId = ?', whereArgs: [songId]);
    } else {
      await _db.insert('ratings', {'songId': songId, 'rating': rating});
    }
  }

  Future<void> setRatingOfSong(int songId, int rating) async {
    await _db
        .rawQuery("update songs set rating = ? where id=$songId", [rating]);
  }

  Future<int> upsertSOng(Song song) async {
    if (song.count == null) {
      song.count = 0;
    }
    if (song.timeStamp == null) {
      song.timeStamp = 0;
    }
    if (song.isFav == null) {
      song.isFav = 0;
    }
    if (song.rating == null) {
      print('called for ${song.title}');
//      song.rating = await fetchRatingsFromSecond(song.id);
      song.rating = 0;
    }
    int id = 0;
    var count = Sqflite.firstIntValue(await _db
        .rawQuery('SELECT COUNT(*) FROM songs WHERE id = ?', [song.id]));
    if (count == 0) {
      id = await _db.insert('songs', song.toMap());
    } else {
      await _db
          .update('songs', song.toMap(), where: 'id = ?', whereArgs: [song.id]);
    }
    return id;
  }

  Future<int> updateList(Song song) async {
    song.count = 0;
    song.timeStamp = DateTime.now().millisecondsSinceEpoch;
    song.isFav = 0;
    int id = 0;
    var count = Sqflite.firstIntValue(await _db
        .rawQuery('SELECT COUNT(*) FROM songs WHERE title = ?', [song.title]));
    if (count == 0) {
      id = await _db.insert('songs', song.toMap());
    }
    return id;
  }

  Future<bool> alreadyLoaded() async {
    var count =
        Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM songs'));
    return count > 0 ? true : false;
  }

  Future<List<Song>> fetchSongs() async {
    List<Map> results =
        await _db.query('songs', columns: Song.Columns, orderBy: 'title');
    List<Song> songs = [];
    results.forEach((s) {
      Song song = Song.fromMap(s);
      songs.add(song);
    });
    return songs;
  }

  Future<List<Song>> fetchSongsFromAlbum(int id) async {
    List<Map> results =
        await _db.query('songs', columns: Song.Columns, where: 'albumId=$id');
    List<Song> songs = [];
    results.forEach((s) {
      Song song = Song.fromMap(s);
      songs.add(song);
    });
    return songs;
  }

  Future<List<Song>> fetchAlbum() async {
    List<Map> results = await _db.rawQuery(
        'select distinct albumId, album, artist ,albumArt from songs group by album order by album');
    List<Song> songs = [];
    results.forEach((s) {
      Song song = Song.fromMap(s);
      songs.add(song);
    });
    return songs;
  }

  Future<List<Song>> fetchArtist() async {
    List<Map> results = await _db.rawQuery(
        'select distinct artist, album, albumArt from songs group by artist order by artist');
    List<Song> songs = [];
    results.forEach((s) {
      Song song = Song.fromMap(s);
      songs.add(song);
    });
    return songs;
  }

  Future<List<Song>> fetchSongsByArtist(String artist) async {
    List<Map> results = await _db.query('songs',
        columns: Song.Columns, where: 'artist="$artist"');
    List<Song> songs = [];
    results.forEach((s) {
      print('inLoop');
      Song song = Song.fromMap(s);
      songs.add(song);
    });
    return songs;
  }

  Future<List<Song>> fetchRandomAlbum() async {
    List<Map> results = await _db.rawQuery(
        'select distinct albumId, album, artist, albumArt from songs group by album order by album');
    List<Song> songs = [];
    results.forEach((s) {
      Song song = Song.fromMap(s);
      songs.add(song);
    });
    return songs;
  }

  Future<int> upsertSong(Song song) async {
    int id = 0;
    var count = Sqflite.firstIntValue(await _db
        .rawQuery('select COUNT(*) from recents where id = ?', [song.id]));
    if (count == 0) {
      id = await _db.insert('recents', song.toMap());
    } else {
      await _db
          .update('recents', song.toMap(), where: 'id=?', whereArgs: [song.id]);
    }
    return id;
  }

  Future<List<Song>> fetchRecentSong() async {
    List<Map> results = await _db
        .rawQuery("select * from songs order by timestamp desc limit 25");
    List<Song> songs = new List();
    results.forEach((s) {
      Song song = new Song.fromMap(s);
      songs.add(song);
    });
    return songs;
  }

  Future<List<Song>> fetchTopSong() async {
    List<Map> results =
        await _db.rawQuery("select * from songs order by count desc limit 25");
    List<Song> songs = new List();
    results.forEach((s) {
      Song song = new Song.fromMap(s);
      songs.add(song);
    });
    return songs;
  }

  Future<int> updateSong(Song song) async {
    int id = 0;
    // id==9999 for shared song
//    var count = Sqflite.firstIntValue(
//        await _db.rawQuery("SELECT COUNT FROM songs WHERE id = ?", [song.id]
//        ));
    if (song.count == null) {
      song.count = 0;
    }
    song.count += 1;
    await _db
        .update("songs", song.toMap(), where: "id= ?", whereArgs: [song.id]);

    return id;
  }

  Future<int> isFav(Song song) async {
    var c = Sqflite.firstIntValue(
        await _db.rawQuery("select isFav from songs where is=${song.id}"));
    if (c == 0) {
      return 1;
    } else {
      return 0;
    }
  }

  Future<Song> fetchLastSong() async {
    List<Map> results = await _db
        .rawQuery("select * from songs order by timestamp desc limit 1");
    Song song;
    results.forEach((s) {
      song = new Song.fromMap(s);
    });
    return song;
  }

  Future<List<Song>> fetchFavSong() async {
    List<Map> results = await _db.rawQuery("select * from songs where isFav=1");
    List<Song> songs = new List();
    results.forEach((s) {
      Song song = new Song.fromMap(s);
      songs.add(song);
    });
    return songs;
  }

  Future<List<Song>> searchSong(String q) async {
    List<Map> results =
        await _db.rawQuery("select * from songs where title like '%$q%'");
    List<Song> songs = new List();
    results.forEach((s) {
      Song song = new Song.fromMap(s);
      songs.add(song);
    });
    return songs;
  }

  Future<List<Song>> fetchSongById(int id) async {
    List<Map> results = await _db.rawQuery("select * from songs where id=$id");
    List<Song> songs = new List();
    results.forEach((s) {
      Song song = new Song.fromMap(s);
      songs.add(song);
    });
    return songs;
  }
}
