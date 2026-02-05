//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/consulta_model.dart';
import '../models/documento_model.dart';
import 'package:mobile/services/api_service.dart';

class HistoricoDeclaracoes extends StatefulWidget {
  final String title;
  const HistoricoDeclaracoes({super.key, required this.title});

  @override
  State<HistoricoDeclaracoes> createState() => _HistoricoDeclaracoesState();
}

class _HistoricoDeclaracoesState extends State<HistoricoDeclaracoes> {
  String filtro = "ambos"; // ambos | declaracoes | atestados

  List<Consulta> consultas = [];
  Map<int, List<Documento>> documentosPorConsulta =
      {}; 
  bool aCarregar = true; 
  int? idPerfil;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }
Future<void> _carregarDados() async {
  final prefs = await SharedPreferences.getInstance();
  idPerfil = prefs.getInt('id_perfis');

  if (idPerfil == null) {
    if (mounted) context.go('/login');
    return;
  }

  setState(() => aCarregar = true);

  try {
    debugPrint("A carregar consultas da API...");
    final listaConsultas = await ApiService().getConsultas();
    debugPrint("Consultas recebidas: ${listaConsultas.length}");

    // 1️⃣ Carregar documentos por cada consulta
    final Map<int, List<Documento>> docsMap = {};
    for (final c in listaConsultas) {
      final docs = await ApiService().getDocumentosPorConsulta(c.idConsultas);
      docsMap[c.idConsultas] = docs;
      debugPrint(
        "Consulta ${c.idConsultas} → documentos por consulta: ${docs.map((d) => d.idDocumento)}",
      );
    }

    // 2️⃣ Carregar documentos do paciente (todas as consultas)
    try {
      debugPrint("A carregar documentos do paciente...");
      final listaDocsPaciente = await ApiService().getDocumentosDoPaciente(idPerfil!);
      debugPrint("Documentos do paciente recebidos: ${listaDocsPaciente.length}");

      // Agrupar no mapa usando uma chave especial, ou adicionar às consultas existentes
      for (final doc in listaDocsPaciente) {
        final consultaId = doc.idConsultas ?? 0;
        if (docsMap.containsKey(consultaId)) {
          // Evita duplicados
          final existentes = docsMap[consultaId]!;
          if (!existentes.any((d) => d.idDocumento == doc.idDocumento)) {
            existentes.add(doc);
          }
        } else {
          docsMap[consultaId] = [doc];
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar documentos do paciente: $e");
    }

    setState(() {
      consultas = listaConsultas;
      documentosPorConsulta = docsMap;
      aCarregar = false;
    });
  } catch (e) {
    debugPrint("Erro ao carregar consultas/documentos da API: $e");
    setState(() => aCarregar = false);
  }
}



  String formatHora(String? hora) {
    if (hora == null || hora.length < 5) return '--:--';
    return hora.substring(0, 5); // HH:mm
  }

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

  // ------------------- PDF TILE -------------------
  Widget _pdfTile({
    required BuildContext context,
    required String filename,
    required String url,
    required String sizeInfo,
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
              color: (url.isEmpty)
                  ? Colors.grey.shade400
                  : Colors.grey.shade700,
            ),
            onPressed: (url.isEmpty)
                ? null // desativa o botão se não houver URL
                : () async {
                    final path = await downloadPdf(url, filename);
                    abrirPdf(context, path);
                  },
          ),
        ],
      ),
    );
  }

  // ------------------- CARD DO EXAME -------------------
  Widget _card({
    required String medico,
    required String tipoConsulta,
    required String data,
    required String horario,
    required List<Map<String, String>> pdfs,
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
          const Text("Médico", style: TextStyle(fontWeight: FontWeight.w600)),
          Text(medico),

          const SizedBox(height: 12),

          const Text(
            "Tipo de consulta",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(tipoConsulta),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Data",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(data),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 50),
                    child: Text(
                      "Horário",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),

                  Text(horario),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          Column(
            children: pdfs.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _pdfTile(
                  context: context,
                  filename: p["nome"]!,
                  url: p["url"]!,
                  sizeInfo: "60KB de 120KB",
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ------------------- BOTÃO FILTRO -------------------
  Widget _filtroButton(String label, String valor) {
    final bool ativo = (filtro == valor);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => filtro = valor);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: ativo
                ? const LinearGradient(
                    colors: [
                      Color(0xFF907041),
                      Color.fromARGB(255, 167, 142, 113),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: ativo ? null : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: ativo ? Colors.transparent : Colors.grey.shade300,
            ),
            boxShadow: ativo
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 7,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ativo ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------- BUILD PAGE -------------------
  @override
  Widget build(BuildContext context) {
    final String baseUrl = "https://pi4backend.onrender.com";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      appBar: AppBar(
        title: const Text(
          "Histórico e Declarações",
          style: TextStyle(color: Colors.white),
        ),

        // setinha
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/inicio'),
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
      // ---------------- FILTROS ----------------
      Row(
        children: [
          _filtroButton("Ambos", "ambos"),
          const SizedBox(width: 10),
          _filtroButton("Declarações", "declaracoes"),
          const SizedBox(width: 10),
          _filtroButton("Atestados", "atestados"),
        ],
      ),

      const SizedBox(height: 20),

      // ---------------- CARDS ----------------
      ...consultas.map((c) {
        final docs = documentosPorConsulta[c.idConsultas] ?? [];
        debugPrint(
          "Consulta ${c.idConsultas} → ${docs.length} documentos",
        );

        if (docs.isEmpty) {
          return _card(
            medico: c.medicoNome ?? '—',
            tipoConsulta: c.especialidadeNome ?? 'Consulta',
            data: c.dataConsulta ?? '',
            horario:
                '${formatHora(c.horarioInicio)} - ${formatHora(c.horarioFim)}',
            pdfs: [
              {"nome": "Sem documentos", "url": ""},
            ],
          );
        }

        return _card(
          medico: c.medicoNome ?? '—',
          tipoConsulta: c.especialidadeNome ?? 'Consulta',
          data: c.dataConsulta ?? '',
          horario:
              '${formatHora(c.horarioInicio)} - ${formatHora(c.horarioFim)}',
          pdfs: docs
              .map(
                (doc) => {
                  "nome": (doc.titulo?.isNotEmpty == true)
                      ? "${doc.titulo}.pdf"
                      : "documento_${doc.idDocumento}.pdf",
                  "url":
                      "$baseUrl/consultas/download-documento/${doc.idDocumento}",
                },
              )
              .toList(),
        );
      }).toList(),
    ],
  ),
),


      // ---------------- BOTTOM NAV BAR ----------------
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

// ---------------- PDF VIEWER -------------------

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
