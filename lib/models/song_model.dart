import 'package:flute_music_player/flute_music_player.dart';
import 'package:musitory/database/database_client.dart';
import 'package:scoped_model/scoped_model.dart';

class SongModel extends Model {
  Song _song;
  List albums, recents, songs;
  Song last;
  Song top;
  int mode = 2;
  int rating = 0;

  Song get song => _song;
  int get ratings => rating;

  void updateUI(Song song, db) async {
    _song = song;
    recents = await db.fetchRecentSong();
    top = await db.fetchTopSong().then((item) => item[0]);
    notifyListeners();
  }

  void setMode(int mode) {
    this.mode = mode;
    notifyListeners();
  }

  void init(DatabaseClient db) async {
    recents = (await db.fetchRecentSong());
    //TODO Aman has written 'as its showing in header' So INVESTIGATE WHY WE ARE REMOVING THIS
    notifyListeners();
  }
}
