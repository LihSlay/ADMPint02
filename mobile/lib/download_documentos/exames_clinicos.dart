//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:go_router/go_router.dart';

class ExamesClinicos extends StatelessWidget {
  final String title;
  const ExamesClinicos({super.key, required this.title});

  // ---------------- PDF DOWNLOAD ------------------

  Future<String> downloadPdf(String url, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/$filename";
    await Dio().download(url, filePath);
    return filePath;
  }

  void abrirPdf(BuildContext context, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfViewerPage(path: path)),
    );
  }

  // ---------------- PDF CARD ------------------

  Widget _pdfTile({
    required BuildContext context,
    required String filename,
    required String url,
    required String sizeInfo,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Image.asset("assets/images/pdf_icon.png", height: 40),

          const SizedBox(width: 1),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sizeInfo,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(Icons.check_circle,
                        color: Color(0xFF4CAF50), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "Concluído",
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.download_outlined,
                size: 26, color: Colors.grey.shade700),
            onPressed: () async {
              final path = await downloadPdf(url, filename);
              abrirPdf(context, path);
            },
          ),
        ],
      ),
    );
  }

  // ---------------- CARD EXAME ------------------

  Widget _cardExame({
    required BuildContext context,
    required String titulo,
    required String medico,
    required String tipoConsulta,
    required String data,
    required String horario,
    required String pdfNome,
    required String pdfUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          const Text("Médico", style: TextStyle(fontWeight: FontWeight.w600)),
          Text(medico),

          const SizedBox(height: 14),

          const Text("Tipo de consulta",
              style: TextStyle(fontWeight: FontWeight.w600)),
          Text(tipoConsulta),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Data",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(data),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Horário",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(horario),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          _pdfTile(
            context: context,
            filename: pdfNome,
            url: pdfUrl,
            sizeInfo: "60KB de 120KB",
          ),
        ],
      ),
    );
  }

  // ---------------- PAGE BUILD ------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      appBar: AppBar(
        title: const Text(
          "Exames Clínicos",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF907041),
                Color(0xFFA68A69),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.brown),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Para obter os exames em papel é necessário contactar a clínica via contacto telefónico.",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _cardExame(
              context: context,
              titulo: "Avaliação da oclusão",
              medico: "Dt. Sílvia Coimbra",
              tipoConsulta: "Remoção de Cárie",
              data: "02 out 2025",
              horario: "10:00 – 10:45",
              pdfNome: "exame_oclusão.pdf",
              pdfUrl: "https://www.africau.edu/images/default/sample.pdf",
            ),

            _cardExame(
              context: context,
              titulo: "Radiografia dentária",
              medico: "Dt. Diogo Calçada",
              tipoConsulta: "Check-up",
              data: "17 set 2025",
              horario: "17:30 – 18:00",
              pdfNome: "exame_radiografia.pdf",
              pdfUrl: "https://www.africau.edu/images/default/sample.pdf",
            ),
          ],
        ),
      ),

      // ---------------- BOTTOM NAV BAR ------------------
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        indicatorColor: Colors.transparent,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/inicio');
              break;
            case 1:
              context.go('/calendario');
              break;
            case 2:
              context.go('/notificacoes');
              break;
            case 3:
              context.go('/definicoes');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendário',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notificações',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Definições',
          ),
        ],
      ),
    );
  }
}

// ---------------- PDF VIEWER ------------------

class PdfViewerPage extends StatelessWidget {
  final String path;

  const PdfViewerPage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Visualizar PDF", style: TextStyle(color: Colors.white)),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF907041),
                Color(0xFFA68A69),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: PDFView(filePath: path),
    );
  }
}
