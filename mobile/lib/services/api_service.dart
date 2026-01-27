import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/consulta_model.dart';
import '../models/usuario_model.dart';
import '../models/perfil_model.dart';

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

  // LOGIN: Autentica e guarda UTILIZADOR + PERFIL
  Future<Usuario?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'palavra_passe': password}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("Dados do login: $data");
        
        // Tentar extrair token de diferentes localizações possíveis
        String? extractedToken = data['user']?['token'] ?? 
                                 data['token'] ?? 
                                 data['access_token'] ??
                                 data['accessToken'] ??
                                 data['user']?['access_token'] ??
                                 data['user']?['accessToken'];
        
        debugPrint("Token extraído do login: ${extractedToken != null ? 'SIM (${extractedToken.substring(0, 10).padRight(10, '.')})' : 'NÃO ENCONTRADO'}");
        
        // Mapeamento flexível para aceitar diferentes formatos de resposta do backend
        Usuario usuario = Usuario(
          idUtilizadores: data['user']?['id_utilizadores'] ?? data['id_utilizadores'] ?? 0,
          email: email,
          idPerfis: data['user']?['id_perfis'] ?? data['id_perfis'] ?? 0,
          idTipoUtilizadores: data['user']?['id_tipo_utilizadores'] ?? data['id_tipo_utilizadores'] ?? 0,
          token: extractedToken,
          termosAssinados: data['user']?['termos_assinados'] ?? data['termos_assinados'] ?? data['user']?['aceitou_termos'] ?? data['aceitou_termos'],
        );

        final db = await _dbHelper.database;
        await db.delete('utilizadores');
        await db.insert('utilizadores', usuario.toMap());
        
        debugPrint("Utilizador guardado na BD com token: ${usuario.token != null ? 'SIM' : 'NÃO'}");

        // Se o login já trouxer a informação de termos assinados (1, true ou "assinado")
        final statusTermos = usuario.termosAssinados;
        if (statusTermos == 1 || statusTermos == true || statusTermos == 'assinado') {
          await db.insert(
            'consentimentos',
            {
              'id_perfis': usuario.idPerfis,
              'estado': 'assinado',
              'data_assinatura': DateTime.now().toIso8601String(),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        if (data['perfil'] != null) {
          Perfil perfil = Perfil.fromMap(data['perfil']);
          await db.delete('perfis');
          await db.insert('perfis', perfil.toMap());
        }
        
        return usuario;
      } else {
        // Se não for 200, tentamos ler a mensagem, mas com cuidado para não crashar se não for JSON
        String msg;
        try {
          final errorData = json.decode(response.body);
          msg = errorData['message'] ?? errorData['error'] ?? "Erro (${response.statusCode})";
        } catch (_) {
          msg = "Erro ${response.statusCode}: ${response.body}";
        }
        throw Exception(msg);
      }
    } catch (e) {
      debugPrint("Erro no login: $e");
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
          .timeout(const Duration(seconds: 45)); // Timeout maior para wake-up do Render
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
          "Resposta Verify: Status ${response.statusCode}, Body: ${response.body}");
      // Alguns backends respondem 201/204 para operações válidas.
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      // Se falhar, tentar obter mensagem clara do backend.
      try {
        final data = json.decode(response.body);
        final msg = data['message'] ?? data['error'] ?? 'Falha na verificação do código.';
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
      String email, String code, String newPassword) async {
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
      debugPrint("Resposta Reset: Status ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      try {
        final data = json.decode(response.body);
        final msg = data['message'] ?? data['error'] ?? 'Falha ao alterar a palavra‑passe.';
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

  // BUSCA CONSULTAS: Offline-First
  Future<List<Consulta>> getConsultas() async {
    final db = await _dbHelper.database;

    if (await hasInternet()) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/consultas'));
        
        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          List<Consulta> consultas = data.map((json) => Consulta.fromMap(json)).toList();

          // Sincronização
          await db.delete('consultas');
          for (var consulta in consultas) {
            await db.insert('consultas', consulta.toMap());
          }
          return consultas;
        }
      } catch (e) {
        debugPrint("Erro API: $e");
      }
    }

    // Fallback Local
    final List<Map<String, dynamic>> maps = await db.query('consultas');
    return maps.map((m) => Consulta.fromMap(m)).toList();
  }

  Future<bool> verificarConsentimento(int idPerfis) async {
    // 1. Verificar primeiro localmente (mais rápido e seguro)
    bool assinadoLocal = await verificarConsentimentoLocal(idPerfis);
    if (assinadoLocal) return true;

    // Nota: Removida a chamada GET /consentimentos porque exige permissões de admin/gestor.
    // O estado de consentimento deve vir preferencialmente no objeto Usuario durante o login.
    
    return false;
  }

  Future<void> atualizarConsentimento(int idPerfis) async {
    try {
      // 1. Guardar logo localmente
      final db = await _dbHelper.database;
      await db.insert(
        'consentimentos',
        {
          'id_perfis': idPerfis,
          'estado': 'assinado',
          'data_assinatura': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Enviar para o servidor usando a rota correta do backend: PUT /consentimentos/:id_perfis/assinar
      if (await hasInternet()) {
        final response = await http.put(
          Uri.parse('$baseUrl/consentimentos/$idPerfis/assinar'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 30));
        
        debugPrint("Atualizar consentimento ($idPerfis): ${response.statusCode}");
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
        final response = await http.get(
          Uri.parse('$baseUrl/consentimentos/$idPerfis'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await db.insert(
            'consentimentos',
            {
              'id_perfis': idPerfis,
              'estado': data['estado'],
              'data_assinatura': data['data_assinatura'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      } catch (e) {
        debugPrint('Erro ao sincronizar consentimento: $e');
      }
    }
  }

  // ALTERAR PALAVRA-PASSE: Para utilizadores autenticados
  Future<bool> changePassword(
      String email, String currentPassword, String newPassword) async {
    try {
      // Obter token do utilizador autenticado
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> userResult = await db.query('utilizadores');
      String? token;
      if (userResult.isNotEmpty) {
        token = userResult.first['token'];
        debugPrint("Token obtido: ${token != null ? 'SIM (${token.substring(0, 10)}...)' : 'NÃO'}");
      } else {
        debugPrint("Nenhum utilizador encontrado na base de dados");
      }

      final requestBody = {
        'email': email,
        'palavra_passe_atual': currentPassword,
        'password_atual': currentPassword,
        'current_password': currentPassword,
        'palavra_passe': newPassword,
        'nova_palavra_passe': newPassword,
        'password': newPassword,
        'new_password': newPassword,
        'password_confirmation': newPassword,
        'confirm_password': newPassword,
        if (token != null) 'token': token, // Incluir token no body também
      };
      
      debugPrint("Request changePassword body: ${json.encode(requestBody)}");
      
      // Headers com autenticação (token) em múltiplos formatos
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        if (token != null) 'token': token, // Algumas APIs usam header customizado
        if (token != null) 'x-auth-token': token,
      };
      
      debugPrint("Headers: ${headers.toString()}");
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/change-password'),
        headers: headers,
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 30));

      debugPrint("Resposta changePassword: Status ${response.statusCode}, Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      
      try {
        final data = json.decode(response.body);
        final msg = data['message'] ?? data['error'] ?? 'Falha ao alterar a palavra-passe.';
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
}
