import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/registro.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('geodiario.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT,
        caminho_imagem TEXT NOT NULL,
        data_hora TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        localidade TEXT,
        favorito INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> inserirRegistro(Registro registro) async {
    final db = await instance.database;
    return await db.insert('registros', registro.toMap());
  }

  Future<List<Registro>> listarRegistros({String busca = '', bool apenasFavoritos = false}) async {
    final db = await instance.database;
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (apenasFavoritos) {
      whereClauses.add('favorito = ?');
      whereArgs.add(1);
    }

    if (busca.isNotEmpty) {
      whereClauses.add('(titulo LIKE ? OR localidade LIKE ? OR descricao LIKE ?)');
      whereArgs.addAll(['%$busca%', '%$busca%', '%$busca%']);
    }

    final result = await db.query(
      'registros',
      where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'id DESC',
    );

    return result.map((map) => Registro.fromMap(map)).toList();
  }

  Future<int> alternarFavorito(Registro registro) async {
    final db = await instance.database;
    return await db.update(
      'registros',
      {'favorito': registro.favorito ? 0 : 1},
      where: 'id = ?',
      whereArgs: [registro.id],
    );
  }

  Future<int> excluirRegistro(Registro registro) async {
    final db = await instance.database;

    try {
      final arquivo = File(registro.caminhoImagem);
      if (await arquivo.exists()) {
        await arquivo.delete();
      }
    } catch (_) {}

    return await db.delete(
      'registros',
      where: 'id = ?',
      whereArgs: [registro.id],
    );
  }
}
