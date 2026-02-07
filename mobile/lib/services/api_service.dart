import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/consulta_model.dart';
import '../models/usuario_model.dart';
import '../models/perfil_model.dart';
import '../models/documento_model.dart';
import '../models/exame_clinico.dart';
import '../models/plano_tratamento.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class ApiService {
  final String baseUrl = "https://pi4backend.onrender.com";
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<bool> hasInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }

  // LOGIN: Autentica e guarda UTILIZADOR + PERFIL (Offline-First)
  Future<Usuario?> login(String email, String password) async {
    final db = await _dbHelper.database;
    bool online = await hasInternet();

    if (online) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/auth/login'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'email': email, 'palavra_passe': password}),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          debugPrint('LOGIN response: $data');

          // ---- TOKEN (flexível)
          String? token =
              data['user']?['token'] ??
              data['token'] ??
              data['access_token'] ??
              data['accessToken'];

          // ---- UTILIZADOR
          Usuario usuario = Usuario(
            idUtilizadores:
                data['user']?['id_utilizadores'] ?? data['id_utilizadores'],
            email: email,
            idPerfis: data['user']?['id_perfis'] ?? data['id_perfis'],
            idTipoUtilizadores:
                data['user']?['id_tipo_utilizadores'] ??
                data['id_tipo_utilizadores'],
            token: token,
            termosAssinados:
                data['user']?['termos_assinados'] ?? data['termos_assinados'],
          );

          // ---- guardar utilizador
          await db.delete('utilizadores');
          await db.insert('utilizadores', usuario.toMap());

          // ---- credenciais offline
          await db.insert('credenciais_offline', {
            'email': email,
            'password_hash': password.hashCode.toString(),
            'data_atualizacao': DateTime.now().toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.replace);

          // ---- PERFIL
          if (data['perfil'] != null) {
            // veio no login
            final perfil = Perfil.fromMap(data['perfil']);
            await db.delete('perfis');
            await db.insert('perfis', perfil.toMap());
            debugPrint('Perfil guardado a partir do login');
          } else if (token != null) {
            debugPrint(
              'Perfil não veio no login, a ir buscar /pacientes/meu-perfil...',
            );
            await fetchAndSaveMeuPerfil(usuario.idPerfis ?? 0, token);
          }

          return usuario;
        } else {
          throw Exception('Credenciais inválidas');
        }
      } catch (e) {
        debugPrint('Erro no login online: $e');
        return await _loginOffline(email, password, db);
      }
    } else {
      debugPrint('Sem internet → login offline');
      return await _loginOffline(email, password, db);
    }
  }

  Future<void> fetchAndSaveMeuPerfil(int idPerfis, String? token) async {
    if (token == null) throw Exception("Token ausente");

    final db = await _dbHelper.database;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pacientes/meu-perfil'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(" fetchMeuPerfil response.statusCode: ${response.statusCode}");
      debugPrint(" fetchMeuPerfil response.body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final pacienteData = data['paciente'];
        if (pacienteData == null) throw Exception("Paciente ausente");

        Perfil perfil = Perfil(
          idPerfis: pacienteData['id_perfis'] ?? idPerfis,
          idUtilizadores: pacienteData['id_utilizadores'] ?? 0,
          nome: pacienteData['nome'] ?? '',
          nUtente: pacienteData['n_utente'] != null
              ? int.tryParse(pacienteData['n_utente'].toString())
              : null,
          dataNasc: pacienteData['data_nasc'] ?? '',
          contactoTel: pacienteData['contacto_tel'] ?? '',
          profissao: pacienteData['profissao'] ?? '',
          morada: pacienteData['morada'] ?? '',
          codPostal: pacienteData['cod_postal'] ?? '',
          nif: pacienteData['nif'] ?? '',
          responsavel: pacienteData['responsavel'] ?? '',
          notas: pacienteData['notas'] ?? '',
          idSubsistemasSaude: pacienteData['id_subsistemas_saude'] ?? 0,
          idParentesco: pacienteData['id_parentesco'] ?? 0,
          alcunhas: pacienteData['alcunhas'] ?? '',
          ativo: (pacienteData['ativo'] == true || pacienteData['ativo'] == 1)
              ? 1
              : 0,
        );

        debugPrint("Perfil construído: ${perfil.toMap()}");

        // Substituir dados existentes
        await db.delete('perfis');
        await db.insert('perfis', perfil.toMap());

        debugPrint("✅ Perfil do utilizador guardado localmente");
      } else {
        throw Exception("Erro ao obter perfil: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Erro fetchMeuPerfil: $e");
      rethrow;
    }
  }

  // Login offline: Verificar credenciais guardadas localmente
  Future<Usuario?> _loginOffline(
    String email,
    String password,
    Database db,
  ) async {
    try {
      // Verificar credenciais guardadas
      final credenciais = await db.query(
        'credenciais_offline',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (credenciais.isEmpty) {
        throw Exception(
          'Nenhuma sessão anterior encontrada. É necessário internet para o primeiro login.',
        );
      }

      final passwordHashGuardado = credenciais.first['password_hash'];
      final passwordHashAtual = password.hashCode.toString();

      if (passwordHashGuardado != passwordHashAtual) {
        throw Exception('Credenciais inválidas');
      }

      // Carregar utilizador da BD local
      final usuarioData = await db.query(
        'utilizadores',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (usuarioData.isEmpty) {
        throw Exception('Dados do utilizador não encontrados');
      }

      debugPrint("Login offline bem-sucedido para $email");
      return Usuario.fromMap(usuarioData.first);
    } catch (e) {
      debugPrint("Erro no login offline: $e");
      rethrow;
    }
  }

  // RECUPERAR PASSE 1: Enviar email para receber código
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email}),
          )
          .timeout(
            const Duration(seconds: 45),
          ); // Timeout maior para wake-up do Render
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Erro forgotPassword: $e");
      return false;
    }
  }

  // RECUPERAR PASSE 2: Verificar o código de 5 dígitos (Mailtrap)
  Future<bool> verifyResetCode(String email, String code) async {
    try {
      debugPrint("Verificando código: Email: '$email', Código: '$code'");
      final requestBody = {
        'email': email.trim(),
        // Enviar variantes para maximizar compatibilidade com o backend
        'reset_code': code.trim(),
        'code': code.trim(),
        'codigo': code.trim(),
      };
      debugPrint("Request Verify body: ${json.encode(requestBody)}");
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/verify-reset-code'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint(
        "Resposta Verify: Status ${response.statusCode}, Body: ${response.body}",
      );
      // Alguns backends respondem 201/204 para operações válidas.
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      // Se falhar, tentar obter mensagem clara do backend.
      try {
        final data = json.decode(response.body);
        final msg =
            data['message'] ??
            data['error'] ??
            'Falha na verificação do código.';
        debugPrint("Falha Verify: $msg");
        throw Exception(msg);
      } catch (_) {
        throw Exception('Falha na verificação do código.');
      }
    } catch (e) {
      debugPrint("Erro verifyResetCode: $e");
      // Propagar mensagem para UI mostrar
      throw Exception(e.toString());
    }
  }

  // RECUPERAR PASSE 3: Definir nova password
  Future<bool> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final requestBody = {
        'email': email.trim(),
        // Variantes de campo para o código
        'reset_code': code.trim(),
        'code': code.trim(),
        'codigo': code.trim(),
        // Variantes de campo para a nova palavra‑passe (maximizar compatibilidade)
        'palavra_passe': newPassword,
        'new_password': newPassword,
        'password': newPassword,
        'nova_palavra_passe': newPassword,
        'nova_senha': newPassword,
        // Algumas APIs exigem confirmação
        'password_confirmation': newPassword,
        'confirm_password': newPassword,
      };
      debugPrint("Request Reset body: ${json.encode(requestBody)}");
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 45));
      debugPrint(
        "Resposta Reset: Status ${response.statusCode}, Body: ${response.body}",
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      try {
        final data = json.decode(response.body);
        final msg =
            data['message'] ??
            data['error'] ??
            'Falha ao alterar a palavra‑passe.';
        debugPrint("Falha Reset: $msg");
        throw Exception(msg);
      } catch (_) {
        throw Exception('Falha ao alterar a palavra‑passe.');
      }
    } catch (e) {
      debugPrint("Erro resetPassword: $e");
      throw Exception(e.toString());
    }
  }

  // Historico e Declarações
  Future<void> downloadDocumento({
    required String url,
    required String filePath,
  }) async {
    // 1️⃣ obter DB
    final db = await _dbHelper.database;

    // 2️⃣ obter utilizador + token
    final user = await db.query('utilizadores', limit: 1);
    final token = user.isNotEmpty ? user.first['token'] as String? : null;

    if (token == null) {
      throw Exception("Token inexistente");
    }

    // 3️⃣ criar Dio autenticado
    final dio = Dio();

    // 4️⃣ fazer download com Authorization
    await dio.download(
      url,
      filePath,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    
    final file = File(filePath);
    print("📄 Ficheiro existe: ${await file.exists()}");
    print("📄 Tamanho: ${await file.length()} bytes");
    print("📁 Caminho: $filePath");
  }

  // Exames Clinicos
  Future<void> downloadExameClinico({
    required int idExame,
    required String filePath,
  }) async {
    final db = await _dbHelper.database;

    final user = await db.query('utilizadores', limit: 1);
    final token = user.isNotEmpty ? user.first['token'] as String? : null;

    if (token == null) {
      throw Exception("Token inexistente");
    }

    final dio = Dio();

    await dio.download(
      '$baseUrl/exames-clinicos/download/$idExame',
      filePath,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<List<PlanoTratamento>> getPlanosTratamentoPaciente(
    int idPerfis,
  ) async {
    final db = await _dbHelper.database;

    // 🔐 obter token
    final user = await db.query('utilizadores', limit: 1);
    final token = user.isNotEmpty ? user.first['token'] as String? : null;
    debugPrint("🔑 TOKEN ATUAL: $token");

    if (token == null) {
      throw Exception("Token inexistente");
    }

    debugPrint("🚀 A pedir planos para id_perfis = $idPerfis");

    final response = await http.get(
      Uri.parse('$baseUrl/planos-tratamento/paciente/$idPerfis'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint("📦 RAW RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List lista = data['planos'] ?? [];

      debugPrint("📦 Planos recebidos (Flutter): ${lista.length}");

      return lista.map((p) => PlanoTratamento.fromMap(p)).toList();
    } else {
      throw Exception('Erro ao obter planos de tratamento');
    }
  }

  // Planos de Tratamento
  Future<void> downloadPlanoTratamento({
    required int idPlano,
    required String filePath,
  }) async {
    final db = await _dbHelper.database;

    final user = await db.query('utilizadores', limit: 1);
    final token = user.isNotEmpty ? user.first['token'] as String? : null;

    if (token == null) {
      throw Exception("Token inexistente");
    }

    final dio = Dio();

    await dio.download(
      '$baseUrl/planos-tratamento/download/$idPlano',
      filePath,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  // BUSCA CONSULTAS: Offline-First
  Future<List<Consulta>> getConsultas() async {
    final db = await _dbHelper.database;

    debugPrint("A verificar ligação à Internet...");
    if (await hasInternet()) {
      debugPrint("Internet disponível, a tentar buscar consultas da API...");
      try {
        // obter token guardado
        final user = await db.query('utilizadores', limit: 1);
        final token = user.isNotEmpty ? user.first['token'] as String? : null;

        if (token == null) {
          throw Exception("Token inexistente");
        }

        final response = await http.get(
          Uri.parse('$baseUrl/consultas/paciente'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        debugPrint("Status code da API: ${response.statusCode}");
        debugPrint("Body: ${response.body}");

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);

          // 🔑 vem dentro de "consultas"
          final List<dynamic> lista = decoded['consultas'];

          final consultas = lista.map((json) {
            final documentos = (json['Documentos'] as List? ?? [])
                .map((d) => Documento.fromMap(d))
                .toList();

            return Consulta.fromMap({
              'id_consultas': json['id_consultas'],
              'data_consulta': json['data_consulta'],
              'horario_inicio': json['horario_inicio'],
              'horario_fim': json['horario_fim'],
              'estado': json['estado'],
              'id_perfis': json['id_perfis'],
              'id_medicos': json['id_medicos'],
              'id_tipo_consultas': json['id_tipo_consultas'],
              'documentos': documentos,

              // 👇 dados vindos dos includes
              'medico_nome': json['Medico']?['nome_med'],
              'especialidade_nome': json['TipoConsulta']?['designacao'],
            });
          }).toList();

          // ===============================
          // ✅ FILTRO: só hoje e futuras
          // ===============================
          final hoje = DateTime.now();
          final hojeSemHoras = DateTime(hoje.year, hoje.month, hoje.day);

          final consultasFuturas = consultas.where((c) {
            if (c.dataConsulta == null) return false;

            try {
              final dataConsulta = DateTime.parse(c.dataConsulta!);
              final dataSemHoras = DateTime(
                dataConsulta.year,
                dataConsulta.month,
                dataConsulta.day,
              );

              // mantém hoje e futuro
              return !dataSemHoras.isBefore(hojeSemHoras);
            } catch (_) {
              return false;
            }
          }).toList();

          //  sincronizar local (já filtradas)
          await db.delete('consultas');
          for (var c in consultasFuturas) {
            await db.insert(
              'consultas',
              c.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
          return consultasFuturas;
        }
      } catch (e) {
        debugPrint("Erro ao buscar consultas da API: $e");
      }
    }

    // ===============================
    // 📦 Fallback offline
    // ===============================
    debugPrint("Sem Internet ou erro → usar base local");
    final maps = await db.query('consultas');
    return maps.map((m) => Consulta.fromMap(m)).toList();
  }

  // Adiciona isto dentro da classe ApiService
  // Busca todos os documentos de um paciente
  Future<List<Documento>> getDocumentosPorConsulta(int idConsultas) async {
    final db = await _dbHelper.database;

    // 🔐 Obter token
    final user = await db.query('utilizadores', limit: 1);
    final token = user.isNotEmpty ? user.first['token'] as String? : null;

    if (token == null) {
      throw Exception("Token inexistente");
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/consultas/$idConsultas/documentos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> lista = data['documentos'] ?? [];
        return lista.map((json) => Documento.fromMap(json)).toList();
      } else {
        throw Exception('Erro ao obter documentos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Erro getDocumentosPorConsulta: $e");
      return [];
    }
  }

  Future<List<Documento>> getDocumentosDoPaciente(int idPerfis) async {
    final db = await _dbHelper.database;

    // 🔐 Obter token
    final user = await db.query('utilizadores', limit: 1);
    final token = user.isNotEmpty ? user.first['token'] as String? : null;

    if (token == null) {
      throw Exception("Token inexistente");
    }

    // Primeiro tenta obter documentos de uma consulta (exemplo: última consulta)
    try {
      final listaConsultas = await getConsultas(); // já tens este método
      if (listaConsultas.isNotEmpty) {
        final ultimaConsulta =
            listaConsultas.first; // ou qualquer lógica que queiras
        final docsConsulta = await getDocumentosPorConsulta(
          ultimaConsulta.idConsultas,
        );
        if (docsConsulta.isNotEmpty) {
          debugPrint(
            "Documentos obtidos da última consulta (${ultimaConsulta.idConsultas}): ${docsConsulta.length}",
          );
          return docsConsulta;
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar documentos por consulta: $e");
      // continua para tentar pegar todos os documentos do paciente
    }

    // Se não houver documentos por consulta, vai buscar todos os documentos do paciente
    final url = '$baseUrl/paciente/$idPerfis/documentos';
    debugPrint('URL GET Documentos do Paciente: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Status code da API: ${response.statusCode}');
      debugPrint('Resposta da API: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['documentos'] == null) {
          debugPrint('Campo "documentos" não encontrado na resposta');
          return [];
        }

        final List<dynamic> lista = data['documentos'];
        debugPrint(
          'Lista de documentos do paciente recebidos: ${lista.length}',
        );

        return lista.map((json) => Documento.fromMap(json)).toList();
      } else {
        throw Exception('Erro ao obter documentos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Erro getDocumentosDoPaciente: $e");
      return [];
    }
  }

  Future<List<ExameClinico>> getExamesClinicosPaciente(int idPerfis) async {
    final db = await _dbHelper.database;

    final user = await db.query('utilizadores', limit: 1);
    final token = user.isNotEmpty ? user.first['token'] as String? : null;

    if (token == null) {
      throw Exception("Token inexistente");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/exames-clinicos/$idPerfis'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List lista = data['exames'] ?? [];

      debugPrint("📄 Exames recebidos: ${lista.length}");

      return lista.map((e) {
        debugPrint("🧾 EXAME RAW:");
        debugPrint(e.toString());
        return ExameClinico.fromMap(e);
      }).toList();
    } else {
      throw Exception('Erro ao obter exames clínicos');
    }
  }

  Future<void> atualizarConsentimento(int idPerfis) async {
    try {
      // 1. Guardar logo localmente
      final db = await _dbHelper.database;
      await db.insert('consentimentos', {
        'id_perfis': idPerfis,
        'estado': 'assinado',
        'data_assinatura': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // 2. Enviar para o servidor usando a rota correta do backend: PUT /consentimentos/:id_perfis/assinar
      if (await hasInternet()) {
        final response = await http
            .put(
              Uri.parse('$baseUrl/consentimentos/$idPerfis/assinar'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 30));

        debugPrint(
          "Atualizar consentimento ($idPerfis): ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("Erro ao atualizar consentimento: $e");
    }
  }

  Future<bool> verificarConsentimentoLocal(int idPerfis) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'consentimentos',
      where: 'id_perfis = ?',
      whereArgs: [idPerfis],
    );

    if (result.isNotEmpty) {
      return result.first['estado'] == 'assinado';
    }
    return false;
  }

  Future<void> sincronizarConsentimento(int idPerfis) async {
    if (await hasInternet()) {
      final db = await _dbHelper.database;
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl/consentimentos/$idPerfis'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await db.insert('consentimentos', {
            'id_perfis': idPerfis,
            'estado': data['estado'],
            'data_assinatura': data['data_assinatura'],
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      } catch (e) {
        debugPrint('Erro ao sincronizar consentimento: $e');
      }
    }
  }

  // ALTERAR PALAVRA-PASSE: Para utilizadores autenticados (Offline-First)
  Future<Map<String, dynamic>> changePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> userResult = await db.query(
        'utilizadores',
      );

      if (userResult.isEmpty) {
        debugPrint("Nenhum utilizador encontrado na base de dados");
        throw Exception(
          'Utilizador não encontrado. Por favor, faça login novamente.',
        );
      }

      String? token = userResult.first['token'];
      debugPrint(
        "Token obtido: ${token != null ? 'SIM (${token.substring(0, 10)}...)' : 'NÃO'}",
      );

      // Verificar conectividade
      bool online = await hasInternet();

      if (!online) {
        // Modo Offline: Guardar operação pendente
        debugPrint("SEM INTERNET: Guardando operação pendente");

        final operacaoDados = json.encode({
          'email': email,
          'current_password': currentPassword,
          'new_password': newPassword,
          'token': token,
        });

        await _dbHelper.inserirOperacaoPendente(
          'change_password',
          operacaoDados,
        );

        return {
          'success': true,
          'offline': true,
          'message':
              'Alteração guardada. Será sincronizada quando houver internet.',
        };
      }

      // Modo Online: Tentar alterar na API
      debugPrint("COM INTERNET: Tentando alterar password na API");

      final requestBody = {
        'email': email,
        'current_password': currentPassword,
        'new_password': newPassword,
      };

      debugPrint("Request changePassword body: ${json.encode(requestBody)}");

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      debugPrint("Headers: ${headers.toString()}");

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/change-password'),
            headers: headers,
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint(
        "Resposta changePassword: Status ${response.statusCode}, Body: ${response.body}",
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Sucesso: Atualizar localmente (se necessário guardar hash, etc.)
        debugPrint("Password alterada com sucesso na API");

        return {
          'success': true,
          'offline': false,
          'message': 'Palavra-passe alterada com sucesso!',
        };
      }

      // Falha na API
      try {
        final data = json.decode(response.body);
        final msg =
            data['message'] ??
            data['error'] ??
            'Falha ao alterar a palavra-passe.';
        debugPrint("Falha changePassword: $msg");
        throw Exception(msg);
      } catch (_) {
        throw Exception('Falha ao alterar a palavra-passe.');
      }
    } catch (e) {
      debugPrint("Erro changePassword: $e");
      rethrow;
    }
  }

  // SINCRONIZAR OPERAÇÕES PENDENTES: Processa alterações feitas offline
  Future<void> sincronizarOperacoesPendentes() async {
    if (!await hasInternet()) {
      debugPrint("Sem internet, sincronização adiada");
      return;
    }

    final operacoes = await _dbHelper.obterOperacoesPendentes();
    debugPrint("Sincronizando ${operacoes.length} operações pendentes");

    for (var operacao in operacoes) {
      final int id = operacao['id'];
      final String tipo = operacao['tipo_operacao'];
      final Map<String, dynamic> dados = json.decode(operacao['dados']);

      try {
        if (tipo == 'change_password') {
          debugPrint("Processando mudança de password pendente (ID: $id)");

          final headers = {
            'Content-Type': 'application/json',
            if (dados['token'] != null)
              'Authorization': 'Bearer ${dados['token']}',
          };

          final requestBody = {
            'email': dados['email'],
            'current_password': dados['current_password'],
            'new_password': dados['new_password'],
          };

          final response = await http
              .post(
                Uri.parse('$baseUrl/auth/change-password'),
                headers: headers,
                body: json.encode(requestBody),
              )
              .timeout(const Duration(seconds: 30));

          if (response.statusCode >= 200 && response.statusCode < 300) {
            debugPrint("Operação pendente ID $id sincronizada com sucesso");
            await _dbHelper.removerOperacaoPendente(id);
          } else {
            debugPrint(
              "Falha na sincronização da operação ID $id: ${response.statusCode}",
            );
            await _dbHelper.incrementarTentativasOperacao(id);
          }
        }
      } catch (e) {
        debugPrint("Erro ao sincronizar operação ID $id: $e");
        await _dbHelper.incrementarTentativasOperacao(id);
      }
    }
  }
}
