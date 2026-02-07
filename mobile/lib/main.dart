import 'dart:async';
import 'package:flutter/material.dart';
import 'app_route.dart';
import 'database/database_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_PT', null); // deixar o calendário em pt

  // Inicializar a base de dados antes de arrancar a app
  await DatabaseHelper().database;

  runApp(const AppShell());
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final ApiService _apiService = ApiService();
  StreamSubscription<dynamic>? _sub;

  @override
  void initState() {
    super.initState();

    // tentar sincronizar operações pendentes logo ao arrancar
    _apiService.sincronizarOperacoesPendentes().catchError((e) {
      debugPrint('Erro sincronizar ao arrancar: $e');
    });

    // ouvir mudanças de conectividade e sincronizar quando houver rede
    _sub = Connectivity().onConnectivityChanged.listen((result) {
      // result é sempre ConnectivityResult
      bool hasNetwork = result != ConnectivityResult.none;

      if (hasNetwork) {
        _apiService.sincronizarOperacoesPendentes().catchError((e) {
          debugPrint('Erro sincronizar onConnectivityChanged: $e');
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false, // remove a barra de debug

      locale: const Locale('pt', 'PT'),

      supportedLocales: const [Locale('pt', 'PT')],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routerConfig: rotas,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
