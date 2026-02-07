import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_service.dart';
import '../models/plano_tratamento.dart';
import 'dart:io';

class PlanoTratamentoPage extends StatefulWidget {
  final String title;
  const PlanoTratamentoPage({super.key, required this.title});

  @override
  State<PlanoTratamentoPage> createState() => _PlanoTratamentoPageState();
}

class _PlanoTratamentoPageState extends State<PlanoTratamentoPage> {
  bool aCarregar = true;
  List<PlanoTratamento> planos = [];
  int? idPerfil;

  @override
  void initState() {
    super.initState();
    _carregarPlanos();
  }

  Future<void> _carregarPlanos() async {
    final prefs = await SharedPreferences.getInstance();
    idPerfil = prefs.getInt('id_perfis');

    debugPrint("🧠 ID PERFIL (SharedPreferences): $idPerfil");

    if (idPerfil == null) {
      if (mounted) context.go('/login');
      return;
    }

    try {
      final lista = await ApiService().getPlanosTratamentoPaciente(idPerfil!);

      debugPrint("📦 Planos recebidos (Flutter): ${lista.length}");

      if (!mounted) return;
      setState(() {
        planos = lista;
        aCarregar = false;
      });
    } catch (e) {
      debugPrint("❌ Erro ao carregar planos: $e");
      if (!mounted) return;
      setState(() => aCarregar = false);
    }
  }

  // ---------------- DOWNLOAD PDF ----------------
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

  // ---------------- PDF TILE ----------------
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
            splashRadius: 20,
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

  // ---------------- CARD PLANO ----------------
  Widget _cardPlano({
    required BuildContext context,
    required PlanoTratamento plano,
    required String ficheiro_url,
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
            plano.nomePlano ?? "Plano de Tratamento",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          const Text("Médico", style: TextStyle(fontWeight: FontWeight.w600)),
          Text(plano.medicoNome ?? "—"),

          const SizedBox(height: 14),

          if (plano.nomeFicheiro == null)
            const Text(
              "Sem ficheiro associado",
              style: TextStyle(color: Colors.grey),
            )
          else
            _pdfTile(
              context: context,
              filename: plano.nomeFicheiro!,
              url: ficheiro_url,
              sizeInfo: "60KB de 120KB",
            ),
        ],
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Plano de Tratamento",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/inicio'),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF907041), Color(0xFFA68A69)],
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

            if (aCarregar)
              const Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(),
              )
            else if (planos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  "Sem planos de tratamento",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: planos.map((p) {
                  return _cardPlano(
                    context: context,
                    plano: p,
                    ficheiro_url: p.ficheiroUrl ?? '',
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------- PDF VIEWER ----------------
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF907041), Color(0xFFA68A69)],
            ),
          ),
        ),
      ),
      body: PDFView(filePath: path),
    );
  }
}
