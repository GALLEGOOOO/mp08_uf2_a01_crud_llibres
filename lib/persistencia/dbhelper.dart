import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_flutter_crud/JsonModels/note_model.dart';
import 'package:sqlite_flutter_crud/settings/constants_db.dart';

class DatabaseHelper {
  final databaseName = '${ConstantsDb.DATABASE_NAME}.db';
  String Table =
      'CREATE TABLE ${ConstantsDb.TABLE_NOTES} (${ConstantsDb.FIELD_NOTES_ID} INTEGER PRIMARY KEY AUTOINCREMENT, ${ConstantsDb.FIELD_NOTES_TITOL} TEXT NOT NULL, ${ConstantsDb.FIELD_NOTES_CONTENT} TEXT NOT NULL, ${ConstantsDb.FIELD_NOTES_CREATED_AT} TEXT DEFAULT CURRENT_TIMESTAMP)';

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(Table);
    });
  }

  Future<List<LlibreModel>> searchNotes(String keyword) async {
    final Database db = await initDB();
    List<Map<String, Object?>> searchResult = await db.rawQuery(
        'select * from ${ConstantsDb.TABLE_NOTES} where ${ConstantsDb.FIELD_NOTES_TITOL} LIKE ?',
        ['%$keyword%']);
    return searchResult.map((e) => LlibreModel.fromMap(e)).toList();
  }

  Future<int> createLlibre(LlibreModel llibre) async {
    final Database db = await initDB();
    return db.insert(ConstantsDb.TABLE_NOTES, llibre.toMap());
  }

  Future<List<LlibreModel>> getLlibres() async {
    final Database db = await initDB();
    List<Map<String, Object?>> result = await db.query(ConstantsDb.TABLE_NOTES);
    return result.map((e) => LlibreModel.fromMap(e)).toList();
  }

  Future<int> deleteLlibre(int id) async {
    final Database db = await initDB();
    return db.delete(ConstantsDb.TABLE_NOTES,
        where: '${ConstantsDb.FIELD_NOTES_ID} = ?', whereArgs: [id]);
  }

  Future<int> updateLlibre(title, content, Id) async {
    final Database db = await initDB();
    return db.rawUpdate(
        'update ${ConstantsDb.TABLE_NOTES} set ${ConstantsDb.FIELD_NOTES_TITOL} = ?, ${ConstantsDb.FIELD_NOTES_CONTENT} = ? where ${ConstantsDb.FIELD_NOTES_ID} = ?',
        [title, content, Id]);
  }
}
