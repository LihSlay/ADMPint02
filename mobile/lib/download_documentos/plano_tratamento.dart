//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PlanoTratamentoPage extends StatelessWidget {
  const PlanoTratamentoPage({super.key});

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

  // =================== PDF TILE (idêntico ao segundo print) ====================
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
          // ÍCON PDF
          Image.asset(
            "assets/images/pdf_icon.png",
            height: 42,
          ),

          const SizedBox(width: 14),

          // COLUNA COM TEXTO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do ficheiro
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

                // Linha: tamanho + check + concluído
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

          // ÍCONE DOWNLOAD
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

  // =================== CARD TRATAMENTO ====================
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

          const Text(
            "Médico",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          Text(
            medico,
            style: const TextStyle(color: Colors.black87),
          ),

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

  // =================== PAGE BUILD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      appBar: AppBar(
        title: const Text(
          "Plano de Tratamento",
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
    );
  }
}

// =================== PDF VIEWER PAGE ====================
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
