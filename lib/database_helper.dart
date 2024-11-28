import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:note_application/models/note.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton instance
  static Database? _database; // Singleton database

  final String noteTable = 'note_table';
  final String colId = 'id';
  final String colTitle = 'title';
  final String colDescription = 'description';
  final String colPriority = 'priority';
  final String colDate = 'date';

  DatabaseHelper._createInstance(); // Named constructor to create an instance

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance(); // Initialize if null
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase(); // Initialize database if null
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory for storing the database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'notes.db');

    // Open/create the database at the given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    // Create the table in the database
    await db.execute(
      'CREATE TABLE $noteTable('
      '$colId INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$colTitle TEXT, '
      '$colDescription TEXT, '
      '$colPriority INTEGER, '
      '$colDate TEXT)',
    );
  }

  // Fetch all notes as a list of maps
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await database;
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert a note into the database
  Future<int> insertNote(Note note) async {
    Database db = await database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // Update a note in the database
  Future<int> updateNote(Note note) async {
    Database db = await database;
    var result = await db.update(
      noteTable,
      note.toMap(),
      where: '$colId = ?',
      whereArgs: [note.id],
    );
    return result;
  }

  // Delete a note from the database
  Future<int> deleteNote(int id) async {
    Database db = await database;
    var result = await db.delete(
      noteTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }

  // Get the count of notes in the database
  Future<int> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT(*) AS count FROM $noteTable');
    int result = Sqflite.firstIntValue(x) ?? 0; // Null safety added
    return result;
  }

  // Fetch all notes as a list of Note objects
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); // Fetch the map list
    int count = noteMapList.length; // Count the number of map entries

    List<Note> noteList = [];
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}
