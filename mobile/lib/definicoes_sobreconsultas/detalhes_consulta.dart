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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConsultaDetailCard(consultas.first),
                  const SizedBox(height: 20),
                  _buildAviso(),
                ],
              ),
            ),
    );
  }

  Widget _buildAviso() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.black54),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consulta',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          const SizedBox(height: 8),
          Text(
            consulta.observacoes ?? 'Sem observações',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
