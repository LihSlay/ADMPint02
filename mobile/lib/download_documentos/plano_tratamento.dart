//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:go_router/go_router.dart';

class PlanoTratamento extends StatefulWidget {
  final String title;
  const PlanoTratamento({super.key, required this.title});

  @override
  State<PlanoTratamento> createState() => _PlanoTratamentoState();
}

class _PlanoTratamentoState extends State<PlanoTratamento> {
  int currentPageIndex = 0;

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/pdf_icon.png", height: 42),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 18,
                    ),

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
            icon: Icon(
              Icons.download_outlined,
              size: 26,
              color: Colors.grey.shade700,
            ),
            onPressed: () async {
              final path = await downloadPdf(url, filename);
              abrirPdf(context, path);
            },
          ),
        ],
      ),
    );
  }

  Widget _cardTratamento({
    required BuildContext context,
    required String titulo,
    required String medico,
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

          Text(medico, style: const TextStyle(color: Colors.black87)),

          const SizedBox(height: 14),

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      appBar: AppBar(
        title: const Text(
          "Plano de Tratamento",
          style: TextStyle(color: Colors.white),
        ),

        // setinha
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              context.go('/inicio'), // vai diretamente para a rota /definicoes
        ),

        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF907041), Color(0xFFA68A69)],
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
                    "Para obter os planos de tratamento em papel é necessário contactar a clínica via contacto telefónico.",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _cardTratamento(
              context: context,
              titulo: "Reabilitação oral",
              medico: "Dt. Melissa Pinto",
              pdfNome: "reabilitacao_oral.pdf",
              pdfUrl: "https://www.africau.edu/images/default/sample.pdf",
            ),

            _cardTratamento(
              context: context,
              titulo: "Tratamento para bruxismo",
              medico: "Dt. Sílvia Coimbra",
              pdfNome: "exame_oclusao.pdf",
              pdfUrl: "https://www.africau.edu/images/default/sample.pdf",
            ),
          ],
        ),
      ),

      // =================== BOTTOM NAV BAR ===================
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.transparent,
        onDestinationSelected: (index) {
          setState(() {
            currentPageIndex = index;
          });

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

// =================== PDF VIEWER PAGE ===================
class PdfViewerPage extends StatelessWidget {
  final String path;

  const PdfViewerPage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Visualizar PDF",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF907041), Color(0xFFA68A69)],
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