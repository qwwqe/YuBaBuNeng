import 'package:sqflite/sqflite.dart';
import 'dart:core';
import 'package:yu_ba_bu_neng/models/models.dart';

class ChengYuProvider {
  Database _database;

  Future<Database> getDatabase() async {
    if (_database == null) {
      var dbBasePath = await getDatabasesPath();
      var dbPath = dbBasePath + "/" + "chengyu.db";
      print(dbPath);
      _database = await openDatabase(dbPath, version: 1,
          /*onCreate: (Database db, int version) async {
            await db.execute(
                'CREATE TABLE notes (id INTEGER PRIMARY KEY, modelId TEXT, deckId TEXT, note TEXT);'
            );
          }*/
      );
    }

    return _database;
  }

  Future<List<ChengYu>> getRandomChengYu(int amount, {String like}) async {
    var db = await getDatabase();
    var rows = await db.rawQuery(
        'SELECT * FROM entries WHERE LENGTH(chengyu) = 4 ORDER BY RANDOM() LIMIT ?', [amount]
    );

    var chengYuList = List<ChengYu>();
    for(int i = 0; i < rows.length; i++) {
      var chengYu = ChengYu();
      chengYu.loadEntryFromSQLRow(rows[i]);
      chengYuList.add(chengYu);
    }

    return chengYuList;
  }

  Future<List<ChengYu>> getUnseenChengYu(int amount, {String like = "%", String unlike =""}) async {
    var db = await getDatabase();
    var rows;
    if (like != null || unlike != null) {
      // TODO: confirm this works. otherwise, maybe.. just.. sanitize the 'like' string...?
      rows = await db.rawQuery(
          'SELECT * FROM entries WHERE id NOT IN (SELECT entryId FROM stats) AND LENGTH(chengyu) = 4 AND chengyu LIKE ? ORDER BY RANDOM() LIMIT ?',
          [like, amount]
      );
    } else {
      rows = await db.rawQuery(
          'SELECT * FROM entries WHERE id NOT IN (SELECT entryId FROM stats) AND LENGTH(chengyu) = 4 ORDER BY RANDOM() LIMIT ?',
          [amount]
      );
    }

    var chengYuList = List<ChengYu>();
    for(int i = 0; i < rows.length; i++) {
      var chengYu = ChengYu();
      chengYu.loadEntryFromSQLRow(rows[i]);
      chengYuList.add(chengYu);
    }

    return chengYuList;
  }

  Future<List<ChengYu>> getLearningChengYu(int amount, {bool random = false, String like}) async {
    var db = await getDatabase();
    var rows;
    if(random) {
      rows = await db.rawQuery(
          'SELECT * FROM entries LEFT JOIN stats WHERE id = entryId AND stage = 1 AND LENGTH(chengyu) = 4 ORDER BY RANDOM() LIMIT ?', [amount]
      );
    } else {
      rows = await db.rawQuery(
          'SELECT * FROM entries LEFT JOIN stats WHERE id = entryId AND stage = 1 AND LENGTH(chengyu) = 4 ORDER BY timeDue ASC LIMIT ?', [amount]
      );
    }

    var chengYuList = List<ChengYu>();
    for(int i = 0; i < rows.length; i++) {
      var chengYu = ChengYu();
      chengYu.loadEntryFromSQLRow(rows[i]);
      chengYu.loadStatsFromSQLRow(rows[i]);
      chengYuList.add(chengYu);
    }

    return chengYuList;
  }

  Future<List<ChengYu>> getLearnedChengYu(int amount, {bool random = false, String like}) async {
    var db = await getDatabase();
    List<Map<String, dynamic>> rows;
    if(random) {
      rows = await db.rawQuery(
          'SELECT * FROM entries LEFT JOIN stats WHERE id = entryId AND stage = 2 AND LENGTH(chengyu) = 4 ORDER BY RANDOM() LIMIT ?', [amount]
      );
    } else {
      var nowTime = DateTime.now().millisecondsSinceEpoch;

      rows = await db.rawQuery(
          'SELECT * FROM entries LEFT JOIN stats WHERE id = entryId AND stage = 2 AND LENGTH(chengyu) = 4 AND timeDue <= ? ORDER BY timeDue ASC LIMIT ?',
          [nowTime, amount]
      );

      if(rows.length < amount) {
          List<Map<String, dynamic>> extraRows;
          extraRows = await db.rawQuery(
              'SELECT * FROM entries LEFT JOIN stats WHERE id = entryId AND stage = 2 AND LENGTH(chengyu) = 4 AND timeDue > ? LIMIT ?',
              [nowTime, amount - rows.length]
          );

          rows.addAll(extraRows);
      }
    }

    var chengYuList = List<ChengYu>();
    for(int i = 0; i < rows.length; i++) {
      var chengYu = ChengYu();
      chengYu.loadEntryFromSQLRow(rows[i]);
      chengYu.loadStatsFromSQLRow(rows[i]);
      chengYuList.add(chengYu);
    }

    return chengYuList;
  }

  void saveChengYu(List<ChengYu> chengYu) async {
    // TODO: stub
    var db = await getDatabase();
  }

  void saveStats(List<ChengYu> chengYuList, {newCardLimit}) async {

    var db = await getDatabase();
    await db.transaction((tx) async {
      chengYuList.forEach((c) async {
        await tx.execute("INSERT OR REPLACE INTO stats (entryId, timeStaged, timeDue, steps, easiness, stage) VALUES (?, ?, ?, ?, ?, ?)",
            [c.id, c.timeStaged, c.timeDue, c.steps, c.easiness, c.stage]);
      });
    });
    ;
  }
}