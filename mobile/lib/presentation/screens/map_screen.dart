import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Экран карты с метками мероприятий
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> ecoCenters = [
    {
      'name':
          'Экоцентр «Музей природы» ГПБУ «Государственный природоохранный центр»',
      'address': 'Москва, Родионовская ул., д. 2',
      'point': const LatLng(55.894611, 37.400081)
    },
    {
      'name':
          'Экоцентр «Дом Лани» ГПБУ «Государственный природоохранный центр»',
      'address': 'Зеленоград, 4921-й пр-д., д. 4',
      'point': const LatLng(55.981832, 37.255839)
    },
    {
      'name':
          'Экоцентр «Экошкола в Кусково» ГПБУ «Государственный природоохранный центр»',
      'address': 'Москва, 3-я Музейная ул., д. 40, стр. 1',
      'point': const LatLng(55.736138, 37.797514)
    },
    {
      'name':
          'Экоцентр «Воробьевы горы» ГПБУ «Государственный природоохранный центр»',
      'address': 'Москва, Андреевская наб., д. 1',
      'point': const LatLng(55.712538, 37.576232)
    },
    {
      'name':
          'Экоцентр «Битцевский лес»  ГПБУ «Государственный природоохранный центр»',
      'address': 'Москва, Новоясеневский тупик, д. 1, стр.3',
      'point': const LatLng(55.59722, 37.556828)
    },
    {
      'name':
          'Экоцентр «Лесная сказка» ГПБУ «Государственный природоохранный центр»',
      'address':
          'Москва, 36-й км МКАД, внешняя сторона, зона отдыха "Битца", стр. 8',
      'point': const LatLng(55.584639, 37.557224)
    },
    {
      'name': 'Экоцентр «Южный» ГПБУ «Государственный природоохранный центр»',
      'address': 'Москва, Каширское шоссе, 148/1',
      'point': const LatLng(55.59541, 37.724382)
    },
    {
      'name':
          'Экоцентр «Терлецкий» ГПБУ «Государственный природоохранный центр»',
      'address': 'Москва, ул. Металлургов, д. 41, стр. 1',
      'point': const LatLng(55.761295, 37.812525)
    },
    {
      'name':
          'Экоцентр «Царская пасека» ГПБУ «Государственный природоохранный центр»',
      'address': 'Москва, пос. Измайловская пасека, д. 1',
      'point': const LatLng(55.774092, 37.784991)
    },
    {
      'name':
          'Экоцентр «Кузьминки» ГПБУ «Государственный природоохранный центр»',
      'address': 'Москва, ул. Кузьминская д.10, стр.1',
      'point': const LatLng(55.693378, 37.788162)
    },
  ];

  void _showBottomModal(BuildContext context, String name, String address) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: true,
        title: const Text(
          "Карта",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(55.761335550558734, 37.60894706574121),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.flutter_map_example',
          ),
          MarkerLayer(
            markers: ecoCenters
                .map((e) => Marker(
                      point: e["point"],
                      child: InkWell(
                        onTap: () {
                          _showBottomModal(
                            context,
                            e['name'],
                            e['address'],
                          );
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset("assets/leave.png"),
                            )),
                      ),
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
