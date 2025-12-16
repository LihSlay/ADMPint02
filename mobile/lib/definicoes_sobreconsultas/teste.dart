import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];

  // Posição inicial (Lisboa)
  final LatLng _initial = LatLng(38.7223, -9.1393);

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
      _markers
        ..clear()
        ..add(
          Marker(
            point: latLng,
            width: 40,
            height: 40,
            child:
                const Icon(Icons.my_location, color: Colors.blue, size: 40),
          ),
        );
    });

    _mapController.move(latLng, 16);
  }

  void _onTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      _markers
        ..clear()
        ..add(
          Marker(
            point: latLng,
            width: 40,
            height: 40,
            child:
                const Icon(Icons.location_on, color: Colors.red, size: 40),
          ),
        );
    });
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa (OpenStreetMap)")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _initial,
          initialZoom: 13,
          onTap: _onTap,
        ),
        children: [
          // MAPA BASE
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.exemplo.app',
          ),

          // MARCADORES
          MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMyLocation,
        icon: const Icon(Icons.my_location),
        label: const Text("Minha localização"),
      ),
    );
  }
}
