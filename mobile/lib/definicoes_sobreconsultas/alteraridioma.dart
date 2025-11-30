import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinimolelos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Idioma(title: 'Alterar Idioma'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Idioma extends StatelessWidget {
  final String title;

  const Idioma({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF907041), Color(0xFF97774D), Color(0xFFA68A69)],
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selecione o idioma",
               style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    height: 1.45,
                    color: Colors.black,
                  ),
            ),

            const SizedBox(height: 20),

            // PORTUGUÊS
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3), // quadrado
                  ),
                  side: const BorderSide(color: Colors.black26, width: 1),
                  elevation: 2,
                ),
                onPressed: () {
                  // Ação português
                },
                child: const Text("Português"),
              ),
            ),

            const SizedBox(height: 16),

            // INGLÊS
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  side: const BorderSide(color: Colors.black26, width: 1),
                  elevation: 2,
                ),
                onPressed: () {
                  // Ação inglês
                },
                child: const Text("Inglês"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
