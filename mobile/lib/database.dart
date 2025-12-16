import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Basededados {
  static const nomebd = "bdadm.db";
  final int versao = 1;
  static Database? _basededados;

  Future<Database> get basededados async {
    if (_basededados != null) return _basededados!;
    _basededados = await _initDatabase();
    return _basededados!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), nomebd);
    return await openDatabase(path, version: versao, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {}

  // Criar tabela manualmente (opcional)
  Future<void> criartabela() async {
    Database db = await basededados;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS utilizadores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        login TEXT,
        password TEXT,
        email TEXT,
        telefone TEXT
      )
    ''');
  }

  // Inserir novo utilizador
  Future<void> inserirUtilizador(String login, String password, String email, String telefone) async {
    Database db = await basededados;
    await db.rawInsert(
      'INSERT INTO utilizadores(login, password, email, telefone) VALUES(?, ?, ?, ?)',
      [login, password, email, telefone],
    );
  }

  Future<String> consultaprimeiro() async {
Database db = await basededados;
List<Map<String,Object?>> resultado = await db.rawQuery(
'select login from utilizadores where id=1');
return resultado[0]['login'].toString();
}


  //---------------------------------------
  Future<void> consulta() async {
    Database db = await basededados;
    List<Map> resultado = await db.rawQuery('SELECT * FROM utilizadores');
    resultado.forEach((linha) {
      print(linha);
    });
  }
}