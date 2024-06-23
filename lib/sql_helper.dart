import 'package:cf_visualizer/rating.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class SQLHelper {
  // Creates Tables: For each CP platform
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE codeforces(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        rating INTEGER,
        username TEXT
      )
      """);

    await database.execute("""CREATE TABLE leetcode(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        rating INTEGER,
        username TEXT
      )
      """);
  }

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
  static Future<int> createItem(String username, String table) async {
    final db = await SQLHelper.db();
    final rating = await ratingOfUser(username);
    final data = {'username': username, 'rating': rating};
    final id = await db.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
    return id;
  }

  // Read all User
  static Future<List<Map<String, dynamic>>> getItems(String table) async {
    final db = await SQLHelper.db();
    return db.query(table, orderBy: "rating DESC");
  }

  // Read a Single User data by ID
  // Currently didn't use but for future reference
  static Future<List<Map<String, dynamic>>> getItem(
      int id, String table) async {
    final db = await SQLHelper.db();
    return db.query(table, where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an User by ID
  static Future<int> updateItem(int id, String username, String table) async {
    final db = await SQLHelper.db();
    // TODO: Update the rating of the user for the given platform
    final rating = await ratingOfUser(username);
    final data = {'username': username, 'rating': rating};

    final result =
        await db.update(table, data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete a User by ID
  static Future<void> deleteItem(int id, String table) async {
    final db = await SQLHelper.db();
    try {
      await db.delete(table, where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
