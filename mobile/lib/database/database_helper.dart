import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'clinica_database.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS consentimentos(
          id_perfis INTEGER PRIMARY KEY,
          estado TEXT,
          data_assinatura TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS operacoes_pendentes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tipo_operacao TEXT NOT NULL,
          dados TEXT NOT NULL,
          data_criacao TEXT NOT NULL,
          tentativas INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS credenciais_offline(
          email TEXT PRIMARY KEY,
          password_hash TEXT NOT NULL,
          data_atualizacao TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
    CREATE TABLE IF NOT EXISTS tipo_documentos(
      id_tipo_documentos INTEGER PRIMARY KEY AUTOINCREMENT,
      designacao TEXT
    )
  ''');

      await db.execute('''
    CREATE TABLE IF NOT EXISTS documentos(
      id_documentos INTEGER PRIMARY KEY AUTOINCREMENT,
      titulo TEXT,
      url TEXT,
      id_consultas INTEGER NOT NULL,
      id_tipo_documentos INTEGER
        FOREIGN KEY (id_consultas) REFERENCES consultas (id_consultas),
  FOREIGN KEY (id_tipo_documentos) REFERENCES tipo_documentos (id_tipo_documentos)
    )
  ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela Utilizadores (id_utilizadores, email, id_perfis, id_tipo_utilizadores)
    await db.execute('''
      CREATE TABLE utilizadores(
        id_utilizadores INTEGER PRIMARY KEY,
        email TEXT NOT NULL,
        id_perfis INTEGER,
        id_tipo_utilizadores INTEGER,
        token TEXT
      )
    ''');

    // Tabela Perfis (Fiel ao Perfis.js do backend)
    await db.execute('''
      CREATE TABLE perfis(
        id_perfis INTEGER PRIMARY KEY,
        id_utilizadores INTEGER,
        nome TEXT,
        n_utente INTEGER,
        data_nasc TEXT,
        contacto_tel TEXT,
        profissao TEXT,
        morada TEXT,
        cod_postal TEXT,
        nif TEXT,
        responsavel TEXT,
        notas TEXT,
        id_subsistemas_saude INTEGER,
        id_parentesco INTEGER,
        alcunhas TEXT,
        ativo INTEGER
      )
    ''');

    // Tabela Consultas (Fiel ao Consultas.js)
    await db.execute('''
      CREATE TABLE consultas(
        id_consultas INTEGER PRIMARY KEY,
        data_consulta TEXT,
        horario_inicio TEXT,
        horario_fim TEXT,
        observacoes TEXT,
        estado TEXT,
        id_perfis INTEGER,
        id_medicos INTEGER,
        id_tipo_marcacao INTEGER,
        id_tipo_consultas INTEGER,
        medico_nome TEXT, -- Campo extra para exibição rápida offline
        especialidade_nome TEXT -- Campo extra para exibição rápida offline
      )
    ''');

    // Tabela Notificações (Fiel ao Notificacoes.js)
    await db.execute('''
      CREATE TABLE notificacoes(
        id_notificacoes INTEGER PRIMARY KEY,
        descricao TEXT,
        designacao TEXT,
        id_perfis INTEGER,
        id_utilizadores INTEGER,
        id_tipo_notificacoes INTEGER,
        lida INTEGER DEFAULT 0
      )
    ''');

    // Tabela Especialidades (Fiel ao Especialidades.js)
    await db.execute('''
      CREATE TABLE especialidades(
        id_especialidades INTEGER PRIMARY KEY,
        designacao TEXT NOT NULL
      )
    ''');

    // Tabela Médicos (Fiel ao Medicos.js)
    await db.execute('''
      CREATE TABLE medicos(
        id_medicos INTEGER PRIMARY KEY,
        id_utilizadores INTEGER,
        nome_med TEXT NOT NULL,
        n_omd INTEGER,
        id_especialidades INTEGER,
        alcunha TEXT,
        id_tipo_utilizadores INTEGER,
        FOREIGN KEY (id_especialidades) REFERENCES especialidades (id_especialidades)
      )
    ''');

    // Tabela Consentimentos
    await db.execute('''
      CREATE TABLE consentimentos(
        id_perfis INTEGER PRIMARY KEY,
        estado TEXT,
        data_assinatura TEXT
      )
    ''');

    // Tabela Operações Pendentes (para sincronização offline-first)
    await db.execute('''
      CREATE TABLE operacoes_pendentes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo_operacao TEXT NOT NULL,
        dados TEXT NOT NULL,
        data_criacao TEXT NOT NULL,
        tentativas INTEGER DEFAULT 0
      )
    ''');

    // Tabela tipo documentos
    await db.execute('''
  CREATE TABLE tipo_documentos(
    id_tipo_documentos INTEGER PRIMARY KEY AUTOINCREMENT,
    designacao TEXT
  )
    ''');

    // Tabela documentos
    await db.execute('''
  CREATE TABLE documentos(
    id_documentos INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo TEXT,
    url TEXT,
    id_consultas INTEGER NOT NULL,
    id_tipo_documentos INTEGER,
    FOREIGN KEY (id_consultas) REFERENCES consultas (id_consultas),
    FOREIGN KEY (id_tipo_documentos) REFERENCES tipo_documentos (id_tipo_documentos)
    )
    ''');

    await db.execute('''
      CREATE TABLE credenciais_offline(
        email TEXT PRIMARY KEY,
        password_hash TEXT NOT NULL,
        data_atualizacao TEXT NOT NULL
      )
    ''');
  }

  // Métodos para gestão de operações pendentes (offline-first)
  Future<int> inserirOperacaoPendente(String tipoOperacao, String dados) async {
    final db = await database;
    return await db.insert('operacoes_pendentes', {
      'tipo_operacao': tipoOperacao,
      'dados': dados,
      'data_criacao': DateTime.now().toIso8601String(),
      'tentativas': 0,
    });
  }

  Future<List<Map<String, dynamic>>> obterOperacoesPendentes() async {
    final db = await database;
    return await db.query('operacoes_pendentes', orderBy: 'data_criacao ASC');
  }

  Future<void> removerOperacaoPendente(int id) async {
    final db = await database;
    await db.delete('operacoes_pendentes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementarTentativasOperacao(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE operacoes_pendentes SET tentativas = tentativas + 1 WHERE id = ?',
      [id],
    );
  }



  // Métodos CRUD genéricos podem ser adicionados aqui
}
