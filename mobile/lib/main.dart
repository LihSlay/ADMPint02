import 'package:flutter/material.dart';
import 'app_route.dart';
//import 'package:sqflite/sqflite.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar a base de dados antes de arrancar a app
  await DatabaseHelper().database;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false, // remove a barra de debug
      routerConfig: rotas,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}