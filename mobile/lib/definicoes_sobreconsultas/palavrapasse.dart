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
      home: const Palavrapasse(title: 'Alterar Palavra-passe'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Palavrapasse extends StatelessWidget {
  final String title;

  const Palavrapasse({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: Colors.white), // título branco
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF907041), Color(0xFF97774D), Color(0xFFA68A69)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          20,
        ), //aplica 20 pixels de espaço em todas as direções
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Palavra-passe atual",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            //caixas de texto
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            const Text(
              "Palavra-passe nova",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            //caixas de texto
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            const Text(
              "Confirmar palavra-passe nova",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            //caixas de texto
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity, //o botão fica no comprimeto da tela
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(221, 255, 255, 255),
                  padding: EdgeInsets.symmetric(
                    vertical: 20,
                  ), //plica padding só na vertical: 20 px em cima, 20 px em baixo
                  side: const BorderSide(
                    color: Colors.black26, width: 1, // cor da borda e espessura da borda
                  ),
                  // Cantos quadrados
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      3,
                    ), // cantos ligeiramente arredondados
                  ),

                  elevation: 2, // sombra
                ),

                onPressed: () {},
                child: const Text(
                  "Continuar",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
