//import 'dart:io';
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/services/api_service.dart';
import '../models/exame_clinico.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ExamesClinicos extends StatefulWidget {
  final String title;
  const ExamesClinicos({super.key, required this.title});

  @override
  State<ExamesClinicos> createState() => _ExamesClinicosState();
}

class _ExamesClinicosState extends State<ExamesClinicos> {
  bool aCarregar = true;
  List<ExameClinico> exames = [];
  int? idPerfil;

  @override
  void initState() {
    super.initState();
    _carregarExames();
  }

  Future<void> _carregarExames() async {
    final prefs = await SharedPreferences.getInstance();
    idPerfil = prefs.getInt('id_perfis');

    if (idPerfil == null) {
      if (mounted) context.go('/login');
      return;
    }

    try {
      final lista = await ApiService().getExamesClinicosPaciente(idPerfil!);

      debugPrint("🧪 Exames clínicos recebidos: ${lista.length}");

      for (final e in lista) {
        debugPrint(
          "📄 Exame:"
          " id=${e.idExamesClinicos},"
          " tipo=${e.tipoExame},"
          " nome=${e.nomeFicheiro},"
          " data=${e.dataUpload},"
          " url=${e.ficheiroUrl}",
        );
      }

      setState(() {
        exames = lista;
        aCarregar = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar exames clínicos: $e");
      setState(() => aCarregar = false);
    }
  }

  // ---------------- PDF DOWNLOAD ------------------
  Future<String> downloadPdf(String url, String filename) async {
    Directory dir;

    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final filePath = '${dir.path}/$filename';

    await ApiService().downloadDocumento(url: url, filePath: filePath);

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
    required String sizeInfo,
    required String url,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/pdf_icon.png", height: 30),
          const SizedBox(width: 12),

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

                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      sizeInfo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                    Text(
                      "Concluído",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          IconButton(
            icon: const Icon(Icons.download_outlined),
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
    required String medico,
    required String titulo,
    required String data,
    required String pdfNome,
    required String? ficheiroUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          // -------- MÉDICO --------
          const Text("Médico", style: TextStyle(fontWeight: FontWeight.w600)),
          Text(medico),

          const SizedBox(height: 12),

          // -------- DATA --------
          const Text("Data", style: TextStyle(fontWeight: FontWeight.w600)),
          Text(data),

          const SizedBox(height: 16),

          // -------- PDF --------
          _pdfTile(
            context: context,
            filename: pdfNome,
            sizeInfo: "60KB de 120KB",
            url: ficheiroUrl ?? '',
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
          crossAxisAlignment: CrossAxisAlignment.start,
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

            if (aCarregar)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (exames.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    "Sem exames clínicos",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                children: exames.map((e) {
                  return _cardExame(
                    context: context,
                    titulo: e.tipoExame ?? 'Exame clínico',
                    medico: e.medicoNome ?? '—',
                    data: e.dataUpload,
                    pdfNome: e.nomeFicheiro ?? 'exame.pdf',
                    ficheiroUrl: e.ficheiroUrl,
                  );
                }).toList(),
              ),
          ],
        ),
      ),

      // ---------------- BOTTOM NAV BAR ------------------
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        indicatorColor: Colors.transparent,
        backgroundColor: Colors.white,
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
