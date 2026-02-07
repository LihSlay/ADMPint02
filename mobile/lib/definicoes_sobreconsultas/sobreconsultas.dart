import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class SobreConsultasPage extends StatefulWidget {
  final String title;
  const SobreConsultasPage({super.key, required this.title});

  @override
  State<SobreConsultasPage> createState() => _SobreConsultasPageState();
}

class _SobreConsultasPageState extends State<SobreConsultasPage> {
  int currentPageIndex = 3; // Bottomnavegationbar
  final MapController _mapController =
      MapController(); // Controlador do mapa para manipular a posição e o zoom
  final List<Marker> _markers =
      []; // Lista de marcadores para exibir no mapa (inicialmente vazia)
  final LatLng _initial = LatLng(
    40.533192,
    -8.1033865,
  ); // Localização inicial (Tondela)

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        point: _initial,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    // Função para obter a localização atual do usuário e mover o mapa para essa posição
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _show("Ativa o GPS.");
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _show("Permissão de localização negada.");
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final latLng = LatLng(pos.latitude, pos.longitude);

    setState(() {
      // Atualiza o estado para adicionar um marcador na posição atual do usuário e mover o mapa para essa posição
      _markers
        ..clear()
        ..add(
          Marker(
            point: latLng,
            width: 40,
            height: 40,
            child: const Icon(Icons.my_location, color: Colors.blue, size: 40),
          ),
        );
    });

    _mapController.move(latLng, 16);
  }

  void _onTap(TapPosition tapPosition, LatLng latLng) {
    // Função para adicionar um marcador no local onde o usuário tocar no mapa
    setState(() {
      _markers
        ..clear()
        ..add(
          Marker(
            point: latLng,
            width: 40,
            height: 40,
            child: const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        );
    });
  }

  void _show(String msg) {
    // Função para exibir uma mensagem de erro ou informação usando um SnackBar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30,
        title: const Text(
          'Sobre Consultas',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/definicoes'), // voltar para Definições
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF907041), Color(0xFF97774D), Color(0xFFA68A69)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      // ---------- CONTEÚDO ----------
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Informações da clínica ----------
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Clinimolelos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Contacto telefónico',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4),
                          Text('232 823 220'),
                          SizedBox(height: 12),
                          Text(
                            'Correio eletrónico',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4),
                          Text('clinimolelos@gmail.com'),
                          SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Para marcar e/ou desmarcar uma consulta é necessário contactar a clínica via contacto telefónico.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Horário de funcionamento',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          Text('Segunda a sábado'),
                          SizedBox(height: 4),
                          Text('09:30 - 19:00'),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Localização',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          Text('3460-009 Tondela'),
                          Text('Av. Dr. Adriano Figueiredo 158'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ---------- MAPA ----------
                    SizedBox(
                      height: 300,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _initial,
                          initialZoom: 15,
                          onTap: _onTap,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png", // Mapa base
                            userAgentPackageName: 'com.exemplo.app',
                          ),
                          MarkerLayer(markers: _markers),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _goToMyLocation,
                        icon: const Icon(
                          Icons.my_location,
                          color: Color(0xFF422C20),
                        ),
                        label: const Text(
                          "Minha localização",
                          style: TextStyle(
                            color: Color(0xFF422C20),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: Colors.black.withOpacity(0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ---------- BOTTOM NAVBAR ----------
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
}
