import 'package:flutter/material.dart';

class Calendario extends StatelessWidget {
  const Calendario({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Página calendário.'),
          ],
        ),
      ),
    );
  }
}
