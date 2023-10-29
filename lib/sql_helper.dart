import 'package:cf_visualizer/rating.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        rating INTEGER,
        username TEXT
      )
      """);
  }
  // id : The ID of a user
  // username : Handle of a user on Codeforces

  static Future<sql.Database> db() async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'cards.db');
    return sql.openDatabase(
      path,
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new User
  static Future<int> createItem(String username) async {
    final db = await SQLHelper.db();
    final rating = await ratingOfUser(username);
    final data = {'username': username, 'rating': rating};
    final id = await db.insert(
      'users',
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
    return id;
  }

  // Read all User
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('users', orderBy: "rating DESC");
  }

  // Read a Single User data by ID
  // Currently didn't use but for future reference
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('users', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an User by ID
  static Future<int> updateItem(int id, String username) async {
    final db = await SQLHelper.db();
    final rating = await ratingOfUser(username);
    final data = {'username': username, 'rating': rating};

    final result =
        await db.update('users', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete a User by ID
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("users", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
