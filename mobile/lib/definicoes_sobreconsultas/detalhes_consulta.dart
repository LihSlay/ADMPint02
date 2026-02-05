import 'package:flutter/material.dart';
import 'package:mobile/database/database_helper.dart';
import 'package:mobile/models/consulta_model.dart';
import 'package:go_router/go_router.dart';

class DetalhesConsulta extends StatefulWidget {
  const DetalhesConsulta({super.key});

  @override
  State<DetalhesConsulta> createState() => _DetalhesConsultaState();
}

class _DetalhesConsultaState extends State<DetalhesConsulta> {
  int currentPageIndex = 3; // Definições
  List<Consulta> consultas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConsultas();
  }

  Future<void> _loadConsultas() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      final maps = await db.query('consultas');
      setState(() {
        consultas = maps.map((m) => Consulta.fromMap(m)).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar consultas: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/inicio'),
        ),
        title: const Text(
          'Detalhes das Consultas',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF907041), Color(0xFF97774D), Color(0xFFA68A69)],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : consultas.isEmpty
          ? const Center(child: Text('Nenhuma consulta encontrada'))
          : SingleChildScrollView( // Scroll automático se faltar espaço
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConsultaDetailCard(consultas.first),
                  const SizedBox(height: 5),
                  _buildAviso(),
                ],
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.transparent,
        backgroundColor: Colors.white,
        onDestinationSelected: (index) {
          setState(() => currentPageIndex = index);

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

  Widget _buildAviso() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF422C20)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black87, fontSize: 13),
                children: [
                  TextSpan(
                    text:
                        'Para desmarcar uma consulta é necessário contactar a clínica via contacto telefónico. ',
                  ),
                  TextSpan(
                    text: '232 823 220',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultaDetailCard(Consulta consulta) {
    // Formatar data
    DateTime dataParsed;
    try {
      final dataStr = consulta.dataConsulta;
      if (dataStr != null && dataStr.isNotEmpty) {
        dataParsed = DateTime.parse(dataStr);
      } else {
        dataParsed = DateTime.now();
      }
    } catch (_) {
      dataParsed = DateTime.now();
    }
    final dia = dataParsed.day.toString().padLeft(2, '0');
    final mesNumero = dataParsed.month;
    final ano = dataParsed.year.toString();
    const meses = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    final mesTexto = meses[mesNumero - 1];
    final dataFormatada = '$dia $mesTexto $ano';

    // Formatar horário
    String formatarHora(String? hora) {
      if (hora == null || hora.isEmpty) return '--:--';
      try {
        final partes = hora.split(':');
        return '${partes[0].padLeft(2, '0')}:${partes[1].padLeft(2, '0')}';
      } catch (_) {
        return '--:--';
      }
    }

    final horarioFormatado =
        '${formatarHora(consulta.horarioInicio)} - ${formatarHora(consulta.horarioFim)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consulta',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Tipo de Consulta',
            consulta.especialidadeNome ?? 'Não informado',
          ),
          _buildDetailRow('Médico', consulta.medicoNome ?? 'Não informado'),
          _buildDetailRow('Data', dataFormatada),
          _buildDetailRow('Horário', horarioFormatado),
          _buildDetailRow('Estado', consulta.estado ?? 'Não informado'),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF422C20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
