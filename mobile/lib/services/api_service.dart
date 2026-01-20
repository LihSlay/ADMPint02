import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
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
        
        // Mapeamento flexível para aceitar diferentes formatos de resposta do backend
        Usuario usuario = Usuario(
          idUtilizadores: data['user']?['id_utilizadores'] ?? data['id_utilizadores'] ?? 0,
          email: email,
          idPerfis: data['user']?['id_perfis'] ?? data['id_perfis'],
          idTipoUtilizadores: data['user']?['id_tipo_utilizadores'] ?? data['id_tipo_utilizadores'],
          token: data['token'] ?? data['accessToken'],
        );

        final db = await _dbHelper.database;
        await db.delete('utilizadores');
        await db.insert('utilizadores', usuario.toMap());

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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Erro forgotPassword: $e");
      return false;
    }
  }

  // RECUPERAR PASSE 2: Verificar o código de 5 dígitos (Mailtrap)
  Future<bool> verifyResetCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'reset_code': code}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Erro verifyResetCode: $e");
      return false;
    }
  }

  // RECUPERAR PASSE 3: Definir nova password
  Future<bool> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'reset_code': code,
          'palavra_passe': newPassword, // Ajustado para bater com o teu modelo Utilizadores.js
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Erro resetPassword: $e");
      return false;
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
}
