import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CompFacilityNav extends StatefulWidget {
  final double latitude = 18.559117344247614;
  final double longitude = 73.77516494295556;
  final String facilityName = 'ProEarth Ecosystems';

  const CompFacilityNav({Key? key}) : super(key: key);

  @override
  _CompFacilityNavState createState() => _CompFacilityNavState();
}

class _CompFacilityNavState extends State<CompFacilityNav> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location: ${widget.facilityName ?? ''}',
            style: TextStyle(fontSize: 20)),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(widget.latitude ?? 0, widget.longitude ?? 0),
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(widget.latitude ?? 0, widget.longitude ?? 0),
                child: const Icon(Icons.location_on_outlined,
                    color: Colors.redAccent, size: 35),
              )
            ],
          ),
        ],
      ),
    );
  }
}
